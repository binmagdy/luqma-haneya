import 'package:flutter/foundation.dart';

import '../../core/bootstrap.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/services/recipe_scoring_service.dart';
import '../datasources/recipe_local_datasource.dart';
import '../datasources/recipe_remote_datasource.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  RecipeRepositoryImpl({
    required RecipeLocalDataSource local,
    required RecipeRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final RecipeLocalDataSource _local;
  final RecipeRemoteDataSource _remote;

  Future<List<RecipeModel>> _resolvedCatalog() async {
    final bundled = await _local.loadBundledRecipes();
    if (firebaseAppReady) {
      try {
        final remote = await _remote.fetchRecipes();
        if (remote.isNotEmpty) return remote;
      } catch (_) {
        /* use bundled */
      }
    }
    return bundled;
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
    UserPreferencesEntity prefs,
  ) async {
    final all = await _resolvedCatalog();
    final ranked = <MapEntry<RecipeModel, double>>[];

    for (final r in all) {
      final s = RecipeScoringService.scoreForDailySuggestion(r, prefs);
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

    return pool.take(5).map((e) => e.key).toList();
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
