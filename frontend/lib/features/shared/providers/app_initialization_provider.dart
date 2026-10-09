import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/auth/providers/service_providers.dart';
import 'package:hazard_app/features/map/providers/hazard_markers_bitmaps_provider.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/providers/instance_providers.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/providers/main_categories_provider.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/services/sim_country.dart';
import 'package:hazard_app/others/startup_trace.dart';
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
    StartupTrace.mark('init: start');

    await _initializeSharedPreferences();
    StartupTrace.mark('init: settings storage ready');
    if (!ref.mounted) return;

    // Migrate any auth tokens still in plaintext SharedPreferences into
    // encrypted storage. No-ops after the first successful run.
    await _migrateTokensToSecureStorage();
    if (!ref.mounted) return;

    // The SIM's country decides which emergency number the app offers, so
    // it is read before any screen can ask. Never throws, and a null just
    // falls the resolution through to device region.
    await _bounded('loadSimCountry', SimCountry.load, 3);
    if (!ref.mounted) return;

    // initialize these things after shared preference is initialized but before logged in user is initialized
    StartupTrace.mark('init: checking sign-in and Google set-up');
    await Future.wait([
      _initializeLoggedInUser(),
      _bounded('initializeGoogleSignIn', _initializeGoogleSignIn, 8),
    ]);
    if (!ref.mounted) return;

    StartupTrace.mark(
      'init: signed in = ${ref.read(providerOfLoggedInUser) != null}; loading location, markers, categories',
    );
    // initialize these things after logged in user is initialized
    await Future.wait([
      _bounded('getCurrentUserLocation', _getCurrentUserLocation, 8),
      _bounded('generateMarkerBitmaps', _generateMarkerBitmaps, 10),
      _bounded('initializeMainCategories', _initializeMainCategories, 10),
    ]);
    if (!ref.mounted) {
      StartupTrace.mark('init: stopped (provider disposed)');
      return;
    }

    StartupTrace.mark('init: done');
    state = true;
  }

  /// Runs one start-up step without ever holding the splash screen: it may
  /// take at most [seconds] and any error is logged and dropped. Each step
  /// already copes with having no result (categories and markers reload on
  /// use, location is asked for again), so the app always moves on to
  /// sign-in, onboarding or home instead of sitting on the splash while a
  /// slow or unreachable server is retried.
  Future<void> _bounded(
    final String name,
    final Future<void> Function() step,
    final int seconds,
  ) async {
    StartupTrace.mark('  $name: start');
    try {
      await step().timeout(Duration(seconds: seconds));
      StartupTrace.mark('  $name: done');
    } catch (error) {
      StartupTrace.mark('  $name: SKIPPED ($error)');
      log('Start-up step $name skipped: $error', name: 'AppInitialization');
    }
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

  /// Migrates auth tokens from plaintext SharedPreferences to encrypted
  /// storage. Safe on every cold start -- no-ops when nothing to migrate.
  Future<void> _migrateTokensToSecureStorage() {
    return runAsyncCall(
      name: '_migrateTokensToSecureStorage',
      future: () async {
        await ref.read(providerOfSecureTokenStorage).migrateFromSharedPrefs(
              ref.read(providerOfSharedPreferencesRepository),
            );
      },
      onError: (_) {},
    );
  }

  /// Initialize google sign-in.
  Future<void> _initializeGoogleSignIn() async {
    await ref.read(providerOfAuthService).initializeGoogleSignIn();
  }

  /// Initializes the current logged in user.
  ///
  /// Capped at 20 seconds so a poor connection can't hold the splash for the
  /// client's full request timeout; the wrapper then offers a retry.
  Future<void> _initializeLoggedInUser() async {
    StartupTrace.mark('  user: start');
    try {
      final result = await ref
          .refresh(providerOfLoggedInUserFetcher.future)
          .timeout(const Duration(seconds: 20));
      StartupTrace.mark(
        '  user: ${result.when((_) => 'signed in', (e) => 'none (${e.code ?? 'no answer'}: ${e.message})')}',
      );
    } catch (error) {
      StartupTrace.mark('  user: FAILED ($error)');
      // Read by AppWrapper through providerOfLoggedInUserFetcher.
    }
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

  Future<void> _initializeMainCategories() async {
    await ref
        .read(providerOfMainCategories.notifier)
        .getAllMainHazardCategories();
  }
}
