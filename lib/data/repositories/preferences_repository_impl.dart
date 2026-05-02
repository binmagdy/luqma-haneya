import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_local_datasource.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl(this._local);

  final PreferencesLocalDataSource _local;

  @override
  Future<bool> isOnboardingComplete() => _local.isOnboardingComplete();

  @override
  Future<void> setOnboardingComplete(bool value) =>
      _local.setOnboardingComplete(value);

  @override
  Future<UserPreferencesEntity> loadPreferences() => _local.loadPreferences();

  @override
  Future<void> savePreferences(UserPreferencesEntity prefs) =>
      _local.savePreferences(prefs);
}
