import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/auth/views/screens/auth_screen.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_launch_handler.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/profile/views/screens/deleted_account_info_screen.dart';
import 'package:hazard_app/features/shared/enums/shared_prefs_key_types.dart';
import 'package:hazard_app/features/shared/providers/app_initialization_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/views/screens/splash_screen.dart';
import 'package:hazard_app/others/startup_trace.dart';
import 'package:hazard_app/features/app_update/providers/force_update_provider.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';

class AppWrapperArgs {
  const AppWrapperArgs({this.homeScreenArgs});

  /// The arguments for the home screen.
  final HomeScreenArgs? homeScreenArgs;
}

class AppWrapper extends ConsumerStatefulWidget {
  /// A simple wrapper widget for the app's main content.
  ///
  /// If the user is not logged in, it shows the auth screen.
  /// If the user is logged in, it shows the home screen.
  const AppWrapper({
    super.key,
    required this.args,
  });

  /// The arguments for the app wrapper.
  final AppWrapperArgs args;

  static const route = '/';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper> {
  /// Routes home-screen widget taps into the app. Attached only once the user
  /// is authenticated and heading to home, so a cold-start tap can never
  /// bypass the auth/onboarding gate.
  HomeWidgetLaunchHandler? _widgetLaunch;

  /// True when a signed-in person's account could not be reached (no
  /// connection, or the server did not answer). They stay signed in and get
  /// a Retry instead of being sent to the sign-in screen.
  bool _unreachable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onInit());
  }

  @override
  void dispose() {
    _widgetLaunch?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _listenToTheAppInitializationProvider();

    if (_unreachable) return _UnreachableScreen(onRetry: _retry);
    // TEST builds: if start-up stalls, show what it is waiting on.
    if (appFlavor == 'dev') {
      return Stack(children: const [SplashScreen(), StartupTraceOverlay()]);
    }
    return SplashScreen();
  }

  void _onInit() {
    StartupTrace.mark('wrapper: first frame, starting init');
    ref.read(providerOfAppInitialization.notifier).initialize();
  }

  void _retry() {
    setState(() => _unreachable = false);
    ref.read(providerOfAppInitialization.notifier).initialize();
  }

  /// Whether the user fetch failed for want of an answer (no HTTP status),
  /// as opposed to the server refusing the stored sign-in.
  bool _failedWithoutAnswer() {
    final fetched = ref.read(providerOfLoggedInUserFetcher);
    return fetched.maybeWhen(
      data: (result) =>
          result.when((_) => false, (error) => error.code == null),
      error: (_, _) => true,
      // Still loading after the start-up cap: the server never answered.
      loading: () => true,
      orElse: () => false,
    );
  }

  Future<bool> _hasStoredSignIn() async {
    final result = await ref
        .read(providerOfSharedPreferencesRepository)
        .getString(key: SharedPrefsKey.refreshToken);
    final token = result.whenSuccess((value) => value);
    return token != null && token.isNotEmpty;
  }

  /// Listens to the app initialization provider and checks the authentication state.
  void _listenToTheAppInitializationProvider() {
    ref.listen(
      providerOfAppInitialization,
      (prev, next) {
        if (prev != next) {
          StartupTrace.mark('wrapper: init state $prev -> $next');
          if (next) _checkAuthState();
        }
      },
    );
  }

  /// Checks which screen to navigate to based on the authentication state.
  void _checkAuthState() async {
    // create a fake delay to simulate loading
    // await Future.delayed(const Duration(seconds: 2));
    // if (!mounted) return;

    final loggedInUser = ref.read(providerOfLoggedInUser);
    // App start and every sign-in come through here: sign RevenueCat in as
    // this user once, so paywalls, Restore and plan reads never meet an
    // unconfigured SDK. A build without keys skips it quietly.
    if (loggedInUser != null) {
      unawaited(
        ref.read(providerOfRevenueCat).ensureConfiguredFor(loggedInUser.id),
      );
    }
    // A build the backend no longer supports is stopped here, on a
    // full-screen "Please update ALRT" (shown by MyApp over any route).
    unawaited(ref.read(providerOfForceUpdate.notifier).check());
    if (loggedInUser != null) {
      // Check if account is scheduled for deletion
      if (loggedInUser.scheduledDeletionAt != null) {
        StartupTrace.mark('wrapper: -> deleted-account screen');
        _gotoDeletedAccountInfoScreen();
      } else if (!loggedInUser.isOnboardingCompleted) {
        StartupTrace.mark('wrapper: -> onboarding');
        _gotoOnboardingScreen();
      } else {
        StartupTrace.mark('wrapper: -> home');
        _gotoHomeScreen();
      }
    } else if (_failedWithoutAnswer() && await _hasStoredSignIn()) {
      if (!mounted) return;
      StartupTrace.mark('wrapper: -> cannot reach ALRT');
      setState(() => _unreachable = true);
    } else {
      if (!mounted) return;
      StartupTrace.mark('wrapper: -> sign-in screen');
      _gotoAuthScreen();
    }
  }

  /// Navigates to the auth screen.
  void _gotoAuthScreen() {
    context.go(AuthScreen.route);
  }

  /// Navigates to the onboarding screen based on the current onboarding step.
  void _gotoOnboardingScreen() {
    context.go(OnboardingStep.welcome.route);
  }

  /// Navigates to the home screen.
  void _gotoHomeScreen() {
    context.go(
      HomeScreen.route,
      extra: widget.args.homeScreenArgs,
    );
    // Now that we're authenticated and on home, start honoring widget taps.
    _widgetLaunch ??= HomeWidgetLaunchHandler(ref)..attach();
  }

  /// Navigates to the deleted account info screen.
  void _gotoDeletedAccountInfoScreen() {
    context.go(DeletedAccountInfoScreen.route);
  }
}

/// Shown instead of the sign-in screen when a signed-in person's account
/// could not be reached at start-up.
class _UnreachableScreen extends StatelessWidget {
  const _UnreachableScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 44),
                const SizedBox(height: 16),
                const Text(
                  "Can't reach ALRT",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your connection and try again. You are still signed in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
