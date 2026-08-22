import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents the maneuver to perform at the start of a navigation step.
///
/// Mirrors the `Maneuver` enum returned by Google Routes API v2 under
/// `routes.legs.steps.navigationInstruction.maneuver`.
enum ManeuverType {
  /// Maneuver was not specified by the API.
  unspecified,

  /// Depart from the start of the route.
  depart,

  /// Arrive at the destination.
  arrive,

  /// Slight left turn.
  turnSlightLeft,

  /// Sharp left turn.
  turnSharpLeft,

  /// Left u-turn.
  uTurnLeft,

  /// Left turn.
  turnLeft,

  /// Slight right turn.
  turnSlightRight,

  /// Sharp right turn.
  turnSharpRight,

  /// Right u-turn.
  uTurnRight,

  /// Right turn.
  turnRight,

  /// Continue straight.
  straight,

  /// Keep left at a fork.
  keepLeft,

  /// Keep right at a fork.
  keepRight,

  /// Merge.
  merge,

  /// Fork to the left.
  forkLeft,

  /// Fork to the right.
  forkRight,

  /// Take a ferry.
  ferry,

  /// Take a ferry train.
  ferryTrain,

  /// Roundabout left turn.
  roundaboutLeft,

  /// Roundabout right turn.
  roundaboutRight;

  /// Maps the API string (e.g. `TURN_LEFT`) to the corresponding enum value.
  ///
  /// Returns [ManeuverType.unspecified] when the value is null, empty, or
  /// otherwise unrecognized.
  static ManeuverType fromApi(final String? value) {
    if (value == null || value.isEmpty) return ManeuverType.unspecified;
    switch (value) {
      case 'DEPART':
        return ManeuverType.depart;
      case 'ARRIVE':
        return ManeuverType.arrive;
      case 'TURN_SLIGHT_LEFT':
        return ManeuverType.turnSlightLeft;
      case 'TURN_SHARP_LEFT':
        return ManeuverType.turnSharpLeft;
      case 'UTURN_LEFT':
        return ManeuverType.uTurnLeft;
      case 'TURN_LEFT':
        return ManeuverType.turnLeft;
      case 'TURN_SLIGHT_RIGHT':
        return ManeuverType.turnSlightRight;
      case 'TURN_SHARP_RIGHT':
        return ManeuverType.turnSharpRight;
      case 'UTURN_RIGHT':
        return ManeuverType.uTurnRight;
      case 'TURN_RIGHT':
        return ManeuverType.turnRight;
      case 'STRAIGHT':
        return ManeuverType.straight;
      case 'KEEP_LEFT':
        return ManeuverType.keepLeft;
      case 'KEEP_RIGHT':
        return ManeuverType.keepRight;
      case 'MERGE':
        return ManeuverType.merge;
      case 'FORK_LEFT':
        return ManeuverType.forkLeft;
      case 'FORK_RIGHT':
        return ManeuverType.forkRight;
      case 'FERRY':
        return ManeuverType.ferry;
      case 'FERRY_TRAIN':
        return ManeuverType.ferryTrain;
      case 'ROUNDABOUT_LEFT':
        return ManeuverType.roundaboutLeft;
      case 'ROUNDABOUT_RIGHT':
        return ManeuverType.roundaboutRight;
      default:
        return ManeuverType.unspecified;
    }
  }
}

/// A single navigation step within a route.
///
/// Each step corresponds to one maneuver (e.g. "Turn left onto Pacific
/// Highway") and carries the polyline traversed by that step so the current
/// step can be located by projecting the user's GPS position onto it.
class RouteStep {
  const RouteStep({
    required this.instruction,
    required this.maneuver,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.polylinePoints,
    required this.startLocation,
    required this.endLocation,
    required this.travelMode,
  });

  /// Human-readable instruction text, e.g. *"Turn left onto Pacific Highway"*.
  ///
  /// Localized using the `languageCode` / `regionCode` provided in the request.
  final String instruction;

  /// The maneuver to perform at the start of this step.
  final ManeuverType maneuver;

  /// Distance covered by this step, in meters.
  final int distanceMeters;

  /// Static (no-traffic) duration of this step, in seconds.
  final int durationSeconds;

  /// Decoded polyline points for this step.
  final List<LatLng> polylinePoints;

  /// Starting coordinate of the step.
  final LatLng startLocation;

  /// Ending coordinate of the step (i.e. the location of the next maneuver).
  final LatLng endLocation;

  /// Travel mode for this step. Useful for transit routes where individual
  /// steps may switch between walking and a transit vehicle.
  final TravelMode travelMode;

  /// Builds a [RouteStep] from a single `routes.legs.steps[*]` JSON object as
  /// returned by Google Routes API v2.
  ///
  /// Returns `null` if [json] is malformed (no instruction text, no polyline,
  /// or missing start/end locations) so the caller can skip it.
  static RouteStep? fromJson(final Map<String, dynamic> json) {
    final navigationInstruction =
        json['navigationInstruction'] as Map<String, dynamic>?;
    final instruction =
        navigationInstruction?['instructions'] as String? ?? '';

    final encodedPolyline =
        (json['polyline'] as Map<String, dynamic>?)?['encodedPolyline']
            as String?;
    final List<LatLng> polylinePoints =
        (encodedPolyline != null && encodedPolyline.isNotEmpty)
        ? PolylinePoints.decodePolyline(encodedPolyline)
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList()
        : const <LatLng>[];

    final startLatLng = _parseLatLng(json['startLocation']);
    final endLatLng = _parseLatLng(json['endLocation']);
    if (startLatLng == null || endLatLng == null) {
      return null;
    }

    return RouteStep(
      instruction: instruction,
      maneuver: ManeuverType.fromApi(
        navigationInstruction?['maneuver'] as String?,
      ),
      distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
      durationSeconds: _parseDurationSeconds(json['staticDuration']),
      polylinePoints: polylinePoints,
      startLocation: startLatLng,
      endLocation: endLatLng,
      travelMode: _parseTravelMode(json['travelMode'] as String?),
    );
  }

  /// Parses Google's location structure
  /// `{ "latLng": { "latitude": ..., "longitude": ... } }` into a [LatLng].
  static LatLng? _parseLatLng(final dynamic location) {
    if (location is! Map<String, dynamic>) return null;
    final latLng = location['latLng'] as Map<String, dynamic>?;
    if (latLng == null) return null;
    final lat = (latLng['latitude'] as num?)?.toDouble();
    final lng = (latLng['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  /// Parses a Google duration string like `"45s"` into seconds.
  static int _parseDurationSeconds(final dynamic duration) {
    if (duration == null) return 0;
    final raw = duration.toString().replaceAll('s', '').trim();
    return int.tryParse(raw) ?? 0;
  }

  /// Defaults to [TravelMode.driving] when the API omits the travel mode.
  static TravelMode _parseTravelMode(final String? value) {
    switch (value) {
      case 'WALK':
        return TravelMode.walking;
      case 'BICYCLE':
        return TravelMode.bicycling;
      case 'TRANSIT':
        return TravelMode.transit;
      case 'TWO_WHEELER':
        return TravelMode.twoWheeler;
      case 'DRIVE':
      default:
        return TravelMode.driving;
    }
  }
}
