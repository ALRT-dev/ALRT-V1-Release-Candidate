import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_notification_settings_model.freezed.dart';
part 'push_notification_settings_model.g.dart';

@freezed
abstract class PushNotificationSettings with _$PushNotificationSettings {
  const PushNotificationSettings._();

  const factory PushNotificationSettings({
    /// Whether AWS Emergency level "Emergency" is selected.
    @Default(false) final bool awsEmergency,

    /// Whether AWS Emergency level "Watch and Act" is selected.
    @Default(false) final bool awsWatchAndAct,

    /// Whether AWS Emergency level "Advice" is selected.
    @Default(false) final bool awsAdvice,

    /// Whether Official Non-AWS sources are selected.
    @Default(false) final bool officialNonAws,

    /// Whether User Reported sources are selected.
    @Default(false) final bool userReported,

    /// The IDs of the categories the user is subscribed to.
    @Default(<String>{}) final Set<String> subscribedCategoryIds,
  }) = _PushNotificationSettings;

  factory PushNotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationSettingsFromJson(json);
}
