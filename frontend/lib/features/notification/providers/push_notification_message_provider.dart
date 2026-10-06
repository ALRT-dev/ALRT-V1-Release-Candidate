import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/notification/providers/service_providers.dart';
import 'package:hazard_app/features/notification/providers/states/push_notification_message_provider_state.dart';
import 'package:hazard_app/features/notification/services/notification_service.dart';

final providerOfPushNotificationMessage =
    StateNotifierProvider.autoDispose<
      PushNotificationMessageProvider,
      PushNotificationMessageProviderState
    >(
      (ref) => PushNotificationMessageProvider(
        ref: ref,
        state: PushNotificationMessageProviderState(),
      ),
    );

class PushNotificationMessageProvider
    extends StateNotifier<PushNotificationMessageProviderState> {
  PushNotificationMessageProvider({
    required final Ref ref,
    required final PushNotificationMessageProviderState state,
  }) : _ref = ref,
       super(state) {
    _handleNotificationMessage();
  }

  final Ref _ref;
  NotificationService get _notificationService =>
      _ref.read(providerOfNotificationService);

  /// Listens to the received push notification message and updates the state.
  Future<void> _handleNotificationMessage() async {
    _notificationService.handlePushNotificationMessage(
      onMessageReceived: updateReceivedPushNotifMessage,
    );
    _ref.onDispose(
      () => _notificationService.disposePushNotificationMessageListener(),
    );
  }

  /// Updates [PushNotificationMessageProviderState.receivedPushNotifMessage] with [receivedPushNotifMessage].
  void updateReceivedPushNotifMessage(
    final RemoteMessage receivedPushNotifMessage,
  ) {
    state = state.copyWith(
      receivedPushNotifMessage: receivedPushNotifMessage,
    );
  }
}
