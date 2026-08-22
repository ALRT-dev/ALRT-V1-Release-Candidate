// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'navigation_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NavigationProviderState {

/// Whether navigation is currently active
 bool get isNavigating;/// Current user location during navigation
 AlrtLocation? get currentLocation;/// Destination location
 AlrtLocation? get destination;/// Current route polyline points
 List<LatLng> get routePoints;/// Current step index in the navigation
 int get currentStepIndex;/// Current navigation instruction
 String? get currentInstruction;/// Distance remaining to destination (in meters)
 double? get remainingDistance;/// Estimated time of arrival
 DateTime? get estimatedArrival;/// Current speed (m/s)
 double get currentSpeed;/// Current bearing/direction in degrees (0-360)
 double get currentBearing;/// Whether the user is off-route
 bool get isOffRoute;/// Camera should follow user during navigation
 bool get followUser;/// Navigation state
 NavigationState get navigationState;
/// Create a copy of NavigationProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationProviderStateCopyWith<NavigationProviderState> get copyWith => _$NavigationProviderStateCopyWithImpl<NavigationProviderState>(this as NavigationProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationProviderState&&(identical(other.isNavigating, isNavigating) || other.isNavigating == isNavigating)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other.routePoints, routePoints)&&(identical(other.currentStepIndex, currentStepIndex) || other.currentStepIndex == currentStepIndex)&&(identical(other.currentInstruction, currentInstruction) || other.currentInstruction == currentInstruction)&&(identical(other.remainingDistance, remainingDistance) || other.remainingDistance == remainingDistance)&&(identical(other.estimatedArrival, estimatedArrival) || other.estimatedArrival == estimatedArrival)&&(identical(other.currentSpeed, currentSpeed) || other.currentSpeed == currentSpeed)&&(identical(other.currentBearing, currentBearing) || other.currentBearing == currentBearing)&&(identical(other.isOffRoute, isOffRoute) || other.isOffRoute == isOffRoute)&&(identical(other.followUser, followUser) || other.followUser == followUser)&&(identical(other.navigationState, navigationState) || other.navigationState == navigationState));
}


@override
int get hashCode => Object.hash(runtimeType,isNavigating,currentLocation,destination,const DeepCollectionEquality().hash(routePoints),currentStepIndex,currentInstruction,remainingDistance,estimatedArrival,currentSpeed,currentBearing,isOffRoute,followUser,navigationState);

@override
String toString() {
  return 'NavigationProviderState(isNavigating: $isNavigating, currentLocation: $currentLocation, destination: $destination, routePoints: $routePoints, currentStepIndex: $currentStepIndex, currentInstruction: $currentInstruction, remainingDistance: $remainingDistance, estimatedArrival: $estimatedArrival, currentSpeed: $currentSpeed, currentBearing: $currentBearing, isOffRoute: $isOffRoute, followUser: $followUser, navigationState: $navigationState)';
}


}

/// @nodoc
abstract mixin class $NavigationProviderStateCopyWith<$Res>  {
  factory $NavigationProviderStateCopyWith(NavigationProviderState value, $Res Function(NavigationProviderState) _then) = _$NavigationProviderStateCopyWithImpl;
@useResult
$Res call({
 bool isNavigating, AlrtLocation? currentLocation, AlrtLocation? destination, List<LatLng> routePoints, int currentStepIndex, String? currentInstruction, double? remainingDistance, DateTime? estimatedArrival, double currentSpeed, double currentBearing, bool isOffRoute, bool followUser, NavigationState navigationState
});


$AlrtLocationCopyWith<$Res>? get currentLocation;$AlrtLocationCopyWith<$Res>? get destination;$NavigationStateCopyWith<$Res> get navigationState;

}
/// @nodoc
class _$NavigationProviderStateCopyWithImpl<$Res>
    implements $NavigationProviderStateCopyWith<$Res> {
  _$NavigationProviderStateCopyWithImpl(this._self, this._then);

  final NavigationProviderState _self;
  final $Res Function(NavigationProviderState) _then;

/// Create a copy of NavigationProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isNavigating = null,Object? currentLocation = freezed,Object? destination = freezed,Object? routePoints = null,Object? currentStepIndex = null,Object? currentInstruction = freezed,Object? remainingDistance = freezed,Object? estimatedArrival = freezed,Object? currentSpeed = null,Object? currentBearing = null,Object? isOffRoute = null,Object? followUser = null,Object? navigationState = null,}) {
  return _then(_self.copyWith(
isNavigating: null == isNavigating ? _self.isNavigating : isNavigating // ignore: cast_nullable_to_non_nullable
as bool,currentLocation: freezed == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as AlrtLocation?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as AlrtLocation?,routePoints: null == routePoints ? _self.routePoints : routePoints // ignore: cast_nullable_to_non_nullable
as List<LatLng>,currentStepIndex: null == currentStepIndex ? _self.currentStepIndex : currentStepIndex // ignore: cast_nullable_to_non_nullable
as int,currentInstruction: freezed == currentInstruction ? _self.currentInstruction : currentInstruction // ignore: cast_nullable_to_non_nullable
as String?,remainingDistance: freezed == remainingDistance ? _self.remainingDistance : remainingDistance // ignore: cast_nullable_to_non_nullable
as double?,estimatedArrival: freezed == estimatedArrival ? _self.estimatedArrival : estimatedArrival // ignore: cast_nullable_to_non_nullable
as DateTime?,currentSpeed: null == currentSpeed ? _self.currentSpeed : currentSpeed // ignore: cast_nullable_to_non_nullable
as double,currentBearing: null == currentBearing ? _self.currentBearing : currentBearing // ignore: cast_nullable_to_non_nullable
as double,isOffRoute: null == isOffRoute ? _self.isOffRoute : isOffRoute // ignore: cast_nullable_to_non_nullable
as bool,followUser: null == followUser ? _self.followUser : followUser // ignore: cast_nullable_to_non_nullable
as bool,navigationState: null == navigationState ? _self.navigationState : navigationState // ignore: cast_nullable_to_non_nullable
as NavigationState,
  ));
}
/// Create a copy of NavigationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res>? get currentLocation {
    if (_self.currentLocation == null) {
    return null;
  }

  return $AlrtLocationCopyWith<$Res>(_self.currentLocation!, (value) {
    return _then(_self.copyWith(currentLocation: value));
  });
}/// Create a copy of NavigationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $AlrtLocationCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of NavigationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NavigationStateCopyWith<$Res> get navigationState {
  
  return $NavigationStateCopyWith<$Res>(_self.navigationState, (value) {
    return _then(_self.copyWith(navigationState: value));
  });
}
}


/// Adds pattern-matching-related methods to [NavigationProviderState].
extension NavigationProviderStatePatterns on NavigationProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavigationProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavigationProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavigationProviderState value)  $default,){
final _that = this;
switch (_that) {
case _NavigationProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavigationProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _NavigationProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isNavigating,  AlrtLocation? currentLocation,  AlrtLocation? destination,  List<LatLng> routePoints,  int currentStepIndex,  String? currentInstruction,  double? remainingDistance,  DateTime? estimatedArrival,  double currentSpeed,  double currentBearing,  bool isOffRoute,  bool followUser,  NavigationState navigationState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavigationProviderState() when $default != null:
return $default(_that.isNavigating,_that.currentLocation,_that.destination,_that.routePoints,_that.currentStepIndex,_that.currentInstruction,_that.remainingDistance,_that.estimatedArrival,_that.currentSpeed,_that.currentBearing,_that.isOffRoute,_that.followUser,_that.navigationState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isNavigating,  AlrtLocation? currentLocation,  AlrtLocation? destination,  List<LatLng> routePoints,  int currentStepIndex,  String? currentInstruction,  double? remainingDistance,  DateTime? estimatedArrival,  double currentSpeed,  double currentBearing,  bool isOffRoute,  bool followUser,  NavigationState navigationState)  $default,) {final _that = this;
switch (_that) {
case _NavigationProviderState():
return $default(_that.isNavigating,_that.currentLocation,_that.destination,_that.routePoints,_that.currentStepIndex,_that.currentInstruction,_that.remainingDistance,_that.estimatedArrival,_that.currentSpeed,_that.currentBearing,_that.isOffRoute,_that.followUser,_that.navigationState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isNavigating,  AlrtLocation? currentLocation,  AlrtLocation? destination,  List<LatLng> routePoints,  int currentStepIndex,  String? currentInstruction,  double? remainingDistance,  DateTime? estimatedArrival,  double currentSpeed,  double currentBearing,  bool isOffRoute,  bool followUser,  NavigationState navigationState)?  $default,) {final _that = this;
switch (_that) {
case _NavigationProviderState() when $default != null:
return $default(_that.isNavigating,_that.currentLocation,_that.destination,_that.routePoints,_that.currentStepIndex,_that.currentInstruction,_that.remainingDistance,_that.estimatedArrival,_that.currentSpeed,_that.currentBearing,_that.isOffRoute,_that.followUser,_that.navigationState);case _:
  return null;

}
}

}

/// @nodoc


class _NavigationProviderState implements NavigationProviderState {
  const _NavigationProviderState({this.isNavigating = false, this.currentLocation, this.destination, final  List<LatLng> routePoints = const [], this.currentStepIndex = 0, this.currentInstruction, this.remainingDistance, this.estimatedArrival, this.currentSpeed = 0.0, this.currentBearing = 0.0, this.isOffRoute = false, this.followUser = true, this.navigationState = const NavigationStateIdle()}): _routePoints = routePoints;
  

/// Whether navigation is currently active
@override@JsonKey() final  bool isNavigating;
/// Current user location during navigation
@override final  AlrtLocation? currentLocation;
/// Destination location
@override final  AlrtLocation? destination;
/// Current route polyline points
 final  List<LatLng> _routePoints;
/// Current route polyline points
@override@JsonKey() List<LatLng> get routePoints {
  if (_routePoints is EqualUnmodifiableListView) return _routePoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routePoints);
}

/// Current step index in the navigation
@override@JsonKey() final  int currentStepIndex;
/// Current navigation instruction
@override final  String? currentInstruction;
/// Distance remaining to destination (in meters)
@override final  double? remainingDistance;
/// Estimated time of arrival
@override final  DateTime? estimatedArrival;
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

/// Create a copy of NavigationProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationProviderStateCopyWith<_NavigationProviderState> get copyWith => __$NavigationProviderStateCopyWithImpl<_NavigationProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationProviderState&&(identical(other.isNavigating, isNavigating) || other.isNavigating == isNavigating)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other._routePoints, _routePoints)&&(identical(other.currentStepIndex, currentStepIndex) || other.currentStepIndex == currentStepIndex)&&(identical(other.currentInstruction, currentInstruction) || other.currentInstruction == currentInstruction)&&(identical(other.remainingDistance, remainingDistance) || other.remainingDistance == remainingDistance)&&(identical(other.estimatedArrival, estimatedArrival) || other.estimatedArrival == estimatedArrival)&&(identical(other.currentSpeed, currentSpeed) || other.currentSpeed == currentSpeed)&&(identical(other.currentBearing, currentBearing) || other.currentBearing == currentBearing)&&(identical(other.isOffRoute, isOffRoute) || other.isOffRoute == isOffRoute)&&(identical(other.followUser, followUser) || other.followUser == followUser)&&(identical(other.navigationState, navigationState) || other.navigationState == navigationState));
}


@override
int get hashCode => Object.hash(runtimeType,isNavigating,currentLocation,destination,const DeepCollectionEquality().hash(_routePoints),currentStepIndex,currentInstruction,remainingDistance,estimatedArrival,currentSpeed,currentBearing,isOffRoute,followUser,navigationState);

@override
String toString() {
  return 'NavigationProviderState(isNavigating: $isNavigating, currentLocation: $currentLocation, destination: $destination, routePoints: $routePoints, currentStepIndex: $currentStepIndex, currentInstruction: $currentInstruction, remainingDistance: $remainingDistance, estimatedArrival: $estimatedArrival, currentSpeed: $currentSpeed, currentBearing: $currentBearing, isOffRoute: $isOffRoute, followUser: $followUser, navigationState: $navigationState)';
}


}

/// @nodoc
abstract mixin class _$NavigationProviderStateCopyWith<$Res> implements $NavigationProviderStateCopyWith<$Res> {
  factory _$NavigationProviderStateCopyWith(_NavigationProviderState value, $Res Function(_NavigationProviderState) _then) = __$NavigationProviderStateCopyWithImpl;
@override @useResult
$Res call({
 bool isNavigating, AlrtLocation? currentLocation, AlrtLocation? destination, List<LatLng> routePoints, int currentStepIndex, String? currentInstruction, double? remainingDistance, DateTime? estimatedArrival, double currentSpeed, double currentBearing, bool isOffRoute, bool followUser, NavigationState navigationState
});


@override $AlrtLocationCopyWith<$Res>? get currentLocation;@override $AlrtLocationCopyWith<$Res>? get destination;@override $NavigationStateCopyWith<$Res> get navigationState;

}
/// @nodoc
class __$NavigationProviderStateCopyWithImpl<$Res>
    implements _$NavigationProviderStateCopyWith<$Res> {
  __$NavigationProviderStateCopyWithImpl(this._self, this._then);

  final _NavigationProviderState _self;
  final $Res Function(_NavigationProviderState) _then;

/// Create a copy of NavigationProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isNavigating = null,Object? currentLocation = freezed,Object? destination = freezed,Object? routePoints = null,Object? currentStepIndex = null,Object? currentInstruction = freezed,Object? remainingDistance = freezed,Object? estimatedArrival = freezed,Object? currentSpeed = null,Object? currentBearing = null,Object? isOffRoute = null,Object? followUser = null,Object? navigationState = null,}) {
  return _then(_NavigationProviderState(
isNavigating: null == isNavigating ? _self.isNavigating : isNavigating // ignore: cast_nullable_to_non_nullable
as bool,currentLocation: freezed == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as AlrtLocation?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as AlrtLocation?,routePoints: null == routePoints ? _self._routePoints : routePoints // ignore: cast_nullable_to_non_nullable
as List<LatLng>,currentStepIndex: null == currentStepIndex ? _self.currentStepIndex : currentStepIndex // ignore: cast_nullable_to_non_nullable
as int,currentInstruction: freezed == currentInstruction ? _self.currentInstruction : currentInstruction // ignore: cast_nullable_to_non_nullable
as String?,remainingDistance: freezed == remainingDistance ? _self.remainingDistance : remainingDistance // ignore: cast_nullable_to_non_nullable
as double?,estimatedArrival: freezed == estimatedArrival ? _self.estimatedArrival : estimatedArrival // ignore: cast_nullable_to_non_nullable
as DateTime?,currentSpeed: null == currentSpeed ? _self.currentSpeed : currentSpeed // ignore: cast_nullable_to_non_nullable
as double,currentBearing: null == currentBearing ? _self.currentBearing : currentBearing // ignore: cast_nullable_to_non_nullable
as double,isOffRoute: null == isOffRoute ? _self.isOffRoute : isOffRoute // ignore: cast_nullable_to_non_nullable
as bool,followUser: null == followUser ? _self.followUser : followUser // ignore: cast_nullable_to_non_nullable
as bool,navigationState: null == navigationState ? _self.navigationState : navigationState // ignore: cast_nullable_to_non_nullable
as NavigationState,
  ));
}

/// Create a copy of NavigationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res>? get currentLocation {
    if (_self.currentLocation == null) {
    return null;
  }

  return $AlrtLocationCopyWith<$Res>(_self.currentLocation!, (value) {
    return _then(_self.copyWith(currentLocation: value));
  });
}/// Create a copy of NavigationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $AlrtLocationCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of NavigationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NavigationStateCopyWith<$Res> get navigationState {
  
  return $NavigationStateCopyWith<$Res>(_self.navigationState, (value) {
    return _then(_self.copyWith(navigationState: value));
  });
}
}

/// @nodoc
mixin _$NavigationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationState()';
}


}

/// @nodoc
class $NavigationStateCopyWith<$Res>  {
$NavigationStateCopyWith(NavigationState _, $Res Function(NavigationState) __);
}


/// Adds pattern-matching-related methods to [NavigationState].
extension NavigationStatePatterns on NavigationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NavigationStateIdle value)?  idle,TResult Function( NavigationStateStarting value)?  starting,TResult Function( NavigationStateActive value)?  active,TResult Function( NavigationStatePaused value)?  paused,TResult Function( NavigationStateCompleted value)?  completed,TResult Function( NavigationStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NavigationStateIdle() when idle != null:
return idle(_that);case NavigationStateStarting() when starting != null:
return starting(_that);case NavigationStateActive() when active != null:
return active(_that);case NavigationStatePaused() when paused != null:
return paused(_that);case NavigationStateCompleted() when completed != null:
return completed(_that);case NavigationStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NavigationStateIdle value)  idle,required TResult Function( NavigationStateStarting value)  starting,required TResult Function( NavigationStateActive value)  active,required TResult Function( NavigationStatePaused value)  paused,required TResult Function( NavigationStateCompleted value)  completed,required TResult Function( NavigationStateError value)  error,}){
final _that = this;
switch (_that) {
case NavigationStateIdle():
return idle(_that);case NavigationStateStarting():
return starting(_that);case NavigationStateActive():
return active(_that);case NavigationStatePaused():
return paused(_that);case NavigationStateCompleted():
return completed(_that);case NavigationStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NavigationStateIdle value)?  idle,TResult? Function( NavigationStateStarting value)?  starting,TResult? Function( NavigationStateActive value)?  active,TResult? Function( NavigationStatePaused value)?  paused,TResult? Function( NavigationStateCompleted value)?  completed,TResult? Function( NavigationStateError value)?  error,}){
final _that = this;
switch (_that) {
case NavigationStateIdle() when idle != null:
return idle(_that);case NavigationStateStarting() when starting != null:
return starting(_that);case NavigationStateActive() when active != null:
return active(_that);case NavigationStatePaused() when paused != null:
return paused(_that);case NavigationStateCompleted() when completed != null:
return completed(_that);case NavigationStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  starting,TResult Function()?  active,TResult Function()?  paused,TResult Function()?  completed,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NavigationStateIdle() when idle != null:
return idle();case NavigationStateStarting() when starting != null:
return starting();case NavigationStateActive() when active != null:
return active();case NavigationStatePaused() when paused != null:
return paused();case NavigationStateCompleted() when completed != null:
return completed();case NavigationStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  starting,required TResult Function()  active,required TResult Function()  paused,required TResult Function()  completed,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case NavigationStateIdle():
return idle();case NavigationStateStarting():
return starting();case NavigationStateActive():
return active();case NavigationStatePaused():
return paused();case NavigationStateCompleted():
return completed();case NavigationStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  starting,TResult? Function()?  active,TResult? Function()?  paused,TResult? Function()?  completed,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case NavigationStateIdle() when idle != null:
return idle();case NavigationStateStarting() when starting != null:
return starting();case NavigationStateActive() when active != null:
return active();case NavigationStatePaused() when paused != null:
return paused();case NavigationStateCompleted() when completed != null:
return completed();case NavigationStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class NavigationStateIdle implements NavigationState {
  const NavigationStateIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationStateIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationState.idle()';
}


}




/// @nodoc


class NavigationStateStarting implements NavigationState {
  const NavigationStateStarting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationStateStarting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationState.starting()';
}


}




/// @nodoc


class NavigationStateActive implements NavigationState {
  const NavigationStateActive();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationStateActive);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationState.active()';
}


}




/// @nodoc


class NavigationStatePaused implements NavigationState {
  const NavigationStatePaused();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationStatePaused);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationState.paused()';
}


}




/// @nodoc


class NavigationStateCompleted implements NavigationState {
  const NavigationStateCompleted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationStateCompleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationState.completed()';
}


}




/// @nodoc


class NavigationStateError implements NavigationState {
  const NavigationStateError(this.error);
  

 final  AppError error;

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationStateErrorCopyWith<NavigationStateError> get copyWith => _$NavigationStateErrorCopyWithImpl<NavigationStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'NavigationState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $NavigationStateErrorCopyWith<$Res> implements $NavigationStateCopyWith<$Res> {
  factory $NavigationStateErrorCopyWith(NavigationStateError value, $Res Function(NavigationStateError) _then) = _$NavigationStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class _$NavigationStateErrorCopyWithImpl<$Res>
    implements $NavigationStateErrorCopyWith<$Res> {
  _$NavigationStateErrorCopyWithImpl(this._self, this._then);

  final NavigationStateError _self;
  final $Res Function(NavigationStateError) _then;

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(NavigationStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res> get error {
  
  return $AppErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
