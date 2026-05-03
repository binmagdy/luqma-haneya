import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/bootstrap.dart';

class FavoritesRemoteDataSource {
  FavoritesRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  Future<void> setFavorite({
    required String userId,
    required String recipeId,
    required bool value,
  }) async {
    if (!isAvailable) return;
    final ref = _firestore!
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipeId);
    if (value) {
      await ref.set({
        'recipeId': recipeId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  Future<Set<String>> fetchFavorites(String userId) async {
    if (!isAvailable) return {};
    final snap = await _firestore!
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();
    return snap.docs.map((d) => d.id).toSet();
  }
}
