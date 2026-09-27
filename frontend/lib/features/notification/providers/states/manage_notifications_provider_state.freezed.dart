// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manage_notifications_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ManageNotificationsProviderState {

/// The push notification settings of the user.
 PushNotificationSettings get pushNotificationSettings;/// The state of getting push notification settings.
 GetPushNotificationSettingsState get getPushNotificationSettingsState;/// The state of updating push notification settings.
 UpdatePushNotificationSettingsState get updatePushNotificationSettingsState;
/// Create a copy of ManageNotificationsProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManageNotificationsProviderStateCopyWith<ManageNotificationsProviderState> get copyWith => _$ManageNotificationsProviderStateCopyWithImpl<ManageNotificationsProviderState>(this as ManageNotificationsProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManageNotificationsProviderState&&(identical(other.pushNotificationSettings, pushNotificationSettings) || other.pushNotificationSettings == pushNotificationSettings)&&(identical(other.getPushNotificationSettingsState, getPushNotificationSettingsState) || other.getPushNotificationSettingsState == getPushNotificationSettingsState)&&(identical(other.updatePushNotificationSettingsState, updatePushNotificationSettingsState) || other.updatePushNotificationSettingsState == updatePushNotificationSettingsState));
}


@override
int get hashCode => Object.hash(runtimeType,pushNotificationSettings,getPushNotificationSettingsState,updatePushNotificationSettingsState);

@override
String toString() {
  return 'ManageNotificationsProviderState(pushNotificationSettings: $pushNotificationSettings, getPushNotificationSettingsState: $getPushNotificationSettingsState, updatePushNotificationSettingsState: $updatePushNotificationSettingsState)';
}


}

/// @nodoc
abstract mixin class $ManageNotificationsProviderStateCopyWith<$Res>  {
  factory $ManageNotificationsProviderStateCopyWith(ManageNotificationsProviderState value, $Res Function(ManageNotificationsProviderState) _then) = _$ManageNotificationsProviderStateCopyWithImpl;
@useResult
$Res call({
 PushNotificationSettings pushNotificationSettings, GetPushNotificationSettingsState getPushNotificationSettingsState, UpdatePushNotificationSettingsState updatePushNotificationSettingsState
});


$PushNotificationSettingsCopyWith<$Res> get pushNotificationSettings;$GetPushNotificationSettingsStateCopyWith<$Res> get getPushNotificationSettingsState;$UpdatePushNotificationSettingsStateCopyWith<$Res> get updatePushNotificationSettingsState;

}
/// @nodoc
class _$ManageNotificationsProviderStateCopyWithImpl<$Res>
    implements $ManageNotificationsProviderStateCopyWith<$Res> {
  _$ManageNotificationsProviderStateCopyWithImpl(this._self, this._then);

  final ManageNotificationsProviderState _self;
  final $Res Function(ManageNotificationsProviderState) _then;

/// Create a copy of ManageNotificationsProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pushNotificationSettings = null,Object? getPushNotificationSettingsState = null,Object? updatePushNotificationSettingsState = null,}) {
  return _then(_self.copyWith(
pushNotificationSettings: null == pushNotificationSettings ? _self.pushNotificationSettings : pushNotificationSettings // ignore: cast_nullable_to_non_nullable
as PushNotificationSettings,getPushNotificationSettingsState: null == getPushNotificationSettingsState ? _self.getPushNotificationSettingsState : getPushNotificationSettingsState // ignore: cast_nullable_to_non_nullable
as GetPushNotificationSettingsState,updatePushNotificationSettingsState: null == updatePushNotificationSettingsState ? _self.updatePushNotificationSettingsState : updatePushNotificationSettingsState // ignore: cast_nullable_to_non_nullable
as UpdatePushNotificationSettingsState,
  ));
}
/// Create a copy of ManageNotificationsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PushNotificationSettingsCopyWith<$Res> get pushNotificationSettings {
  
  return $PushNotificationSettingsCopyWith<$Res>(_self.pushNotificationSettings, (value) {
    return _then(_self.copyWith(pushNotificationSettings: value));
  });
}/// Create a copy of ManageNotificationsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetPushNotificationSettingsStateCopyWith<$Res> get getPushNotificationSettingsState {
  
  return $GetPushNotificationSettingsStateCopyWith<$Res>(_self.getPushNotificationSettingsState, (value) {
    return _then(_self.copyWith(getPushNotificationSettingsState: value));
  });
}/// Create a copy of ManageNotificationsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdatePushNotificationSettingsStateCopyWith<$Res> get updatePushNotificationSettingsState {
  
  return $UpdatePushNotificationSettingsStateCopyWith<$Res>(_self.updatePushNotificationSettingsState, (value) {
    return _then(_self.copyWith(updatePushNotificationSettingsState: value));
  });
}
}


/// Adds pattern-matching-related methods to [ManageNotificationsProviderState].
extension ManageNotificationsProviderStatePatterns on ManageNotificationsProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManageNotificationsProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManageNotificationsProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManageNotificationsProviderState value)  $default,){
final _that = this;
switch (_that) {
case _ManageNotificationsProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManageNotificationsProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _ManageNotificationsProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PushNotificationSettings pushNotificationSettings,  GetPushNotificationSettingsState getPushNotificationSettingsState,  UpdatePushNotificationSettingsState updatePushNotificationSettingsState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManageNotificationsProviderState() when $default != null:
return $default(_that.pushNotificationSettings,_that.getPushNotificationSettingsState,_that.updatePushNotificationSettingsState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PushNotificationSettings pushNotificationSettings,  GetPushNotificationSettingsState getPushNotificationSettingsState,  UpdatePushNotificationSettingsState updatePushNotificationSettingsState)  $default,) {final _that = this;
switch (_that) {
case _ManageNotificationsProviderState():
return $default(_that.pushNotificationSettings,_that.getPushNotificationSettingsState,_that.updatePushNotificationSettingsState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PushNotificationSettings pushNotificationSettings,  GetPushNotificationSettingsState getPushNotificationSettingsState,  UpdatePushNotificationSettingsState updatePushNotificationSettingsState)?  $default,) {final _that = this;
switch (_that) {
case _ManageNotificationsProviderState() when $default != null:
return $default(_that.pushNotificationSettings,_that.getPushNotificationSettingsState,_that.updatePushNotificationSettingsState);case _:
  return null;

}
}

}

/// @nodoc


class _ManageNotificationsProviderState implements ManageNotificationsProviderState {
  const _ManageNotificationsProviderState({this.pushNotificationSettings = const PushNotificationSettings(), this.getPushNotificationSettingsState = const GetPushNotificationSettingsState.initial(), this.updatePushNotificationSettingsState = const UpdatePushNotificationSettingsState.initial()});
  

/// The push notification settings of the user.
@override@JsonKey() final  PushNotificationSettings pushNotificationSettings;
/// The state of getting push notification settings.
@override@JsonKey() final  GetPushNotificationSettingsState getPushNotificationSettingsState;
/// The state of updating push notification settings.
@override@JsonKey() final  UpdatePushNotificationSettingsState updatePushNotificationSettingsState;

/// Create a copy of ManageNotificationsProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManageNotificationsProviderStateCopyWith<_ManageNotificationsProviderState> get copyWith => __$ManageNotificationsProviderStateCopyWithImpl<_ManageNotificationsProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManageNotificationsProviderState&&(identical(other.pushNotificationSettings, pushNotificationSettings) || other.pushNotificationSettings == pushNotificationSettings)&&(identical(other.getPushNotificationSettingsState, getPushNotificationSettingsState) || other.getPushNotificationSettingsState == getPushNotificationSettingsState)&&(identical(other.updatePushNotificationSettingsState, updatePushNotificationSettingsState) || other.updatePushNotificationSettingsState == updatePushNotificationSettingsState));
}


@override
int get hashCode => Object.hash(runtimeType,pushNotificationSettings,getPushNotificationSettingsState,updatePushNotificationSettingsState);

@override
String toString() {
  return 'ManageNotificationsProviderState(pushNotificationSettings: $pushNotificationSettings, getPushNotificationSettingsState: $getPushNotificationSettingsState, updatePushNotificationSettingsState: $updatePushNotificationSettingsState)';
}


}

/// @nodoc
abstract mixin class _$ManageNotificationsProviderStateCopyWith<$Res> implements $ManageNotificationsProviderStateCopyWith<$Res> {
  factory _$ManageNotificationsProviderStateCopyWith(_ManageNotificationsProviderState value, $Res Function(_ManageNotificationsProviderState) _then) = __$ManageNotificationsProviderStateCopyWithImpl;
@override @useResult
$Res call({
 PushNotificationSettings pushNotificationSettings, GetPushNotificationSettingsState getPushNotificationSettingsState, UpdatePushNotificationSettingsState updatePushNotificationSettingsState
});


@override $PushNotificationSettingsCopyWith<$Res> get pushNotificationSettings;@override $GetPushNotificationSettingsStateCopyWith<$Res> get getPushNotificationSettingsState;@override $UpdatePushNotificationSettingsStateCopyWith<$Res> get updatePushNotificationSettingsState;

}
/// @nodoc
class __$ManageNotificationsProviderStateCopyWithImpl<$Res>
    implements _$ManageNotificationsProviderStateCopyWith<$Res> {
  __$ManageNotificationsProviderStateCopyWithImpl(this._self, this._then);

  final _ManageNotificationsProviderState _self;
  final $Res Function(_ManageNotificationsProviderState) _then;

/// Create a copy of ManageNotificationsProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pushNotificationSettings = null,Object? getPushNotificationSettingsState = null,Object? updatePushNotificationSettingsState = null,}) {
  return _then(_ManageNotificationsProviderState(
pushNotificationSettings: null == pushNotificationSettings ? _self.pushNotificationSettings : pushNotificationSettings // ignore: cast_nullable_to_non_nullable
as PushNotificationSettings,getPushNotificationSettingsState: null == getPushNotificationSettingsState ? _self.getPushNotificationSettingsState : getPushNotificationSettingsState // ignore: cast_nullable_to_non_nullable
as GetPushNotificationSettingsState,updatePushNotificationSettingsState: null == updatePushNotificationSettingsState ? _self.updatePushNotificationSettingsState : updatePushNotificationSettingsState // ignore: cast_nullable_to_non_nullable
as UpdatePushNotificationSettingsState,
  ));
}

/// Create a copy of ManageNotificationsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PushNotificationSettingsCopyWith<$Res> get pushNotificationSettings {
  
  return $PushNotificationSettingsCopyWith<$Res>(_self.pushNotificationSettings, (value) {
    return _then(_self.copyWith(pushNotificationSettings: value));
  });
}/// Create a copy of ManageNotificationsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetPushNotificationSettingsStateCopyWith<$Res> get getPushNotificationSettingsState {
  
  return $GetPushNotificationSettingsStateCopyWith<$Res>(_self.getPushNotificationSettingsState, (value) {
    return _then(_self.copyWith(getPushNotificationSettingsState: value));
  });
}/// Create a copy of ManageNotificationsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdatePushNotificationSettingsStateCopyWith<$Res> get updatePushNotificationSettingsState {
  
  return $UpdatePushNotificationSettingsStateCopyWith<$Res>(_self.updatePushNotificationSettingsState, (value) {
    return _then(_self.copyWith(updatePushNotificationSettingsState: value));
  });
}
}

/// @nodoc
mixin _$GetPushNotificationSettingsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetPushNotificationSettingsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetPushNotificationSettingsState()';
}


}

/// @nodoc
class $GetPushNotificationSettingsStateCopyWith<$Res>  {
$GetPushNotificationSettingsStateCopyWith(GetPushNotificationSettingsState _, $Res Function(GetPushNotificationSettingsState) __);
}


/// Adds pattern-matching-related methods to [GetPushNotificationSettingsState].
extension GetPushNotificationSettingsStatePatterns on GetPushNotificationSettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetPushNotificationSettingsStateInitial value)?  initial,TResult Function( _GetPushNotificationSettingsStateLoading value)?  loading,TResult Function( _GetPushNotificationSettingsStateSuccess value)?  success,TResult Function( _GetPushNotificationSettingsStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetPushNotificationSettingsStateInitial() when initial != null:
return initial(_that);case _GetPushNotificationSettingsStateLoading() when loading != null:
return loading(_that);case _GetPushNotificationSettingsStateSuccess() when success != null:
return success(_that);case _GetPushNotificationSettingsStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetPushNotificationSettingsStateInitial value)  initial,required TResult Function( _GetPushNotificationSettingsStateLoading value)  loading,required TResult Function( _GetPushNotificationSettingsStateSuccess value)  success,required TResult Function( _GetPushNotificationSettingsStateError value)  error,}){
final _that = this;
switch (_that) {
case _GetPushNotificationSettingsStateInitial():
return initial(_that);case _GetPushNotificationSettingsStateLoading():
return loading(_that);case _GetPushNotificationSettingsStateSuccess():
return success(_that);case _GetPushNotificationSettingsStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetPushNotificationSettingsStateInitial value)?  initial,TResult? Function( _GetPushNotificationSettingsStateLoading value)?  loading,TResult? Function( _GetPushNotificationSettingsStateSuccess value)?  success,TResult? Function( _GetPushNotificationSettingsStateError value)?  error,}){
final _that = this;
switch (_that) {
case _GetPushNotificationSettingsStateInitial() when initial != null:
return initial(_that);case _GetPushNotificationSettingsStateLoading() when loading != null:
return loading(_that);case _GetPushNotificationSettingsStateSuccess() when success != null:
return success(_that);case _GetPushNotificationSettingsStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( PushNotificationSettings pushNotificationSettings)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetPushNotificationSettingsStateInitial() when initial != null:
return initial();case _GetPushNotificationSettingsStateLoading() when loading != null:
return loading();case _GetPushNotificationSettingsStateSuccess() when success != null:
return success(_that.pushNotificationSettings);case _GetPushNotificationSettingsStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( PushNotificationSettings pushNotificationSettings)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _GetPushNotificationSettingsStateInitial():
return initial();case _GetPushNotificationSettingsStateLoading():
return loading();case _GetPushNotificationSettingsStateSuccess():
return success(_that.pushNotificationSettings);case _GetPushNotificationSettingsStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( PushNotificationSettings pushNotificationSettings)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _GetPushNotificationSettingsStateInitial() when initial != null:
return initial();case _GetPushNotificationSettingsStateLoading() when loading != null:
return loading();case _GetPushNotificationSettingsStateSuccess() when success != null:
return success(_that.pushNotificationSettings);case _GetPushNotificationSettingsStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetPushNotificationSettingsStateInitial implements GetPushNotificationSettingsState {
  const _GetPushNotificationSettingsStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetPushNotificationSettingsStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetPushNotificationSettingsState.initial()';
}


}




/// @nodoc


class _GetPushNotificationSettingsStateLoading implements GetPushNotificationSettingsState {
  const _GetPushNotificationSettingsStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetPushNotificationSettingsStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetPushNotificationSettingsState.loading()';
}


}




/// @nodoc


class _GetPushNotificationSettingsStateSuccess implements GetPushNotificationSettingsState {
  const _GetPushNotificationSettingsStateSuccess(this.pushNotificationSettings);
  

 final  PushNotificationSettings pushNotificationSettings;

/// Create a copy of GetPushNotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetPushNotificationSettingsStateSuccessCopyWith<_GetPushNotificationSettingsStateSuccess> get copyWith => __$GetPushNotificationSettingsStateSuccessCopyWithImpl<_GetPushNotificationSettingsStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetPushNotificationSettingsStateSuccess&&(identical(other.pushNotificationSettings, pushNotificationSettings) || other.pushNotificationSettings == pushNotificationSettings));
}


@override
int get hashCode => Object.hash(runtimeType,pushNotificationSettings);

@override
String toString() {
  return 'GetPushNotificationSettingsState.success(pushNotificationSettings: $pushNotificationSettings)';
}


}

/// @nodoc
abstract mixin class _$GetPushNotificationSettingsStateSuccessCopyWith<$Res> implements $GetPushNotificationSettingsStateCopyWith<$Res> {
  factory _$GetPushNotificationSettingsStateSuccessCopyWith(_GetPushNotificationSettingsStateSuccess value, $Res Function(_GetPushNotificationSettingsStateSuccess) _then) = __$GetPushNotificationSettingsStateSuccessCopyWithImpl;
@useResult
$Res call({
 PushNotificationSettings pushNotificationSettings
});


$PushNotificationSettingsCopyWith<$Res> get pushNotificationSettings;

}
/// @nodoc
class __$GetPushNotificationSettingsStateSuccessCopyWithImpl<$Res>
    implements _$GetPushNotificationSettingsStateSuccessCopyWith<$Res> {
  __$GetPushNotificationSettingsStateSuccessCopyWithImpl(this._self, this._then);

  final _GetPushNotificationSettingsStateSuccess _self;
  final $Res Function(_GetPushNotificationSettingsStateSuccess) _then;

/// Create a copy of GetPushNotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? pushNotificationSettings = null,}) {
  return _then(_GetPushNotificationSettingsStateSuccess(
null == pushNotificationSettings ? _self.pushNotificationSettings : pushNotificationSettings // ignore: cast_nullable_to_non_nullable
as PushNotificationSettings,
  ));
}

/// Create a copy of GetPushNotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PushNotificationSettingsCopyWith<$Res> get pushNotificationSettings {
  
  return $PushNotificationSettingsCopyWith<$Res>(_self.pushNotificationSettings, (value) {
    return _then(_self.copyWith(pushNotificationSettings: value));
  });
}
}

/// @nodoc


class _GetPushNotificationSettingsStateError implements GetPushNotificationSettingsState {
  const _GetPushNotificationSettingsStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetPushNotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetPushNotificationSettingsStateErrorCopyWith<_GetPushNotificationSettingsStateError> get copyWith => __$GetPushNotificationSettingsStateErrorCopyWithImpl<_GetPushNotificationSettingsStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetPushNotificationSettingsStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetPushNotificationSettingsState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetPushNotificationSettingsStateErrorCopyWith<$Res> implements $GetPushNotificationSettingsStateCopyWith<$Res> {
  factory _$GetPushNotificationSettingsStateErrorCopyWith(_GetPushNotificationSettingsStateError value, $Res Function(_GetPushNotificationSettingsStateError) _then) = __$GetPushNotificationSettingsStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GetPushNotificationSettingsStateErrorCopyWithImpl<$Res>
    implements _$GetPushNotificationSettingsStateErrorCopyWith<$Res> {
  __$GetPushNotificationSettingsStateErrorCopyWithImpl(this._self, this._then);

  final _GetPushNotificationSettingsStateError _self;
  final $Res Function(_GetPushNotificationSettingsStateError) _then;

/// Create a copy of GetPushNotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GetPushNotificationSettingsStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetPushNotificationSettingsState
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
mixin _$UpdatePushNotificationSettingsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePushNotificationSettingsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdatePushNotificationSettingsState()';
}


}

/// @nodoc
class $UpdatePushNotificationSettingsStateCopyWith<$Res>  {
$UpdatePushNotificationSettingsStateCopyWith(UpdatePushNotificationSettingsState _, $Res Function(UpdatePushNotificationSettingsState) __);
}


/// Adds pattern-matching-related methods to [UpdatePushNotificationSettingsState].
extension UpdatePushNotificationSettingsStatePatterns on UpdatePushNotificationSettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _UpdatePushNotificationSettingsStateInitial value)?  initial,TResult Function( _UpdatePushNotificationSettingsStateLoading value)?  loading,TResult Function( _UpdatePushNotificationSettingsStateSuccess value)?  success,TResult Function( _UpdatePushNotificationSettingsStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdatePushNotificationSettingsStateInitial() when initial != null:
return initial(_that);case _UpdatePushNotificationSettingsStateLoading() when loading != null:
return loading(_that);case _UpdatePushNotificationSettingsStateSuccess() when success != null:
return success(_that);case _UpdatePushNotificationSettingsStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _UpdatePushNotificationSettingsStateInitial value)  initial,required TResult Function( _UpdatePushNotificationSettingsStateLoading value)  loading,required TResult Function( _UpdatePushNotificationSettingsStateSuccess value)  success,required TResult Function( _UpdatePushNotificationSettingsStateError value)  error,}){
final _that = this;
switch (_that) {
case _UpdatePushNotificationSettingsStateInitial():
return initial(_that);case _UpdatePushNotificationSettingsStateLoading():
return loading(_that);case _UpdatePushNotificationSettingsStateSuccess():
return success(_that);case _UpdatePushNotificationSettingsStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _UpdatePushNotificationSettingsStateInitial value)?  initial,TResult? Function( _UpdatePushNotificationSettingsStateLoading value)?  loading,TResult? Function( _UpdatePushNotificationSettingsStateSuccess value)?  success,TResult? Function( _UpdatePushNotificationSettingsStateError value)?  error,}){
final _that = this;
switch (_that) {
case _UpdatePushNotificationSettingsStateInitial() when initial != null:
return initial(_that);case _UpdatePushNotificationSettingsStateLoading() when loading != null:
return loading(_that);case _UpdatePushNotificationSettingsStateSuccess() when success != null:
return success(_that);case _UpdatePushNotificationSettingsStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdatePushNotificationSettingsStateInitial() when initial != null:
return initial();case _UpdatePushNotificationSettingsStateLoading() when loading != null:
return loading();case _UpdatePushNotificationSettingsStateSuccess() when success != null:
return success();case _UpdatePushNotificationSettingsStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _UpdatePushNotificationSettingsStateInitial():
return initial();case _UpdatePushNotificationSettingsStateLoading():
return loading();case _UpdatePushNotificationSettingsStateSuccess():
return success();case _UpdatePushNotificationSettingsStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _UpdatePushNotificationSettingsStateInitial() when initial != null:
return initial();case _UpdatePushNotificationSettingsStateLoading() when loading != null:
return loading();case _UpdatePushNotificationSettingsStateSuccess() when success != null:
return success();case _UpdatePushNotificationSettingsStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _UpdatePushNotificationSettingsStateInitial implements UpdatePushNotificationSettingsState {
  const _UpdatePushNotificationSettingsStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePushNotificationSettingsStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdatePushNotificationSettingsState.initial()';
}


}




/// @nodoc


class _UpdatePushNotificationSettingsStateLoading implements UpdatePushNotificationSettingsState {
  const _UpdatePushNotificationSettingsStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePushNotificationSettingsStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdatePushNotificationSettingsState.loading()';
}


}




/// @nodoc


class _UpdatePushNotificationSettingsStateSuccess implements UpdatePushNotificationSettingsState {
  const _UpdatePushNotificationSettingsStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePushNotificationSettingsStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdatePushNotificationSettingsState.success()';
}


}




/// @nodoc


class _UpdatePushNotificationSettingsStateError implements UpdatePushNotificationSettingsState {
  const _UpdatePushNotificationSettingsStateError(this.error);
  

 final  AppError error;

/// Create a copy of UpdatePushNotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePushNotificationSettingsStateErrorCopyWith<_UpdatePushNotificationSettingsStateError> get copyWith => __$UpdatePushNotificationSettingsStateErrorCopyWithImpl<_UpdatePushNotificationSettingsStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePushNotificationSettingsStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'UpdatePushNotificationSettingsState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$UpdatePushNotificationSettingsStateErrorCopyWith<$Res> implements $UpdatePushNotificationSettingsStateCopyWith<$Res> {
  factory _$UpdatePushNotificationSettingsStateErrorCopyWith(_UpdatePushNotificationSettingsStateError value, $Res Function(_UpdatePushNotificationSettingsStateError) _then) = __$UpdatePushNotificationSettingsStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$UpdatePushNotificationSettingsStateErrorCopyWithImpl<$Res>
    implements _$UpdatePushNotificationSettingsStateErrorCopyWith<$Res> {
  __$UpdatePushNotificationSettingsStateErrorCopyWithImpl(this._self, this._then);

  final _UpdatePushNotificationSettingsStateError _self;
  final $Res Function(_UpdatePushNotificationSettingsStateError) _then;

/// Create a copy of UpdatePushNotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_UpdatePushNotificationSettingsStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of UpdatePushNotificationSettingsState
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
mixin _$GetLocationSubscriptionsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocationSubscriptionsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetLocationSubscriptionsState()';
}


}

/// @nodoc
class $GetLocationSubscriptionsStateCopyWith<$Res>  {
$GetLocationSubscriptionsStateCopyWith(GetLocationSubscriptionsState _, $Res Function(GetLocationSubscriptionsState) __);
}


/// Adds pattern-matching-related methods to [GetLocationSubscriptionsState].
extension GetLocationSubscriptionsStatePatterns on GetLocationSubscriptionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetLocationSubscriptionsStateInitial value)?  initial,TResult Function( _GetLocationSubscriptionsStateLoading value)?  loading,TResult Function( _GetLocationSubscriptionsStateSuccess value)?  success,TResult Function( _GetLocationSubscriptionsStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetLocationSubscriptionsStateInitial() when initial != null:
return initial(_that);case _GetLocationSubscriptionsStateLoading() when loading != null:
return loading(_that);case _GetLocationSubscriptionsStateSuccess() when success != null:
return success(_that);case _GetLocationSubscriptionsStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetLocationSubscriptionsStateInitial value)  initial,required TResult Function( _GetLocationSubscriptionsStateLoading value)  loading,required TResult Function( _GetLocationSubscriptionsStateSuccess value)  success,required TResult Function( _GetLocationSubscriptionsStateError value)  error,}){
final _that = this;
switch (_that) {
case _GetLocationSubscriptionsStateInitial():
return initial(_that);case _GetLocationSubscriptionsStateLoading():
return loading(_that);case _GetLocationSubscriptionsStateSuccess():
return success(_that);case _GetLocationSubscriptionsStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetLocationSubscriptionsStateInitial value)?  initial,TResult? Function( _GetLocationSubscriptionsStateLoading value)?  loading,TResult? Function( _GetLocationSubscriptionsStateSuccess value)?  success,TResult? Function( _GetLocationSubscriptionsStateError value)?  error,}){
final _that = this;
switch (_that) {
case _GetLocationSubscriptionsStateInitial() when initial != null:
return initial(_that);case _GetLocationSubscriptionsStateLoading() when loading != null:
return loading(_that);case _GetLocationSubscriptionsStateSuccess() when success != null:
return success(_that);case _GetLocationSubscriptionsStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<LocationSubscription> locationSubscriptions)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetLocationSubscriptionsStateInitial() when initial != null:
return initial();case _GetLocationSubscriptionsStateLoading() when loading != null:
return loading();case _GetLocationSubscriptionsStateSuccess() when success != null:
return success(_that.locationSubscriptions);case _GetLocationSubscriptionsStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<LocationSubscription> locationSubscriptions)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _GetLocationSubscriptionsStateInitial():
return initial();case _GetLocationSubscriptionsStateLoading():
return loading();case _GetLocationSubscriptionsStateSuccess():
return success(_that.locationSubscriptions);case _GetLocationSubscriptionsStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<LocationSubscription> locationSubscriptions)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _GetLocationSubscriptionsStateInitial() when initial != null:
return initial();case _GetLocationSubscriptionsStateLoading() when loading != null:
return loading();case _GetLocationSubscriptionsStateSuccess() when success != null:
return success(_that.locationSubscriptions);case _GetLocationSubscriptionsStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetLocationSubscriptionsStateInitial implements GetLocationSubscriptionsState {
  const _GetLocationSubscriptionsStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetLocationSubscriptionsStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetLocationSubscriptionsState.initial()';
}


}




/// @nodoc


class _GetLocationSubscriptionsStateLoading implements GetLocationSubscriptionsState {
  const _GetLocationSubscriptionsStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetLocationSubscriptionsStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetLocationSubscriptionsState.loading()';
}


}




/// @nodoc


class _GetLocationSubscriptionsStateSuccess implements GetLocationSubscriptionsState {
  const _GetLocationSubscriptionsStateSuccess(final  List<LocationSubscription> locationSubscriptions): _locationSubscriptions = locationSubscriptions;
  

 final  List<LocationSubscription> _locationSubscriptions;
 List<LocationSubscription> get locationSubscriptions {
  if (_locationSubscriptions is EqualUnmodifiableListView) return _locationSubscriptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locationSubscriptions);
}


/// Create a copy of GetLocationSubscriptionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetLocationSubscriptionsStateSuccessCopyWith<_GetLocationSubscriptionsStateSuccess> get copyWith => __$GetLocationSubscriptionsStateSuccessCopyWithImpl<_GetLocationSubscriptionsStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetLocationSubscriptionsStateSuccess&&const DeepCollectionEquality().equals(other._locationSubscriptions, _locationSubscriptions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_locationSubscriptions));

@override
String toString() {
  return 'GetLocationSubscriptionsState.success(locationSubscriptions: $locationSubscriptions)';
}


}

/// @nodoc
abstract mixin class _$GetLocationSubscriptionsStateSuccessCopyWith<$Res> implements $GetLocationSubscriptionsStateCopyWith<$Res> {
  factory _$GetLocationSubscriptionsStateSuccessCopyWith(_GetLocationSubscriptionsStateSuccess value, $Res Function(_GetLocationSubscriptionsStateSuccess) _then) = __$GetLocationSubscriptionsStateSuccessCopyWithImpl;
@useResult
$Res call({
 List<LocationSubscription> locationSubscriptions
});




}
/// @nodoc
class __$GetLocationSubscriptionsStateSuccessCopyWithImpl<$Res>
    implements _$GetLocationSubscriptionsStateSuccessCopyWith<$Res> {
  __$GetLocationSubscriptionsStateSuccessCopyWithImpl(this._self, this._then);

  final _GetLocationSubscriptionsStateSuccess _self;
  final $Res Function(_GetLocationSubscriptionsStateSuccess) _then;

/// Create a copy of GetLocationSubscriptionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? locationSubscriptions = null,}) {
  return _then(_GetLocationSubscriptionsStateSuccess(
null == locationSubscriptions ? _self._locationSubscriptions : locationSubscriptions // ignore: cast_nullable_to_non_nullable
as List<LocationSubscription>,
  ));
}


}

/// @nodoc


class _GetLocationSubscriptionsStateError implements GetLocationSubscriptionsState {
  const _GetLocationSubscriptionsStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetLocationSubscriptionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetLocationSubscriptionsStateErrorCopyWith<_GetLocationSubscriptionsStateError> get copyWith => __$GetLocationSubscriptionsStateErrorCopyWithImpl<_GetLocationSubscriptionsStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetLocationSubscriptionsStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetLocationSubscriptionsState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetLocationSubscriptionsStateErrorCopyWith<$Res> implements $GetLocationSubscriptionsStateCopyWith<$Res> {
  factory _$GetLocationSubscriptionsStateErrorCopyWith(_GetLocationSubscriptionsStateError value, $Res Function(_GetLocationSubscriptionsStateError) _then) = __$GetLocationSubscriptionsStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GetLocationSubscriptionsStateErrorCopyWithImpl<$Res>
    implements _$GetLocationSubscriptionsStateErrorCopyWith<$Res> {
  __$GetLocationSubscriptionsStateErrorCopyWithImpl(this._self, this._then);

  final _GetLocationSubscriptionsStateError _self;
  final $Res Function(_GetLocationSubscriptionsStateError) _then;

/// Create a copy of GetLocationSubscriptionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GetLocationSubscriptionsStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetLocationSubscriptionsState
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
