import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Sends the nearby-alert glance (the same JSON the home-screen widget draws
/// from) to a paired smartwatch: Wear OS over the Wearable Data Layer, Apple
/// Watch over WatchConnectivity. Read-only. The watch shows it and can only
/// ask the phone to open the app; nothing on a watch sends an SOS or a
/// message, and no location is sent (the payload carries only what the widget
/// already shows).
class WatchSync {
  const WatchSync._();

  static const _channel = MethodChannel('com.safetyalrt.alrt/watch');

  /// Best effort. A phone with no watch paired, or a platform without the
  /// native half, returns false and the app carries on.
  static Future<bool> push(final String payloadJson) async {
    try {
      final sent = await _channel.invokeMethod<bool>(
        'push',
        <String, dynamic>{'payload': payloadJson},
      );
      return sent ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      debugPrint('WatchSync.push failed: $e');
      return false;
    }
  }
}
