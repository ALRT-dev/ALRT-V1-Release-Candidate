import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/auth/views/screens/auth_screen.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_launch_handler.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/profile/views/screens/deleted_account_info_screen.dart';
import 'package:hazard_app/features/shared/providers/app_initialization_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/views/screens/splash_screen.dart';

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

    return SplashScreen();
  }

  void _onInit() {
    ref.read(providerOfAppInitialization.notifier).initialize();
  }

  /// Listens to the app initialization provider and checks the authentication state.
  void _listenToTheAppInitializationProvider() {
    ref.listen(
      providerOfAppInitialization,
      (prev, next) {
        if (prev != next) {
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
    if (loggedInUser != null) {
      // Check if account is scheduled for deletion
      if (loggedInUser.scheduledDeletionAt != null) {
        _gotoDeletedAccountInfoScreen();
      } else if (!loggedInUser.isOnboardingCompleted) {
        _gotoOnboardingScreen();
      } else {
        _gotoHomeScreen();
      }
    } else {
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
