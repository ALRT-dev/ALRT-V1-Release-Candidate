import 'package:hazard_app/features/profile/views/screens/safety_profile_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_complete_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_disclaimer_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_legal_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_welcome_screen.dart';

enum OnboardingStep {
  welcome,
  disclaimer,
  legal,
  safetyProfile,
  // location,
  // radius,
  // pushNotification,
  completed;

  /// Returns the route associated with the onboarding step.
  String get route {
    switch (this) {
      case OnboardingStep.welcome:
        return OnboardingWelcomeScreen.route;
      case OnboardingStep.disclaimer:
        return OnboardingDisclaimerScreen.route;
      case OnboardingStep.legal:
        return OnboardingLegalScreen.route;
      case OnboardingStep.safetyProfile:
        return SafetyProfileScreen.onboardingRoute;
      // case OnboardingStep.location:
      //   return OnboardingLocationScreen.route;
      // case OnboardingStep.radius:
      //   return OnboardingRadiusScreen.route;
      // case OnboardingStep.pushNotification:
      //   return OnboardingAlertSourcesScreen.route;
      case OnboardingStep.completed:
        return OnboardingCompleteScreen.route;
    }
  }

  /// Returns the previous onboarding step.
  OnboardingStep get previousStep {
    return OnboardingStep.values[(index - 1).clamp(
      0,
      OnboardingStep.values.length - 1,
    )];
  }

  /// Returns the next onboarding step.
  OnboardingStep get nextStep {
    return OnboardingStep.values[(index + 1).clamp(
      0,
      OnboardingStep.values.length - 1,
    )];
  }
}
