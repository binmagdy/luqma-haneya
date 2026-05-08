/// OAuth 2.0 **Web client** ID (ends with `.apps.googleusercontent.com`) from
/// Firebase Console → Project settings → Your apps → Web client (or Google Cloud
/// Credentials). Required for reliable Google Sign-In → Firebase on **Android/iOS**
/// when `google-services.json` has an empty `oauth_client` list.
///
/// Pass at build time: `--dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com`
/// or replace the default below for local dev only.
const String kGoogleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue: '',
);
