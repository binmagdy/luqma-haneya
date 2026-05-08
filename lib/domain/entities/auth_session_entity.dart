/// Optional Firebase Auth session + stable local device id for guests.
class AuthSessionEntity {
  const AuthSessionEntity({
    required this.localDeviceId,
    this.firebaseUid,
    this.firebaseIsAnonymous = false,
    this.displayName,
    this.email,
  });

  /// Stable id from local storage (guests).
  final String localDeviceId;

  final String? firebaseUid;
  final bool firebaseIsAnonymous;
  final String? displayName;

  /// Email when linked credential (null for anonymous / guest).
  final String? email;

  /// Firebase session active (anonymous or future Google).
  bool get isLoggedIn => firebaseUid != null;

  bool get isGuest => firebaseUid == null;

  /// Same id used for Firestore user paths when logged in; local device id as guest.
  String get userId => firestoreSyncId;

  String get firestoreSyncId => firebaseUid ?? localDeviceId;

  String? get resolvedDisplayName {
    if (firebaseUid == null) return null;
    if (firebaseIsAnonymous) return 'زائر سحابي';
    return displayName ?? email ?? firebaseUid!.substring(0, 8);
  }

  bool get canPublishPublicRatings => firebaseUid != null;
}
