import '../value_objects/recipe_moderation.dart';
import '../value_objects/recipe_schema.dart';
import '../value_objects/recipe_source.dart';

class RecipeEntity {
  const RecipeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.minutes,
    required this.servings,
    required this.steps,
    required this.tags,
    required this.mealType,
    required this.difficulty,
    required this.budget,
    required this.spicy,
    required this.cuisine,
    required this.mainIngredients,
    required this.optionalIngredients,
    this.source = RecipeSource.asset,
    this.createdByUserId,
    this.createdAt,
    this.isApproved = true,
    this.moderationStatus = RecipeModerationStatus.approved,
    this.visibility = RecipeVisibility.public,
    this.rejectedReason,
    this.updatedAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.averageRating,
    this.ratingCount,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final int minutes;
  final int servings;
  final List<String> steps;
  final List<String> tags;

  /// One of [RecipeMealType] values.
  final String mealType;

  /// One of [RecipeDifficulty] values.
  final String difficulty;

  /// One of [RecipeBudget] values.
  final String budget;

  final bool spicy;

  /// Short cuisine slug, e.g. `egyptian`, `mixed`.
  final String cuisine;

  final List<String> mainIngredients;
  final List<String> optionalIngredients;

  /// One of [RecipeSource] values: bundled asset, user submission, or remote doc.
  final String source;

  /// Local device id or auth uid when synced to Firestore.
  final String? createdByUserId;

  final DateTime? createdAt;

  /// In production, user-submitted rows should stay false until moderation.
  final bool isApproved;

  /// Firestore `status`: pending | approved | rejected.
  final String moderationStatus;

  /// Firestore `visibility`: public | hidden.
  final String visibility;

  final String? rejectedReason;

  final DateTime? updatedAt;

  final String? approvedBy;

  final DateTime? approvedAt;

  final String? rejectedBy;

  final DateTime? rejectedAt;

  /// Denormalized community average from Firestore recipe doc when present.
  final double? averageRating;

  /// Denormalized count from Firestore recipe doc when present.
  final int? ratingCount;

  /// Optional cover image (user recipes / remote).
  final String? imageUrl;

  /// All ingredient lines (main then optional) for lists and legacy call sites.
  List<String> get ingredients => [...mainIngredients, ...optionalIngredients];
}
