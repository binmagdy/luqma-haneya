abstract class MealPlanRepository {
  Future<Map<String, String>> loadWeek(String weekKey);

  Future<void> saveDayAssignment(
    String weekKey,
    String dayKey,
    String recipeId,
    String recipeTitle,
  );

  Future<void> clearDay(String weekKey, String dayKey);
}
