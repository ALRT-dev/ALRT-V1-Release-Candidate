import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hazard_app/features/family/services/family_service.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';

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
    final position = await getLastKnownOrCurrentPosition();
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

  /// Returns the last known position, falling back to a fresh (low accuracy)
  /// fix. Returns `null` when the location is unavailable or not permitted.
  Future<Position?> getLastKnownOrCurrentPosition() {
    return runAsyncCall<Position?>(
      name: 'getLastKnownOrCurrentPosition',
      future: () async {
        final hasPermission = await _hasLocationPermission();
        if (!hasPermission) return null;

        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) return lastKnown;

        return Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
      },
      onError: (_) => null,
    );
  }

  /// Returns true when location services are enabled and permission is
  /// granted (requesting it once when it is simply denied).
  Future<bool> _hasLocationPermission() {
    return runAsyncCall<bool>(
      name: 'familyLocationPermissionCheck',
      future: () async {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return false;

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        return permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
      },
      onError: (_) => false,
    );
  }
}
