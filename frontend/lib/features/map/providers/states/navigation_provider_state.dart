import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

part 'navigation_provider_state.freezed.dart';

@freezed
abstract class NavigationProviderState with _$NavigationProviderState {
  const factory NavigationProviderState({
    /// Whether navigation is currently active
    @Default(false) final bool isNavigating,

    /// Current user location during navigation
    final AlrtLocation? currentLocation,

    /// Destination location
    final AlrtLocation? destination,

    /// Current route polyline points
    @Default([]) final List<LatLng> routePoints,

    /// Current step index in the navigation
    @Default(0) final int currentStepIndex,

    /// Current navigation instruction
    final String? currentInstruction,

    /// Distance remaining to destination (in meters)
    final double? remainingDistance,

    /// Estimated time of arrival
    final DateTime? estimatedArrival,

    /// Current speed (m/s)
    @Default(0.0) final double currentSpeed,

    /// Current bearing/direction in degrees (0-360)
    @Default(0.0) final double currentBearing,

    /// Whether the user is off-route
    @Default(false) final bool isOffRoute,

    /// Camera should follow user during navigation
    @Default(true) final bool followUser,

    /// Navigation state
    @Default(NavigationStateIdle()) final NavigationState navigationState,
  }) = _NavigationProviderState;
}

@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState.idle() = NavigationStateIdle;
  const factory NavigationState.starting() = NavigationStateStarting;
  const factory NavigationState.active() = NavigationStateActive;
  const factory NavigationState.paused() = NavigationStatePaused;
  const factory NavigationState.completed() = NavigationStateCompleted;
  const factory NavigationState.error(final AppError error) =
      NavigationStateError;
}
