import 'package:flutter/foundation.dart';

import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../datasources/favorites_remote_datasource.dart';
import '../datasources/user_identity_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({
    required FavoritesLocalDataSource local,
    required FavoritesRemoteDataSource remote,
    required UserIdentityLocalDataSource identity,
  })  : _local = local,
        _remote = remote,
        _identity = identity;

  final FavoritesLocalDataSource _local;
  final FavoritesRemoteDataSource _remote;
  final UserIdentityLocalDataSource _identity;

  @override
  Future<Set<String>> favoriteRecipeIds() async {
    final local = await _local.load();
    if (_remote.isAvailable) {
      try {
        final uid = await _identity.getOrCreateDeviceId();
        final remote = await _remote.fetchFavorites(uid);
        if (remote.isNotEmpty) {
          final merged = {...local, ...remote};
          await _local.save(merged);
          return merged;
        }
      } catch (e, st) {
        debugPrint('FavoritesRepositoryImpl remote fetch failed: $e $st');
      }
    }
    return local;
  }

  @override
  Future<bool> isFavorite(String recipeId) async {
    final s = await favoriteRecipeIds();
    return s.contains(recipeId);
  }

  @override
  Future<void> setFavorite(String recipeId, bool value) async {
    final cur = await _local.load();
    if (value) {
      cur.add(recipeId);
    } else {
      cur.remove(recipeId);
    }
    await _local.save(cur);
    if (_remote.isAvailable) {
      try {
        final uid = await _identity.getOrCreateDeviceId();
        await _remote.setFavorite(
            userId: uid, recipeId: recipeId, value: value);
      } catch (e, st) {
        debugPrint('FavoritesRepositoryImpl remote sync failed: $e $st');
      }
    }
  }
}
