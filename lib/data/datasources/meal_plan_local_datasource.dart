import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MealPlanLocalDataSource {
  static String _key(String weekKey) => 'meal_plan_$weekKey';

  Future<Map<String, String>> load(String weekKey) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key(weekKey));
    if (raw == null) return {};
    final map = json.decode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as String));
  }

  Future<void> save(String weekKey, Map<String, String> assignments) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key(weekKey), json.encode(assignments));
  }
}
