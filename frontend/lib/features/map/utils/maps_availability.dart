import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Whether Google Maps can be shown on this device.
///
/// On iOS the Maps SDK must be given an API key (AppDelegate reads it from
/// the GMSApiKey Info.plist entry) before any map view is created; creating
/// one without a key throws a native exception and the app closes. A build
/// made without the key (for example a TEST build whose Maps secret is not
/// set) therefore asks AppDelegate once at start-up and every map in the app
/// shows [MapUnavailable] instead. Android shows a blank map without a key
/// rather than crashing, so it is always treated as available.
class MapsAvailability {
  MapsAvailability._();

  static const _channel = MethodChannel('com.safetyalrt.alrt/maps');

  static bool _available = true;

  static bool get available => _available;

  static Future<void> initialize() async {
    if (kIsWeb || !Platform.isIOS) return;
    try {
      _available = await _channel.invokeMethod<bool>('isConfigured') ?? false;
    } catch (error) {
      // Without a definite yes, never risk creating a map view.
      debugPrint('MapsAvailability: $error');
      _available = false;
    }
  }
}

/// Shown in place of a map when [MapsAvailability.available] is false.
class MapUnavailable extends StatelessWidget {
  const MapUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE9EAEE),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.map_outlined, size: 40, color: Color(0xFF6B6F7B)),
              SizedBox(height: 12),
              Text(
                'Map unavailable on this build',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF23252B),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Alerts, Family and Ask ALRT still work.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B6F7B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
