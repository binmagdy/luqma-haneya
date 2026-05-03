import '../entities/recipe_rating_summary.dart';

abstract class RatingRepository {
  /// Current device user's 1–5 rating for this recipe, or null if never rated.
  Future<int?> getMyRating(String recipeId);

  /// All star ratings submitted on this device (for personalization).
  Future<Map<String, int>> allMyRatings();

  Future<RecipeRatingSummary?> getSummary(String recipeId);

  /// All cached summaries (for browse lists). May be sparse offline.
  Future<Map<String, RecipeRatingSummary>> getAllCachedSummaries();

  /// Persists locally. If [publishPublic] is true, syncs to Firestore as a public
  /// rating (requires signed-in Firebase user). Otherwise stays local-only.
  Future<void> setMyRating(
    String recipeId,
    int stars, {
    required bool publishPublic,
  });
}
