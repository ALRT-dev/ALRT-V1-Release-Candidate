// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blocked_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BlockedUser {

 String get userId; String get name; DateTime? get blockedAt;
/// Create a copy of BlockedUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockedUserCopyWith<BlockedUser> get copyWith => _$BlockedUserCopyWithImpl<BlockedUser>(this as BlockedUser, _$identity);

  /// Serializes this BlockedUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockedUser&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.blockedAt, blockedAt) || other.blockedAt == blockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,blockedAt);

@override
String toString() {
  return 'BlockedUser(userId: $userId, name: $name, blockedAt: $blockedAt)';
}


}

/// @nodoc
abstract mixin class $BlockedUserCopyWith<$Res>  {
  factory $BlockedUserCopyWith(BlockedUser value, $Res Function(BlockedUser) _then) = _$BlockedUserCopyWithImpl;
@useResult
$Res call({
 String userId, String name, DateTime? blockedAt
});




}
/// @nodoc
class _$BlockedUserCopyWithImpl<$Res>
    implements $BlockedUserCopyWith<$Res> {
  _$BlockedUserCopyWithImpl(this._self, this._then);

  final BlockedUser _self;
  final $Res Function(BlockedUser) _then;

/// Create a copy of BlockedUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? blockedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BlockedUser].
extension BlockedUserPatterns on BlockedUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlockedUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlockedUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlockedUser value)  $default,){
final _that = this;
switch (_that) {
case _BlockedUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlockedUser value)?  $default,){
final _that = this;
switch (_that) {
case _BlockedUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String name,  DateTime? blockedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlockedUser() when $default != null:
return $default(_that.userId,_that.name,_that.blockedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String name,  DateTime? blockedAt)  $default,) {final _that = this;
switch (_that) {
case _BlockedUser():
return $default(_that.userId,_that.name,_that.blockedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String name,  DateTime? blockedAt)?  $default,) {final _that = this;
switch (_that) {
case _BlockedUser() when $default != null:
return $default(_that.userId,_that.name,_that.blockedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BlockedUser implements BlockedUser {
  const _BlockedUser({required this.userId, this.name = 'Community member', this.blockedAt});
  factory _BlockedUser.fromJson(Map<String, dynamic> json) => _$BlockedUserFromJson(json);

@override final  String userId;
@override@JsonKey() final  String name;
@override final  DateTime? blockedAt;

/// Create a copy of BlockedUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockedUserCopyWith<_BlockedUser> get copyWith => __$BlockedUserCopyWithImpl<_BlockedUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlockedUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlockedUser&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.blockedAt, blockedAt) || other.blockedAt == blockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,blockedAt);

@override
String toString() {
  return 'BlockedUser(userId: $userId, name: $name, blockedAt: $blockedAt)';
}


}

/// @nodoc
abstract mixin class _$BlockedUserCopyWith<$Res> implements $BlockedUserCopyWith<$Res> {
  factory _$BlockedUserCopyWith(_BlockedUser value, $Res Function(_BlockedUser) _then) = __$BlockedUserCopyWithImpl;
@override @useResult
$Res call({
 String userId, String name, DateTime? blockedAt
});




}
/// @nodoc
class __$BlockedUserCopyWithImpl<$Res>
    implements _$BlockedUserCopyWith<$Res> {
  __$BlockedUserCopyWithImpl(this._self, this._then);

  final _BlockedUser _self;
  final $Res Function(_BlockedUser) _then;

/// Create a copy of BlockedUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? blockedAt = freezed,}) {
  return _then(_BlockedUser(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BlockedUsersResponse {

 List<BlockedUser> get blocked;
/// Create a copy of BlockedUsersResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockedUsersResponseCopyWith<BlockedUsersResponse> get copyWith => _$BlockedUsersResponseCopyWithImpl<BlockedUsersResponse>(this as BlockedUsersResponse, _$identity);

  /// Serializes this BlockedUsersResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockedUsersResponse&&const DeepCollectionEquality().equals(other.blocked, blocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(blocked));

@override
String toString() {
  return 'BlockedUsersResponse(blocked: $blocked)';
}


}

/// @nodoc
abstract mixin class $BlockedUsersResponseCopyWith<$Res>  {
  factory $BlockedUsersResponseCopyWith(BlockedUsersResponse value, $Res Function(BlockedUsersResponse) _then) = _$BlockedUsersResponseCopyWithImpl;
@useResult
$Res call({
 List<BlockedUser> blocked
});




}
/// @nodoc
class _$BlockedUsersResponseCopyWithImpl<$Res>
    implements $BlockedUsersResponseCopyWith<$Res> {
  _$BlockedUsersResponseCopyWithImpl(this._self, this._then);

  final BlockedUsersResponse _self;
  final $Res Function(BlockedUsersResponse) _then;

/// Create a copy of BlockedUsersResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blocked = null,}) {
  return _then(_self.copyWith(
blocked: null == blocked ? _self.blocked : blocked // ignore: cast_nullable_to_non_nullable
as List<BlockedUser>,
  ));
}

}


/// Adds pattern-matching-related methods to [BlockedUsersResponse].
extension BlockedUsersResponsePatterns on BlockedUsersResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlockedUsersResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlockedUsersResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlockedUsersResponse value)  $default,){
final _that = this;
switch (_that) {
case _BlockedUsersResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlockedUsersResponse value)?  $default,){
final _that = this;
switch (_that) {
case _BlockedUsersResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BlockedUser> blocked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlockedUsersResponse() when $default != null:
return $default(_that.blocked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BlockedUser> blocked)  $default,) {final _that = this;
switch (_that) {
case _BlockedUsersResponse():
return $default(_that.blocked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BlockedUser> blocked)?  $default,) {final _that = this;
switch (_that) {
case _BlockedUsersResponse() when $default != null:
return $default(_that.blocked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BlockedUsersResponse implements BlockedUsersResponse {
  const _BlockedUsersResponse({final  List<BlockedUser> blocked = const <BlockedUser>[]}): _blocked = blocked;
  factory _BlockedUsersResponse.fromJson(Map<String, dynamic> json) => _$BlockedUsersResponseFromJson(json);

 final  List<BlockedUser> _blocked;
@override@JsonKey() List<BlockedUser> get blocked {
  if (_blocked is EqualUnmodifiableListView) return _blocked;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocked);
}


/// Create a copy of BlockedUsersResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockedUsersResponseCopyWith<_BlockedUsersResponse> get copyWith => __$BlockedUsersResponseCopyWithImpl<_BlockedUsersResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlockedUsersResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlockedUsersResponse&&const DeepCollectionEquality().equals(other._blocked, _blocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_blocked));

@override
String toString() {
  return 'BlockedUsersResponse(blocked: $blocked)';
}


}

/// @nodoc
abstract mixin class _$BlockedUsersResponseCopyWith<$Res> implements $BlockedUsersResponseCopyWith<$Res> {
  factory _$BlockedUsersResponseCopyWith(_BlockedUsersResponse value, $Res Function(_BlockedUsersResponse) _then) = __$BlockedUsersResponseCopyWithImpl;
@override @useResult
$Res call({
 List<BlockedUser> blocked
});




}
/// @nodoc
class __$BlockedUsersResponseCopyWithImpl<$Res>
    implements _$BlockedUsersResponseCopyWith<$Res> {
  __$BlockedUsersResponseCopyWithImpl(this._self, this._then);

  final _BlockedUsersResponse _self;
  final $Res Function(_BlockedUsersResponse) _then;

/// Create a copy of BlockedUsersResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blocked = null,}) {
  return _then(_BlockedUsersResponse(
blocked: null == blocked ? _self._blocked : blocked // ignore: cast_nullable_to_non_nullable
as List<BlockedUser>,
  ));
}


}

// dart format on
