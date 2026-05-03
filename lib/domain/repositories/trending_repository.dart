import '../entities/recipe_entity.dart';

abstract class TrendingRepository {
  /// Trending this ISO week, then all-time, then heuristic fallback.
  Future<List<RecipeEntity>> trendingRecipes(
    List<RecipeEntity> catalog,
  );
}
