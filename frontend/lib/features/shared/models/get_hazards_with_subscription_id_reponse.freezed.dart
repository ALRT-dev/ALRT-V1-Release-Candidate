// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_hazards_with_subscription_id_reponse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GetHazardsWithSubscriptionIdResponse {

/// The list of hazards.
 List<Hazard> get hazards;/// The subscription ID associated with the hazards retrieval.
 String? get subscriptionId;
/// Create a copy of GetHazardsWithSubscriptionIdResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetHazardsWithSubscriptionIdResponseCopyWith<GetHazardsWithSubscriptionIdResponse> get copyWith => _$GetHazardsWithSubscriptionIdResponseCopyWithImpl<GetHazardsWithSubscriptionIdResponse>(this as GetHazardsWithSubscriptionIdResponse, _$identity);

  /// Serializes this GetHazardsWithSubscriptionIdResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetHazardsWithSubscriptionIdResponse&&const DeepCollectionEquality().equals(other.hazards, hazards)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(hazards),subscriptionId);

@override
String toString() {
  return 'GetHazardsWithSubscriptionIdResponse(hazards: $hazards, subscriptionId: $subscriptionId)';
}


}

/// @nodoc
abstract mixin class $GetHazardsWithSubscriptionIdResponseCopyWith<$Res>  {
  factory $GetHazardsWithSubscriptionIdResponseCopyWith(GetHazardsWithSubscriptionIdResponse value, $Res Function(GetHazardsWithSubscriptionIdResponse) _then) = _$GetHazardsWithSubscriptionIdResponseCopyWithImpl;
@useResult
$Res call({
 List<Hazard> hazards, String? subscriptionId
});




}
/// @nodoc
class _$GetHazardsWithSubscriptionIdResponseCopyWithImpl<$Res>
    implements $GetHazardsWithSubscriptionIdResponseCopyWith<$Res> {
  _$GetHazardsWithSubscriptionIdResponseCopyWithImpl(this._self, this._then);

  final GetHazardsWithSubscriptionIdResponse _self;
  final $Res Function(GetHazardsWithSubscriptionIdResponse) _then;

/// Create a copy of GetHazardsWithSubscriptionIdResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hazards = null,Object? subscriptionId = freezed,}) {
  return _then(_self.copyWith(
hazards: null == hazards ? _self.hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GetHazardsWithSubscriptionIdResponse].
extension GetHazardsWithSubscriptionIdResponsePatterns on GetHazardsWithSubscriptionIdResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GetHazardsWithSubscriptionIdResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetHazardsWithSubscriptionIdResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GetHazardsWithSubscriptionIdResponse value)  $default,){
final _that = this;
switch (_that) {
case _GetHazardsWithSubscriptionIdResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GetHazardsWithSubscriptionIdResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GetHazardsWithSubscriptionIdResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Hazard> hazards,  String? subscriptionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetHazardsWithSubscriptionIdResponse() when $default != null:
return $default(_that.hazards,_that.subscriptionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Hazard> hazards,  String? subscriptionId)  $default,) {final _that = this;
switch (_that) {
case _GetHazardsWithSubscriptionIdResponse():
return $default(_that.hazards,_that.subscriptionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Hazard> hazards,  String? subscriptionId)?  $default,) {final _that = this;
switch (_that) {
case _GetHazardsWithSubscriptionIdResponse() when $default != null:
return $default(_that.hazards,_that.subscriptionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GetHazardsWithSubscriptionIdResponse implements GetHazardsWithSubscriptionIdResponse {
  const _GetHazardsWithSubscriptionIdResponse({final  List<Hazard> hazards = const <Hazard>[], this.subscriptionId}): _hazards = hazards;
  factory _GetHazardsWithSubscriptionIdResponse.fromJson(Map<String, dynamic> json) => _$GetHazardsWithSubscriptionIdResponseFromJson(json);

/// The list of hazards.
 final  List<Hazard> _hazards;
/// The list of hazards.
@override@JsonKey() List<Hazard> get hazards {
  if (_hazards is EqualUnmodifiableListView) return _hazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazards);
}

/// The subscription ID associated with the hazards retrieval.
@override final  String? subscriptionId;

/// Create a copy of GetHazardsWithSubscriptionIdResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetHazardsWithSubscriptionIdResponseCopyWith<_GetHazardsWithSubscriptionIdResponse> get copyWith => __$GetHazardsWithSubscriptionIdResponseCopyWithImpl<_GetHazardsWithSubscriptionIdResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GetHazardsWithSubscriptionIdResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetHazardsWithSubscriptionIdResponse&&const DeepCollectionEquality().equals(other._hazards, _hazards)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_hazards),subscriptionId);

@override
String toString() {
  return 'GetHazardsWithSubscriptionIdResponse(hazards: $hazards, subscriptionId: $subscriptionId)';
}


}

/// @nodoc
abstract mixin class _$GetHazardsWithSubscriptionIdResponseCopyWith<$Res> implements $GetHazardsWithSubscriptionIdResponseCopyWith<$Res> {
  factory _$GetHazardsWithSubscriptionIdResponseCopyWith(_GetHazardsWithSubscriptionIdResponse value, $Res Function(_GetHazardsWithSubscriptionIdResponse) _then) = __$GetHazardsWithSubscriptionIdResponseCopyWithImpl;
@override @useResult
$Res call({
 List<Hazard> hazards, String? subscriptionId
});




}
/// @nodoc
class __$GetHazardsWithSubscriptionIdResponseCopyWithImpl<$Res>
    implements _$GetHazardsWithSubscriptionIdResponseCopyWith<$Res> {
  __$GetHazardsWithSubscriptionIdResponseCopyWithImpl(this._self, this._then);

  final _GetHazardsWithSubscriptionIdResponse _self;
  final $Res Function(_GetHazardsWithSubscriptionIdResponse) _then;

/// Create a copy of GetHazardsWithSubscriptionIdResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hazards = null,Object? subscriptionId = freezed,}) {
  return _then(_GetHazardsWithSubscriptionIdResponse(
hazards: null == hazards ? _self._hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
