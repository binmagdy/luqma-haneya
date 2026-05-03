import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/bootstrap.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/user_identity_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthLocalDataSource local,
    required UserIdentityLocalDataSource identity,
    FirebaseAuth? firebaseAuth,
  })  : _local = local,
        _identity = identity,
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
  final FirebaseAuth? _auth;

  final _controller = StreamController<AuthSessionEntity>.broadcast();
  AuthSessionEntity? _cache;

  @override
  AuthSessionEntity? get currentSession => _cache;

  AuthSessionEntity _build(User? u, String deviceId) {
    if (u == null) {
      return AuthSessionEntity(localDeviceId: deviceId);
    }
    return AuthSessionEntity(
      localDeviceId: deviceId,
      firebaseUid: u.uid,
      firebaseIsAnonymous: u.isAnonymous,
      displayName: u.displayName ?? u.email,
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

  @override
  Future<void> signInAnonymously() async {
    if (_auth == null) {
      debugPrint('AuthRepositoryImpl: Firebase not ready');
      return;
    }
    await _local.setPreferGuestOnly(false);
    await _auth.signInAnonymously();
    await _emit();
  }

  @override
  Future<void> signOut() async {
    await _auth?.signOut();
    await _local.setPreferGuestOnly(true);
    await _emit();
  }

  @override
  Future<void> continueAsGuest() async {
    await _local.setPreferGuestOnly(true);
    await _auth?.signOut();
    await _emit();
  }
}
