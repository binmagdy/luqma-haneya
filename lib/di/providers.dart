import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/bootstrap.dart';
import '../data/datasources/favorites_local_datasource.dart';
import '../data/datasources/favorites_remote_datasource.dart';
import '../data/datasources/meal_plan_local_datasource.dart';
import '../data/datasources/meal_plan_remote_datasource.dart';
import '../data/datasources/preferences_local_datasource.dart';
import '../data/datasources/rating_local_datasource.dart';
import '../data/datasources/rating_remote_datasource.dart';
import '../data/datasources/recipe_local_datasource.dart';
import '../data/datasources/recipe_remote_datasource.dart';
import '../data/datasources/user_identity_local_datasource.dart';
import '../data/datasources/user_recipe_local_datasource.dart';
import '../data/datasources/user_recipe_remote_datasource.dart';
import '../data/datasources/viewed_recipes_local_datasource.dart';
import '../data/repositories/favorites_repository_impl.dart';
import '../data/repositories/meal_plan_repository_impl.dart';
import '../data/repositories/preferences_repository_impl.dart';
import '../data/repositories/rating_repository_impl.dart';
import '../data/repositories/recipe_repository_impl.dart';
import '../data/repositories/user_recipe_repository_impl.dart';
import '../domain/entities/recipe_entity.dart';
import '../domain/entities/recipe_rating_summary.dart';
import '../domain/repositories/favorites_repository.dart';
import '../domain/repositories/meal_plan_repository.dart';
import '../domain/repositories/preferences_repository.dart';
import '../domain/repositories/rating_repository.dart';
import '../domain/repositories/recipe_repository.dart';
import '../domain/repositories/user_recipe_repository.dart';

final preferencesLocalDsProvider = Provider<PreferencesLocalDataSource>(
  (ref) => PreferencesLocalDataSource(),
);

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepositoryImpl(ref.watch(preferencesLocalDsProvider)),
);

final userIdentityDsProvider = Provider<UserIdentityLocalDataSource>(
  (ref) => UserIdentityLocalDataSource(),
);

final viewedRecipesLocalDsProvider = Provider<ViewedRecipesLocalDataSource>(
  (ref) => ViewedRecipesLocalDataSource(),
);

final recipeLocalDsProvider = Provider<RecipeLocalDataSource>(
  (ref) => RecipeLocalDataSource(),
);

final recipeRemoteDsProvider = Provider<RecipeRemoteDataSource>(
  (ref) => RecipeRemoteDataSource(
    firebaseAppReady ? FirebaseFirestore.instance : null,
  ),
);

final ratingLocalDsProvider = Provider<RatingLocalDataSource>(
  (ref) => RatingLocalDataSource(),
);

final ratingRemoteDsProvider = Provider<RatingRemoteDataSource>(
  (ref) => RatingRemoteDataSource(
    firebaseAppReady ? FirebaseFirestore.instance : null,
  ),
);

final ratingRepositoryProvider = Provider<RatingRepository>(
  (ref) => RatingRepositoryImpl(
    local: ref.watch(ratingLocalDsProvider),
    remote: ref.watch(ratingRemoteDsProvider),
    identity: ref.watch(userIdentityDsProvider),
  ),
);

final favoritesLocalDsProvider = Provider<FavoritesLocalDataSource>(
  (ref) => FavoritesLocalDataSource(),
);

final favoritesRemoteDsProvider = Provider<FavoritesRemoteDataSource>(
  (ref) => FavoritesRemoteDataSource(
    firebaseAppReady ? FirebaseFirestore.instance : null,
  ),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepositoryImpl(
    local: ref.watch(favoritesLocalDsProvider),
    remote: ref.watch(favoritesRemoteDsProvider),
    identity: ref.watch(userIdentityDsProvider),
  ),
);

final userRecipeLocalDsProvider = Provider<UserRecipeLocalDataSource>(
  (ref) => UserRecipeLocalDataSource(),
);

final userRecipeRemoteDsProvider = Provider<UserRecipeRemoteDataSource>(
  (ref) => UserRecipeRemoteDataSource(
    firebaseAppReady ? FirebaseFirestore.instance : null,
  ),
);

final userRecipeRepositoryProvider = Provider<UserRecipeRepository>(
  (ref) => UserRecipeRepositoryImpl(
    local: ref.watch(userRecipeLocalDsProvider),
    remote: ref.watch(userRecipeRemoteDsProvider),
  ),
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => RecipeRepositoryImpl(
    local: ref.watch(recipeLocalDsProvider),
    remote: ref.watch(recipeRemoteDsProvider),
    userRecipes: ref.watch(userRecipeRepositoryProvider),
    ratingRepository: ref.watch(ratingRepositoryProvider),
    favoritesRepository: ref.watch(favoritesRepositoryProvider),
    viewedRecipesLocal: ref.watch(viewedRecipesLocalDsProvider),
  ),
);

final mealPlanLocalDsProvider = Provider<MealPlanLocalDataSource>(
  (ref) => MealPlanLocalDataSource(),
);

final mealPlanRemoteDsProvider = Provider<MealPlanRemoteDataSource>(
  (ref) => MealPlanRemoteDataSource(
    firebaseAppReady ? FirebaseFirestore.instance : null,
  ),
);

final mealPlanRepositoryProvider = Provider<MealPlanRepository>(
  (ref) => MealPlanRepositoryImpl(
    local: ref.watch(mealPlanLocalDsProvider),
    remote: ref.watch(mealPlanRemoteDsProvider),
    identity: ref.watch(userIdentityDsProvider),
  ),
);

final firebaseReadyProvider = Provider<bool>((ref) => firebaseAppReady);

final allRecipesCatalogProvider = FutureProvider<List<RecipeEntity>>(
  (ref) => ref.watch(recipeRepositoryProvider).getAllRecipes(),
);

final ratingSummariesProvider =
    FutureProvider<Map<String, RecipeRatingSummary>>(
  (ref) => ref.watch(ratingRepositoryProvider).getAllCachedSummaries(),
);

final favoriteIdsProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(favoritesRepositoryProvider).favoriteRecipeIds(),
);

final myRatingProvider = FutureProvider.family<int?, String>(
  (ref, recipeId) => ref.watch(ratingRepositoryProvider).getMyRating(recipeId),
);

final suggestionBundleProvider = FutureProvider<
    ({
      List<RecipeEntity> suggestions,
      Set<String> favorites,
      Map<String, RecipeRatingSummary> summaries,
    })>((ref) async {
  final prefs = await ref.read(preferencesRepositoryProvider).loadPreferences();
  final suggestions =
      await ref.read(recipeRepositoryProvider).suggestForToday(prefs);
  final favorites =
      await ref.read(favoritesRepositoryProvider).favoriteRecipeIds();
  final summaries =
      await ref.read(ratingRepositoryProvider).getAllCachedSummaries();
  return (
    suggestions: suggestions,
    favorites: favorites,
    summaries: summaries,
  );
});
