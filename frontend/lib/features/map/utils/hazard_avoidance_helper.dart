import 'dart:developer' as dev;
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';

/// Helper class for hazard avoidance functionality
class HazardAvoidanceHelper {
  static final bool _enableLogging = false;

  /// Filters hazards that are relevant to a specific route using actual route polyline
  static List<Hazard> getRelevantHazardsForPolyline(
    List<Hazard> allHazards,
    List<LatLng> routePoints, {
    double bushfireBufferKm =
        5.0, // Default 5km buffer around route (used for bushfire)
    double otherHazardsBufferKm = 2.5, // Buffer for non-bushfire hazards
  }) {
    if (routePoints.isEmpty) {
      log('Warning: Empty route points provided');
      return [];
    }

    final filteredHazards = <Hazard>[];

    for (final hazard in allHazards) {
      if (hazard.latitude == null || hazard.longitude == null) {
        log('Skipping hazard with null coordinates: ${hazard.id}');
        continue;
      }

      final hazardLocation = LatLng(hazard.latitude!, hazard.longitude!);
      final distanceToRoute = _calculateDistanceToPolyline(
        hazardLocation,
        routePoints,
      );

      // Use different buffer distances based on hazard type
      final isBushfire = hazard.categoryId == 'bushfire';
      final effectiveBufferKm = isBushfire
          ? bushfireBufferKm
          : otherHazardsBufferKm;
      final bufferMeters = effectiveBufferKm * 1000;
      final isRelevant = distanceToRoute <= bufferMeters;

      // log(
      //   'Hazard ${hazard.id}: distance=${distanceToRoute.toStringAsFixed(0)}m, buffer=${bufferMeters.toStringAsFixed(0)}m, relevant=$isRelevant, severity=${hazard.severity}',
      // );

      if (isRelevant) {
        filteredHazards.add(hazard);
      }
    }

    return filteredHazards;
  }

  /// Filters hazards that are relevant to a specific route (legacy method - kept for backward compatibility)
  static List<Hazard> getRelevantHazards(
    List<Hazard> allHazards,
    LatLng origin,
    LatLng destination, {
    double bufferKm = 5.0, // Default 5km buffer around route
  }) {
    final filteredHazards = <Hazard>[];

    for (final hazard in allHazards) {
      if (hazard.latitude == null || hazard.longitude == null) {
        log('Skipping hazard with null coordinates: ${hazard.id}');
        continue;
      }

      final hazardLocation = LatLng(hazard.latitude!, hazard.longitude!);
      final distanceToRoute = _calculateDistanceToRoute(
        hazardLocation,
        origin,
        destination,
      );

      final bufferMeters = bufferKm * 1000;
      final isRelevant = distanceToRoute <= bufferMeters;

      log(
        'Hazard ${hazard.id}: distance=${distanceToRoute.toStringAsFixed(0)}m, buffer=${bufferMeters.toStringAsFixed(0)}m, relevant=$isRelevant, severity=${hazard.severity}',
      );

      if (isRelevant) {
        filteredHazards.add(hazard);
      }
    }

    return filteredHazards;
  }

  /// Gets hazards filtered by severity level
  static List<Hazard> getHazardsBySeverity(
    List<Hazard> hazards,
    List<HazardSeverity> severityLevels,
  ) {
    return hazards.where((hazard) {
      return hazard.severity != null &&
          severityLevels.contains(hazard.severity);
    }).toList();
  }

  /// Gets high-priority hazards that should definitely be avoided
  static List<Hazard> getHighPriorityHazards(List<Hazard> hazards) {
    return getHazardsBySeverity(hazards, [
      HazardSeverity.emergency,
      HazardSeverity.watchAndAct,
    ]);
  }

  /// Creates a summary of hazards for a route using actual route polyline points
  static RouteHazardSummary analyzeRouteHazards({
    required List<Hazard> hazards,
    required List<LatLng> routePoints,
    double bushfireBufferKm = 5.0, // 5km buffer for bushfire hazards
    double otherHazardsBufferKm = 2.5, // 2.5km buffer for other hazards
  }) {
    // First, get only hazards that are relevant to this route
    final relevantHazards = getRelevantHazardsForPolyline(
      hazards,
      routePoints,
      bushfireBufferKm: bushfireBufferKm,
      otherHazardsBufferKm: otherHazardsBufferKm,
    );

    // Debug: log the filtering results
    // log('Total hazards: ${hazards.length}');
    // log('Relevant hazards for route: ${relevantHazards.length}');
    // log('Route points: ${routePoints.length}');
    // if (routePoints.isNotEmpty) {
    //   log(
    //     'Route start: ${routePoints.first.latitude}, ${routePoints.first.longitude}',
    //   );
    //   log(
    //     'Route end: ${routePoints.last.latitude}, ${routePoints.last.longitude}',
    //   );
    // }

    // Count hazards by severity band
    final emergencyCount = relevantHazards
        .where((h) => h.severityBand == HazardSeverityBand.critical)
        .length;

    final highRiskCount = relevantHazards
        .where((h) => h.severityBand == HazardSeverityBand.action)
        .length;

    final mediumRiskCount = relevantHazards
        .where((h) => h.severityBand == HazardSeverityBand.monitor)
        .length;

    final lowRiskCount = relevantHazards
        .where((h) => h.severityBand == HazardSeverityBand.info)
        .length;

    // Debug: log the counts
    log(
      'Emergency: $emergencyCount, High: $highRiskCount, Medium: $mediumRiskCount, Low: $lowRiskCount',
    );

    return RouteHazardSummary(
      totalHazards: relevantHazards.length,
      emergencyHazards: emergencyCount,
      highRiskHazards: highRiskCount,
      mediumRiskHazards: mediumRiskCount,
      lowRiskHazards: lowRiskCount,
      hazards: relevantHazards,
    );
  }

  /// Determines if a route should use hazard avoidance based on hazard count/severity
  static bool shouldAvoidHazards(List<Hazard> hazards) {
    final highPriorityHazards = getHighPriorityHazards(hazards);
    return highPriorityHazards.isNotEmpty;
  }

  /// Calculates distance from a point to the closest point on a polyline (actual route)
  static double _calculateDistanceToPolyline(
    LatLng point,
    List<LatLng> routePoints,
  ) {
    if (routePoints.isEmpty) return double.infinity;
    if (routePoints.length == 1) {
      return _calculateDistance(point, routePoints.first);
    }

    double minDistance = double.infinity;

    // Check distance to each segment of the route polyline
    for (int i = 0; i < routePoints.length - 1; i++) {
      final segmentStart = routePoints[i];
      final segmentEnd = routePoints[i + 1];

      final distanceToSegment = _calculateDistanceToRoute(
        point,
        segmentStart,
        segmentEnd,
      );

      minDistance = math.min(minDistance, distanceToSegment);
    }

    return minDistance;
  }

  /// Calculates approximate distance from a point to a route line segment (legacy method)
  static double _calculateDistanceToRoute(
    LatLng point,
    LatLng routeStart,
    LatLng routeEnd,
  ) {
    // Simplified distance calculation to line segment
    final A = point.latitude - routeStart.latitude;
    final B = point.longitude - routeStart.longitude;
    final C = routeEnd.latitude - routeStart.latitude;
    final D = routeEnd.longitude - routeStart.longitude;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;

    if (lenSq == 0) {
      return _calculateDistance(point, routeStart);
    }

    final param = dot / lenSq;
    LatLng closestPoint;

    if (param < 0) {
      closestPoint = routeStart;
    } else if (param > 1) {
      closestPoint = routeEnd;
    } else {
      closestPoint = LatLng(
        routeStart.latitude + param * C,
        routeStart.longitude + param * D,
      );
    }

    return _calculateDistance(point, closestPoint);
  }

  /// Calculates distance between two coordinates in meters using Haversine formula.
  static double _calculateDistance(LatLng point1, LatLng point2) {
    return calculateDistanceInMeters(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Logs a message if logging is enabled
  static void log(final String message) {
    if (!_enableLogging) return;
    dev.log(message);
  }
}

/// Summary of hazards affecting a route
class RouteHazardSummary {
  const RouteHazardSummary({
    required this.totalHazards,
    required this.emergencyHazards,
    required this.highRiskHazards,
    required this.mediumRiskHazards,
    required this.lowRiskHazards,
    required this.hazards,
  });

  final int totalHazards;
  final int emergencyHazards;
  final int highRiskHazards;
  final int mediumRiskHazards;
  final int lowRiskHazards;
  final List<Hazard> hazards;

  bool get hasEmergencyHazards => emergencyHazards > 0;
  bool get hasHighRiskHazards => highRiskHazards > 0;
  bool get hasAnyHazards => totalHazards > 0;

  /// Gets a risk level for the route
  RouteRiskLevel get riskLevel {
    if (emergencyHazards > 0) return RouteRiskLevel.emergency;
    if (highRiskHazards > 0) return RouteRiskLevel.high;
    if (mediumRiskHazards > 0) return RouteRiskLevel.medium;
    if (lowRiskHazards > 0) return RouteRiskLevel.low;
    return RouteRiskLevel.safe;
  }

  /// Gets a human-readable summary message
  String get summaryMessage {
    if (totalHazards == 0) {
      return 'No alerts detected on this route. Safe to proceed.';
    }

    final messages = <String>[];
    if (emergencyHazards > 0) {
      messages.add(
        '$emergencyHazards critical alert${emergencyHazards == 1 ? '' : 's'}',
      );
    }
    if (highRiskHazards > 0) {
      messages.add(
        '$highRiskHazards high risk alert${highRiskHazards == 1 ? '' : 's'}',
      );
    }
    if (mediumRiskHazards > 0) {
      messages.add(
        '$mediumRiskHazards medium risk alert${mediumRiskHazards == 1 ? '' : 's'}',
      );
    }
    if (lowRiskHazards > 0) {
      messages.add(
        '$lowRiskHazards low risk alert${lowRiskHazards == 1 ? '' : 's'}',
      );
    }

    final hazardText = messages.join(', ');

    switch (riskLevel) {
      case RouteRiskLevel.emergency:
        return 'CRITICAL: Route contains $hazardText. Consider alternative route.';
      case RouteRiskLevel.high:
        return 'ACTION: Route contains $hazardText. Exercise caution.';
      case RouteRiskLevel.medium:
        return 'MONITOR: Route contains $hazardText. Stay alert.';
      case RouteRiskLevel.low:
        return 'INFO: Route contains $hazardText.';
      case RouteRiskLevel.safe:
        return 'Route appears safe.';
    }
  }
}

enum RouteRiskLevel {
  safe,
  low,
  medium,
  high,
  emergency,
}
