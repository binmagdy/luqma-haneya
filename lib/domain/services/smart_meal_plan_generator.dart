import 'dart:math';

import 'package:flutter/foundation.dart';

import '../entities/recipe_entity.dart';
import '../entities/user_preferences_entity.dart';
import '../value_objects/recipe_schema.dart';
import '../value_objects/smart_plan_settings.dart';
import 'meal_plan_slot_codec.dart';
import 'recipe_scoring_service.dart';

/// Outcome of [SmartMealPlanGenerator.generate].
class SmartPlanGenerationResult {
  const SmartPlanGenerationResult({
    required this.assignments,
    required this.totalSlots,
    required this.filledSlots,
    this.relaxedFiltersUsed = false,
    this.reusedRecipes = false,
  });

  final Map<String, String> assignments;
  final int totalSlots;
  final int filledSlots;
  final bool relaxedFiltersUsed;
  final bool reusedRecipes;

  /// Shown when we had to relax meal/budget filters or reuse recipes.
  static const String relaxedMessageAr =
      'لم نجد تطابق كامل، فهذه أفضل الاقتراحات المتاحة';

  bool get shouldShowRelaxedHint =>
      relaxedFiltersUsed || reusedRecipes || filledSlots < totalSlots;
}

class _RecipeRow {
  _RecipeRow(this.recipe, this.dailyScore, this.protein);

  final RecipeEntity recipe;
  final double dailyScore;
  final String protein;
}

/// Heuristic smart plan using weighted signals (MVP — tune weights with real usage).
class SmartMealPlanGenerator {
  SmartMealPlanGenerator._();

  static const _slotsLunchOnly = [RecipeMealType.lunch];
  static const _slotsLunchDinner = [
    RecipeMealType.lunch,
    RecipeMealType.dinner
  ];
  static const _slotsAll = [
    RecipeMealType.breakfast,
    RecipeMealType.lunch,
    RecipeMealType.dinner,
  ];

  static List<String> slotsForDay(SmartPlanMealsPerDay m) {
    return switch (m) {
      SmartPlanMealsPerDay.lunchOnly => _slotsLunchOnly,
      SmartPlanMealsPerDay.lunchDinner => _slotsLunchDinner,
      SmartPlanMealsPerDay.allThree => _slotsAll,
    };
  }

  static String _proteinBucket(RecipeEntity r) {
    final b = [
      ...r.mainIngredients,
      ...r.tags,
      r.title,
    ].join(' ').toLowerCase();
    if (b.contains('سمك') || b.contains('سماك')) return 'fish';
    if (b.contains('فراخ') || b.contains('دجاج') || b.contains('chicken')) {
      return 'chicken';
    }
    if (b.contains('لحم') ||
        b.contains('كبده') ||
        b.contains('كفتة') ||
        b.contains('لحمة')) {
      return 'meat';
    }
    if (b.contains('فول') ||
        b.contains('عدس') ||
        b.contains('حمص') ||
        b.contains('طعمية')) {
      return 'legume';
    }
    if (b.contains('بيض')) return 'egg';
    return 'veg';
  }

  static bool _budgetOk(RecipeEntity r, SmartPlanBudget b) {
    return switch (b) {
      SmartPlanBudget.economical => r.budget == RecipeBudget.low,
      SmartPlanBudget.balanced =>
        r.budget == RecipeBudget.low || r.budget == RecipeBudget.medium,
      SmartPlanBudget.flexible => true,
    };
  }

  static bool _mealOk(RecipeEntity r, String slot) {
    if (r.mealType == RecipeMealType.any) return true;
    return r.mealType == slot;
  }

  /// Builds a week of slot assignments. Always fills every slot when [catalog] is non-empty.
  static SmartPlanGenerationResult generate({
    required SmartPlanSettings settings,
    required List<RecipeEntity> catalog,
    required UserPreferencesEntity prefs,
    required Set<String> favoriteIds,
    required Map<String, int> myRatings,
    required RecipeSuggestionContext suggestionContext,
    DateTime? startMonday,
  }) {
    final sw = Stopwatch()..start();
    final rng = Random(
      (startMonday ?? DateTime.now()).millisecondsSinceEpoch ~/ 86400000,
    );
    final start = startMonday ?? mondayOf(DateTime.now());
    final used = <String>{};
    final proteinByDay = <int, String>{};
    final out = <String, String>{};
    var forcedNewDone = !settings.tryNewRecipes;
    var relaxedFiltersUsed = false;
    var reusedRecipes = false;

    final slots = slotsForDay(settings.mealsPerDay);
    final totalSlots = settings.durationDays * slots.length;

    if (catalog.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'SmartMealPlanGenerator: empty catalog, totalSlots=$totalSlots in ${sw.elapsedMilliseconds}ms',
        );
      }
      return SmartPlanGenerationResult(
        assignments: const {},
        totalSlots: totalSlots,
        filledSlots: 0,
        relaxedFiltersUsed: false,
        reusedRecipes: false,
      );
    }

    // Pre-filter + cache daily scores once per recipe (major perf win vs per-slot rescoring).
    final rows = <_RecipeRow>[];
    for (final r in catalog) {
      if (RecipeScoringService.isHardExcluded(r, prefs)) continue;
      if (prefs.avoidSpicy && r.spicy) continue;
      final daily = RecipeScoringService.scoreForDailySuggestion(
        r,
        prefs,
        context: suggestionContext,
      );
      if (daily == null) continue;
      rows.add(_RecipeRow(r, daily, _proteinBucket(r)));
    }

    if (kDebugMode) {
      debugPrint(
        'SmartMealPlanGenerator: candidates=${rows.length} catalog=${catalog.length} '
        'plannedSlots=$totalSlots in ${sw.elapsedMilliseconds}ms (after precompute)',
      );
    }

    if (rows.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            'SmartMealPlanGenerator: no eligible recipes after prefs filter');
      }
      return SmartPlanGenerationResult(
        assignments: const {},
        totalSlots: totalSlots,
        filledSlots: 0,
        relaxedFiltersUsed: true,
        reusedRecipes: false,
      );
    }

    final pantryNorm = settings.usePantry
        ? settings.pantryIngredients
            .map(RecipeScoringService.normalize)
            .where((s) => s.length >= 2)
            .toList()
        : const <String>[];

    RecipeEntity? pickBestForSlot({
      required String slot,
      required int dayIndex,
      required bool isWeekend,
      required bool relaxMeal,
      required bool relaxBudget,
      required bool allowReuse,
    }) {
      final candidates = <MapEntry<RecipeEntity, double>>[];

      for (final row in rows) {
        final r = row.recipe;
        if (!allowReuse && used.contains(r.id)) continue;
        if (!relaxBudget && !_budgetOk(r, settings.budget)) continue;
        if (!relaxMeal && !_mealOk(r, slot)) continue;

        var s = 0.35 * row.dailyScore;

        if (settings.includeFavorites && favoriteIds.contains(r.id)) {
          s += 0.25 * 85;
        }

        if (settings.usePantry && pantryNorm.isNotEmpty) {
          final p = RecipeScoringService.scoreForPantry(
            r,
            prefs,
            pantryNorm,
          );
          if (p != null) {
            s += 0.20 * (p.clamp(0, 120) / 120 * 100);
          }
        }

        final mr = myRatings[r.id] ?? 0;
        final pub = r.averageRating ?? 0;
        s += 0.10 * ((mr + pub) / 10 * 40);

        s += 0.10 * rng.nextDouble() * 25;

        if (settings.cookingPace == SmartPlanCookingPace.quickWeekdays &&
            !isWeekend &&
            r.minutes <= 35) {
          s += 12;
        }
        if (isWeekend && r.minutes >= 50) {
          s += 6;
        }

        final prot = row.protein;
        if (dayIndex > 0 &&
            proteinByDay[dayIndex - 1] == prot &&
            dayIndex > 1 &&
            proteinByDay[dayIndex - 2] == prot) {
          s -= 40;
        } else if (dayIndex > 0 && proteinByDay[dayIndex - 1] == prot) {
          s -= 18;
        }

        if (settings.tryNewRecipes &&
            !forcedNewDone &&
            !favoriteIds.contains(r.id) &&
            (myRatings[r.id] ?? 0) == 0) {
          s += 22;
        }

        candidates.add(MapEntry(r, s));
      }

      if (candidates.isEmpty) return null;
      candidates.sort((a, b) => b.value.compareTo(a.value));
      return candidates.first.key;
    }

    for (var d = 0; d < settings.durationDays; d++) {
      final date =
          DateTime(start.year, start.month, start.day).add(Duration(days: d));
      final weekday = date.weekday;
      final isWeekend =
          weekday == DateTime.saturday || weekday == DateTime.sunday;

      for (final slot in slots) {
        final slotKey =
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}__$slot';

        RecipeEntity? chosen = pickBestForSlot(
          slot: slot,
          dayIndex: d,
          isWeekend: isWeekend,
          relaxMeal: false,
          relaxBudget: false,
          allowReuse: false,
        );

        if (chosen == null) {
          chosen = pickBestForSlot(
            slot: slot,
            dayIndex: d,
            isWeekend: isWeekend,
            relaxMeal: true,
            relaxBudget: false,
            allowReuse: false,
          );
          if (chosen != null) relaxedFiltersUsed = true;
        }
        if (chosen == null) {
          chosen = pickBestForSlot(
            slot: slot,
            dayIndex: d,
            isWeekend: isWeekend,
            relaxMeal: true,
            relaxBudget: true,
            allowReuse: false,
          );
          if (chosen != null) relaxedFiltersUsed = true;
        }
        if (chosen == null) {
          chosen = pickBestForSlot(
            slot: slot,
            dayIndex: d,
            isWeekend: isWeekend,
            relaxMeal: true,
            relaxBudget: true,
            allowReuse: true,
          );
          if (chosen != null) {
            relaxedFiltersUsed = true;
            reusedRecipes = true;
          }
        }

        // Absolute fallback: first eligible row (never leave slot empty).
        chosen ??= rows.first.recipe;
        if (used.contains(chosen.id)) {
          reusedRecipes = true;
          relaxedFiltersUsed = true;
        }

        if (settings.tryNewRecipes &&
            !forcedNewDone &&
            !favoriteIds.contains(chosen.id) &&
            (myRatings[chosen.id] ?? 0) == 0) {
          forcedNewDone = true;
        }

        used.add(chosen.id);
        proteinByDay[d] = _proteinBucket(chosen);
        out[slotKey] = MealPlanSlotCodec.encode(
          recipeId: chosen.id,
          recipeTitle: chosen.title,
          servings: settings.people,
          locked: false,
          generatedAt: DateTime.now(),
        );
      }
    }

    if (kDebugMode) {
      debugPrint(
        'SmartMealPlanGenerator: done filled=${out.length}/$totalSlots '
        'relaxed=$relaxedFiltersUsed reused=$reusedRecipes ${sw.elapsedMilliseconds}ms',
      );
    }

    return SmartPlanGenerationResult(
      assignments: out,
      totalSlots: totalSlots,
      filledSlots: out.length,
      relaxedFiltersUsed: relaxedFiltersUsed,
      reusedRecipes: reusedRecipes,
    );
  }

  static DateTime mondayOf(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }
}
