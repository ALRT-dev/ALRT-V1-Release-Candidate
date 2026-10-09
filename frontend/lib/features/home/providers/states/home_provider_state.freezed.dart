// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeProviderState {

/// The state of sending push notification token to the server
 SendPushNotificationTokenState get sendPushNotificationTokenState;/// The state of updating user location
 UpdateUserLocationState get updateUserLocationState;/// Set when the notification priming screen should be shown (permission
/// missing and the "maybe later" snooze has lapsed). Null otherwise.
 NotificationPrimingKind? get notificationPrimingRequest;
/// Create a copy of HomeProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeProviderStateCopyWith<HomeProviderState> get copyWith => _$HomeProviderStateCopyWithImpl<HomeProviderState>(this as HomeProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeProviderState&&(identical(other.sendPushNotificationTokenState, sendPushNotificationTokenState) || other.sendPushNotificationTokenState == sendPushNotificationTokenState)&&(identical(other.updateUserLocationState, updateUserLocationState) || other.updateUserLocationState == updateUserLocationState)&&(identical(other.notificationPrimingRequest, notificationPrimingRequest) || other.notificationPrimingRequest == notificationPrimingRequest));
}


@override
int get hashCode => Object.hash(runtimeType,sendPushNotificationTokenState,updateUserLocationState,notificationPrimingRequest);

@override
String toString() {
  return 'HomeProviderState(sendPushNotificationTokenState: $sendPushNotificationTokenState, updateUserLocationState: $updateUserLocationState, notificationPrimingRequest: $notificationPrimingRequest)';
}


}

/// @nodoc
abstract mixin class $HomeProviderStateCopyWith<$Res>  {
  factory $HomeProviderStateCopyWith(HomeProviderState value, $Res Function(HomeProviderState) _then) = _$HomeProviderStateCopyWithImpl;
@useResult
$Res call({
 SendPushNotificationTokenState sendPushNotificationTokenState, UpdateUserLocationState updateUserLocationState, NotificationPrimingKind? notificationPrimingRequest
});


$SendPushNotificationTokenStateCopyWith<$Res> get sendPushNotificationTokenState;$UpdateUserLocationStateCopyWith<$Res> get updateUserLocationState;

}
/// @nodoc
class _$HomeProviderStateCopyWithImpl<$Res>
    implements $HomeProviderStateCopyWith<$Res> {
  _$HomeProviderStateCopyWithImpl(this._self, this._then);

  final HomeProviderState _self;
  final $Res Function(HomeProviderState) _then;

/// Create a copy of HomeProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sendPushNotificationTokenState = null,Object? updateUserLocationState = null,Object? notificationPrimingRequest = freezed,}) {
  return _then(_self.copyWith(
sendPushNotificationTokenState: null == sendPushNotificationTokenState ? _self.sendPushNotificationTokenState : sendPushNotificationTokenState // ignore: cast_nullable_to_non_nullable
as SendPushNotificationTokenState,updateUserLocationState: null == updateUserLocationState ? _self.updateUserLocationState : updateUserLocationState // ignore: cast_nullable_to_non_nullable
as UpdateUserLocationState,notificationPrimingRequest: freezed == notificationPrimingRequest ? _self.notificationPrimingRequest : notificationPrimingRequest // ignore: cast_nullable_to_non_nullable
as NotificationPrimingKind?,
  ));
}
/// Create a copy of HomeProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SendPushNotificationTokenStateCopyWith<$Res> get sendPushNotificationTokenState {
  
  return $SendPushNotificationTokenStateCopyWith<$Res>(_self.sendPushNotificationTokenState, (value) {
    return _then(_self.copyWith(sendPushNotificationTokenState: value));
  });
}/// Create a copy of HomeProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateUserLocationStateCopyWith<$Res> get updateUserLocationState {
  
  return $UpdateUserLocationStateCopyWith<$Res>(_self.updateUserLocationState, (value) {
    return _then(_self.copyWith(updateUserLocationState: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeProviderState].
extension HomeProviderStatePatterns on HomeProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeProviderState value)  $default,){
final _that = this;
switch (_that) {
case _HomeProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SendPushNotificationTokenState sendPushNotificationTokenState,  UpdateUserLocationState updateUserLocationState,  NotificationPrimingKind? notificationPrimingRequest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeProviderState() when $default != null:
return $default(_that.sendPushNotificationTokenState,_that.updateUserLocationState,_that.notificationPrimingRequest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SendPushNotificationTokenState sendPushNotificationTokenState,  UpdateUserLocationState updateUserLocationState,  NotificationPrimingKind? notificationPrimingRequest)  $default,) {final _that = this;
switch (_that) {
case _HomeProviderState():
return $default(_that.sendPushNotificationTokenState,_that.updateUserLocationState,_that.notificationPrimingRequest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SendPushNotificationTokenState sendPushNotificationTokenState,  UpdateUserLocationState updateUserLocationState,  NotificationPrimingKind? notificationPrimingRequest)?  $default,) {final _that = this;
switch (_that) {
case _HomeProviderState() when $default != null:
return $default(_that.sendPushNotificationTokenState,_that.updateUserLocationState,_that.notificationPrimingRequest);case _:
  return null;

}
}

}

/// @nodoc


class _HomeProviderState implements HomeProviderState {
  const _HomeProviderState({this.sendPushNotificationTokenState = const SendPushNotificationTokenState.initial(), this.updateUserLocationState = const UpdateUserLocationState.initial(), this.notificationPrimingRequest});
  

/// The state of sending push notification token to the server
@override@JsonKey() final  SendPushNotificationTokenState sendPushNotificationTokenState;
/// The state of updating user location
@override@JsonKey() final  UpdateUserLocationState updateUserLocationState;
/// Set when the notification priming screen should be shown (permission
/// missing and the "maybe later" snooze has lapsed). Null otherwise.
@override final  NotificationPrimingKind? notificationPrimingRequest;

/// Create a copy of HomeProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeProviderStateCopyWith<_HomeProviderState> get copyWith => __$HomeProviderStateCopyWithImpl<_HomeProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeProviderState&&(identical(other.sendPushNotificationTokenState, sendPushNotificationTokenState) || other.sendPushNotificationTokenState == sendPushNotificationTokenState)&&(identical(other.updateUserLocationState, updateUserLocationState) || other.updateUserLocationState == updateUserLocationState)&&(identical(other.notificationPrimingRequest, notificationPrimingRequest) || other.notificationPrimingRequest == notificationPrimingRequest));
}


@override
int get hashCode => Object.hash(runtimeType,sendPushNotificationTokenState,updateUserLocationState,notificationPrimingRequest);

@override
String toString() {
  return 'HomeProviderState(sendPushNotificationTokenState: $sendPushNotificationTokenState, updateUserLocationState: $updateUserLocationState, notificationPrimingRequest: $notificationPrimingRequest)';
}


}

/// @nodoc
abstract mixin class _$HomeProviderStateCopyWith<$Res> implements $HomeProviderStateCopyWith<$Res> {
  factory _$HomeProviderStateCopyWith(_HomeProviderState value, $Res Function(_HomeProviderState) _then) = __$HomeProviderStateCopyWithImpl;
@override @useResult
$Res call({
 SendPushNotificationTokenState sendPushNotificationTokenState, UpdateUserLocationState updateUserLocationState, NotificationPrimingKind? notificationPrimingRequest
});


@override $SendPushNotificationTokenStateCopyWith<$Res> get sendPushNotificationTokenState;@override $UpdateUserLocationStateCopyWith<$Res> get updateUserLocationState;

}
/// @nodoc
class __$HomeProviderStateCopyWithImpl<$Res>
    implements _$HomeProviderStateCopyWith<$Res> {
  __$HomeProviderStateCopyWithImpl(this._self, this._then);

  final _HomeProviderState _self;
  final $Res Function(_HomeProviderState) _then;

/// Create a copy of HomeProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sendPushNotificationTokenState = null,Object? updateUserLocationState = null,Object? notificationPrimingRequest = freezed,}) {
  return _then(_HomeProviderState(
sendPushNotificationTokenState: null == sendPushNotificationTokenState ? _self.sendPushNotificationTokenState : sendPushNotificationTokenState // ignore: cast_nullable_to_non_nullable
as SendPushNotificationTokenState,updateUserLocationState: null == updateUserLocationState ? _self.updateUserLocationState : updateUserLocationState // ignore: cast_nullable_to_non_nullable
as UpdateUserLocationState,notificationPrimingRequest: freezed == notificationPrimingRequest ? _self.notificationPrimingRequest : notificationPrimingRequest // ignore: cast_nullable_to_non_nullable
as NotificationPrimingKind?,
  ));
}

/// Create a copy of HomeProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SendPushNotificationTokenStateCopyWith<$Res> get sendPushNotificationTokenState {
  
  return $SendPushNotificationTokenStateCopyWith<$Res>(_self.sendPushNotificationTokenState, (value) {
    return _then(_self.copyWith(sendPushNotificationTokenState: value));
  });
}/// Create a copy of HomeProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateUserLocationStateCopyWith<$Res> get updateUserLocationState {
  
  return $UpdateUserLocationStateCopyWith<$Res>(_self.updateUserLocationState, (value) {
    return _then(_self.copyWith(updateUserLocationState: value));
  });
}
}

/// @nodoc
mixin _$SendPushNotificationTokenState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendPushNotificationTokenState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SendPushNotificationTokenState()';
}


}

/// @nodoc
class $SendPushNotificationTokenStateCopyWith<$Res>  {
$SendPushNotificationTokenStateCopyWith(SendPushNotificationTokenState _, $Res Function(SendPushNotificationTokenState) __);
}


/// Adds pattern-matching-related methods to [SendPushNotificationTokenState].
extension SendPushNotificationTokenStatePatterns on SendPushNotificationTokenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SendPushNotificationTokenStateInitial value)?  initial,TResult Function( _SendPushNotificationTokenStateLoading value)?  loading,TResult Function( _SendPushNotificationTokenStateSuccess value)?  success,TResult Function( _SendPushNotificationTokenStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendPushNotificationTokenStateInitial() when initial != null:
return initial(_that);case _SendPushNotificationTokenStateLoading() when loading != null:
return loading(_that);case _SendPushNotificationTokenStateSuccess() when success != null:
return success(_that);case _SendPushNotificationTokenStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SendPushNotificationTokenStateInitial value)  initial,required TResult Function( _SendPushNotificationTokenStateLoading value)  loading,required TResult Function( _SendPushNotificationTokenStateSuccess value)  success,required TResult Function( _SendPushNotificationTokenStateError value)  error,}){
final _that = this;
switch (_that) {
case _SendPushNotificationTokenStateInitial():
return initial(_that);case _SendPushNotificationTokenStateLoading():
return loading(_that);case _SendPushNotificationTokenStateSuccess():
return success(_that);case _SendPushNotificationTokenStateError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SendPushNotificationTokenStateInitial value)?  initial,TResult? Function( _SendPushNotificationTokenStateLoading value)?  loading,TResult? Function( _SendPushNotificationTokenStateSuccess value)?  success,TResult? Function( _SendPushNotificationTokenStateError value)?  error,}){
final _that = this;
switch (_that) {
case _SendPushNotificationTokenStateInitial() when initial != null:
return initial(_that);case _SendPushNotificationTokenStateLoading() when loading != null:
return loading(_that);case _SendPushNotificationTokenStateSuccess() when success != null:
return success(_that);case _SendPushNotificationTokenStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String token)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendPushNotificationTokenStateInitial() when initial != null:
return initial();case _SendPushNotificationTokenStateLoading() when loading != null:
return loading();case _SendPushNotificationTokenStateSuccess() when success != null:
return success(_that.token);case _SendPushNotificationTokenStateError() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String token)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _SendPushNotificationTokenStateInitial():
return initial();case _SendPushNotificationTokenStateLoading():
return loading();case _SendPushNotificationTokenStateSuccess():
return success(_that.token);case _SendPushNotificationTokenStateError():
return error(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String token)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _SendPushNotificationTokenStateInitial() when initial != null:
return initial();case _SendPushNotificationTokenStateLoading() when loading != null:
return loading();case _SendPushNotificationTokenStateSuccess() when success != null:
return success(_that.token);case _SendPushNotificationTokenStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _SendPushNotificationTokenStateInitial implements SendPushNotificationTokenState {
  const _SendPushNotificationTokenStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendPushNotificationTokenStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SendPushNotificationTokenState.initial()';
}


}




/// @nodoc


class _SendPushNotificationTokenStateLoading implements SendPushNotificationTokenState {
  const _SendPushNotificationTokenStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendPushNotificationTokenStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SendPushNotificationTokenState.loading()';
}


}




/// @nodoc


class _SendPushNotificationTokenStateSuccess implements SendPushNotificationTokenState {
  const _SendPushNotificationTokenStateSuccess(this.token);
  

 final  String token;

/// Create a copy of SendPushNotificationTokenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendPushNotificationTokenStateSuccessCopyWith<_SendPushNotificationTokenStateSuccess> get copyWith => __$SendPushNotificationTokenStateSuccessCopyWithImpl<_SendPushNotificationTokenStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendPushNotificationTokenStateSuccess&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'SendPushNotificationTokenState.success(token: $token)';
}


}

/// @nodoc
abstract mixin class _$SendPushNotificationTokenStateSuccessCopyWith<$Res> implements $SendPushNotificationTokenStateCopyWith<$Res> {
  factory _$SendPushNotificationTokenStateSuccessCopyWith(_SendPushNotificationTokenStateSuccess value, $Res Function(_SendPushNotificationTokenStateSuccess) _then) = __$SendPushNotificationTokenStateSuccessCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class __$SendPushNotificationTokenStateSuccessCopyWithImpl<$Res>
    implements _$SendPushNotificationTokenStateSuccessCopyWith<$Res> {
  __$SendPushNotificationTokenStateSuccessCopyWithImpl(this._self, this._then);

  final _SendPushNotificationTokenStateSuccess _self;
  final $Res Function(_SendPushNotificationTokenStateSuccess) _then;

/// Create a copy of SendPushNotificationTokenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(_SendPushNotificationTokenStateSuccess(
null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _SendPushNotificationTokenStateError implements SendPushNotificationTokenState {
  const _SendPushNotificationTokenStateError(this.error);
  

 final  AppError error;

/// Create a copy of SendPushNotificationTokenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendPushNotificationTokenStateErrorCopyWith<_SendPushNotificationTokenStateError> get copyWith => __$SendPushNotificationTokenStateErrorCopyWithImpl<_SendPushNotificationTokenStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendPushNotificationTokenStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'SendPushNotificationTokenState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$SendPushNotificationTokenStateErrorCopyWith<$Res> implements $SendPushNotificationTokenStateCopyWith<$Res> {
  factory _$SendPushNotificationTokenStateErrorCopyWith(_SendPushNotificationTokenStateError value, $Res Function(_SendPushNotificationTokenStateError) _then) = __$SendPushNotificationTokenStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$SendPushNotificationTokenStateErrorCopyWithImpl<$Res>
    implements _$SendPushNotificationTokenStateErrorCopyWith<$Res> {
  __$SendPushNotificationTokenStateErrorCopyWithImpl(this._self, this._then);

  final _SendPushNotificationTokenStateError _self;
  final $Res Function(_SendPushNotificationTokenStateError) _then;

/// Create a copy of SendPushNotificationTokenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_SendPushNotificationTokenStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of SendPushNotificationTokenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res> get error {
  
  return $AppErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

/// @nodoc
mixin _$UpdateUserLocationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserLocationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserLocationState()';
}


}

/// @nodoc
class $UpdateUserLocationStateCopyWith<$Res>  {
$UpdateUserLocationStateCopyWith(UpdateUserLocationState _, $Res Function(UpdateUserLocationState) __);
}


/// Adds pattern-matching-related methods to [UpdateUserLocationState].
extension UpdateUserLocationStatePatterns on UpdateUserLocationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UpdateUserLocationStateInitial value)?  initial,TResult Function( UpdateUserLocationStateLoading value)?  loading,TResult Function( UpdateUserLocationStateSuccess value)?  success,TResult Function( UpdateUserLocationStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UpdateUserLocationStateInitial() when initial != null:
return initial(_that);case UpdateUserLocationStateLoading() when loading != null:
return loading(_that);case UpdateUserLocationStateSuccess() when success != null:
return success(_that);case UpdateUserLocationStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UpdateUserLocationStateInitial value)  initial,required TResult Function( UpdateUserLocationStateLoading value)  loading,required TResult Function( UpdateUserLocationStateSuccess value)  success,required TResult Function( UpdateUserLocationStateError value)  error,}){
final _that = this;
switch (_that) {
case UpdateUserLocationStateInitial():
return initial(_that);case UpdateUserLocationStateLoading():
return loading(_that);case UpdateUserLocationStateSuccess():
return success(_that);case UpdateUserLocationStateError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UpdateUserLocationStateInitial value)?  initial,TResult? Function( UpdateUserLocationStateLoading value)?  loading,TResult? Function( UpdateUserLocationStateSuccess value)?  success,TResult? Function( UpdateUserLocationStateError value)?  error,}){
final _that = this;
switch (_that) {
case UpdateUserLocationStateInitial() when initial != null:
return initial(_that);case UpdateUserLocationStateLoading() when loading != null:
return loading(_that);case UpdateUserLocationStateSuccess() when success != null:
return success(_that);case UpdateUserLocationStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( AppUser newAppUser)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UpdateUserLocationStateInitial() when initial != null:
return initial();case UpdateUserLocationStateLoading() when loading != null:
return loading();case UpdateUserLocationStateSuccess() when success != null:
return success(_that.newAppUser);case UpdateUserLocationStateError() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( AppUser newAppUser)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case UpdateUserLocationStateInitial():
return initial();case UpdateUserLocationStateLoading():
return loading();case UpdateUserLocationStateSuccess():
return success(_that.newAppUser);case UpdateUserLocationStateError():
return error(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( AppUser newAppUser)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case UpdateUserLocationStateInitial() when initial != null:
return initial();case UpdateUserLocationStateLoading() when loading != null:
return loading();case UpdateUserLocationStateSuccess() when success != null:
return success(_that.newAppUser);case UpdateUserLocationStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class UpdateUserLocationStateInitial implements UpdateUserLocationState {
  const UpdateUserLocationStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserLocationStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserLocationState.initial()';
}


}




/// @nodoc


class UpdateUserLocationStateLoading implements UpdateUserLocationState {
  const UpdateUserLocationStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserLocationStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserLocationState.loading()';
}


}




/// @nodoc


class UpdateUserLocationStateSuccess implements UpdateUserLocationState {
  const UpdateUserLocationStateSuccess(this.newAppUser);
  

 final  AppUser newAppUser;

/// Create a copy of UpdateUserLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserLocationStateSuccessCopyWith<UpdateUserLocationStateSuccess> get copyWith => _$UpdateUserLocationStateSuccessCopyWithImpl<UpdateUserLocationStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserLocationStateSuccess&&(identical(other.newAppUser, newAppUser) || other.newAppUser == newAppUser));
}


@override
int get hashCode => Object.hash(runtimeType,newAppUser);

@override
String toString() {
  return 'UpdateUserLocationState.success(newAppUser: $newAppUser)';
}


}

/// @nodoc
abstract mixin class $UpdateUserLocationStateSuccessCopyWith<$Res> implements $UpdateUserLocationStateCopyWith<$Res> {
  factory $UpdateUserLocationStateSuccessCopyWith(UpdateUserLocationStateSuccess value, $Res Function(UpdateUserLocationStateSuccess) _then) = _$UpdateUserLocationStateSuccessCopyWithImpl;
@useResult
$Res call({
 AppUser newAppUser
});


$AppUserCopyWith<$Res> get newAppUser;

}
/// @nodoc
class _$UpdateUserLocationStateSuccessCopyWithImpl<$Res>
    implements $UpdateUserLocationStateSuccessCopyWith<$Res> {
  _$UpdateUserLocationStateSuccessCopyWithImpl(this._self, this._then);

  final UpdateUserLocationStateSuccess _self;
  final $Res Function(UpdateUserLocationStateSuccess) _then;

/// Create a copy of UpdateUserLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? newAppUser = null,}) {
  return _then(UpdateUserLocationStateSuccess(
null == newAppUser ? _self.newAppUser : newAppUser // ignore: cast_nullable_to_non_nullable
as AppUser,
  ));
}

/// Create a copy of UpdateUserLocationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get newAppUser {
  
  return $AppUserCopyWith<$Res>(_self.newAppUser, (value) {
    return _then(_self.copyWith(newAppUser: value));
  });
}
}

/// @nodoc


class UpdateUserLocationStateError implements UpdateUserLocationState {
  const UpdateUserLocationStateError(this.error);
  

 final  AppError error;

/// Create a copy of UpdateUserLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserLocationStateErrorCopyWith<UpdateUserLocationStateError> get copyWith => _$UpdateUserLocationStateErrorCopyWithImpl<UpdateUserLocationStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserLocationStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'UpdateUserLocationState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $UpdateUserLocationStateErrorCopyWith<$Res> implements $UpdateUserLocationStateCopyWith<$Res> {
  factory $UpdateUserLocationStateErrorCopyWith(UpdateUserLocationStateError value, $Res Function(UpdateUserLocationStateError) _then) = _$UpdateUserLocationStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class _$UpdateUserLocationStateErrorCopyWithImpl<$Res>
    implements $UpdateUserLocationStateErrorCopyWith<$Res> {
  _$UpdateUserLocationStateErrorCopyWithImpl(this._self, this._then);

  final UpdateUserLocationStateError _self;
  final $Res Function(UpdateUserLocationStateError) _then;

/// Create a copy of UpdateUserLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(UpdateUserLocationStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of UpdateUserLocationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res> get error {
  
  return $AppErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
