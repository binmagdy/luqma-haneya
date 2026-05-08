import 'package:flutter/foundation.dart';

import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/user_recipe_repository.dart';
import '../datasources/user_recipe_local_datasource.dart';
import '../datasources/user_recipe_remote_datasource.dart';
import '../models/recipe_model.dart';

class UserRecipeRepositoryImpl implements UserRecipeRepository {
  UserRecipeRepositoryImpl({
    required UserRecipeLocalDataSource local,
    required UserRecipeRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final UserRecipeLocalDataSource _local;
  final UserRecipeRemoteDataSource _remote;

  @override
  Future<List<RecipeEntity>> submittedRecipes() async {
    return _local.loadAll();
  }

  @override
  Future<List<RecipeEntity>> mySubmittedFromRemote(String uid) async {
    if (!_remote.isAvailable) {
      final local = await _local.loadAll();
      return local.where((r) => r.createdByUserId == uid).toList();
    }
    try {
      final remote = await _remote.fetchByCreator(uid);
      final byId = {for (final r in remote) r.id: r as RecipeEntity};
      final local = await _local.loadAll();
      for (final l in local) {
        if (l.createdByUserId != uid) continue;
        final m = RecipeModel.fromEntity(l);
        byId.putIfAbsent(m.id, () => m);
      }
      final list = byId.values.toList();
      int ts(RecipeEntity e) => e.createdAt?.millisecondsSinceEpoch ?? 0;
      list.sort((a, b) => ts(b).compareTo(ts(a)));
      return list;
    } catch (e, st) {
      debugPrint('UserRecipeRepositoryImpl.mySubmittedFromRemote: $e $st');
      final local = await _local.loadAll();
      return local.where((r) => r.createdByUserId == uid).toList();
    }
  }

  @override
  Future<void> submit(RecipeEntity recipe) async {
    final model = recipe is RecipeModel
        ? recipe
        : RecipeModel(
            id: recipe.id,
            title: recipe.title,
            description: recipe.description,
            minutes: recipe.minutes,
            servings: recipe.servings,
            steps: recipe.steps,
            tags: recipe.tags,
            mealType: recipe.mealType,
            difficulty: recipe.difficulty,
            budget: recipe.budget,
            spicy: recipe.spicy,
            cuisine: recipe.cuisine,
            mainIngredients: recipe.mainIngredients,
            optionalIngredients: recipe.optionalIngredients,
            source: recipe.source,
            createdByUserId: recipe.createdByUserId,
            createdAt: recipe.createdAt,
            isApproved: recipe.isApproved,
            moderationStatus: recipe.moderationStatus,
            visibility: recipe.visibility,
            rejectedReason: recipe.rejectedReason,
            updatedAt: recipe.updatedAt,
            approvedBy: recipe.approvedBy,
            approvedAt: recipe.approvedAt,
            rejectedBy: recipe.rejectedBy,
            rejectedAt: recipe.rejectedAt,
            averageRating: recipe.averageRating,
            ratingCount: recipe.ratingCount,
          );
    final existing = await _local.loadAll();
    final idx = existing.indexWhere((r) => r.id == model.id);
    if (idx >= 0) {
      existing[idx] = model;
    } else {
      existing.add(model);
    }
    await _local.saveAll(existing);
    if (_remote.isAvailable) {
      try {
        await _remote.upsertRecipe(model);
      } catch (e, st) {
        debugPrint('UserRecipeRepositoryImpl remote save failed: $e $st');
      }
    }
  }
}
