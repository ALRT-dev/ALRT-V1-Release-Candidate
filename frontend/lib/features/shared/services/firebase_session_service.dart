import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/shared/providers/rest_client_provider.dart';

/// Signs the app in to Firebase, which Ask ALRT requires.
///
/// Ask ALRT is a Firebase callable declared with `enforceAppCheck: true`
/// and an explicit `request.auth.uid` check. The app authenticates against
/// the ALRT backend, not against Firebase, and had neither firebase_auth
/// nor firebase_app_check, so every call was rejected twice over before it
/// reached the assistant. The provider caught the failure and printed its
/// offline fallback, which is why it read as a flaky assistant rather than
/// as something that had never been connected.
///
/// Two things have to be true for a call to land:
///   1. App Check has an attestation token for this app+device.
///   2. Firebase Auth holds a session for the same person the backend
///      knows, which comes from a custom token the backend mints.
///
/// Both are best-effort. If either fails the assistant falls back to its
/// on-device answers exactly as before, so nothing regresses.
class FirebaseSessionService {
  const FirebaseSessionService._();

  /// Registers App Check. Call once, right after Firebase.initializeApp.
  ///
  /// Debug builds use the debug provider, which needs its printed token
  /// registered in the Firebase console once per machine. Release builds
  /// use Play Integrity on Android and Device Check on iOS.
  static Future<void> initializeAppCheck() async {
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? AndroidDebugProvider()
            : AndroidPlayIntegrityProvider(),
        providerApple:
            kDebugMode ? AppleDebugProvider() : AppleDeviceCheckProvider(),
      );
    } catch (e, s) {
      // A missing App Check registration must not stop the app booting.
      debugPrint('FirebaseSessionService.initializeAppCheck failed: $e\n$s');
    }
  }

  /// Exchanges an ALRT session for a Firebase one.
  ///
  /// Safe to call repeatedly: it returns early when Firebase already holds
  /// a session for this user, so sign-in and app resume can both call it.
  static Future<bool> signIn(final RestClient restClient) async {
    try {
      final existing = FirebaseAuth.instance.currentUser;
      if (existing != null) return true;

      final response = await restClient.getFirebaseCustomToken();
      final data = response.data;
      final token = data is Map ? data['token']?.toString() : null;
      if (token == null || token.isEmpty) return false;

      await FirebaseAuth.instance.signInWithCustomToken(token);
      return true;
    } catch (e, s) {
      debugPrint('FirebaseSessionService.signIn failed: $e\n$s');
      return false;
    }
  }

  /// Drops the Firebase session when the user signs out of ALRT, so the
  /// next person on this phone never inherits it.
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('FirebaseSessionService.signOut failed: $e');
    }
  }
}

/// Signs in to Firebase using the app's REST client.
final providerOfFirebaseSessionSignIn = Provider<Future<bool> Function()>(
  (ref) => () => FirebaseSessionService.signIn(ref.read(providerOfRestClient)),
);
