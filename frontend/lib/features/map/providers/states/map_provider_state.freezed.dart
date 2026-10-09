// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapProviderState {

/// The cancel token for fetching map hazards.
 CancelToken get getMapHazardsCancelToken;/// The cancel token for fetching hazards to avoid.
 CancelToken get getHazardsToAvoidCancelToken;/// The list of hazards displayed on the map.
 List<Hazard> get hazards;/// The currently selected hazard on the map, if any.
 Hazard? get selectedHazard;/// The current camera position of the map.
 CameraPosition get cameraPosition;/// The set of markers displayed on the map.
 Set<Marker> get markers;/// The cluster manager for hazard markers.
 cluster_manager.ClusterManager? get clusterManager;/// The set of polylines displayed on the map.
 Set<Polyline> get polylines;/// The currently selected location on the map, if any.
 AlrtLocation? get selectedLocation;/// The current route plan, including travel mode and route responses.
 RoutePlan? get currentRoutePlan;/// The state of fetching route.
 GetRouteState get getRouteState;/// The state of fetching address from coordinates.
 GetAddressFromCoordinatesState get getAddressFromCoordinatesState;/// The state of fetching hazards for the map.
 GetMapHazardsState get getMapHazardsState;// Navigation-related fields
/// Current user location during navigation
 AlrtLocation? get currentNavigationLocation;/// Current speed (m/s)
 double get currentSpeed;/// Current bearing/direction in degrees (0-360)
 double get currentBearing;/// Whether the user is off-route
 bool get isOffRoute;/// Camera should follow user during navigation
 bool get followUser;/// Navigation state
 NavigationState get navigationState;/// Whether the map controller is ready for operations
 bool get isMapReady;/// Pending camera update to apply when the map is ready
 CameraUpdate? get pendingCameraUpdateToApply;/// Whether to show route hazards
 bool get showRouteHazards;/// In-memory hazard cache keyed by hazard ID.
 Map<String, Hazard> get hazardCache;// Turn-by-turn navigation step tracking
/// Index of the user's current step within the active route's step list,
/// or `null` when navigation hasn't started or the route has no steps.
 int? get currentStepIndex;/// The step the user is currently traversing.
 RouteStep? get currentStep;/// The next step the user will traverse, or `null` if [currentStep] is the
/// final step (i.e. the user is on the arrival leg).
 RouteStep? get nextStep;/// Remaining distance, in meters, from the user's projected position on
/// [currentStep] to that step's `endLocation` (i.e. the next maneuver).
 double? get distanceToNextManeuverMeters;/// The step after [nextStep], used to render the secondary "THEN" preview
/// in the navigation overlay. `null` when the user is on the second-to-last
/// or last step.
 RouteStep? get stepAfterNext;/// Total remaining distance, in meters, from the user's current position
/// to the destination along the active route.
 int? get remainingDistanceMeters;/// Total remaining duration, in seconds, from the user's current position
/// to the destination along the active route.
 int? get remainingDurationSeconds;/// When true (debug only), GPS updates are ignored and position is driven
/// by simulation controls ([simulateNavigationOffsetMeters], etc.).
 bool get navigationSimulationEnabled;/// Hazard clusters within the proximity threshold of the *remaining*
/// active route polyline, recomputed on each location update. The
/// "Take Alternate Route" button is only shown when this list is
/// non-empty.
 List<HazardCorridor> get hazardCorridorsAhead;/// Corridors a previously accepted detour already routed around. They
/// are kept across the trip so subsequent detours don't reuse a path
/// through an earlier hazard.
 List<HazardCorridor> get forbiddenCorridors;/// State of the "Take Alternate Route" orchestrator (idle / loading /
/// error). Mirrors the [GetRouteState] pattern used elsewhere in this
/// file.
 TakeAlternateRouteState get takeAlternateRouteState;/// Whether the user is within 300m of the closest hazard corridor.
/// Used to control the visibility of the "Take Alternate Route" button.
 bool get isUserNearClosestHazard;/// Whether to show the "Take Alternate Route" button.
/// This is true for 10 seconds after a hazard corridor is first detected,
/// then automatically becomes false. Resets when a different corridor
/// becomes the closest.
 bool get showTakeAlternateRouteButton;/// ID of the hazard in the last alerted corridor, used to determine
/// if a different hazard corridor has become closest (to restart the
/// 10-second display timer).
 String? get lastAlertedHazardId;
/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapProviderStateCopyWith<MapProviderState> get copyWith => _$MapProviderStateCopyWithImpl<MapProviderState>(this as MapProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapProviderState&&(identical(other.getMapHazardsCancelToken, getMapHazardsCancelToken) || other.getMapHazardsCancelToken == getMapHazardsCancelToken)&&(identical(other.getHazardsToAvoidCancelToken, getHazardsToAvoidCancelToken) || other.getHazardsToAvoidCancelToken == getHazardsToAvoidCancelToken)&&const DeepCollectionEquality().equals(other.hazards, hazards)&&(identical(other.selectedHazard, selectedHazard) || other.selectedHazard == selectedHazard)&&(identical(other.cameraPosition, cameraPosition) || other.cameraPosition == cameraPosition)&&const DeepCollectionEquality().equals(other.markers, markers)&&(identical(other.clusterManager, clusterManager) || other.clusterManager == clusterManager)&&const DeepCollectionEquality().equals(other.polylines, polylines)&&(identical(other.selectedLocation, selectedLocation) || other.selectedLocation == selectedLocation)&&(identical(other.currentRoutePlan, currentRoutePlan) || other.currentRoutePlan == currentRoutePlan)&&(identical(other.getRouteState, getRouteState) || other.getRouteState == getRouteState)&&(identical(other.getAddressFromCoordinatesState, getAddressFromCoordinatesState) || other.getAddressFromCoordinatesState == getAddressFromCoordinatesState)&&(identical(other.getMapHazardsState, getMapHazardsState) || other.getMapHazardsState == getMapHazardsState)&&(identical(other.currentNavigationLocation, currentNavigationLocation) || other.currentNavigationLocation == currentNavigationLocation)&&(identical(other.currentSpeed, currentSpeed) || other.currentSpeed == currentSpeed)&&(identical(other.currentBearing, currentBearing) || other.currentBearing == currentBearing)&&(identical(other.isOffRoute, isOffRoute) || other.isOffRoute == isOffRoute)&&(identical(other.followUser, followUser) || other.followUser == followUser)&&(identical(other.navigationState, navigationState) || other.navigationState == navigationState)&&(identical(other.isMapReady, isMapReady) || other.isMapReady == isMapReady)&&(identical(other.pendingCameraUpdateToApply, pendingCameraUpdateToApply) || other.pendingCameraUpdateToApply == pendingCameraUpdateToApply)&&(identical(other.showRouteHazards, showRouteHazards) || other.showRouteHazards == showRouteHazards)&&const DeepCollectionEquality().equals(other.hazardCache, hazardCache)&&(identical(other.currentStepIndex, currentStepIndex) || other.currentStepIndex == currentStepIndex)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.nextStep, nextStep) || other.nextStep == nextStep)&&(identical(other.distanceToNextManeuverMeters, distanceToNextManeuverMeters) || other.distanceToNextManeuverMeters == distanceToNextManeuverMeters)&&(identical(other.stepAfterNext, stepAfterNext) || other.stepAfterNext == stepAfterNext)&&(identical(other.remainingDistanceMeters, remainingDistanceMeters) || other.remainingDistanceMeters == remainingDistanceMeters)&&(identical(other.remainingDurationSeconds, remainingDurationSeconds) || other.remainingDurationSeconds == remainingDurationSeconds)&&(identical(other.navigationSimulationEnabled, navigationSimulationEnabled) || other.navigationSimulationEnabled == navigationSimulationEnabled)&&const DeepCollectionEquality().equals(other.hazardCorridorsAhead, hazardCorridorsAhead)&&const DeepCollectionEquality().equals(other.forbiddenCorridors, forbiddenCorridors)&&(identical(other.takeAlternateRouteState, takeAlternateRouteState) || other.takeAlternateRouteState == takeAlternateRouteState)&&(identical(other.isUserNearClosestHazard, isUserNearClosestHazard) || other.isUserNearClosestHazard == isUserNearClosestHazard)&&(identical(other.showTakeAlternateRouteButton, showTakeAlternateRouteButton) || other.showTakeAlternateRouteButton == showTakeAlternateRouteButton)&&(identical(other.lastAlertedHazardId, lastAlertedHazardId) || other.lastAlertedHazardId == lastAlertedHazardId));
}


@override
int get hashCode => Object.hashAll([runtimeType,getMapHazardsCancelToken,getHazardsToAvoidCancelToken,const DeepCollectionEquality().hash(hazards),selectedHazard,cameraPosition,const DeepCollectionEquality().hash(markers),clusterManager,const DeepCollectionEquality().hash(polylines),selectedLocation,currentRoutePlan,getRouteState,getAddressFromCoordinatesState,getMapHazardsState,currentNavigationLocation,currentSpeed,currentBearing,isOffRoute,followUser,navigationState,isMapReady,pendingCameraUpdateToApply,showRouteHazards,const DeepCollectionEquality().hash(hazardCache),currentStepIndex,currentStep,nextStep,distanceToNextManeuverMeters,stepAfterNext,remainingDistanceMeters,remainingDurationSeconds,navigationSimulationEnabled,const DeepCollectionEquality().hash(hazardCorridorsAhead),const DeepCollectionEquality().hash(forbiddenCorridors),takeAlternateRouteState,isUserNearClosestHazard,showTakeAlternateRouteButton,lastAlertedHazardId]);

@override
String toString() {
  return 'MapProviderState(getMapHazardsCancelToken: $getMapHazardsCancelToken, getHazardsToAvoidCancelToken: $getHazardsToAvoidCancelToken, hazards: $hazards, selectedHazard: $selectedHazard, cameraPosition: $cameraPosition, markers: $markers, clusterManager: $clusterManager, polylines: $polylines, selectedLocation: $selectedLocation, currentRoutePlan: $currentRoutePlan, getRouteState: $getRouteState, getAddressFromCoordinatesState: $getAddressFromCoordinatesState, getMapHazardsState: $getMapHazardsState, currentNavigationLocation: $currentNavigationLocation, currentSpeed: $currentSpeed, currentBearing: $currentBearing, isOffRoute: $isOffRoute, followUser: $followUser, navigationState: $navigationState, isMapReady: $isMapReady, pendingCameraUpdateToApply: $pendingCameraUpdateToApply, showRouteHazards: $showRouteHazards, hazardCache: $hazardCache, currentStepIndex: $currentStepIndex, currentStep: $currentStep, nextStep: $nextStep, distanceToNextManeuverMeters: $distanceToNextManeuverMeters, stepAfterNext: $stepAfterNext, remainingDistanceMeters: $remainingDistanceMeters, remainingDurationSeconds: $remainingDurationSeconds, navigationSimulationEnabled: $navigationSimulationEnabled, hazardCorridorsAhead: $hazardCorridorsAhead, forbiddenCorridors: $forbiddenCorridors, takeAlternateRouteState: $takeAlternateRouteState, isUserNearClosestHazard: $isUserNearClosestHazard, showTakeAlternateRouteButton: $showTakeAlternateRouteButton, lastAlertedHazardId: $lastAlertedHazardId)';
}


}

/// @nodoc
abstract mixin class $MapProviderStateCopyWith<$Res>  {
  factory $MapProviderStateCopyWith(MapProviderState value, $Res Function(MapProviderState) _then) = _$MapProviderStateCopyWithImpl;
@useResult
$Res call({
 CancelToken getMapHazardsCancelToken, CancelToken getHazardsToAvoidCancelToken, List<Hazard> hazards, Hazard? selectedHazard, CameraPosition cameraPosition, Set<Marker> markers, cluster_manager.ClusterManager? clusterManager, Set<Polyline> polylines, AlrtLocation? selectedLocation, RoutePlan? currentRoutePlan, GetRouteState getRouteState, GetAddressFromCoordinatesState getAddressFromCoordinatesState, GetMapHazardsState getMapHazardsState, AlrtLocation? currentNavigationLocation, double currentSpeed, double currentBearing, bool isOffRoute, bool followUser, NavigationState navigationState, bool isMapReady, CameraUpdate? pendingCameraUpdateToApply, bool showRouteHazards, Map<String, Hazard> hazardCache, int? currentStepIndex, RouteStep? currentStep, RouteStep? nextStep, double? distanceToNextManeuverMeters, RouteStep? stepAfterNext, int? remainingDistanceMeters, int? remainingDurationSeconds, bool navigationSimulationEnabled, List<HazardCorridor> hazardCorridorsAhead, List<HazardCorridor> forbiddenCorridors, TakeAlternateRouteState takeAlternateRouteState, bool isUserNearClosestHazard, bool showTakeAlternateRouteButton, String? lastAlertedHazardId
});


$HazardCopyWith<$Res>? get selectedHazard;$AlrtLocationCopyWith<$Res>? get selectedLocation;$RoutePlanCopyWith<$Res>? get currentRoutePlan;$GetRouteStateCopyWith<$Res> get getRouteState;$GetAddressFromCoordinatesStateCopyWith<$Res> get getAddressFromCoordinatesState;$GetMapHazardsStateCopyWith<$Res> get getMapHazardsState;$AlrtLocationCopyWith<$Res>? get currentNavigationLocation;$TakeAlternateRouteStateCopyWith<$Res> get takeAlternateRouteState;

}
/// @nodoc
class _$MapProviderStateCopyWithImpl<$Res>
    implements $MapProviderStateCopyWith<$Res> {
  _$MapProviderStateCopyWithImpl(this._self, this._then);

  final MapProviderState _self;
  final $Res Function(MapProviderState) _then;

/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? getMapHazardsCancelToken = null,Object? getHazardsToAvoidCancelToken = null,Object? hazards = null,Object? selectedHazard = freezed,Object? cameraPosition = null,Object? markers = null,Object? clusterManager = freezed,Object? polylines = null,Object? selectedLocation = freezed,Object? currentRoutePlan = freezed,Object? getRouteState = null,Object? getAddressFromCoordinatesState = null,Object? getMapHazardsState = null,Object? currentNavigationLocation = freezed,Object? currentSpeed = null,Object? currentBearing = null,Object? isOffRoute = null,Object? followUser = null,Object? navigationState = null,Object? isMapReady = null,Object? pendingCameraUpdateToApply = freezed,Object? showRouteHazards = null,Object? hazardCache = null,Object? currentStepIndex = freezed,Object? currentStep = freezed,Object? nextStep = freezed,Object? distanceToNextManeuverMeters = freezed,Object? stepAfterNext = freezed,Object? remainingDistanceMeters = freezed,Object? remainingDurationSeconds = freezed,Object? navigationSimulationEnabled = null,Object? hazardCorridorsAhead = null,Object? forbiddenCorridors = null,Object? takeAlternateRouteState = null,Object? isUserNearClosestHazard = null,Object? showTakeAlternateRouteButton = null,Object? lastAlertedHazardId = freezed,}) {
  return _then(_self.copyWith(
getMapHazardsCancelToken: null == getMapHazardsCancelToken ? _self.getMapHazardsCancelToken : getMapHazardsCancelToken // ignore: cast_nullable_to_non_nullable
as CancelToken,getHazardsToAvoidCancelToken: null == getHazardsToAvoidCancelToken ? _self.getHazardsToAvoidCancelToken : getHazardsToAvoidCancelToken // ignore: cast_nullable_to_non_nullable
as CancelToken,hazards: null == hazards ? _self.hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,selectedHazard: freezed == selectedHazard ? _self.selectedHazard : selectedHazard // ignore: cast_nullable_to_non_nullable
as Hazard?,cameraPosition: null == cameraPosition ? _self.cameraPosition : cameraPosition // ignore: cast_nullable_to_non_nullable
as CameraPosition,markers: null == markers ? _self.markers : markers // ignore: cast_nullable_to_non_nullable
as Set<Marker>,clusterManager: freezed == clusterManager ? _self.clusterManager : clusterManager // ignore: cast_nullable_to_non_nullable
as cluster_manager.ClusterManager?,polylines: null == polylines ? _self.polylines : polylines // ignore: cast_nullable_to_non_nullable
as Set<Polyline>,selectedLocation: freezed == selectedLocation ? _self.selectedLocation : selectedLocation // ignore: cast_nullable_to_non_nullable
as AlrtLocation?,currentRoutePlan: freezed == currentRoutePlan ? _self.currentRoutePlan : currentRoutePlan // ignore: cast_nullable_to_non_nullable
as RoutePlan?,getRouteState: null == getRouteState ? _self.getRouteState : getRouteState // ignore: cast_nullable_to_non_nullable
as GetRouteState,getAddressFromCoordinatesState: null == getAddressFromCoordinatesState ? _self.getAddressFromCoordinatesState : getAddressFromCoordinatesState // ignore: cast_nullable_to_non_nullable
as GetAddressFromCoordinatesState,getMapHazardsState: null == getMapHazardsState ? _self.getMapHazardsState : getMapHazardsState // ignore: cast_nullable_to_non_nullable
as GetMapHazardsState,currentNavigationLocation: freezed == currentNavigationLocation ? _self.currentNavigationLocation : currentNavigationLocation // ignore: cast_nullable_to_non_nullable
as AlrtLocation?,currentSpeed: null == currentSpeed ? _self.currentSpeed : currentSpeed // ignore: cast_nullable_to_non_nullable
as double,currentBearing: null == currentBearing ? _self.currentBearing : currentBearing // ignore: cast_nullable_to_non_nullable
as double,isOffRoute: null == isOffRoute ? _self.isOffRoute : isOffRoute // ignore: cast_nullable_to_non_nullable
as bool,followUser: null == followUser ? _self.followUser : followUser // ignore: cast_nullable_to_non_nullable
as bool,navigationState: null == navigationState ? _self.navigationState : navigationState // ignore: cast_nullable_to_non_nullable
as NavigationState,isMapReady: null == isMapReady ? _self.isMapReady : isMapReady // ignore: cast_nullable_to_non_nullable
as bool,pendingCameraUpdateToApply: freezed == pendingCameraUpdateToApply ? _self.pendingCameraUpdateToApply : pendingCameraUpdateToApply // ignore: cast_nullable_to_non_nullable
as CameraUpdate?,showRouteHazards: null == showRouteHazards ? _self.showRouteHazards : showRouteHazards // ignore: cast_nullable_to_non_nullable
as bool,hazardCache: null == hazardCache ? _self.hazardCache : hazardCache // ignore: cast_nullable_to_non_nullable
as Map<String, Hazard>,currentStepIndex: freezed == currentStepIndex ? _self.currentStepIndex : currentStepIndex // ignore: cast_nullable_to_non_nullable
as int?,currentStep: freezed == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as RouteStep?,nextStep: freezed == nextStep ? _self.nextStep : nextStep // ignore: cast_nullable_to_non_nullable
as RouteStep?,distanceToNextManeuverMeters: freezed == distanceToNextManeuverMeters ? _self.distanceToNextManeuverMeters : distanceToNextManeuverMeters // ignore: cast_nullable_to_non_nullable
as double?,stepAfterNext: freezed == stepAfterNext ? _self.stepAfterNext : stepAfterNext // ignore: cast_nullable_to_non_nullable
as RouteStep?,remainingDistanceMeters: freezed == remainingDistanceMeters ? _self.remainingDistanceMeters : remainingDistanceMeters // ignore: cast_nullable_to_non_nullable
as int?,remainingDurationSeconds: freezed == remainingDurationSeconds ? _self.remainingDurationSeconds : remainingDurationSeconds // ignore: cast_nullable_to_non_nullable
as int?,navigationSimulationEnabled: null == navigationSimulationEnabled ? _self.navigationSimulationEnabled : navigationSimulationEnabled // ignore: cast_nullable_to_non_nullable
as bool,hazardCorridorsAhead: null == hazardCorridorsAhead ? _self.hazardCorridorsAhead : hazardCorridorsAhead // ignore: cast_nullable_to_non_nullable
as List<HazardCorridor>,forbiddenCorridors: null == forbiddenCorridors ? _self.forbiddenCorridors : forbiddenCorridors // ignore: cast_nullable_to_non_nullable
as List<HazardCorridor>,takeAlternateRouteState: null == takeAlternateRouteState ? _self.takeAlternateRouteState : takeAlternateRouteState // ignore: cast_nullable_to_non_nullable
as TakeAlternateRouteState,isUserNearClosestHazard: null == isUserNearClosestHazard ? _self.isUserNearClosestHazard : isUserNearClosestHazard // ignore: cast_nullable_to_non_nullable
as bool,showTakeAlternateRouteButton: null == showTakeAlternateRouteButton ? _self.showTakeAlternateRouteButton : showTakeAlternateRouteButton // ignore: cast_nullable_to_non_nullable
as bool,lastAlertedHazardId: freezed == lastAlertedHazardId ? _self.lastAlertedHazardId : lastAlertedHazardId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HazardCopyWith<$Res>? get selectedHazard {
    if (_self.selectedHazard == null) {
    return null;
  }

  return $HazardCopyWith<$Res>(_self.selectedHazard!, (value) {
    return _then(_self.copyWith(selectedHazard: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res>? get selectedLocation {
    if (_self.selectedLocation == null) {
    return null;
  }

  return $AlrtLocationCopyWith<$Res>(_self.selectedLocation!, (value) {
    return _then(_self.copyWith(selectedLocation: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutePlanCopyWith<$Res>? get currentRoutePlan {
    if (_self.currentRoutePlan == null) {
    return null;
  }

  return $RoutePlanCopyWith<$Res>(_self.currentRoutePlan!, (value) {
    return _then(_self.copyWith(currentRoutePlan: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetRouteStateCopyWith<$Res> get getRouteState {
  
  return $GetRouteStateCopyWith<$Res>(_self.getRouteState, (value) {
    return _then(_self.copyWith(getRouteState: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetAddressFromCoordinatesStateCopyWith<$Res> get getAddressFromCoordinatesState {
  
  return $GetAddressFromCoordinatesStateCopyWith<$Res>(_self.getAddressFromCoordinatesState, (value) {
    return _then(_self.copyWith(getAddressFromCoordinatesState: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetMapHazardsStateCopyWith<$Res> get getMapHazardsState {
  
  return $GetMapHazardsStateCopyWith<$Res>(_self.getMapHazardsState, (value) {
    return _then(_self.copyWith(getMapHazardsState: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res>? get currentNavigationLocation {
    if (_self.currentNavigationLocation == null) {
    return null;
  }

  return $AlrtLocationCopyWith<$Res>(_self.currentNavigationLocation!, (value) {
    return _then(_self.copyWith(currentNavigationLocation: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TakeAlternateRouteStateCopyWith<$Res> get takeAlternateRouteState {
  
  return $TakeAlternateRouteStateCopyWith<$Res>(_self.takeAlternateRouteState, (value) {
    return _then(_self.copyWith(takeAlternateRouteState: value));
  });
}
}


/// Adds pattern-matching-related methods to [MapProviderState].
extension MapProviderStatePatterns on MapProviderState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapProviderState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapProviderState value)  $default,){
final _that = this;
switch (_that) {
case _MapProviderState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _MapProviderState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CancelToken getMapHazardsCancelToken,  CancelToken getHazardsToAvoidCancelToken,  List<Hazard> hazards,  Hazard? selectedHazard,  CameraPosition cameraPosition,  Set<Marker> markers,  cluster_manager.ClusterManager? clusterManager,  Set<Polyline> polylines,  AlrtLocation? selectedLocation,  RoutePlan? currentRoutePlan,  GetRouteState getRouteState,  GetAddressFromCoordinatesState getAddressFromCoordinatesState,  GetMapHazardsState getMapHazardsState,  AlrtLocation? currentNavigationLocation,  double currentSpeed,  double currentBearing,  bool isOffRoute,  bool followUser,  NavigationState navigationState,  bool isMapReady,  CameraUpdate? pendingCameraUpdateToApply,  bool showRouteHazards,  Map<String, Hazard> hazardCache,  int? currentStepIndex,  RouteStep? currentStep,  RouteStep? nextStep,  double? distanceToNextManeuverMeters,  RouteStep? stepAfterNext,  int? remainingDistanceMeters,  int? remainingDurationSeconds,  bool navigationSimulationEnabled,  List<HazardCorridor> hazardCorridorsAhead,  List<HazardCorridor> forbiddenCorridors,  TakeAlternateRouteState takeAlternateRouteState,  bool isUserNearClosestHazard,  bool showTakeAlternateRouteButton,  String? lastAlertedHazardId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapProviderState() when $default != null:
return $default(_that.getMapHazardsCancelToken,_that.getHazardsToAvoidCancelToken,_that.hazards,_that.selectedHazard,_that.cameraPosition,_that.markers,_that.clusterManager,_that.polylines,_that.selectedLocation,_that.currentRoutePlan,_that.getRouteState,_that.getAddressFromCoordinatesState,_that.getMapHazardsState,_that.currentNavigationLocation,_that.currentSpeed,_that.currentBearing,_that.isOffRoute,_that.followUser,_that.navigationState,_that.isMapReady,_that.pendingCameraUpdateToApply,_that.showRouteHazards,_that.hazardCache,_that.currentStepIndex,_that.currentStep,_that.nextStep,_that.distanceToNextManeuverMeters,_that.stepAfterNext,_that.remainingDistanceMeters,_that.remainingDurationSeconds,_that.navigationSimulationEnabled,_that.hazardCorridorsAhead,_that.forbiddenCorridors,_that.takeAlternateRouteState,_that.isUserNearClosestHazard,_that.showTakeAlternateRouteButton,_that.lastAlertedHazardId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CancelToken getMapHazardsCancelToken,  CancelToken getHazardsToAvoidCancelToken,  List<Hazard> hazards,  Hazard? selectedHazard,  CameraPosition cameraPosition,  Set<Marker> markers,  cluster_manager.ClusterManager? clusterManager,  Set<Polyline> polylines,  AlrtLocation? selectedLocation,  RoutePlan? currentRoutePlan,  GetRouteState getRouteState,  GetAddressFromCoordinatesState getAddressFromCoordinatesState,  GetMapHazardsState getMapHazardsState,  AlrtLocation? currentNavigationLocation,  double currentSpeed,  double currentBearing,  bool isOffRoute,  bool followUser,  NavigationState navigationState,  bool isMapReady,  CameraUpdate? pendingCameraUpdateToApply,  bool showRouteHazards,  Map<String, Hazard> hazardCache,  int? currentStepIndex,  RouteStep? currentStep,  RouteStep? nextStep,  double? distanceToNextManeuverMeters,  RouteStep? stepAfterNext,  int? remainingDistanceMeters,  int? remainingDurationSeconds,  bool navigationSimulationEnabled,  List<HazardCorridor> hazardCorridorsAhead,  List<HazardCorridor> forbiddenCorridors,  TakeAlternateRouteState takeAlternateRouteState,  bool isUserNearClosestHazard,  bool showTakeAlternateRouteButton,  String? lastAlertedHazardId)  $default,) {final _that = this;
switch (_that) {
case _MapProviderState():
return $default(_that.getMapHazardsCancelToken,_that.getHazardsToAvoidCancelToken,_that.hazards,_that.selectedHazard,_that.cameraPosition,_that.markers,_that.clusterManager,_that.polylines,_that.selectedLocation,_that.currentRoutePlan,_that.getRouteState,_that.getAddressFromCoordinatesState,_that.getMapHazardsState,_that.currentNavigationLocation,_that.currentSpeed,_that.currentBearing,_that.isOffRoute,_that.followUser,_that.navigationState,_that.isMapReady,_that.pendingCameraUpdateToApply,_that.showRouteHazards,_that.hazardCache,_that.currentStepIndex,_that.currentStep,_that.nextStep,_that.distanceToNextManeuverMeters,_that.stepAfterNext,_that.remainingDistanceMeters,_that.remainingDurationSeconds,_that.navigationSimulationEnabled,_that.hazardCorridorsAhead,_that.forbiddenCorridors,_that.takeAlternateRouteState,_that.isUserNearClosestHazard,_that.showTakeAlternateRouteButton,_that.lastAlertedHazardId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CancelToken getMapHazardsCancelToken,  CancelToken getHazardsToAvoidCancelToken,  List<Hazard> hazards,  Hazard? selectedHazard,  CameraPosition cameraPosition,  Set<Marker> markers,  cluster_manager.ClusterManager? clusterManager,  Set<Polyline> polylines,  AlrtLocation? selectedLocation,  RoutePlan? currentRoutePlan,  GetRouteState getRouteState,  GetAddressFromCoordinatesState getAddressFromCoordinatesState,  GetMapHazardsState getMapHazardsState,  AlrtLocation? currentNavigationLocation,  double currentSpeed,  double currentBearing,  bool isOffRoute,  bool followUser,  NavigationState navigationState,  bool isMapReady,  CameraUpdate? pendingCameraUpdateToApply,  bool showRouteHazards,  Map<String, Hazard> hazardCache,  int? currentStepIndex,  RouteStep? currentStep,  RouteStep? nextStep,  double? distanceToNextManeuverMeters,  RouteStep? stepAfterNext,  int? remainingDistanceMeters,  int? remainingDurationSeconds,  bool navigationSimulationEnabled,  List<HazardCorridor> hazardCorridorsAhead,  List<HazardCorridor> forbiddenCorridors,  TakeAlternateRouteState takeAlternateRouteState,  bool isUserNearClosestHazard,  bool showTakeAlternateRouteButton,  String? lastAlertedHazardId)?  $default,) {final _that = this;
switch (_that) {
case _MapProviderState() when $default != null:
return $default(_that.getMapHazardsCancelToken,_that.getHazardsToAvoidCancelToken,_that.hazards,_that.selectedHazard,_that.cameraPosition,_that.markers,_that.clusterManager,_that.polylines,_that.selectedLocation,_that.currentRoutePlan,_that.getRouteState,_that.getAddressFromCoordinatesState,_that.getMapHazardsState,_that.currentNavigationLocation,_that.currentSpeed,_that.currentBearing,_that.isOffRoute,_that.followUser,_that.navigationState,_that.isMapReady,_that.pendingCameraUpdateToApply,_that.showRouteHazards,_that.hazardCache,_that.currentStepIndex,_that.currentStep,_that.nextStep,_that.distanceToNextManeuverMeters,_that.stepAfterNext,_that.remainingDistanceMeters,_that.remainingDurationSeconds,_that.navigationSimulationEnabled,_that.hazardCorridorsAhead,_that.forbiddenCorridors,_that.takeAlternateRouteState,_that.isUserNearClosestHazard,_that.showTakeAlternateRouteButton,_that.lastAlertedHazardId);case _:
  return null;

}
}

}

/// @nodoc


class _MapProviderState implements MapProviderState {
  const _MapProviderState({required this.getMapHazardsCancelToken, required this.getHazardsToAvoidCancelToken, final  List<Hazard> hazards = const <Hazard>[], this.selectedHazard, this.cameraPosition = kDefaultCameraPosition, final  Set<Marker> markers = const <Marker>{}, this.clusterManager, final  Set<Polyline> polylines = const <Polyline>{}, this.selectedLocation, this.currentRoutePlan, this.getRouteState = const GetRouteState.initial(), this.getAddressFromCoordinatesState = const GetAddressFromCoordinatesState.initial(), this.getMapHazardsState = const GetMapHazardsState.initial(), this.currentNavigationLocation, this.currentSpeed = 0.0, this.currentBearing = 0.0, this.isOffRoute = false, this.followUser = true, this.navigationState = NavigationState.idle, this.isMapReady = false, this.pendingCameraUpdateToApply, this.showRouteHazards = false, final  Map<String, Hazard> hazardCache = const <String, Hazard>{}, this.currentStepIndex, this.currentStep, this.nextStep, this.distanceToNextManeuverMeters, this.stepAfterNext, this.remainingDistanceMeters, this.remainingDurationSeconds, this.navigationSimulationEnabled = false, final  List<HazardCorridor> hazardCorridorsAhead = const <HazardCorridor>[], final  List<HazardCorridor> forbiddenCorridors = const <HazardCorridor>[], this.takeAlternateRouteState = const TakeAlternateRouteState.idle(), this.isUserNearClosestHazard = false, this.showTakeAlternateRouteButton = false, this.lastAlertedHazardId}): _hazards = hazards,_markers = markers,_polylines = polylines,_hazardCache = hazardCache,_hazardCorridorsAhead = hazardCorridorsAhead,_forbiddenCorridors = forbiddenCorridors;
  

/// The cancel token for fetching map hazards.
@override final  CancelToken getMapHazardsCancelToken;
/// The cancel token for fetching hazards to avoid.
@override final  CancelToken getHazardsToAvoidCancelToken;
/// The list of hazards displayed on the map.
 final  List<Hazard> _hazards;
/// The list of hazards displayed on the map.
@override@JsonKey() List<Hazard> get hazards {
  if (_hazards is EqualUnmodifiableListView) return _hazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazards);
}

/// The currently selected hazard on the map, if any.
@override final  Hazard? selectedHazard;
/// The current camera position of the map.
@override@JsonKey() final  CameraPosition cameraPosition;
/// The set of markers displayed on the map.
 final  Set<Marker> _markers;
/// The set of markers displayed on the map.
@override@JsonKey() Set<Marker> get markers {
  if (_markers is EqualUnmodifiableSetView) return _markers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_markers);
}

/// The cluster manager for hazard markers.
@override final  cluster_manager.ClusterManager? clusterManager;
/// The set of polylines displayed on the map.
 final  Set<Polyline> _polylines;
/// The set of polylines displayed on the map.
@override@JsonKey() Set<Polyline> get polylines {
  if (_polylines is EqualUnmodifiableSetView) return _polylines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_polylines);
}

/// The currently selected location on the map, if any.
@override final  AlrtLocation? selectedLocation;
/// The current route plan, including travel mode and route responses.
@override final  RoutePlan? currentRoutePlan;
/// The state of fetching route.
@override@JsonKey() final  GetRouteState getRouteState;
/// The state of fetching address from coordinates.
@override@JsonKey() final  GetAddressFromCoordinatesState getAddressFromCoordinatesState;
/// The state of fetching hazards for the map.
@override@JsonKey() final  GetMapHazardsState getMapHazardsState;
// Navigation-related fields
/// Current user location during navigation
@override final  AlrtLocation? currentNavigationLocation;
/// Current speed (m/s)
@override@JsonKey() final  double currentSpeed;
/// Current bearing/direction in degrees (0-360)
@override@JsonKey() final  double currentBearing;
/// Whether the user is off-route
@override@JsonKey() final  bool isOffRoute;
/// Camera should follow user during navigation
@override@JsonKey() final  bool followUser;
/// Navigation state
@override@JsonKey() final  NavigationState navigationState;
/// Whether the map controller is ready for operations
@override@JsonKey() final  bool isMapReady;
/// Pending camera update to apply when the map is ready
@override final  CameraUpdate? pendingCameraUpdateToApply;
/// Whether to show route hazards
@override@JsonKey() final  bool showRouteHazards;
/// In-memory hazard cache keyed by hazard ID.
 final  Map<String, Hazard> _hazardCache;
/// In-memory hazard cache keyed by hazard ID.
@override@JsonKey() Map<String, Hazard> get hazardCache {
  if (_hazardCache is EqualUnmodifiableMapView) return _hazardCache;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hazardCache);
}

// Turn-by-turn navigation step tracking
/// Index of the user's current step within the active route's step list,
/// or `null` when navigation hasn't started or the route has no steps.
@override final  int? currentStepIndex;
/// The step the user is currently traversing.
@override final  RouteStep? currentStep;
/// The next step the user will traverse, or `null` if [currentStep] is the
/// final step (i.e. the user is on the arrival leg).
@override final  RouteStep? nextStep;
/// Remaining distance, in meters, from the user's projected position on
/// [currentStep] to that step's `endLocation` (i.e. the next maneuver).
@override final  double? distanceToNextManeuverMeters;
/// The step after [nextStep], used to render the secondary "THEN" preview
/// in the navigation overlay. `null` when the user is on the second-to-last
/// or last step.
@override final  RouteStep? stepAfterNext;
/// Total remaining distance, in meters, from the user's current position
/// to the destination along the active route.
@override final  int? remainingDistanceMeters;
/// Total remaining duration, in seconds, from the user's current position
/// to the destination along the active route.
@override final  int? remainingDurationSeconds;
/// When true (debug only), GPS updates are ignored and position is driven
/// by simulation controls ([simulateNavigationOffsetMeters], etc.).
@override@JsonKey() final  bool navigationSimulationEnabled;
/// Hazard clusters within the proximity threshold of the *remaining*
/// active route polyline, recomputed on each location update. The
/// "Take Alternate Route" button is only shown when this list is
/// non-empty.
 final  List<HazardCorridor> _hazardCorridorsAhead;
/// Hazard clusters within the proximity threshold of the *remaining*
/// active route polyline, recomputed on each location update. The
/// "Take Alternate Route" button is only shown when this list is
/// non-empty.
@override@JsonKey() List<HazardCorridor> get hazardCorridorsAhead {
  if (_hazardCorridorsAhead is EqualUnmodifiableListView) return _hazardCorridorsAhead;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazardCorridorsAhead);
}

/// Corridors a previously accepted detour already routed around. They
/// are kept across the trip so subsequent detours don't reuse a path
/// through an earlier hazard.
 final  List<HazardCorridor> _forbiddenCorridors;
/// Corridors a previously accepted detour already routed around. They
/// are kept across the trip so subsequent detours don't reuse a path
/// through an earlier hazard.
@override@JsonKey() List<HazardCorridor> get forbiddenCorridors {
  if (_forbiddenCorridors is EqualUnmodifiableListView) return _forbiddenCorridors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_forbiddenCorridors);
}

/// State of the "Take Alternate Route" orchestrator (idle / loading /
/// error). Mirrors the [GetRouteState] pattern used elsewhere in this
/// file.
@override@JsonKey() final  TakeAlternateRouteState takeAlternateRouteState;
/// Whether the user is within 300m of the closest hazard corridor.
/// Used to control the visibility of the "Take Alternate Route" button.
@override@JsonKey() final  bool isUserNearClosestHazard;
/// Whether to show the "Take Alternate Route" button.
/// This is true for 10 seconds after a hazard corridor is first detected,
/// then automatically becomes false. Resets when a different corridor
/// becomes the closest.
@override@JsonKey() final  bool showTakeAlternateRouteButton;
/// ID of the hazard in the last alerted corridor, used to determine
/// if a different hazard corridor has become closest (to restart the
/// 10-second display timer).
@override final  String? lastAlertedHazardId;

/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapProviderStateCopyWith<_MapProviderState> get copyWith => __$MapProviderStateCopyWithImpl<_MapProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapProviderState&&(identical(other.getMapHazardsCancelToken, getMapHazardsCancelToken) || other.getMapHazardsCancelToken == getMapHazardsCancelToken)&&(identical(other.getHazardsToAvoidCancelToken, getHazardsToAvoidCancelToken) || other.getHazardsToAvoidCancelToken == getHazardsToAvoidCancelToken)&&const DeepCollectionEquality().equals(other._hazards, _hazards)&&(identical(other.selectedHazard, selectedHazard) || other.selectedHazard == selectedHazard)&&(identical(other.cameraPosition, cameraPosition) || other.cameraPosition == cameraPosition)&&const DeepCollectionEquality().equals(other._markers, _markers)&&(identical(other.clusterManager, clusterManager) || other.clusterManager == clusterManager)&&const DeepCollectionEquality().equals(other._polylines, _polylines)&&(identical(other.selectedLocation, selectedLocation) || other.selectedLocation == selectedLocation)&&(identical(other.currentRoutePlan, currentRoutePlan) || other.currentRoutePlan == currentRoutePlan)&&(identical(other.getRouteState, getRouteState) || other.getRouteState == getRouteState)&&(identical(other.getAddressFromCoordinatesState, getAddressFromCoordinatesState) || other.getAddressFromCoordinatesState == getAddressFromCoordinatesState)&&(identical(other.getMapHazardsState, getMapHazardsState) || other.getMapHazardsState == getMapHazardsState)&&(identical(other.currentNavigationLocation, currentNavigationLocation) || other.currentNavigationLocation == currentNavigationLocation)&&(identical(other.currentSpeed, currentSpeed) || other.currentSpeed == currentSpeed)&&(identical(other.currentBearing, currentBearing) || other.currentBearing == currentBearing)&&(identical(other.isOffRoute, isOffRoute) || other.isOffRoute == isOffRoute)&&(identical(other.followUser, followUser) || other.followUser == followUser)&&(identical(other.navigationState, navigationState) || other.navigationState == navigationState)&&(identical(other.isMapReady, isMapReady) || other.isMapReady == isMapReady)&&(identical(other.pendingCameraUpdateToApply, pendingCameraUpdateToApply) || other.pendingCameraUpdateToApply == pendingCameraUpdateToApply)&&(identical(other.showRouteHazards, showRouteHazards) || other.showRouteHazards == showRouteHazards)&&const DeepCollectionEquality().equals(other._hazardCache, _hazardCache)&&(identical(other.currentStepIndex, currentStepIndex) || other.currentStepIndex == currentStepIndex)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.nextStep, nextStep) || other.nextStep == nextStep)&&(identical(other.distanceToNextManeuverMeters, distanceToNextManeuverMeters) || other.distanceToNextManeuverMeters == distanceToNextManeuverMeters)&&(identical(other.stepAfterNext, stepAfterNext) || other.stepAfterNext == stepAfterNext)&&(identical(other.remainingDistanceMeters, remainingDistanceMeters) || other.remainingDistanceMeters == remainingDistanceMeters)&&(identical(other.remainingDurationSeconds, remainingDurationSeconds) || other.remainingDurationSeconds == remainingDurationSeconds)&&(identical(other.navigationSimulationEnabled, navigationSimulationEnabled) || other.navigationSimulationEnabled == navigationSimulationEnabled)&&const DeepCollectionEquality().equals(other._hazardCorridorsAhead, _hazardCorridorsAhead)&&const DeepCollectionEquality().equals(other._forbiddenCorridors, _forbiddenCorridors)&&(identical(other.takeAlternateRouteState, takeAlternateRouteState) || other.takeAlternateRouteState == takeAlternateRouteState)&&(identical(other.isUserNearClosestHazard, isUserNearClosestHazard) || other.isUserNearClosestHazard == isUserNearClosestHazard)&&(identical(other.showTakeAlternateRouteButton, showTakeAlternateRouteButton) || other.showTakeAlternateRouteButton == showTakeAlternateRouteButton)&&(identical(other.lastAlertedHazardId, lastAlertedHazardId) || other.lastAlertedHazardId == lastAlertedHazardId));
}


@override
int get hashCode => Object.hashAll([runtimeType,getMapHazardsCancelToken,getHazardsToAvoidCancelToken,const DeepCollectionEquality().hash(_hazards),selectedHazard,cameraPosition,const DeepCollectionEquality().hash(_markers),clusterManager,const DeepCollectionEquality().hash(_polylines),selectedLocation,currentRoutePlan,getRouteState,getAddressFromCoordinatesState,getMapHazardsState,currentNavigationLocation,currentSpeed,currentBearing,isOffRoute,followUser,navigationState,isMapReady,pendingCameraUpdateToApply,showRouteHazards,const DeepCollectionEquality().hash(_hazardCache),currentStepIndex,currentStep,nextStep,distanceToNextManeuverMeters,stepAfterNext,remainingDistanceMeters,remainingDurationSeconds,navigationSimulationEnabled,const DeepCollectionEquality().hash(_hazardCorridorsAhead),const DeepCollectionEquality().hash(_forbiddenCorridors),takeAlternateRouteState,isUserNearClosestHazard,showTakeAlternateRouteButton,lastAlertedHazardId]);

@override
String toString() {
  return 'MapProviderState(getMapHazardsCancelToken: $getMapHazardsCancelToken, getHazardsToAvoidCancelToken: $getHazardsToAvoidCancelToken, hazards: $hazards, selectedHazard: $selectedHazard, cameraPosition: $cameraPosition, markers: $markers, clusterManager: $clusterManager, polylines: $polylines, selectedLocation: $selectedLocation, currentRoutePlan: $currentRoutePlan, getRouteState: $getRouteState, getAddressFromCoordinatesState: $getAddressFromCoordinatesState, getMapHazardsState: $getMapHazardsState, currentNavigationLocation: $currentNavigationLocation, currentSpeed: $currentSpeed, currentBearing: $currentBearing, isOffRoute: $isOffRoute, followUser: $followUser, navigationState: $navigationState, isMapReady: $isMapReady, pendingCameraUpdateToApply: $pendingCameraUpdateToApply, showRouteHazards: $showRouteHazards, hazardCache: $hazardCache, currentStepIndex: $currentStepIndex, currentStep: $currentStep, nextStep: $nextStep, distanceToNextManeuverMeters: $distanceToNextManeuverMeters, stepAfterNext: $stepAfterNext, remainingDistanceMeters: $remainingDistanceMeters, remainingDurationSeconds: $remainingDurationSeconds, navigationSimulationEnabled: $navigationSimulationEnabled, hazardCorridorsAhead: $hazardCorridorsAhead, forbiddenCorridors: $forbiddenCorridors, takeAlternateRouteState: $takeAlternateRouteState, isUserNearClosestHazard: $isUserNearClosestHazard, showTakeAlternateRouteButton: $showTakeAlternateRouteButton, lastAlertedHazardId: $lastAlertedHazardId)';
}


}

/// @nodoc
abstract mixin class _$MapProviderStateCopyWith<$Res> implements $MapProviderStateCopyWith<$Res> {
  factory _$MapProviderStateCopyWith(_MapProviderState value, $Res Function(_MapProviderState) _then) = __$MapProviderStateCopyWithImpl;
@override @useResult
$Res call({
 CancelToken getMapHazardsCancelToken, CancelToken getHazardsToAvoidCancelToken, List<Hazard> hazards, Hazard? selectedHazard, CameraPosition cameraPosition, Set<Marker> markers, cluster_manager.ClusterManager? clusterManager, Set<Polyline> polylines, AlrtLocation? selectedLocation, RoutePlan? currentRoutePlan, GetRouteState getRouteState, GetAddressFromCoordinatesState getAddressFromCoordinatesState, GetMapHazardsState getMapHazardsState, AlrtLocation? currentNavigationLocation, double currentSpeed, double currentBearing, bool isOffRoute, bool followUser, NavigationState navigationState, bool isMapReady, CameraUpdate? pendingCameraUpdateToApply, bool showRouteHazards, Map<String, Hazard> hazardCache, int? currentStepIndex, RouteStep? currentStep, RouteStep? nextStep, double? distanceToNextManeuverMeters, RouteStep? stepAfterNext, int? remainingDistanceMeters, int? remainingDurationSeconds, bool navigationSimulationEnabled, List<HazardCorridor> hazardCorridorsAhead, List<HazardCorridor> forbiddenCorridors, TakeAlternateRouteState takeAlternateRouteState, bool isUserNearClosestHazard, bool showTakeAlternateRouteButton, String? lastAlertedHazardId
});


@override $HazardCopyWith<$Res>? get selectedHazard;@override $AlrtLocationCopyWith<$Res>? get selectedLocation;@override $RoutePlanCopyWith<$Res>? get currentRoutePlan;@override $GetRouteStateCopyWith<$Res> get getRouteState;@override $GetAddressFromCoordinatesStateCopyWith<$Res> get getAddressFromCoordinatesState;@override $GetMapHazardsStateCopyWith<$Res> get getMapHazardsState;@override $AlrtLocationCopyWith<$Res>? get currentNavigationLocation;@override $TakeAlternateRouteStateCopyWith<$Res> get takeAlternateRouteState;

}
/// @nodoc
class __$MapProviderStateCopyWithImpl<$Res>
    implements _$MapProviderStateCopyWith<$Res> {
  __$MapProviderStateCopyWithImpl(this._self, this._then);

  final _MapProviderState _self;
  final $Res Function(_MapProviderState) _then;

/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? getMapHazardsCancelToken = null,Object? getHazardsToAvoidCancelToken = null,Object? hazards = null,Object? selectedHazard = freezed,Object? cameraPosition = null,Object? markers = null,Object? clusterManager = freezed,Object? polylines = null,Object? selectedLocation = freezed,Object? currentRoutePlan = freezed,Object? getRouteState = null,Object? getAddressFromCoordinatesState = null,Object? getMapHazardsState = null,Object? currentNavigationLocation = freezed,Object? currentSpeed = null,Object? currentBearing = null,Object? isOffRoute = null,Object? followUser = null,Object? navigationState = null,Object? isMapReady = null,Object? pendingCameraUpdateToApply = freezed,Object? showRouteHazards = null,Object? hazardCache = null,Object? currentStepIndex = freezed,Object? currentStep = freezed,Object? nextStep = freezed,Object? distanceToNextManeuverMeters = freezed,Object? stepAfterNext = freezed,Object? remainingDistanceMeters = freezed,Object? remainingDurationSeconds = freezed,Object? navigationSimulationEnabled = null,Object? hazardCorridorsAhead = null,Object? forbiddenCorridors = null,Object? takeAlternateRouteState = null,Object? isUserNearClosestHazard = null,Object? showTakeAlternateRouteButton = null,Object? lastAlertedHazardId = freezed,}) {
  return _then(_MapProviderState(
getMapHazardsCancelToken: null == getMapHazardsCancelToken ? _self.getMapHazardsCancelToken : getMapHazardsCancelToken // ignore: cast_nullable_to_non_nullable
as CancelToken,getHazardsToAvoidCancelToken: null == getHazardsToAvoidCancelToken ? _self.getHazardsToAvoidCancelToken : getHazardsToAvoidCancelToken // ignore: cast_nullable_to_non_nullable
as CancelToken,hazards: null == hazards ? _self._hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,selectedHazard: freezed == selectedHazard ? _self.selectedHazard : selectedHazard // ignore: cast_nullable_to_non_nullable
as Hazard?,cameraPosition: null == cameraPosition ? _self.cameraPosition : cameraPosition // ignore: cast_nullable_to_non_nullable
as CameraPosition,markers: null == markers ? _self._markers : markers // ignore: cast_nullable_to_non_nullable
as Set<Marker>,clusterManager: freezed == clusterManager ? _self.clusterManager : clusterManager // ignore: cast_nullable_to_non_nullable
as cluster_manager.ClusterManager?,polylines: null == polylines ? _self._polylines : polylines // ignore: cast_nullable_to_non_nullable
as Set<Polyline>,selectedLocation: freezed == selectedLocation ? _self.selectedLocation : selectedLocation // ignore: cast_nullable_to_non_nullable
as AlrtLocation?,currentRoutePlan: freezed == currentRoutePlan ? _self.currentRoutePlan : currentRoutePlan // ignore: cast_nullable_to_non_nullable
as RoutePlan?,getRouteState: null == getRouteState ? _self.getRouteState : getRouteState // ignore: cast_nullable_to_non_nullable
as GetRouteState,getAddressFromCoordinatesState: null == getAddressFromCoordinatesState ? _self.getAddressFromCoordinatesState : getAddressFromCoordinatesState // ignore: cast_nullable_to_non_nullable
as GetAddressFromCoordinatesState,getMapHazardsState: null == getMapHazardsState ? _self.getMapHazardsState : getMapHazardsState // ignore: cast_nullable_to_non_nullable
as GetMapHazardsState,currentNavigationLocation: freezed == currentNavigationLocation ? _self.currentNavigationLocation : currentNavigationLocation // ignore: cast_nullable_to_non_nullable
as AlrtLocation?,currentSpeed: null == currentSpeed ? _self.currentSpeed : currentSpeed // ignore: cast_nullable_to_non_nullable
as double,currentBearing: null == currentBearing ? _self.currentBearing : currentBearing // ignore: cast_nullable_to_non_nullable
as double,isOffRoute: null == isOffRoute ? _self.isOffRoute : isOffRoute // ignore: cast_nullable_to_non_nullable
as bool,followUser: null == followUser ? _self.followUser : followUser // ignore: cast_nullable_to_non_nullable
as bool,navigationState: null == navigationState ? _self.navigationState : navigationState // ignore: cast_nullable_to_non_nullable
as NavigationState,isMapReady: null == isMapReady ? _self.isMapReady : isMapReady // ignore: cast_nullable_to_non_nullable
as bool,pendingCameraUpdateToApply: freezed == pendingCameraUpdateToApply ? _self.pendingCameraUpdateToApply : pendingCameraUpdateToApply // ignore: cast_nullable_to_non_nullable
as CameraUpdate?,showRouteHazards: null == showRouteHazards ? _self.showRouteHazards : showRouteHazards // ignore: cast_nullable_to_non_nullable
as bool,hazardCache: null == hazardCache ? _self._hazardCache : hazardCache // ignore: cast_nullable_to_non_nullable
as Map<String, Hazard>,currentStepIndex: freezed == currentStepIndex ? _self.currentStepIndex : currentStepIndex // ignore: cast_nullable_to_non_nullable
as int?,currentStep: freezed == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as RouteStep?,nextStep: freezed == nextStep ? _self.nextStep : nextStep // ignore: cast_nullable_to_non_nullable
as RouteStep?,distanceToNextManeuverMeters: freezed == distanceToNextManeuverMeters ? _self.distanceToNextManeuverMeters : distanceToNextManeuverMeters // ignore: cast_nullable_to_non_nullable
as double?,stepAfterNext: freezed == stepAfterNext ? _self.stepAfterNext : stepAfterNext // ignore: cast_nullable_to_non_nullable
as RouteStep?,remainingDistanceMeters: freezed == remainingDistanceMeters ? _self.remainingDistanceMeters : remainingDistanceMeters // ignore: cast_nullable_to_non_nullable
as int?,remainingDurationSeconds: freezed == remainingDurationSeconds ? _self.remainingDurationSeconds : remainingDurationSeconds // ignore: cast_nullable_to_non_nullable
as int?,navigationSimulationEnabled: null == navigationSimulationEnabled ? _self.navigationSimulationEnabled : navigationSimulationEnabled // ignore: cast_nullable_to_non_nullable
as bool,hazardCorridorsAhead: null == hazardCorridorsAhead ? _self._hazardCorridorsAhead : hazardCorridorsAhead // ignore: cast_nullable_to_non_nullable
as List<HazardCorridor>,forbiddenCorridors: null == forbiddenCorridors ? _self._forbiddenCorridors : forbiddenCorridors // ignore: cast_nullable_to_non_nullable
as List<HazardCorridor>,takeAlternateRouteState: null == takeAlternateRouteState ? _self.takeAlternateRouteState : takeAlternateRouteState // ignore: cast_nullable_to_non_nullable
as TakeAlternateRouteState,isUserNearClosestHazard: null == isUserNearClosestHazard ? _self.isUserNearClosestHazard : isUserNearClosestHazard // ignore: cast_nullable_to_non_nullable
as bool,showTakeAlternateRouteButton: null == showTakeAlternateRouteButton ? _self.showTakeAlternateRouteButton : showTakeAlternateRouteButton // ignore: cast_nullable_to_non_nullable
as bool,lastAlertedHazardId: freezed == lastAlertedHazardId ? _self.lastAlertedHazardId : lastAlertedHazardId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HazardCopyWith<$Res>? get selectedHazard {
    if (_self.selectedHazard == null) {
    return null;
  }

  return $HazardCopyWith<$Res>(_self.selectedHazard!, (value) {
    return _then(_self.copyWith(selectedHazard: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res>? get selectedLocation {
    if (_self.selectedLocation == null) {
    return null;
  }

  return $AlrtLocationCopyWith<$Res>(_self.selectedLocation!, (value) {
    return _then(_self.copyWith(selectedLocation: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutePlanCopyWith<$Res>? get currentRoutePlan {
    if (_self.currentRoutePlan == null) {
    return null;
  }

  return $RoutePlanCopyWith<$Res>(_self.currentRoutePlan!, (value) {
    return _then(_self.copyWith(currentRoutePlan: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetRouteStateCopyWith<$Res> get getRouteState {
  
  return $GetRouteStateCopyWith<$Res>(_self.getRouteState, (value) {
    return _then(_self.copyWith(getRouteState: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetAddressFromCoordinatesStateCopyWith<$Res> get getAddressFromCoordinatesState {
  
  return $GetAddressFromCoordinatesStateCopyWith<$Res>(_self.getAddressFromCoordinatesState, (value) {
    return _then(_self.copyWith(getAddressFromCoordinatesState: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetMapHazardsStateCopyWith<$Res> get getMapHazardsState {
  
  return $GetMapHazardsStateCopyWith<$Res>(_self.getMapHazardsState, (value) {
    return _then(_self.copyWith(getMapHazardsState: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res>? get currentNavigationLocation {
    if (_self.currentNavigationLocation == null) {
    return null;
  }

  return $AlrtLocationCopyWith<$Res>(_self.currentNavigationLocation!, (value) {
    return _then(_self.copyWith(currentNavigationLocation: value));
  });
}/// Create a copy of MapProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TakeAlternateRouteStateCopyWith<$Res> get takeAlternateRouteState {
  
  return $TakeAlternateRouteStateCopyWith<$Res>(_self.takeAlternateRouteState, (value) {
    return _then(_self.copyWith(takeAlternateRouteState: value));
  });
}
}

/// @nodoc
mixin _$GetRouteState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetRouteState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetRouteState()';
}


}

/// @nodoc
class $GetRouteStateCopyWith<$Res>  {
$GetRouteStateCopyWith(GetRouteState _, $Res Function(GetRouteState) __);
}


/// Adds pattern-matching-related methods to [GetRouteState].
extension GetRouteStatePatterns on GetRouteState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetRouteStateInitial value)?  initial,TResult Function( _GetRouteStateLoading value)?  loading,TResult Function( _GetRouteStateSuccess value)?  success,TResult Function( _GetRouteStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetRouteStateInitial() when initial != null:
return initial(_that);case _GetRouteStateLoading() when loading != null:
return loading(_that);case _GetRouteStateSuccess() when success != null:
return success(_that);case _GetRouteStateError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetRouteStateInitial value)  initial,required TResult Function( _GetRouteStateLoading value)  loading,required TResult Function( _GetRouteStateSuccess value)  success,required TResult Function( _GetRouteStateError value)  error,}){
final _that = this;
switch (_that) {
case _GetRouteStateInitial():
return initial(_that);case _GetRouteStateLoading():
return loading(_that);case _GetRouteStateSuccess():
return success(_that);case _GetRouteStateError():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetRouteStateInitial value)?  initial,TResult? Function( _GetRouteStateLoading value)?  loading,TResult? Function( _GetRouteStateSuccess value)?  success,TResult? Function( _GetRouteStateError value)?  error,}){
final _that = this;
switch (_that) {
case _GetRouteStateInitial() when initial != null:
return initial(_that);case _GetRouteStateLoading() when loading != null:
return loading(_that);case _GetRouteStateSuccess() when success != null:
return success(_that);case _GetRouteStateError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( RoutePlan routeSettings)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetRouteStateInitial() when initial != null:
return initial();case _GetRouteStateLoading() when loading != null:
return loading();case _GetRouteStateSuccess() when success != null:
return success(_that.routeSettings);case _GetRouteStateError() when error != null:
return error(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( RoutePlan routeSettings)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _GetRouteStateInitial():
return initial();case _GetRouteStateLoading():
return loading();case _GetRouteStateSuccess():
return success(_that.routeSettings);case _GetRouteStateError():
return error(_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( RoutePlan routeSettings)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _GetRouteStateInitial() when initial != null:
return initial();case _GetRouteStateLoading() when loading != null:
return loading();case _GetRouteStateSuccess() when success != null:
return success(_that.routeSettings);case _GetRouteStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetRouteStateInitial implements GetRouteState {
  const _GetRouteStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetRouteStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetRouteState.initial()';
}


}




/// @nodoc


class _GetRouteStateLoading implements GetRouteState {
  const _GetRouteStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetRouteStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetRouteState.loading()';
}


}




/// @nodoc


class _GetRouteStateSuccess implements GetRouteState {
  const _GetRouteStateSuccess(this.routeSettings);
  

 final  RoutePlan routeSettings;

/// Create a copy of GetRouteState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetRouteStateSuccessCopyWith<_GetRouteStateSuccess> get copyWith => __$GetRouteStateSuccessCopyWithImpl<_GetRouteStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetRouteStateSuccess&&(identical(other.routeSettings, routeSettings) || other.routeSettings == routeSettings));
}


@override
int get hashCode => Object.hash(runtimeType,routeSettings);

@override
String toString() {
  return 'GetRouteState.success(routeSettings: $routeSettings)';
}


}

/// @nodoc
abstract mixin class _$GetRouteStateSuccessCopyWith<$Res> implements $GetRouteStateCopyWith<$Res> {
  factory _$GetRouteStateSuccessCopyWith(_GetRouteStateSuccess value, $Res Function(_GetRouteStateSuccess) _then) = __$GetRouteStateSuccessCopyWithImpl;
@useResult
$Res call({
 RoutePlan routeSettings
});


$RoutePlanCopyWith<$Res> get routeSettings;

}
/// @nodoc
class __$GetRouteStateSuccessCopyWithImpl<$Res>
    implements _$GetRouteStateSuccessCopyWith<$Res> {
  __$GetRouteStateSuccessCopyWithImpl(this._self, this._then);

  final _GetRouteStateSuccess _self;
  final $Res Function(_GetRouteStateSuccess) _then;

/// Create a copy of GetRouteState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? routeSettings = null,}) {
  return _then(_GetRouteStateSuccess(
null == routeSettings ? _self.routeSettings : routeSettings // ignore: cast_nullable_to_non_nullable
as RoutePlan,
  ));
}

/// Create a copy of GetRouteState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutePlanCopyWith<$Res> get routeSettings {
  
  return $RoutePlanCopyWith<$Res>(_self.routeSettings, (value) {
    return _then(_self.copyWith(routeSettings: value));
  });
}
}

/// @nodoc


class _GetRouteStateError implements GetRouteState {
  const _GetRouteStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetRouteState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetRouteStateErrorCopyWith<_GetRouteStateError> get copyWith => __$GetRouteStateErrorCopyWithImpl<_GetRouteStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetRouteStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetRouteState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetRouteStateErrorCopyWith<$Res> implements $GetRouteStateCopyWith<$Res> {
  factory _$GetRouteStateErrorCopyWith(_GetRouteStateError value, $Res Function(_GetRouteStateError) _then) = __$GetRouteStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GetRouteStateErrorCopyWithImpl<$Res>
    implements _$GetRouteStateErrorCopyWith<$Res> {
  __$GetRouteStateErrorCopyWithImpl(this._self, this._then);

  final _GetRouteStateError _self;
  final $Res Function(_GetRouteStateError) _then;

/// Create a copy of GetRouteState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GetRouteStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetRouteState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res> get error {
  
  return $AppErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

/// @nodoc
mixin _$GetAddressFromCoordinatesState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAddressFromCoordinatesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAddressFromCoordinatesState()';
}


}

/// @nodoc
class $GetAddressFromCoordinatesStateCopyWith<$Res>  {
$GetAddressFromCoordinatesStateCopyWith(GetAddressFromCoordinatesState _, $Res Function(GetAddressFromCoordinatesState) __);
}


/// Adds pattern-matching-related methods to [GetAddressFromCoordinatesState].
extension GetAddressFromCoordinatesStatePatterns on GetAddressFromCoordinatesState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetAddressFromCoordinatesStateInitial value)?  initial,TResult Function( _GetAddressFromCoordinatesStateLoading value)?  loading,TResult Function( _GetAddressFromCoordinatesStateSuccess value)?  success,TResult Function( _GetAddressFromCoordinatesStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetAddressFromCoordinatesStateInitial() when initial != null:
return initial(_that);case _GetAddressFromCoordinatesStateLoading() when loading != null:
return loading(_that);case _GetAddressFromCoordinatesStateSuccess() when success != null:
return success(_that);case _GetAddressFromCoordinatesStateError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetAddressFromCoordinatesStateInitial value)  initial,required TResult Function( _GetAddressFromCoordinatesStateLoading value)  loading,required TResult Function( _GetAddressFromCoordinatesStateSuccess value)  success,required TResult Function( _GetAddressFromCoordinatesStateError value)  error,}){
final _that = this;
switch (_that) {
case _GetAddressFromCoordinatesStateInitial():
return initial(_that);case _GetAddressFromCoordinatesStateLoading():
return loading(_that);case _GetAddressFromCoordinatesStateSuccess():
return success(_that);case _GetAddressFromCoordinatesStateError():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetAddressFromCoordinatesStateInitial value)?  initial,TResult? Function( _GetAddressFromCoordinatesStateLoading value)?  loading,TResult? Function( _GetAddressFromCoordinatesStateSuccess value)?  success,TResult? Function( _GetAddressFromCoordinatesStateError value)?  error,}){
final _that = this;
switch (_that) {
case _GetAddressFromCoordinatesStateInitial() when initial != null:
return initial(_that);case _GetAddressFromCoordinatesStateLoading() when loading != null:
return loading(_that);case _GetAddressFromCoordinatesStateSuccess() when success != null:
return success(_that);case _GetAddressFromCoordinatesStateError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( AlrtLocation location)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetAddressFromCoordinatesStateInitial() when initial != null:
return initial();case _GetAddressFromCoordinatesStateLoading() when loading != null:
return loading();case _GetAddressFromCoordinatesStateSuccess() when success != null:
return success(_that.location);case _GetAddressFromCoordinatesStateError() when error != null:
return error(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( AlrtLocation location)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _GetAddressFromCoordinatesStateInitial():
return initial();case _GetAddressFromCoordinatesStateLoading():
return loading();case _GetAddressFromCoordinatesStateSuccess():
return success(_that.location);case _GetAddressFromCoordinatesStateError():
return error(_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( AlrtLocation location)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _GetAddressFromCoordinatesStateInitial() when initial != null:
return initial();case _GetAddressFromCoordinatesStateLoading() when loading != null:
return loading();case _GetAddressFromCoordinatesStateSuccess() when success != null:
return success(_that.location);case _GetAddressFromCoordinatesStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetAddressFromCoordinatesStateInitial implements GetAddressFromCoordinatesState {
  const _GetAddressFromCoordinatesStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetAddressFromCoordinatesStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAddressFromCoordinatesState.initial()';
}


}




/// @nodoc


class _GetAddressFromCoordinatesStateLoading implements GetAddressFromCoordinatesState {
  const _GetAddressFromCoordinatesStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetAddressFromCoordinatesStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAddressFromCoordinatesState.loading()';
}


}




/// @nodoc


class _GetAddressFromCoordinatesStateSuccess implements GetAddressFromCoordinatesState {
  const _GetAddressFromCoordinatesStateSuccess(this.location);
  

 final  AlrtLocation location;

/// Create a copy of GetAddressFromCoordinatesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetAddressFromCoordinatesStateSuccessCopyWith<_GetAddressFromCoordinatesStateSuccess> get copyWith => __$GetAddressFromCoordinatesStateSuccessCopyWithImpl<_GetAddressFromCoordinatesStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetAddressFromCoordinatesStateSuccess&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode => Object.hash(runtimeType,location);

@override
String toString() {
  return 'GetAddressFromCoordinatesState.success(location: $location)';
}


}

/// @nodoc
abstract mixin class _$GetAddressFromCoordinatesStateSuccessCopyWith<$Res> implements $GetAddressFromCoordinatesStateCopyWith<$Res> {
  factory _$GetAddressFromCoordinatesStateSuccessCopyWith(_GetAddressFromCoordinatesStateSuccess value, $Res Function(_GetAddressFromCoordinatesStateSuccess) _then) = __$GetAddressFromCoordinatesStateSuccessCopyWithImpl;
@useResult
$Res call({
 AlrtLocation location
});


$AlrtLocationCopyWith<$Res> get location;

}
/// @nodoc
class __$GetAddressFromCoordinatesStateSuccessCopyWithImpl<$Res>
    implements _$GetAddressFromCoordinatesStateSuccessCopyWith<$Res> {
  __$GetAddressFromCoordinatesStateSuccessCopyWithImpl(this._self, this._then);

  final _GetAddressFromCoordinatesStateSuccess _self;
  final $Res Function(_GetAddressFromCoordinatesStateSuccess) _then;

/// Create a copy of GetAddressFromCoordinatesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? location = null,}) {
  return _then(_GetAddressFromCoordinatesStateSuccess(
null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as AlrtLocation,
  ));
}

/// Create a copy of GetAddressFromCoordinatesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res> get location {
  
  return $AlrtLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

/// @nodoc


class _GetAddressFromCoordinatesStateError implements GetAddressFromCoordinatesState {
  const _GetAddressFromCoordinatesStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetAddressFromCoordinatesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetAddressFromCoordinatesStateErrorCopyWith<_GetAddressFromCoordinatesStateError> get copyWith => __$GetAddressFromCoordinatesStateErrorCopyWithImpl<_GetAddressFromCoordinatesStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetAddressFromCoordinatesStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetAddressFromCoordinatesState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetAddressFromCoordinatesStateErrorCopyWith<$Res> implements $GetAddressFromCoordinatesStateCopyWith<$Res> {
  factory _$GetAddressFromCoordinatesStateErrorCopyWith(_GetAddressFromCoordinatesStateError value, $Res Function(_GetAddressFromCoordinatesStateError) _then) = __$GetAddressFromCoordinatesStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GetAddressFromCoordinatesStateErrorCopyWithImpl<$Res>
    implements _$GetAddressFromCoordinatesStateErrorCopyWith<$Res> {
  __$GetAddressFromCoordinatesStateErrorCopyWithImpl(this._self, this._then);

  final _GetAddressFromCoordinatesStateError _self;
  final $Res Function(_GetAddressFromCoordinatesStateError) _then;

/// Create a copy of GetAddressFromCoordinatesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GetAddressFromCoordinatesStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetAddressFromCoordinatesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res> get error {
  
  return $AppErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

/// @nodoc
mixin _$GetMapHazardsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMapHazardsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetMapHazardsState()';
}


}

/// @nodoc
class $GetMapHazardsStateCopyWith<$Res>  {
$GetMapHazardsStateCopyWith(GetMapHazardsState _, $Res Function(GetMapHazardsState) __);
}


/// Adds pattern-matching-related methods to [GetMapHazardsState].
extension GetMapHazardsStatePatterns on GetMapHazardsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetMapHazardsStateInitial value)?  initial,TResult Function( _GetMapHazardsStateLoading value)?  loading,TResult Function( _GetMapHazardsStateSuccess value)?  success,TResult Function( _GetMapHazardsStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetMapHazardsStateInitial() when initial != null:
return initial(_that);case _GetMapHazardsStateLoading() when loading != null:
return loading(_that);case _GetMapHazardsStateSuccess() when success != null:
return success(_that);case _GetMapHazardsStateError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetMapHazardsStateInitial value)  initial,required TResult Function( _GetMapHazardsStateLoading value)  loading,required TResult Function( _GetMapHazardsStateSuccess value)  success,required TResult Function( _GetMapHazardsStateError value)  error,}){
final _that = this;
switch (_that) {
case _GetMapHazardsStateInitial():
return initial(_that);case _GetMapHazardsStateLoading():
return loading(_that);case _GetMapHazardsStateSuccess():
return success(_that);case _GetMapHazardsStateError():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetMapHazardsStateInitial value)?  initial,TResult? Function( _GetMapHazardsStateLoading value)?  loading,TResult? Function( _GetMapHazardsStateSuccess value)?  success,TResult? Function( _GetMapHazardsStateError value)?  error,}){
final _that = this;
switch (_that) {
case _GetMapHazardsStateInitial() when initial != null:
return initial(_that);case _GetMapHazardsStateLoading() when loading != null:
return loading(_that);case _GetMapHazardsStateSuccess() when success != null:
return success(_that);case _GetMapHazardsStateError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Hazard> hazards)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetMapHazardsStateInitial() when initial != null:
return initial();case _GetMapHazardsStateLoading() when loading != null:
return loading();case _GetMapHazardsStateSuccess() when success != null:
return success(_that.hazards);case _GetMapHazardsStateError() when error != null:
return error(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Hazard> hazards)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _GetMapHazardsStateInitial():
return initial();case _GetMapHazardsStateLoading():
return loading();case _GetMapHazardsStateSuccess():
return success(_that.hazards);case _GetMapHazardsStateError():
return error(_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Hazard> hazards)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _GetMapHazardsStateInitial() when initial != null:
return initial();case _GetMapHazardsStateLoading() when loading != null:
return loading();case _GetMapHazardsStateSuccess() when success != null:
return success(_that.hazards);case _GetMapHazardsStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetMapHazardsStateInitial implements GetMapHazardsState {
  const _GetMapHazardsStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMapHazardsStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetMapHazardsState.initial()';
}


}




/// @nodoc


class _GetMapHazardsStateLoading implements GetMapHazardsState {
  const _GetMapHazardsStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMapHazardsStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetMapHazardsState.loading()';
}


}




/// @nodoc


class _GetMapHazardsStateSuccess implements GetMapHazardsState {
  const _GetMapHazardsStateSuccess(final  List<Hazard> hazards): _hazards = hazards;
  

 final  List<Hazard> _hazards;
 List<Hazard> get hazards {
  if (_hazards is EqualUnmodifiableListView) return _hazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazards);
}


/// Create a copy of GetMapHazardsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetMapHazardsStateSuccessCopyWith<_GetMapHazardsStateSuccess> get copyWith => __$GetMapHazardsStateSuccessCopyWithImpl<_GetMapHazardsStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMapHazardsStateSuccess&&const DeepCollectionEquality().equals(other._hazards, _hazards));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_hazards));

@override
String toString() {
  return 'GetMapHazardsState.success(hazards: $hazards)';
}


}

/// @nodoc
abstract mixin class _$GetMapHazardsStateSuccessCopyWith<$Res> implements $GetMapHazardsStateCopyWith<$Res> {
  factory _$GetMapHazardsStateSuccessCopyWith(_GetMapHazardsStateSuccess value, $Res Function(_GetMapHazardsStateSuccess) _then) = __$GetMapHazardsStateSuccessCopyWithImpl;
@useResult
$Res call({
 List<Hazard> hazards
});




}
/// @nodoc
class __$GetMapHazardsStateSuccessCopyWithImpl<$Res>
    implements _$GetMapHazardsStateSuccessCopyWith<$Res> {
  __$GetMapHazardsStateSuccessCopyWithImpl(this._self, this._then);

  final _GetMapHazardsStateSuccess _self;
  final $Res Function(_GetMapHazardsStateSuccess) _then;

/// Create a copy of GetMapHazardsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hazards = null,}) {
  return _then(_GetMapHazardsStateSuccess(
null == hazards ? _self._hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,
  ));
}


}

/// @nodoc


class _GetMapHazardsStateError implements GetMapHazardsState {
  const _GetMapHazardsStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetMapHazardsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetMapHazardsStateErrorCopyWith<_GetMapHazardsStateError> get copyWith => __$GetMapHazardsStateErrorCopyWithImpl<_GetMapHazardsStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMapHazardsStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetMapHazardsState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetMapHazardsStateErrorCopyWith<$Res> implements $GetMapHazardsStateCopyWith<$Res> {
  factory _$GetMapHazardsStateErrorCopyWith(_GetMapHazardsStateError value, $Res Function(_GetMapHazardsStateError) _then) = __$GetMapHazardsStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GetMapHazardsStateErrorCopyWithImpl<$Res>
    implements _$GetMapHazardsStateErrorCopyWith<$Res> {
  __$GetMapHazardsStateErrorCopyWithImpl(this._self, this._then);

  final _GetMapHazardsStateError _self;
  final $Res Function(_GetMapHazardsStateError) _then;

/// Create a copy of GetMapHazardsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GetMapHazardsStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetMapHazardsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res> get error {
  
  return $AppErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

/// @nodoc
mixin _$TakeAlternateRouteState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TakeAlternateRouteState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TakeAlternateRouteState()';
}


}

/// @nodoc
class $TakeAlternateRouteStateCopyWith<$Res>  {
$TakeAlternateRouteStateCopyWith(TakeAlternateRouteState _, $Res Function(TakeAlternateRouteState) __);
}


/// Adds pattern-matching-related methods to [TakeAlternateRouteState].
extension TakeAlternateRouteStatePatterns on TakeAlternateRouteState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _TakeAlternateRouteStateIdle value)?  idle,TResult Function( _TakeAlternateRouteStateLoading value)?  loading,TResult Function( _TakeAlternateRouteStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TakeAlternateRouteStateIdle() when idle != null:
return idle(_that);case _TakeAlternateRouteStateLoading() when loading != null:
return loading(_that);case _TakeAlternateRouteStateError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _TakeAlternateRouteStateIdle value)  idle,required TResult Function( _TakeAlternateRouteStateLoading value)  loading,required TResult Function( _TakeAlternateRouteStateError value)  error,}){
final _that = this;
switch (_that) {
case _TakeAlternateRouteStateIdle():
return idle(_that);case _TakeAlternateRouteStateLoading():
return loading(_that);case _TakeAlternateRouteStateError():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _TakeAlternateRouteStateIdle value)?  idle,TResult? Function( _TakeAlternateRouteStateLoading value)?  loading,TResult? Function( _TakeAlternateRouteStateError value)?  error,}){
final _that = this;
switch (_that) {
case _TakeAlternateRouteStateIdle() when idle != null:
return idle(_that);case _TakeAlternateRouteStateLoading() when loading != null:
return loading(_that);case _TakeAlternateRouteStateError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TakeAlternateRouteStateIdle() when idle != null:
return idle();case _TakeAlternateRouteStateLoading() when loading != null:
return loading();case _TakeAlternateRouteStateError() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _TakeAlternateRouteStateIdle():
return idle();case _TakeAlternateRouteStateLoading():
return loading();case _TakeAlternateRouteStateError():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _TakeAlternateRouteStateIdle() when idle != null:
return idle();case _TakeAlternateRouteStateLoading() when loading != null:
return loading();case _TakeAlternateRouteStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _TakeAlternateRouteStateIdle extends TakeAlternateRouteState {
  const _TakeAlternateRouteStateIdle(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TakeAlternateRouteStateIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TakeAlternateRouteState.idle()';
}


}




/// @nodoc


class _TakeAlternateRouteStateLoading extends TakeAlternateRouteState {
  const _TakeAlternateRouteStateLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TakeAlternateRouteStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TakeAlternateRouteState.loading()';
}


}




/// @nodoc


class _TakeAlternateRouteStateError extends TakeAlternateRouteState {
  const _TakeAlternateRouteStateError(this.message): super._();
  

 final  String message;

/// Create a copy of TakeAlternateRouteState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TakeAlternateRouteStateErrorCopyWith<_TakeAlternateRouteStateError> get copyWith => __$TakeAlternateRouteStateErrorCopyWithImpl<_TakeAlternateRouteStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TakeAlternateRouteStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'TakeAlternateRouteState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$TakeAlternateRouteStateErrorCopyWith<$Res> implements $TakeAlternateRouteStateCopyWith<$Res> {
  factory _$TakeAlternateRouteStateErrorCopyWith(_TakeAlternateRouteStateError value, $Res Function(_TakeAlternateRouteStateError) _then) = __$TakeAlternateRouteStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$TakeAlternateRouteStateErrorCopyWithImpl<$Res>
    implements _$TakeAlternateRouteStateErrorCopyWith<$Res> {
  __$TakeAlternateRouteStateErrorCopyWithImpl(this._self, this._then);

  final _TakeAlternateRouteStateError _self;
  final $Res Function(_TakeAlternateRouteStateError) _then;

/// Create a copy of TakeAlternateRouteState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_TakeAlternateRouteStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
