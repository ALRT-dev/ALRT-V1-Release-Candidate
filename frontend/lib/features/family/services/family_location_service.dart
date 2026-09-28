import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/family/services/location_fix.dart';

/// The phone's location API (overridden in tests).
final providerOfDeviceLocationSource = Provider<DeviceLocationSource>(
  (ref) => const GeolocatorLocationSource(),
);

/// Provides [FamilyLocationService].
final providerOfFamilyLocationService = Provider<FamilyLocationService>(
  FamilyLocationService.new,
);

/// One-time location snapshot sharing for Family Mode.
///
/// ALRT never live-tracks. A snapshot is shared only when the member takes a
/// deliberate action — checking in, answering a location request, triggering
/// SOS, or explicitly re-sharing — and it expires on the server after an
/// hour. There is no position stream, no timer, and no background tracking.
class FamilyLocationService {
  FamilyLocationService(final Ref ref) : _ref = ref;

  final Ref _ref;
  FamilyService get _familyService => _ref.read(providerOfFamilyService);

  /// Speeds above this (m/s) are considered "moving".
  static const movingSpeedThresholdMps = 1.0;

  /// Shares a single, expiring location snapshot with the circle.
  ///
  /// Returns true when a snapshot was shared; false when location is
  /// unavailable or not permitted (never crashes).
  Future<bool> shareSnapshotNow() async {
    final position = await getCurrentPositionOrNull();
    if (position == null) {
      log(
        'No location available — snapshot not shared.',
        name: 'FamilyLocationService',
      );
      return false;
    }

    final result = await _familyService.sendFamilyLocationPing(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed,
      isMoving: position.speed > movingSpeedThresholdMps,
    );
    return result.whenSuccess((_) => true) ?? false;
  }

  /// The phone's location, said truthfully: current, last known (with its
  /// age) or unavailable (with the reason). See [resolveLocationFix].
  Future<LocationFix> resolveFix() =>
      resolveLocationFix(_ref.read(providerOfDeviceLocationSource));

  /// A position only when it is CURRENT (fixed in the last two minutes).
  /// Check-ins, answers to "where are you" and journeys send "where you
  /// are now", so an old cached point is never used for them: they go
  /// without a location instead. (The old helper returned any cached
  /// point, however old.)
  Future<Position?> getCurrentPositionOrNull() async {
    final fix = await resolveFix();
    return fix.isCurrent ? fix.position : null;
  }
}
