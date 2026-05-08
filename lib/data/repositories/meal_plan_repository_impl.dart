import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../../domain/services/meal_plan_slot_codec.dart';
import '../datasources/meal_plan_local_datasource.dart';
import '../datasources/meal_plan_remote_datasource.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  MealPlanRepositoryImpl({
    required MealPlanLocalDataSource local,
    required MealPlanRemoteDataSource remote,
    required AuthRepository auth,
  })  : _local = local,
        _remote = remote,
        _auth = auth;

  final MealPlanLocalDataSource _local;
  final MealPlanRemoteDataSource _remote;
  final AuthRepository _auth;

  Future<String> _syncId() async => (await _auth.readSession()).firestoreSyncId;

  Future<Map<String, String>> _merged(String weekKey) async {
    final local = await _local.load(weekKey);
    final deviceId = await _syncId();
    final remote = await _remote.tryLoad(deviceId, weekKey);
    if (kDebugMode) {
      debugPrint(
        'MealPlanRepositoryImpl._merged week=$weekKey '
        'localKeys=${local.length} remoteKeys=${remote?.length ?? 0}',
      );
    }
    if (remote == null || remote.isEmpty) return local;
    if (local.isEmpty) return remote;
    return {...remote, ...local};
  }

  Future<void> _persist(String weekKey, Map<String, String> next) async {
    await _local.save(weekKey, next);
    if (!_remote.isAvailable) {
      if (kDebugMode) {
        debugPrint(
            'MealPlanRepositoryImpl._persist: skip remote (unavailable)');
      }
      return;
    }
    try {
      final deviceId = await _syncId();
      await _remote.upsert(deviceId, weekKey, next);
      if (kDebugMode) {
        debugPrint(
          'MealPlanRepositoryImpl._persist: remote ok week=$weekKey keys=${next.length}',
        );
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          'MealPlanRepositoryImpl._persist: remote failed (local saved) week=$weekKey $e\n$st',
        );
      }
    }
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

  @override
  Future<void> applySmartAssignments(
    String weekKey,
    Map<String, String> generated,
  ) async {
    final current = await _merged(weekKey);
    final next = Map<String, String>.from(current);
    for (final e in generated.entries) {
      final prev = current[e.key];
      if (prev != null && MealPlanSlotCodec.isLocked(prev)) {
        continue;
      }
      next[e.key] = e.value;
    }
    if (kDebugMode) {
      debugPrint(
        'MealPlanRepositoryImpl.applySmartAssignments week=$weekKey '
        'generated=${generated.length} merged=${next.length}',
      );
    }
    await _persist(weekKey, next);
  }

  @override
  Future<void> replaceSlot(
    String weekKey,
    String slotKey,
    String recipeId,
    String recipeTitle, {
    int servings = 4,
  }) async {
    final current = await _merged(weekKey);
    final prev = MealPlanSlotCodec.decode(current[slotKey]);
    final locked = prev?.locked ?? false;
    final next = Map<String, String>.from(current);
    next[slotKey] = MealPlanSlotCodec.encode(
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      servings: servings,
      locked: locked,
      generatedAt: prev?.generatedAt,
    );
    await _persist(weekKey, next);
  }

  @override
  Future<void> setSlotLocked(
    String weekKey,
    String slotKey,
    bool locked,
  ) async {
    final current = await _merged(weekKey);
    final raw = current[slotKey];
    if (raw == null) return;
    final p = MealPlanSlotCodec.decode(raw);
    if (p == null) return;
    final next = Map<String, String>.from(current);
    next[slotKey] = MealPlanSlotCodec.encode(
      recipeId: p.recipeId,
      recipeTitle: p.recipeTitle,
      servings: p.servings,
      locked: locked,
      generatedAt: p.generatedAt,
    );
    await _persist(weekKey, next);
  }
}
