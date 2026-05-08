import '../entities/recipe_entity.dart';

/// Admin-only recipe moderation and catalog maintenance (Firestore).
abstract class AdminModerationRepository {
  Future<void> approveRecipe({
    required String recipeId,
    required String adminUid,
  });

  Future<void> rejectRecipe({
    required String recipeId,
    required String adminUid,
    required String reason,
  });

  Future<void> setVisibility({
    required String recipeId,
    required String visibility,
  });

  Future<void> deleteRecipe(String recipeId);

  /// Full recipe body + moderation-safe fields; keeps approved recipes approved.
  Future<void> saveRecipeDocument(RecipeEntity recipe);
}
