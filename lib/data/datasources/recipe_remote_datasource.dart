import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/bootstrap.dart';
import '../models/recipe_model.dart';

class RecipeRemoteDataSource {
  RecipeRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  Future<List<RecipeModel>> fetchRecipes() async {
    if (!isAvailable) return [];
    final snap = await _firestore!.collection('recipes').get();
    return snap.docs
        .map((d) => RecipeModel.fromFirestore(d.id, d.data()))
        .toList();
  }
}
