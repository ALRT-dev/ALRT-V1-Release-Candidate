import 'dart:math' as math;

import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

/// Below this zoom level hazards are grouped into clusters; at or above it
/// every hazard renders as an individual marker.
const kClusterMaxZoom = 12.5;

/// Screen-space grid cell size used for clustering, in logical pixels.
/// 64 matches the density of the live app (about fifteen groups across
/// metro Perth at city zoom); 90 merged the whole metro area into a
/// handful of bubbles.
const kClusterGridPx = 64.0;

/// Above [kClusterMaxZoom] markers are drawn one by one, but two pins
/// closer than this many logical pixels still hide each other, so they are
/// grouped into a small count bubble until the camera is close enough to
/// separate them.
const kOverlapGridPx = 34.0;

/// From this zoom nothing groups any more; pins sharing a spot are fanned
/// out around it instead (see [fanOutOffsets]).
const kNoGroupingZoom = 17.0;

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

  /// Highest band present in the cluster. Community reports carry no
  /// severity, so they never raise it.
  HazardSeverityBand? get dominantBand {
    HazardSeverityBand? dominant;
    for (final hazard in hazards) {
      if (hazard.isUserReported) continue;
      final band = hazard.severityBand;
      if (band == null) continue;
      if (dominant == null || band.index > dominant.index) dominant = band;
    }
    return dominant;
  }

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
  final double gridPx = kClusterGridPx,
}) {
  final cellDegrees = 360 / math.pow(2, zoom) * (gridPx / 256);

  final buckets = <String, List<Hazard>>{};
  final standalone = <HazardCluster>[];
  for (final hazard in hazards) {
    final lat = hazard.latitude;
    final lng = hazard.longitude;
    if (lat == null || lng == null) continue;
    // AWS Watch and Act and Emergency Warnings are never hidden inside a
    // count bubble (locked map rule): they always draw as themselves.
    if (isClusterExempt(hazard)) {
      standalone.add(
        HazardCluster(hazards: [hazard], latitude: lat, longitude: lng),
      );
      continue;
    }
    final key =
        '${(lat / cellDegrees).floor()}_${(lng / cellDegrees).floor()}';
    buckets.putIfAbsent(key, () => []).add(hazard);
  }

  return [
    ...standalone,
    ...buckets.values.map((members) {
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
  }),
  ];
}

/// AWS Watch and Act / Emergency Warning: always drawn on its own.
bool isClusterExempt(final Hazard hazard) {
  if (hazard.isUserReported || hazard.isAwsCompliant != true) return false;
  final band = hazard.severityBand;
  return band == HazardSeverityBand.action ||
      band == HazardSeverityBand.critical;
}

/// Pins that share (almost) the same coordinate at street zoom are spread
/// on a small ring so every one stays visible and tappable. Returns a
/// latitude/longitude offset per hazard id; hazards alone at their spot get
/// none.
Map<String, (double, double)> fanOutOffsets({
  required final List<Hazard> hazards,
  required final double zoom,
}) {
  // About 12 logical px: anything closer than this reads as one pin.
  final cellDegrees = 360 / math.pow(2, zoom) * (12 / 256);
  final spots = <String, List<Hazard>>{};
  for (final hazard in hazards) {
    final lat = hazard.latitude;
    final lng = hazard.longitude;
    if (lat == null || lng == null || hazard.id == null) continue;
    final key = '${(lat / cellDegrees).round()}_${(lng / cellDegrees).round()}';
    spots.putIfAbsent(key, () => []).add(hazard);
  }
  // Ring radius about 26 logical px, so diamonds sit side by side.
  final radius = 360 / math.pow(2, zoom) * (26 / 256);
  final offsets = <String, (double, double)>{};
  for (final group in spots.values) {
    if (group.length < 2) continue;
    for (var i = 0; i < group.length; i++) {
      final angle = 2 * math.pi * i / group.length;
      offsets[group[i].id!] = (
        radius * math.sin(angle),
        radius * math.cos(angle),
      );
    }
  }
  return offsets;
}
