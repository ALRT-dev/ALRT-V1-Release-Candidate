import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';

extension PolylineExtension on List<LatLng> {
  /// Finds the midpoint of a polyline by calculating the total distance
  /// and finding the point that's approximately halfway along the route.
  LatLng? findMidpoint() {
    if (isEmpty) return null;
    if (length == 1) return first;
    if (length == 2) {
      return LatLng(
        (first.latitude + last.latitude) / 2,
        (first.longitude + last.longitude) / 2,
      );
    }

    // Calculate total distance along the polyline
    double totalDistance = 0;
    final List<double> segmentDistances = [];

    for (int i = 0; i < length - 1; i++) {
      final distance = calculateDistanceInMeters(
        this[i].latitude,
        this[i].longitude,
        this[i + 1].latitude,
        this[i + 1].longitude,
      );
      segmentDistances.add(distance);
      totalDistance += distance;
    }

    // Find the midpoint distance
    final halfDistance = totalDistance / 2;

    // Walk along the polyline until we reach the midpoint
    double accumulatedDistance = 0;
    for (int i = 0; i < segmentDistances.length; i++) {
      final nextDistance = accumulatedDistance + segmentDistances[i];

      if (nextDistance >= halfDistance) {
        // The midpoint is somewhere along this segment
        final remainingDistance = halfDistance - accumulatedDistance;
        final segmentProgress = remainingDistance / segmentDistances[i];

        // Interpolate between the two points
        final start = this[i];
        final end = this[i + 1];

        return LatLng(
          start.latitude + (end.latitude - start.latitude) * segmentProgress,
          start.longitude + (end.longitude - start.longitude) * segmentProgress,
        );
      }

      accumulatedDistance = nextDistance;
    }

    // Fallback to the last point if something goes wrong
    return last;
  }
}
