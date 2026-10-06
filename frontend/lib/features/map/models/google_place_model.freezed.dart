// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'google_place_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GooglePlace {

@JsonKey(name: 'place_id') String get placeId; String get description; double get latitude; double get longitude; String get name; String get address; AlrtLocationBounds get bounds;
/// Create a copy of GooglePlace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GooglePlaceCopyWith<GooglePlace> get copyWith => _$GooglePlaceCopyWithImpl<GooglePlace>(this as GooglePlace, _$identity);

  /// Serializes this GooglePlace to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GooglePlace&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.description, description) || other.description == description)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.bounds, bounds) || other.bounds == bounds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,description,latitude,longitude,name,address,bounds);

@override
String toString() {
  return 'GooglePlace(placeId: $placeId, description: $description, latitude: $latitude, longitude: $longitude, name: $name, address: $address, bounds: $bounds)';
}


}

/// @nodoc
abstract mixin class $GooglePlaceCopyWith<$Res>  {
  factory $GooglePlaceCopyWith(GooglePlace value, $Res Function(GooglePlace) _then) = _$GooglePlaceCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'place_id') String placeId, String description, double latitude, double longitude, String name, String address, AlrtLocationBounds bounds
});


$AlrtLocationBoundsCopyWith<$Res> get bounds;

}
/// @nodoc
class _$GooglePlaceCopyWithImpl<$Res>
    implements $GooglePlaceCopyWith<$Res> {
  _$GooglePlaceCopyWithImpl(this._self, this._then);

  final GooglePlace _self;
  final $Res Function(GooglePlace) _then;

/// Create a copy of GooglePlace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? description = null,Object? latitude = null,Object? longitude = null,Object? name = null,Object? address = null,Object? bounds = null,}) {
  return _then(_self.copyWith(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,bounds: null == bounds ? _self.bounds : bounds // ignore: cast_nullable_to_non_nullable
as AlrtLocationBounds,
  ));
}
/// Create a copy of GooglePlace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationBoundsCopyWith<$Res> get bounds {
  
  return $AlrtLocationBoundsCopyWith<$Res>(_self.bounds, (value) {
    return _then(_self.copyWith(bounds: value));
  });
}
}


/// Adds pattern-matching-related methods to [GooglePlace].
extension GooglePlacePatterns on GooglePlace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GooglePlace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GooglePlace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GooglePlace value)  $default,){
final _that = this;
switch (_that) {
case _GooglePlace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GooglePlace value)?  $default,){
final _that = this;
switch (_that) {
case _GooglePlace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'place_id')  String placeId,  String description,  double latitude,  double longitude,  String name,  String address,  AlrtLocationBounds bounds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GooglePlace() when $default != null:
return $default(_that.placeId,_that.description,_that.latitude,_that.longitude,_that.name,_that.address,_that.bounds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'place_id')  String placeId,  String description,  double latitude,  double longitude,  String name,  String address,  AlrtLocationBounds bounds)  $default,) {final _that = this;
switch (_that) {
case _GooglePlace():
return $default(_that.placeId,_that.description,_that.latitude,_that.longitude,_that.name,_that.address,_that.bounds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'place_id')  String placeId,  String description,  double latitude,  double longitude,  String name,  String address,  AlrtLocationBounds bounds)?  $default,) {final _that = this;
switch (_that) {
case _GooglePlace() when $default != null:
return $default(_that.placeId,_that.description,_that.latitude,_that.longitude,_that.name,_that.address,_that.bounds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GooglePlace extends GooglePlace {
  const _GooglePlace({@JsonKey(name: 'place_id') required this.placeId, required this.description, required this.latitude, required this.longitude, required this.name, required this.address, required this.bounds}): super._();
  factory _GooglePlace.fromJson(Map<String, dynamic> json) => _$GooglePlaceFromJson(json);

@override@JsonKey(name: 'place_id') final  String placeId;
@override final  String description;
@override final  double latitude;
@override final  double longitude;
@override final  String name;
@override final  String address;
@override final  AlrtLocationBounds bounds;

/// Create a copy of GooglePlace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GooglePlaceCopyWith<_GooglePlace> get copyWith => __$GooglePlaceCopyWithImpl<_GooglePlace>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GooglePlaceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GooglePlace&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.description, description) || other.description == description)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.bounds, bounds) || other.bounds == bounds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,description,latitude,longitude,name,address,bounds);

@override
String toString() {
  return 'GooglePlace(placeId: $placeId, description: $description, latitude: $latitude, longitude: $longitude, name: $name, address: $address, bounds: $bounds)';
}


}

/// @nodoc
abstract mixin class _$GooglePlaceCopyWith<$Res> implements $GooglePlaceCopyWith<$Res> {
  factory _$GooglePlaceCopyWith(_GooglePlace value, $Res Function(_GooglePlace) _then) = __$GooglePlaceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'place_id') String placeId, String description, double latitude, double longitude, String name, String address, AlrtLocationBounds bounds
});


@override $AlrtLocationBoundsCopyWith<$Res> get bounds;

}
/// @nodoc
class __$GooglePlaceCopyWithImpl<$Res>
    implements _$GooglePlaceCopyWith<$Res> {
  __$GooglePlaceCopyWithImpl(this._self, this._then);

  final _GooglePlace _self;
  final $Res Function(_GooglePlace) _then;

/// Create a copy of GooglePlace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? description = null,Object? latitude = null,Object? longitude = null,Object? name = null,Object? address = null,Object? bounds = null,}) {
  return _then(_GooglePlace(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,bounds: null == bounds ? _self.bounds : bounds // ignore: cast_nullable_to_non_nullable
as AlrtLocationBounds,
  ));
}

/// Create a copy of GooglePlace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationBoundsCopyWith<$Res> get bounds {
  
  return $AlrtLocationBoundsCopyWith<$Res>(_self.bounds, (value) {
    return _then(_self.copyWith(bounds: value));
  });
}
}

// dart format on
