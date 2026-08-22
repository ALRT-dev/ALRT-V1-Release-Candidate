// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alrt_location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlrtLocation {

 double get latitude; double get longitude; String? get address; String? get name; AlrtLocationBounds? get bounds;
/// Create a copy of AlrtLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<AlrtLocation> get copyWith => _$AlrtLocationCopyWithImpl<AlrtLocation>(this as AlrtLocation, _$identity);

  /// Serializes this AlrtLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlrtLocation&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address)&&(identical(other.name, name) || other.name == name)&&(identical(other.bounds, bounds) || other.bounds == bounds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,address,name,bounds);

@override
String toString() {
  return 'AlrtLocation(latitude: $latitude, longitude: $longitude, address: $address, name: $name, bounds: $bounds)';
}


}

/// @nodoc
abstract mixin class $AlrtLocationCopyWith<$Res>  {
  factory $AlrtLocationCopyWith(AlrtLocation value, $Res Function(AlrtLocation) _then) = _$AlrtLocationCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, String? address, String? name, AlrtLocationBounds? bounds
});


$AlrtLocationBoundsCopyWith<$Res>? get bounds;

}
/// @nodoc
class _$AlrtLocationCopyWithImpl<$Res>
    implements $AlrtLocationCopyWith<$Res> {
  _$AlrtLocationCopyWithImpl(this._self, this._then);

  final AlrtLocation _self;
  final $Res Function(AlrtLocation) _then;

/// Create a copy of AlrtLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? address = freezed,Object? name = freezed,Object? bounds = freezed,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,bounds: freezed == bounds ? _self.bounds : bounds // ignore: cast_nullable_to_non_nullable
as AlrtLocationBounds?,
  ));
}
/// Create a copy of AlrtLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationBoundsCopyWith<$Res>? get bounds {
    if (_self.bounds == null) {
    return null;
  }

  return $AlrtLocationBoundsCopyWith<$Res>(_self.bounds!, (value) {
    return _then(_self.copyWith(bounds: value));
  });
}
}


/// Adds pattern-matching-related methods to [AlrtLocation].
extension AlrtLocationPatterns on AlrtLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlrtLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlrtLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlrtLocation value)  $default,){
final _that = this;
switch (_that) {
case _AlrtLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlrtLocation value)?  $default,){
final _that = this;
switch (_that) {
case _AlrtLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  String? address,  String? name,  AlrtLocationBounds? bounds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlrtLocation() when $default != null:
return $default(_that.latitude,_that.longitude,_that.address,_that.name,_that.bounds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  String? address,  String? name,  AlrtLocationBounds? bounds)  $default,) {final _that = this;
switch (_that) {
case _AlrtLocation():
return $default(_that.latitude,_that.longitude,_that.address,_that.name,_that.bounds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  String? address,  String? name,  AlrtLocationBounds? bounds)?  $default,) {final _that = this;
switch (_that) {
case _AlrtLocation() when $default != null:
return $default(_that.latitude,_that.longitude,_that.address,_that.name,_that.bounds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlrtLocation extends AlrtLocation {
  const _AlrtLocation({required this.latitude, required this.longitude, this.address, this.name, this.bounds}): super._();
  factory _AlrtLocation.fromJson(Map<String, dynamic> json) => _$AlrtLocationFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override final  String? address;
@override final  String? name;
@override final  AlrtLocationBounds? bounds;

/// Create a copy of AlrtLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlrtLocationCopyWith<_AlrtLocation> get copyWith => __$AlrtLocationCopyWithImpl<_AlrtLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlrtLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlrtLocation&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address)&&(identical(other.name, name) || other.name == name)&&(identical(other.bounds, bounds) || other.bounds == bounds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,address,name,bounds);

@override
String toString() {
  return 'AlrtLocation(latitude: $latitude, longitude: $longitude, address: $address, name: $name, bounds: $bounds)';
}


}

/// @nodoc
abstract mixin class _$AlrtLocationCopyWith<$Res> implements $AlrtLocationCopyWith<$Res> {
  factory _$AlrtLocationCopyWith(_AlrtLocation value, $Res Function(_AlrtLocation) _then) = __$AlrtLocationCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, String? address, String? name, AlrtLocationBounds? bounds
});


@override $AlrtLocationBoundsCopyWith<$Res>? get bounds;

}
/// @nodoc
class __$AlrtLocationCopyWithImpl<$Res>
    implements _$AlrtLocationCopyWith<$Res> {
  __$AlrtLocationCopyWithImpl(this._self, this._then);

  final _AlrtLocation _self;
  final $Res Function(_AlrtLocation) _then;

/// Create a copy of AlrtLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? address = freezed,Object? name = freezed,Object? bounds = freezed,}) {
  return _then(_AlrtLocation(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,bounds: freezed == bounds ? _self.bounds : bounds // ignore: cast_nullable_to_non_nullable
as AlrtLocationBounds?,
  ));
}

/// Create a copy of AlrtLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationBoundsCopyWith<$Res>? get bounds {
    if (_self.bounds == null) {
    return null;
  }

  return $AlrtLocationBoundsCopyWith<$Res>(_self.bounds!, (value) {
    return _then(_self.copyWith(bounds: value));
  });
}
}

// dart format on
