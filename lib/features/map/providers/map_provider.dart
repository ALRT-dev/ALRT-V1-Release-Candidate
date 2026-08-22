import 'dart:async';
import 'dart:math' hide log;
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_sync.dart';
import 'package:hazard_app/features/map/extensions/lat_lng_list_extension.dart';
import 'package:hazard_app/features/map/extensions/polyline_extension.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/models/hazard_corridor_model.dart';
import 'package:hazard_app/features/map/models/route_plan_model.dart';
import 'package:hazard_app/features/map/models/route_step_model.dart';
import 'package:hazard_app/features/map/models/safest_fastest_routes_model.dart';
import 'package:hazard_app/features/map/providers/hazard_markers_bitmaps_provider.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_display_settings_provider.dart';
import 'package:hazard_app/features/map/providers/service_providers.dart';
import 'package:hazard_app/features/map/providers/states/hazard_markers_bitmaps_provider_state.dart';
import 'package:hazard_app/features/map/providers/states/map_provider_state.dart';
import 'package:hazard_app/features/map/services/location_service.dart';
import 'package:hazard_app/features/map/services/map_service.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/map/utils/hazard_cluster_util.dart';
import 'package:hazard_app/features/map/utils/bypass_waypoint_planner.dart';
import 'package:hazard_app/features/map/utils/hazard_corridor_detector.dart';
import 'package:hazard_app/features/map/utils/navigation_polyline_simulation.dart';
import 'package:hazard_app/features/map/views/widgets/route_label_marker.dart';
import 'package:hazard_app/features/search/models/hazard_search_params.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/features/shared/enums/sort_category_types.dart';
import 'package:hazard_app/features/shared/enums/sort_order_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_filters_provider_state.dart';
import 'package:hazard_app/features/shared/providers/hazard_item_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/hazard_service.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:hazard_app/features/shared/providers/community_safety_provider.dart';

final providerOfMap =
    StateNotifierProvider.autoDispose<MapProvider, MapProviderState>(
      (ref) => MapProvider(
        ref: ref,
        state: MapProviderState(
          getMapHazardsCancelToken: CancelToken(),
          getHazardsToAvoidCancelToken: CancelToken(),
        ),
      ),
    );

class MapProvider extends StateNotifier<MapProviderState> {
  MapProvider({
    required final Ref ref,
    required final MapProviderState state,
  }) : _ref = ref,
       super(state) {
    _onInit();
  }

  final Ref _ref;
  MapService get _mapService => _ref.read(providerOfMapService);
  HazardService get _hazardService => _ref.read(providerOfHazardService);
  LocationService get _locationService => _ref.read(providerOfLocationService);
  HazardMarkersBitmapsProviderState get _hazardMarkerBitmapsProviderState =>
      _ref.read(providerOfHazardMarkerBitmaps);

  StreamSubscription<double>? _headingStreamSubscription;
  StreamSubscription? _positionStreamSubscription;
  int _hazardRequestId = 0;

  /// Timer to auto-hide the "Take Alternate Route" button after 10 seconds.
  Timer? _takeAlternateRouteButtonTimer;

  /// After sim framing runs once ([_applySimulationNorthUpCameraFrame]), arrow
  /// presses only pan with [CameraUpdate.newLatLng] so zoom/bearing/tilt do not
  /// animate every tick (maps interpolate full [CameraPosition] updates).
  bool _simulationNorthUpCameraFrameApplied = false;

  /// The page size for fetching hazards.
  int get _pageSize => 5000;

  void _onInit() {
    final currentUserLocation = _ref.read(providerOfLocation).location;
    updateCameraPosition(
      cameraPosition: CameraPosition(
        target: LatLng(
          currentUserLocation.latitude,
          currentUserLocation.longitude,
        ),
        zoom: 14.0,
      ),
    );

    // Re-render markers when family members' live locations move so their
    // avatar pins track in real time.
    _ref.listen(
      providerOfFamily.select(
        (s) => s.circle?.members
            .map((m) => '${m.id}:${m.latitude},${m.longitude}')
            .join('|'),
      ),
      (prev, next) {
        if (prev != next && state.isMapReady) generateMarkers();
      },
    );

    // Re-render markers when the Map details sheet's source-system toggles
    // change so alerts from a hidden system disappear immediately.
    _ref.listen(
      providerOfVisibleAlertSystems,
      (prev, next) {
        if (prev != next && state.isMapReady) generateMarkers();
      },
    );

    _ref.onDispose(() {
      _headingStreamSubscription?.cancel();
      _positionStreamSubscription?.cancel();
      _takeAlternateRouteButtonTimer?.cancel();
      // Reset map ready state when provider is disposed
      if (mounted) {
        state = state.copyWith(
          isMapReady: false,
          pendingCameraUpdateToApply: null,
        );
      }
    });
  }

  /// Initializes the map controller.
  Future<void> init({
    required final GoogleMapController googleMapController,
  }) async {
    _mapService.initializeMapController(
      googleMapController: googleMapController,
    );

    // Mark map as ready
    updateIsMapReady(true);

    // Execute any pending animation
    final pendingCameraUpdateToApply = state.pendingCameraUpdateToApply;
    if (pendingCameraUpdateToApply != null) {
      animateToCameraUpdate(
        cameraUpdate: pendingCameraUpdateToApply,
      );
    }
  }

  bool _isInBounds(Hazard hazard, LatLngBounds bounds) {
    final lat = hazard.latitude;
    final lng = hazard.longitude;
    if (lat == null || lng == null) return false;
    return lat >= bounds.southwest.latitude &&
        lat <= bounds.northeast.latitude &&
        lng >= bounds.southwest.longitude &&
        lng <= bounds.northeast.longitude;
  }

  /// Returns true if [hazard] passes the given source/category filters.
  bool _matchesFilters(
    Hazard hazard,
    HazardFiltersProviderState filters,
  ) {
    // Category filter
    final categoryId = hazard.categoryId;
    final parentCategoryId = hazard.category?.parentId;
    final isCategorySelected =
        categoryId != null && filters.selectedCategoryIds.contains(categoryId);
    final isParentCategorySelected =
        parentCategoryId != null &&
        filters.selectedCategoryIds.contains(parentCategoryId);
    if (filters.selectedCategoryIds.isNotEmpty &&
        !isCategorySelected &&
        !isParentCategorySelected) {
      return false;
    }

    // Source-type filters
    if (hazard.isUserReported) return filters.userReported;

    if (hazard.isAwsCompliant == true) {
      return switch (hazard.severityBand) {
        HazardSeverityBand.critical => filters.awsEmergency,
        HazardSeverityBand.action => filters.awsWatchAndAct,
        _ => filters.awsAdvice,
      };
    }

    return filters.officialNonAws;
  }

  List<Hazard> _getHazardsInBounds(
    LatLngBounds bounds,
    HazardFiltersProviderState filters,
  ) {
    return state.hazardCache.values
        .where((h) => _isInBounds(h, bounds) && _matchesFilters(h, filters))
        .toList();
  }

  /// Fetches hazards for the map and updates the state accordingly.
  ///
  /// 1. Immediately renders cached hazards (filtered) within the visible bounds.
  /// 2. Calls the API in the background (no loading indicator).
  /// 3. On response, reconciles the cache for the requested bounds
  ///    and refreshes visible markers.
  Future<void> getMapHazards() async {
    final visibleBoundsResult = await _mapService.getVisibleRegion();
    if (!mounted) return;

    final visibleBounds = visibleBoundsResult.whenSuccess(
      (success) => success,
    );
    if (visibleBounds == null) {
      state = state.copyWith(
        getMapHazardsState: GetMapHazardsState.error(
          AppError(
            message: 'Failed to get visible region bounds.',
          ),
        ),
      );
      return;
    }

    final currentFilterState = _ref.read(providerOfHazardFiltersForMap);

    // Immediately show cached hazards that match the current filters
    final cachedVisible = _getHazardsInBounds(
      visibleBounds,
      currentFilterState,
    );
    state = state.copyWith(hazards: cachedVisible);
    if (cachedVisible.isEmpty) {
      removeAllHazardMarkers();
    } else {
      generateMarkers();
    }

    // Show loading state only on the very first fetch (empty cache)
    if (state.hazardCache.isEmpty) {
      state = state.copyWith(
        getMapHazardsState: const GetMapHazardsState.loading(),
      );
    }

    // Stale request protection
    final currentRequestId = ++_hazardRequestId;

    final selectedCategoryIds = currentFilterState.selectedCategoryIds.toList();
    final awsEmergency = currentFilterState.awsEmergency;
    final awsWatchAndAct = currentFilterState.awsWatchAndAct;
    final awsAdvice = currentFilterState.awsAdvice;
    final officialNonAws = currentFilterState.officialNonAws;
    final userReported = currentFilterState.userReported;

    // Cancel the old requests before making new requests
    if (state.getMapHazardsCancelToken.requestOptions != null) {
      state.getMapHazardsCancelToken.cancel();
      state = state.copyWith(getMapHazardsCancelToken: CancelToken());
    }

    final requestedBounds = visibleBounds;

    final stopwatch = Stopwatch()..start();
    final result = await _hazardService.getAllHazards(
      cancelToken: state.getMapHazardsCancelToken,
      searchParams: HazardSearchParams(
        categoryIds: selectedCategoryIds,
        awsEmergency: awsEmergency,
        awsWatchAndAct: awsWatchAndAct,
        awsAdvice: awsAdvice,
        officialNonAws: officialNonAws,
        userReported: userReported,
        northeastLat: requestedBounds.northeast.latitude,
        northeastLng: requestedBounds.northeast.longitude,
        southwestLat: requestedBounds.southwest.latitude,
        southwestLng: requestedBounds.southwest.longitude,
        ignoreHazardLatLngBounds: true,
        sortSettings: [
          {SortCategory.severityBand: SortOrder.desc},
          {SortCategory.createdAt: SortOrder.desc},
        ],
        pageSize: _pageSize,
      ),
    );
    if (!mounted) return;

    // Discard stale responses
    if (currentRequestId != _hazardRequestId) return;

    result.when(
      (hazards) {
        // Reconcile cache: start from existing cache
        final updatedCache = Map<String, Hazard>.from(state.hazardCache);

        // Build a set of IDs from the API response for fast lookup
        final responseIds = <String>{};
        for (final hazard in hazards) {
          if (hazard.id == null) continue;
          responseIds.add(hazard.id!);
          updatedCache[hazard.id!] = hazard;
        }

        // Only remove in-bounds hazards that match the current filters
        // but are missing from the API response. Hazards that don't match
        // the active filters stay in cache for other filter states.
        updatedCache.removeWhere(
          (id, hazard) =>
              _isInBounds(hazard, requestedBounds) &&
              _matchesFilters(hazard, currentFilterState) &&
              !responseIds.contains(id),
        );
        updateHazardCache(updatedCache);

        final visibleHazards = _getHazardsInBounds(
          requestedBounds,
          currentFilterState,
        );

        log(
          'getAllHazards time: ${stopwatch.elapsedMilliseconds / 1000} seconds, fetched hazards: ${hazards.length}, visibleHazards: ${visibleHazards.length}',
        );

        state = state.copyWith(
          getMapHazardsState: GetMapHazardsState.success(hazards),
          hazards: visibleHazards,
        );

        // Keep the home-screen widget in step with the freshly fetched hazards.
        // Fire-and-forget; failures are swallowed inside HomeWidgetSync.
        HomeWidgetSync.push(_ref, hazards);

        final selectedHazard = visibleHazards.firstWhereOrNull(
          (hazard) => hazard.id == state.selectedHazard?.id,
        );
        if (selectedHazard != null) {
          updateSelectedHazard(selectedHazard);
        }

        for (final hazard in hazards) {
          if (hazard.id == null) continue;
          final hazardItemProvider = providerOfHazardItem(hazard.id!);
          _ref.read(hazardItemProvider.notifier).updateHazard(hazard);
        }

        if (visibleHazards.isEmpty) {
          removeAllHazardMarkers();
        } else {
          generateMarkers();
        }
      },
      (l) {
        state = state.copyWith(
          getMapHazardsState: GetMapHazardsState.error(l),
        );
      },
    );
  }

  /// Fetches route from the map service and updates the state accordingly.
  /// Optionally avoids specified hazards.
  Future<void> getRoutePlan({
    required final AlrtLocation origin,
    required final AlrtLocation destination,
  }) async {
    state = state.copyWith(
      getRouteState: const GetRouteState.loading(),
    );

    final result = await _mapService.getRoutePlan(
      origin: origin,
      destination: destination,
    );
    if (!mounted) return;

    result.when(
      (r) {
        updateCurrentRoutePlan(r);
        state = state.copyWith(
          getRouteState: GetRouteState.success(r),
        );
      },
      (l) {
        state = state.copyWith(
          getRouteState: GetRouteState.error(l),
        );
      },
    );
  }

  /// Fetches hazards to avoid for the current route plan and updates the state accordingly.
  Future<void> getRoutePlanHazardsToAvoid() async {
    if (state.currentRoutePlan == null) return;

    final allRoutes = state.currentRoutePlan?.currentRoute?.allRoutes ?? [];
    if (allRoutes.isEmpty) return;

    final bounds = allRoutes
        .expand(
          (route) => route.polylinePoints!
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList(),
        )
        .toList()
        .toBounds();

    // cancel the old requests before making new requests
    if (state.getHazardsToAvoidCancelToken.requestOptions != null) {
      state.getHazardsToAvoidCancelToken.cancel();
      state = state.copyWith(getHazardsToAvoidCancelToken: CancelToken());
    }

    final result = await _hazardService.getAllHazards(
      cancelToken: state.getHazardsToAvoidCancelToken,
      allowEmptyCategoryIds: true,
      allowAllSourceFiltersFalse: true,
      searchParams: HazardSearchParams(
        northeastLat: bounds.northeast.latitude,
        northeastLng: bounds.northeast.longitude,
        southwestLat: bounds.southwest.latitude,
        southwestLng: bounds.southwest.longitude,
        ignoreHazardLatLngBounds: true,
        sortSettings: [
          {SortCategory.severityBand: SortOrder.desc},
          {SortCategory.createdAt: SortOrder.desc},
        ],
        pageSize: _pageSize,
      ),
    );

    result.whenSuccess(updateHazardsToAvoid);
  }

  /// Fetches address from coordinates using the map service and updates the state accordingly.
  Future<void> getAddressFromCoordinates({
    required final LatLng coordinates,
    final bool getSubUrbOnly = false,
  }) async {
    final isLoading = state.getAddressFromCoordinatesState.maybeWhen(
      orElse: () => false,
      loading: () => true,
    );
    if (isLoading) return;

    state = state.copyWith(
      getAddressFromCoordinatesState:
          const GetAddressFromCoordinatesState.loading(),
    );

    final result = await _mapService.getAddressFromCoordinates(
      coordinates: coordinates,
      getSubUrbOnly: getSubUrbOnly,
    );
    if (!mounted) return;

    result.when(
      (address) {
        final alrtLocation = AlrtLocation(
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          address: address,
        );
        state = state.copyWith(
          getAddressFromCoordinatesState:
              GetAddressFromCoordinatesState.success(alrtLocation),
        );
      },
      (l) {
        state = state.copyWith(
          getAddressFromCoordinatesState: GetAddressFromCoordinatesState.error(
            l,
          ),
        );
      },
    );
  }

  /// Animates the camera to the given [position].
  Future<void> animateTo({
    required final LatLng position,
    final double? zoom,
  }) async {
    await _mapService.animateCamera(
      cameraUpdate: zoom != null
          ? CameraUpdate.newLatLngZoom(position, zoom)
          : CameraUpdate.newLatLng(position),
    );
  }

  /// Centres the map on [position], queueing the move when the map has not
  /// been created yet (e.g. arriving from the family roll call before the
  /// map tab has ever been shown).
  Future<void> focusOnPosition({
    required final LatLng position,
    final double zoom = 16.0,
  }) async {
    final cameraUpdate = CameraUpdate.newLatLngZoom(position, zoom);
    if (!state.isMapReady) {
      state = state.copyWith(pendingCameraUpdateToApply: cameraUpdate);
      return;
    }
    await _mapService.animateCamera(cameraUpdate: cameraUpdate);
  }

  /// Animates the camera to fit within the given [bounds] with optional [padding].
  /// If the map is not ready, stores the bounds to animate to later.
  Future<void> animateToBounds({
    required final LatLngBounds bounds,
    final double padding = 100.0,
  }) async {
    final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, padding);
    if (!state.isMapReady) {
      // If map is not ready, store the bounds for later execution
      state = state.copyWith(
        pendingCameraUpdateToApply: cameraUpdate,
      );
    } else {
      // If map is ready, attempt to animate immediately
      final result = await _mapService.animateCamera(
        cameraUpdate: cameraUpdate,
      );
      if (!mounted) return;

      result.when(
        (success) {
          // Animation succeeded, reset pending bounds
          state = state.copyWith(
            pendingCameraUpdateToApply: null,
          );
        },
        (failure) {
          // If animation fails, queue it
          state = state.copyWith(
            pendingCameraUpdateToApply: cameraUpdate,
          );
        },
      );
    }
  }

  /// Animates the camera using the given [cameraUpdate].
  Future<void> animateToCameraUpdate({
    required final CameraUpdate cameraUpdate,
  }) async {
    await _mapService.animateCamera(
      cameraUpdate: cameraUpdate,
    );
  }

  /// Starts navigation by centering the camera on the user's current location.
  void startNavigation() async {
    final currentRoutePlan = state.currentRoutePlan;
    if (currentRoutePlan == null) return;

    final currentUserLocation = _ref.read(providerOfLocation).location;
    final origin = currentRoutePlan.origin;
    final destination = currentRoutePlan.destination;

    // If origin is different from current user location, get a new route then start navigation
    if (origin != currentUserLocation) {
      await getRoutePlan(
        origin: currentUserLocation,
        destination: destination,
      );
      if (!mounted) return;
    }

    _logStartNavigationSteps();

    // Seed navigation state from the user's last known location so the
    // overlay has populated step / distance / bearing values on its very
    // first build. Without this, the geolocator stream in
    // `_startLocationTracking` (distanceFilter: 5m) can take a long time to
    // emit while the user is stationary, leaving the UI showing "--" for
    // current step, next step, ETA, etc.
    _updateNavigationLocation(currentUserLocation);
    _updateNavigationStep(currentUserLocation);

    updateIsNavigating(true);

    // Seed the hazard corridor list so the alternate-route button can show
    // immediately if the route already overlaps a hazard cluster, instead
    // of waiting for the next GPS tick.
    _recomputeHazardCorridorsAhead();

    final zoom = 18.0;
    final tilt = 20.0;

    final cameraPosition = CameraPosition(
      target: LatLng(
        currentUserLocation.latitude,
        currentUserLocation.longitude,
      ),
      zoom: zoom,
      tilt: tilt,
    );

    updateCameraPosition(
      cameraPosition: cameraPosition,
    );
    animateToCameraUpdate(
      cameraUpdate: CameraUpdate.newCameraPosition(
        cameraPosition,
      ),
    );

    // Start real-time location tracking during navigation
    _startLocationTracking();

    // Start heading updates
    _startHeadingUpdates();
  }

  /// Starts real-time location tracking using position stream
  void _startLocationTracking() {
    _positionStreamSubscription?.cancel();

    // Use high accuracy location settings for navigation
    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // Update every 5 meters
    );

    _positionStreamSubscription = _locationService
        .getPositionStream(locationSettings: locationSettings)
        .listen(
          (position) {
            if (!mounted) return;
            if (state.navigationSimulationEnabled) return;

            final newLocation = AlrtLocation(
              latitude: position.latitude,
              longitude: position.longitude,
              address: 'Your Location',
            );

            _handleLocationUpdate(newLocation);
          },
          onError: (error) {
            log('Location tracking error: $error');
          },
        );
  }

  /// Handles location updates during navigation.
  ///
  /// When [preserveHeadingAndSpeed] is true (cardinal nudge simulation),
  /// bearing and speed are left unchanged so the follow-camera bearing and
  /// zoom tiers do not snap on each arrow tap.
  void _handleLocationUpdate(
    AlrtLocation newLocation, {
    bool preserveHeadingAndSpeed = false,
  }) {
    final currentRoutePlan = state.currentRoutePlan;
    if (currentRoutePlan == null || !currentRoutePlan.isNavigating) return;

    // Update current navigation location and calculate bearing/speed
    _updateNavigationLocation(
      newLocation,
      preserveHeadingAndSpeed: preserveHeadingAndSpeed,
    );

    // Update current step / next step / distance to next maneuver and log
    // any meaningful changes for the upcoming navigation UI to consume.
    _updateNavigationStep(newLocation);

    // Check if destination is reached
    if (_checkDestinationReached(newLocation)) {
      _handleNavigationComplete();
      return;
    }

    // Check if user is off route and trigger rerouting if needed
    _checkAndHandleRerouting(newLocation);

    // Update route polylines to show progress
    addPolylineForRoutePlan();

    // Update user location marker
    // _updateUserLocationMarker(newLocation);

    // Update camera position smoothly
    _updateNavigationCamera(newLocation);

    _syncSimulatedNavigationMarker();

    // Refresh the ahead-of-user hazard corridors so the alternate-route
    // button reflects the user's new position.
    _recomputeHazardCorridorsAhead();
  }

  /// Updates navigation location and calculates speed/bearing
  void _updateNavigationLocation(
    AlrtLocation newLocation, {
    bool preserveHeadingAndSpeed = false,
  }) {
    final previousLocation = state.currentNavigationLocation;

    double bearing = state.currentBearing;
    double speed = state.currentSpeed;

    if (previousLocation != null && !preserveHeadingAndSpeed) {
      speed = _calculateSpeed(previousLocation, newLocation);
      bearing = _calculateBearing(
        LatLng(previousLocation.latitude, previousLocation.longitude),
        LatLng(newLocation.latitude, newLocation.longitude),
      );
    }

    state = state.copyWith(
      currentNavigationLocation: newLocation,
      currentSpeed: speed,
      currentBearing: bearing,
    );
  }

  /// Distance thresholds (meters) at which we re-emit the "approaching the
  /// next maneuver" log. Mirrors how Google Maps announces *"In 500 m..."*,
  /// *"In 200 m..."*, *"Now turn..."*.
  static const List<double> _maneuverAnnouncementThresholdsMeters = [
    500.0,
    200.0,
    50.0,
  ];

  /// Locates the user's current step on the active route, computes the
  /// remaining distance to the next maneuver, and pushes everything into
  /// state.
  ///
  /// Logs are emitted only when the step index advances or the user crosses
  /// one of [_maneuverAnnouncementThresholdsMeters], so the console isn't
  /// flooded by per-tick GPS updates.
  void _updateNavigationStep(AlrtLocation newLocation) {
    final routePlan = state.currentRoutePlan;
    final safestFastest = routePlan?.currentRoute;
    if (safestFastest == null) return;

    final activeRoute = safestFastest.currentRoute;
    final steps = safestFastest.stepsForRoute(activeRoute);
    if (steps.isEmpty) return;

    final userLatLng = LatLng(newLocation.latitude, newLocation.longitude);

    // Pick the step whose polyline (or, if missing, whose start/end segment)
    // is closest to the user. This is robust against GPS noise pushing the
    // user briefly off the next step.
    int? bestStepIndex;
    double bestDistance = double.infinity;
    for (var i = 0; i < steps.length; i++) {
      final distance = _distanceFromUserToStep(userLatLng, steps[i]);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestStepIndex = i;
      }
    }
    if (bestStepIndex == null) return;

    final currentStep = steps[bestStepIndex];
    final nextStep = bestStepIndex + 1 < steps.length
        ? steps[bestStepIndex + 1]
        : null;
    final stepAfterNext = bestStepIndex + 2 < steps.length
        ? steps[bestStepIndex + 2]
        : null;
    final distanceToNextManeuver = _calculateDistanceToStepEnd(
      userLatLng,
      currentStep,
    );

    // Total remaining distance: distance left in the current step plus the
    // full length of every subsequent step.
    var remainingDistance = distanceToNextManeuver;
    for (var i = bestStepIndex + 1; i < steps.length; i++) {
      remainingDistance += steps[i].distanceMeters.toDouble();
    }

    // Total remaining duration: pro-rate the current step's duration by how
    // much of it is left, then add full durations of all subsequent steps.
    final currentStepDistance = currentStep.distanceMeters;
    final currentStepRemainingFraction = currentStepDistance > 0
        ? (distanceToNextManeuver / currentStepDistance).clamp(0.0, 1.0)
        : 0.0;
    var remainingDuration =
        (currentStep.durationSeconds * currentStepRemainingFraction).round();
    for (var i = bestStepIndex + 1; i < steps.length; i++) {
      remainingDuration += steps[i].durationSeconds;
    }

    final previousStepIndex = state.currentStepIndex;
    final previousDistance = state.distanceToNextManeuverMeters;

    state = state.copyWith(
      currentStepIndex: bestStepIndex,
      currentStep: currentStep,
      nextStep: nextStep,
      stepAfterNext: stepAfterNext,
      distanceToNextManeuverMeters: distanceToNextManeuver,
      remainingDistanceMeters: remainingDistance.round(),
      remainingDurationSeconds: remainingDuration,
    );

    final stepChanged = previousStepIndex != bestStepIndex;
    final crossedThreshold = _crossedAnnouncementThreshold(
      previousDistance,
      distanceToNextManeuver,
    );

    if (stepChanged || crossedThreshold) {
      log(
        '[Nav step] #${bestStepIndex + 1}/${steps.length} '
        '[${currentStep.maneuver.name}] ${currentStep.instruction} '
        '(${distanceToNextManeuver.toStringAsFixed(0)} m to next maneuver)',
      );
      log(
        '[Nav step]   Then: '
        '${nextStep == null ? "(arrive)" : "[${nextStep.maneuver.name}] ${nextStep.instruction}"}',
      );
    }
  }

  /// Returns the perpendicular distance, in meters, from [user] to the
  /// closest segment of [step]'s polyline. Falls back to the start->end
  /// segment when the polyline is empty.
  double _distanceFromUserToStep(LatLng user, RouteStep step) {
    final polyline = step.polylinePoints;
    if (polyline.length < 2) {
      return _calculateDistanceToLineSegment(
        user,
        step.startLocation,
        step.endLocation,
      );
    }

    var minDistance = double.infinity;
    for (var i = 0; i < polyline.length - 1; i++) {
      final distance = _calculateDistanceToLineSegment(
        user,
        polyline[i],
        polyline[i + 1],
      );
      if (distance < minDistance) minDistance = distance;
    }
    return minDistance;
  }

  /// Approximates remaining distance from [user] to [step]'s end location by
  /// walking the step polyline forwards from the closest vertex. Falls back
  /// to a straight-line haversine measurement when no polyline is available.
  double _calculateDistanceToStepEnd(LatLng user, RouteStep step) {
    final polyline = step.polylinePoints;
    if (polyline.length < 2) {
      return calculateDistanceInMeters(
        user.latitude,
        user.longitude,
        step.endLocation.latitude,
        step.endLocation.longitude,
      );
    }

    // Find the closest segment to the user, then sum the remaining segment
    // lengths plus the residual distance from the user to the end of that
    // closest segment.
    var minDistance = double.infinity;
    var closestSegmentIndex = 0;
    for (var i = 0; i < polyline.length - 1; i++) {
      final distance = _calculateDistanceToLineSegment(
        user,
        polyline[i],
        polyline[i + 1],
      );
      if (distance < minDistance) {
        minDistance = distance;
        closestSegmentIndex = i;
      }
    }

    var remaining = calculateDistanceInMeters(
      user.latitude,
      user.longitude,
      polyline[closestSegmentIndex + 1].latitude,
      polyline[closestSegmentIndex + 1].longitude,
    );
    for (var i = closestSegmentIndex + 1; i < polyline.length - 1; i++) {
      remaining += calculateDistanceInMeters(
        polyline[i].latitude,
        polyline[i].longitude,
        polyline[i + 1].latitude,
        polyline[i + 1].longitude,
      );
    }
    return remaining;
  }

  /// True iff [current] crossed below any of the announcement thresholds
  /// since the last update represented by [previous].
  bool _crossedAnnouncementThreshold(double? previous, double current) {
    if (previous == null) return true;
    for (final threshold in _maneuverAnnouncementThresholdsMeters) {
      if (previous > threshold && current <= threshold) return true;
    }
    return false;
  }

  /// Calculates speed between two locations in m/s
  double _calculateSpeed(AlrtLocation from, AlrtLocation to) {
    final distance = calculateDistanceInMeters(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );

    // Assume 1 second between updates for speed calculation
    // Apply smoothing to avoid erratic speed readings
    final newSpeed = distance / 1.0; // m/s
    final currentSpeed = state.currentSpeed;

    // Apply simple low-pass filter for smoother speed readings
    const double alpha = 0.3; // Smoothing factor
    return alpha * newSpeed + (1 - alpha) * currentSpeed;
  }

  /// Calculates bearing between two points in degrees (0-360)
  double _calculateBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * (3.14159265359 / 180);
    final lat2 = to.latitude * (3.14159265359 / 180);
    final deltaLng = (to.longitude - from.longitude) * (3.14159265359 / 180);

    final y = sin(deltaLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);

    final bearing = atan2(y, x);
    return (bearing * 180 / 3.14159265359 + 360) % 360;
  }

  /// Toggles whether the camera should follow the user
  void toggleFollowUser() {
    state = state.copyWith(
      followUser: !state.followUser,
    );
  }

  /// Updates or creates a user location marker during navigation
  // ignore: unused_element
  void _updateUserLocationMarker(AlrtLocation location) {
    final userLocationMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: LatLng(location.latitude, location.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(title: 'Your Location'),
      zIndexInt: 10, // Show above route markers
    );

    // Remove existing user location marker and add new one
    final updatedMarkers = Set<Marker>.from(state.markers)
      ..removeWhere((marker) => marker.markerId.value == 'user_location')
      ..add(userLocationMarker);

    updateMarkers(updatedMarkers);
  }

  /// Checks if the destination has been reached
  bool _checkDestinationReached(AlrtLocation currentLocation) {
    final destination = state.currentRoutePlan?.destination;
    if (destination == null) return false;

    const double arrivalThreshold = 20.0; // 20 meters
    final distanceToDestination = calculateDistanceInMeters(
      currentLocation.latitude,
      currentLocation.longitude,
      destination.latitude,
      destination.longitude,
    );

    return distanceToDestination <= arrivalThreshold;
  }

  /// Handles navigation completion
  void _handleNavigationComplete() {
    log('Navigation completed - arrived at destination');

    // Stop navigation after a short delay to show arrival
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        stopNavigation();
        updateCurrentRoutePlan(null); // Clear the route
      }
    });
  }

  /// Checks if user is off route and handles rerouting
  void _checkAndHandleRerouting(AlrtLocation currentLocation) {
    final currentRoutePlan = state.currentRoutePlan;
    if (currentRoutePlan?.currentRoute?.currentRoute.polylinePoints == null) {
      return;
    }

    final routePoints = currentRoutePlan!
        .currentRoute!
        .currentRoute
        .polylinePoints!
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    // Check distance to route
    final userLatLng = LatLng(
      currentLocation.latitude,
      currentLocation.longitude,
    );
    double minDistanceToRoute = double.infinity;

    for (int i = 0; i < routePoints.length - 1; i++) {
      final distance = _calculateDistanceToLineSegment(
        userLatLng,
        routePoints[i],
        routePoints[i + 1],
      );
      if (distance < minDistanceToRoute) {
        minDistanceToRoute = distance;
      }
    }

    // Dynamic rerouting threshold based on travel mode
    final selectedTravelMode = currentRoutePlan.selectedTravelMode;
    double rerouteThreshold = switch (selectedTravelMode) {
      TravelMode.driving => 100.0, // 100m for driving
      TravelMode.walking => 50.0, // 50m for walking
      TravelMode.bicycling => 75.0, // 75m for cycling
      TravelMode.twoWheeler => 75.0, // 75m for two wheeler
      TravelMode.transit => 150.0, // 150m for transit
    };

    // Add some hysteresis to prevent constant rerouting
    if (state.isOffRoute) {
      rerouteThreshold *= 0.7; // Easier to get back on route
    } else {
      rerouteThreshold *= 1.3; // Harder to go off route
    }

    // Update off-route status
    final isOffRoute = minDistanceToRoute > rerouteThreshold;
    if (isOffRoute != state.isOffRoute) {
      state = state.copyWith(isOffRoute: isOffRoute);
    }

    if (minDistanceToRoute > rerouteThreshold) {
      _triggerRerouting(currentLocation);
    }
  }

  /// Triggers automatic rerouting from current location to destination
  void _triggerRerouting(AlrtLocation currentLocation) async {
    final currentRoutePlan = state.currentRoutePlan;
    if (currentRoutePlan?.destination == null) return;

    // Prevent too frequent rerouting
    if (state.getRouteState.maybeWhen(
      orElse: () => false,
      loading: () => true,
    )) {
      return;
    }

    log('User is off route, recalculating...');

    // Get new route from current location to destination
    await getRoutePlan(
      origin: currentLocation,
      destination: currentRoutePlan!.destination,
    );
  }

  void _applySimulationNorthUpCameraFrame(LatLng target) {
    animateToCameraUpdate(
      cameraUpdate: CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: _kSimulationNavigationCameraZoom,
          bearing: _kSimulationNavigationCameraBearing,
          tilt: _kSimulationNavigationCameraTilt,
        ),
      ),
    );
  }

  /// Updates camera position during navigation
  void _updateNavigationCamera(AlrtLocation location) {
    // Only update camera if user following is enabled
    if (!state.followUser) return;

    if (state.navigationSimulationEnabled) {
      final latLng = LatLng(location.latitude, location.longitude);
      if (!_simulationNorthUpCameraFrameApplied) {
        _applySimulationNorthUpCameraFrame(latLng);
        _simulationNorthUpCameraFrameApplied = true;
      } else {
        animateToCameraUpdate(
          cameraUpdate: CameraUpdate.newLatLng(latLng),
        );
      }
      return;
    }

    final currentBearing = state.currentBearing;
    final currentSpeed = state.currentSpeed;

    // Adjust zoom and tilt based on speed for better navigation experience
    double zoom = 18.0;
    double tilt = 30.0;

    if (currentSpeed > 20) {
      // High speed (>72 km/h)
      zoom = 16.0;
      tilt = 45.0;
    } else if (currentSpeed > 10) {
      // Medium speed (>36 km/h)
      zoom = 17.0;
      tilt = 50.0;
    }

    animateToCameraUpdate(
      cameraUpdate: CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: zoom,
          bearing: currentBearing,
          tilt: tilt,
        ),
      ),
    );
  }

  /// Starts heading updates for navigation
  void _startHeadingUpdates() {
    double? lastHeading;
    _headingStreamSubscription?.cancel();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      _headingStreamSubscription = _locationService.getHeadingStream().listen((
        heading,
      ) {
        if (!mounted) return;
        if (state.navigationSimulationEnabled) return;

        if (lastHeading == null || (heading - (lastHeading ?? 0)).abs() > 6) {
          lastHeading = heading;
          final cameraPosition = state.cameraPosition;
          animateToCameraUpdate(
            cameraUpdate: CameraUpdate.newCameraPosition(
              CameraPosition.fromMap({
                ...cameraPosition.toMap() as Map<String, dynamic>,
                'bearing': heading,
              })!,
            ),
          );
        }
      });
    });
  }

  /// Calculates distance from a point to a line segment in meters
  double _calculateDistanceToLineSegment(
    LatLng point,
    LatLng lineStart,
    LatLng lineEnd,
  ) {
    final A = point.latitude - lineStart.latitude;
    final B = point.longitude - lineStart.longitude;
    final C = lineEnd.latitude - lineStart.latitude;
    final D = lineEnd.longitude - lineStart.longitude;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;

    if (lenSq == 0) {
      return calculateDistanceInMeters(
        point.latitude,
        point.longitude,
        lineStart.latitude,
        lineStart.longitude,
      );
    }

    final param = dot / lenSq;
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

    return calculateDistanceInMeters(
      point.latitude,
      point.longitude,
      closestPoint.latitude,
      closestPoint.longitude,
    );
  }

  // ---------------------------------------------------------------------------
  // Hazard-aware alternate route
  // ---------------------------------------------------------------------------

  /// Distance (in meters) within which a hazard is considered to lie on the
  /// active route polyline.
  static const double _kHazardProximityThresholdMeters = 100.0;

  /// Hazards whose pairwise distance is at or below this value collapse into
  /// the same [HazardCorridor] so a single bypass waypoint can route around
  /// the entire group.
  static const double _kHazardClusterDistanceMeters = 100.0;

  /// Buffer (in meters) used when validating that a candidate detour
  /// polyline doesn't graze a forbidden corridor. Slightly larger than
  /// [_kHazardProximityThresholdMeters] so a fresh route hugging the edge
  /// is still rejected.
  static const double _kForbiddenCorridorBufferMeters = 220.0;

  /// Distance (in meters) within which the user is considered to be near the
  /// closest hazard corridor.
  static const double _kUserNearHazardThresholdMeters = 1500.0;

  /// Schedule of (offset meters, side) attempts the [takeAlternateRoute]
  /// orchestrator iterates through. Order alternates side at the same
  /// distance so the first detour found is the shortest viable one.
  static const List<({double offsetMeters, BypassSide side})> _kBypassAttempts =
      [
        (offsetMeters: 200.0, side: BypassSide.right),
        (offsetMeters: 200.0, side: BypassSide.left),
        (offsetMeters: 500.0, side: BypassSide.right),
        (offsetMeters: 500.0, side: BypassSide.left),
        (offsetMeters: 1500.0, side: BypassSide.right),
        (offsetMeters: 1500.0, side: BypassSide.left),
        (offsetMeters: 5000.0, side: BypassSide.right),
        (offsetMeters: 5000.0, side: BypassSide.left),
      ];

  /// Recomputes [MapProviderState.hazardCorridorsAhead] from the current
  /// navigation location, the active route polyline, and the route plan's
  /// `hazardsToAvoid` set.
  ///
  /// Called whenever any of those inputs change (new location, new route,
  /// detour applied, etc.) so the "Take Alternate Route" button visibility
  /// stays in sync.
  void _recomputeHazardCorridorsAhead() {
    final routePlan = state.currentRoutePlan;
    final user = state.currentNavigationLocation;
    final polylinePoints = routePlan?.currentRoute?.currentRoute.polylinePoints;

    if (routePlan == null ||
        !routePlan.isNavigating ||
        user == null ||
        polylinePoints == null ||
        polylinePoints.length < 2) {
      if (state.hazardCorridorsAhead.isNotEmpty ||
          state.isUserNearClosestHazard ||
          state.showTakeAlternateRouteButton) {
        _takeAlternateRouteButtonTimer?.cancel();
        _takeAlternateRouteButtonTimer = null;
        state = state.copyWith(
          hazardCorridorsAhead: const <HazardCorridor>[],
          isUserNearClosestHazard: false,
          showTakeAlternateRouteButton: false,
          lastAlertedHazardId: null,
        );
      }
      return;
    }

    final polyline = polylinePoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);

    final corridors = detectHazardCorridorsAhead(
      user: user,
      polyline: polyline,
      hazards: routePlan.hazardsToAvoid,
      proximityMeters: _kHazardProximityThresholdMeters,
      clusterDistanceMeters: _kHazardClusterDistanceMeters,
      corridorBufferMeters: _kForbiddenCorridorBufferMeters,
    );

    // Calculate if user is within 300m of the closest hazard corridor
    bool isUserNear = false;
    HazardCorridor? closestCorridor;
    if (corridors.isNotEmpty) {
      double minDistance = double.infinity;

      for (final corridor in corridors) {
        final distanceToCenter = calculateDistanceInMeters(
          user.latitude,
          user.longitude,
          corridor.centerPoint.latitude,
          corridor.centerPoint.longitude,
        );
        if (distanceToCenter < minDistance) {
          minDistance = distanceToCenter;
          closestCorridor = corridor;
        }
      }

      isUserNear = minDistance <= _kUserNearHazardThresholdMeters;
    }

    // Determine if we should show the button and manage the timer
    bool shouldShowButton = state.showTakeAlternateRouteButton;
    String? newLastAlertedHazardId = state.lastAlertedHazardId;

    if (isUserNear && closestCorridor != null) {
      // Get the first hazard ID from the closest corridor as its identifier
      final closestHazardId = closestCorridor.hazards.firstOrNull?.id;

      // Check if this is a new/different hazard than the one we last alerted for
      if (closestHazardId != null &&
          closestHazardId != state.lastAlertedHazardId) {
        // New hazard detected - show button and start timer
        shouldShowButton = true;
        newLastAlertedHazardId = closestHazardId;

        // Cancel existing timer and start a new one
        _takeAlternateRouteButtonTimer?.cancel();
        _takeAlternateRouteButtonTimer = Timer(
          const Duration(seconds: 10),
          () {
            if (mounted) {
              state = state.copyWith(showTakeAlternateRouteButton: false);
            }
          },
        );
      }
      // If it's the same hazard, keep the current button state and timer
    } else {
      // User moved away from hazards - hide button and cancel timer
      if (state.showTakeAlternateRouteButton) {
        shouldShowButton = false;
        newLastAlertedHazardId = null;
        _takeAlternateRouteButtonTimer?.cancel();
        _takeAlternateRouteButtonTimer = null;
      }
    }

    state = state.copyWith(
      hazardCorridorsAhead: corridors,
      isUserNearClosestHazard: isUserNear,
      showTakeAlternateRouteButton: shouldShowButton,
      lastAlertedHazardId: newLastAlertedHazardId,
    );
  }

  /// Re-fetches the active route so it bypasses every corridor currently
  /// flagged in [MapProviderState.hazardCorridorsAhead] (plus every
  /// previously avoided corridor in [MapProviderState.forbiddenCorridors]).
  ///
  /// Strategy (Google Routes API doesn't expose "avoid this polygon"):
  /// 1. Build a single bypass waypoint perpendicular to the corridor's
  ///    travel direction, on a chosen side, at a chosen offset.
  /// 2. Ask Routes API for a route that must visit that waypoint.
  /// 3. Validate the returned polyline does not pass through any forbidden
  ///    corridor (with buffer).
  /// 4. If it still does, retry with a different side / wider offset.
  /// 5. On success, swap the active route and remember the corridor so a
  ///    later detour doesn't reuse this same area.
  Future<void> takeAlternateRoute() async {
    if (state.takeAlternateRouteState.isLoading) return;

    final routePlan = state.currentRoutePlan;
    final corridorsAhead = state.hazardCorridorsAhead;
    final currentLocation = state.currentNavigationLocation;

    if (routePlan == null ||
        !routePlan.isNavigating ||
        corridorsAhead.isEmpty ||
        currentLocation == null) {
      return;
    }

    // V1 detours route around the closest corridor ahead. Multi-corridor
    // chaining is intentionally out of scope (see plan); the data model
    // already represents all clusters so it can be added later.
    final targetCorridor = corridorsAhead.first;
    final corridorsToAvoid = <HazardCorridor>[
      ...state.forbiddenCorridors,
      targetCorridor,
    ];
    final destination = routePlan.destination;
    final selectedMode = routePlan.selectedTravelMode;

    // The Routes API rejects `intermediates` for TRANSIT, so a bypass
    // waypoint detour can never succeed on a transit route.
    if (selectedMode == TravelMode.transit) {
      state = state.copyWith(
        takeAlternateRouteState: const TakeAlternateRouteState.error(
          'Detours are not available for transit routes.',
        ),
      );
      return;
    }

    state = state.copyWith(
      takeAlternateRouteState: const TakeAlternateRouteState.loading(),
    );

    log(
      '[Detour] requested for corridor with '
      '${targetCorridor.hazards.length} hazard(s) — trying '
      '${_kBypassAttempts.length} bypass attempt(s)',
    );

    RoutesApiResponse? acceptedResponse;
    Route? acceptedRoute;
    AppError? lastError;

    for (final attempt in _kBypassAttempts) {
      final intermediates = planBypassWaypoints(
        corridor: targetCorridor,
        offsetMeters: attempt.offsetMeters,
        side: attempt.side,
      );

      final result = await _mapService.getRoute(
        origin: LatLng(currentLocation.latitude, currentLocation.longitude),
        destination: destination.latLng,
        travelMode: selectedMode,
        intermediates: intermediates,
      );
      if (!mounted) return;

      RoutesApiResponse? response;
      result.when(
        (r) => response = r,
        (e) => lastError = e,
      );
      if (response == null || response!.routes.isEmpty) continue;

      // Pick the first returned route (alternatives are ordered best-first
      // for the supplied constraints) and validate it.
      for (final route in response!.routes) {
        final points = route.polylinePoints;
        if (points == null || points.isEmpty) continue;

        final candidate = points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(growable: false);

        final crosses = polylineCrossesCorridors(
          candidatePolyline: candidate,
          corridors: corridorsToAvoid,
        );
        if (!crosses) {
          acceptedResponse = response;
          acceptedRoute = route;
          break;
        }
      }
      if (acceptedRoute != null) {
        log(
          '[Detour] accepted attempt offset=${attempt.offsetMeters}m '
          'side=${attempt.side.name}',
        );
        break;
      }
    }

    if (acceptedResponse == null || acceptedRoute == null) {
      log(
        '[Detour] no safe alternate found after ${_kBypassAttempts.length} '
        'attempts (lastError=${lastError?.message})',
      );
      state = state.copyWith(
        takeAlternateRouteState: const TakeAlternateRouteState.error(
          'No safe detour found. Try again or proceed with caution.',
        ),
      );
      return;
    }

    // Build a fresh SafestFastestRoutes for the chosen travel mode using
    // the same parsing pipeline as initial planning so steps + scoring stay
    // consistent.
    final newSafestFastest = _mapService
        .convertRoutesApiResponseToSafestFastestRoutes(
          response: acceptedResponse,
          hazardsToAvoid: routePlan.hazardsToAvoid,
          travelMode: selectedMode,
        );

    if (newSafestFastest == null) {
      state = state.copyWith(
        takeAlternateRouteState: const TakeAlternateRouteState.error(
          'No safe detour found. Try again or proceed with caution.',
        ),
      );
      return;
    }

    // Promote the accepted route to the selected route in the new
    // SafestFastestRoutes (the response may contain other alternatives we
    // already validated against, but only the accepted one is guaranteed
    // safe).
    final detourSafestFastest = newSafestFastest.copyWith(
      selectedRoute: acceptedRoute,
    );

    final newRoutePlan = routePlan.copyWith(
      travelModeRoutes: <TravelMode, SafestFastestRoutes>{
        ...routePlan.travelModeRoutes,
        selectedMode: detourSafestFastest,
      },
    );

    updateCurrentRoutePlan(
      newRoutePlan,
      animateToRouteBounds: false,
    );

    state = state.copyWith(
      forbiddenCorridors: <HazardCorridor>[
        ...state.forbiddenCorridors,
        targetCorridor,
      ],
      takeAlternateRouteState: const TakeAlternateRouteState.idle(),
    );
  }

  /// Stops navigation and cancels heading updates.
  void stopNavigation() {
    _simulationNorthUpCameraFrameApplied = false;
    updateIsNavigating(false);
    _headingStreamSubscription?.cancel();
    _headingStreamSubscription = null;
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _takeAlternateRouteButtonTimer?.cancel();
    _takeAlternateRouteButtonTimer = null;

    // Clear turn-by-turn step tracking so it doesn't leak into the next
    // navigation session.
    state = state.copyWith(
      currentStepIndex: null,
      currentStep: null,
      nextStep: null,
      stepAfterNext: null,
      currentSpeed: 0.0,
      distanceToNextManeuverMeters: null,
      remainingDistanceMeters: null,
      remainingDurationSeconds: null,
      navigationSimulationEnabled: false,
      hazardCorridorsAhead: const <HazardCorridor>[],
      forbiddenCorridors: const <HazardCorridor>[],
      takeAlternateRouteState: const TakeAlternateRouteState.idle(),
      isUserNearClosestHazard: false,
      showTakeAlternateRouteButton: false,
      lastAlertedHazardId: null,
    );

    // Remove user location marker
    _removeUserLocationMarker();
    _removeSimulatedNavigationMarker();
  }

  /// Debug-only: toggles whether GPS is ignored and movement is simulated.
  void toggleNavigationSimulation() {
    if (!kDebugMode) return;
    if (!(state.currentRoutePlan?.isNavigating ?? false)) return;
    final enablingSim = !state.navigationSimulationEnabled;
    state = state.copyWith(
      navigationSimulationEnabled: enablingSim,
    );
    _syncSimulatedNavigationMarker();

    if (!enablingSim) {
      _simulationNorthUpCameraFrameApplied = false;
      return;
    }

    _simulationNorthUpCameraFrameApplied = false;
    final loc = state.currentNavigationLocation;
    if (loc != null && state.followUser) {
      _applySimulationNorthUpCameraFrame(
        LatLng(loc.latitude, loc.longitude),
      );
      _simulationNorthUpCameraFrameApplied = true;
    }
  }

  /// Desk-testing: stable north-up follow camera (no speed-based zoom/tilt).
  static const double _kSimulationNavigationCameraZoom = 18.0;
  static const double _kSimulationNavigationCameraTilt = 0.0;
  static const double _kSimulationNavigationCameraBearing = 0.0;

  static const double _navigationSimulationNudgeMeters = 2.0;
  static const String _kSimulatedNavigationMarkerIdValue =
      'simulated_navigation_location';

  /// Debug-only: move the simulated position by [northMeters] / [eastMeters].
  void simulateNavigationOffsetMeters({
    required double northMeters,
    required double eastMeters,
  }) {
    if (!kDebugMode) return;
    if (!state.navigationSimulationEnabled) return;
    final plan = state.currentRoutePlan;
    if (plan == null || !plan.isNavigating) return;

    final base =
        state.currentNavigationLocation ??
        _ref.read(providerOfLocation).location;
    final nextLatLng = offsetByNorthEastMeters(
      LatLng(base.latitude, base.longitude),
      northMeters,
      eastMeters,
    );
    _handleLocationUpdate(
      AlrtLocation(
        latitude: nextLatLng.latitude,
        longitude: nextLatLng.longitude,
        address: 'Simulated',
      ),
      preserveHeadingAndSpeed: true,
    );
  }

  void simulateNavigationNudgeNorth() => simulateNavigationOffsetMeters(
    northMeters: _navigationSimulationNudgeMeters,
    eastMeters: 0,
  );

  void simulateNavigationNudgeSouth() => simulateNavigationOffsetMeters(
    northMeters: -_navigationSimulationNudgeMeters,
    eastMeters: 0,
  );

  void simulateNavigationNudgeEast() => simulateNavigationOffsetMeters(
    northMeters: 0,
    eastMeters: _navigationSimulationNudgeMeters,
  );

  void simulateNavigationNudgeWest() => simulateNavigationOffsetMeters(
    northMeters: 0,
    eastMeters: -_navigationSimulationNudgeMeters,
  );

  /// Debug-only: advance [meters] along the active route polyline toward the
  /// destination (realistic step progression for desk testing).
  void simulateAdvanceAlongRoute(final double meters) {
    if (!kDebugMode) return;
    if (!state.navigationSimulationEnabled) return;
    final plan = state.currentRoutePlan;
    final safest = plan?.currentRoute;
    if (plan == null || !plan.isNavigating || safest == null) return;

    final polyPoints = safest.currentRoute.polylinePoints;
    if (polyPoints == null || polyPoints.isEmpty) return;

    final polyline = polyPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final base =
        state.currentNavigationLocation ??
        _ref.read(providerOfLocation).location;
    final from = LatLng(base.latitude, base.longitude);

    final nextLatLng = advanceAlongPolylineTowardsEnd(
      polyline: polyline,
      from: from,
      meters: meters,
    );
    if (nextLatLng == null) return;

    _handleLocationUpdate(
      AlrtLocation(
        latitude: nextLatLng.latitude,
        longitude: nextLatLng.longitude,
        address: 'Simulated',
      ),
    );
  }

  /// Debug-only: jump to [latLng] (used with map long-press while sim is on).
  void simulateTeleportToNavigationLocation(final LatLng latLng) {
    if (!kDebugMode) return;
    if (!state.navigationSimulationEnabled) return;
    final plan = state.currentRoutePlan;
    if (plan == null || !plan.isNavigating) return;

    _handleLocationUpdate(
      AlrtLocation(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        address: 'Simulated',
      ),
    );
  }

  /// Dumps the full ordered step list for the route the user is about to
  /// navigate. Mirrors how Google Maps recaps the trip in voice and the
  /// "all steps" sheet at navigation start.
  void _logStartNavigationSteps() {
    final routePlan = state.currentRoutePlan;
    final safestFastest = routePlan?.currentRoute;
    if (routePlan == null || safestFastest == null) return;

    final activeRoute = safestFastest.currentRoute;
    final steps = safestFastest.stepsForRoute(activeRoute);

    log(
      '[Nav start] travelMode=${routePlan.selectedTravelMode.name}, '
      '${steps.length} step(s) for selected route',
    );
    for (var i = 0; i < steps.length; i++) {
      final s = steps[i];
      log(
        '[Nav start]   ${i + 1}. [${s.maneuver.name}] ${s.instruction} '
        '(${s.distanceMeters} m, ${s.durationSeconds}s)',
      );
    }
  }

  /// Removes the user location marker
  void _removeUserLocationMarker() {
    final updatedMarkers = Set<Marker>.from(state.markers)
      ..removeWhere((marker) => marker.markerId.value == 'user_location');
    updateMarkers(updatedMarkers);
  }

  /// Debug-only: shows the simulated navigation position as an Azure pin on
  /// the map (real GPS continues to use the blue-dot pipeline when sim is off).
  void _syncSimulatedNavigationMarker() {
    if (!kDebugMode) {
      _removeSimulatedNavigationMarker();
      return;
    }
    final navigating = state.currentRoutePlan?.isNavigating ?? false;
    final loc = state.currentNavigationLocation;
    if (!navigating || !state.navigationSimulationEnabled || loc == null) {
      _removeSimulatedNavigationMarker();
      return;
    }
    final marker = Marker(
      markerId: MarkerId(_kSimulatedNavigationMarkerIdValue),
      position: LatLng(loc.latitude, loc.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      rotation: state.currentBearing,
      flat: true,
      zIndexInt: 100,
      consumeTapEvents: false,
      infoWindow: const InfoWindow(title: 'Simulated position'),
    );
    final updatedMarkers = Set<Marker>.from(state.markers)
      ..removeWhere(
        (final m) => m.markerId.value == _kSimulatedNavigationMarkerIdValue,
      )
      ..add(marker);
    updateMarkers(updatedMarkers);
  }

  void _removeSimulatedNavigationMarker() {
    if (!state.markers.any(
      (final m) => m.markerId.value == _kSimulatedNavigationMarkerIdValue,
    )) {
      return;
    }
    final updatedMarkers = Set<Marker>.from(state.markers)
      ..removeWhere(
        (final m) => m.markerId.value == _kSimulatedNavigationMarkerIdValue,
      );
    updateMarkers(updatedMarkers);
  }

  /// Toggles navigation state between started and stopped.
  void toggleNavigation() {
    final isNavigating = state.currentRoutePlan?.isNavigating ?? false;
    if (isNavigating) {
      stopNavigation();
    } else {
      startNavigation();
    }
  }

  /// Generates markers for all hazards in the state.
  ///
  /// Below [kClusterMaxZoom] hazards are grouped into screen-space grid
  /// clusters rendered as a count badge tinted by the highest severity in
  /// the group — previously every hazard rendered as its own marker (up to
  /// the full 5000-item page) which made wide zooms unreadable and slow.
  void generateMarkers() async {
    // Exclude hazards whose source system is toggled off in the Map
    // details sheet.
    final visibleAlertSystems = _ref.read(providerOfVisibleAlertSystems);
    // A blocked account is blocked everywhere. The feed already excludes
    // them server-side; the map draws from cached state, so without this
    // a blocked person lingers as a pin after vanishing from the list.
    final blockedIds = _ref.read(providerOfBlockedUserIds);
    final hazards =
        (state.showRouteHazards
                ? state.currentRoutePlan?.hazardsToAvoid ?? <Hazard>[]
                : state.hazards)
            .where(
              (hazard) =>
                  visibleAlertSystems.contains(AlertSourceSystem.of(hazard)) &&
                  !blockedIds.contains(hazard.reportedBy?.id),
            )
            .toList();
    final currentZoom = state.cameraPosition.zoom;
    final individualMarkers = <Marker>[];

    if (currentZoom < kClusterMaxZoom) {
      final clusters = clusterHazards(hazards: hazards, zoom: currentZoom);
      final markerBitmaps = _hazardMarkerBitmapsProviderState.markerBitmaps;

      for (final cluster in clusters) {
        if (cluster.isSingle) {
          final hazard = cluster.single;
          individualMarkers.add(
            Marker(
              markerId: MarkerId(
                'hazard_${hazard.id ?? '${hazard.latitude},${hazard.longitude}'}',
              ),
              position: LatLng(hazard.latitude!, hazard.longitude!),
              onTap: () => _onIndividualMarkerTap(hazard: hazard),
              consumeTapEvents: true,
              icon:
                  await _hazardMarkerBitmap(hazard, markerBitmaps) ??
                  BitmapDescriptor.defaultMarker,
            ),
          );
          continue;
        }

        final clusterBitmap = await _getClusterBitmap(cluster);
        individualMarkers.add(
          Marker(
            markerId: MarkerId(
              'cluster_${cluster.latitude}_${cluster.longitude}_${cluster.count}',
            ),
            position: LatLng(cluster.latitude, cluster.longitude),
            onTap: () => _onClusterMarkerTap(cluster),
            consumeTapEvents: true,
            icon: clusterBitmap ?? BitmapDescriptor.defaultMarker,
          ),
        );
      }
    } else {
      for (final hazard in hazards) {
        if (hazard.latitude == null || hazard.longitude == null) continue;

        final markerBitmaps = _hazardMarkerBitmapsProviderState.markerBitmaps;
        final bitmapDescriptor = await _hazardMarkerBitmap(
          hazard,
          markerBitmaps,
        );

        individualMarkers.add(
          Marker(
            markerId: MarkerId(
              'hazard_${hazard.id ?? '${hazard.latitude},${hazard.longitude}'}',
            ),
            position: LatLng(hazard.latitude!, hazard.longitude!),
            onTap: () => _onIndividualMarkerTap(hazard: hazard),
            consumeTapEvents: true,
            icon: bitmapDescriptor ?? BitmapDescriptor.defaultMarker,
          ),
        );
      }
    }

    // Family members with live locations render as avatar pins.
    final familyMarkers = await _generateFamilyMemberMarkers();

    // Preserve non-hazard markers
    final selectedPlaceMarker = state.markers.firstWhereOrNull(
      (marker) => marker.markerId.value == 'selected_location',
    );
    final routeLabelMarkers = state.markers.where(
      (marker) => marker.markerId.value.startsWith('route_label_'),
    );
    final simulatedNavigationMarker = state.markers.firstWhereOrNull(
      (marker) => marker.markerId.value == _kSimulatedNavigationMarkerIdValue,
    );
    final currentUserLocationMarker = state.markers.firstWhereOrNull(
      (marker) => marker.markerId.value == 'user_location',
    );

    final allMarkers = <Marker>{
      ...individualMarkers,
      ...familyMarkers,
      if (selectedPlaceMarker != null) selectedPlaceMarker,
      ...routeLabelMarkers,
      if (simulatedNavigationMarker != null) simulatedNavigationMarker,
      if (currentUserLocationMarker != null) currentUserLocationMarker,
    };

    updateMarkers(allMarkers);
  }

  /// Cache of member avatar pin bitmaps keyed by member id + initials.
  final Map<String, BitmapDescriptor> _familyPinBitmapCache = {};

  /// The avatar pin shrinks in steps as the camera zooms out, so a city
  /// or country view is not dominated by full-size family circles
  /// (product owner 2026-08-07). Buckets, not a continuous function, so
  /// the bitmap cache stays small and pins do not shimmer on every tick.
  static double _familyPinScaleForZoom(final double zoom) {
    if (zoom >= 14) return 1.0;
    if (zoom >= 12) return 0.85;
    if (zoom >= 10) return 0.68;
    return 0.52;
  }

  /// Builds avatar pins for family members currently sharing a location
  /// (other than the user themself).
  Future<List<Marker>> _generateFamilyMemberMarkers() async {
    try {
      final familyState = _ref.read(providerOfFamily);
      final circle = familyState.circle;
      if (circle == null) return const [];

      final scale = _familyPinScaleForZoom(state.cameraPosition.zoom);

      final markers = <Marker>[];
      for (final member in circle.others) {
        if (!member.hasLiveLocation) continue;

        final cacheKey = '${member.id}_${member.initials}_$scale';
        var bitmap = _familyPinBitmapCache[cacheKey];
        if (bitmap == null) {
          final color = FamilyColors.memberColor(member.id);
          final size = 44.0 * scale;
          final widget = Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3 * scale),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              member.initials,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 15 * scale,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
          );
          bitmap = await widget.toBitmapDescriptor(
            logicalSize: Size(size, size),
            imageSize: Size(size * 2.5, size * 2.5),
          );
          _familyPinBitmapCache[cacheKey] = bitmap;
        }

        markers.add(
          Marker(
            markerId: MarkerId('family_${member.id}'),
            position: LatLng(member.latitude!, member.longitude!),
            icon: bitmap,
            zIndexInt: 2, // keep family pins above hazard markers
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: member.name,
              snippet: member.locationLabel,
            ),
          ),
        );
      }
      return markers;
    } catch (_) {
      // The family layer must never break hazard rendering.
      return const [];
    }
  }

  void _onIndividualMarkerTap({
    required final Hazard hazard,
    final bool isRedDot = false,
  }) {
    if (isRedDot) {
      // At low zoom levels, just zoom in closer to show detailed marker
      animateTo(
        position: LatLng(hazard.latitude!, hazard.longitude!),
        zoom: 8.0,
      );
      return;
    }

    updateSelectedHazard(hazard);

    // Calculate position with offset to create top padding effect
    final markerPosition = LatLng(hazard.latitude!, hazard.longitude!);

    // Calculate consistent visual offset based on zoom level
    // This ensures the marker appears in the same relative position on screen
    // regardless of zoom level (e.g., 30% from the top of the screen)
    final currentZoom = state.cameraPosition.zoom;

    // Calculate latitude degrees per pixel at current zoom level
    // At zoom level z, each tile is 256 pixels and represents 360/(2^z) degrees
    final degreesPerPixel = 360.0 / (256.0 * pow(2, currentZoom));

    // Offset by approximately 150 pixels (adjust this value to fine-tune positioning)
    // This will consistently place the marker about 150 pixels from the top
    final pixelOffset = 120.0;
    final latOffset = degreesPerPixel * pixelOffset;

    final targetPosition = LatLng(
      markerPosition.latitude + latOffset,
      markerPosition.longitude,
    );

    animateTo(position: targetPosition, zoom: currentZoom + 0.01);
  }

  /// Tapping a cluster zooms in towards its centroid to break it apart.
  void _onClusterMarkerTap(final HazardCluster cluster) {
    final currentZoom = state.cameraPosition.zoom;
    final targetZoom = min(currentZoom + 2.5, kClusterMaxZoom + 1.5);
    animateTo(
      position: LatLng(cluster.latitude, cluster.longitude),
      zoom: targetZoom,
    );
  }

  /// Cache of ALRT Intel shield pins, one per band.
  final Map<String, BitmapDescriptor> _intelShieldBitmapCache = {};

  /// The marker for a hazard: the shield for ALRT Intel, the category pin
  /// sets for everything else.
  ///
  /// The pin assets only know AWS vs non-AWS, so without this branch an
  /// intel alert wore an official-style pin on the map while the keys, the
  /// feed and the source chips all showed the shield for the same alert.
  Future<BitmapDescriptor?> _hazardMarkerBitmap(
    final Hazard hazard,
    final Map<String, BitmapDescriptor> markerBitmaps,
  ) async {
    if (hazard.isAlrtIntel) {
      final shield = await _getIntelShieldBitmap(hazard);
      if (shield != null) return shield;
    }
    return hazard.getMarkerBitmapDescriptor(markerBitmaps);
  }

  /// Draws (and caches) the shield pin: the band hex on a white ground so
  /// it reads against the map, same treatment as every other shape —
  /// colour says urgency, the shape says it is ALRT's own assessment.
  Future<BitmapDescriptor?> _getIntelShieldBitmap(final Hazard hazard) async {
    final band = hazard.severityBand ?? HazardSeverityBand.info;
    final cached = _intelShieldBitmapCache[band.name];
    if (cached != null) return cached;

    try {
      final tint = band.colorNonAws;
      const size = 44.0;
      final widget = Stack(
        alignment: Alignment.center,
        children: [
          // White halo so the shape holds against any map tile.
          Icon(LucideIcons.shield, size: size, color: AppColors.white),
          Icon(LucideIcons.shield, size: size - 9, color: tint),
        ],
      );
      final bitmap = await widget.toBitmapDescriptor(
        logicalSize: const Size(size, size),
        imageSize: const Size(size * 2.5, size * 2.5),
      );
      _intelShieldBitmapCache[band.name] = bitmap;
      return bitmap;
    } catch (_) {
      // The intel layer must never break marker rendering.
      return null;
    }
  }

  /// Cache of cluster badge bitmaps keyed by label + severity, so repeated
  /// camera moves don't re-rasterize identical badges.
  final Map<String, BitmapDescriptor> _clusterBitmapCache = {};

  /// Builds (or reuses) the circular count badge for a cluster, tinted by
  /// the highest severity present in the group.
  Future<BitmapDescriptor?> _getClusterBitmap(
    final HazardCluster cluster,
  ) async {
    final severity = cluster.dominantSeverity;
    final badgeColor = switch (severity) {
      HazardSeverity.emergency => AppColors.emergency,
      HazardSeverity.watchAndAct => AppColors.watchAndAct,
      HazardSeverity.advice => AppColors.advice,
      // The quiet end of the scale is the Info grey. Black is not a band,
      // and the key says so.
      _ => AppColors.info,
    };
    final cacheKey = '${cluster.label}_${severity.name}';

    final cached = _clusterBitmapCache[cacheKey];
    if (cached != null) return cached;

    try {
      final size = cluster.count > 20 ? 46.0 : 40.0;
      final widget = Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: badgeColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          cluster.label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      );

      final bitmap = await widget.toBitmapDescriptor(
        logicalSize: Size(size, size),
        imageSize: Size(size * 2.5, size * 2.5),
      );
      _clusterBitmapCache[cacheKey] = bitmap;
      return bitmap;
    } catch (_) {
      return null;
    }
  }

  /// Updates [MapProviderState.isMapReady] to the given [isMapReady].
  void updateIsMapReady(final bool isMapReady) {
    state = state.copyWith(
      isMapReady: isMapReady,
    );
  }

  /// Updates the [MapProviderState.hazards] to the given [hazards].
  void updateHazards(final List<Hazard> hazards) {
    state = state.copyWith(
      hazards: hazards,
    );
  }

  /// Removes a hazard by its [hazardId] from the state and cache.
  void removeFromHazards(final String hazardId) {
    final updatedHazards = state.hazards
        .where((hazard) => hazard.id != hazardId)
        .toList();
    final updatedCache = Map<String, Hazard>.from(
      state.hazardCache,
    )..remove(hazardId);
    updateHazards(updatedHazards);
    updateHazardCache(updatedCache);

    // If the removed hazard was the selected one, clear selection
    if (state.selectedHazard?.id == hazardId) {
      updateSelectedHazard(null);
    }

    // Regenerate markers after removal
    generateMarkers();
  }

  /// Updates the [MapProviderState.hazardCache] to the given [hazardCache].
  void updateHazardCache(final Map<String, Hazard> hazardCache) {
    state = state.copyWith(
      hazardCache: hazardCache,
    );
  }

  /// Updates [MapProviderState.selectedHazard] to the given [hazard].
  void updateSelectedHazard(final Hazard? hazard) {
    state = state.copyWith(
      selectedHazard: hazard,
    );
  }

  /// Updates [MapProviderState.cameraPosition] to the given [cameraPosition].
  void updateCameraPosition({
    required final CameraPosition cameraPosition,
  }) {
    // Family pins are sized by zoom bucket at generation time, but
    // generation otherwise only runs after a hazard fetch — which never
    // happens offline or over an empty viewport. Crossing a bucket
    // regenerates directly so the pins always match the zoom.
    final crossedPinBucket =
        _familyPinScaleForZoom(state.cameraPosition.zoom) !=
        _familyPinScaleForZoom(cameraPosition.zoom);
    state = state.copyWith(
      cameraPosition: cameraPosition,
    );
    if (crossedPinBucket && state.isMapReady) generateMarkers();
  }

  /// Updates [MapProviderState.markers] to the given [markers].
  void updateMarkers(final Set<Marker> markers) {
    state = state.copyWith(
      markers: markers,
    );
  }

  /// Adds a marker to the current set of markers.
  void addToMarkers(final Marker marker) {
    updateMarkers(
      {...state.markers, marker},
    );
  }

  /// Removes all hazard markers from the current set of markers.
  void removeAllHazardMarkers() {
    final updatedMarkers = state.markers
        .where(
          (marker) => !marker.markerId.value.startsWith('hazard_'),
        )
        .toSet();
    updateMarkers(updatedMarkers);
  }

  /// Updates [MapProviderState.polylines] to the given [polylines].
  void updatePolylines(final Set<Polyline> polylines) {
    state = state.copyWith(
      polylines: polylines,
    );
  }

  /// Adds a polyline for current route plan.
  ///
  /// If [animateToBounds] is true, animates the camera to fit the route bounds.
  void addPolylineForRoutePlan({
    final bool animateToBounds = true,
  }) {
    var polylines = <Polyline>{};

    final allRoutes = (state.currentRoutePlan?.currentRoute?.allRoutes ?? []);
    final isNavigating = state.currentRoutePlan?.isNavigating ?? false;

    for (final route in allRoutes) {
      final routePoints = route.polylinePoints!
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();
      if (routePoints.isEmpty) continue;

      final selectedTravelMode = state.currentRoutePlan?.selectedTravelMode;
      if (selectedTravelMode == null) continue;

      final isCurrentRoute =
          state.currentRoutePlan?.currentRoute?.currentRoute == route;

      if (isNavigating && isCurrentRoute) {
        // During navigation, split the route into passed and upcoming segments
        final routeSegments = _createNavigationRouteSegments(routePoints);
        polylines.addAll(routeSegments);
      } else {
        // Normal route display (not navigating or not the current route)
        final polyLine = Polyline(
          polylineId: PolylineId('route_${allRoutes.indexOf(route)}'),
          color: isCurrentRoute
              ? AppColors.darkBlue
              : AppColors.darkBlue.withValues(alpha: 0.3),
          points: routePoints,
          width: isCurrentRoute ? 10 : 8,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          consumeTapEvents: true,
          onTap: () {
            // Update selected route in the current route plan
            handleRouteTap(route);
          },
        );
        polylines.add(polyLine);
      }
    }

    // Update polylines in the state
    updatePolylines(polylines);

    // Add route label markers (only when not navigating)
    if (!isNavigating) {
      addRouteLabelMarkers();
    } else {
      removeRouteLabelMarkers();
    }

    // If not navigating, animate to fit the route bounds
    if (!isNavigating && animateToBounds) {
      final currentRoutePoints =
          state.currentRoutePlan?.currentRoute?.currentRoute.polylinePoints
              ?.map((e) => LatLng(e.latitude, e.longitude))
              .toList() ??
          [];

      if (currentRoutePoints.isNotEmpty) {
        this.animateToBounds(
          bounds: currentRoutePoints.toBounds(),
        );
      }
    }
  }

  /// Handles the tap on a route.
  ///
  /// Updates the current route plan to the given [route].
  void handleRouteTap(final Route route) {
    final selectedTravelMode = state.currentRoutePlan?.selectedTravelMode;
    if (selectedTravelMode == null) return;

    updateCurrentRoutePlan(
      state.currentRoutePlan?.copyWith(
        travelModeRoutes: {
          ...state.currentRoutePlan!.travelModeRoutes,
          selectedTravelMode: state
              .currentRoutePlan!
              .travelModeRoutes[selectedTravelMode]!
              .copyWith(selectedRoute: route),
        },
      ),
      animateToRouteBounds: false,
    );
  }

  /// Creates route segments for navigation with different colors for passed and upcoming parts
  Set<Polyline> _createNavigationRouteSegments(List<LatLng> routePoints) {
    final polylines = <Polyline>{};

    // Get current user location from navigation state
    final currentLocation = state.currentNavigationLocation;
    if (currentLocation == null) {
      // If no current location, show entire route in active color
      polylines.add(
        Polyline(
          polylineId: const PolylineId('active_route'),
          color: AppColors.darkBlue,
          points: routePoints,
          width: 8,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
      return polylines;
    }

    final userLatLng = LatLng(
      currentLocation.latitude,
      currentLocation.longitude,
    );

    // Find the closest point on the route to the user's current location
    int closestSegmentIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < routePoints.length - 1; i++) {
      final distance = _calculateDistanceToLineSegment(
        userLatLng,
        routePoints[i],
        routePoints[i + 1],
      );
      if (distance < minDistance) {
        minDistance = distance;
        closestSegmentIndex = i;
      }
    }

    // Choose colors based on whether user is on route
    final isOffRoute = state.isOffRoute;
    final activeColor = isOffRoute ? AppColors.red : AppColors.darkBlue;
    final passedColor = AppColors.grey.withValues(alpha: 0.6);

    // Create passed route segment (gray/dimmed)
    if (closestSegmentIndex > 0) {
      final passedPoints = routePoints.sublist(0, closestSegmentIndex + 1);
      polylines.add(
        Polyline(
          polylineId: const PolylineId('passed_route'),
          color: passedColor,
          points: passedPoints,
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }

    // Create upcoming route segment (active color - darkBlue if on route, red if off route)
    if (closestSegmentIndex < routePoints.length - 1) {
      final upcomingPoints = routePoints.sublist(closestSegmentIndex);
      polylines.add(
        Polyline(
          polylineId: const PolylineId('upcoming_route'),
          color: activeColor,
          points: upcomingPoints,
          width: 8,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          patterns: isOffRoute
              ? [PatternItem.dash(20), PatternItem.gap(10)]
              : [],
        ),
      );
    }

    return polylines;
  }

  /// Adds route label markers for fastest and safest routes.
  void addRouteLabelMarkers() async {
    final currentRoute = state.currentRoutePlan?.currentRoute;
    if (currentRoute == null) return;

    final routes = currentRoute.allRoutes;
    if (routes.length < 2) return; // No need to add labels if only one route

    final fastestRoute = currentRoute.fastestRoute;
    final safestRoute = currentRoute.safestRoute;

    log('State markers before adding route labels: ${state.markers.length}');

    // Remove existing route label markers
    final updatedMarkers = Set<Marker>.from(state.markers)
      ..removeWhere(
        (marker) => marker.markerId.value.startsWith('route_label_'),
      );

    // Add fastest route marker
    final fastestRoutePoints = fastestRoute.polylinePoints
        ?.map((e) => LatLng(e.latitude, e.longitude))
        .toList();
    if (fastestRoutePoints != null && fastestRoutePoints.isNotEmpty) {
      final fastestMidpoint = fastestRoutePoints.findMidpoint();
      if (fastestMidpoint != null) {
        final fastestMarkerIcon = await RouteLabelMarker(
          label: safestRoute == fastestRoute ? 'Fastest & Safest' : 'Fastest',
          backgroundColor: AppColors.darkBlue,
        ).toBitmapDescriptor();

        updatedMarkers.add(
          Marker(
            markerId: const MarkerId('route_label_fastest'),
            position: fastestMidpoint,
            icon: fastestMarkerIcon,
            zIndexInt: 2,
            anchor: const Offset(
              0.0,
              0.5,
            ), // Anchor at left center so arrow points to route from the side
          ),
        );
      }
    }

    // Add safest route marker (only if different from fastest)
    if (safestRoute != fastestRoute) {
      final safestRoutePoints = safestRoute.polylinePoints
          ?.map((e) => LatLng(e.latitude, e.longitude))
          .toList();
      if (safestRoutePoints != null && safestRoutePoints.isNotEmpty) {
        final safestMidpoint = safestRoutePoints.findMidpoint();
        if (safestMidpoint != null) {
          final safestMarkerIcon = await const RouteLabelMarker(
            label: 'Safest',
            backgroundColor: AppColors.darkBlue,
          ).toBitmapDescriptor();

          updatedMarkers.add(
            Marker(
              markerId: const MarkerId('route_label_safest'),
              position: safestMidpoint,
              icon: safestMarkerIcon,
              zIndexInt: 2,
              anchor: const Offset(
                0.0,
                0.5,
              ), // Anchor at left center so arrow points to route from the side
            ),
          );
        }
      }
    }

    updateMarkers(updatedMarkers);
  }

  /// Removes route label markers from the map.
  void removeRouteLabelMarkers() {
    final updatedMarkers = Set<Marker>.from(state.markers)
      ..removeWhere(
        (marker) => marker.markerId.value.startsWith('route_label_'),
      );
    updateMarkers(updatedMarkers);
  }

  /// Adds a marker for the selected location, replacing any existing selected location marker.
  void addSelectedLocationMarker(final LatLng position) {
    final marker = Marker(
      markerId: const MarkerId('selected_location'),
      position: position,
    );

    // Remove existing selected location marker if any
    final updatedMarkers = Set<Marker>.from(
      state.markers,
    ).where((m) => m.markerId.value != 'selected_location').toSet();

    // Add the new selected location marker
    updatedMarkers.add(marker);

    updateMarkers(updatedMarkers);
  }

  /// Removes the marker for the selected location if it exists.
  void removeSelectedLocationMarker() {
    final updatedMarkers = Set<Marker>.from(
      state.markers,
    ).where((m) => m.markerId.value != 'selected_location').toSet();
    updateMarkers(updatedMarkers);
  }

  /// Updates [MapProviderState.selectedLocation] to the given [location].
  void updateSelectedLocation(final AlrtLocation? location) {
    state = state.copyWith(
      selectedLocation: location,
    );
  }

  /// Updates [MapProviderState.currentRoutePlan] to the given [routePlan].
  ///
  /// If [routePlan] is null, removes existing polylines and route label markers.
  /// If [animateToRouteBounds] is true, animates the camera to fit the route bounds.
  void updateCurrentRoutePlan(
    final RoutePlan? routePlan, {
    final bool animateToRouteBounds = true,
    final bool updatePolylines = true,
  }) {
    state = state.copyWith(
      currentRoutePlan: routePlan,
    );

    if (updatePolylines) {
      if (routePlan == null) {
        this.updatePolylines({});
        removeRouteLabelMarkers();
      } else {
        addPolylineForRoutePlan(
          animateToBounds: animateToRouteBounds,
        );
      }
    }

    // Initial route plan, reroute, and detour-applied cases all flow
    // through here, so this single call keeps the alternate-route button
    // in sync with whichever route is now active.
    _recomputeHazardCorridorsAhead();
  }

  /// Updates [MapProviderState.currentRoutePlan]'s selected travel mode to the given [mode].
  void updateSelectedTravelMode(final TravelMode mode) {
    updateCurrentRoutePlan(
      state.currentRoutePlan?.copyWith(
        selectedTravelMode: mode,
      ),
    );
  }

  /// Updates [MapProviderState.currentRoutePlan]'s hazards to avoid to the given [hazardsToAvoid].
  void updateHazardsToAvoid(final List<Hazard> hazardsToAvoid) {
    updateCurrentRoutePlan(
      state.currentRoutePlan?.copyWith(
        hazardsToAvoid: hazardsToAvoid,
      ),

      // No need to update polylines here as the route itself hasn't changed
      updatePolylines: false,
    );
  }

  /// Updates [MapProviderState.currentRoutePlan]'s isNavigating to the given [isNavigating].
  void updateIsNavigating(final bool isNavigating) {
    updateCurrentRoutePlan(
      state.currentRoutePlan?.copyWith(
        isNavigating: isNavigating,
      ),
    );
  }

  /// Updates [MapProviderState.currentRoutePlan]'s source to the given [source].
  void updateRouteSource(final AlrtLocation source) {
    updateCurrentRoutePlan(
      state.currentRoutePlan?.copyWith(
        origin: source,
      ),
    );
  }

  /// Updates [MapProviderState.currentRoutePlan]'s destination to the given [destination].
  void updateRouteDestination(final AlrtLocation destination) {
    updateCurrentRoutePlan(
      state.currentRoutePlan?.copyWith(
        destination: destination,
      ),
    );
  }

  /// Updates [MapProviderState.showRouteHazards] to the given [showRouteHazards].
  void updateShowRouteHazards(final bool showRouteHazards) {
    state = state.copyWith(
      showRouteHazards: showRouteHazards,
    );
  }

  /// Toggles the route hazards visibility.
  void toggleShowRouteHazards() {
    updateShowRouteHazards(
      !state.showRouteHazards,
    );
  }

  /// Updates [MapProviderState.showTakeAlternateRouteButton] to the given [showTakeAlternateRouteButton].
  void updateShowTakeAlternateRouteButton(
    final bool showTakeAlternateRouteButton,
  ) {
    state = state.copyWith(
      showTakeAlternateRouteButton: showTakeAlternateRouteButton,
    );
  }
}
