abstract class FavoritesRepository {
  Future<Set<String>> favoriteRecipeIds();

  Future<bool> isFavorite(String recipeId);

  Future<void> setFavorite(String recipeId, bool value);
}
