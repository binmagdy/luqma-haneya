import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/bootstrap.dart';
import '../../domain/entities/recipe_rating_summary.dart';

/// Firestore: `recipes/{recipeId}/ratings/{userId}` plus denormalized counters on the recipe doc.
///
/// TODO: Move weekly / all-time aggregate maintenance to a Cloud Function to avoid
/// extra reads and race conditions at scale.
class RatingRemoteDataSource {
  RatingRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  static const int _maxRatingsDocsPerRecipe = 500;

  /// Client-side truth for public display (Option A): average + count from
  /// `recipes/{recipeId}/ratings/*`. Falls back to denormalized recipe doc fields.
  Future<RecipeRatingSummary?> summarizePublicRatingsForRecipe(
    String recipeId,
  ) async {
    if (!isAvailable) return null;
    try {
      final snap = await _firestore!
          .collection('recipes')
          .doc(recipeId)
          .collection('ratings')
          .limit(_maxRatingsDocsPerRecipe)
          .get();
      var sum = 0;
      var n = 0;
      for (final d in snap.docs) {
        final v = (d.data()['rating'] as num?)?.toInt();
        if (v == null || v < 1 || v > 5) continue;
        sum += v;
        n++;
      }
      if (n > 0) {
        if (kDebugMode) {
          debugPrint(
            'RatingRemoteDataSource: recipe=$recipeId ratingsFetched=$n avg=${sum / n}',
          );
        }
        return RecipeRatingSummary(average: sum / n, count: n);
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('RatingRemoteDataSource.summarizePublic $recipeId: $e $st');
      }
    }
    return _summaryFromRecipeDocOnly(recipeId);
  }

  Future<RecipeRatingSummary?> _summaryFromRecipeDocOnly(
    String recipeId,
  ) async {
    if (!isAvailable) return null;
    try {
      final doc = await _firestore!.collection('recipes').doc(recipeId).get();
      final d = doc.data();
      if (d == null) return null;
      final c = (d['ratingCount'] as num?)?.toInt() ??
          (d['ratingsCount'] as num?)?.toInt() ??
          0;
      if (c <= 0) return null;
      final avg = (d['averageRating'] as num?)?.toDouble() ??
          (((d['ratingSum'] as num?)?.toDouble() ?? 0) / c);
      return RecipeRatingSummary(average: avg, count: c);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertRating({
    required String recipeId,
    required String userId,
    required int stars,
    required String weekKey,
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
        'recipeId': recipeId,
        'userId': userId,
        'rating': stars,
        'weekKey': weekKey,
        'updatedAt': now,
      };
      if (!ratingSnap.exists) {
        ratingPayload['createdAt'] = now;
      }
      transaction.set(ratingRef, ratingPayload, SetOptions(merge: true));

      if (!recipeSnap.exists) {
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
          'ratingsCount': count,
          'averageRating': avg,
          'lastRatedAt': now,
        },
        SetOptions(merge: true),
      );
    });

    await _patchWeeklyFromClient(recipeRef, weekKey);
  }

  Future<void> _patchWeeklyFromClient(
    DocumentReference<Map<String, dynamic>> recipeRef,
    String weekKey,
  ) async {
    if (!isAvailable) return;
    try {
      final snap = await recipeRef
          .collection('ratings')
          .where('weekKey', isEqualTo: weekKey)
          .get();
      if (snap.docs.isEmpty) {
        await recipeRef.set({
          'weeklyRatingAverage': null,
          'weeklyRatingCount': 0,
        }, SetOptions(merge: true));
        return;
      }
      var s = 0;
      for (final d in snap.docs) {
        final v = (d.data()['rating'] as num?)?.toInt() ?? 0;
        s += v;
      }
      final c = snap.docs.length;
      final wavg = s / c;
      await recipeRef.set({
        'weeklyRatingAverage': wavg,
        'weeklyRatingCount': c,
      }, SetOptions(merge: true));
    } catch (_) {
      /* index missing or offline — skip weekly patch */
    }
  }

  Future<({double average, int count})?> fetchRecipeAggregate(
    String recipeId,
  ) async {
    if (!isAvailable) return null;
    final doc = await _firestore!.collection('recipes').doc(recipeId).get();
    final d = doc.data();
    if (d == null) return null;
    final c = (d['ratingCount'] as num?)?.toInt() ??
        (d['ratingsCount'] as num?)?.toInt() ??
        0;
    if (c <= 0) return null;
    final avg = (d['averageRating'] as num?)?.toDouble() ??
        (((d['ratingSum'] as num?)?.toDouble() ?? 0) / c);
    return (average: avg, count: c);
  }
}
