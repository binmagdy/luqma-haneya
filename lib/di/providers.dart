import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/bootstrap.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/datasources/favorites_local_datasource.dart';
import '../data/datasources/favorites_remote_datasource.dart';
import '../data/datasources/meal_plan_local_datasource.dart';
import '../data/datasources/meal_plan_remote_datasource.dart';
import '../data/datasources/preferences_local_datasource.dart';
import '../data/datasources/public_stats_remote_datasource.dart';
import '../data/datasources/rating_local_datasource.dart';
import '../data/datasources/rating_remote_datasource.dart';
import '../data/datasources/recipe_local_datasource.dart';
import '../data/datasources/recipe_remote_datasource.dart';
import '../data/datasources/trending_remote_datasource.dart';
import '../data/datasources/user_identity_local_datasource.dart';
import '../data/datasources/user_profile_remote_datasource.dart';
import '../data/datasources/user_recipe_local_datasource.dart';
import '../data/datasources/user_recipe_remote_datasource.dart';
import '../data/datasources/viewed_recipes_local_datasource.dart';
import '../data/repositories/admin_moderation_repository_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/favorites_repository_impl.dart';
import '../data/repositories/meal_plan_repository_impl.dart';
import '../data/repositories/preferences_repository_impl.dart';
import '../data/repositories/rating_repository_impl.dart';
import '../data/repositories/recipe_repository_impl.dart';
import '../data/repositories/trending_repository_impl.dart';
import '../data/repositories/user_recipe_repository_impl.dart';
import '../domain/entities/app_user_context.dart';
import '../domain/entities/auth_session_entity.dart';
import '../domain/entities/recipe_entity.dart';
import '../domain/entities/recipe_rating_summary.dart';
import '../domain/repositories/admin_moderation_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/favorites_repository.dart';
import '../domain/repositories/meal_plan_repository.dart';
import '../domain/repositories/preferences_repository.dart';
import '../domain/repositories/rating_repository.dart';
import '../domain/repositories/recipe_repository.dart';
import '../domain/repositories/trending_repository.dart';
import '../domain/repositories/user_recipe_repository.dart';

final preferencesLocalDsProvider = Provider<PreferencesLocalDataSource>(
  (ref) => PreferencesLocalDataSource(),
);

final userProfileRemoteDsProvider = Provider<UserProfileRemoteDataSource>(
  (ref) => UserProfileRemoteDataSource(
    firebaseAppReady ? FirebaseFirestore.instance : null,
  ),
);

final publicStatsRemoteDsProvider = Provider<PublicStatsRemoteDataSource>(
  (ref) => PublicStatsRemoteDataSource(
    firebaseAppReady ? FirebaseFirestore.instance : null,
  ),
);

/// Community tag counts from Firestore (aggregated only; no PII).
final popularPreferencesProvider =
    FutureProvider<List<({String key, String label, int count})>>((ref) async {
  return ref.read(publicStatsRemoteDsProvider).fetchTopTags(limit: 16);
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepositoryImpl(
    ref.watch(preferencesLocalDsProvider),
    publicStats: ref.watch(publicStatsRemoteDsProvider),
    auth: ref.watch(authRepositoryProvider),
  ),
);

final userIdentityDsProvider = Provider<UserIdentityLocalDataSource>(
  (ref) => UserIdentityLocalDataSource(),
);

final authLocalDsProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    local: ref.watch(authLocalDsProvider),
    identity: ref.watch(userIdentityDsProvider),
    userProfileRemote: ref.watch(userProfileRemoteDsProvider),
  ),
);

final authSessionProvider = StreamProvider<AuthSessionEntity>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return Stream.fromFuture(repo.readSession())
      .asyncExpand((_) => repo.watchSession());
});

/// Auth session + Firestore `users/{uid}.role` (for admin UI and GoRouter).
final appUserContextProvider = StreamProvider<AppUserContext>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final profile = ref.watch(userProfileRemoteDsProvider);
  return auth.watchSession().asyncExpand((session) {
    if (session.firebaseUid == null || !profile.isAvailable) {
      return Stream.value(AppUserContext(session: session));
    }
    return profile
        .watchRole(session.firebaseUid!)
        .map((role) => AppUserContext(session: session, role: role));
  });
});

class _GoRouterRefreshBridge extends ChangeNotifier {
  _GoRouterRefreshBridge(this._ref) {
    _sub = _ref.listen(
      appUserContextProvider,
      (_, __) => notifyListeners(),
      fireImmediately: true,
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<AppUserContext>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

/// Notifies GoRouter when auth or admin role changes.
final goRouterAuthRefreshProvider = Provider<ChangeNotifier>((ref) {
  final bridge = _GoRouterRefreshBridge(ref);
  ref.onDispose(bridge.dispose);
  return bridge;
});

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
    auth: ref.watch(authRepositoryProvider),
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
    auth: ref.watch(authRepositoryProvider),
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
    authRepository: ref.watch(authRepositoryProvider),
    userProfileRemote: ref.watch(userProfileRemoteDsProvider),
  ),
);

final adminModerationRepositoryProvider = Provider<AdminModerationRepository>(
  (ref) => AdminModerationRepositoryImpl(
    firebaseAppReady ? FirebaseFirestore.instance : null,
  ),
);

final adminRecipesByStatusProvider =
    FutureProvider.family<List<RecipeEntity>, String>((ref, status) async {
  final ctx = await ref.watch(appUserContextProvider.future);
  if (!ctx.isAdmin) return const [];
  final list =
      await ref.read(recipeRemoteDsProvider).fetchRecipesByStatus(status);
  return List<RecipeEntity>.from(list);
});

final mySubmittedRecipesProvider = FutureProvider<List<RecipeEntity>>(
  (ref) async {
    final session = await ref.watch(authSessionProvider.future);
    final uid = session.firebaseUid;
    if (uid == null) return const [];
    return ref.read(userRecipeRepositoryProvider).mySubmittedFromRemote(uid);
  },
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
    auth: ref.watch(authRepositoryProvider),
  ),
);

final mealPlanWeekAssignmentsProvider =
    FutureProvider.autoDispose.family<Map<String, String>, String>(
  (ref, weekKey) => ref.watch(mealPlanRepositoryProvider).loadWeek(weekKey),
);

final firebaseReadyProvider = Provider<bool>((ref) => firebaseAppReady);

final allRecipesCatalogProvider = FutureProvider<List<RecipeEntity>>(
  (ref) => ref.watch(recipeRepositoryProvider).getAllRecipes(),
);

final trendingRemoteDsProvider = Provider<TrendingRemoteDataSource>(
  (ref) => TrendingRemoteDataSource(
    firebaseAppReady ? FirebaseFirestore.instance : null,
  ),
);

final trendingRepositoryProvider = Provider<TrendingRepository>(
  (ref) => TrendingRepositoryImpl(ref.watch(trendingRemoteDsProvider)),
);

final trendingRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  final cat = await ref.watch(allRecipesCatalogProvider.future);
  final sums = await ref.watch(ratingSummariesProvider.future);
  return ref.watch(trendingRepositoryProvider).trendingRecipes(
        cat,
        ratingSummaries: sums,
      );
});

final ratingSummariesProvider =
    FutureProvider<Map<String, RecipeRatingSummary>>((ref) async {
  final catalog = await ref.watch(allRecipesCatalogProvider.future);
  return ref
      .watch(ratingRepositoryProvider)
      .buildMergedSummariesForCatalog(catalog);
});

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
  final trendingList = await ref.watch(trendingRecipesProvider.future);
  final trendingIds = trendingList.map((e) => e.id).toSet();
  final suggestions = await ref.read(recipeRepositoryProvider).suggestForToday(
        prefs,
        trendingRecipeIds: trendingIds,
      );
  final favorites =
      await ref.read(favoritesRepositoryProvider).favoriteRecipeIds();
  final summaries = await ref.watch(ratingSummariesProvider.future);
  return (
    suggestions: suggestions,
    favorites: favorites,
    summaries: summaries,
  );
});
