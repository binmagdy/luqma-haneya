import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/bootstrap.dart';

/// Firestore: `recipes/{recipeId}/ratings/{userId}` plus denormalized counters on the recipe doc.
class RatingRemoteDataSource {
  RatingRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  /// Updates subcollection rating doc and maintains `ratingSum` / `ratingCount` / `averageRating` on the recipe.
  Future<void> upsertRating({
    required String recipeId,
    required String userId,
    required int stars,
  }) async {
    if (!isAvailable) return;
    final fs = _firestore!;
    final recipeRef = fs.collection('recipes').doc(recipeId);
    final ratingRef = recipeRef.collection('ratings').doc(userId);
    final now = FieldValue.serverTimestamp();

    await fs.runTransaction((transaction) async {
      final ratingSnap = await transaction.get(ratingRef);
      final recipeSnap = await transaction.get(recipeRef);

      final ratingPayload = <String, dynamic>{
        'rating': stars,
        'updatedAt': now,
      };
      if (!ratingSnap.exists) {
        ratingPayload['createdAt'] = now;
      }
      transaction.set(ratingRef, ratingPayload, SetOptions(merge: true));

      if (!recipeSnap.exists) {
        // Avoid creating a stub top-level recipe doc with only counters when the
        // catalog row is not in Firestore yet (e.g. bundled-only recipes).
        return;
      }

      final oldStars = (ratingSnap.data()?['rating'] as num?)?.toInt();
      var sum = (recipeSnap.data()?['ratingSum'] as num?)?.toDouble() ?? 0.0;
      var count = (recipeSnap.data()?['ratingCount'] as num?)?.toInt() ?? 0;

      if (oldStars == null) {
        count += 1;
        sum += stars;
      } else {
        sum += stars - oldStars;
      }

      final avg = count > 0 ? sum / count : 0.0;

      transaction.set(
        recipeRef,
        {
          'ratingSum': sum,
          'ratingCount': count,
          'averageRating': avg,
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Pull denormalized aggregates after a write (or on cold start for a recipe).
  Future<({double average, int count})?> fetchRecipeAggregate(
    String recipeId,
  ) async {
    if (!isAvailable) return null;
    final doc = await _firestore!.collection('recipes').doc(recipeId).get();
    final d = doc.data();
    if (d == null) return null;
    final c = (d['ratingCount'] as num?)?.toInt() ?? 0;
    if (c <= 0) return null;
    final avg = (d['averageRating'] as num?)?.toDouble() ??
        (((d['ratingSum'] as num?)?.toDouble() ?? 0) / c);
    return (average: avg, count: c);
  }
}
