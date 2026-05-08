import 'auth_session_entity.dart';

/// Auth session + Firestore `users/{uid}.role` for UI and routing.
class AppUserContext {
  const AppUserContext({
    required this.session,
    this.role = 'user',
  });

  final AuthSessionEntity session;

  /// From Firestore `users/{uid}.role`; only the literal `"admin"` is elevated.
  /// Missing or any other value is treated as non-admin (`user` in UI).
  final String role;

  bool get isLoggedIn => session.isLoggedIn;

  String? get userId => session.firebaseUid;

  /// Admin UI only when Firestore `role` is exactly `admin`.
  bool get isAdmin =>
      isLoggedIn && !session.firebaseIsAnonymous && role == 'admin';
}
