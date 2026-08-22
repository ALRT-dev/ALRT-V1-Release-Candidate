import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/onboarding/enums/push_notification_preference_types.dart';
import 'package:hazard_app/features/onboarding/providers/repository_providers.dart';
import 'package:hazard_app/features/onboarding/repositories/onboarding_repository.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

class OnboardingService {
  const OnboardingService(final Ref ref) : _ref = ref;

  final Ref _ref;

  OnboardingRepository get _onboardingRepository =>
      _ref.read(providerOfOnboardingRepository);

  /// Accepts the disclaimer during onboarding.
  Future<Either<void, AppError>> acceptOnboardingDisclaimer() {
    return _onboardingRepository.acceptOnboardingDisclaimer();
  }

  /// Accepts the terms of service during onboarding.
  Future<Either<void, AppError>> acceptOnboardingTermsOfService() {
    return _onboardingRepository.acceptOnboardingTermsOfService();
  }

  /// Sets the user's location during onboarding.
  Future<Either<void, AppError>> setOnboardingLocation({
    required double latitude,
    required double longitude,
    String? locationName,
  }) {
    return _onboardingRepository.setOnboardingLocation(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
  }

  /// Sets the user's notification radius during onboarding.
  Future<Either<void, AppError>> setOnboardingRadius({
    required double radiusInKm,
  }) {
    return _onboardingRepository.setOnboardingRadius(
      radiusInKm: radiusInKm,
    );
  }

  /// Sets the user's notification preferences during onboarding.
  Future<Either<void, AppError>> setOnboardingNotificationPreferences({
    required PushNotificationPreference pushNotificationPreference,
  }) {
    return _onboardingRepository.setOnboardingNotificationPreferences(
      pushNotificationPreference: pushNotificationPreference,
    );
  }
}
