// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_plan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoutePlan {

/// The origin location for the route.
 AlrtLocation get origin;/// The destination location for the route.
 AlrtLocation get destination;/// Currently selected travel mode.
 TravelMode get selectedTravelMode;/// Map of travel modes to their corresponding route responses.
 Map<TravelMode, SafestFastestRoutes> get travelModeRoutes;/// The list of hazards to avoid during route planning.
 List<Hazard> get hazardsToAvoid;/// Whether navigation is currently active.
 bool get isNavigating;/// Modes that returned no usable route, with the reason. Kept so the
/// option can still be offered and explained instead of vanishing.
 Map<TravelMode, String> get unavailableModes;
/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutePlanCopyWith<RoutePlan> get copyWith => _$RoutePlanCopyWithImpl<RoutePlan>(this as RoutePlan, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutePlan&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.selectedTravelMode, selectedTravelMode) || other.selectedTravelMode == selectedTravelMode)&&const DeepCollectionEquality().equals(other.travelModeRoutes, travelModeRoutes)&&const DeepCollectionEquality().equals(other.hazardsToAvoid, hazardsToAvoid)&&(identical(other.isNavigating, isNavigating) || other.isNavigating == isNavigating)&&const DeepCollectionEquality().equals(other.unavailableModes, unavailableModes));
}


@override
int get hashCode => Object.hash(runtimeType,origin,destination,selectedTravelMode,const DeepCollectionEquality().hash(travelModeRoutes),const DeepCollectionEquality().hash(hazardsToAvoid),isNavigating,const DeepCollectionEquality().hash(unavailableModes));

@override
String toString() {
  return 'RoutePlan(origin: $origin, destination: $destination, selectedTravelMode: $selectedTravelMode, travelModeRoutes: $travelModeRoutes, hazardsToAvoid: $hazardsToAvoid, isNavigating: $isNavigating, unavailableModes: $unavailableModes)';
}


}

/// @nodoc
abstract mixin class $RoutePlanCopyWith<$Res>  {
  factory $RoutePlanCopyWith(RoutePlan value, $Res Function(RoutePlan) _then) = _$RoutePlanCopyWithImpl;
@useResult
$Res call({
 AlrtLocation origin, AlrtLocation destination, TravelMode selectedTravelMode, Map<TravelMode, SafestFastestRoutes> travelModeRoutes, List<Hazard> hazardsToAvoid, bool isNavigating, Map<TravelMode, String> unavailableModes
});


$AlrtLocationCopyWith<$Res> get origin;$AlrtLocationCopyWith<$Res> get destination;

}
/// @nodoc
class _$RoutePlanCopyWithImpl<$Res>
    implements $RoutePlanCopyWith<$Res> {
  _$RoutePlanCopyWithImpl(this._self, this._then);

  final RoutePlan _self;
  final $Res Function(RoutePlan) _then;

/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? origin = null,Object? destination = null,Object? selectedTravelMode = null,Object? travelModeRoutes = null,Object? hazardsToAvoid = null,Object? isNavigating = null,Object? unavailableModes = null,}) {
  return _then(_self.copyWith(
origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as AlrtLocation,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as AlrtLocation,selectedTravelMode: null == selectedTravelMode ? _self.selectedTravelMode : selectedTravelMode // ignore: cast_nullable_to_non_nullable
as TravelMode,travelModeRoutes: null == travelModeRoutes ? _self.travelModeRoutes : travelModeRoutes // ignore: cast_nullable_to_non_nullable
as Map<TravelMode, SafestFastestRoutes>,hazardsToAvoid: null == hazardsToAvoid ? _self.hazardsToAvoid : hazardsToAvoid // ignore: cast_nullable_to_non_nullable
as List<Hazard>,isNavigating: null == isNavigating ? _self.isNavigating : isNavigating // ignore: cast_nullable_to_non_nullable
as bool,unavailableModes: null == unavailableModes ? _self.unavailableModes : unavailableModes // ignore: cast_nullable_to_non_nullable
as Map<TravelMode, String>,
  ));
}
/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res> get origin {
  
  return $AlrtLocationCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res> get destination {
  
  return $AlrtLocationCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}


/// Adds pattern-matching-related methods to [RoutePlan].
extension RoutePlanPatterns on RoutePlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutePlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutePlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutePlan value)  $default,){
final _that = this;
switch (_that) {
case _RoutePlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutePlan value)?  $default,){
final _that = this;
switch (_that) {
case _RoutePlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AlrtLocation origin,  AlrtLocation destination,  TravelMode selectedTravelMode,  Map<TravelMode, SafestFastestRoutes> travelModeRoutes,  List<Hazard> hazardsToAvoid,  bool isNavigating,  Map<TravelMode, String> unavailableModes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutePlan() when $default != null:
return $default(_that.origin,_that.destination,_that.selectedTravelMode,_that.travelModeRoutes,_that.hazardsToAvoid,_that.isNavigating,_that.unavailableModes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AlrtLocation origin,  AlrtLocation destination,  TravelMode selectedTravelMode,  Map<TravelMode, SafestFastestRoutes> travelModeRoutes,  List<Hazard> hazardsToAvoid,  bool isNavigating,  Map<TravelMode, String> unavailableModes)  $default,) {final _that = this;
switch (_that) {
case _RoutePlan():
return $default(_that.origin,_that.destination,_that.selectedTravelMode,_that.travelModeRoutes,_that.hazardsToAvoid,_that.isNavigating,_that.unavailableModes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AlrtLocation origin,  AlrtLocation destination,  TravelMode selectedTravelMode,  Map<TravelMode, SafestFastestRoutes> travelModeRoutes,  List<Hazard> hazardsToAvoid,  bool isNavigating,  Map<TravelMode, String> unavailableModes)?  $default,) {final _that = this;
switch (_that) {
case _RoutePlan() when $default != null:
return $default(_that.origin,_that.destination,_that.selectedTravelMode,_that.travelModeRoutes,_that.hazardsToAvoid,_that.isNavigating,_that.unavailableModes);case _:
  return null;

}
}

}

/// @nodoc


class _RoutePlan extends RoutePlan {
  const _RoutePlan({required this.origin, required this.destination, this.selectedTravelMode = TravelMode.driving, final  Map<TravelMode, SafestFastestRoutes> travelModeRoutes = const <TravelMode, SafestFastestRoutes>{}, final  List<Hazard> hazardsToAvoid = const <Hazard>[], this.isNavigating = false, final  Map<TravelMode, String> unavailableModes = const <TravelMode, String>{}}): _travelModeRoutes = travelModeRoutes,_hazardsToAvoid = hazardsToAvoid,_unavailableModes = unavailableModes,super._();
  

/// The origin location for the route.
@override final  AlrtLocation origin;
/// The destination location for the route.
@override final  AlrtLocation destination;
/// Currently selected travel mode.
@override@JsonKey() final  TravelMode selectedTravelMode;
/// Map of travel modes to their corresponding route responses.
 final  Map<TravelMode, SafestFastestRoutes> _travelModeRoutes;
/// Map of travel modes to their corresponding route responses.
@override@JsonKey() Map<TravelMode, SafestFastestRoutes> get travelModeRoutes {
  if (_travelModeRoutes is EqualUnmodifiableMapView) return _travelModeRoutes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_travelModeRoutes);
}

/// The list of hazards to avoid during route planning.
 final  List<Hazard> _hazardsToAvoid;
/// The list of hazards to avoid during route planning.
@override@JsonKey() List<Hazard> get hazardsToAvoid {
  if (_hazardsToAvoid is EqualUnmodifiableListView) return _hazardsToAvoid;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazardsToAvoid);
}

/// Whether navigation is currently active.
@override@JsonKey() final  bool isNavigating;
/// Modes that returned no usable route, with the reason. Kept so the
/// option can still be offered and explained instead of vanishing.
 final  Map<TravelMode, String> _unavailableModes;
/// Modes that returned no usable route, with the reason. Kept so the
/// option can still be offered and explained instead of vanishing.
@override@JsonKey() Map<TravelMode, String> get unavailableModes {
  if (_unavailableModes is EqualUnmodifiableMapView) return _unavailableModes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unavailableModes);
}


/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutePlanCopyWith<_RoutePlan> get copyWith => __$RoutePlanCopyWithImpl<_RoutePlan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutePlan&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.selectedTravelMode, selectedTravelMode) || other.selectedTravelMode == selectedTravelMode)&&const DeepCollectionEquality().equals(other._travelModeRoutes, _travelModeRoutes)&&const DeepCollectionEquality().equals(other._hazardsToAvoid, _hazardsToAvoid)&&(identical(other.isNavigating, isNavigating) || other.isNavigating == isNavigating)&&const DeepCollectionEquality().equals(other._unavailableModes, _unavailableModes));
}


@override
int get hashCode => Object.hash(runtimeType,origin,destination,selectedTravelMode,const DeepCollectionEquality().hash(_travelModeRoutes),const DeepCollectionEquality().hash(_hazardsToAvoid),isNavigating,const DeepCollectionEquality().hash(_unavailableModes));

@override
String toString() {
  return 'RoutePlan(origin: $origin, destination: $destination, selectedTravelMode: $selectedTravelMode, travelModeRoutes: $travelModeRoutes, hazardsToAvoid: $hazardsToAvoid, isNavigating: $isNavigating, unavailableModes: $unavailableModes)';
}


}

/// @nodoc
abstract mixin class _$RoutePlanCopyWith<$Res> implements $RoutePlanCopyWith<$Res> {
  factory _$RoutePlanCopyWith(_RoutePlan value, $Res Function(_RoutePlan) _then) = __$RoutePlanCopyWithImpl;
@override @useResult
$Res call({
 AlrtLocation origin, AlrtLocation destination, TravelMode selectedTravelMode, Map<TravelMode, SafestFastestRoutes> travelModeRoutes, List<Hazard> hazardsToAvoid, bool isNavigating, Map<TravelMode, String> unavailableModes
});


@override $AlrtLocationCopyWith<$Res> get origin;@override $AlrtLocationCopyWith<$Res> get destination;

}
/// @nodoc
class __$RoutePlanCopyWithImpl<$Res>
    implements _$RoutePlanCopyWith<$Res> {
  __$RoutePlanCopyWithImpl(this._self, this._then);

  final _RoutePlan _self;
  final $Res Function(_RoutePlan) _then;

/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? origin = null,Object? destination = null,Object? selectedTravelMode = null,Object? travelModeRoutes = null,Object? hazardsToAvoid = null,Object? isNavigating = null,Object? unavailableModes = null,}) {
  return _then(_RoutePlan(
origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as AlrtLocation,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as AlrtLocation,selectedTravelMode: null == selectedTravelMode ? _self.selectedTravelMode : selectedTravelMode // ignore: cast_nullable_to_non_nullable
as TravelMode,travelModeRoutes: null == travelModeRoutes ? _self._travelModeRoutes : travelModeRoutes // ignore: cast_nullable_to_non_nullable
as Map<TravelMode, SafestFastestRoutes>,hazardsToAvoid: null == hazardsToAvoid ? _self._hazardsToAvoid : hazardsToAvoid // ignore: cast_nullable_to_non_nullable
as List<Hazard>,isNavigating: null == isNavigating ? _self.isNavigating : isNavigating // ignore: cast_nullable_to_non_nullable
as bool,unavailableModes: null == unavailableModes ? _self._unavailableModes : unavailableModes // ignore: cast_nullable_to_non_nullable
as Map<TravelMode, String>,
  ));
}

/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res> get origin {
  
  return $AlrtLocationCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RoutePlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res> get destination {
  
  return $AlrtLocationCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}

// dart format on
