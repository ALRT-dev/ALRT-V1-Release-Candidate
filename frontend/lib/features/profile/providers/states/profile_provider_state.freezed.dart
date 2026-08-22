// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileProviderState {

/// The profile picture of the user.
 AlrtMedia? get profilePicture;/// Whether to show the update profile picture button.
 bool get showUpdateProfilePictureButton;/// The state of updating the profile picture.
 ProfilePictureUpdateState get profilePictureUpdateState;/// The state of logging out the user.
 LogoutState get logoutState;/// The state of deleting the user's account.
 DeleteAccountState get deleteAccountState;
/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileProviderStateCopyWith<ProfileProviderState> get copyWith => _$ProfileProviderStateCopyWithImpl<ProfileProviderState>(this as ProfileProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileProviderState&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.showUpdateProfilePictureButton, showUpdateProfilePictureButton) || other.showUpdateProfilePictureButton == showUpdateProfilePictureButton)&&(identical(other.profilePictureUpdateState, profilePictureUpdateState) || other.profilePictureUpdateState == profilePictureUpdateState)&&(identical(other.logoutState, logoutState) || other.logoutState == logoutState)&&(identical(other.deleteAccountState, deleteAccountState) || other.deleteAccountState == deleteAccountState));
}


@override
int get hashCode => Object.hash(runtimeType,profilePicture,showUpdateProfilePictureButton,profilePictureUpdateState,logoutState,deleteAccountState);

@override
String toString() {
  return 'ProfileProviderState(profilePicture: $profilePicture, showUpdateProfilePictureButton: $showUpdateProfilePictureButton, profilePictureUpdateState: $profilePictureUpdateState, logoutState: $logoutState, deleteAccountState: $deleteAccountState)';
}


}

/// @nodoc
abstract mixin class $ProfileProviderStateCopyWith<$Res>  {
  factory $ProfileProviderStateCopyWith(ProfileProviderState value, $Res Function(ProfileProviderState) _then) = _$ProfileProviderStateCopyWithImpl;
@useResult
$Res call({
 AlrtMedia? profilePicture, bool showUpdateProfilePictureButton, ProfilePictureUpdateState profilePictureUpdateState, LogoutState logoutState, DeleteAccountState deleteAccountState
});


$AlrtMediaCopyWith<$Res>? get profilePicture;$ProfilePictureUpdateStateCopyWith<$Res> get profilePictureUpdateState;$LogoutStateCopyWith<$Res> get logoutState;$DeleteAccountStateCopyWith<$Res> get deleteAccountState;

}
/// @nodoc
class _$ProfileProviderStateCopyWithImpl<$Res>
    implements $ProfileProviderStateCopyWith<$Res> {
  _$ProfileProviderStateCopyWithImpl(this._self, this._then);

  final ProfileProviderState _self;
  final $Res Function(ProfileProviderState) _then;

/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profilePicture = freezed,Object? showUpdateProfilePictureButton = null,Object? profilePictureUpdateState = null,Object? logoutState = null,Object? deleteAccountState = null,}) {
  return _then(_self.copyWith(
profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as AlrtMedia?,showUpdateProfilePictureButton: null == showUpdateProfilePictureButton ? _self.showUpdateProfilePictureButton : showUpdateProfilePictureButton // ignore: cast_nullable_to_non_nullable
as bool,profilePictureUpdateState: null == profilePictureUpdateState ? _self.profilePictureUpdateState : profilePictureUpdateState // ignore: cast_nullable_to_non_nullable
as ProfilePictureUpdateState,logoutState: null == logoutState ? _self.logoutState : logoutState // ignore: cast_nullable_to_non_nullable
as LogoutState,deleteAccountState: null == deleteAccountState ? _self.deleteAccountState : deleteAccountState // ignore: cast_nullable_to_non_nullable
as DeleteAccountState,
  ));
}
/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtMediaCopyWith<$Res>? get profilePicture {
    if (_self.profilePicture == null) {
    return null;
  }

  return $AlrtMediaCopyWith<$Res>(_self.profilePicture!, (value) {
    return _then(_self.copyWith(profilePicture: value));
  });
}/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfilePictureUpdateStateCopyWith<$Res> get profilePictureUpdateState {
  
  return $ProfilePictureUpdateStateCopyWith<$Res>(_self.profilePictureUpdateState, (value) {
    return _then(_self.copyWith(profilePictureUpdateState: value));
  });
}/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LogoutStateCopyWith<$Res> get logoutState {
  
  return $LogoutStateCopyWith<$Res>(_self.logoutState, (value) {
    return _then(_self.copyWith(logoutState: value));
  });
}/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeleteAccountStateCopyWith<$Res> get deleteAccountState {
  
  return $DeleteAccountStateCopyWith<$Res>(_self.deleteAccountState, (value) {
    return _then(_self.copyWith(deleteAccountState: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileProviderState].
extension ProfileProviderStatePatterns on ProfileProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileProviderState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AlrtMedia? profilePicture,  bool showUpdateProfilePictureButton,  ProfilePictureUpdateState profilePictureUpdateState,  LogoutState logoutState,  DeleteAccountState deleteAccountState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileProviderState() when $default != null:
return $default(_that.profilePicture,_that.showUpdateProfilePictureButton,_that.profilePictureUpdateState,_that.logoutState,_that.deleteAccountState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AlrtMedia? profilePicture,  bool showUpdateProfilePictureButton,  ProfilePictureUpdateState profilePictureUpdateState,  LogoutState logoutState,  DeleteAccountState deleteAccountState)  $default,) {final _that = this;
switch (_that) {
case _ProfileProviderState():
return $default(_that.profilePicture,_that.showUpdateProfilePictureButton,_that.profilePictureUpdateState,_that.logoutState,_that.deleteAccountState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AlrtMedia? profilePicture,  bool showUpdateProfilePictureButton,  ProfilePictureUpdateState profilePictureUpdateState,  LogoutState logoutState,  DeleteAccountState deleteAccountState)?  $default,) {final _that = this;
switch (_that) {
case _ProfileProviderState() when $default != null:
return $default(_that.profilePicture,_that.showUpdateProfilePictureButton,_that.profilePictureUpdateState,_that.logoutState,_that.deleteAccountState);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileProviderState implements ProfileProviderState {
  const _ProfileProviderState({this.profilePicture, this.showUpdateProfilePictureButton = false, this.profilePictureUpdateState = const ProfilePictureUpdateState.initial(), this.logoutState = const LogoutState.initial(), this.deleteAccountState = const DeleteAccountState.initial()});
  

/// The profile picture of the user.
@override final  AlrtMedia? profilePicture;
/// Whether to show the update profile picture button.
@override@JsonKey() final  bool showUpdateProfilePictureButton;
/// The state of updating the profile picture.
@override@JsonKey() final  ProfilePictureUpdateState profilePictureUpdateState;
/// The state of logging out the user.
@override@JsonKey() final  LogoutState logoutState;
/// The state of deleting the user's account.
@override@JsonKey() final  DeleteAccountState deleteAccountState;

/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileProviderStateCopyWith<_ProfileProviderState> get copyWith => __$ProfileProviderStateCopyWithImpl<_ProfileProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileProviderState&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.showUpdateProfilePictureButton, showUpdateProfilePictureButton) || other.showUpdateProfilePictureButton == showUpdateProfilePictureButton)&&(identical(other.profilePictureUpdateState, profilePictureUpdateState) || other.profilePictureUpdateState == profilePictureUpdateState)&&(identical(other.logoutState, logoutState) || other.logoutState == logoutState)&&(identical(other.deleteAccountState, deleteAccountState) || other.deleteAccountState == deleteAccountState));
}


@override
int get hashCode => Object.hash(runtimeType,profilePicture,showUpdateProfilePictureButton,profilePictureUpdateState,logoutState,deleteAccountState);

@override
String toString() {
  return 'ProfileProviderState(profilePicture: $profilePicture, showUpdateProfilePictureButton: $showUpdateProfilePictureButton, profilePictureUpdateState: $profilePictureUpdateState, logoutState: $logoutState, deleteAccountState: $deleteAccountState)';
}


}

/// @nodoc
abstract mixin class _$ProfileProviderStateCopyWith<$Res> implements $ProfileProviderStateCopyWith<$Res> {
  factory _$ProfileProviderStateCopyWith(_ProfileProviderState value, $Res Function(_ProfileProviderState) _then) = __$ProfileProviderStateCopyWithImpl;
@override @useResult
$Res call({
 AlrtMedia? profilePicture, bool showUpdateProfilePictureButton, ProfilePictureUpdateState profilePictureUpdateState, LogoutState logoutState, DeleteAccountState deleteAccountState
});


@override $AlrtMediaCopyWith<$Res>? get profilePicture;@override $ProfilePictureUpdateStateCopyWith<$Res> get profilePictureUpdateState;@override $LogoutStateCopyWith<$Res> get logoutState;@override $DeleteAccountStateCopyWith<$Res> get deleteAccountState;

}
/// @nodoc
class __$ProfileProviderStateCopyWithImpl<$Res>
    implements _$ProfileProviderStateCopyWith<$Res> {
  __$ProfileProviderStateCopyWithImpl(this._self, this._then);

  final _ProfileProviderState _self;
  final $Res Function(_ProfileProviderState) _then;

/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profilePicture = freezed,Object? showUpdateProfilePictureButton = null,Object? profilePictureUpdateState = null,Object? logoutState = null,Object? deleteAccountState = null,}) {
  return _then(_ProfileProviderState(
profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as AlrtMedia?,showUpdateProfilePictureButton: null == showUpdateProfilePictureButton ? _self.showUpdateProfilePictureButton : showUpdateProfilePictureButton // ignore: cast_nullable_to_non_nullable
as bool,profilePictureUpdateState: null == profilePictureUpdateState ? _self.profilePictureUpdateState : profilePictureUpdateState // ignore: cast_nullable_to_non_nullable
as ProfilePictureUpdateState,logoutState: null == logoutState ? _self.logoutState : logoutState // ignore: cast_nullable_to_non_nullable
as LogoutState,deleteAccountState: null == deleteAccountState ? _self.deleteAccountState : deleteAccountState // ignore: cast_nullable_to_non_nullable
as DeleteAccountState,
  ));
}

/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtMediaCopyWith<$Res>? get profilePicture {
    if (_self.profilePicture == null) {
    return null;
  }

  return $AlrtMediaCopyWith<$Res>(_self.profilePicture!, (value) {
    return _then(_self.copyWith(profilePicture: value));
  });
}/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfilePictureUpdateStateCopyWith<$Res> get profilePictureUpdateState {
  
  return $ProfilePictureUpdateStateCopyWith<$Res>(_self.profilePictureUpdateState, (value) {
    return _then(_self.copyWith(profilePictureUpdateState: value));
  });
}/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LogoutStateCopyWith<$Res> get logoutState {
  
  return $LogoutStateCopyWith<$Res>(_self.logoutState, (value) {
    return _then(_self.copyWith(logoutState: value));
  });
}/// Create a copy of ProfileProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeleteAccountStateCopyWith<$Res> get deleteAccountState {
  
  return $DeleteAccountStateCopyWith<$Res>(_self.deleteAccountState, (value) {
    return _then(_self.copyWith(deleteAccountState: value));
  });
}
}

/// @nodoc
mixin _$LogoutState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogoutState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LogoutState()';
}


}

/// @nodoc
class $LogoutStateCopyWith<$Res>  {
$LogoutStateCopyWith(LogoutState _, $Res Function(LogoutState) __);
}


/// Adds pattern-matching-related methods to [LogoutState].
extension LogoutStatePatterns on LogoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LogoutStateInitial value)?  initial,TResult Function( _LogoutStateLoading value)?  loading,TResult Function( _LogoutStateSuccess value)?  success,TResult Function( _LogoutStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogoutStateInitial() when initial != null:
return initial(_that);case _LogoutStateLoading() when loading != null:
return loading(_that);case _LogoutStateSuccess() when success != null:
return success(_that);case _LogoutStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LogoutStateInitial value)  initial,required TResult Function( _LogoutStateLoading value)  loading,required TResult Function( _LogoutStateSuccess value)  success,required TResult Function( _LogoutStateError value)  error,}){
final _that = this;
switch (_that) {
case _LogoutStateInitial():
return initial(_that);case _LogoutStateLoading():
return loading(_that);case _LogoutStateSuccess():
return success(_that);case _LogoutStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LogoutStateInitial value)?  initial,TResult? Function( _LogoutStateLoading value)?  loading,TResult? Function( _LogoutStateSuccess value)?  success,TResult? Function( _LogoutStateError value)?  error,}){
final _that = this;
switch (_that) {
case _LogoutStateInitial() when initial != null:
return initial(_that);case _LogoutStateLoading() when loading != null:
return loading(_that);case _LogoutStateSuccess() when success != null:
return success(_that);case _LogoutStateError() when error != null:
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
case _LogoutStateInitial() when initial != null:
return initial();case _LogoutStateLoading() when loading != null:
return loading();case _LogoutStateSuccess() when success != null:
return success();case _LogoutStateError() when error != null:
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
case _LogoutStateInitial():
return initial();case _LogoutStateLoading():
return loading();case _LogoutStateSuccess():
return success();case _LogoutStateError():
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
case _LogoutStateInitial() when initial != null:
return initial();case _LogoutStateLoading() when loading != null:
return loading();case _LogoutStateSuccess() when success != null:
return success();case _LogoutStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _LogoutStateInitial implements LogoutState {
  const _LogoutStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogoutStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LogoutState.initial()';
}


}




/// @nodoc


class _LogoutStateLoading implements LogoutState {
  const _LogoutStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogoutStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LogoutState.loading()';
}


}




/// @nodoc


class _LogoutStateSuccess implements LogoutState {
  const _LogoutStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogoutStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LogoutState.success()';
}


}




/// @nodoc


class _LogoutStateError implements LogoutState {
  const _LogoutStateError(this.error);
  

 final  AppError error;

/// Create a copy of LogoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogoutStateErrorCopyWith<_LogoutStateError> get copyWith => __$LogoutStateErrorCopyWithImpl<_LogoutStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogoutStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'LogoutState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$LogoutStateErrorCopyWith<$Res> implements $LogoutStateCopyWith<$Res> {
  factory _$LogoutStateErrorCopyWith(_LogoutStateError value, $Res Function(_LogoutStateError) _then) = __$LogoutStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$LogoutStateErrorCopyWithImpl<$Res>
    implements _$LogoutStateErrorCopyWith<$Res> {
  __$LogoutStateErrorCopyWithImpl(this._self, this._then);

  final _LogoutStateError _self;
  final $Res Function(_LogoutStateError) _then;

/// Create a copy of LogoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_LogoutStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of LogoutState
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
mixin _$ProfilePictureUpdateState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfilePictureUpdateState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfilePictureUpdateState()';
}


}

/// @nodoc
class $ProfilePictureUpdateStateCopyWith<$Res>  {
$ProfilePictureUpdateStateCopyWith(ProfilePictureUpdateState _, $Res Function(ProfilePictureUpdateState) __);
}


/// Adds pattern-matching-related methods to [ProfilePictureUpdateState].
extension ProfilePictureUpdateStatePatterns on ProfilePictureUpdateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ProfilePictureUpdateStateInitial value)?  initial,TResult Function( _ProfilePictureUpdateStateLoading value)?  loading,TResult Function( _ProfilePictureUpdateStateSuccess value)?  success,TResult Function( _ProfilePictureUpdateStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfilePictureUpdateStateInitial() when initial != null:
return initial(_that);case _ProfilePictureUpdateStateLoading() when loading != null:
return loading(_that);case _ProfilePictureUpdateStateSuccess() when success != null:
return success(_that);case _ProfilePictureUpdateStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ProfilePictureUpdateStateInitial value)  initial,required TResult Function( _ProfilePictureUpdateStateLoading value)  loading,required TResult Function( _ProfilePictureUpdateStateSuccess value)  success,required TResult Function( _ProfilePictureUpdateStateError value)  error,}){
final _that = this;
switch (_that) {
case _ProfilePictureUpdateStateInitial():
return initial(_that);case _ProfilePictureUpdateStateLoading():
return loading(_that);case _ProfilePictureUpdateStateSuccess():
return success(_that);case _ProfilePictureUpdateStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ProfilePictureUpdateStateInitial value)?  initial,TResult? Function( _ProfilePictureUpdateStateLoading value)?  loading,TResult? Function( _ProfilePictureUpdateStateSuccess value)?  success,TResult? Function( _ProfilePictureUpdateStateError value)?  error,}){
final _that = this;
switch (_that) {
case _ProfilePictureUpdateStateInitial() when initial != null:
return initial(_that);case _ProfilePictureUpdateStateLoading() when loading != null:
return loading(_that);case _ProfilePictureUpdateStateSuccess() when success != null:
return success(_that);case _ProfilePictureUpdateStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( double progress)?  loading,TResult Function( AppUser updatedUser)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfilePictureUpdateStateInitial() when initial != null:
return initial();case _ProfilePictureUpdateStateLoading() when loading != null:
return loading(_that.progress);case _ProfilePictureUpdateStateSuccess() when success != null:
return success(_that.updatedUser);case _ProfilePictureUpdateStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( double progress)  loading,required TResult Function( AppUser updatedUser)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _ProfilePictureUpdateStateInitial():
return initial();case _ProfilePictureUpdateStateLoading():
return loading(_that.progress);case _ProfilePictureUpdateStateSuccess():
return success(_that.updatedUser);case _ProfilePictureUpdateStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( double progress)?  loading,TResult? Function( AppUser updatedUser)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _ProfilePictureUpdateStateInitial() when initial != null:
return initial();case _ProfilePictureUpdateStateLoading() when loading != null:
return loading(_that.progress);case _ProfilePictureUpdateStateSuccess() when success != null:
return success(_that.updatedUser);case _ProfilePictureUpdateStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ProfilePictureUpdateStateInitial implements ProfilePictureUpdateState {
  const _ProfilePictureUpdateStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfilePictureUpdateStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfilePictureUpdateState.initial()';
}


}




/// @nodoc


class _ProfilePictureUpdateStateLoading implements ProfilePictureUpdateState {
  const _ProfilePictureUpdateStateLoading({this.progress = 0.0});
  

@JsonKey() final  double progress;

/// Create a copy of ProfilePictureUpdateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfilePictureUpdateStateLoadingCopyWith<_ProfilePictureUpdateStateLoading> get copyWith => __$ProfilePictureUpdateStateLoadingCopyWithImpl<_ProfilePictureUpdateStateLoading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfilePictureUpdateStateLoading&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode => Object.hash(runtimeType,progress);

@override
String toString() {
  return 'ProfilePictureUpdateState.loading(progress: $progress)';
}


}

/// @nodoc
abstract mixin class _$ProfilePictureUpdateStateLoadingCopyWith<$Res> implements $ProfilePictureUpdateStateCopyWith<$Res> {
  factory _$ProfilePictureUpdateStateLoadingCopyWith(_ProfilePictureUpdateStateLoading value, $Res Function(_ProfilePictureUpdateStateLoading) _then) = __$ProfilePictureUpdateStateLoadingCopyWithImpl;
@useResult
$Res call({
 double progress
});




}
/// @nodoc
class __$ProfilePictureUpdateStateLoadingCopyWithImpl<$Res>
    implements _$ProfilePictureUpdateStateLoadingCopyWith<$Res> {
  __$ProfilePictureUpdateStateLoadingCopyWithImpl(this._self, this._then);

  final _ProfilePictureUpdateStateLoading _self;
  final $Res Function(_ProfilePictureUpdateStateLoading) _then;

/// Create a copy of ProfilePictureUpdateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? progress = null,}) {
  return _then(_ProfilePictureUpdateStateLoading(
progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class _ProfilePictureUpdateStateSuccess implements ProfilePictureUpdateState {
  const _ProfilePictureUpdateStateSuccess(this.updatedUser);
  

 final  AppUser updatedUser;

/// Create a copy of ProfilePictureUpdateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfilePictureUpdateStateSuccessCopyWith<_ProfilePictureUpdateStateSuccess> get copyWith => __$ProfilePictureUpdateStateSuccessCopyWithImpl<_ProfilePictureUpdateStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfilePictureUpdateStateSuccess&&(identical(other.updatedUser, updatedUser) || other.updatedUser == updatedUser));
}


@override
int get hashCode => Object.hash(runtimeType,updatedUser);

@override
String toString() {
  return 'ProfilePictureUpdateState.success(updatedUser: $updatedUser)';
}


}

/// @nodoc
abstract mixin class _$ProfilePictureUpdateStateSuccessCopyWith<$Res> implements $ProfilePictureUpdateStateCopyWith<$Res> {
  factory _$ProfilePictureUpdateStateSuccessCopyWith(_ProfilePictureUpdateStateSuccess value, $Res Function(_ProfilePictureUpdateStateSuccess) _then) = __$ProfilePictureUpdateStateSuccessCopyWithImpl;
@useResult
$Res call({
 AppUser updatedUser
});


$AppUserCopyWith<$Res> get updatedUser;

}
/// @nodoc
class __$ProfilePictureUpdateStateSuccessCopyWithImpl<$Res>
    implements _$ProfilePictureUpdateStateSuccessCopyWith<$Res> {
  __$ProfilePictureUpdateStateSuccessCopyWithImpl(this._self, this._then);

  final _ProfilePictureUpdateStateSuccess _self;
  final $Res Function(_ProfilePictureUpdateStateSuccess) _then;

/// Create a copy of ProfilePictureUpdateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? updatedUser = null,}) {
  return _then(_ProfilePictureUpdateStateSuccess(
null == updatedUser ? _self.updatedUser : updatedUser // ignore: cast_nullable_to_non_nullable
as AppUser,
  ));
}

/// Create a copy of ProfilePictureUpdateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get updatedUser {
  
  return $AppUserCopyWith<$Res>(_self.updatedUser, (value) {
    return _then(_self.copyWith(updatedUser: value));
  });
}
}

/// @nodoc


class _ProfilePictureUpdateStateError implements ProfilePictureUpdateState {
  const _ProfilePictureUpdateStateError(this.error);
  

 final  AppError error;

/// Create a copy of ProfilePictureUpdateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfilePictureUpdateStateErrorCopyWith<_ProfilePictureUpdateStateError> get copyWith => __$ProfilePictureUpdateStateErrorCopyWithImpl<_ProfilePictureUpdateStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfilePictureUpdateStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ProfilePictureUpdateState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$ProfilePictureUpdateStateErrorCopyWith<$Res> implements $ProfilePictureUpdateStateCopyWith<$Res> {
  factory _$ProfilePictureUpdateStateErrorCopyWith(_ProfilePictureUpdateStateError value, $Res Function(_ProfilePictureUpdateStateError) _then) = __$ProfilePictureUpdateStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$ProfilePictureUpdateStateErrorCopyWithImpl<$Res>
    implements _$ProfilePictureUpdateStateErrorCopyWith<$Res> {
  __$ProfilePictureUpdateStateErrorCopyWithImpl(this._self, this._then);

  final _ProfilePictureUpdateStateError _self;
  final $Res Function(_ProfilePictureUpdateStateError) _then;

/// Create a copy of ProfilePictureUpdateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_ProfilePictureUpdateStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of ProfilePictureUpdateState
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
mixin _$DeleteAccountState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteAccountState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeleteAccountState()';
}


}

/// @nodoc
class $DeleteAccountStateCopyWith<$Res>  {
$DeleteAccountStateCopyWith(DeleteAccountState _, $Res Function(DeleteAccountState) __);
}


/// Adds pattern-matching-related methods to [DeleteAccountState].
extension DeleteAccountStatePatterns on DeleteAccountState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _DeleteAccountStateInitial value)?  initial,TResult Function( _DeleteAccountStateLoading value)?  loading,TResult Function( _DeleteAccountStateSuccess value)?  success,TResult Function( _DeleteAccountStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteAccountStateInitial() when initial != null:
return initial(_that);case _DeleteAccountStateLoading() when loading != null:
return loading(_that);case _DeleteAccountStateSuccess() when success != null:
return success(_that);case _DeleteAccountStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _DeleteAccountStateInitial value)  initial,required TResult Function( _DeleteAccountStateLoading value)  loading,required TResult Function( _DeleteAccountStateSuccess value)  success,required TResult Function( _DeleteAccountStateError value)  error,}){
final _that = this;
switch (_that) {
case _DeleteAccountStateInitial():
return initial(_that);case _DeleteAccountStateLoading():
return loading(_that);case _DeleteAccountStateSuccess():
return success(_that);case _DeleteAccountStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _DeleteAccountStateInitial value)?  initial,TResult? Function( _DeleteAccountStateLoading value)?  loading,TResult? Function( _DeleteAccountStateSuccess value)?  success,TResult? Function( _DeleteAccountStateError value)?  error,}){
final _that = this;
switch (_that) {
case _DeleteAccountStateInitial() when initial != null:
return initial(_that);case _DeleteAccountStateLoading() when loading != null:
return loading(_that);case _DeleteAccountStateSuccess() when success != null:
return success(_that);case _DeleteAccountStateError() when error != null:
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
case _DeleteAccountStateInitial() when initial != null:
return initial();case _DeleteAccountStateLoading() when loading != null:
return loading();case _DeleteAccountStateSuccess() when success != null:
return success();case _DeleteAccountStateError() when error != null:
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
case _DeleteAccountStateInitial():
return initial();case _DeleteAccountStateLoading():
return loading();case _DeleteAccountStateSuccess():
return success();case _DeleteAccountStateError():
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
case _DeleteAccountStateInitial() when initial != null:
return initial();case _DeleteAccountStateLoading() when loading != null:
return loading();case _DeleteAccountStateSuccess() when success != null:
return success();case _DeleteAccountStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _DeleteAccountStateInitial implements DeleteAccountState {
  const _DeleteAccountStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteAccountStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeleteAccountState.initial()';
}


}




/// @nodoc


class _DeleteAccountStateLoading implements DeleteAccountState {
  const _DeleteAccountStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteAccountStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeleteAccountState.loading()';
}


}




/// @nodoc


class _DeleteAccountStateSuccess implements DeleteAccountState {
  const _DeleteAccountStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteAccountStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeleteAccountState.success()';
}


}




/// @nodoc


class _DeleteAccountStateError implements DeleteAccountState {
  const _DeleteAccountStateError(this.error);
  

 final  AppError error;

/// Create a copy of DeleteAccountState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteAccountStateErrorCopyWith<_DeleteAccountStateError> get copyWith => __$DeleteAccountStateErrorCopyWithImpl<_DeleteAccountStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteAccountStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'DeleteAccountState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$DeleteAccountStateErrorCopyWith<$Res> implements $DeleteAccountStateCopyWith<$Res> {
  factory _$DeleteAccountStateErrorCopyWith(_DeleteAccountStateError value, $Res Function(_DeleteAccountStateError) _then) = __$DeleteAccountStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$DeleteAccountStateErrorCopyWithImpl<$Res>
    implements _$DeleteAccountStateErrorCopyWith<$Res> {
  __$DeleteAccountStateErrorCopyWithImpl(this._self, this._then);

  final _DeleteAccountStateError _self;
  final $Res Function(_DeleteAccountStateError) _then;

/// Create a copy of DeleteAccountState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_DeleteAccountStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of DeleteAccountState
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
