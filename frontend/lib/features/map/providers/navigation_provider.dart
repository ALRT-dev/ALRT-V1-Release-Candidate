import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/states/navigation_provider_state.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';

final providerOfNavigation =
    StateNotifierProvider<NavigationProvider, NavigationProviderState>(
  (ref) => NavigationProvider(
    ref: ref,
    state: NavigationProviderState(),
  ),
);

class NavigationProvider extends StateNotifier<NavigationProviderState> {
  NavigationProvider({
    required final Ref ref,
    required final NavigationProviderState state,
  })  : _ref = ref,
        super(state);

  final Ref _ref;
  Timer? _locationUpdateTimer;
  StreamSubscription? _locationSubscription;

  /// Starts navigation to the given destination
  Future<void> startNavigation({
    required AlrtLocation destination,
    required List<LatLng> routePoints,
  }) async {
    try {
      state = state.copyWith(
        navigationState: const NavigationState.starting(),
        destination: destination,
        routePoints: routePoints,
        isNavigating: true,
        currentStepIndex: 0,
        isOffRoute: false,
        followUser: true,
      );

      // Ensure location permission and get initial location
      await _ref.read(providerOfLocation.notifier).getLocation();
      final initialLocation = _ref.read(providerOfLocation).location;

      state = state.copyWith(
        currentLocation: initialLocation,
      );

      // Start location tracking
      await _startLocationTracking();

      state = state.copyWith(
        navigationState: const NavigationState.active(),
      );
    } catch (e) {
      state = state.copyWith(
        navigationState: NavigationState.error(
          AppError(
            code: 'NAVIGATION_START_ERROR',
            message: 'Failed to start navigation: $e',
          ),
        ),
      );
    }
  }

  /// Stops the current navigation
  void stopNavigation() {
    _stopLocationTracking();
    state = NavigationProviderState();
  }

  /// Pauses the current navigation
  void pauseNavigation() {
    if (state.isNavigating) {
      state = state.copyWith(
        navigationState: const NavigationState.paused(),
      );
      _stopLocationTracking();
    }
  }

  /// Resumes paused navigation
  Future<void> resumeNavigation() async {
    if (state.navigationState == const NavigationState.paused()) {
      await _startLocationTracking();
      state = state.copyWith(
        navigationState: const NavigationState.active(),
      );
    }
  }

  /// Toggles whether the camera should follow the user
  void toggleFollowUser() {
    state = state.copyWith(
      followUser: !state.followUser,
    );
  }

  /// Manually update location (useful for testing)
  void updateLocationManually(AlrtLocation location) {
    _updateLocation(location);
  }

  /// Updates the current location during navigation
  void _updateLocation(AlrtLocation location) {
    if (!state.isNavigating) return;

    final previousLocation = state.currentLocation;

    // Calculate bearing if we have a previous location
    double bearing = state.currentBearing;
    if (previousLocation != null) {
      final speed = _calculateSpeed(previousLocation, location);
      bearing = _calculateBearing(
        LatLng(previousLocation.latitude, previousLocation.longitude),
        LatLng(location.latitude, location.longitude),
      );

      state = state.copyWith(
        currentLocation: location,
        currentSpeed: speed,
        currentBearing: bearing,
      );
    } else {
      state = state.copyWith(currentLocation: location);
    }

    // Check if user is still on route
    _checkIfOnRoute(location);

    // Update navigation instructions
    _updateNavigationInstructions(location);

    // Calculate remaining distance and ETA
    _updateDistanceAndETA(location);

    // Check if destination is reached
    _checkDestinationReached(location);
  }

  /// Starts tracking user location during navigation
  Future<void> _startLocationTracking() async {
    // Update location every 1 second during navigation for smooth tracking
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        await _ref.read(providerOfLocation.notifier).getLocation();
        final currentLocation = _ref.read(providerOfLocation).location;
        _updateLocation(currentLocation);
      },
    );
  }

  /// Stops location tracking
  void _stopLocationTracking() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Calculates speed between two locations
  double _calculateSpeed(AlrtLocation from, AlrtLocation to) {
    const double earthRadius = 6371000; // Earth radius in meters
    final double lat1Rad = from.latitude * pi / 180;
    final double lat2Rad = to.latitude * pi / 180;
    final double deltaLatRad = (to.latitude - from.latitude) * pi / 180;
    final double deltaLngRad = (to.longitude - from.longitude) * pi / 180;

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLngRad / 2) *
            sin(deltaLngRad / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    // Assume 1 second between updates for speed calculation
    // Apply smoothing to avoid erratic speed readings
    final newSpeed = distance / 1.0; // m/s
    final currentSpeed = state.currentSpeed;

    // Apply simple low-pass filter for smoother speed readings
    const double alpha = 0.3; // Smoothing factor
    return alpha * newSpeed + (1 - alpha) * currentSpeed;
  }

  /// Checks if the user is still on the planned route
  void _checkIfOnRoute(AlrtLocation location) {
    if (state.routePoints.isEmpty) return;

    const double maxDistanceFromRoute = 50.0; // 50 meters threshold
    final userLatLng = LatLng(location.latitude, location.longitude);

    double minDistance = double.infinity;

    // Find the closest point on the route
    for (int i = 0; i < state.routePoints.length - 1; i++) {
      final distance = _distanceToLineSegment(
        userLatLng,
        state.routePoints[i],
        state.routePoints[i + 1],
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    final bool wasOffRoute = state.isOffRoute;
    final bool isOffRoute = minDistance > maxDistanceFromRoute;

    if (isOffRoute != wasOffRoute) {
      state = state.copyWith(isOffRoute: isOffRoute);
    }
  }

  /// Calculates distance from a point to a line segment
  double _distanceToLineSegment(
      LatLng point, LatLng lineStart, LatLng lineEnd) {
    final double A = point.latitude - lineStart.latitude;
    final double B = point.longitude - lineStart.longitude;
    final double C = lineEnd.latitude - lineStart.latitude;
    final double D = lineEnd.longitude - lineStart.longitude;

    final double dot = A * C + B * D;
    final double lenSq = C * C + D * D;

    if (lenSq == 0) {
      return _calculateDistance(point, lineStart);
    }

    final double param = dot / lenSq;
    final LatLng closestPoint;

    if (param < 0) {
      closestPoint = lineStart;
    } else if (param > 1) {
      closestPoint = lineEnd;
    } else {
      closestPoint = LatLng(
        lineStart.latitude + param * C,
        lineStart.longitude + param * D,
      );
    }

    return _calculateDistance(point, closestPoint);
  }

  /// Calculates distance between two LatLng points in meters
  double _calculateDistance(LatLng from, LatLng to) {
    return calculateDistanceInMeters(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Updates navigation instructions based on current location
  void _updateNavigationInstructions(AlrtLocation location) {
    if (state.routePoints.isEmpty) return;

    final userLatLng = LatLng(location.latitude, location.longitude);

    // Find the closest route point ahead of the user
    int closestIndex = state.currentStepIndex;
    double minDistance = double.infinity;

    // Look ahead from current position to find the closest upcoming waypoint
    for (int i = state.currentStepIndex; i < state.routePoints.length; i++) {
      final distance = _calculateDistance(userLatLng, state.routePoints[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    // Only update if we've moved forward significantly (to avoid jumping back and forth)
    if (closestIndex > state.currentStepIndex || minDistance < 25.0) {
      // 25 meter threshold
      state = state.copyWith(currentStepIndex: closestIndex);
    }

    // Generate instruction based on the direction to the next significant waypoint
    String? instruction;
    final lookAheadDistance = 100.0; // Look 100 meters ahead for instructions

    // Find the next waypoint that's far enough ahead for a meaningful instruction
    LatLng? nextSignificantPoint;
    for (int i = state.currentStepIndex + 1;
        i < state.routePoints.length;
        i++) {
      final distance = _calculateDistance(userLatLng, state.routePoints[i]);
      if (distance > lookAheadDistance) {
        nextSignificantPoint = state.routePoints[i];
        break;
      }
    }

    if (nextSignificantPoint != null) {
      final bearing = _calculateBearing(userLatLng, nextSignificantPoint);
      instruction = _getDirectionInstruction(bearing);
    } else if (state.currentStepIndex < state.routePoints.length - 1) {
      instruction = 'Continue to destination';
    } else {
      instruction = 'Arriving at destination';
    }

    if (instruction != state.currentInstruction) {
      state = state.copyWith(currentInstruction: instruction);
    }
  }

  /// Calculates bearing between two points
  double _calculateBearing(LatLng from, LatLng to) {
    final double lat1 = from.latitude * pi / 180;
    final double lat2 = to.latitude * pi / 180;
    final double deltaLng = (to.longitude - from.longitude) * pi / 180;

    final double y = sin(deltaLng) * cos(lat2);
    final double x =
        cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);

    final double bearing = atan2(y, x);
    return (bearing * 180 / pi + 360) % 360; // Convert to degrees 0-360
  }

  /// Converts bearing to direction instruction
  String _getDirectionInstruction(double bearing) {
    // Get the current bearing to determine relative direction
    final currentBearing = state.currentBearing;
    final relativeBearing = (bearing - currentBearing + 360) % 360;

    if (relativeBearing >= 345 || relativeBearing < 15) {
      return 'Continue straight';
    } else if (relativeBearing >= 15 && relativeBearing < 45) {
      return 'Turn slightly right';
    } else if (relativeBearing >= 45 && relativeBearing < 135) {
      return 'Turn right';
    } else if (relativeBearing >= 135 && relativeBearing < 165) {
      return 'Turn sharp right';
    } else if (relativeBearing >= 165 && relativeBearing < 195) {
      return 'Make a U-turn';
    } else if (relativeBearing >= 195 && relativeBearing < 225) {
      return 'Turn sharp left';
    } else if (relativeBearing >= 225 && relativeBearing < 315) {
      return 'Turn left';
    } else {
      return 'Turn slightly left';
    }
  }

  /// Updates remaining distance and estimated time of arrival
  void _updateDistanceAndETA(AlrtLocation location) {
    if (state.routePoints.isEmpty) return;

    final userLatLng = LatLng(location.latitude, location.longitude);

    // Calculate remaining distance along the route
    double remainingDistance = 0.0;

    // Find the closest point on the route ahead of the user
    int startIndex = state.currentStepIndex;

    // If we have a valid current step index, calculate from there
    if (startIndex < state.routePoints.length) {
      // Add distance from current location to the next route point
      if (startIndex < state.routePoints.length - 1) {
        remainingDistance +=
            _calculateDistance(userLatLng, state.routePoints[startIndex + 1]);
      }

      // Add distance between all remaining route points
      for (int i = startIndex + 1; i < state.routePoints.length - 1; i++) {
        remainingDistance +=
            _calculateDistance(state.routePoints[i], state.routePoints[i + 1]);
      }
    } else {
      // Fallback: calculate straight-line distance to destination
      remainingDistance =
          _calculateDistance(userLatLng, state.routePoints.last);
    }

    DateTime? eta;
    if (state.currentSpeed > 0.5) {
      // Only calculate ETA if moving at reasonable speed (> 0.5 m/s)
      final timeInSeconds = remainingDistance / state.currentSpeed;
      eta = DateTime.now().add(Duration(seconds: timeInSeconds.round()));
    }

    state = state.copyWith(
      remainingDistance: remainingDistance,
      estimatedArrival: eta,
    );
  }

  /// Checks if the destination has been reached
  void _checkDestinationReached(AlrtLocation location) {
    if (state.destination == null) return;

    const double arrivalThreshold = 20.0; // 20 meters
    final distanceToDestination = _calculateDistance(
      LatLng(location.latitude, location.longitude),
      LatLng(state.destination!.latitude, state.destination!.longitude),
    );

    if (distanceToDestination <= arrivalThreshold) {
      state = state.copyWith(
        navigationState: const NavigationState.completed(),
        currentInstruction: 'You have arrived at your destination',
      );

      // Stop navigation after a delay
      Future.delayed(const Duration(seconds: 3), () {
        stopNavigation();
      });
    }
  }

  @override
  void dispose() {
    _stopLocationTracking();
    super.dispose();
  }
}
