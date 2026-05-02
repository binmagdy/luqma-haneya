import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/recipe_model.dart';

class RecipeLocalDataSource {
  List<RecipeModel>? _cache;

  Future<List<RecipeModel>> loadBundledRecipes() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/recipes.json');
    final list = json.decode(raw) as List<dynamic>;
    _cache = list
        .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }
}
