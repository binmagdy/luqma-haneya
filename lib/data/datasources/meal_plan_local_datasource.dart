import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MealPlanLocalDataSource {
  static const _prefix = 'meal_plan_';
  static String _key(String weekKey) => '$_prefix$weekKey';

  /// Week keys that have any saved assignments on this device.
  Future<List<String>> listStoredWeekKeys() async {
    final sp = await SharedPreferences.getInstance();
    final out = <String>[];
    for (final k in sp.getKeys()) {
      if (k.startsWith(_prefix)) {
        out.add(k.substring(_prefix.length));
      }
    }
    out.sort();
    return out;
  }

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
