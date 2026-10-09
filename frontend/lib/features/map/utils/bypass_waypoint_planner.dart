import 'dart:math' as math;

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/models/hazard_corridor_model.dart';
import 'package:hazard_app/features/map/utils/navigation_polyline_simulation.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';

/// Side of the active route a bypass waypoint should sit on, relative to
/// the entry → exit travel direction across the [HazardCorridor].
enum BypassSide { left, right }

/// Builds the `intermediates` list passed to the Routes API so the
/// returned route is forced to detour around [corridor].
///
/// A single waypoint is placed perpendicular to the corridor's travel
/// direction (entry → exit), [offsetMeters] off the corridor's
/// [HazardCorridor.centerPoint] on the chosen [side]. The waypoint is
/// emitted as `stopOver: false` so the routing engine treats it as a
/// pass-through hint rather than a stop.
List<PolylineWayPoint> planBypassWaypoints({
  required final HazardCorridor corridor,
  required final double offsetMeters,
  required final BypassSide side,
}) {
  final waypointLatLng = _offsetLatLngPerpendicular(
    anchor: corridor.centerPoint,
    fromPoint: corridor.entryPoint,
    toPoint: corridor.exitPoint,
    offsetMeters: offsetMeters,
    side: side,
  );

  return <PolylineWayPoint>[
    PolylineWayPoint(
      location: '${waypointLatLng.latitude},${waypointLatLng.longitude}',
      stopOver: false,
    ),
  ];
}

/// Returns `true` if any segment of [candidatePolyline] passes within
/// `corridor.bufferMeters` of any [HazardCorridor] in [corridors].
///
/// Used to reject Routes API responses that still cut through a forbidden
/// corridor even after waypoints were supplied.
bool polylineCrossesCorridors({
  required final List<LatLng> candidatePolyline,
  required final List<HazardCorridor> corridors,
}) {
  if (candidatePolyline.length < 2 || corridors.isEmpty) return false;

  for (final corridor in corridors) {
    final anchors = <LatLng>{
      corridor.centerPoint,
      corridor.entryPoint,
      corridor.exitPoint,
      for (final h in corridor.hazards)
        if (h.latitude != null && h.longitude != null)
          LatLng(h.latitude!, h.longitude!),
    };

    for (var i = 0; i < candidatePolyline.length - 1; i++) {
      final segStart = candidatePolyline[i];
      final segEnd = candidatePolyline[i + 1];
      for (final anchor in anchors) {
        final d = _distanceFromPointToSegmentMeters(
          point: anchor,
          segmentStart: segStart,
          segmentEnd: segEnd,
        );
        if (d <= corridor.bufferMeters) return true;
      }
    }
  }
  return false;
}

/// Offsets [anchor] perpendicular to the bearing `fromPoint → toPoint` by
/// [offsetMeters] on the requested [side]. Reuses [offsetByNorthEastMeters]
/// (spherical Earth model) by decomposing the offset into north/east
/// components.
LatLng _offsetLatLngPerpendicular({
  required final LatLng anchor,
  required final LatLng fromPoint,
  required final LatLng toPoint,
  required final double offsetMeters,
  required final BypassSide side,
}) {
  final bearingRad = _bearingRadians(fromPoint, toPoint);

  // Perpendicular bearing: rotate by ±90° depending on side.
  // Right side = travel direction + 90° (clockwise), left side = -90°.
  final perpendicularRad =
      bearingRad + (side == BypassSide.right ? math.pi / 2 : -math.pi / 2);

  final northMeters = offsetMeters * math.cos(perpendicularRad);
  final eastMeters = offsetMeters * math.sin(perpendicularRad);

  return offsetByNorthEastMeters(anchor, northMeters, eastMeters);
}

double _bearingRadians(final LatLng from, final LatLng to) {
  final lat1 = from.latitude * math.pi / 180.0;
  final lat2 = to.latitude * math.pi / 180.0;
  final deltaLng = (to.longitude - from.longitude) * math.pi / 180.0;

  final y = math.sin(deltaLng) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);
  return math.atan2(y, x);
}

double _distanceFromPointToSegmentMeters({
  required final LatLng point,
  required final LatLng segmentStart,
  required final LatLng segmentEnd,
}) {
  final A = point.latitude - segmentStart.latitude;
  final B = point.longitude - segmentStart.longitude;
  final C = segmentEnd.latitude - segmentStart.latitude;
  final D = segmentEnd.longitude - segmentStart.longitude;

  final dot = A * C + B * D;
  final lenSq = C * C + D * D;

  if (lenSq == 0) {
    return calculateDistanceInMeters(
      point.latitude,
      point.longitude,
      segmentStart.latitude,
      segmentStart.longitude,
    );
  }

  final param = (dot / lenSq).clamp(0.0, 1.0);
  final closest = LatLng(
    segmentStart.latitude + param * C,
    segmentStart.longitude + param * D,
  );
  return calculateDistanceInMeters(
    point.latitude,
    point.longitude,
    closest.latitude,
    closest.longitude,
  );
}
