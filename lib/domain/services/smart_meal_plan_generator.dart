import 'dart:math';

import '../entities/recipe_entity.dart';
import '../entities/user_preferences_entity.dart';
import '../value_objects/recipe_schema.dart';
import '../value_objects/smart_plan_settings.dart';
import 'meal_plan_slot_codec.dart';
import 'recipe_scoring_service.dart';

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

  static Map<String, String> generate({
    required SmartPlanSettings settings,
    required List<RecipeEntity> catalog,
    required UserPreferencesEntity prefs,
    required Set<String> favoriteIds,
    required Map<String, int> myRatings,
    required RecipeSuggestionContext suggestionContext,
    DateTime? startMonday,
  }) {
    final rng = Random(
      (startMonday ?? DateTime.now()).millisecondsSinceEpoch ~/ 86400000,
    );
    final start = startMonday ?? mondayOf(DateTime.now());
    final used = <String>{};
    final proteinByDay = <int, String>{};
    final out = <String, String>{};
    var forcedNewDone = !settings.tryNewRecipes;

    final pantryNorm = settings.usePantry
        ? settings.pantryIngredients
            .map(RecipeScoringService.normalize)
            .where((s) => s.length >= 2)
            .toList()
        : const <String>[];

    for (var d = 0; d < settings.durationDays; d++) {
      final date =
          DateTime(start.year, start.month, start.day).add(Duration(days: d));
      final weekday = date.weekday;
      final isWeekend =
          weekday == DateTime.saturday || weekday == DateTime.sunday;

      for (final slot in slotsForDay(settings.mealsPerDay)) {
        final slotKey =
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}__$slot';

        RecipeEntity? pickBest() {
          final candidates = <MapEntry<RecipeEntity, double>>[];
          for (final r in catalog) {
            if (used.contains(r.id)) continue;
            if (RecipeScoringService.isHardExcluded(r, prefs)) continue;
            if (prefs.avoidSpicy && r.spicy) continue;
            if (!_mealOk(r, slot)) continue;
            if (!_budgetOk(r, settings.budget)) continue;

            final daily = RecipeScoringService.scoreForDailySuggestion(
              r,
              prefs,
              context: suggestionContext,
            );
            if (daily == null) continue;

            var s = 0.35 * daily;

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

            final prot = _proteinBucket(r);
            if (proteinByDay[d - 1] == prot && proteinByDay[d - 2] == prot) {
              s -= 40;
            } else if (proteinByDay[d - 1] == prot) {
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

        var chosen = pickBest();
        if (chosen == null) {
          for (final r in catalog) {
            if (used.contains(r.id)) continue;
            if (RecipeScoringService.isHardExcluded(r, prefs)) continue;
            if (prefs.avoidSpicy && r.spicy) continue;
            chosen = r;
            break;
          }
        }

        if (chosen == null) continue;

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

    return out;
  }

  static DateTime mondayOf(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }
}
