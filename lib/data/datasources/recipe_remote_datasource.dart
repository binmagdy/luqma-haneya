import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/bootstrap.dart';
import '../../domain/value_objects/recipe_moderation.dart';
import '../../domain/value_objects/recipe_source.dart';
import '../models/recipe_model.dart';

class RecipeRemoteDataSource {
  RecipeRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  /// Remote docs merged into catalog; caller filters to public catalog rows.
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

  /// Single doc read; allowed by rules for owner/admin/public approved.
  Future<RecipeModel?> tryFetchRecipeById(String id) async {
    if (!isAvailable) return null;
    try {
      final doc = await _firestore!.collection('recipes').doc(id).get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      return RecipeModel.fromFirestore(doc.id, data);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      if (kDebugMode) {
        debugPrint('RecipeRemoteDataSource.tryFetchRecipeById: $e');
      }
      return null;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('RecipeRemoteDataSource.tryFetchRecipeById: $e $st');
      }
      return null;
    }
  }

  /// Admin-only list by moderation status (requires composite index).
  Future<List<RecipeModel>> fetchRecipesByStatus(String status) async {
    if (!isAvailable) return [];
    try {
      final snap = await _firestore!
          .collection('recipes')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      final out = <RecipeModel>[];
      for (final d in snap.docs) {
        try {
          out.add(RecipeModel.fromFirestore(d.id, d.data()));
        } catch (_) {}
      }
      return out;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('RecipeRemoteDataSource.fetchRecipesByStatus: $e $st');
      }
      return [];
    }
  }
}

/// True when a recipe row may appear in public browse/search/trending/meal plan.
bool recipeRowIsPublicCatalog(RecipeModel r) {
  if (r.source == RecipeSource.asset) {
    return true;
  }
  if (r.visibility != RecipeVisibility.public) {
    return false;
  }
  if (r.moderationStatus == RecipeModerationStatus.pending ||
      r.moderationStatus == RecipeModerationStatus.rejected) {
    return false;
  }
  if (!r.isApproved) {
    return false;
  }
  return r.moderationStatus == RecipeModerationStatus.approved;
}
