import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe_model.dart';

class UserRecipeLocalDataSource {
  static const _k = 'user_submitted_recipes_json_v1';

  Future<List<RecipeModel>> loadAll() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_k);
    if (raw == null || raw.isEmpty) return const [];
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<RecipeModel> recipes) async {
    final sp = await SharedPreferences.getInstance();
    final encoded = recipes.map((r) => r.toJson()).toList();
    await sp.setString(_k, json.encode(encoded));
  }
}
