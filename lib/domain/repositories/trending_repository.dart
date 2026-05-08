import '../entities/recipe_entity.dart';
import '../entities/recipe_rating_summary.dart';

abstract class TrendingRepository {
  /// Trending this ISO week, then all-time, then catalog sort by public ratings.
  Future<List<RecipeEntity>> trendingRecipes(
    List<RecipeEntity> catalog, {
    Map<String, RecipeRatingSummary>? ratingSummaries,
  });
}
