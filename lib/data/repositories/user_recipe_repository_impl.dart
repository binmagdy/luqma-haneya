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
