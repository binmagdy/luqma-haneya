import 'auth_session_entity.dart';

/// Auth session + Firestore `users/{uid}.role` for UI and routing.
class AppUserContext {
  const AppUserContext({
    required this.session,
    this.role = 'user',
  });

  final AuthSessionEntity session;

  /// `user` or `admin` from Firestore; missing field treated as `user`.
  final String role;

  bool get isLoggedIn => session.isLoggedIn;

  String? get userId => session.firebaseUid;

  bool get isAdmin =>
      isLoggedIn && !session.firebaseIsAnonymous && role == 'admin';
}
