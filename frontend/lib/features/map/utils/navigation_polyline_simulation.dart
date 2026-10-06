import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';

/// Moves [from] by [northMeters] / [eastMeters] using a spherical Earth model.
LatLng offsetByNorthEastMeters(
  LatLng from,
  double northMeters,
  double eastMeters,
) {
  const earthRadius = 6378137.0;
  final latRad = from.latitude * math.pi / 180;
  final dLat = northMeters / earthRadius * (180 / math.pi);
  final dLng = eastMeters / (earthRadius * math.cos(latRad)) * (180 / math.pi);
  return LatLng(from.latitude + dLat, from.longitude + dLng);
}

/// Advances [from] by [meters] along [polyline] toward the path end.
///
/// Projects [from] onto the nearest segment, walks forward along vertices,
/// and returns the interpolated position. If [meters] reaches past the end,
/// returns the last point of [polyline].
///
/// Returns `null` if [polyline] has fewer than two distinct points.
LatLng? advanceAlongPolylineTowardsEnd({
  required List<LatLng> polyline,
  required LatLng from,
  required double meters,
}) {
  if (polyline.length < 2) return null;

  final projected = _projectOntoPolyline(polyline, from);
  if (projected == null) return null;

  var remaining = meters;
  var segmentIndex = projected.segmentIndex;
  LatLng current = projected.closestPoint;

  while (remaining > 0 && segmentIndex < polyline.length - 1) {
    final segmentEnd = polyline[segmentIndex + 1];
    final legLength = calculateDistanceInMeters(
      current.latitude,
      current.longitude,
      segmentEnd.latitude,
      segmentEnd.longitude,
    );

    if (legLength <= 1e-6) {
      segmentIndex++;
      current = segmentEnd;
      continue;
    }

    if (remaining <= legLength) {
      final fraction = remaining / legLength;
      return LatLng(
        current.latitude +
            fraction * (segmentEnd.latitude - current.latitude),
        current.longitude +
            fraction * (segmentEnd.longitude - current.longitude),
      );
    }

    remaining -= legLength;
    segmentIndex++;
    current = segmentEnd;
  }

  return polyline.last;
}

class _PolylineProjection {
  const _PolylineProjection({
    required this.segmentIndex,
    required this.closestPoint,
  });

  final int segmentIndex;
  final LatLng closestPoint;
}

_PolylineProjection? _projectOntoPolyline(
  List<LatLng> polyline,
  LatLng point,
) {
  var bestDist = double.infinity;
  _PolylineProjection? best;

  for (var i = 0; i < polyline.length - 1; i++) {
    final a = polyline[i];
    final b = polyline[i + 1];
    final closest = _closestPointOnSegment(point, a, b);
    final d = calculateDistanceInMeters(
      point.latitude,
      point.longitude,
      closest.latitude,
      closest.longitude,
    );
    if (d < bestDist) {
      bestDist = d;
      best = _PolylineProjection(segmentIndex: i, closestPoint: closest);
    }
  }
  return best;
}

/// Closest point on segment AB to P (in lat/lng space, linear interpolation).
LatLng _closestPointOnSegment(LatLng p, LatLng a, LatLng b) {
  final ax = a.longitude;
  final ay = a.latitude;
  final bx = b.longitude;
  final by = b.latitude;
  final px = p.longitude;
  final py = p.latitude;

  final abx = bx - ax;
  final aby = by - ay;
  final apx = px - ax;
  final apy = py - ay;

  final abLenSq = abx * abx + aby * aby;
  if (abLenSq < 1e-18) return a;

  var t = (apx * abx + apy * aby) / abLenSq;
  t = math.max(0.0, math.min(1.0, t));

  return LatLng(ay + t * aby, ax + t * abx);
}
