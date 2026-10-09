import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The ISO country of the SIM in the phone.
///
/// This is the top tier of the emergency-number resolution (§16): someone
/// who flies to Spain with an Australian phone should be offered 112, not
/// 000, and the SIM is the only signal that changes when they land. Device
/// region and locale follow the owner, not the ground they are standing on.
///
/// Deliberately a channel of our own rather than a plugin: it is one string
/// from one system API on each platform, and an unmaintained dependency in
/// the path of an emergency call is not worth the saving.
///
/// Android reads TelephonyManager.getSimCountryIso, which needs no
/// permission. iOS has no usable equivalent any more: CTCarrier and its
/// isoCountryCode were deprecated in iOS 16 and return a placeholder, so
/// iOS returns null and resolution falls through to device region, which
/// is the behaviour that was already shipping.
abstract final class SimCountry {
  static const _channel = MethodChannel('com.safetyalrt.alrt/sim');

  /// Cached because it cannot change while the app is running without a
  /// SIM swap, and the emergency number is read on screens that must not
  /// wait on a platform call.
  static String? _cached;
  static bool _hasLoaded = false;

  /// The last value [load] read, or null if it has not run or found none.
  static String? get value => _cached;

  static bool get hasLoaded => _hasLoaded;

  /// Reads the SIM country once, at startup. Never throws: any failure
  /// leaves the value null and the resolution falls through to device
  /// region, so an emergency number is always offered.
  static Future<String?> load() async {
    if (_hasLoaded) return _cached;
    try {
      final iso = await _channel.invokeMethod<String>('getSimCountryIso');
      final trimmed = iso?.trim();
      _cached = (trimmed == null || trimmed.isEmpty)
          ? null
          : trimmed.toUpperCase();
    } catch (e) {
      // MissingPluginException on iOS and anything the platform throws.
      debugPrint('SimCountry.load: $e');
      _cached = null;
    }
    _hasLoaded = true;
    return _cached;
  }

  /// Test seam.
  @visibleForTesting
  static void debugSet(final String? iso, {final bool hasLoaded = true}) {
    _cached = iso;
    _hasLoaded = hasLoaded;
  }
}
