import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Recent recipe ids the user opened (detail screen), newest first.
class ViewedRecipesLocalDataSource {
  static const _k = 'viewed_recipe_ids_json_v1';
  static const _max = 32;

  Future<List<String>> loadOrdered() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_k);
    if (raw == null || raw.isEmpty) return const [];
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => e.toString()).toList();
  }

  Future<void> recordView(String recipeId) async {
    final sp = await SharedPreferences.getInstance();
    var list = await loadOrdered();
    list = list.where((id) => id != recipeId).toList();
    list.insert(0, recipeId);
    if (list.length > _max) {
      list = list.sublist(0, _max);
    }
    await sp.setString(_k, json.encode(list));
  }
}
