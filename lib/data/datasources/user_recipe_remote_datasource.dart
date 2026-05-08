import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/bootstrap.dart';
import '../models/recipe_model.dart';

class UserRecipeRemoteDataSource {
  UserRecipeRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  Future<void> upsertRecipe(RecipeModel recipe) async {
    if (!isAvailable) return;
    final map = Map<String, dynamic>.from(recipe.toFirestore());
    map['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore!
        .collection('recipes')
        .doc(recipe.id)
        .set(map, SetOptions(merge: true));
  }

  /// All recipes created by [uid] (pending/approved/rejected) for "my submissions".
  Future<List<RecipeModel>> fetchByCreator(String uid) async {
    if (!isAvailable) return [];
    try {
      final snap = await _firestore!
          .collection('recipes')
          .where('createdBy', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();
      final out = <RecipeModel>[];
      for (final d in snap.docs) {
        try {
          out.add(RecipeModel.fromFirestore(d.id, d.data()));
        } catch (_) {}
      }
      return out;
    } catch (_) {
      return [];
    }
  }
}
