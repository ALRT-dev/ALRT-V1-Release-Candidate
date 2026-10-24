import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/models/route_step_model.dart';
import 'package:hazard_app/features/map/utils/hazard_avoidance_helper.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

/// Copy and lookups shared by Check a route, Travelling and the en route
/// sheet, so the three screens describe a route the same way.
class RouteOptionFormat {
  const RouteOptionFormat._();

  /// The prototype's labels, in the prototype's order.
  static const modes = <(TravelMode, String)>[
    (TravelMode.driving, 'Drive'),
    (TravelMode.transit, 'Public transport'),
    (TravelMode.walking, 'Walk'),
    (TravelMode.bicycling, 'Bike'),
  ];

  static String modeLabel(final TravelMode mode) {
    for (final entry in modes) {
      if (entry.$1 == mode) return entry.$2;
    }
    return 'Drive';
  }

  /// "24 min", or "1 hr 5 min" past the hour.
  static String minutes(final num? minutes) {
    final total = (minutes ?? 0).round();
    if (total < 60) return '$total min';
    final hours = total ~/ 60;
    final rest = total % 60;
    return rest == 0 ? '$hours hr' : '$hours hr $rest min';
  }

  /// "18.2 km", or "650 m" under a kilometre.
  static String distance(final num? metres) {
    if (metres == null) return '';
    if (metres >= 1000) return '${(metres / 1000).toStringAsFixed(1)} km';
    return '${metres.round()} m';
  }

  /// The route's distance in metres, from whichever field the Routes API
  /// filled in.
  static num? routeMetres(final Route route) {
    final metres = route.distanceMeters;
    if (metres != null) return metres;
    final km = route.distanceKm;
    return km == null ? null : km * 1000;
  }

  static final _roadPattern = RegExp(
    r'\b(?:onto|on|along|via)\s+(.+?)(?:\s+(?:toward|towards|to|and)\b.*)?$',
    caseSensitive: false,
  );

  /// The road the route spends longest on, read from Google's own step
  /// instructions ("Merge onto Mitchell Fwy" gives "Mitchell Fwy"). Null
  /// when no instruction names a road.
  static String? viaRoad(final List<RouteStep> steps) {
    if (steps.isEmpty) return null;
    final byLength = [...steps]
      ..sort((a, b) => b.distanceMeters.compareTo(a.distanceMeters));
    for (final step in byLength.take(5)) {
      final firstLine = step.instruction.split('\n').first.trim();
      final match = _roadPattern.firstMatch(firstLine);
      final road = match?.group(1)?.trim().replaceAll(RegExp(r'[.,]+$'), '');
      if (road != null && road.isNotEmpty && road.length <= 40) return road;
    }
    return null;
  }

  /// "18.2 km · via Mitchell Fwy" (the via part only when known).
  static String distanceAndVia(final Route route, final List<RouteStep> steps) {
    final km = distance(routeMetres(route));
    final via = viaRoad(steps);
    if (via == null) return km;
    return km.isEmpty ? 'via $via' : '$km · via $via';
  }

  /// The alerts that touch [route], most serious first. Same corridor the
  /// route cards have always used (0.5 km, 5 km for bushfires).
  static List<Hazard> hazardsOnRoute({
    required final List<Hazard> hazards,
    required final Route route,
  }) {
    final points =
        route.polylinePoints
            ?.map((e) => LatLng(e.latitude, e.longitude))
            .toList() ??
        const <LatLng>[];
    if (hazards.isEmpty || points.isEmpty) return const <Hazard>[];
    final found = [
      ...HazardAvoidanceHelper.analyzeRouteHazards(
        hazards: hazards,
        routePoints: points,
        otherHazardsBufferKm: 0.5,
      ).hazards,
    ];
    found.sort(
      (a, b) => (b.severityBand ?? HazardSeverityBand.info).index.compareTo(
        (a.severityBand ?? HazardSeverityBand.info).index,
      ),
    );
    return found;
  }
}
