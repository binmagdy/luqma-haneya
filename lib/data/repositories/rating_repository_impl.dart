import 'package:flutter/foundation.dart';

import '../../core/utils/week_calendar.dart';
import '../../domain/entities/recipe_entity.dart';
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

    final uid = session.firebaseUid;
    final canRemote = publishPublic &&
        session.canPublishPublicRatings &&
        uid != null &&
        _remote.isAvailable;

    if (canRemote) {
      try {
        final wk = isoWeekKey(DateTime.now());
        if (kDebugMode) {
          debugPrint(
            'RatingRepositoryImpl: write public rating recipe=$recipeId uid=$uid',
          );
        }
        await _remote.upsertRating(
          recipeId: recipeId,
          userId: uid,
          stars: stars,
          weekKey: wk,
        );
        final merged = await _remote.summarizePublicRatingsForRecipe(recipeId);
        if (merged != null && merged.hasRatings) {
          await _local.mergeSummary(recipeId, merged);
        } else {
          final agg = await _remote.fetchRecipeAggregate(recipeId);
          if (agg != null) {
            await _local.mergeSummary(
              recipeId,
              RecipeRatingSummary(average: agg.average, count: agg.count),
            );
          }
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

  @override
  Future<RecipeRatingSummary?> fetchPublicSummaryForRecipe(
    String recipeId,
  ) async {
    if (!_remote.isAvailable) return null;
    return _remote.summarizePublicRatingsForRecipe(recipeId);
  }

  @override
  Future<Map<String, RecipeRatingSummary>> buildMergedSummariesForCatalog(
    List<RecipeEntity> catalog, {
    int maxRemoteHydrate = 120,
  }) async {
    final local = await _local.loadSummaries();
    final merged = Map<String, RecipeRatingSummary>.from(local);
    if (!_remote.isAvailable) {
      if (kDebugMode) {
        debugPrint(
          'RatingRepositoryImpl.buildMergedSummaries: remote off, localKeys=${merged.length}',
        );
      }
      return merged;
    }

    final take = catalog.length > maxRemoteHydrate
        ? catalog.take(maxRemoteHydrate).toList()
        : catalog;
    const batch = 8;
    for (var i = 0; i < take.length; i += batch) {
      final slice = take.skip(i).take(batch);
      await Future.wait(slice.map((r) async {
        final s = await _remote.summarizePublicRatingsForRecipe(r.id);
        if (s != null && s.hasRatings) {
          merged[r.id] = s;
        }
      }));
    }
    if (kDebugMode) {
      debugPrint(
        'RatingRepositoryImpl.buildMergedSummaries: catalog=${catalog.length} '
        'hydrated=${take.length} mergedKeys=${merged.length}',
      );
    }
    return merged;
  }
}
