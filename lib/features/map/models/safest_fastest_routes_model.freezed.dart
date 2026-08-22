// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safest_fastest_routes_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SafestFastestRoutes {

/// The safest route determined by the application.
 Route get safestRoute;/// The fastest route determined by the application.
 Route get fastestRoute;/// The list of all available routes.
 List<Route> get allRoutes;/// The currently selected route amoung the routes.
 Route? get selectedRoute;/// The turn-by-turn navigation steps for each route in [allRoutes].
///
/// Routes without parsable steps map to an empty list.
 Map<Route, List<RouteStep>> get routeSteps;
/// Create a copy of SafestFastestRoutes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SafestFastestRoutesCopyWith<SafestFastestRoutes> get copyWith => _$SafestFastestRoutesCopyWithImpl<SafestFastestRoutes>(this as SafestFastestRoutes, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SafestFastestRoutes&&(identical(other.safestRoute, safestRoute) || other.safestRoute == safestRoute)&&(identical(other.fastestRoute, fastestRoute) || other.fastestRoute == fastestRoute)&&const DeepCollectionEquality().equals(other.allRoutes, allRoutes)&&(identical(other.selectedRoute, selectedRoute) || other.selectedRoute == selectedRoute)&&const DeepCollectionEquality().equals(other.routeSteps, routeSteps));
}


@override
int get hashCode => Object.hash(runtimeType,safestRoute,fastestRoute,const DeepCollectionEquality().hash(allRoutes),selectedRoute,const DeepCollectionEquality().hash(routeSteps));

@override
String toString() {
  return 'SafestFastestRoutes(safestRoute: $safestRoute, fastestRoute: $fastestRoute, allRoutes: $allRoutes, selectedRoute: $selectedRoute, routeSteps: $routeSteps)';
}


}

/// @nodoc
abstract mixin class $SafestFastestRoutesCopyWith<$Res>  {
  factory $SafestFastestRoutesCopyWith(SafestFastestRoutes value, $Res Function(SafestFastestRoutes) _then) = _$SafestFastestRoutesCopyWithImpl;
@useResult
$Res call({
 Route safestRoute, Route fastestRoute, List<Route> allRoutes, Route? selectedRoute, Map<Route, List<RouteStep>> routeSteps
});




}
/// @nodoc
class _$SafestFastestRoutesCopyWithImpl<$Res>
    implements $SafestFastestRoutesCopyWith<$Res> {
  _$SafestFastestRoutesCopyWithImpl(this._self, this._then);

  final SafestFastestRoutes _self;
  final $Res Function(SafestFastestRoutes) _then;

/// Create a copy of SafestFastestRoutes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? safestRoute = null,Object? fastestRoute = null,Object? allRoutes = null,Object? selectedRoute = freezed,Object? routeSteps = null,}) {
  return _then(_self.copyWith(
safestRoute: null == safestRoute ? _self.safestRoute : safestRoute // ignore: cast_nullable_to_non_nullable
as Route,fastestRoute: null == fastestRoute ? _self.fastestRoute : fastestRoute // ignore: cast_nullable_to_non_nullable
as Route,allRoutes: null == allRoutes ? _self.allRoutes : allRoutes // ignore: cast_nullable_to_non_nullable
as List<Route>,selectedRoute: freezed == selectedRoute ? _self.selectedRoute : selectedRoute // ignore: cast_nullable_to_non_nullable
as Route?,routeSteps: null == routeSteps ? _self.routeSteps : routeSteps // ignore: cast_nullable_to_non_nullable
as Map<Route, List<RouteStep>>,
  ));
}

}


/// Adds pattern-matching-related methods to [SafestFastestRoutes].
extension SafestFastestRoutesPatterns on SafestFastestRoutes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SafestFastestRoutes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SafestFastestRoutes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SafestFastestRoutes value)  $default,){
final _that = this;
switch (_that) {
case _SafestFastestRoutes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SafestFastestRoutes value)?  $default,){
final _that = this;
switch (_that) {
case _SafestFastestRoutes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Route safestRoute,  Route fastestRoute,  List<Route> allRoutes,  Route? selectedRoute,  Map<Route, List<RouteStep>> routeSteps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SafestFastestRoutes() when $default != null:
return $default(_that.safestRoute,_that.fastestRoute,_that.allRoutes,_that.selectedRoute,_that.routeSteps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Route safestRoute,  Route fastestRoute,  List<Route> allRoutes,  Route? selectedRoute,  Map<Route, List<RouteStep>> routeSteps)  $default,) {final _that = this;
switch (_that) {
case _SafestFastestRoutes():
return $default(_that.safestRoute,_that.fastestRoute,_that.allRoutes,_that.selectedRoute,_that.routeSteps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Route safestRoute,  Route fastestRoute,  List<Route> allRoutes,  Route? selectedRoute,  Map<Route, List<RouteStep>> routeSteps)?  $default,) {final _that = this;
switch (_that) {
case _SafestFastestRoutes() when $default != null:
return $default(_that.safestRoute,_that.fastestRoute,_that.allRoutes,_that.selectedRoute,_that.routeSteps);case _:
  return null;

}
}

}

/// @nodoc


class _SafestFastestRoutes extends SafestFastestRoutes {
  const _SafestFastestRoutes({required this.safestRoute, required this.fastestRoute, required final  List<Route> allRoutes, this.selectedRoute, final  Map<Route, List<RouteStep>> routeSteps = const <Route, List<RouteStep>>{}}): _allRoutes = allRoutes,_routeSteps = routeSteps,super._();
  

/// The safest route determined by the application.
@override final  Route safestRoute;
/// The fastest route determined by the application.
@override final  Route fastestRoute;
/// The list of all available routes.
 final  List<Route> _allRoutes;
/// The list of all available routes.
@override List<Route> get allRoutes {
  if (_allRoutes is EqualUnmodifiableListView) return _allRoutes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allRoutes);
}

/// The currently selected route amoung the routes.
@override final  Route? selectedRoute;
/// The turn-by-turn navigation steps for each route in [allRoutes].
///
/// Routes without parsable steps map to an empty list.
 final  Map<Route, List<RouteStep>> _routeSteps;
/// The turn-by-turn navigation steps for each route in [allRoutes].
///
/// Routes without parsable steps map to an empty list.
@override@JsonKey() Map<Route, List<RouteStep>> get routeSteps {
  if (_routeSteps is EqualUnmodifiableMapView) return _routeSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_routeSteps);
}


/// Create a copy of SafestFastestRoutes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SafestFastestRoutesCopyWith<_SafestFastestRoutes> get copyWith => __$SafestFastestRoutesCopyWithImpl<_SafestFastestRoutes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SafestFastestRoutes&&(identical(other.safestRoute, safestRoute) || other.safestRoute == safestRoute)&&(identical(other.fastestRoute, fastestRoute) || other.fastestRoute == fastestRoute)&&const DeepCollectionEquality().equals(other._allRoutes, _allRoutes)&&(identical(other.selectedRoute, selectedRoute) || other.selectedRoute == selectedRoute)&&const DeepCollectionEquality().equals(other._routeSteps, _routeSteps));
}


@override
int get hashCode => Object.hash(runtimeType,safestRoute,fastestRoute,const DeepCollectionEquality().hash(_allRoutes),selectedRoute,const DeepCollectionEquality().hash(_routeSteps));

@override
String toString() {
  return 'SafestFastestRoutes(safestRoute: $safestRoute, fastestRoute: $fastestRoute, allRoutes: $allRoutes, selectedRoute: $selectedRoute, routeSteps: $routeSteps)';
}


}

/// @nodoc
abstract mixin class _$SafestFastestRoutesCopyWith<$Res> implements $SafestFastestRoutesCopyWith<$Res> {
  factory _$SafestFastestRoutesCopyWith(_SafestFastestRoutes value, $Res Function(_SafestFastestRoutes) _then) = __$SafestFastestRoutesCopyWithImpl;
@override @useResult
$Res call({
 Route safestRoute, Route fastestRoute, List<Route> allRoutes, Route? selectedRoute, Map<Route, List<RouteStep>> routeSteps
});




}
/// @nodoc
class __$SafestFastestRoutesCopyWithImpl<$Res>
    implements _$SafestFastestRoutesCopyWith<$Res> {
  __$SafestFastestRoutesCopyWithImpl(this._self, this._then);

  final _SafestFastestRoutes _self;
  final $Res Function(_SafestFastestRoutes) _then;

/// Create a copy of SafestFastestRoutes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? safestRoute = null,Object? fastestRoute = null,Object? allRoutes = null,Object? selectedRoute = freezed,Object? routeSteps = null,}) {
  return _then(_SafestFastestRoutes(
safestRoute: null == safestRoute ? _self.safestRoute : safestRoute // ignore: cast_nullable_to_non_nullable
as Route,fastestRoute: null == fastestRoute ? _self.fastestRoute : fastestRoute // ignore: cast_nullable_to_non_nullable
as Route,allRoutes: null == allRoutes ? _self._allRoutes : allRoutes // ignore: cast_nullable_to_non_nullable
as List<Route>,selectedRoute: freezed == selectedRoute ? _self.selectedRoute : selectedRoute // ignore: cast_nullable_to_non_nullable
as Route?,routeSteps: null == routeSteps ? _self._routeSteps : routeSteps // ignore: cast_nullable_to_non_nullable
as Map<Route, List<RouteStep>>,
  ));
}


}

// dart format on
