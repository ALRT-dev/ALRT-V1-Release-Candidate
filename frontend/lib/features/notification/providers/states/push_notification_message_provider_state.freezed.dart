// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'push_notification_message_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PushNotificationMessageProviderState {

/// The message that is received from the push notification.
 RemoteMessage? get receivedPushNotifMessage;
/// Create a copy of PushNotificationMessageProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushNotificationMessageProviderStateCopyWith<PushNotificationMessageProviderState> get copyWith => _$PushNotificationMessageProviderStateCopyWithImpl<PushNotificationMessageProviderState>(this as PushNotificationMessageProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushNotificationMessageProviderState&&(identical(other.receivedPushNotifMessage, receivedPushNotifMessage) || other.receivedPushNotifMessage == receivedPushNotifMessage));
}


@override
int get hashCode => Object.hash(runtimeType,receivedPushNotifMessage);

@override
String toString() {
  return 'PushNotificationMessageProviderState(receivedPushNotifMessage: $receivedPushNotifMessage)';
}


}

/// @nodoc
abstract mixin class $PushNotificationMessageProviderStateCopyWith<$Res>  {
  factory $PushNotificationMessageProviderStateCopyWith(PushNotificationMessageProviderState value, $Res Function(PushNotificationMessageProviderState) _then) = _$PushNotificationMessageProviderStateCopyWithImpl;
@useResult
$Res call({
 RemoteMessage? receivedPushNotifMessage
});




}
/// @nodoc
class _$PushNotificationMessageProviderStateCopyWithImpl<$Res>
    implements $PushNotificationMessageProviderStateCopyWith<$Res> {
  _$PushNotificationMessageProviderStateCopyWithImpl(this._self, this._then);

  final PushNotificationMessageProviderState _self;
  final $Res Function(PushNotificationMessageProviderState) _then;

/// Create a copy of PushNotificationMessageProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? receivedPushNotifMessage = freezed,}) {
  return _then(_self.copyWith(
receivedPushNotifMessage: freezed == receivedPushNotifMessage ? _self.receivedPushNotifMessage : receivedPushNotifMessage // ignore: cast_nullable_to_non_nullable
as RemoteMessage?,
  ));
}

}


/// Adds pattern-matching-related methods to [PushNotificationMessageProviderState].
extension PushNotificationMessageProviderStatePatterns on PushNotificationMessageProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PushNotificationMessageProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PushNotificationMessageProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PushNotificationMessageProviderState value)  $default,){
final _that = this;
switch (_that) {
case _PushNotificationMessageProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PushNotificationMessageProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _PushNotificationMessageProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RemoteMessage? receivedPushNotifMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PushNotificationMessageProviderState() when $default != null:
return $default(_that.receivedPushNotifMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RemoteMessage? receivedPushNotifMessage)  $default,) {final _that = this;
switch (_that) {
case _PushNotificationMessageProviderState():
return $default(_that.receivedPushNotifMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RemoteMessage? receivedPushNotifMessage)?  $default,) {final _that = this;
switch (_that) {
case _PushNotificationMessageProviderState() when $default != null:
return $default(_that.receivedPushNotifMessage);case _:
  return null;

}
}

}

/// @nodoc


class _PushNotificationMessageProviderState implements PushNotificationMessageProviderState {
  const _PushNotificationMessageProviderState({this.receivedPushNotifMessage});
  

/// The message that is received from the push notification.
@override final  RemoteMessage? receivedPushNotifMessage;

/// Create a copy of PushNotificationMessageProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PushNotificationMessageProviderStateCopyWith<_PushNotificationMessageProviderState> get copyWith => __$PushNotificationMessageProviderStateCopyWithImpl<_PushNotificationMessageProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PushNotificationMessageProviderState&&(identical(other.receivedPushNotifMessage, receivedPushNotifMessage) || other.receivedPushNotifMessage == receivedPushNotifMessage));
}


@override
int get hashCode => Object.hash(runtimeType,receivedPushNotifMessage);

@override
String toString() {
  return 'PushNotificationMessageProviderState(receivedPushNotifMessage: $receivedPushNotifMessage)';
}


}

/// @nodoc
abstract mixin class _$PushNotificationMessageProviderStateCopyWith<$Res> implements $PushNotificationMessageProviderStateCopyWith<$Res> {
  factory _$PushNotificationMessageProviderStateCopyWith(_PushNotificationMessageProviderState value, $Res Function(_PushNotificationMessageProviderState) _then) = __$PushNotificationMessageProviderStateCopyWithImpl;
@override @useResult
$Res call({
 RemoteMessage? receivedPushNotifMessage
});




}
/// @nodoc
class __$PushNotificationMessageProviderStateCopyWithImpl<$Res>
    implements _$PushNotificationMessageProviderStateCopyWith<$Res> {
  __$PushNotificationMessageProviderStateCopyWithImpl(this._self, this._then);

  final _PushNotificationMessageProviderState _self;
  final $Res Function(_PushNotificationMessageProviderState) _then;

/// Create a copy of PushNotificationMessageProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? receivedPushNotifMessage = freezed,}) {
  return _then(_PushNotificationMessageProviderState(
receivedPushNotifMessage: freezed == receivedPushNotifMessage ? _self.receivedPushNotifMessage : receivedPushNotifMessage // ignore: cast_nullable_to_non_nullable
as RemoteMessage?,
  ));
}


}

// dart format on
