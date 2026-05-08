import 'package:flutter/foundation.dart';

import '../domain/value_objects/recipe_source.dart';
import 'models/recipe_model.dart';

/// Merges local + Firestore [RecipeModel]s so rating-only or partial cloud docs
/// never replace fully populated bundled/user recipes.
abstract class RecipeContentMerge {
  /// Heuristic: higher = more complete recipe *content* (not ratings).
  static int completenessScore(RecipeModel r) {
    var s = 0;
    if (r.title.trim().isNotEmpty) s += 200;
    if (r.description.trim().isNotEmpty) s += 40;
    if (r.mainIngredients.isNotEmpty) {
      s += 80 + r.mainIngredients.length * 2;
    }
    if (r.steps.isNotEmpty) {
      s += 120 + r.steps.length * 3;
    }
    if (r.optionalIngredients.isNotEmpty) s += 20;
    if (r.tags.isNotEmpty) s += 15;
    return s;
  }

  static String _pickText(String a, String b) {
    final ta = a.trim();
    final tb = b.trim();
    if (ta.isNotEmpty) {
      return a.trim();
    }
    if (tb.isNotEmpty) {
      return b.trim();
    }
    return a;
  }

  static List<String> _pickRicherList(List<String> a, List<String> b) {
    if (a.isNotEmpty && b.isEmpty) {
      return a;
    }
    if (b.isNotEmpty && a.isEmpty) {
      return b;
    }
    if (a.length > b.length) {
      return a;
    }
    if (b.length > a.length) {
      return b;
    }
    return a.isNotEmpty ? a : b;
  }

  static int _pickMinutes(RecipeModel primary, RecipeModel secondary) {
    final p = primary.minutes;
    final s = secondary.minutes;
    if (completenessScore(primary) >= completenessScore(secondary)) {
      return p > 0 ? p : (s > 0 ? s : p);
    }
    return s > 0 ? s : (p > 0 ? p : s);
  }

  static int _pickServings(RecipeModel primary, RecipeModel secondary) {
    final p = primary.servings;
    final s = secondary.servings;
    if (completenessScore(primary) >= completenessScore(secondary)) {
      return p > 0 ? p : (s > 0 ? s : p);
    }
    return s > 0 ? s : (p > 0 ? p : s);
  }

  static String _pickMealType(RecipeModel a, RecipeModel b) {
    return a.mealType.trim().isNotEmpty ? a.mealType : b.mealType;
  }

  static String _pickDifficulty(RecipeModel a, RecipeModel b) {
    return a.difficulty.trim().isNotEmpty ? a.difficulty : b.difficulty;
  }

  static String _pickBudget(RecipeModel a, RecipeModel b) {
    return a.budget.trim().isNotEmpty ? a.budget : b.budget;
  }

  static String _pickCuisine(RecipeModel a, RecipeModel b) {
    return a.cuisine.trim().isNotEmpty ? a.cuisine : b.cuisine;
  }

  static bool _pickSpicy(RecipeModel a, RecipeModel b) {
    return a.spicy || b.spicy;
  }

  static double? _pickAverageRating(RecipeModel a, RecipeModel b) {
    final ca = a.ratingCount ?? 0;
    final cb = b.ratingCount ?? 0;
    if (cb > ca) {
      return b.averageRating ?? a.averageRating;
    }
    if (ca > cb) {
      return a.averageRating ?? b.averageRating;
    }
    return b.averageRating ?? a.averageRating;
  }

  static int? _pickRatingCount(RecipeModel a, RecipeModel b) {
    final ca = a.ratingCount ?? 0;
    final cb = b.ratingCount ?? 0;
    if (cb > ca) {
      return b.ratingCount ?? a.ratingCount;
    }
    if (ca > cb) {
      return a.ratingCount ?? b.ratingCount;
    }
    return b.ratingCount ?? a.ratingCount;
  }

  static String _pickSource(RecipeModel a, RecipeModel b) {
    if (a.source == RecipeSource.asset || b.source == RecipeSource.asset) {
      return RecipeSource.asset;
    }
    if (a.source == RecipeSource.user || b.source == RecipeSource.user) {
      return RecipeSource.user;
    }
    return RecipeSource.remote;
  }

  /// Picks the richer recipe, then overlays missing fields and rating metadata.
  static RecipeModel chooseMostCompleteRecipe(RecipeModel a, RecipeModel b) {
    return mergeByRecipeId(a, b);
  }

  /// [existing] may be bundled/local; [incoming] is typically Firestore.
  static RecipeModel mergeByRecipeId(
      RecipeModel? existing, RecipeModel incoming) {
    if (existing == null) {
      if (kDebugMode) {
        debugPrint(
          'RecipeContentMerge: id=${incoming.id} noExisting incomingScore=${completenessScore(incoming)}',
        );
      }
      return incoming;
    }

    final sa = completenessScore(existing);
    final sb = completenessScore(incoming);
    final primary = sa >= sb ? existing : incoming;
    final secondary = sa >= sb ? incoming : existing;

    if (kDebugMode) {
      debugPrint(
        'RecipeContentMerge: id=${incoming.id} localScore=$sa remoteScore=$sb '
        'primary=${sa >= sb ? 'localFirst' : 'remoteFirst'}',
      );
    }

    final merged = RecipeModel(
      id: primary.id,
      title: _pickText(primary.title, secondary.title),
      description: _pickText(primary.description, secondary.description),
      minutes: _pickMinutes(primary, secondary),
      servings: _pickServings(primary, secondary),
      steps: _pickRicherList(primary.steps, secondary.steps),
      tags: primary.tags.isNotEmpty ? primary.tags : secondary.tags,
      mealType: _pickMealType(primary, secondary),
      difficulty: _pickDifficulty(primary, secondary),
      budget: _pickBudget(primary, secondary),
      spicy: _pickSpicy(primary, secondary),
      cuisine: _pickCuisine(primary, secondary),
      mainIngredients:
          _pickRicherList(primary.mainIngredients, secondary.mainIngredients),
      optionalIngredients: _pickRicherList(
        primary.optionalIngredients,
        secondary.optionalIngredients,
      ),
      source: _pickSource(existing, incoming),
      createdByUserId: primary.createdByUserId ?? secondary.createdByUserId,
      createdAt: primary.createdAt ?? secondary.createdAt,
      isApproved: primary.isApproved || secondary.isApproved,
      averageRating: _pickAverageRating(existing, incoming),
      ratingCount: _pickRatingCount(existing, incoming),
      imageUrl: primary.imageUrl ?? secondary.imageUrl,
      creatorName: primary.creatorName ?? secondary.creatorName,
    );

    if (kDebugMode) {
      final ms = completenessScore(merged);
      if (ms < sa && ms < sb) {
        debugPrint(
          'RecipeContentMerge: WARNING id=${incoming.id} mergedScore=$ms '
          'lower than inputs (sa=$sa sb=$sb)',
        );
      }
    }

    return merged;
  }
}
