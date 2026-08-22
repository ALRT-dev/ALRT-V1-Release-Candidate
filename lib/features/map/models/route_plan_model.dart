import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/models/safest_fastest_routes_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

part 'route_plan_model.freezed.dart';

@freezed
abstract class RoutePlan with _$RoutePlan {
  const RoutePlan._();

  const factory RoutePlan({
    /// The origin location for the route.
    required final AlrtLocation origin,

    /// The destination location for the route.
    required final AlrtLocation destination,

    /// Currently selected travel mode.
    @Default(TravelMode.driving) final TravelMode selectedTravelMode,

    /// Map of travel modes to their corresponding route responses.
    @Default(<TravelMode, SafestFastestRoutes>{})
    final Map<TravelMode, SafestFastestRoutes> travelModeRoutes,

    /// The list of hazards to avoid during route planning.
    @Default(<Hazard>[]) final List<Hazard> hazardsToAvoid,

    /// Whether navigation is currently active.
    @Default(false) final bool isNavigating,

    /// Modes that returned no usable route, with the reason. Kept so the
    /// option can still be offered and explained instead of vanishing.
    @Default(<TravelMode, String>{})
    final Map<TravelMode, String> unavailableModes,
  }) = _RoutePlan;

  /// Gets the current route based on the selected travel mode.
  SafestFastestRoutes? get currentRoute => travelModeRoutes[selectedTravelMode];
}
