import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/bootstrap.dart';
import '../../domain/auth/auth_exceptions.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/user_identity_local_datasource.dart';
import '../datasources/user_profile_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthLocalDataSource local,
    required UserIdentityLocalDataSource identity,
    UserProfileRemoteDataSource? userProfileRemote,
    FirebaseAuth? firebaseAuth,
  })  : _local = local,
        _identity = identity,
        _userProfileRemote = userProfileRemote,
        _auth =
            firebaseAuth ?? (firebaseAppReady ? FirebaseAuth.instance : null) {
    final auth = _auth;
    if (auth != null) {
      auth.authStateChanges().listen((_) {
        unawaited(_emit());
      });
    }
    unawaited(Future.microtask(() => _emit()));
  }

  final AuthLocalDataSource _local;
  final UserIdentityLocalDataSource _identity;
  final UserProfileRemoteDataSource? _userProfileRemote;
  final FirebaseAuth? _auth;

  final _controller = StreamController<AuthSessionEntity>.broadcast();
  static var _googleMobileInitialized = false;
  AuthSessionEntity? _cache;

  @override
  AuthSessionEntity? get currentSession => _cache;

  AuthSessionEntity _build(User? u, String deviceId) {
    if (u == null) {
      return AuthSessionEntity(localDeviceId: deviceId);
    }
    final primary =
        u.providerData.isNotEmpty ? u.providerData.first.providerId : null;
    return AuthSessionEntity(
      localDeviceId: deviceId,
      firebaseUid: u.uid,
      firebaseIsAnonymous: u.isAnonymous,
      displayName: u.displayName ?? u.email,
      email: u.email,
      primaryProviderId: primary,
    );
  }

  Future<void> _emit() async {
    try {
      final deviceId = await _identity.getOrCreateDeviceId();
      final u = _auth?.currentUser;
      final next = _build(u, deviceId);
      _cache = next;
      if (!_controller.isClosed) _controller.add(next);
    } catch (e, st) {
      debugPrint('AuthRepositoryImpl._emit: $e $st');
    }
  }

  @override
  Stream<AuthSessionEntity> watchSession() => _controller.stream;

  @override
  Future<AuthSessionEntity> readSession() async {
    await _emit();
    return _cache!;
  }

  Future<void> _ensureGoogleSignInMobileReady() async {
    if (_googleMobileInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleMobileInitialized = true;
  }

  Future<void> _afterFirebaseSignIn(User user) async {
    await _local.setPreferGuestOnly(false);
    if (_userProfileRemote?.isAvailable == true) {
      await _userProfileRemote!.syncProfileFieldsForSignedInUser(user);
    }
    await _emit();
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'app-not-ready',
        message: 'Firebase not initialized',
      );
    }
    final cred = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final u = cred.user;
    if (u != null) await _afterFirebaseSignIn(u);
  }

  @override
  Future<void> registerWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'app-not-ready',
        message: 'Firebase not initialized',
      );
    }
    final cred = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final u = cred.user;
    if (u == null) return;
    await u.updateDisplayName(displayName.trim());
    await u.reload();
    final fresh = auth.currentUser ?? u;
    await _local.setPreferGuestOnly(false);
    if (_userProfileRemote?.isAvailable == true) {
      await _userProfileRemote!.writeRegisteredUserProfile(
        user: fresh,
        displayName: displayName.trim(),
      );
    }
    await _emit();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'app-not-ready',
        message: 'Firebase not initialized',
      );
    }
    await auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'app-not-ready',
        message: 'Firebase not initialized',
      );
    }

    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      final cred = await auth.signInWithPopup(provider);
      final u = cred.user;
      if (u != null) await _afterFirebaseSignIn(u);
      return;
    }

    await _ensureGoogleSignInMobileReady();

    late final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted ||
          e.code == GoogleSignInExceptionCode.uiUnavailable) {
        throw const AuthUserCancelledException();
      }
      rethrow;
    }

    final ga = account.authentication;
    final idToken = ga.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'google-missing-token',
        message: 'Missing Google ID token',
      );
    }

    final oauth = GoogleAuthProvider.credential(idToken: idToken);

    try {
      final cred = await auth.signInWithCredential(oauth);
      final u = cred.user;
      if (u != null) await _afterFirebaseSignIn(u);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        await GoogleSignIn.instance.signOut();
      }
      rethrow;
    } on PlatformException catch (e) {
      if (e.code == 'network_error' || e.message?.contains('network') == true) {
        await GoogleSignIn.instance.signOut();
        rethrow;
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (e) {
      debugPrint('AuthRepositoryImpl Google signOut: $e');
    }
    await _auth?.signOut();
    await _local.setPreferGuestOnly(true);
    await _emit();
  }

  @override
  Future<void> continueAsGuest() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {}
    await _auth?.signOut();
    await _local.setPreferGuestOnly(true);
    await _emit();
  }
}
