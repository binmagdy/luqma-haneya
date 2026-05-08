import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({
    required FavoritesLocalDataSource local,
    required FavoritesRemoteDataSource remote,
    required AuthRepository auth,
  })  : _local = local,
        _remote = remote,
        _auth = auth;

  final FavoritesLocalDataSource _local;
  final FavoritesRemoteDataSource _remote;
  final AuthRepository _auth;

  @override
  Future<Set<String>> favoriteRecipeIds() async {
    final local = await _local.load();
    final session = await _auth.readSession();
    if (session.isGuest || !_remote.isAvailable) {
      return local;
    }
    final uid = session.firebaseUid!;
    try {
      final remote = await _remote.fetchFavorites(uid);
      if (remote.isNotEmpty) {
        final merged = {...local, ...remote};
        await _local.save(merged);
        return merged;
      }
    } catch (e, st) {
      debugPrint('FavoritesRepositoryImpl remote fetch failed: $e $st');
    }
    return local;
  }

  @override
  Future<bool> isFavorite(String recipeId) async {
    final s = await favoriteRecipeIds();
    return s.contains(recipeId);
  }

  @override
  Future<Set<String>> getFavorites() => favoriteRecipeIds();

  @override
  Future<void> addFavorite(String recipeId) => setFavorite(recipeId, true);

  @override
  Future<void> removeFavorite(String recipeId) => setFavorite(recipeId, false);

  @override
  Future<void> setFavorite(String recipeId, bool value) async {
    final cur = await _local.load();
    if (value) {
      cur.add(recipeId);
    } else {
      cur.remove(recipeId);
    }
    await _local.save(cur);
    final session = await _auth.readSession();
    if (session.isGuest || !_remote.isAvailable) {
      return;
    }
    try {
      final uid = session.firebaseUid!;
      await _remote.setFavorite(
        userId: uid,
        recipeId: recipeId,
        value: value,
      );
    } catch (e, st) {
      debugPrint('FavoritesRepositoryImpl remote sync failed: $e $st');
    }
  }

  @override
  Future<void> pushLocalFavoritesToCloud() async {
    final session = await _auth.readSession();
    if (session.isGuest || !_remote.isAvailable) return;
    final uid = session.firebaseUid!;
    final local = await _local.load();
    try {
      final remote = await _remote.fetchFavorites(uid);
      for (final id in local) {
        if (!remote.contains(id)) {
          await _remote.setFavorite(userId: uid, recipeId: id, value: true);
        }
      }
      if (kDebugMode) {
        debugPrint(
          'FavoritesRepositoryImpl.pushLocalFavoritesToCloud: uploaded '
          '${local.length} local ids',
        );
      }
    } catch (e, st) {
      debugPrint('FavoritesRepositoryImpl.pushLocalFavoritesToCloud: $e $st');
    }
  }
}
