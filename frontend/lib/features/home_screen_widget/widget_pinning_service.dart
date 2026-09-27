import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The two pinnable home-screen widgets.
enum PinnableWidget {
  alerts('alerts'),
  family('family');

  const PinnableWidget(this.channelValue);

  final String channelValue;
}

/// Asks the Android launcher to pin one of our home-screen widgets
/// (the same dialog the app-icon long-press shortcuts trigger).
///
/// iOS has no pin API — callers show the manual instructions sheet instead.
class WidgetPinningService {
  const WidgetPinningService._();

  static const _channel = MethodChannel('com.safetyalrt.alrt/widget_pinning');

  /// Whether the launcher supports the pin-widget dialog (Android 8+ and a
  /// supporting launcher). Always false on iOS/web.
  static Future<bool> isPinSupported() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isPinSupported') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Shows the launcher's pin dialog for [widget]. Returns whether the
  /// dialog was shown (not whether the user confirmed).
  static Future<bool> requestPin(final PinnableWidget widget) async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>(
            'requestPinWidget',
            {'widget': widget.channelValue},
          ) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
