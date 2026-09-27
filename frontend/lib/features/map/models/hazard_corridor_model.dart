import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

part 'hazard_corridor_model.freezed.dart';

/// A contiguous slice of an active route polyline that the user wants to
/// avoid because one or more hazards lie within the proximity threshold.
///
/// Multiple hazards collapse into a single corridor when their pairwise
/// distance is below the cluster threshold (see
/// [hazard_corridor_detector.dart]). The corridor's [entryPolylineIndex] and
/// [exitPolylineIndex] mark the first/last polyline points within the
/// cluster's projection so a bypass waypoint can route around the entire
/// cluster instead of a single hazard.
@freezed
abstract class HazardCorridor with _$HazardCorridor {
  const factory HazardCorridor({
    /// The hazards (≥ 1) that share this corridor.
    required final List<Hazard> hazards,

    /// Index on the active route polyline of the closest segment vertex
    /// before the cluster (inclusive).
    required final int entryPolylineIndex,

    /// Index on the active route polyline of the closest segment vertex
    /// after the cluster (inclusive).
    required final int exitPolylineIndex,

    /// Polyline vertex matching [entryPolylineIndex].
    required final LatLng entryPoint,

    /// Polyline vertex matching [exitPolylineIndex].
    required final LatLng exitPoint,

    /// Centroid of the cluster's hazards in lat/lng.
    required final LatLng centerPoint,

    /// Buffer (in meters) used by the intersection check to decide whether a
    /// candidate detour polyline still passes too close to this corridor.
    @Default(220.0) final double bufferMeters,
  }) = _HazardCorridor;
}
