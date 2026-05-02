/// Canonical JSON / Firestore values for recipe metadata (English slugs).
abstract class RecipeMealType {
  static const breakfast = 'breakfast';
  static const lunch = 'lunch';
  static const dinner = 'dinner';
  static const snack = 'snack';
  static const any = 'any';
}

abstract class RecipeDifficulty {
  static const easy = 'easy';
  static const medium = 'medium';
  static const hard = 'hard';
}

abstract class RecipeBudget {
  static const low = 'low';
  static const medium = 'medium';
  static const high = 'high';
}
