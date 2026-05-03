/// Optional Firebase Auth session + stable local device id for guests.
class AuthSessionEntity {
  const AuthSessionEntity({
    required this.localDeviceId,
    this.firebaseUid,
    this.firebaseIsAnonymous = false,
    this.displayName,
  });

  /// Stable id from local storage (guests).
  final String localDeviceId;

  final String? firebaseUid;
  final bool firebaseIsAnonymous;
  final String? displayName;

  bool get isGuest => firebaseUid == null;

  /// Firestore `users/{id}` and public `ratings/{userId}` when logged in.
  String get firestoreSyncId => firebaseUid ?? localDeviceId;

  String? get resolvedDisplayName {
    if (firebaseUid == null) return null;
    if (firebaseIsAnonymous) return 'زائر سحابي';
    return displayName ?? firebaseUid!.substring(0, 8);
  }

  bool get canPublishPublicRatings => firebaseUid != null;
}
