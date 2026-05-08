import 'package:flutter/foundation.dart';

import '../../core/bootstrap.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/rating_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/user_recipe_repository.dart';
import '../../domain/services/recipe_scoring_service.dart';
import '../datasources/recipe_local_datasource.dart';
import '../datasources/recipe_remote_datasource.dart';
import '../datasources/viewed_recipes_local_datasource.dart';
import '../models/recipe_model.dart';
import '../recipe_content_merge.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  RecipeRepositoryImpl({
    required RecipeLocalDataSource local,
    required RecipeRemoteDataSource remote,
    required UserRecipeRepository userRecipes,
    required RatingRepository ratingRepository,
    required FavoritesRepository favoritesRepository,
    required ViewedRecipesLocalDataSource viewedRecipesLocal,
  })  : _local = local,
        _remote = remote,
        _userRecipes = userRecipes,
        _rating = ratingRepository,
        _favorites = favoritesRepository,
        _viewed = viewedRecipesLocal;

  final RecipeLocalDataSource _local;
  final RecipeRemoteDataSource _remote;
  final UserRecipeRepository _userRecipes;
  final RatingRepository _rating;
  final FavoritesRepository _favorites;
  final ViewedRecipesLocalDataSource _viewed;

  Future<List<RecipeModel>> _resolvedCatalog() async {
    final bundled = await _local.loadBundledRecipes();
    final submitted = await _userRecipes.submittedRecipes();
    final byId = <String, RecipeModel>{};

    for (final r in bundled) {
      byId[r.id] = r;
    }
    for (final e in submitted) {
      final m = RecipeModel.fromEntity(e);
      byId[m.id] = RecipeContentMerge.mergeByRecipeId(byId[m.id], m);
    }

    if (firebaseAppReady && _remote.isAvailable) {
      try {
        final remote = await _remote.fetchRecipes();
        if (kDebugMode) {
          debugPrint(
            'RecipeRepositoryImpl._resolvedCatalog: bundled=${bundled.length} '
            'submitted=${submitted.length} remote=${remote.length} '
            'idsAfterLocal=${byId.length}',
          );
        }
        for (final r in remote) {
          byId[r.id] = RecipeContentMerge.mergeByRecipeId(byId[r.id], r);
        }
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('RecipeRepositoryImpl._resolvedCatalog remote: $e $st');
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
        'RecipeRepositoryImpl._resolvedCatalog: total merged=${byId.length}',
      );
    }
    return byId.values.toList();
  }

  Future<RecipeSuggestionContext> _suggestionContext(
    List<RecipeModel> all, {
    Set<String> trendingRecipeIds = const {},
    Set<String> penalizedRecipeIds = const {},
  }) async {
    final favIds = await _favorites.favoriteRecipeIds();
    final favRecipes = <RecipeEntity>[];
    for (final r in all) {
      if (favIds.contains(r.id)) favRecipes.add(r);
    }

    final myRatings = await _rating.allMyRatings();
    final highRated = <RecipeEntity>[];
    for (final r in all) {
      final v = myRatings[r.id];
      if (v != null && v >= 4) highRated.add(r);
    }

    final viewedIds = await _viewed.loadOrdered();
    final recent = <RecipeEntity>[];
    for (final id in viewedIds.take(10)) {
      for (final r in all) {
        if (r.id == id) {
          recent.add(r);
          break;
        }
      }
    }

    return RecipeSuggestionContext(
      favoriteRecipeIds: favIds,
      favoriteRecipes: favRecipes,
      highRatedRecipes: highRated,
      recentlyViewedRecipes: recent,
      trendingRecipeIds: trendingRecipeIds,
      penalizedRecipeIds: penalizedRecipeIds,
    );
  }

  @override
  Future<List<RecipeEntity>> getAllRecipes() => _resolvedCatalog();

  @override
  Future<RecipeEntity?> getRecipeById(String id) async {
    final all = await _resolvedCatalog();
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  Future<List<RecipeEntity>> suggestForToday(
    UserPreferencesEntity prefs, {
    Set<String> trendingRecipeIds = const {},
  }) async {
    final all = await _resolvedCatalog();
    final viewed = await _viewed.loadOrdered();
    final penalized = viewed.take(6).toSet();
    final ctx = await _suggestionContext(
      all,
      trendingRecipeIds: trendingRecipeIds,
      penalizedRecipeIds: penalized,
    );
    final ranked = <MapEntry<RecipeModel, double>>[];

    for (final r in all) {
      final s = RecipeScoringService.scoreForDailySuggestion(
        r,
        prefs,
        context: ctx,
      );
      if (s == null) continue;
      ranked.add(MapEntry(r, s));
    }
    ranked.sort((a, b) => b.value.compareTo(a.value));

    RecipeScoringService.debugLogRanking(
      label: 'suggestForToday',
      ranked: ranked.map((e) => MapEntry<RecipeEntity, double>(e.key, e.value)),
    );

    final passed = ranked
        .where((e) => e.value >= RecipeScoringService.minSuggestionScore)
        .toList();
    final pool = passed.isNotEmpty ? passed : ranked;

    if (kDebugMode && pool.isNotEmpty) {
      for (final e in pool.take(5)) {
        debugPrint(
          RecipeScoringService.describeScoreForDebug(
            recipe: e.key,
            prefs: prefs,
            mode: 'daily',
          ),
        );
      }
    }

    return pool.take(kDailySuggestionDisplayLimit).map((e) => e.key).toList();
  }

  @override
  Future<List<RecipeEntity>> findByPantryIngredients(
    List<String> ingredients,
    UserPreferencesEntity prefs,
  ) async {
    if (ingredients.isEmpty) return const [];
    final normalized = ingredients
        .map(RecipeScoringService.normalize)
        .where((s) => s.length >= 2)
        .toList();
    if (normalized.isEmpty) return const [];

    final all = await _resolvedCatalog();
    final ranked = <MapEntry<RecipeModel, double>>[];

    for (final r in all) {
      final s = RecipeScoringService.scoreForPantry(r, prefs, normalized);
      if (s == null) continue;
      ranked.add(MapEntry(r, s));
    }
    ranked.sort((a, b) => b.value.compareTo(a.value));

    RecipeScoringService.debugLogRanking(
      label: 'findByPantryIngredients',
      ranked: ranked.map((e) => MapEntry<RecipeEntity, double>(e.key, e.value)),
    );

    final passed = ranked
        .where((e) => e.value >= RecipeScoringService.minPantryScore)
        .toList();
    final pool = passed.isNotEmpty ? passed : ranked;

    if (kDebugMode && pool.isNotEmpty) {
      for (final e in pool.take(8)) {
        debugPrint(
          RecipeScoringService.describeScoreForDebug(
            recipe: e.key,
            prefs: prefs,
            mode: 'pantry',
            pantryNormalized: normalized,
          ),
        );
      }
    }

    return pool.take(8).map((e) => e.key).toList();
  }
}
