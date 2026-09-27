// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hazard_corridor_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HazardCorridor {

/// The hazards (≥ 1) that share this corridor.
 List<Hazard> get hazards;/// Index on the active route polyline of the closest segment vertex
/// before the cluster (inclusive).
 int get entryPolylineIndex;/// Index on the active route polyline of the closest segment vertex
/// after the cluster (inclusive).
 int get exitPolylineIndex;/// Polyline vertex matching [entryPolylineIndex].
 LatLng get entryPoint;/// Polyline vertex matching [exitPolylineIndex].
 LatLng get exitPoint;/// Centroid of the cluster's hazards in lat/lng.
 LatLng get centerPoint;/// Buffer (in meters) used by the intersection check to decide whether a
/// candidate detour polyline still passes too close to this corridor.
 double get bufferMeters;
/// Create a copy of HazardCorridor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HazardCorridorCopyWith<HazardCorridor> get copyWith => _$HazardCorridorCopyWithImpl<HazardCorridor>(this as HazardCorridor, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HazardCorridor&&const DeepCollectionEquality().equals(other.hazards, hazards)&&(identical(other.entryPolylineIndex, entryPolylineIndex) || other.entryPolylineIndex == entryPolylineIndex)&&(identical(other.exitPolylineIndex, exitPolylineIndex) || other.exitPolylineIndex == exitPolylineIndex)&&(identical(other.entryPoint, entryPoint) || other.entryPoint == entryPoint)&&(identical(other.exitPoint, exitPoint) || other.exitPoint == exitPoint)&&(identical(other.centerPoint, centerPoint) || other.centerPoint == centerPoint)&&(identical(other.bufferMeters, bufferMeters) || other.bufferMeters == bufferMeters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(hazards),entryPolylineIndex,exitPolylineIndex,entryPoint,exitPoint,centerPoint,bufferMeters);

@override
String toString() {
  return 'HazardCorridor(hazards: $hazards, entryPolylineIndex: $entryPolylineIndex, exitPolylineIndex: $exitPolylineIndex, entryPoint: $entryPoint, exitPoint: $exitPoint, centerPoint: $centerPoint, bufferMeters: $bufferMeters)';
}


}

/// @nodoc
abstract mixin class $HazardCorridorCopyWith<$Res>  {
  factory $HazardCorridorCopyWith(HazardCorridor value, $Res Function(HazardCorridor) _then) = _$HazardCorridorCopyWithImpl;
@useResult
$Res call({
 List<Hazard> hazards, int entryPolylineIndex, int exitPolylineIndex, LatLng entryPoint, LatLng exitPoint, LatLng centerPoint, double bufferMeters
});




}
/// @nodoc
class _$HazardCorridorCopyWithImpl<$Res>
    implements $HazardCorridorCopyWith<$Res> {
  _$HazardCorridorCopyWithImpl(this._self, this._then);

  final HazardCorridor _self;
  final $Res Function(HazardCorridor) _then;

/// Create a copy of HazardCorridor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hazards = null,Object? entryPolylineIndex = null,Object? exitPolylineIndex = null,Object? entryPoint = null,Object? exitPoint = null,Object? centerPoint = null,Object? bufferMeters = null,}) {
  return _then(_self.copyWith(
hazards: null == hazards ? _self.hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,entryPolylineIndex: null == entryPolylineIndex ? _self.entryPolylineIndex : entryPolylineIndex // ignore: cast_nullable_to_non_nullable
as int,exitPolylineIndex: null == exitPolylineIndex ? _self.exitPolylineIndex : exitPolylineIndex // ignore: cast_nullable_to_non_nullable
as int,entryPoint: null == entryPoint ? _self.entryPoint : entryPoint // ignore: cast_nullable_to_non_nullable
as LatLng,exitPoint: null == exitPoint ? _self.exitPoint : exitPoint // ignore: cast_nullable_to_non_nullable
as LatLng,centerPoint: null == centerPoint ? _self.centerPoint : centerPoint // ignore: cast_nullable_to_non_nullable
as LatLng,bufferMeters: null == bufferMeters ? _self.bufferMeters : bufferMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [HazardCorridor].
extension HazardCorridorPatterns on HazardCorridor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HazardCorridor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HazardCorridor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HazardCorridor value)  $default,){
final _that = this;
switch (_that) {
case _HazardCorridor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HazardCorridor value)?  $default,){
final _that = this;
switch (_that) {
case _HazardCorridor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Hazard> hazards,  int entryPolylineIndex,  int exitPolylineIndex,  LatLng entryPoint,  LatLng exitPoint,  LatLng centerPoint,  double bufferMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HazardCorridor() when $default != null:
return $default(_that.hazards,_that.entryPolylineIndex,_that.exitPolylineIndex,_that.entryPoint,_that.exitPoint,_that.centerPoint,_that.bufferMeters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Hazard> hazards,  int entryPolylineIndex,  int exitPolylineIndex,  LatLng entryPoint,  LatLng exitPoint,  LatLng centerPoint,  double bufferMeters)  $default,) {final _that = this;
switch (_that) {
case _HazardCorridor():
return $default(_that.hazards,_that.entryPolylineIndex,_that.exitPolylineIndex,_that.entryPoint,_that.exitPoint,_that.centerPoint,_that.bufferMeters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Hazard> hazards,  int entryPolylineIndex,  int exitPolylineIndex,  LatLng entryPoint,  LatLng exitPoint,  LatLng centerPoint,  double bufferMeters)?  $default,) {final _that = this;
switch (_that) {
case _HazardCorridor() when $default != null:
return $default(_that.hazards,_that.entryPolylineIndex,_that.exitPolylineIndex,_that.entryPoint,_that.exitPoint,_that.centerPoint,_that.bufferMeters);case _:
  return null;

}
}

}

/// @nodoc


class _HazardCorridor implements HazardCorridor {
  const _HazardCorridor({required final  List<Hazard> hazards, required this.entryPolylineIndex, required this.exitPolylineIndex, required this.entryPoint, required this.exitPoint, required this.centerPoint, this.bufferMeters = 220.0}): _hazards = hazards;
  

/// The hazards (≥ 1) that share this corridor.
 final  List<Hazard> _hazards;
/// The hazards (≥ 1) that share this corridor.
@override List<Hazard> get hazards {
  if (_hazards is EqualUnmodifiableListView) return _hazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazards);
}

/// Index on the active route polyline of the closest segment vertex
/// before the cluster (inclusive).
@override final  int entryPolylineIndex;
/// Index on the active route polyline of the closest segment vertex
/// after the cluster (inclusive).
@override final  int exitPolylineIndex;
/// Polyline vertex matching [entryPolylineIndex].
@override final  LatLng entryPoint;
/// Polyline vertex matching [exitPolylineIndex].
@override final  LatLng exitPoint;
/// Centroid of the cluster's hazards in lat/lng.
@override final  LatLng centerPoint;
/// Buffer (in meters) used by the intersection check to decide whether a
/// candidate detour polyline still passes too close to this corridor.
@override@JsonKey() final  double bufferMeters;

/// Create a copy of HazardCorridor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HazardCorridorCopyWith<_HazardCorridor> get copyWith => __$HazardCorridorCopyWithImpl<_HazardCorridor>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HazardCorridor&&const DeepCollectionEquality().equals(other._hazards, _hazards)&&(identical(other.entryPolylineIndex, entryPolylineIndex) || other.entryPolylineIndex == entryPolylineIndex)&&(identical(other.exitPolylineIndex, exitPolylineIndex) || other.exitPolylineIndex == exitPolylineIndex)&&(identical(other.entryPoint, entryPoint) || other.entryPoint == entryPoint)&&(identical(other.exitPoint, exitPoint) || other.exitPoint == exitPoint)&&(identical(other.centerPoint, centerPoint) || other.centerPoint == centerPoint)&&(identical(other.bufferMeters, bufferMeters) || other.bufferMeters == bufferMeters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_hazards),entryPolylineIndex,exitPolylineIndex,entryPoint,exitPoint,centerPoint,bufferMeters);

@override
String toString() {
  return 'HazardCorridor(hazards: $hazards, entryPolylineIndex: $entryPolylineIndex, exitPolylineIndex: $exitPolylineIndex, entryPoint: $entryPoint, exitPoint: $exitPoint, centerPoint: $centerPoint, bufferMeters: $bufferMeters)';
}


}

/// @nodoc
abstract mixin class _$HazardCorridorCopyWith<$Res> implements $HazardCorridorCopyWith<$Res> {
  factory _$HazardCorridorCopyWith(_HazardCorridor value, $Res Function(_HazardCorridor) _then) = __$HazardCorridorCopyWithImpl;
@override @useResult
$Res call({
 List<Hazard> hazards, int entryPolylineIndex, int exitPolylineIndex, LatLng entryPoint, LatLng exitPoint, LatLng centerPoint, double bufferMeters
});




}
/// @nodoc
class __$HazardCorridorCopyWithImpl<$Res>
    implements _$HazardCorridorCopyWith<$Res> {
  __$HazardCorridorCopyWithImpl(this._self, this._then);

  final _HazardCorridor _self;
  final $Res Function(_HazardCorridor) _then;

/// Create a copy of HazardCorridor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hazards = null,Object? entryPolylineIndex = null,Object? exitPolylineIndex = null,Object? entryPoint = null,Object? exitPoint = null,Object? centerPoint = null,Object? bufferMeters = null,}) {
  return _then(_HazardCorridor(
hazards: null == hazards ? _self._hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,entryPolylineIndex: null == entryPolylineIndex ? _self.entryPolylineIndex : entryPolylineIndex // ignore: cast_nullable_to_non_nullable
as int,exitPolylineIndex: null == exitPolylineIndex ? _self.exitPolylineIndex : exitPolylineIndex // ignore: cast_nullable_to_non_nullable
as int,entryPoint: null == entryPoint ? _self.entryPoint : entryPoint // ignore: cast_nullable_to_non_nullable
as LatLng,exitPoint: null == exitPoint ? _self.exitPoint : exitPoint // ignore: cast_nullable_to_non_nullable
as LatLng,centerPoint: null == centerPoint ? _self.centerPoint : centerPoint // ignore: cast_nullable_to_non_nullable
as LatLng,bufferMeters: null == bufferMeters ? _self.bufferMeters : bufferMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
