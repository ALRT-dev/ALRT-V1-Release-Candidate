// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_permission_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocationProviderState {

/// Current user's location.
///
/// Defaults to [kDefaultUserLocation].
 AlrtLocation get location;/// Whether the app is using the device's location.
 bool get isUsingDeviceLocation;/// Cancel token for updating the user's location.
 CancelToken get updateLocationCancelToken;/// The state of getting the current user's location.
 GetLocationState get getLocationState;/// The state of getting the location permission of the device.
 GetLocationPremissionState get getLocationPremissionState;/// The state of updating the user's location.
 UpdateUserLocationState get updateUserLocationState;
/// Create a copy of LocationProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationProviderStateCopyWith<LocationProviderState> get copyWith => _$LocationProviderStateCopyWithImpl<LocationProviderState>(this as LocationProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationProviderState&&(identical(other.location, location) || other.location == location)&&(identical(other.isUsingDeviceLocation, isUsingDeviceLocation) || other.isUsingDeviceLocation == isUsingDeviceLocation)&&(identical(other.updateLocationCancelToken, updateLocationCancelToken) || other.updateLocationCancelToken == updateLocationCancelToken)&&(identical(other.getLocationState, getLocationState) || other.getLocationState == getLocationState)&&(identical(other.getLocationPremissionState, getLocationPremissionState) || other.getLocationPremissionState == getLocationPremissionState)&&(identical(other.updateUserLocationState, updateUserLocationState) || other.updateUserLocationState == updateUserLocationState));
}


@override
int get hashCode => Object.hash(runtimeType,location,isUsingDeviceLocation,updateLocationCancelToken,getLocationState,getLocationPremissionState,updateUserLocationState);

@override
String toString() {
  return 'LocationProviderState(location: $location, isUsingDeviceLocation: $isUsingDeviceLocation, updateLocationCancelToken: $updateLocationCancelToken, getLocationState: $getLocationState, getLocationPremissionState: $getLocationPremissionState, updateUserLocationState: $updateUserLocationState)';
}


}

/// @nodoc
abstract mixin class $LocationProviderStateCopyWith<$Res>  {
  factory $LocationProviderStateCopyWith(LocationProviderState value, $Res Function(LocationProviderState) _then) = _$LocationProviderStateCopyWithImpl;
@useResult
$Res call({
 AlrtLocation location, bool isUsingDeviceLocation, CancelToken updateLocationCancelToken, GetLocationState getLocationState, GetLocationPremissionState getLocationPremissionState, UpdateUserLocationState updateUserLocationState
});


$AlrtLocationCopyWith<$Res> get location;$GetLocationStateCopyWith<$Res> get getLocationState;$GetLocationPremissionStateCopyWith<$Res> get getLocationPremissionState;$UpdateUserLocationStateCopyWith<$Res> get updateUserLocationState;

}
/// @nodoc
class _$LocationProviderStateCopyWithImpl<$Res>
    implements $LocationProviderStateCopyWith<$Res> {
  _$LocationProviderStateCopyWithImpl(this._self, this._then);

  final LocationProviderState _self;
  final $Res Function(LocationProviderState) _then;

/// Create a copy of LocationProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = null,Object? isUsingDeviceLocation = null,Object? updateLocationCancelToken = null,Object? getLocationState = null,Object? getLocationPremissionState = null,Object? updateUserLocationState = null,}) {
  return _then(_self.copyWith(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as AlrtLocation,isUsingDeviceLocation: null == isUsingDeviceLocation ? _self.isUsingDeviceLocation : isUsingDeviceLocation // ignore: cast_nullable_to_non_nullable
as bool,updateLocationCancelToken: null == updateLocationCancelToken ? _self.updateLocationCancelToken : updateLocationCancelToken // ignore: cast_nullable_to_non_nullable
as CancelToken,getLocationState: null == getLocationState ? _self.getLocationState : getLocationState // ignore: cast_nullable_to_non_nullable
as GetLocationState,getLocationPremissionState: null == getLocationPremissionState ? _self.getLocationPremissionState : getLocationPremissionState // ignore: cast_nullable_to_non_nullable
as GetLocationPremissionState,updateUserLocationState: null == updateUserLocationState ? _self.updateUserLocationState : updateUserLocationState // ignore: cast_nullable_to_non_nullable
as UpdateUserLocationState,
  ));
}
/// Create a copy of LocationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res> get location {
  
  return $AlrtLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of LocationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetLocationStateCopyWith<$Res> get getLocationState {
  
  return $GetLocationStateCopyWith<$Res>(_self.getLocationState, (value) {
    return _then(_self.copyWith(getLocationState: value));
  });
}/// Create a copy of LocationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetLocationPremissionStateCopyWith<$Res> get getLocationPremissionState {
  
  return $GetLocationPremissionStateCopyWith<$Res>(_self.getLocationPremissionState, (value) {
    return _then(_self.copyWith(getLocationPremissionState: value));
  });
}/// Create a copy of LocationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateUserLocationStateCopyWith<$Res> get updateUserLocationState {
  
  return $UpdateUserLocationStateCopyWith<$Res>(_self.updateUserLocationState, (value) {
    return _then(_self.copyWith(updateUserLocationState: value));
  });
}
}


/// Adds pattern-matching-related methods to [LocationProviderState].
extension LocationProviderStatePatterns on LocationProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationProviderState value)  $default,){
final _that = this;
switch (_that) {
case _LocationProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _LocationProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AlrtLocation location,  bool isUsingDeviceLocation,  CancelToken updateLocationCancelToken,  GetLocationState getLocationState,  GetLocationPremissionState getLocationPremissionState,  UpdateUserLocationState updateUserLocationState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationProviderState() when $default != null:
return $default(_that.location,_that.isUsingDeviceLocation,_that.updateLocationCancelToken,_that.getLocationState,_that.getLocationPremissionState,_that.updateUserLocationState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AlrtLocation location,  bool isUsingDeviceLocation,  CancelToken updateLocationCancelToken,  GetLocationState getLocationState,  GetLocationPremissionState getLocationPremissionState,  UpdateUserLocationState updateUserLocationState)  $default,) {final _that = this;
switch (_that) {
case _LocationProviderState():
return $default(_that.location,_that.isUsingDeviceLocation,_that.updateLocationCancelToken,_that.getLocationState,_that.getLocationPremissionState,_that.updateUserLocationState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AlrtLocation location,  bool isUsingDeviceLocation,  CancelToken updateLocationCancelToken,  GetLocationState getLocationState,  GetLocationPremissionState getLocationPremissionState,  UpdateUserLocationState updateUserLocationState)?  $default,) {final _that = this;
switch (_that) {
case _LocationProviderState() when $default != null:
return $default(_that.location,_that.isUsingDeviceLocation,_that.updateLocationCancelToken,_that.getLocationState,_that.getLocationPremissionState,_that.updateUserLocationState);case _:
  return null;

}
}

}

/// @nodoc


class _LocationProviderState extends LocationProviderState {
  const _LocationProviderState({this.location = kDefaultUserLocation, this.isUsingDeviceLocation = false, required this.updateLocationCancelToken, this.getLocationState = const GetLocationState.initial(), this.getLocationPremissionState = const GetLocationPremissionState.initial(), this.updateUserLocationState = const UpdateUserLocationState.initial()}): super._();
  

/// Current user's location.
///
/// Defaults to [kDefaultUserLocation].
@override@JsonKey() final  AlrtLocation location;
/// Whether the app is using the device's location.
@override@JsonKey() final  bool isUsingDeviceLocation;
/// Cancel token for updating the user's location.
@override final  CancelToken updateLocationCancelToken;
/// The state of getting the current user's location.
@override@JsonKey() final  GetLocationState getLocationState;
/// The state of getting the location permission of the device.
@override@JsonKey() final  GetLocationPremissionState getLocationPremissionState;
/// The state of updating the user's location.
@override@JsonKey() final  UpdateUserLocationState updateUserLocationState;

/// Create a copy of LocationProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationProviderStateCopyWith<_LocationProviderState> get copyWith => __$LocationProviderStateCopyWithImpl<_LocationProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationProviderState&&(identical(other.location, location) || other.location == location)&&(identical(other.isUsingDeviceLocation, isUsingDeviceLocation) || other.isUsingDeviceLocation == isUsingDeviceLocation)&&(identical(other.updateLocationCancelToken, updateLocationCancelToken) || other.updateLocationCancelToken == updateLocationCancelToken)&&(identical(other.getLocationState, getLocationState) || other.getLocationState == getLocationState)&&(identical(other.getLocationPremissionState, getLocationPremissionState) || other.getLocationPremissionState == getLocationPremissionState)&&(identical(other.updateUserLocationState, updateUserLocationState) || other.updateUserLocationState == updateUserLocationState));
}


@override
int get hashCode => Object.hash(runtimeType,location,isUsingDeviceLocation,updateLocationCancelToken,getLocationState,getLocationPremissionState,updateUserLocationState);

@override
String toString() {
  return 'LocationProviderState(location: $location, isUsingDeviceLocation: $isUsingDeviceLocation, updateLocationCancelToken: $updateLocationCancelToken, getLocationState: $getLocationState, getLocationPremissionState: $getLocationPremissionState, updateUserLocationState: $updateUserLocationState)';
}


}

/// @nodoc
abstract mixin class _$LocationProviderStateCopyWith<$Res> implements $LocationProviderStateCopyWith<$Res> {
  factory _$LocationProviderStateCopyWith(_LocationProviderState value, $Res Function(_LocationProviderState) _then) = __$LocationProviderStateCopyWithImpl;
@override @useResult
$Res call({
 AlrtLocation location, bool isUsingDeviceLocation, CancelToken updateLocationCancelToken, GetLocationState getLocationState, GetLocationPremissionState getLocationPremissionState, UpdateUserLocationState updateUserLocationState
});


@override $AlrtLocationCopyWith<$Res> get location;@override $GetLocationStateCopyWith<$Res> get getLocationState;@override $GetLocationPremissionStateCopyWith<$Res> get getLocationPremissionState;@override $UpdateUserLocationStateCopyWith<$Res> get updateUserLocationState;

}
/// @nodoc
class __$LocationProviderStateCopyWithImpl<$Res>
    implements _$LocationProviderStateCopyWith<$Res> {
  __$LocationProviderStateCopyWithImpl(this._self, this._then);

  final _LocationProviderState _self;
  final $Res Function(_LocationProviderState) _then;

/// Create a copy of LocationProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = null,Object? isUsingDeviceLocation = null,Object? updateLocationCancelToken = null,Object? getLocationState = null,Object? getLocationPremissionState = null,Object? updateUserLocationState = null,}) {
  return _then(_LocationProviderState(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as AlrtLocation,isUsingDeviceLocation: null == isUsingDeviceLocation ? _self.isUsingDeviceLocation : isUsingDeviceLocation // ignore: cast_nullable_to_non_nullable
as bool,updateLocationCancelToken: null == updateLocationCancelToken ? _self.updateLocationCancelToken : updateLocationCancelToken // ignore: cast_nullable_to_non_nullable
as CancelToken,getLocationState: null == getLocationState ? _self.getLocationState : getLocationState // ignore: cast_nullable_to_non_nullable
as GetLocationState,getLocationPremissionState: null == getLocationPremissionState ? _self.getLocationPremissionState : getLocationPremissionState // ignore: cast_nullable_to_non_nullable
as GetLocationPremissionState,updateUserLocationState: null == updateUserLocationState ? _self.updateUserLocationState : updateUserLocationState // ignore: cast_nullable_to_non_nullable
as UpdateUserLocationState,
  ));
}

/// Create a copy of LocationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res> get location {
  
  return $AlrtLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of LocationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetLocationStateCopyWith<$Res> get getLocationState {
  
  return $GetLocationStateCopyWith<$Res>(_self.getLocationState, (value) {
    return _then(_self.copyWith(getLocationState: value));
  });
}/// Create a copy of LocationProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetLocationPremissionStateCopyWith<$Res> get getLocationPremissionState {
  
  return $GetLocationPremissionStateCopyWith<$Res>(_self.getLocationPremissionState, (value) {
    return _then(_self.copyWith(getLocationPremissionState: value));
  });
}/// Create a copy of LocationProviderState
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
mixin _$GetLocationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetLocationState()';
}


}

/// @nodoc
class $GetLocationStateCopyWith<$Res>  {
$GetLocationStateCopyWith(GetLocationState _, $Res Function(GetLocationState) __);
}


/// Adds pattern-matching-related methods to [GetLocationState].
extension GetLocationStatePatterns on GetLocationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetLocationStateInitial value)?  initial,TResult Function( GetLocationStateLoading value)?  loading,TResult Function( GetLocationStateSuccess value)?  success,TResult Function( GetLocationStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetLocationStateInitial() when initial != null:
return initial(_that);case GetLocationStateLoading() when loading != null:
return loading(_that);case GetLocationStateSuccess() when success != null:
return success(_that);case GetLocationStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetLocationStateInitial value)  initial,required TResult Function( GetLocationStateLoading value)  loading,required TResult Function( GetLocationStateSuccess value)  success,required TResult Function( GetLocationStateError value)  error,}){
final _that = this;
switch (_that) {
case GetLocationStateInitial():
return initial(_that);case GetLocationStateLoading():
return loading(_that);case GetLocationStateSuccess():
return success(_that);case GetLocationStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetLocationStateInitial value)?  initial,TResult? Function( GetLocationStateLoading value)?  loading,TResult? Function( GetLocationStateSuccess value)?  success,TResult? Function( GetLocationStateError value)?  error,}){
final _that = this;
switch (_that) {
case GetLocationStateInitial() when initial != null:
return initial(_that);case GetLocationStateLoading() when loading != null:
return loading(_that);case GetLocationStateSuccess() when success != null:
return success(_that);case GetLocationStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( AlrtLocation location)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetLocationStateInitial() when initial != null:
return initial();case GetLocationStateLoading() when loading != null:
return loading();case GetLocationStateSuccess() when success != null:
return success(_that.location);case GetLocationStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( AlrtLocation location)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case GetLocationStateInitial():
return initial();case GetLocationStateLoading():
return loading();case GetLocationStateSuccess():
return success(_that.location);case GetLocationStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( AlrtLocation location)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case GetLocationStateInitial() when initial != null:
return initial();case GetLocationStateLoading() when loading != null:
return loading();case GetLocationStateSuccess() when success != null:
return success(_that.location);case GetLocationStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class GetLocationStateInitial implements GetLocationState {
  const GetLocationStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocationStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetLocationState.initial()';
}


}




/// @nodoc


class GetLocationStateLoading implements GetLocationState {
  const GetLocationStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocationStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetLocationState.loading()';
}


}




/// @nodoc


class GetLocationStateSuccess implements GetLocationState {
  const GetLocationStateSuccess(this.location);
  

 final  AlrtLocation location;

/// Create a copy of GetLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetLocationStateSuccessCopyWith<GetLocationStateSuccess> get copyWith => _$GetLocationStateSuccessCopyWithImpl<GetLocationStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocationStateSuccess&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode => Object.hash(runtimeType,location);

@override
String toString() {
  return 'GetLocationState.success(location: $location)';
}


}

/// @nodoc
abstract mixin class $GetLocationStateSuccessCopyWith<$Res> implements $GetLocationStateCopyWith<$Res> {
  factory $GetLocationStateSuccessCopyWith(GetLocationStateSuccess value, $Res Function(GetLocationStateSuccess) _then) = _$GetLocationStateSuccessCopyWithImpl;
@useResult
$Res call({
 AlrtLocation location
});


$AlrtLocationCopyWith<$Res> get location;

}
/// @nodoc
class _$GetLocationStateSuccessCopyWithImpl<$Res>
    implements $GetLocationStateSuccessCopyWith<$Res> {
  _$GetLocationStateSuccessCopyWithImpl(this._self, this._then);

  final GetLocationStateSuccess _self;
  final $Res Function(GetLocationStateSuccess) _then;

/// Create a copy of GetLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? location = null,}) {
  return _then(GetLocationStateSuccess(
null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as AlrtLocation,
  ));
}

/// Create a copy of GetLocationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res> get location {
  
  return $AlrtLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

/// @nodoc


class GetLocationStateError implements GetLocationState {
  const GetLocationStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetLocationStateErrorCopyWith<GetLocationStateError> get copyWith => _$GetLocationStateErrorCopyWithImpl<GetLocationStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocationStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetLocationState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $GetLocationStateErrorCopyWith<$Res> implements $GetLocationStateCopyWith<$Res> {
  factory $GetLocationStateErrorCopyWith(GetLocationStateError value, $Res Function(GetLocationStateError) _then) = _$GetLocationStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class _$GetLocationStateErrorCopyWithImpl<$Res>
    implements $GetLocationStateErrorCopyWith<$Res> {
  _$GetLocationStateErrorCopyWithImpl(this._self, this._then);

  final GetLocationStateError _self;
  final $Res Function(GetLocationStateError) _then;

/// Create a copy of GetLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(GetLocationStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetLocationState
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
mixin _$GetLocationPremissionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocationPremissionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetLocationPremissionState()';
}


}

/// @nodoc
class $GetLocationPremissionStateCopyWith<$Res>  {
$GetLocationPremissionStateCopyWith(GetLocationPremissionState _, $Res Function(GetLocationPremissionState) __);
}


/// Adds pattern-matching-related methods to [GetLocationPremissionState].
extension GetLocationPremissionStatePatterns on GetLocationPremissionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetLocationPremissionStateInitial value)?  initial,TResult Function( GetLocationPremissionStateLoading value)?  loading,TResult Function( GetLocationPremissionStateSuccess value)?  success,TResult Function( GetLocationPremissionStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetLocationPremissionStateInitial() when initial != null:
return initial(_that);case GetLocationPremissionStateLoading() when loading != null:
return loading(_that);case GetLocationPremissionStateSuccess() when success != null:
return success(_that);case GetLocationPremissionStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetLocationPremissionStateInitial value)  initial,required TResult Function( GetLocationPremissionStateLoading value)  loading,required TResult Function( GetLocationPremissionStateSuccess value)  success,required TResult Function( GetLocationPremissionStateError value)  error,}){
final _that = this;
switch (_that) {
case GetLocationPremissionStateInitial():
return initial(_that);case GetLocationPremissionStateLoading():
return loading(_that);case GetLocationPremissionStateSuccess():
return success(_that);case GetLocationPremissionStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetLocationPremissionStateInitial value)?  initial,TResult? Function( GetLocationPremissionStateLoading value)?  loading,TResult? Function( GetLocationPremissionStateSuccess value)?  success,TResult? Function( GetLocationPremissionStateError value)?  error,}){
final _that = this;
switch (_that) {
case GetLocationPremissionStateInitial() when initial != null:
return initial(_that);case GetLocationPremissionStateLoading() when loading != null:
return loading(_that);case GetLocationPremissionStateSuccess() when success != null:
return success(_that);case GetLocationPremissionStateError() when error != null:
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
case GetLocationPremissionStateInitial() when initial != null:
return initial();case GetLocationPremissionStateLoading() when loading != null:
return loading();case GetLocationPremissionStateSuccess() when success != null:
return success();case GetLocationPremissionStateError() when error != null:
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
case GetLocationPremissionStateInitial():
return initial();case GetLocationPremissionStateLoading():
return loading();case GetLocationPremissionStateSuccess():
return success();case GetLocationPremissionStateError():
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
case GetLocationPremissionStateInitial() when initial != null:
return initial();case GetLocationPremissionStateLoading() when loading != null:
return loading();case GetLocationPremissionStateSuccess() when success != null:
return success();case GetLocationPremissionStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class GetLocationPremissionStateInitial implements GetLocationPremissionState {
  const GetLocationPremissionStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocationPremissionStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetLocationPremissionState.initial()';
}


}




/// @nodoc


class GetLocationPremissionStateLoading implements GetLocationPremissionState {
  const GetLocationPremissionStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocationPremissionStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetLocationPremissionState.loading()';
}


}




/// @nodoc


class GetLocationPremissionStateSuccess implements GetLocationPremissionState {
  const GetLocationPremissionStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocationPremissionStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetLocationPremissionState.success()';
}


}




/// @nodoc


class GetLocationPremissionStateError implements GetLocationPremissionState {
  const GetLocationPremissionStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetLocationPremissionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetLocationPremissionStateErrorCopyWith<GetLocationPremissionStateError> get copyWith => _$GetLocationPremissionStateErrorCopyWithImpl<GetLocationPremissionStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocationPremissionStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetLocationPremissionState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $GetLocationPremissionStateErrorCopyWith<$Res> implements $GetLocationPremissionStateCopyWith<$Res> {
  factory $GetLocationPremissionStateErrorCopyWith(GetLocationPremissionStateError value, $Res Function(GetLocationPremissionStateError) _then) = _$GetLocationPremissionStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class _$GetLocationPremissionStateErrorCopyWithImpl<$Res>
    implements $GetLocationPremissionStateErrorCopyWith<$Res> {
  _$GetLocationPremissionStateErrorCopyWithImpl(this._self, this._then);

  final GetLocationPremissionStateError _self;
  final $Res Function(GetLocationPremissionStateError) _then;

/// Create a copy of GetLocationPremissionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(GetLocationPremissionStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetLocationPremissionState
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( AppUser updatedUser)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UpdateUserLocationStateInitial() when initial != null:
return initial();case UpdateUserLocationStateLoading() when loading != null:
return loading();case UpdateUserLocationStateSuccess() when success != null:
return success(_that.updatedUser);case UpdateUserLocationStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( AppUser updatedUser)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case UpdateUserLocationStateInitial():
return initial();case UpdateUserLocationStateLoading():
return loading();case UpdateUserLocationStateSuccess():
return success(_that.updatedUser);case UpdateUserLocationStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( AppUser updatedUser)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case UpdateUserLocationStateInitial() when initial != null:
return initial();case UpdateUserLocationStateLoading() when loading != null:
return loading();case UpdateUserLocationStateSuccess() when success != null:
return success(_that.updatedUser);case UpdateUserLocationStateError() when error != null:
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
  const UpdateUserLocationStateSuccess(this.updatedUser);
  

 final  AppUser updatedUser;

/// Create a copy of UpdateUserLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserLocationStateSuccessCopyWith<UpdateUserLocationStateSuccess> get copyWith => _$UpdateUserLocationStateSuccessCopyWithImpl<UpdateUserLocationStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserLocationStateSuccess&&(identical(other.updatedUser, updatedUser) || other.updatedUser == updatedUser));
}


@override
int get hashCode => Object.hash(runtimeType,updatedUser);

@override
String toString() {
  return 'UpdateUserLocationState.success(updatedUser: $updatedUser)';
}


}

/// @nodoc
abstract mixin class $UpdateUserLocationStateSuccessCopyWith<$Res> implements $UpdateUserLocationStateCopyWith<$Res> {
  factory $UpdateUserLocationStateSuccessCopyWith(UpdateUserLocationStateSuccess value, $Res Function(UpdateUserLocationStateSuccess) _then) = _$UpdateUserLocationStateSuccessCopyWithImpl;
@useResult
$Res call({
 AppUser updatedUser
});


$AppUserCopyWith<$Res> get updatedUser;

}
/// @nodoc
class _$UpdateUserLocationStateSuccessCopyWithImpl<$Res>
    implements $UpdateUserLocationStateSuccessCopyWith<$Res> {
  _$UpdateUserLocationStateSuccessCopyWithImpl(this._self, this._then);

  final UpdateUserLocationStateSuccess _self;
  final $Res Function(UpdateUserLocationStateSuccess) _then;

/// Create a copy of UpdateUserLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? updatedUser = null,}) {
  return _then(UpdateUserLocationStateSuccess(
null == updatedUser ? _self.updatedUser : updatedUser // ignore: cast_nullable_to_non_nullable
as AppUser,
  ));
}

/// Create a copy of UpdateUserLocationState
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
