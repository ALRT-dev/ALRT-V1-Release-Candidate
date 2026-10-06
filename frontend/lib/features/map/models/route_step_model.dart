import 'dart:ui';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart'
    show ColorConverter;

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

/// The kind of vehicle a transit line uses.
///
/// Mirrors `TransitVehicle.TransitVehicleType` from Google Routes API v2
/// (`google.maps.routing.v2.TransitVehicle`), returned under
/// `routes.legs.steps.transitDetails.transitLine.vehicle.type`.
enum TransitVehicleType {
  unspecified,
  bus,
  cableCar,
  commuterTrain,
  ferry,
  funicular,
  gondolaLift,
  heavyRail,
  highSpeedTrain,
  intercityBus,
  longDistanceTrain,
  metroRail,
  monorail,
  other,
  rail,
  shareTaxi,
  subway,
  tram,
  trolleybus;

  static TransitVehicleType fromApi(final String? value) {
    switch (value) {
      case 'BUS':
        return TransitVehicleType.bus;
      case 'CABLE_CAR':
        return TransitVehicleType.cableCar;
      case 'COMMUTER_TRAIN':
        return TransitVehicleType.commuterTrain;
      case 'FERRY':
        return TransitVehicleType.ferry;
      case 'FUNICULAR':
        return TransitVehicleType.funicular;
      case 'GONDOLA_LIFT':
        return TransitVehicleType.gondolaLift;
      case 'HEAVY_RAIL':
        return TransitVehicleType.heavyRail;
      case 'HIGH_SPEED_TRAIN':
        return TransitVehicleType.highSpeedTrain;
      case 'INTERCITY_BUS':
        return TransitVehicleType.intercityBus;
      case 'LONG_DISTANCE_TRAIN':
        return TransitVehicleType.longDistanceTrain;
      case 'METRO_RAIL':
        return TransitVehicleType.metroRail;
      case 'MONORAIL':
        return TransitVehicleType.monorail;
      case 'OTHER':
        return TransitVehicleType.other;
      case 'RAIL':
        return TransitVehicleType.rail;
      case 'SHARE_TAXI':
        return TransitVehicleType.shareTaxi;
      case 'SUBWAY':
        return TransitVehicleType.subway;
      case 'TRAM':
        return TransitVehicleType.tram;
      case 'TROLLEYBUS':
        return TransitVehicleType.trolleybus;
      default:
        return TransitVehicleType.unspecified;
    }
  }
}

/// A single stop/station on a transit leg (`TransitStop`).
class TransitStopInfo {
  const TransitStopInfo({required this.name, this.location});

  final String name;
  final LatLng? location;

  static TransitStopInfo? fromJson(final dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) return null;
    return TransitStopInfo(
      name: name,
      location: RouteStep._parseLatLng(json['location']),
    );
  }
}

/// The vehicle used by a transit line (`TransitVehicle`).
class TransitVehicleInfo {
  const TransitVehicleInfo({required this.name, required this.type});

  /// Localized vehicle name, e.g. *"Subway"*, *"Bus"*.
  final String name;
  final TransitVehicleType type;

  static TransitVehicleInfo fromJson(final Map<String, dynamic>? json) {
    if (json == null) {
      return const TransitVehicleInfo(
        name: '',
        type: TransitVehicleType.unspecified,
      );
    }
    final localizedName = json['name'] as Map<String, dynamic>?;
    return TransitVehicleInfo(
      name: (localizedName?['text'] as String?) ?? '',
      type: TransitVehicleType.fromApi(json['type'] as String?),
    );
  }
}

/// A transit line/route (`TransitLine`), e.g. a specific bus route or train
/// line, including its official display colour where Google returns one.
class TransitLineInfo {
  const TransitLineInfo({
    required this.vehicle,
    this.name,
    this.nameShort,
    this.color,
    this.textColor,
  });

  /// Full line name, e.g. *"7 Avenue Express"*.
  final String? name;

  /// Short line code as shown on signage, e.g. *"M1"*, *"66"*.
  final String? nameShort;

  /// The line's official colour, when Google provides one.
  final Color? color;

  /// The line's official text colour (for contrast against [color]).
  final Color? textColor;

  final TransitVehicleInfo vehicle;

  /// A label suitable for a UI badge: prefers [nameShort], falls back to
  /// [name], falls back to the vehicle's own name (e.g. *"Bus"*).
  String get displayLabel => nameShort ?? name ?? vehicle.name;

  static TransitLineInfo? fromJson(final dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    const colorConverter = ColorConverter();
    return TransitLineInfo(
      name: json['name'] as String?,
      nameShort: json['nameShort'] as String?,
      color: colorConverter.fromJson(json['color'] as String?),
      textColor: colorConverter.fromJson(json['textColor'] as String?),
      vehicle: TransitVehicleInfo.fromJson(
        json['vehicle'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// Transit-specific detail for a step whose [RouteStep.travelMode] is
/// [TravelMode.transit] (`RouteLegStepTransitDetails`).
///
/// Only the fields this app currently displays are modelled; anything not
/// listed here (e.g. `localizedValues`, agency phone/uri, icon URIs) is
/// available in the raw API response but deliberately not surfaced yet.
class TransitDetails {
  const TransitDetails({
    this.departureStop,
    this.departureTime,
    this.arrivalStop,
    this.arrivalTime,
    this.headsign,
    this.stopCount,
    this.line,
  });

  final TransitStopInfo? departureStop;
  final DateTime? departureTime;
  final TransitStopInfo? arrivalStop;
  final DateTime? arrivalTime;

  /// The direction/destination as shown on the vehicle, e.g. *"Downtown"*.
  final String? headsign;

  /// Number of stops between departure and arrival.
  final int? stopCount;
  final TransitLineInfo? line;

  static TransitDetails? fromJson(final dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final stopDetails = json['stopDetails'] as Map<String, dynamic>?;
    return TransitDetails(
      departureStop: TransitStopInfo.fromJson(stopDetails?['departureStop']),
      departureTime: DateTime.tryParse(
        stopDetails?['departureTime'] as String? ?? '',
      ),
      arrivalStop: TransitStopInfo.fromJson(stopDetails?['arrivalStop']),
      arrivalTime: DateTime.tryParse(
        stopDetails?['arrivalTime'] as String? ?? '',
      ),
      headsign: json['headsign'] as String?,
      stopCount: (json['stopCount'] as num?)?.toInt(),
      line: TransitLineInfo.fromJson(json['transitLine']),
    );
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
    this.transitDetails,
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

  /// Present only when [travelMode] is [TravelMode.transit]: the specific
  /// line/vehicle/stops Google's Routes API returned for this segment.
  final TransitDetails? transitDetails;

  /// Builds a [RouteStep] from a single `routes.legs.steps[*]` JSON object as
  /// returned by Google Routes API v2.
  ///
  /// Returns `null` if [json] is malformed (no instruction text, no polyline,
  /// or missing start/end locations) so the caller can skip it.
  static RouteStep? fromJson(final Map<String, dynamic> json) {
    final navigationInstruction =
        json['navigationInstruction'] as Map<String, dynamic>?;
    final transitDetails = TransitDetails.fromJson(json['transitDetails']);

    // Google's Routes API often omits navigationInstruction for a transit
    // step (the "instruction" there is the line/headsign, not a maneuver) —
    // fall back to a derived instruction from the parsed transit data rather
    // than showing a blank one.
    var instruction = navigationInstruction?['instructions'] as String? ?? '';
    if (instruction.isEmpty && transitDetails != null) {
      final label = transitDetails.line?.displayLabel;
      final headsign = transitDetails.headsign;
      instruction = [
        if (label != null && label.isNotEmpty) 'Take $label',
        if (headsign != null && headsign.isNotEmpty) 'towards $headsign',
      ].join(' ');
    }

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
      transitDetails: transitDetails,
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
