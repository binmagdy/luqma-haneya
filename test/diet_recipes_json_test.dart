import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqma_haneya/data/models/recipe_model.dart';
import 'package:luqma_haneya/domain/value_objects/recipe_category.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('assets/diet_recipes.json parses 20 diet recipes with nutrition',
      () async {
    final raw = await rootBundle.loadString('assets/diet_recipes.json');
    final list = jsonDecode(raw) as List<dynamic>;
    expect(list.length, 20);

    for (final item in list) {
      final map = Map<String, dynamic>.from(item as Map);
      final model = RecipeModel.fromJson(map);
      expect(model.recipeCategory, RecipeCategory.diet);
      expect(model.hasNutritionInfo, isTrue);
      expect(model.calories, greaterThan(0));
      expect(model.steps, isNotEmpty);
      expect(model.mainIngredients, isNotEmpty);
    }
  });
}
