import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqma_haneya/data/models/recipe_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('assets/recipes.json parses 100 detailed recipes', () async {
    final raw = await rootBundle.loadString('assets/recipes.json');
    final list = jsonDecode(raw) as List<dynamic>;
    expect(list.length, 100);

    final ids = <String>{};
    for (final item in list) {
      final map = Map<String, dynamic>.from(item as Map);
      final model = RecipeModel.fromJson(map);
      expect(model.id, isNotEmpty);
      expect(model.title, isNotEmpty);
      expect(model.steps, isNotEmpty);
      expect(model.mainIngredients, isNotEmpty);
      expect(model.chefTips, isNotEmpty);
      expect(model.servingSuggestions, isNotEmpty);
      for (final key in [
        'tags',
        'mainIngredients',
        'optionalIngredients',
        'steps',
        'chefTips',
        'servingSuggestions',
      ]) {
        expect(map[key], isA<List>());
      }
      expect(ids.add(model.id), isTrue, reason: 'duplicate id ${model.id}');
    }
  });
}
