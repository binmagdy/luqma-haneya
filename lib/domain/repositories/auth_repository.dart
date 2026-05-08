import '../entities/auth_session_entity.dart';

abstract class AuthRepository {
  Stream<AuthSessionEntity> watchSession();

  AuthSessionEntity? get currentSession;

  Future<AuthSessionEntity> readSession();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> registerWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  /// Google sign-in. Throws [AuthUserCancelledException] if the user closes the picker.
  Future<void> signInWithGoogle();

  Future<void> signOut();

  /// Stay on device id only; clears Firebase session if any.
  Future<void> continueAsGuest();
}
