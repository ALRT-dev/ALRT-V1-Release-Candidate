import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';

/// Extension for navigation-related functionality
extension NavigationExtension on AlrtLocation {
  /// Checks if this location is close to another location within a threshold
  bool isCloseTo(AlrtLocation other, {double thresholdMeters = 20.0}) {
    final distance = calculateDistanceInMeters(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
    return distance <= thresholdMeters;
  }

  /// Converts to LatLng for Google Maps
  LatLng get latLng => LatLng(latitude, longitude);
}

/// Extension for polyline navigation patterns
extension PolylineNavigationExtension on Polyline {
  /// Creates a copy of the polyline with off-route styling
  Polyline asOffRoute() {
    return copyWith(
      colorParam: const Color(0xFFFF5722), // Red-orange color
      patternsParam: [
        PatternItem.dash(20),
        PatternItem.gap(10),
      ],
      widthParam: 6,
    );
  }

  /// Creates a copy of the polyline as a passed route segment
  Polyline asPassedRoute() {
    return copyWith(
      colorParam: const Color(0xFF9E9E9E).withValues(alpha: 0.6), // Gray
      widthParam: 4,
    );
  }

  /// Creates a copy of the polyline as an active upcoming route
  Polyline asActiveRoute() {
    return copyWith(
      colorParam: const Color(0xFF2196F3), // Blue
      widthParam: 8,
      patternsParam: [], // Clear any patterns
    );
  }
}
