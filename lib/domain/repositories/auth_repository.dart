import '../entities/auth_session_entity.dart';

abstract class AuthRepository {
  Stream<AuthSessionEntity> watchSession();

  AuthSessionEntity? get currentSession;

  Future<AuthSessionEntity> readSession();

  Future<void> signInAnonymously();

  Future<void> signOut();

  /// Stay on device id only; clears Firebase session if any.
  Future<void> continueAsGuest();
}
