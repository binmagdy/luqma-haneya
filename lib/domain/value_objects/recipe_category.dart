/// Bundled / Firestore recipe category.
abstract class RecipeCategory {
  static const normal = 'normal';
  static const diet = 'diet';

  static bool isDiet(String? value) => value == diet;

  static String normalize(String? value) {
    if (value == diet) return diet;
    return normal;
  }
}
