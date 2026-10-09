import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hazard_app/features/notification/enums/push_notification_types.dart';

extension RemoteMessageExt on RemoteMessage {
  /// Returns the type of the push notification from the [data].
  PushNotificationType get type {
    return PushNotificationType.values.firstWhere(
      (element) => data['notificationType'] == element.name,
      orElse: () => PushNotificationType.unknown,
    );
  }

  /// Returns the payload of the push notification from the [data].
  Map<String, dynamic> get payload {
    final payloadString = data['payload'];
    if (payloadString == null || payloadString.isEmpty) {
      return {};
    }
    try {
      return jsonDecode(payloadString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
}
