import '../entities/user_preferences_entity.dart';

abstract class PreferencesRepository {
  Future<bool> isOnboardingComplete();

  Future<void> setOnboardingComplete(bool value);

  Future<UserPreferencesEntity> loadPreferences();

  Future<void> savePreferences(UserPreferencesEntity prefs);
}
