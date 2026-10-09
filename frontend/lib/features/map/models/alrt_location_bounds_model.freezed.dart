// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alrt_location_bounds_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlrtLocationBounds {

 double get northeastLat; double get northeastLng; double get southwestLat; double get southwestLng;
/// Create a copy of AlrtLocationBounds
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlrtLocationBoundsCopyWith<AlrtLocationBounds> get copyWith => _$AlrtLocationBoundsCopyWithImpl<AlrtLocationBounds>(this as AlrtLocationBounds, _$identity);

  /// Serializes this AlrtLocationBounds to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlrtLocationBounds&&(identical(other.northeastLat, northeastLat) || other.northeastLat == northeastLat)&&(identical(other.northeastLng, northeastLng) || other.northeastLng == northeastLng)&&(identical(other.southwestLat, southwestLat) || other.southwestLat == southwestLat)&&(identical(other.southwestLng, southwestLng) || other.southwestLng == southwestLng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,northeastLat,northeastLng,southwestLat,southwestLng);

@override
String toString() {
  return 'AlrtLocationBounds(northeastLat: $northeastLat, northeastLng: $northeastLng, southwestLat: $southwestLat, southwestLng: $southwestLng)';
}


}

/// @nodoc
abstract mixin class $AlrtLocationBoundsCopyWith<$Res>  {
  factory $AlrtLocationBoundsCopyWith(AlrtLocationBounds value, $Res Function(AlrtLocationBounds) _then) = _$AlrtLocationBoundsCopyWithImpl;
@useResult
$Res call({
 double northeastLat, double northeastLng, double southwestLat, double southwestLng
});




}
/// @nodoc
class _$AlrtLocationBoundsCopyWithImpl<$Res>
    implements $AlrtLocationBoundsCopyWith<$Res> {
  _$AlrtLocationBoundsCopyWithImpl(this._self, this._then);

  final AlrtLocationBounds _self;
  final $Res Function(AlrtLocationBounds) _then;

/// Create a copy of AlrtLocationBounds
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? northeastLat = null,Object? northeastLng = null,Object? southwestLat = null,Object? southwestLng = null,}) {
  return _then(_self.copyWith(
northeastLat: null == northeastLat ? _self.northeastLat : northeastLat // ignore: cast_nullable_to_non_nullable
as double,northeastLng: null == northeastLng ? _self.northeastLng : northeastLng // ignore: cast_nullable_to_non_nullable
as double,southwestLat: null == southwestLat ? _self.southwestLat : southwestLat // ignore: cast_nullable_to_non_nullable
as double,southwestLng: null == southwestLng ? _self.southwestLng : southwestLng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AlrtLocationBounds].
extension AlrtLocationBoundsPatterns on AlrtLocationBounds {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlrtLocationBounds value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlrtLocationBounds() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlrtLocationBounds value)  $default,){
final _that = this;
switch (_that) {
case _AlrtLocationBounds():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlrtLocationBounds value)?  $default,){
final _that = this;
switch (_that) {
case _AlrtLocationBounds() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double northeastLat,  double northeastLng,  double southwestLat,  double southwestLng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlrtLocationBounds() when $default != null:
return $default(_that.northeastLat,_that.northeastLng,_that.southwestLat,_that.southwestLng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double northeastLat,  double northeastLng,  double southwestLat,  double southwestLng)  $default,) {final _that = this;
switch (_that) {
case _AlrtLocationBounds():
return $default(_that.northeastLat,_that.northeastLng,_that.southwestLat,_that.southwestLng);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double northeastLat,  double northeastLng,  double southwestLat,  double southwestLng)?  $default,) {final _that = this;
switch (_that) {
case _AlrtLocationBounds() when $default != null:
return $default(_that.northeastLat,_that.northeastLng,_that.southwestLat,_that.southwestLng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlrtLocationBounds implements AlrtLocationBounds {
  const _AlrtLocationBounds({required this.northeastLat, required this.northeastLng, required this.southwestLat, required this.southwestLng});
  factory _AlrtLocationBounds.fromJson(Map<String, dynamic> json) => _$AlrtLocationBoundsFromJson(json);

@override final  double northeastLat;
@override final  double northeastLng;
@override final  double southwestLat;
@override final  double southwestLng;

/// Create a copy of AlrtLocationBounds
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlrtLocationBoundsCopyWith<_AlrtLocationBounds> get copyWith => __$AlrtLocationBoundsCopyWithImpl<_AlrtLocationBounds>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlrtLocationBoundsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlrtLocationBounds&&(identical(other.northeastLat, northeastLat) || other.northeastLat == northeastLat)&&(identical(other.northeastLng, northeastLng) || other.northeastLng == northeastLng)&&(identical(other.southwestLat, southwestLat) || other.southwestLat == southwestLat)&&(identical(other.southwestLng, southwestLng) || other.southwestLng == southwestLng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,northeastLat,northeastLng,southwestLat,southwestLng);

@override
String toString() {
  return 'AlrtLocationBounds(northeastLat: $northeastLat, northeastLng: $northeastLng, southwestLat: $southwestLat, southwestLng: $southwestLng)';
}


}

/// @nodoc
abstract mixin class _$AlrtLocationBoundsCopyWith<$Res> implements $AlrtLocationBoundsCopyWith<$Res> {
  factory _$AlrtLocationBoundsCopyWith(_AlrtLocationBounds value, $Res Function(_AlrtLocationBounds) _then) = __$AlrtLocationBoundsCopyWithImpl;
@override @useResult
$Res call({
 double northeastLat, double northeastLng, double southwestLat, double southwestLng
});




}
/// @nodoc
class __$AlrtLocationBoundsCopyWithImpl<$Res>
    implements _$AlrtLocationBoundsCopyWith<$Res> {
  __$AlrtLocationBoundsCopyWithImpl(this._self, this._then);

  final _AlrtLocationBounds _self;
  final $Res Function(_AlrtLocationBounds) _then;

/// Create a copy of AlrtLocationBounds
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? northeastLat = null,Object? northeastLng = null,Object? southwestLat = null,Object? southwestLng = null,}) {
  return _then(_AlrtLocationBounds(
northeastLat: null == northeastLat ? _self.northeastLat : northeastLat // ignore: cast_nullable_to_non_nullable
as double,northeastLng: null == northeastLng ? _self.northeastLng : northeastLng // ignore: cast_nullable_to_non_nullable
as double,southwestLat: null == southwestLat ? _self.southwestLat : southwestLat // ignore: cast_nullable_to_non_nullable
as double,southwestLng: null == southwestLng ? _self.southwestLng : southwestLng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
