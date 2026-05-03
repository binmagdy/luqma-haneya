enum SmartPlanDuration { three, seven, fourteen }

enum SmartPlanMealsPerDay { lunchOnly, lunchDinner, allThree }

enum SmartPlanBudget { economical, balanced, flexible }

enum SmartPlanCookingPace { quickWeekdays, any }

class SmartPlanSettings {
  const SmartPlanSettings({
    required this.duration,
    required this.mealsPerDay,
    required this.people,
    required this.budget,
    required this.cookingPace,
    required this.usePantry,
    required this.pantryIngredients,
    required this.includeFavorites,
    required this.tryNewRecipes,
  });

  final SmartPlanDuration duration;
  final SmartPlanMealsPerDay mealsPerDay;
  final int people;
  final SmartPlanBudget budget;
  final SmartPlanCookingPace cookingPace;
  final bool usePantry;
  final List<String> pantryIngredients;
  final bool includeFavorites;
  final bool tryNewRecipes;

  int get durationDays => switch (duration) {
        SmartPlanDuration.three => 3,
        SmartPlanDuration.seven => 7,
        SmartPlanDuration.fourteen => 14,
      };
}
