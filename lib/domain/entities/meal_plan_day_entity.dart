class MealPlanDayEntity {
  const MealPlanDayEntity({
    required this.weekdayIndex,
    required this.label,
    this.recipeId,
    this.recipeTitle,
  });

  final int weekdayIndex;
  final String label;
  final String? recipeId;
  final String? recipeTitle;
}
