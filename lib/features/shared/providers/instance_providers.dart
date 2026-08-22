import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hazard_app/others/env.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider of [Connectivity] instance.
final providerOfConnectivityInstance = Provider<Connectivity>(
  (ref) => Connectivity(),
);

/// Provider of [InternetConnectionChecker] instance.
final providerOfInternetConnectionCheckerInstance =
    Provider<InternetConnectionChecker>(
      (ref) => InternetConnectionChecker.instance,
    );

/// Provider of [SharedPreferences] instance.
final providerOfSharedPreferencesInstance = StateProvider<SharedPreferences?>(
  (ref) => null,
);

/// Provider of [GoogleSignIn] instance.
final providerOfGoogleSignInInstance = Provider<GoogleSignIn>(
  (ref) => GoogleSignIn.instance,
);

/// Provider of [PolylinePoints] instance.
final providerOfPolylinePointsInstance = Provider<PolylinePoints>(
  (ref) => PolylinePoints(
    apiKey: Env.googleMapsApiKey,
  ),
);

/// Provider of [FirebaseMessaging] instance.
final providerOfFirebaseMessagingInstance = Provider<FirebaseMessaging>(
  (ref) => FirebaseMessaging.instance,
);

/// Provider of [DefaultCacheManager] instance.
final providerOfCacheManagerInstance = Provider<CacheManager>(
  (ref) {
    final cacheKey = 'libCachedImageData';
    return CacheManager(
      Config(
        cacheKey,
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 5000,
        fileSystem: IOFileSystem(cacheKey),
      ),
    );
  },
);
