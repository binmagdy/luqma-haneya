import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FavoritesLocalDataSource {
  static const _k = 'favorite_recipe_ids_json_v1';

  Future<Set<String>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_k);
    if (raw == null || raw.isEmpty) return {};
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => e.toString()).toSet();
  }

  Future<void> save(Set<String> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k, json.encode(ids.toList()));
  }
}
