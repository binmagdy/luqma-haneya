import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/bootstrap.dart';
import '../models/recipe_model.dart';

class RecipeRemoteDataSource {
  RecipeRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  /// All approved user recipes from `recipes/*` plus any legacy docs without
  /// `approved` / `approved: true`. Does not filter by current user.
  Future<List<RecipeModel>> fetchRecipes() async {
    if (!isAvailable) return [];
    try {
      final snap = await _firestore!.collection('recipes').get();
      if (kDebugMode) {
        debugPrint(
            'RecipeRemoteDataSource: raw remote docs=${snap.docs.length}');
      }
      final out = <RecipeModel>[];
      for (final d in snap.docs) {
        final m = d.data();
        final approved = m['approved'] ?? m['isApproved'];
        if (approved is bool && approved == false) {
          continue;
        }
        try {
          out.add(RecipeModel.fromFirestore(d.id, m));
        } catch (e, st) {
          if (kDebugMode) {
            debugPrint('RecipeRemoteDataSource: skip id=${d.id} parse $e $st');
          }
        }
      }
      if (kDebugMode) {
        debugPrint(
            'RecipeRemoteDataSource: parsed remote recipes=${out.length}');
      }
      return out;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('RecipeRemoteDataSource.fetchRecipes failed: $e $st');
      }
      return [];
    }
  }
}
