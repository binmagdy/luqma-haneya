import '../entities/recipe_entity.dart';

abstract class UserRecipeRepository {
  Future<List<RecipeEntity>> submittedRecipes();

  Future<void> submit(RecipeEntity recipe);

  /// Firestore `recipes` where `createdBy == [uid]`, merged with unsynced local rows.
  Future<List<RecipeEntity>> mySubmittedFromRemote(String uid);
}
