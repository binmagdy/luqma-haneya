import '../value_objects/recipe_schema.dart';

class RecipeEntity {
  const RecipeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.minutes,
    required this.servings,
    required this.steps,
    required this.tags,
    required this.mealType,
    required this.difficulty,
    required this.budget,
    required this.spicy,
    required this.cuisine,
    required this.mainIngredients,
    required this.optionalIngredients,
  });

  final String id;
  final String title;
  final String description;
  final int minutes;
  final int servings;
  final List<String> steps;
  final List<String> tags;

  /// One of [RecipeMealType] values.
  final String mealType;

  /// One of [RecipeDifficulty] values.
  final String difficulty;

  /// One of [RecipeBudget] values.
  final String budget;

  final bool spicy;

  /// Short cuisine slug, e.g. `egyptian`, `mixed`.
  final String cuisine;

  final List<String> mainIngredients;
  final List<String> optionalIngredients;

  /// All ingredient lines (main then optional) for lists and legacy call sites.
  List<String> get ingredients => [...mainIngredients, ...optionalIngredients];
}
