import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/onboarding/services/onboarding_service.dart';

/// Provides [OnboardingService].
final providerOfOnboardingService = Provider<OnboardingService>((ref) {
  return OnboardingService(ref);
});
