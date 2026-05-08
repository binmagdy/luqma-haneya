import 'package:flutter/foundation.dart';

import '../../core/arabic_text_normalize.dart';
import '../entities/recipe_entity.dart';
import '../entities/user_preferences_entity.dart';
import '../value_objects/recipe_schema.dart';

/// Extra personalization for daily suggestions (favorites, strong ratings, history).
class RecipeSuggestionContext {
  const RecipeSuggestionContext({
    this.favoriteRecipeIds = const {},
    this.favoriteRecipes = const [],
    this.highRatedRecipes = const [],
    this.recentlyViewedRecipes = const [],
    this.trendingRecipeIds = const {},
    this.penalizedRecipeIds = const {},
  });

  final Set<String> favoriteRecipeIds;
  final List<RecipeEntity> favoriteRecipes;
  final List<RecipeEntity> highRatedRecipes;
  final List<RecipeEntity> recentlyViewedRecipes;

  /// Cloud/local trending ids for this week (best-effort).
  final Set<String> trendingRecipeIds;

  /// Down-rank recently shown suggestions to reduce repetition.
  final Set<String> penalizedRecipeIds;

  static const RecipeSuggestionContext empty = RecipeSuggestionContext();
}

/// Weighted scoring for recipe recommendations (daily suggestions + pantry search).
/// Uses [ArabicTextNormalize] for ingredient and preference text matching.
class RecipeScoringService {
  RecipeScoringService._();

  /// Minimum total score for daily suggestions before falling back to unfiltered top.
  static const double minSuggestionScore = 14;

  /// Minimum total score for pantry results before falling back.
  static const double minPantryScore = 10;

  static const double _pantryMainHitWeight = 26;
  static const double _pantryOptionalHitWeight = 5;
  static const double _missingMainPenalty = 13;

  static const double _favoriteTagWeight = 15;
  static const double _favoriteIngredientMainWeight = 18;
  static const double _favoriteIngredientOptionalWeight = 7;

  static const double _quickUnder30Weight = 22;
  static const double _quickUnder45Weight = 11;
  static const double _economicalBudgetLowWeight = 18;

  static const double _mealTypeMatchWeight = 20;
  static const double _dislikePenaltyPerHit = 52;
  static const double _spicyPenaltyWhenAvoided = 40;

  static const double _favoriteRecipeIdBoost = 26;
  static const double _favoriteSimilarTagPerHit = 6;
  static const int _favoriteSimilarTagCap = 24;
  static const double _highRatedSimilarTagPerHit = 5;
  static const int _highRatedSimilarTagCap = 18;
  static const double _recentViewMealOrCuisineBoost = 4;
  static const int _recentViewBoostCap = 12;
  static const double _trendingBoost = 12;
  static const double _repeatSuggestionPenalty = 18;

  static const List<String> _meatHints = [
    'لحم',
    'فراخ',
    'دجاج',
    'ارنب',
    'سمك',
    'سجق',
    'كبده',
    'كبدة',
    'لحم مفروم',
    'كفتة',
  ];

  /// Public alias for pantry pipeline: normalize user/pantry tokens.
  static String normalize(String s) => ArabicTextNormalize.forMatch(s);

  /// Strong exclusions: allergies, spicy when avoided, vegetarian mismatch.
  static bool isHardExcluded(RecipeEntity recipe, UserPreferencesEntity prefs) {
    if (prefs.vegetarian && !_isVegetarianFriendly(recipe)) return true;

    final blob = _matchBlob(recipe);
    for (final a in prefs.allergies) {
      final n = normalize(a);
      if (n.length < 2) continue;
      if (ArabicTextNormalize.fuzzyContains(blob, n) || blob.contains(n)) {
        return true;
      }
    }
    return false;
  }

  /// Returns `null` if the recipe should not appear in ranked lists at all.
  static double? scoreForDailySuggestion(
    RecipeEntity recipe,
    UserPreferencesEntity prefs, {
    RecipeSuggestionContext? context,
  }) {
    if (isHardExcluded(recipe, prefs)) return null;

    if (prefs.avoidSpicy && recipe.spicy) {
      return null;
    }

    final ctx = context ?? RecipeSuggestionContext.empty;

    // Baseline so empty prefs still rank; dislikes/allergies pull recipes down.
    var score = 22.0;
    // Deterministic tie-break (stable ordering for similar scores).
    score += recipe.id.hashCode.remainder(1000) * 1e-6;
    final blob = _matchBlob(recipe);

    score -= _dislikePenalty(blob, prefs.dislikedIngredients);

    if (prefs.avoidSpicy && _looksSpicyFromText(blob) && !recipe.spicy) {
      score -= _spicyPenaltyWhenAvoided * 0.35;
    }

    for (final tag in recipe.tags) {
      final nt = normalize(tag);
      for (final fav in prefs.favoriteTags) {
        final nf = normalize(fav);
        if (nf.length < 2) continue;
        if (nt.contains(nf) || nf.contains(nt)) {
          score += _favoriteTagWeight;
        }
      }
    }

    for (final fav in prefs.favoriteIngredients) {
      final nf = normalize(fav);
      if (nf.length < 2) continue;
      for (final line in recipe.mainIngredients) {
        if (_ingredientLineMatchesToken(line, nf)) {
          score += _favoriteIngredientMainWeight;
        }
      }
      for (final line in recipe.optionalIngredients) {
        if (_ingredientLineMatchesToken(line, nf)) {
          score += _favoriteIngredientOptionalWeight;
        }
      }
    }

    if (prefs.quickMealsPreferred) {
      if (recipe.minutes <= 30) {
        score += _quickUnder30Weight;
      } else if (recipe.minutes <= 45) {
        score += _quickUnder45Weight;
      }
    }

    if (prefs.economicalMealsPreferred && recipe.budget == RecipeBudget.low) {
      score += _economicalBudgetLowWeight;
    }

    if (!prefs.quickMealsPreferred && recipe.minutes <= 25) {
      score += 5;
    }

    final preferred = prefs.preferredMealType;
    if (preferred != null &&
        preferred.isNotEmpty &&
        preferred != RecipeMealType.any) {
      if (recipe.mealType == preferred ||
          recipe.mealType == RecipeMealType.any) {
        score += _mealTypeMatchWeight;
      }
    }

    final nc = normalize(recipe.cuisine);
    for (final fav in prefs.favoriteTags) {
      final nf = normalize(fav);
      if (nf.length < 2) continue;
      if (nc.contains(nf) || nf.contains(nc)) {
        score += 6;
      }
    }

    for (final fav in prefs.favoriteIngredients) {
      final nf = normalize(fav);
      if (nf.length < 2) continue;
      if (blob.contains(nf) &&
          !recipe.mainIngredients
              .any((l) => _ingredientLineMatchesToken(l, nf)) &&
          !recipe.optionalIngredients
              .any((l) => _ingredientLineMatchesToken(l, nf))) {
        score += 3;
      }
    }

    if (ctx.favoriteRecipeIds.contains(recipe.id)) {
      score += _favoriteRecipeIdBoost;
    }

    score += _tagOverlapBoost(
      recipe,
      ctx.favoriteRecipes,
      perHit: _favoriteSimilarTagPerHit,
      cap: _favoriteSimilarTagCap,
    );

    score += _tagOverlapBoost(
      recipe,
      ctx.highRatedRecipes,
      perHit: _highRatedSimilarTagPerHit,
      cap: _highRatedSimilarTagCap,
    );

    score += _recentViewAffinity(recipe, ctx.recentlyViewedRecipes);

    if (ctx.trendingRecipeIds.contains(recipe.id)) {
      score += _trendingBoost;
    }
    if (ctx.penalizedRecipeIds.contains(recipe.id)) {
      score -= _repeatSuggestionPenalty;
    }

    return score;
  }

  /// Pantry overlap plus preference bonuses. [pantryNormalized] must be non-empty
  /// (each entry already [normalize]d).
  static double? scoreForPantry(
    RecipeEntity recipe,
    UserPreferencesEntity prefs,
    List<String> pantryNormalized,
  ) {
    if (isHardExcluded(recipe, prefs)) return null;
    if (prefs.avoidSpicy && recipe.spicy) return null;
    if (pantryNormalized.isEmpty) return null;

    var score = 0.0;
    final seenMain = <String>{};
    final seenOpt = <String>{};

    for (final p in pantryNormalized) {
      if (p.length < 2) continue;
      for (final line in recipe.mainIngredients) {
        final nl = normalize(line);
        if (ArabicTextNormalize.ingredientLineMatchesPantry(p, nl) &&
            seenMain.add('$p::$nl')) {
          score += _pantryMainHitWeight;
        }
      }
      for (final line in recipe.optionalIngredients) {
        final nl = normalize(line);
        if (ArabicTextNormalize.ingredientLineMatchesPantry(p, nl) &&
            seenOpt.add('$p::$nl')) {
          score += _pantryOptionalHitWeight;
        }
      }
    }

    if (score == 0) return null;

    if (prefs.avoidSpicy &&
        _looksSpicyFromText(_matchBlob(recipe)) &&
        !recipe.spicy) {
      score -= _spicyPenaltyWhenAvoided * 0.35;
    }

    var matchedMains = 0;
    for (final line in recipe.mainIngredients) {
      final nl = normalize(line);
      final hit = pantryNormalized.any(
        (p) =>
            p.length >= 2 &&
            ArabicTextNormalize.ingredientLineMatchesPantry(p, nl),
      );
      if (hit) matchedMains++;
    }
    final missing = recipe.mainIngredients.length - matchedMains;
    score -= missing * _missingMainPenalty;

    final blob = _matchBlob(recipe);
    score -= _dislikePenalty(blob, prefs.dislikedIngredients);

    for (final tag in recipe.tags) {
      final nt = normalize(tag);
      for (final fav in prefs.favoriteTags) {
        final nf = normalize(fav);
        if (nf.length < 2) continue;
        if (nt.contains(nf) || nf.contains(nt)) {
          score += _favoriteTagWeight * 0.55;
        }
      }
    }

    for (final fav in prefs.favoriteIngredients) {
      final nf = normalize(fav);
      if (nf.length < 2) continue;
      if (_ingredientBlobMatchesToken(blob, nf)) {
        score += _favoriteIngredientMainWeight * 0.4;
      }
    }

    if (prefs.quickMealsPreferred) {
      if (recipe.minutes <= 30) {
        score += _quickUnder30Weight * 0.45;
      } else if (recipe.minutes <= 45) {
        score += _quickUnder45Weight * 0.45;
      }
    }

    if (prefs.economicalMealsPreferred && recipe.budget == RecipeBudget.low) {
      score += _economicalBudgetLowWeight * 0.4;
    }

    final preferred = prefs.preferredMealType;
    if (preferred != null &&
        preferred.isNotEmpty &&
        preferred != RecipeMealType.any) {
      if (recipe.mealType == preferred ||
          recipe.mealType == RecipeMealType.any) {
        score += _mealTypeMatchWeight * 0.5;
      }
    }

    return score;
  }

  /// Debug-only explanation of how a score was built (no user-visible UI).
  static String describeScoreForDebug({
    required RecipeEntity recipe,
    required UserPreferencesEntity prefs,
    required String mode,
    List<String>? pantryNormalized,
  }) {
    if (isHardExcluded(recipe, prefs)) {
      return '[${recipe.id}] hardExcluded=true';
    }
    if (mode == 'pantry') {
      final s = scoreForPantry(recipe, prefs, pantryNormalized ?? const []);
      return '[${recipe.id}] pantry score=${s?.toStringAsFixed(2) ?? 'null'}';
    }
    final s = scoreForDailySuggestion(recipe, prefs);
    return '[${recipe.id}] daily score=${s?.toStringAsFixed(2) ?? 'null'}';
  }

  static double _tagOverlapBoost(
    RecipeEntity recipe,
    List<RecipeEntity> seeds, {
    required double perHit,
    required int cap,
  }) {
    if (seeds.isEmpty) return 0;
    final curTags =
        recipe.tags.map(normalize).where((t) => t.length >= 2).toList();
    if (curTags.isEmpty) return 0;
    var add = 0.0;
    for (final seed in seeds) {
      if (seed.id == recipe.id) continue;
      for (final t in seed.tags) {
        final nt = normalize(t);
        if (nt.length < 2) continue;
        for (final ct in curTags) {
          if (ct.contains(nt) || nt.contains(ct)) {
            add += perHit;
            if (add >= cap) return cap.toDouble();
          }
        }
      }
    }
    return add.clamp(0, cap.toDouble());
  }

  static double _recentViewAffinity(
    RecipeEntity recipe,
    List<RecipeEntity> recent,
  ) {
    if (recent.isEmpty) return 0;
    var add = 0.0;
    for (final v in recent) {
      if (v.id == recipe.id) continue;
      if (recipe.mealType == v.mealType &&
          recipe.mealType != RecipeMealType.any) {
        add += _recentViewMealOrCuisineBoost;
      }
      final nc = normalize(recipe.cuisine);
      final nv = normalize(v.cuisine);
      if (nc.length >= 2 &&
          nv.length >= 2 &&
          (nc.contains(nv) || nv.contains(nc))) {
        add += _recentViewMealOrCuisineBoost;
      }
      if (add >= _recentViewBoostCap) return _recentViewBoostCap.toDouble();
    }
    return add.clamp(0, _recentViewBoostCap.toDouble());
  }

  static void debugLogRanking({
    required String label,
    required Iterable<MapEntry<RecipeEntity, double>> ranked,
    int limit = 12,
  }) {
    if (!kDebugMode) return;
    final top = ranked
        .take(limit)
        .map((e) => '${e.key.id}:${e.value.toStringAsFixed(1)}')
        .join(', ');
    debugPrint('RecipeScoringService $label → $top');
  }

  static bool _isVegetarianFriendly(RecipeEntity recipe) {
    if (recipe.tags.any((t) => normalize(t).contains('نباتي'))) return true;
    final mainBlob = recipe.mainIngredients.map(normalize).join(' ');
    for (final h in _meatHints) {
      if (ArabicTextNormalize.fuzzyContains(mainBlob, normalize(h)) ||
          mainBlob.contains(normalize(h))) {
        return false;
      }
    }
    return true;
  }

  static String _matchBlob(RecipeEntity recipe) {
    return normalize([
      recipe.title,
      recipe.description,
      ...recipe.mainIngredients,
      ...recipe.optionalIngredients,
      ...recipe.tags,
      recipe.cuisine,
    ].join(' '));
  }

  static bool _ingredientLineMatchesToken(String line, String tokenNorm) {
    return ArabicTextNormalize.ingredientLineMatchesPantry(
        tokenNorm, normalize(line));
  }

  static bool _ingredientBlobMatchesToken(String blobNorm, String tokenNorm) {
    return ArabicTextNormalize.fuzzyContains(blobNorm, tokenNorm) ||
        blobNorm.contains(tokenNorm);
  }

  static double _dislikePenalty(String blobNorm, List<String> disliked) {
    var penalty = 0.0;
    for (final d in disliked) {
      final n = normalize(d);
      if (n.length < 2) continue;
      if (ArabicTextNormalize.fuzzyContains(blobNorm, n) ||
          blobNorm.contains(n)) {
        penalty += _dislikePenaltyPerHit;
      }
    }
    return penalty;
  }

  static bool _looksSpicyFromText(String blobNorm) {
    const hints = ['حار', 'شطه', 'شطة', 'هريسه', 'هريسة', 'فلفل حار', 'شيلي'];
    for (final h in hints) {
      if (blobNorm.contains(normalize(h))) return true;
    }
    return false;
  }
}
