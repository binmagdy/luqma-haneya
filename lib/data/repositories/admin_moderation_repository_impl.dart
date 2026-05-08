import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/bootstrap.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/admin_moderation_repository.dart';
import '../../domain/value_objects/recipe_moderation.dart';
import '../models/recipe_model.dart';

class AdminModerationRepositoryImpl implements AdminModerationRepository {
  AdminModerationRepositoryImpl([FirebaseFirestore? firestore])
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  bool get _ok => firebaseAppReady && _firestore != null;

  DocumentReference<Map<String, dynamic>> _ref(String id) =>
      _firestore!.collection('recipes').doc(id);

  @override
  Future<void> approveRecipe({
    required String recipeId,
    required String adminUid,
  }) async {
    if (!_ok) return;
    await _ref(recipeId).update({
      'status': RecipeModerationStatus.approved,
      'approved': true,
      'isApproved': true,
      'approvedBy': adminUid,
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'rejectedReason': FieldValue.delete(),
      'rejectedBy': FieldValue.delete(),
      'rejectedAt': FieldValue.delete(),
    });
  }

  @override
  Future<void> rejectRecipe({
    required String recipeId,
    required String adminUid,
    required String reason,
  }) async {
    if (!_ok) return;
    await _ref(recipeId).update({
      'status': RecipeModerationStatus.rejected,
      'approved': false,
      'isApproved': false,
      'rejectedBy': adminUid,
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectedReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> setVisibility({
    required String recipeId,
    required String visibility,
  }) async {
    if (!_ok) return;
    await _ref(recipeId).update({
      'visibility': visibility,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    if (!_ok) return;
    await _ref(recipeId).delete();
  }

  @override
  Future<void> saveRecipeDocument(RecipeEntity recipe) async {
    if (!_ok) return;
    final m = RecipeModel.fromEntity(recipe);
    final map = Map<String, dynamic>.from(m.toFirestore());
    map['updatedAt'] = FieldValue.serverTimestamp();
    await _ref(m.id).set(map, SetOptions(merge: true));
  }
}
