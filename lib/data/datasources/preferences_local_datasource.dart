import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_preferences_entity.dart';

class PreferencesLocalDataSource {
  static const _kOnboarding = 'onboarding_complete';
  static const _kPrefs = 'user_preferences_json';

  Future<bool> isOnboardingComplete() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kOnboarding) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kOnboarding, value);
  }

  Future<UserPreferencesEntity> loadPreferences() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kPrefs);
    if (raw == null) return const UserPreferencesEntity();
    final map = json.decode(raw) as Map<String, dynamic>;
    return UserPreferencesEntity(
      vegetarian: map['vegetarian'] as bool? ?? false,
      avoidSpicy: map['avoidSpicy'] as bool? ?? true,
      quickMealsPreferred: map['quickMealsPreferred'] as bool? ?? false,
      economicalMealsPreferred:
          map['economicalMealsPreferred'] as bool? ?? false,
      preferredMealType: map['preferredMealType'] as String?,
      favoriteTags: _stringList(map['favoriteTags']),
      favoriteIngredients: _stringList(map['favoriteIngredients']),
      allergies: _stringList(map['allergies']),
      dislikedIngredients: _stringList(map['dislikedIngredients']),
    );
  }

  Future<void> savePreferences(UserPreferencesEntity prefs) async {
    final sp = await SharedPreferences.getInstance();
    final map = {
      'vegetarian': prefs.vegetarian,
      'avoidSpicy': prefs.avoidSpicy,
      'quickMealsPreferred': prefs.quickMealsPreferred,
      'economicalMealsPreferred': prefs.economicalMealsPreferred,
      'preferredMealType': prefs.preferredMealType,
      'favoriteTags': prefs.favoriteTags,
      'favoriteIngredients': prefs.favoriteIngredients,
      'allergies': prefs.allergies,
      'dislikedIngredients': prefs.dislikedIngredients,
    };
    await sp.setString(_kPrefs, json.encode(map));
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (value is String) {
      return value
          .split(RegExp(r'[,،]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
