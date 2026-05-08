import '../entities/recipe_entity.dart';
import '../entities/user_preferences_entity.dart';

/// Max rows on the suggestions screen only; browse/search are not capped here.
const int kDailySuggestionDisplayLimit = 10;

abstract class RecipeRepository {
  Future<List<RecipeEntity>> getAllRecipes();

  Future<RecipeEntity?> getRecipeById(String id);

  Future<List<RecipeEntity>> suggestForToday(
    UserPreferencesEntity prefs, {
    Set<String> trendingRecipeIds = const {},
  });

  Future<List<RecipeEntity>> findByPantryIngredients(
    List<String> ingredients,
    UserPreferencesEntity prefs,
  );
}
