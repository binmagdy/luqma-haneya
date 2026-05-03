import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/bootstrap.dart';
import '../models/recipe_model.dart';

class UserRecipeRemoteDataSource {
  UserRecipeRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  /// Production should set [isApproved] false until moderation; MVP keeps true.
  Future<void> upsertRecipe(RecipeModel recipe) async {
    if (!isAvailable) return;
    await _firestore!
        .collection('recipes')
        .doc(recipe.id)
        .set(recipe.toFirestore(), SetOptions(merge: true));
  }
}
