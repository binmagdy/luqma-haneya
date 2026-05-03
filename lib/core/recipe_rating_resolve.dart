import '../domain/entities/recipe_entity.dart';
import '../domain/entities/recipe_rating_summary.dart';

RecipeRatingSummary? resolveRatingDisplay(
  RecipeEntity recipe,
  Map<String, RecipeRatingSummary> cache,
) {
  final c = cache[recipe.id];
  if (c != null && c.hasRatings) return c;
  final a = recipe.averageRating;
  final n = recipe.ratingCount;
  if (a != null && n != null && n > 0) {
    return RecipeRatingSummary(average: a, count: n);
  }
  return null;
}
