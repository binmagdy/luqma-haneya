import 'package:flutter/foundation.dart';

import '../../domain/entities/recipe_entity.dart';
import '../../domain/entities/recipe_rating_summary.dart';
import '../../domain/repositories/trending_repository.dart';
import '../datasources/trending_remote_datasource.dart';

class TrendingRepositoryImpl implements TrendingRepository {
  TrendingRepositoryImpl(this._remote);

  final TrendingRemoteDataSource _remote;

  double _publicScore(
    RecipeEntity r,
    Map<String, RecipeRatingSummary>? sums,
  ) {
    final s = sums?[r.id];
    final avg = s?.average ?? r.averageRating ?? 0;
    final cnt = s?.count ?? r.ratingCount ?? 0;
    return avg * 1e6 + cnt;
  }

  List<RecipeEntity> _highestRatedFromCatalog(
    List<RecipeEntity> catalog,
    Map<String, RecipeRatingSummary>? ratingSummaries,
  ) {
    final ranked = [...catalog]..sort((a, b) {
        final ca = _publicScore(a, ratingSummaries);
        final cb = _publicScore(b, ratingSummaries);
        final cmp = cb.compareTo(ca);
        if (cmp != 0) return cmp;
        return a.title.compareTo(b.title);
      });
    return ranked.take(24).toList();
  }

  @override
  Future<List<RecipeEntity>> trendingRecipes(
    List<RecipeEntity> catalog, {
    Map<String, RecipeRatingSummary>? ratingSummaries,
  }) async {
    if (catalog.isEmpty) return const [];

    List<RecipeEntity> byIds(List<String> ids) {
      final map = {for (final r in catalog) r.id: r};
      final out = <RecipeEntity>[];
      for (final id in ids) {
        final r = map[id];
        if (r != null) out.add(r);
      }
      return out;
    }

    if (_remote.isAvailable) {
      final denorm = await _remote.recipeIdsSortedByDenormalizedFields();
      if (kDebugMode) {
        debugPrint('TrendingRepositoryImpl: denormIds=${denorm.length}');
      }
      if (denorm.isNotEmpty) {
        final list = byIds(denorm);
        if (list.isNotEmpty) return list;
      }
      final weekly = await _remote.recipeIdsTrendingThisWeek();
      if (kDebugMode) {
        debugPrint('TrendingRepositoryImpl: weeklyIds=${weekly.length}');
      }
      if (weekly.isNotEmpty) {
        final list = byIds(weekly);
        if (list.isNotEmpty) return list;
      }
      final allTime = await _remote.recipeIdsByAllTimeRating();
      if (kDebugMode) {
        debugPrint('TrendingRepositoryImpl: allTimeIds=${allTime.length}');
      }
      if (allTime.isNotEmpty) {
        final list = byIds(allTime);
        if (list.isNotEmpty) return list;
      }
    }

    final fallback = _highestRatedFromCatalog(catalog, ratingSummaries);
    if (kDebugMode) {
      debugPrint(
        'TrendingRepositoryImpl: fallback highest-rated count=${fallback.length}',
      );
    }
    return fallback.take(12).toList();
  }
}
