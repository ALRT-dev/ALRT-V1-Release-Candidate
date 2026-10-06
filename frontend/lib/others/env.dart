import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static final googleAuthServerClientId =
      dotenv.env['GOOGLE_OAUTH_SERVER_CLIENT_ID'] ?? '';

  static final googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // Optional: only needed once the Maps SDK/Routes API key is restricted to
  // this app in Google Cloud Console (Application restrictions > Android/iOS
  // apps). When set, getRoute() sends them as request headers so a raw REST
  // call to the Routes API carries the same app-identity proof the native
  // Maps SDK provides automatically. Left blank, nothing changes — no header
  // is sent and the key behaves exactly as it does today.
  static final googleMapsAndroidPackageName =
      dotenv.env['GOOGLE_MAPS_ANDROID_PACKAGE_NAME'] ?? '';

  static final googleMapsAndroidCertSha1 =
      dotenv.env['GOOGLE_MAPS_ANDROID_CERT_SHA1'] ?? '';

  static final googleMapsIosBundleId =
      dotenv.env['GOOGLE_MAPS_IOS_BUNDLE_ID'] ?? '';

  static final microsoftClientId = dotenv.env['MICROSOFT_CLIENT_ID'] ?? '';

  static final microsoftTenantId = dotenv.env['MICROSOFT_TENANT_ID'] ?? '';

  // RevenueCat public SDK keys (per platform). Safe to ship in the app —
  // these are publishable keys, not secrets.
  static final revenueCatApiKeyApple =
      dotenv.env['REVENUECAT_API_KEY_APPLE'] ?? '';

  static final revenueCatApiKeyGoogle =
      dotenv.env['REVENUECAT_API_KEY_GOOGLE'] ?? '';
}
