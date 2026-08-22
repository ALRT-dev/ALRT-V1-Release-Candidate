// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_subscription_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationSubscription {

/// The subscription's unique identifier.
 String? get id;/// The northeast latitude of the subscription area.
 double get northeastLat;/// The northeast longitude of the subscription area.
 double get northeastLng;/// The southwest latitude of the subscription area.
 double get southwestLat;/// The southwest longitude of the subscription area.
 double get southwestLng;/// Indicates if this subscription is for the user's own location.
 bool get isOwnLocation;/// The name of the location.
 String? get name;/// The human-readable address of the location.
 String? get address;/// The timestamp when the subscription was created.
 DateTime? get createdAt;/// The timestamp when the subscription was last updated.
 DateTime? get updatedAt;
/// Create a copy of LocationSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationSubscriptionCopyWith<LocationSubscription> get copyWith => _$LocationSubscriptionCopyWithImpl<LocationSubscription>(this as LocationSubscription, _$identity);

  /// Serializes this LocationSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.northeastLat, northeastLat) || other.northeastLat == northeastLat)&&(identical(other.northeastLng, northeastLng) || other.northeastLng == northeastLng)&&(identical(other.southwestLat, southwestLat) || other.southwestLat == southwestLat)&&(identical(other.southwestLng, southwestLng) || other.southwestLng == southwestLng)&&(identical(other.isOwnLocation, isOwnLocation) || other.isOwnLocation == isOwnLocation)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,northeastLat,northeastLng,southwestLat,southwestLng,isOwnLocation,name,address,createdAt,updatedAt);

@override
String toString() {
  return 'LocationSubscription(id: $id, northeastLat: $northeastLat, northeastLng: $northeastLng, southwestLat: $southwestLat, southwestLng: $southwestLng, isOwnLocation: $isOwnLocation, name: $name, address: $address, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $LocationSubscriptionCopyWith<$Res>  {
  factory $LocationSubscriptionCopyWith(LocationSubscription value, $Res Function(LocationSubscription) _then) = _$LocationSubscriptionCopyWithImpl;
@useResult
$Res call({
 String? id, double northeastLat, double northeastLng, double southwestLat, double southwestLng, bool isOwnLocation, String? name, String? address, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$LocationSubscriptionCopyWithImpl<$Res>
    implements $LocationSubscriptionCopyWith<$Res> {
  _$LocationSubscriptionCopyWithImpl(this._self, this._then);

  final LocationSubscription _self;
  final $Res Function(LocationSubscription) _then;

/// Create a copy of LocationSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? northeastLat = null,Object? northeastLng = null,Object? southwestLat = null,Object? southwestLng = null,Object? isOwnLocation = null,Object? name = freezed,Object? address = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,northeastLat: null == northeastLat ? _self.northeastLat : northeastLat // ignore: cast_nullable_to_non_nullable
as double,northeastLng: null == northeastLng ? _self.northeastLng : northeastLng // ignore: cast_nullable_to_non_nullable
as double,southwestLat: null == southwestLat ? _self.southwestLat : southwestLat // ignore: cast_nullable_to_non_nullable
as double,southwestLng: null == southwestLng ? _self.southwestLng : southwestLng // ignore: cast_nullable_to_non_nullable
as double,isOwnLocation: null == isOwnLocation ? _self.isOwnLocation : isOwnLocation // ignore: cast_nullable_to_non_nullable
as bool,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationSubscription].
extension LocationSubscriptionPatterns on LocationSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationSubscription value)  $default,){
final _that = this;
switch (_that) {
case _LocationSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _LocationSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  double northeastLat,  double northeastLng,  double southwestLat,  double southwestLng,  bool isOwnLocation,  String? name,  String? address,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationSubscription() when $default != null:
return $default(_that.id,_that.northeastLat,_that.northeastLng,_that.southwestLat,_that.southwestLng,_that.isOwnLocation,_that.name,_that.address,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  double northeastLat,  double northeastLng,  double southwestLat,  double southwestLng,  bool isOwnLocation,  String? name,  String? address,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _LocationSubscription():
return $default(_that.id,_that.northeastLat,_that.northeastLng,_that.southwestLat,_that.southwestLng,_that.isOwnLocation,_that.name,_that.address,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  double northeastLat,  double northeastLng,  double southwestLat,  double southwestLng,  bool isOwnLocation,  String? name,  String? address,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _LocationSubscription() when $default != null:
return $default(_that.id,_that.northeastLat,_that.northeastLng,_that.southwestLat,_that.southwestLng,_that.isOwnLocation,_that.name,_that.address,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationSubscription extends LocationSubscription {
  const _LocationSubscription({this.id, required this.northeastLat, required this.northeastLng, required this.southwestLat, required this.southwestLng, this.isOwnLocation = false, this.name, this.address, this.createdAt, this.updatedAt}): super._();
  factory _LocationSubscription.fromJson(Map<String, dynamic> json) => _$LocationSubscriptionFromJson(json);

/// The subscription's unique identifier.
@override final  String? id;
/// The northeast latitude of the subscription area.
@override final  double northeastLat;
/// The northeast longitude of the subscription area.
@override final  double northeastLng;
/// The southwest latitude of the subscription area.
@override final  double southwestLat;
/// The southwest longitude of the subscription area.
@override final  double southwestLng;
/// Indicates if this subscription is for the user's own location.
@override@JsonKey() final  bool isOwnLocation;
/// The name of the location.
@override final  String? name;
/// The human-readable address of the location.
@override final  String? address;
/// The timestamp when the subscription was created.
@override final  DateTime? createdAt;
/// The timestamp when the subscription was last updated.
@override final  DateTime? updatedAt;

/// Create a copy of LocationSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationSubscriptionCopyWith<_LocationSubscription> get copyWith => __$LocationSubscriptionCopyWithImpl<_LocationSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.northeastLat, northeastLat) || other.northeastLat == northeastLat)&&(identical(other.northeastLng, northeastLng) || other.northeastLng == northeastLng)&&(identical(other.southwestLat, southwestLat) || other.southwestLat == southwestLat)&&(identical(other.southwestLng, southwestLng) || other.southwestLng == southwestLng)&&(identical(other.isOwnLocation, isOwnLocation) || other.isOwnLocation == isOwnLocation)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,northeastLat,northeastLng,southwestLat,southwestLng,isOwnLocation,name,address,createdAt,updatedAt);

@override
String toString() {
  return 'LocationSubscription(id: $id, northeastLat: $northeastLat, northeastLng: $northeastLng, southwestLat: $southwestLat, southwestLng: $southwestLng, isOwnLocation: $isOwnLocation, name: $name, address: $address, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LocationSubscriptionCopyWith<$Res> implements $LocationSubscriptionCopyWith<$Res> {
  factory _$LocationSubscriptionCopyWith(_LocationSubscription value, $Res Function(_LocationSubscription) _then) = __$LocationSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String? id, double northeastLat, double northeastLng, double southwestLat, double southwestLng, bool isOwnLocation, String? name, String? address, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$LocationSubscriptionCopyWithImpl<$Res>
    implements _$LocationSubscriptionCopyWith<$Res> {
  __$LocationSubscriptionCopyWithImpl(this._self, this._then);

  final _LocationSubscription _self;
  final $Res Function(_LocationSubscription) _then;

/// Create a copy of LocationSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? northeastLat = null,Object? northeastLng = null,Object? southwestLat = null,Object? southwestLng = null,Object? isOwnLocation = null,Object? name = freezed,Object? address = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_LocationSubscription(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,northeastLat: null == northeastLat ? _self.northeastLat : northeastLat // ignore: cast_nullable_to_non_nullable
as double,northeastLng: null == northeastLng ? _self.northeastLng : northeastLng // ignore: cast_nullable_to_non_nullable
as double,southwestLat: null == southwestLat ? _self.southwestLat : southwestLat // ignore: cast_nullable_to_non_nullable
as double,southwestLng: null == southwestLng ? _self.southwestLng : southwestLng // ignore: cast_nullable_to_non_nullable
as double,isOwnLocation: null == isOwnLocation ? _self.isOwnLocation : isOwnLocation // ignore: cast_nullable_to_non_nullable
as bool,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
