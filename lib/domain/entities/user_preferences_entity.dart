class UserPreferencesEntity {
  const UserPreferencesEntity({
    this.vegetarian = false,
    this.avoidSpicy = true,
    this.quickMealsPreferred = false,
    this.economicalMealsPreferred = false,
    this.preferredMealType,
    this.favoriteTags = const [],
    this.favoriteIngredients = const [],
    this.allergies = const [],
    this.dislikedIngredients = const [],
  });

  final bool vegetarian;
  final bool avoidSpicy;
  final bool quickMealsPreferred;

  /// Prefer recipes tagged with low budget / economical profile.
  final bool economicalMealsPreferred;

  /// Meal-type slug (`breakfast`, `lunch`, …) or null = no preference.
  final String? preferredMealType;

  final List<String> favoriteTags;

  /// Favorite foods / ingredients used to boost overlap with recipe lines.
  final List<String> favoriteIngredients;

  /// Strong exclusion when text appears in recipe ingredient or metadata blob.
  final List<String> allergies;

  /// Matched text in a recipe lowers its score (strong penalty, not a hard block).
  final List<String> dislikedIngredients;

  UserPreferencesEntity copyWith({
    bool? vegetarian,
    bool? avoidSpicy,
    bool? quickMealsPreferred,
    bool? economicalMealsPreferred,
    String? preferredMealType,
    List<String>? favoriteTags,
    List<String>? favoriteIngredients,
    List<String>? allergies,
    List<String>? dislikedIngredients,
  }) {
    return UserPreferencesEntity(
      vegetarian: vegetarian ?? this.vegetarian,
      avoidSpicy: avoidSpicy ?? this.avoidSpicy,
      quickMealsPreferred: quickMealsPreferred ?? this.quickMealsPreferred,
      economicalMealsPreferred:
          economicalMealsPreferred ?? this.economicalMealsPreferred,
      preferredMealType: preferredMealType ?? this.preferredMealType,
      favoriteTags: favoriteTags ?? this.favoriteTags,
      favoriteIngredients: favoriteIngredients ?? this.favoriteIngredients,
      allergies: allergies ?? this.allergies,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
    );
  }
}
