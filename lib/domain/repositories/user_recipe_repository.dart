import '../entities/recipe_entity.dart';

abstract class UserRecipeRepository {
  Future<List<RecipeEntity>> submittedRecipes();

  Future<void> submit(RecipeEntity recipe);
}
