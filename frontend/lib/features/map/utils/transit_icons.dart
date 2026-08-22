import 'package:flutter/material.dart';
import 'package:hazard_app/features/map/models/route_step_model.dart';

/// Maps a transit vehicle type to a Material icon. Google's Routes API
/// doesn't return maneuver data for transit steps (there's no turn to make
/// while riding a bus), so this — not a maneuver icon — is what should
/// represent a transit step or segment badge.
///
/// Shared between the live navigation overlay and the route-selection cards
/// so both surfaces agree on what a given vehicle type looks like.
IconData iconForTransitVehicleType(final TransitVehicleType? type) {
  switch (type) {
    case TransitVehicleType.bus:
    case TransitVehicleType.intercityBus:
    case TransitVehicleType.trolleybus:
    case TransitVehicleType.shareTaxi:
      return Icons.directions_bus_rounded;
    case TransitVehicleType.tram:
      return Icons.tram_rounded;
    case TransitVehicleType.subway:
    case TransitVehicleType.metroRail:
      return Icons.subway_rounded;
    case TransitVehicleType.ferry:
      return Icons.directions_boat_rounded;
    case TransitVehicleType.cableCar:
    case TransitVehicleType.gondolaLift:
    case TransitVehicleType.funicular:
      return Icons.airline_seat_recline_normal_rounded;
    case TransitVehicleType.commuterTrain:
    case TransitVehicleType.heavyRail:
    case TransitVehicleType.highSpeedTrain:
    case TransitVehicleType.longDistanceTrain:
    case TransitVehicleType.rail:
      return Icons.directions_train_rounded;
    case TransitVehicleType.monorail:
    case TransitVehicleType.other:
    case TransitVehicleType.unspecified:
    case null:
      return Icons.directions_transit_rounded;
  }
}
