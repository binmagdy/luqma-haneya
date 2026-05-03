abstract class FavoritesRepository {
  Future<Set<String>> favoriteRecipeIds();

  Future<bool> isFavorite(String recipeId);

  Future<void> setFavorite(String recipeId, bool value);

  Future<Set<String>> getFavorites() => favoriteRecipeIds();

  Future<void> addFavorite(String recipeId) => setFavorite(recipeId, true);

  Future<void> removeFavorite(String recipeId) => setFavorite(recipeId, false);
}
