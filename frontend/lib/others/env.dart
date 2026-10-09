/// Compile-time environment configuration.
///
/// Values are injected at build time via `--dart-define-from-file=.env` and
/// compiled into the binary as constants. They are NOT shipped as a readable
/// plaintext asset (the old `flutter_dotenv` approach bundled the `.env` file
/// in the APK/IPA where anyone could extract it).
///
/// An undefined key defaults to the empty string, matching the previous
/// `dotenv.env['KEY'] ?? ''` behaviour.
class Env {
  static const googleAuthServerClientId =
      String.fromEnvironment('GOOGLE_OAUTH_SERVER_CLIENT_ID');

  static const googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  // Optional: only needed once the Maps SDK/Routes API key is restricted to
  // this app in Google Cloud Console (Application restrictions > Android/iOS
  // apps). When set, getRoute() sends them as request headers so a raw REST
  // call to the Routes API carries the same app-identity proof the native
  // Maps SDK provides automatically. Left blank, nothing changes -- no header
  // is sent and the key behaves exactly as it does today.
  static const googleMapsAndroidPackageName =
      String.fromEnvironment('GOOGLE_MAPS_ANDROID_PACKAGE_NAME');

  static const googleMapsAndroidCertSha1 =
      String.fromEnvironment('GOOGLE_MAPS_ANDROID_CERT_SHA1');

  static const googleMapsIosBundleId =
      String.fromEnvironment('GOOGLE_MAPS_IOS_BUNDLE_ID');

  static const microsoftClientId =
      String.fromEnvironment('MICROSOFT_CLIENT_ID');

  static const microsoftTenantId =
      String.fromEnvironment('MICROSOFT_TENANT_ID');

  // RevenueCat public SDK keys (per platform). Safe to ship in the app --
  // these are publishable keys, not secrets.
  static const revenueCatApiKeyApple =
      String.fromEnvironment('REVENUECAT_API_KEY_APPLE');

  static const revenueCatApiKeyGoogle =
      String.fromEnvironment('REVENUECAT_API_KEY_GOOGLE');
}
