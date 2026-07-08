import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/value_objects/recipe_category.dart';
import '../models/recipe_model.dart';

class RecipeLocalDataSource {
  List<RecipeModel>? _cache;

  Future<List<RecipeModel>> loadBundledRecipes() async {
    if (_cache != null) return _cache!;
    final normal = await _loadAssetFile(
      'assets/recipes.json',
      defaultCategory: RecipeCategory.normal,
    );
    final diet = await _loadAssetFile(
      'assets/diet_recipes.json',
      defaultCategory: RecipeCategory.diet,
    );
    _cache = [...normal, ...diet];
    return _cache!;
  }

  Future<List<RecipeModel>> _loadAssetFile(
    String path, {
    required String defaultCategory,
  }) async {
    final raw = await rootBundle.loadString(path);
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      map.putIfAbsent('recipeCategory', () => defaultCategory);
      return RecipeModel.fromJson(map);
    }).toList();
  }
}
