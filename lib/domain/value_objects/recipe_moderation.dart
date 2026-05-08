/// Firestore `status` field on `recipes/{id}`.
abstract class RecipeModerationStatus {
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
}

/// Firestore `visibility` on `recipes/{id}`.
abstract class RecipeVisibility {
  static const public = 'public';
  static const hidden = 'hidden';
}
