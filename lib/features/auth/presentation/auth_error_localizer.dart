import 'package:firebase_auth/firebase_auth.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';

import '../../../domain/auth/auth_exceptions.dart';

String localizedAuthError(AppLocalizations l10n, Object error) {
  if (error is AuthUserCancelledException) {
    return '';
  }
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return l10n.authValEmailInvalid;
      case 'wrong-password':
        return l10n.authErrorWrongPassword;
      case 'user-not-found':
        return l10n.authErrorUserNotFound;
      case 'user-disabled':
        return l10n.authErrorUserNotFound;
      case 'email-already-in-use':
        return l10n.authErrorEmailInUse;
      case 'weak-password':
        return l10n.authErrorWeakPassword;
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return l10n.authErrorInvalidCredential;
      case 'network-request-failed':
      case 'app-not-ready':
        return l10n.authErrorNetwork;
      default:
        return l10n.authErrorGeneric(error.message ?? error.code);
    }
  }
  return l10n.authErrorGeneric(error.toString());
}
