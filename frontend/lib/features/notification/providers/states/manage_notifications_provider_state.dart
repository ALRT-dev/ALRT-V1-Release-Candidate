import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/notification/models/push_notification_settings_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';

part 'manage_notifications_provider_state.freezed.dart';

@freezed
abstract class ManageNotificationsProviderState
    with _$ManageNotificationsProviderState {
  const factory ManageNotificationsProviderState({
    /// The push notification settings of the user.
    @Default(PushNotificationSettings())
    final PushNotificationSettings pushNotificationSettings,

    /// The state of getting push notification settings.
    @Default(GetPushNotificationSettingsState.initial())
    final GetPushNotificationSettingsState getPushNotificationSettingsState,

    /// The state of updating push notification settings.
    @Default(UpdatePushNotificationSettingsState.initial())
    final UpdatePushNotificationSettingsState
    updatePushNotificationSettingsState,
  }) = _ManageNotificationsProviderState;
}

@freezed
class GetPushNotificationSettingsState with _$GetPushNotificationSettingsState {
  const factory GetPushNotificationSettingsState.initial() =
      _GetPushNotificationSettingsStateInitial;
  const factory GetPushNotificationSettingsState.loading() =
      _GetPushNotificationSettingsStateLoading;
  const factory GetPushNotificationSettingsState.success(
    final PushNotificationSettings pushNotificationSettings,
  ) = _GetPushNotificationSettingsStateSuccess;
  const factory GetPushNotificationSettingsState.error(
    final AppError error,
  ) = _GetPushNotificationSettingsStateError;
}

@freezed
class UpdatePushNotificationSettingsState
    with _$UpdatePushNotificationSettingsState {
  const factory UpdatePushNotificationSettingsState.initial() =
      _UpdatePushNotificationSettingsStateInitial;
  const factory UpdatePushNotificationSettingsState.loading() =
      _UpdatePushNotificationSettingsStateLoading;
  const factory UpdatePushNotificationSettingsState.success() =
      _UpdatePushNotificationSettingsStateSuccess;
  const factory UpdatePushNotificationSettingsState.error(
    final AppError error,
  ) = _UpdatePushNotificationSettingsStateError;
}

@freezed
class GetLocationSubscriptionsState with _$GetLocationSubscriptionsState {
  const factory GetLocationSubscriptionsState.initial() =
      _GetLocationSubscriptionsStateInitial;
  const factory GetLocationSubscriptionsState.loading() =
      _GetLocationSubscriptionsStateLoading;
  const factory GetLocationSubscriptionsState.success(
    final List<LocationSubscription> locationSubscriptions,
  ) = _GetLocationSubscriptionsStateSuccess;
  const factory GetLocationSubscriptionsState.error(
    final AppError error,
  ) = _GetLocationSubscriptionsStateError;
}
