import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/bootstrap.dart';
import '../../domain/entities/user_preferences_entity.dart';

/// Firestore `users/{userId}` profile (optional cloud layer).
class UserProfileRemoteDataSource {
  UserProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  DocumentReference<Map<String, dynamic>>? _userRef(String userId) {
    if (!isAvailable) return null;
    return _firestore!.collection('users').doc(userId);
  }

  /// Creates or merges the user profile document.
  Future<void> ensureUserDocument({
    required String userId,
    required String? displayName,
    required String? email,
    required bool isAnonymous,
  }) async {
    final ref = _userRef(userId);
    if (ref == null) return;
    final snap = await ref.get();
    final payload = <String, dynamic>{
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'isAnonymous': isAnonymous,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!snap.exists) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }
    await ref.set(payload, SetOptions(merge: true));
  }

  /// Merges local preference fields into `preferences` map (non-destructive merge).
  Future<void> mergePreferencesFromLocal(
    String userId,
    UserPreferencesEntity prefs,
  ) async {
    final ref = _userRef(userId);
    if (ref == null) return;
    final map = <String, dynamic>{
      'vegetarian': prefs.vegetarian,
      'avoidSpicy': prefs.avoidSpicy,
      'quickMealsPreferred': prefs.quickMealsPreferred,
      'economicalMealsPreferred': prefs.economicalMealsPreferred,
      'preferredMealType': prefs.preferredMealType,
      'favoriteTags': prefs.favoriteTags,
      'favoriteIngredients': prefs.favoriteIngredients,
      'allergies': prefs.allergies,
      'dislikedIngredients': prefs.dislikedIngredients,
    };
    await ref.set({
      'preferences': map,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
