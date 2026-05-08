import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  static const String defaultRole = 'user';

  /// Only `"admin"` grants admin UI; missing or any other value → [defaultRole].
  String _normalizeRole(String? raw) {
    if (raw == 'admin') return 'admin';
    return defaultRole;
  }

  /// True when Firestore has no `role` field (treat as [defaultRole] in app only).
  bool _roleFieldMissing(Map<String, dynamic>? data) {
    if (data == null) return true;
    return !data.containsKey('role');
  }

  /// Firestore `users/{userId}.role` — defaults to [defaultRole] if missing.
  Future<String> getRole(String userId) async {
    final ref = _userRef(userId);
    if (ref == null) return defaultRole;
    final snap = await ref.get();
    return _normalizeRole(snap.data()?['role'] as String?);
  }

  Stream<String> watchRole(String userId) {
    final ref = _userRef(userId);
    if (ref == null) return Stream.value(defaultRole);
    return ref.snapshots().map(
          (s) => _normalizeRole(s.data()?['role'] as String?),
        );
  }

  static String providerKind(User user) {
    for (final p in user.providerData) {
      if (p.providerId == 'google.com') return 'google';
      if (p.providerId == 'password') return 'password';
    }
    return 'unknown';
  }

  /// Full profile after email registration (creates doc with defaults).
  ///
  /// New documents always get `role: "user"`. If the document already exists,
  /// identity fields are merged but [role] is never sent (preserves e.g. admin).
  Future<void> writeRegisteredUserProfile({
    required User user,
    required String displayName,
  }) async {
    final ref = _userRef(user.uid);
    if (ref == null) return;
    final snap = await ref.get();
    final now = FieldValue.serverTimestamp();
    if (!snap.exists) {
      await ref.set({
        'uid': user.uid,
        'displayName': displayName,
        'email': user.email,
        'provider': 'password',
        'role': defaultRole,
        'isGuest': false,
        'isAnonymous': user.isAnonymous,
        'createdAt': now,
        'updatedAt': now,
        'favoriteRecipeIds': <String>[],
        'likedRecipeIds': <String>[],
        'viewedRecipeIds': <String>[],
        'preferredTags': <String>[],
        'savedMealPlans': <String>[],
        'uploadedRecipesCount': 0,
        'ratingsCount': 0,
      }, SetOptions(merge: true));
      return;
    }
    await ref.set({
      'uid': user.uid,
      'displayName': displayName,
      'email': user.email,
      'provider': 'password',
      'isGuest': false,
      'isAnonymous': user.isAnonymous,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  /// Merge identity fields after any Firebase sign-in.
  Future<void> syncProfileFieldsForSignedInUser(User user) async {
    final ref = _userRef(user.uid);
    if (ref == null) return;
    final snap = await ref.get();
    final now = FieldValue.serverTimestamp();
    final payload = <String, dynamic>{
      'uid': user.uid,
      'displayName': user.displayName ?? user.email?.split('@').first,
      'email': user.email,
      'provider': providerKind(user),
      'isGuest': false,
      'isAnonymous': user.isAnonymous,
      'updatedAt': now,
    };
    if (!snap.exists) {
      payload['createdAt'] = now;
      payload['role'] = defaultRole;
      payload['favoriteRecipeIds'] = <String>[];
      payload['likedRecipeIds'] = <String>[];
      payload['viewedRecipeIds'] = <String>[];
      payload['preferredTags'] = <String>[];
      payload['savedMealPlans'] = <String>[];
      payload['uploadedRecipesCount'] = 0;
      payload['ratingsCount'] = 0;
    } else if (_roleFieldMissing(snap.data())) {
      payload['role'] = defaultRole;
    }
    await ref.set(payload, SetOptions(merge: true));
  }

  /// @nodoc Legacy name used by older call sites.
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
      'uid': userId,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'isAnonymous': isAnonymous,
      'isGuest': false,
      'provider': isAnonymous ? 'anonymous' : 'unknown',
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!snap.exists) {
      payload['createdAt'] = FieldValue.serverTimestamp();
      payload['role'] = defaultRole;
      payload['favoriteRecipeIds'] = <String>[];
      payload['likedRecipeIds'] = <String>[];
      payload['viewedRecipeIds'] = <String>[];
      payload['preferredTags'] = <String>[];
      payload['savedMealPlans'] = <String>[];
      payload['uploadedRecipesCount'] = 0;
      payload['ratingsCount'] = 0;
    } else if (_roleFieldMissing(snap.data())) {
      payload['role'] = defaultRole;
    }
    await ref.set(payload, SetOptions(merge: true));
  }

  Future<void> mergeFavoriteRecipeIds(String userId, Set<String> ids) async {
    final ref = _userRef(userId);
    if (ref == null || ids.isEmpty) return;
    await ref.set({
      'favoriteRecipeIds': FieldValue.arrayUnion(ids.toList()),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
      'preferredTags': prefs.favoriteTags,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
