import '../entities/recipe_entity.dart';
import '../entities/user_preferences_entity.dart';
import '../value_objects/recipe_category.dart';

/// Max rows on the suggestions screen only; browse/search are not capped here.
const int kDailySuggestionDisplayLimit = 10;

abstract class RecipeRepository {
  Future<List<RecipeEntity>> getAllRecipes();

  Future<List<RecipeEntity>> getRecipesByCategory(String category);

  Future<RecipeEntity?> getRecipeById(String id);

  Future<List<RecipeEntity>> suggestForToday(
    UserPreferencesEntity prefs, {
    Set<String> trendingRecipeIds = const {},
    String suggestionMode = RecipeCategory.normal,
  });

  Future<List<RecipeEntity>> findByPantryIngredients(
    List<String> ingredients,
    UserPreferencesEntity prefs, {
    String recipeCategory = RecipeCategory.normal,
  });
}
