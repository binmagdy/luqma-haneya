import '../entities/recipe_entity.dart';
import '../entities/user_preferences_entity.dart';

abstract class RecipeRepository {
  Future<List<RecipeEntity>> getAllRecipes();

  Future<RecipeEntity?> getRecipeById(String id);

  Future<List<RecipeEntity>> suggestForToday(UserPreferencesEntity prefs);

  Future<List<RecipeEntity>> findByPantryIngredients(
    List<String> ingredients,
    UserPreferencesEntity prefs,
  );
}
