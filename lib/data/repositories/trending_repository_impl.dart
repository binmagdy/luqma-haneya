import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/trending_repository.dart';
import '../datasources/trending_remote_datasource.dart';

class TrendingRepositoryImpl implements TrendingRepository {
  TrendingRepositoryImpl(this._remote);

  final TrendingRemoteDataSource _remote;

  @override
  Future<List<RecipeEntity>> trendingRecipes(List<RecipeEntity> catalog) async {
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
      final weekly = await _remote.recipeIdsTrendingThisWeek();
      if (weekly.isNotEmpty) {
        return byIds(weekly);
      }
      final allTime = await _remote.recipeIdsByAllTimeRating();
      if (allTime.isNotEmpty) {
        return byIds(allTime);
      }
    }

    final scored = [...catalog]..sort((a, b) {
        final ca = _scoreLocal(a);
        final cb = _scoreLocal(b);
        return cb.compareTo(ca);
      });
    return scored.take(12).toList();
  }

  double _scoreLocal(RecipeEntity r) {
    final a = r.averageRating ?? 0;
    final c = r.ratingCount ?? 0;
    return a * 100 + c;
  }
}
