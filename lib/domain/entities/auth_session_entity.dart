/// Optional Firebase Auth session + stable local device id for guests.
class AuthSessionEntity {
  const AuthSessionEntity({
    required this.localDeviceId,
    this.firebaseUid,
    this.firebaseIsAnonymous = false,
    this.displayName,
    this.email,
    this.primaryProviderId,
  });

  /// Stable id from local storage (guests).
  final String localDeviceId;

  final String? firebaseUid;
  final bool firebaseIsAnonymous;
  final String? displayName;

  /// Email when linked credential (null for guest-only / some OAuth edge cases).
  final String? email;

  /// Firebase `UserInfo.providerId`, e.g. `password`, `google.com`.
  final String? primaryProviderId;

  /// Firebase session active (email, Google, etc.).
  bool get isLoggedIn => firebaseUid != null;

  /// Guest = no Firebase account on this device session (local-only identity).
  bool get isGuest => firebaseUid == null;

  /// Same id used for Firestore user paths when logged in; local device id as guest.
  String get userId => firestoreSyncId;

  String get firestoreSyncId => firebaseUid ?? localDeviceId;

  String? get resolvedDisplayName {
    if (firebaseUid == null) return null;
    if (firebaseIsAnonymous) return 'زائر سحابي';
    return displayName ?? email ?? firebaseUid!.substring(0, 8);
  }

  /// Public cloud ratings require a real (non-anonymous) Firebase user.
  bool get canPublishPublicRatings =>
      firebaseUid != null && !firebaseIsAnonymous;
}
