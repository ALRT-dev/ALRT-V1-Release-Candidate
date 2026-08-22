import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_notification_message_provider_state.freezed.dart';

@freezed
abstract class PushNotificationMessageProviderState
    with _$PushNotificationMessageProviderState {
  const factory PushNotificationMessageProviderState({
    /// The message that is received from the push notification.
    final RemoteMessage? receivedPushNotifMessage,
  }) = _PushNotificationMessageProviderState;
}
