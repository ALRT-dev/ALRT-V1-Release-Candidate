import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/onboarding/repositories/onboarding_repository.dart';
import 'package:hazard_app/features/shared/providers/rest_client_provider.dart';

/// Provides [OnboardingRepository].
final providerOfOnboardingRepository = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(
    restClient: ref.watch(providerOfRestClient),
  );
});
