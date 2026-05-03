abstract class MealPlanRepository {
  Future<Map<String, String>> loadWeek(String weekKey);

  Future<void> saveDayAssignment(
    String weekKey,
    String dayKey,
    String recipeId,
    String recipeTitle,
  );

  Future<void> clearDay(String weekKey, String dayKey);

  /// Smart-plan slots use keys like `2026-05-02__lunch` or legacy `mon`.
  Future<void> applySmartAssignments(
    String weekKey,
    Map<String, String> generated,
  );

  Future<void> replaceSlot(
    String weekKey,
    String slotKey,
    String recipeId,
    String recipeTitle, {
    int servings,
  });

  Future<void> setSlotLocked(
    String weekKey,
    String slotKey,
    bool locked,
  );
}
