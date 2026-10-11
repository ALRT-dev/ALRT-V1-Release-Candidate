import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/providers/service_providers.dart';
import 'package:hazard_app/features/map/services/location_service.dart';
import 'package:hazard_app/features/notification/models/push_notification_settings_model.dart';
import 'package:hazard_app/features/onboarding/enums/push_notification_preference_types.dart';
import 'package:hazard_app/features/onboarding/providers/service_providers.dart';
import 'package:hazard_app/features/onboarding/providers/states/onboarding_provider_state.dart';
import 'package:hazard_app/features/onboarding/services/onboarding_service.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart'
    show providerOfUserService;
import 'package:hazard_app/features/shared/services/user_service.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

final providerOfOnboarding =
    StateNotifierProvider.autoDispose<
      OnboardingProvider,
      OnboardingProviderState
    >(
      (ref) => OnboardingProvider(
        ref: ref,
        initialState: OnboardingProviderState(),
      ),
    );

class OnboardingProvider extends StateNotifier<OnboardingProviderState> {
  OnboardingProvider({
    required final Ref ref,
    required final OnboardingProviderState initialState,
  }) : _ref = ref,
       super(initialState);

  final Ref _ref;
  LocationService get _locationService => _ref.read(providerOfLocationService);
  OnboardingService get _onboardingService =>
      _ref.read(providerOfOnboardingService);
  UserService get _userService => _ref.read(providerOfUserService);

  /// Accepts the disclaimer during onboarding.
  Future<Either<void, AppError>> acceptOnboardingDisclaimer() async {
    state = state.copyWith(
      continueOnboarding: const ContinueOnboarding.loading(),
    );

    final result = await _onboardingService.acceptOnboardingDisclaimer();

    if (mounted) {
      result.when(
        (onboardingResponse) {
          state = state.copyWith(
            continueOnboarding: ContinueOnboarding.success(),
          );
        },
        (error) {
          state = state.copyWith(
            continueOnboarding: ContinueOnboarding.error(error),
          );
        },
      );
    }

    return result;
  }

  /// Accepts the terms of service during onboarding.
  Future<Either<void, AppError>> acceptOnboardingTermsOfService() async {
    state = state.copyWith(
      continueOnboarding: const ContinueOnboarding.loading(),
    );

    final result = await _onboardingService.acceptOnboardingTermsOfService();

    if (mounted) {
      result.when(
        (onboardingResponse) {
          state = state.copyWith(
            continueOnboarding: ContinueOnboarding.success(),
          );
        },
        (error) {
          state = state.copyWith(
            continueOnboarding: ContinueOnboarding.error(error),
          );
        },
      );
    }

    return result;
  }

  /// Opens the device's location settings.
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Sets the user's location during onboarding.
  Future<Either<void, AppError>> setOnboardingLocation({
    required final AlrtLocation location,
  }) async {
    state = state.copyWith(
      continueOnboarding: const ContinueOnboarding.loading(),
    );

    final latitude = location.latitude;
    final longitude = location.longitude;
    final address = location.address;

    final result = await _onboardingService.setOnboardingLocation(
      latitude: latitude,
      longitude: longitude,
      locationName: address,
    );

    if (mounted) {
      result.when(
        (onboardingResponse) {
          state = state.copyWith(
            continueOnboarding: ContinueOnboarding.success(),
          );
        },
        (error) {
          state = state.copyWith(
            continueOnboarding: ContinueOnboarding.error(error),
          );
        },
      );
    }

    return result;
  }

  /// Sets the user's notification radius during onboarding.
  Future<Either<void, AppError>> setOnboardingRadius() async {
    if (state.selectedRadius == null) {
      return Failure(AppError(message: 'No radius selected'));
    }

    state = state.copyWith(
      continueOnboarding: const ContinueOnboarding.loading(),
    );

    final result = await _onboardingService.setOnboardingRadius(
      radiusInKm: state.selectedRadius!.toDouble(),
    );

    if (mounted) {
      result.when(
        (onboardingResponse) {
          state = state.copyWith(
            continueOnboarding: ContinueOnboarding.success(),
          );
        },
        (error) {
          state = state.copyWith(
            continueOnboarding: ContinueOnboarding.error(error),
          );
        },
      );
    }

    return result;
  }

  /// Sets the user's notification preferences during onboarding.
  ///
  /// The backend's onboarding endpoint only knows `all`, `official` and
  /// `userReported`. "Keep it quiet" ([PushNotificationPreference.quiet])
  /// is therefore recorded as `official` (so the onboarding step itself is
  /// stored), then narrowed with a second call to the push-notification
  /// settings endpoint so only the most serious official warnings
  /// (AWS Emergency) stay on. If that second call fails the onboarding
  /// step is still complete: the result is a success so the flow can
  /// continue, and [quietNarrowingError] carries the error for the screen
  /// to show as a toast.
  Future<Either<void, AppError>> setOnboardingNotificationPreferences() async {
    final selected = state.selectedNotificationPreference;
    if (selected == null) {
      return Failure(
        AppError(message: 'No notification preference selected'),
      );
    }

    state = state.copyWith(
      continueOnboarding: const ContinueOnboarding.loading(),
    );
    quietNarrowingError = null;

    final isQuiet = selected == PushNotificationPreference.quiet;
    final result = await _onboardingService
        .setOnboardingNotificationPreferences(
          pushNotificationPreference: isQuiet
              ? PushNotificationPreference.official
              : selected,
        );

    if (isQuiet && result.isSuccess) {
      await _narrowToMostSeriousOfficialWarnings();
    }

    if (mounted) {
      result.when(
        (onboardingResponse) {
          state = state.copyWith(
            continueOnboarding: ContinueOnboarding.success(),
          );
        },
        (error) {
          state = state.copyWith(
            continueOnboarding: ContinueOnboarding.error(error),
          );
        },
      );
    }

    return result;
  }

  /// The error from the "Keep it quiet" settings narrowing, when that
  /// second call failed after the onboarding step itself was recorded.
  /// Read by the alert-level screen right after
  /// [setOnboardingNotificationPreferences] returns; null when all is well.
  AppError? quietNarrowingError;

  /// Keeps only AWS Emergency pushes on, turning off Watch and Act, Advice,
  /// other official sources and community reports. The onboarding call
  /// just before this subscribed every main category on the server, so
  /// those are read back and kept rather than wiped.
  Future<void> _narrowToMostSeriousOfficialWarnings() async {
    final current = await _userService.getPushNotificationSettings();
    if (!mounted) return;

    final categoryIds = current.when(
      (settings) => settings.subscribedCategoryIds,
      (error) => <String>{},
    );

    final update = await _userService.updatePushNotificationSettings(
      pushNotificationSettings: PushNotificationSettings(
        awsEmergency: true,
        awsWatchAndAct: false,
        awsAdvice: false,
        officialNonAws: false,
        userReported: false,
        subscribedCategoryIds: categoryIds,
      ),
    );
    if (!mounted) return;

    update.when(
      (_) => quietNarrowingError = null,
      (error) => quietNarrowingError = error,
    );
  }

  /// Updates [OnboardingProviderState.selectedRadius] with the given [radius].
  void updateSelectedRadius(final int radius) {
    state = state.copyWith(selectedRadius: radius);
  }

  /// Updates [OnboardingProviderState.selectedNotificationPreference] with the given [preference].
  void updateSelectedNotificationPreference(
    final PushNotificationPreference preference,
  ) {
    state = state.copyWith(selectedNotificationPreference: preference);
  }
}
