// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_hazard_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ViewHazardResponse {

 String? get message; bool get isViewRecorded;
/// Create a copy of ViewHazardResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewHazardResponseCopyWith<ViewHazardResponse> get copyWith => _$ViewHazardResponseCopyWithImpl<ViewHazardResponse>(this as ViewHazardResponse, _$identity);

  /// Serializes this ViewHazardResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewHazardResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.isViewRecorded, isViewRecorded) || other.isViewRecorded == isViewRecorded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,isViewRecorded);

@override
String toString() {
  return 'ViewHazardResponse(message: $message, isViewRecorded: $isViewRecorded)';
}


}

/// @nodoc
abstract mixin class $ViewHazardResponseCopyWith<$Res>  {
  factory $ViewHazardResponseCopyWith(ViewHazardResponse value, $Res Function(ViewHazardResponse) _then) = _$ViewHazardResponseCopyWithImpl;
@useResult
$Res call({
 String? message, bool isViewRecorded
});




}
/// @nodoc
class _$ViewHazardResponseCopyWithImpl<$Res>
    implements $ViewHazardResponseCopyWith<$Res> {
  _$ViewHazardResponseCopyWithImpl(this._self, this._then);

  final ViewHazardResponse _self;
  final $Res Function(ViewHazardResponse) _then;

/// Create a copy of ViewHazardResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,Object? isViewRecorded = null,}) {
  return _then(_self.copyWith(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,isViewRecorded: null == isViewRecorded ? _self.isViewRecorded : isViewRecorded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ViewHazardResponse].
extension ViewHazardResponsePatterns on ViewHazardResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ViewHazardResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ViewHazardResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ViewHazardResponse value)  $default,){
final _that = this;
switch (_that) {
case _ViewHazardResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ViewHazardResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ViewHazardResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? message,  bool isViewRecorded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ViewHazardResponse() when $default != null:
return $default(_that.message,_that.isViewRecorded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? message,  bool isViewRecorded)  $default,) {final _that = this;
switch (_that) {
case _ViewHazardResponse():
return $default(_that.message,_that.isViewRecorded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? message,  bool isViewRecorded)?  $default,) {final _that = this;
switch (_that) {
case _ViewHazardResponse() when $default != null:
return $default(_that.message,_that.isViewRecorded);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ViewHazardResponse implements ViewHazardResponse {
  const _ViewHazardResponse({this.message, this.isViewRecorded = false});
  factory _ViewHazardResponse.fromJson(Map<String, dynamic> json) => _$ViewHazardResponseFromJson(json);

@override final  String? message;
@override@JsonKey() final  bool isViewRecorded;

/// Create a copy of ViewHazardResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewHazardResponseCopyWith<_ViewHazardResponse> get copyWith => __$ViewHazardResponseCopyWithImpl<_ViewHazardResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ViewHazardResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewHazardResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.isViewRecorded, isViewRecorded) || other.isViewRecorded == isViewRecorded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,isViewRecorded);

@override
String toString() {
  return 'ViewHazardResponse(message: $message, isViewRecorded: $isViewRecorded)';
}


}

/// @nodoc
abstract mixin class _$ViewHazardResponseCopyWith<$Res> implements $ViewHazardResponseCopyWith<$Res> {
  factory _$ViewHazardResponseCopyWith(_ViewHazardResponse value, $Res Function(_ViewHazardResponse) _then) = __$ViewHazardResponseCopyWithImpl;
@override @useResult
$Res call({
 String? message, bool isViewRecorded
});




}
/// @nodoc
class __$ViewHazardResponseCopyWithImpl<$Res>
    implements _$ViewHazardResponseCopyWith<$Res> {
  __$ViewHazardResponseCopyWithImpl(this._self, this._then);

  final _ViewHazardResponse _self;
  final $Res Function(_ViewHazardResponse) _then;

/// Create a copy of ViewHazardResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? isViewRecorded = null,}) {
  return _then(_ViewHazardResponse(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,isViewRecorded: null == isViewRecorded ? _self.isViewRecorded : isViewRecorded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
