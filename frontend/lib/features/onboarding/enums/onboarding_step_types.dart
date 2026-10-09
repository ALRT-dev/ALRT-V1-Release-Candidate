import 'package:hazard_app/features/onboarding/views/onboarding_alrt_plus_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_alert_level_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_complete_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_things_to_know_screen.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_welcome_screen.dart';

enum OnboardingStep {
  welcome,
  thingsToKnow,
  alertLevel,
  alrtPlus,
  completed;

  /// Returns the route associated with the onboarding step.
  String get route {
    switch (this) {
      case OnboardingStep.welcome:
        return OnboardingWelcomeScreen.route;
      case OnboardingStep.thingsToKnow:
        return OnboardingThingsToKnowScreen.route;
      case OnboardingStep.alertLevel:
        return OnboardingAlertLevelScreen.route;
      case OnboardingStep.alrtPlus:
        return OnboardingAlrtPlusScreen.route;
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
