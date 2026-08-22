import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

part 'home_provider_state.freezed.dart';

/// Why the notification priming screen should be shown.
enum NotificationPrimingKind {
  /// Permission has never been asked — priming precedes the OS prompt.
  firstAsk,

  /// Permission was denied before — priming deep-links to system settings.
  previouslyDenied,
}

@freezed
abstract class HomeProviderState with _$HomeProviderState {
  const factory HomeProviderState({
    /// The state of sending push notification token to the server
    @Default(SendPushNotificationTokenState.initial())
    final SendPushNotificationTokenState sendPushNotificationTokenState,

    /// The state of updating user location
    @Default(UpdateUserLocationState.initial())
    final UpdateUserLocationState updateUserLocationState,

    /// Set when the notification priming screen should be shown (permission
    /// missing and the "maybe later" snooze has lapsed). Null otherwise.
    final NotificationPrimingKind? notificationPrimingRequest,
  }) = _HomeProviderState;
}

@freezed
class SendPushNotificationTokenState with _$SendPushNotificationTokenState {
  const factory SendPushNotificationTokenState.initial() =
      _SendPushNotificationTokenStateInitial;
  const factory SendPushNotificationTokenState.loading() =
      _SendPushNotificationTokenStateLoading;
  const factory SendPushNotificationTokenState.success(
    final String token,
  ) = _SendPushNotificationTokenStateSuccess;
  const factory SendPushNotificationTokenState.error(
    final AppError error,
  ) = _SendPushNotificationTokenStateError;
}

@freezed
class UpdateUserLocationState with _$UpdateUserLocationState {
  const factory UpdateUserLocationState.initial() =
      UpdateUserLocationStateInitial;
  const factory UpdateUserLocationState.loading() =
      UpdateUserLocationStateLoading;
  const factory UpdateUserLocationState.success(
    final AppUser newAppUser,
  ) = UpdateUserLocationStateSuccess;
  const factory UpdateUserLocationState.error(
    final AppError error,
  ) = UpdateUserLocationStateError;
}
