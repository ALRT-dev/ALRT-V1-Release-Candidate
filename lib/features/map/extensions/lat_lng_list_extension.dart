import 'package:google_maps_flutter/google_maps_flutter.dart';

extension LatLngListExtension on List<LatLng> {
  /// Converts a list of [LatLng] to a [LatLngBounds] that encompasses all points.
  /// Throws an [ArgumentError] if the list is empty.
  LatLngBounds toBounds() {
    if (isEmpty) {
      throw ArgumentError('Cannot create bounds from an empty list');
    }

    double minLat = first.latitude;
    double maxLat = first.latitude;
    double minLng = first.longitude;
    double maxLng = first.longitude;

    for (final latLng in this) {
      if (latLng.latitude < minLat) minLat = latLng.latitude;
      if (latLng.latitude > maxLat) maxLat = latLng.latitude;
      if (latLng.longitude < minLng) minLng = latLng.longitude;
      if (latLng.longitude > maxLng) maxLng = latLng.longitude;
    }

    // Handle case where all points are identical (prevent map crash)
    if (minLat == maxLat && minLng == maxLng) {
      const delta = 0.0005;
      minLat -= delta;
      maxLat += delta;
      minLng -= delta;
      maxLng += delta;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
