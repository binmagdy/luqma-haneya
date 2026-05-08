/// User closed the Google account picker or cancelled the OAuth flow.
class AuthUserCancelledException implements Exception {
  const AuthUserCancelledException();

  @override
  String toString() => 'AuthUserCancelledException';
}
