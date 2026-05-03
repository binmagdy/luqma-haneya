/// Aggregate display values for a recipe (local cache ± Firestore denorm fields).
class RecipeRatingSummary {
  const RecipeRatingSummary({
    required this.average,
    required this.count,
  });

  final double average;
  final int count;

  bool get hasRatings => count > 0;
}
