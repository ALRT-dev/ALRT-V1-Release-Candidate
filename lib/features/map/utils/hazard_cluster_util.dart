import 'dart:math' as math;

import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

/// Below this zoom level hazards are grouped into clusters; at or above it
/// every hazard renders as an individual marker.
const kClusterMaxZoom = 12.5;

/// Screen-space grid cell size used for clustering, in logical pixels.
const kClusterGridPx = 90.0;

/// A group of hazards bucketed into one screen-space grid cell.
class HazardCluster {
  HazardCluster({
    required this.hazards,
    required this.latitude,
    required this.longitude,
  });

  final List<Hazard> hazards;

  /// Centroid of the cluster members.
  final double latitude;
  final double longitude;

  int get count => hazards.length;

  bool get isSingle => hazards.length == 1;

  /// The single hazard when [isSingle].
  Hazard get single => hazards.first;

  /// Highest severity present in the cluster — drives the badge color.
  HazardSeverity get dominantSeverity {
    var dominant = HazardSeverity.unknown;
    for (final hazard in hazards) {
      final severity = hazard.severity ?? HazardSeverity.unknown;
      if (severity.index > dominant.index) dominant = severity;
    }
    return dominant;
  }

  /// Display label, capped for very dense cells.
  String get label => count > 99 ? '99+' : '$count';
}

/// Groups [hazards] into clusters using a screen-space grid sized for the
/// given [zoom]. Hazards without coordinates are skipped.
///
/// The grid cell edge is [kClusterGridPx] logical pixels: at zoom z one map
/// tile (256 px) spans 360 / 2^z degrees of longitude, so a cell spans
/// 360 / 2^z * (gridPx / 256) degrees. Latitude uses the same span, which is
/// visually close enough at the app's operating latitudes.
List<HazardCluster> clusterHazards({
  required final List<Hazard> hazards,
  required final double zoom,
}) {
  final cellDegrees = 360 / math.pow(2, zoom) * (kClusterGridPx / 256);

  final buckets = <String, List<Hazard>>{};
  for (final hazard in hazards) {
    final lat = hazard.latitude;
    final lng = hazard.longitude;
    if (lat == null || lng == null) continue;
    final key =
        '${(lat / cellDegrees).floor()}_${(lng / cellDegrees).floor()}';
    buckets.putIfAbsent(key, () => []).add(hazard);
  }

  return buckets.values.map((members) {
    var latSum = 0.0;
    var lngSum = 0.0;
    for (final hazard in members) {
      latSum += hazard.latitude!;
      lngSum += hazard.longitude!;
    }
    return HazardCluster(
      hazards: members,
      latitude: latSum / members.length,
      longitude: lngSum / members.length,
    );
  }).toList();
}
