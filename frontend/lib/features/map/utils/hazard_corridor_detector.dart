import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/models/hazard_corridor_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';

/// Pure helpers that translate the user's position, the active route
/// polyline, and the route plan's `hazardsToAvoid` into a list of
/// [HazardCorridor]s ahead of the user.
///
/// The orchestrator [detectHazardCorridorsAhead] is the only entry point
/// most callers need; the smaller helpers are exposed so they remain unit
/// testable in isolation.

/// Returns hazards ahead of the user that lie within [proximityMeters] of
/// the active route polyline, grouped into [HazardCorridor]s such that
/// hazards within [clusterDistanceMeters] of each other share one corridor.
///
/// The remaining polyline is the slice of [polyline] starting at the
/// closest vertex to [user] (so corridors behind the user are ignored).
List<HazardCorridor> detectHazardCorridorsAhead({
  required final AlrtLocation user,
  required final List<LatLng> polyline,
  required final List<Hazard> hazards,
  final double proximityMeters = 200.0,
  final double clusterDistanceMeters = 100.0,
  final double corridorBufferMeters = 220.0,
}) {
  if (polyline.length < 2 || hazards.isEmpty) return const <HazardCorridor>[];

  final userLatLng = LatLng(user.latitude, user.longitude);
  final startIndex = snapPolylineIndexToUser(polyline, userLatLng);
  final remaining = remainingPolylineFrom(startIndex, polyline);
  if (remaining.length < 2) return const <HazardCorridor>[];

  final relevant = hazardsWithinMetersOfPolyline(
    hazards: hazards,
    polyline: remaining,
    thresholdMeters: proximityMeters,
  );
  if (relevant.isEmpty) return const <HazardCorridor>[];

  final clusters = clusterHazardsByDistance(
    hazards: relevant,
    thresholdMeters: clusterDistanceMeters,
  );

  final corridors = <HazardCorridor>[];
  for (final cluster in clusters) {
    final corridor = buildCorridorForCluster(
      cluster: cluster,
      polyline: polyline,
      remainingPolylineStartIndex: startIndex,
      bufferMeters: corridorBufferMeters,
    );
    if (corridor != null) corridors.add(corridor);
  }

  // Sort by entry index so callers can address the "closest ahead" first.
  corridors.sort(
    (a, b) => a.entryPolylineIndex.compareTo(b.entryPolylineIndex),
  );
  return corridors;
}

/// Returns the index of the polyline vertex closest to [user]. Used to
/// trim the polyline to the portion ahead of the user.
int snapPolylineIndexToUser(
  final List<LatLng> polyline,
  final LatLng user,
) {
  if (polyline.isEmpty) return 0;
  var bestIndex = 0;
  var bestDistance = double.infinity;
  for (var i = 0; i < polyline.length; i++) {
    final p = polyline[i];
    final d = calculateDistanceInMeters(
      user.latitude,
      user.longitude,
      p.latitude,
      p.longitude,
    );
    if (d < bestDistance) {
      bestDistance = d;
      bestIndex = i;
    }
  }
  return bestIndex;
}

/// Returns the slice of [polyline] from [startIndex] to the end (inclusive
/// of [startIndex]). Returns an empty list if [startIndex] is out of range.
List<LatLng> remainingPolylineFrom(
  final int startIndex,
  final List<LatLng> polyline,
) {
  if (startIndex < 0 || startIndex >= polyline.length) {
    return const <LatLng>[];
  }
  return polyline.sublist(startIndex);
}

/// Returns the subset of [hazards] whose perpendicular distance to any
/// segment of [polyline] is ≤ [thresholdMeters].
///
/// Hazards with null lat/lng are skipped.
List<Hazard> hazardsWithinMetersOfPolyline({
  required final List<Hazard> hazards,
  required final List<LatLng> polyline,
  required final double thresholdMeters,
}) {
  if (polyline.length < 2) return const <Hazard>[];

  final result = <Hazard>[];
  for (final hazard in hazards) {
    if (hazard.latitude == null || hazard.longitude == null) continue;
    final distance = _distanceToPolylineMeters(
      LatLng(hazard.latitude!, hazard.longitude!),
      polyline,
    );
    if (distance <= thresholdMeters) result.add(hazard);
  }
  return result;
}

/// Single-link clustering: any two hazards within [thresholdMeters] of each
/// other end up in the same cluster (union-find by transitive closure).
///
/// Hazards with null lat/lng become their own singleton clusters.
List<List<Hazard>> clusterHazardsByDistance({
  required final List<Hazard> hazards,
  required final double thresholdMeters,
}) {
  if (hazards.isEmpty) return const <List<Hazard>>[];

  final parent = List<int>.generate(hazards.length, (final i) => i);
  int find(int i) {
    while (parent[i] != i) {
      parent[i] = parent[parent[i]];
      i = parent[i];
    }
    return i;
  }

  void union(final int a, final int b) {
    final ra = find(a);
    final rb = find(b);
    if (ra != rb) parent[ra] = rb;
  }

  for (var i = 0; i < hazards.length; i++) {
    final a = hazards[i];
    if (a.latitude == null || a.longitude == null) continue;
    for (var j = i + 1; j < hazards.length; j++) {
      final b = hazards[j];
      if (b.latitude == null || b.longitude == null) continue;
      final d = calculateDistanceInMeters(
        a.latitude!,
        a.longitude!,
        b.latitude!,
        b.longitude!,
      );
      if (d <= thresholdMeters) union(i, j);
    }
  }

  final groups = <int, List<Hazard>>{};
  for (var i = 0; i < hazards.length; i++) {
    groups.putIfAbsent(find(i), () => <Hazard>[]).add(hazards[i]);
  }
  return groups.values.toList(growable: false);
}

/// Builds a [HazardCorridor] spanning the cluster's projection on the
/// active polyline.
///
/// [polyline] is the *full* active polyline; [remainingPolylineStartIndex]
/// is the offset of the user-snapped vertex inside it. Both are needed so
/// the returned corridor's indices reference the full polyline (other code
/// like the polyline-corridor intersection check operates on the full
/// polyline of a candidate detour, so addressing in the same coordinate
/// space avoids off-by-one bugs).
///
/// Returns `null` if [cluster] has no hazards with valid coordinates or if
/// [polyline] is too short.
HazardCorridor? buildCorridorForCluster({
  required final List<Hazard> cluster,
  required final List<LatLng> polyline,
  required final int remainingPolylineStartIndex,
  required final double bufferMeters,
}) {
  if (cluster.isEmpty || polyline.length < 2) return null;

  final validHazards = cluster
      .where((final h) => h.latitude != null && h.longitude != null)
      .toList(growable: false);
  if (validHazards.isEmpty) return null;

  var entryIndex = polyline.length - 1;
  var exitIndex = remainingPolylineStartIndex;

  for (final hazard in validHazards) {
    final hazardLatLng = LatLng(hazard.latitude!, hazard.longitude!);
    final closestVertex = _closestVertexIndex(
      hazardLatLng,
      polyline,
      fromIndex: remainingPolylineStartIndex,
    );
    if (closestVertex < entryIndex) entryIndex = closestVertex;
    if (closestVertex > exitIndex) exitIndex = closestVertex;
  }

  if (entryIndex > exitIndex) {
    final tmp = entryIndex;
    entryIndex = exitIndex;
    exitIndex = tmp;
  }

  // Centroid (simple lat/lng mean is fine for clusters spanning << 100 km).
  var latSum = 0.0;
  var lngSum = 0.0;
  for (final hazard in validHazards) {
    latSum += hazard.latitude!;
    lngSum += hazard.longitude!;
  }
  final centroid = LatLng(
    latSum / validHazards.length,
    lngSum / validHazards.length,
  );

  return HazardCorridor(
    hazards: List<Hazard>.unmodifiable(cluster),
    entryPolylineIndex: entryIndex,
    exitPolylineIndex: exitIndex,
    entryPoint: polyline[entryIndex],
    exitPoint: polyline[exitIndex],
    centerPoint: centroid,
    bufferMeters: bufferMeters,
  );
}

/// Returns the index (≥ [fromIndex]) of the polyline vertex closest to
/// [point]. Falls back to [fromIndex] when [polyline] is empty past it.
int _closestVertexIndex(
  final LatLng point,
  final List<LatLng> polyline, {
  final int fromIndex = 0,
}) {
  var bestIndex = fromIndex.clamp(0, polyline.length - 1);
  var bestDistance = double.infinity;
  for (var i = fromIndex; i < polyline.length; i++) {
    final p = polyline[i];
    final d = calculateDistanceInMeters(
      point.latitude,
      point.longitude,
      p.latitude,
      p.longitude,
    );
    if (d < bestDistance) {
      bestDistance = d;
      bestIndex = i;
    }
  }
  return bestIndex;
}

/// Minimum perpendicular distance (in meters) from [point] to any segment
/// of [polyline]. Mirrors the math in `HazardAvoidanceHelper`.
double _distanceToPolylineMeters(
  final LatLng point,
  final List<LatLng> polyline,
) {
  if (polyline.isEmpty) return double.infinity;
  if (polyline.length == 1) {
    return calculateDistanceInMeters(
      point.latitude,
      point.longitude,
      polyline.first.latitude,
      polyline.first.longitude,
    );
  }

  var best = double.infinity;
  for (var i = 0; i < polyline.length - 1; i++) {
    final d = _distanceToSegmentMeters(
      point,
      polyline[i],
      polyline[i + 1],
    );
    if (d < best) best = d;
  }
  return best;
}

double _distanceToSegmentMeters(
  final LatLng point,
  final LatLng segmentStart,
  final LatLng segmentEnd,
) {
  // Linear projection in lat/lng degree space then Haversine on the
  // resulting closest point. Accurate enough at typical road-segment
  // lengths and avoids the cost of full-curvature math.
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
