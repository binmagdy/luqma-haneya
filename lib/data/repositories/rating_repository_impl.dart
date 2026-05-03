import 'package:flutter/foundation.dart';

import '../../core/utils/week_calendar.dart';
import '../../domain/entities/recipe_rating_summary.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/rating_repository.dart';
import '../datasources/rating_local_datasource.dart';
import '../datasources/rating_remote_datasource.dart';

/// Offline aggregate on this device is a single-rater MVP until Firestore returns real counts.
class RatingRepositoryImpl implements RatingRepository {
  RatingRepositoryImpl({
    required RatingLocalDataSource local,
    required RatingRemoteDataSource remote,
    required AuthRepository auth,
  })  : _local = local,
        _remote = remote,
        _auth = auth;

  final RatingLocalDataSource _local;
  final RatingRemoteDataSource _remote;
  final AuthRepository _auth;

  @override
  Future<int?> getMyRating(String recipeId) async {
    final map = await _local.loadMyRatings();
    final row = map[recipeId];
    if (row == null) return null;
    return (row['rating'] as num?)?.toInt();
  }

  @override
  Future<RecipeRatingSummary?> getSummary(String recipeId) async {
    final all = await _local.loadSummaries();
    return all[recipeId];
  }

  @override
  Future<Map<String, RecipeRatingSummary>> getAllCachedSummaries() async {
    return _local.loadSummaries();
  }

  @override
  Future<Map<String, int>> allMyRatings() async {
    final my = await _local.loadMyRatings();
    final out = <String, int>{};
    for (final e in my.entries) {
      final v = (e.value['rating'] as num?)?.toInt();
      if (v != null) out[e.key] = v;
    }
    return out;
  }

  @override
  Future<void> setMyRating(
    String recipeId,
    int stars, {
    required bool publishPublic,
  }) async {
    if (stars < 1 || stars > 5) {
      throw ArgumentError.value(stars, 'stars', 'must be 1–5');
    }
    final session = await _auth.readSession();
    final my = await _local.loadMyRatings();
    my[recipeId] = {
      'rating': stars,
      'updatedAt': DateTime.now().toIso8601String(),
      'publishPublic': publishPublic,
    };
    await _local.saveMyRatings(my);

    final canRemote =
        publishPublic && session.canPublishPublicRatings && _remote.isAvailable;

    if (canRemote) {
      try {
        final wk = isoWeekKey(DateTime.now());
        await _remote.upsertRating(
          recipeId: recipeId,
          userId: session.firestoreSyncId,
          stars: stars,
          weekKey: wk,
        );
        final agg = await _remote.fetchRecipeAggregate(recipeId);
        if (agg != null) {
          await _local.mergeSummary(
            recipeId,
            RecipeRatingSummary(average: agg.average, count: agg.count),
          );
        }
      } catch (e, st) {
        debugPrint('RatingRepositoryImpl remote sync failed: $e $st');
        await _offlineAggregateFallback(recipeId, stars);
      }
    } else {
      await _offlineAggregateFallback(recipeId, stars);
    }
  }

  Future<void> _offlineAggregateFallback(String recipeId, int stars) async {
    await _local.mergeSummary(
      recipeId,
      RecipeRatingSummary(average: stars.toDouble(), count: 1),
    );
  }
}
