import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/onboarding/enums/push_notification_preference_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

abstract class OnboardingRepository {
  Future<Either<void, AppError>> acceptOnboardingDisclaimer();

  Future<Either<void, AppError>> acceptOnboardingTermsOfService();

  Future<Either<void, AppError>> setOnboardingLocation({
    required final double latitude,
    required final double longitude,
    final String? locationName,
  });

  Future<Either<void, AppError>> setOnboardingRadius({
    required final double radiusInKm,
  });

  Future<Either<void, AppError>> setOnboardingNotificationPreferences({
    required final PushNotificationPreference pushNotificationPreference,
  });
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    required RestClient restClient,
  }) : _restClient = restClient;

  final RestClient _restClient;

  @override
  Future<Either<void, AppError>> acceptOnboardingDisclaimer() {
    return runAsyncCall(
      name: 'acceptOnboardingDisclaimer',
      future: () async {
        final result = await _restClient.acceptOnboardingDisclaimer();
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> acceptOnboardingTermsOfService() {
    return runAsyncCall(
      name: 'acceptOnboardingTermsOfService',
      future: () async {
        final result = await _restClient.acceptOnboardingTermsOfService();
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> setOnboardingLocation({
    required double latitude,
    required double longitude,
    String? locationName,
  }) {
    return runAsyncCall(
      name: 'setOnboardingLocation',
      future: () async {
        final result = await _restClient.setOnboardingLocation(
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> setOnboardingRadius({
    required double radiusInKm,
  }) {
    return runAsyncCall(
      name: 'setOnboardingRadius',
      future: () async {
        final result = await _restClient.setOnboardingRadius(
          radiusInKm: radiusInKm,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> setOnboardingNotificationPreferences({
    required PushNotificationPreference pushNotificationPreference,
  }) {
    return runAsyncCall(
      name: 'setOnboardingNotificationPreferences',
      future: () async {
        final result = await _restClient.setOnboardingNotificationPreferences(
          pushNotificationPreference: pushNotificationPreference.name,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }
}
