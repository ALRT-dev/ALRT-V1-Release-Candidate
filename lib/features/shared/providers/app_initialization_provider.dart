import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/auth/providers/service_providers.dart';
import 'package:hazard_app/features/map/providers/hazard_markers_bitmaps_provider.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/providers/instance_providers.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/main_categories_provider.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/services/firebase_session_service.dart';
import 'package:hazard_app/features/shared/services/sim_country.dart';
import 'package:shared_preferences/shared_preferences.dart';

final providerOfAppInitialization =
    NotifierProvider.autoDispose<AppInitializationProvider, bool>(
      AppInitializationProvider.new,
    );

class AppInitializationProvider extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  AppUser? get _loggedInUser => ref.read(providerOfLoggedInUser);
  bool get _isOnboardingCompleted =>
      _loggedInUser?.isOnboardingCompleted ?? false;

  /// Initializes the app by performing necessary setup tasks.
  Future<void> initialize() async {
    state = false;

    await _initializeSharedPreferences();
    if (!ref.mounted) return;

    // The SIM's country decides which emergency number the app offers, so
    // it is read before any screen can ask. Never throws, and a null just
    // falls the resolution through to device region.
    await SimCountry.load();
    if (!ref.mounted) return;

    // initialize these things after shared preference is initialized but before logged in user is initialized
    await Future.wait([
      _initializeLoggedInUser(),
      _initializeGoogleSignIn(),
    ]);
    if (!ref.mounted) return;

    // initialize these things after logged in user is initialized
    await Future.wait([
      _getCurrentUserLocation(),
      _generateMarkerBitmaps(),
      _initializeMainCategories(),
      // Ask ALRT's callable wants a Firebase uid. Best-effort: a failure
      // leaves the assistant on its on-device answers, as before.
      _signInToFirebase(),
    ]);
    if (!ref.mounted) return;

    state = true;
  }

  /// Initializes the shared preferences instance.
  Future<void> _initializeSharedPreferences() {
    return runAsyncCall(
      name: '_initializeSharedPreferences',
      future: () async {
        final sharedPrefs = await SharedPreferences.getInstance();
        ref.read(providerOfSharedPreferencesInstance.notifier).state =
            sharedPrefs;
      },
      onError: (_) {},
    );
  }

  /// Initialize google sign-in.
  Future<void> _initializeGoogleSignIn() {
    return ref.read(providerOfAuthService).initializeGoogleSignIn();
  }

  /// Initializes the current logged in user.
  Future<void> _initializeLoggedInUser() {
    return ref.refresh(providerOfLoggedInUserFetcher.future);
  }

  /// Exchanges the ALRT session for a Firebase one so Ask ALRT can call
  /// its backend. Never throws: the assistant degrades, the app does not.
  Future<void> _signInToFirebase() async {
    await ref.read(providerOfFirebaseSessionSignIn)();
  }

  /// Gets the location of the current user.
  Future<void> _getCurrentUserLocation() async {
    if (!_isOnboardingCompleted) return;
    return ref.read(providerOfLocation.notifier).getLocation();
  }

  /// Generates hazard marker bitmaps.
  Future<void> _generateMarkerBitmaps() async {
    final isLoggedIn = ref.read(providerOfLoggedInUser) != null;
    if (!isLoggedIn) return;
    return ref
        .read(providerOfHazardMarkerBitmaps.notifier)
        .generateMarkerBitmaps();
  }

  Future<void> _initializeMainCategories() {
    return ref
        .read(providerOfMainCategories.notifier)
        .getAllMainHazardCategories();
  }
}
