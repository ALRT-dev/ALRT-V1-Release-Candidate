import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/onboarding/enums/push_notification_preference_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

part 'onboarding_provider_state.freezed.dart';

@freezed
abstract class OnboardingProviderState with _$OnboardingProviderState {
  const factory OnboardingProviderState({
    /// The selected notification radius during onboarding.
    final int? selectedRadius,

    /// The selected notification preference during onboarding.
    final PushNotificationPreference? selectedNotificationPreference,

    /// The state of continuing the onboarding process.
    @Default(ContinueOnboarding.initial())
    final ContinueOnboarding continueOnboarding,
  }) = _OnboardingProviderState;
}

@freezed
class ContinueOnboarding with _$ContinueOnboarding {
  const factory ContinueOnboarding.initial() = _ContinueOnboardingInitial;
  const factory ContinueOnboarding.loading() = _ContinueOnboardingLoading;
  const factory ContinueOnboarding.success() = _ContinueOnboardingSuccess;
  const factory ContinueOnboarding.error(
    final AppError error,
  ) = _ContinueOnboardingError;
}
