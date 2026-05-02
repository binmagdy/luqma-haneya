import '../../domain/repositories/meal_plan_repository.dart';
import '../datasources/meal_plan_local_datasource.dart';
import '../datasources/meal_plan_remote_datasource.dart';
import '../datasources/user_identity_local_datasource.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  MealPlanRepositoryImpl({
    required MealPlanLocalDataSource local,
    required MealPlanRemoteDataSource remote,
    required UserIdentityLocalDataSource identity,
  })  : _local = local,
        _remote = remote,
        _identity = identity;

  final MealPlanLocalDataSource _local;
  final MealPlanRemoteDataSource _remote;
  final UserIdentityLocalDataSource _identity;

  Future<Map<String, String>> _merged(String weekKey) async {
    final local = await _local.load(weekKey);
    final deviceId = await _identity.getOrCreateDeviceId();
    final remote = await _remote.tryLoad(deviceId, weekKey);
    if (remote == null || remote.isEmpty) return local;
    if (local.isEmpty) return remote;
    return {...remote, ...local};
  }

  Future<void> _persist(String weekKey, Map<String, String> next) async {
    await _local.save(weekKey, next);
    final deviceId = await _identity.getOrCreateDeviceId();
    await _remote.upsert(deviceId, weekKey, next);
  }

  @override
  Future<Map<String, String>> loadWeek(String weekKey) => _merged(weekKey);

  @override
  Future<void> saveDayAssignment(
    String weekKey,
    String dayKey,
    String recipeId,
    String recipeTitle,
  ) async {
    final current = await _merged(weekKey);
    final next = Map<String, String>.from(current);
    next[dayKey] = '$recipeId|$recipeTitle';
    await _persist(weekKey, next);
  }

  @override
  Future<void> clearDay(String weekKey, String dayKey) async {
    final current = await _merged(weekKey);
    final next = Map<String, String>.from(current)..remove(dayKey);
    await _persist(weekKey, next);
  }
}
