// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_location_subscriptions_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MyLocationSubscriptionsProviderState {

/// The list of location subscriptions of the user.
 List<LocationSubscription> get locationSubscriptions;/// The state of getting location subscriptions.
 GetLocationSubscriptionsState get getLocationSubscriptionsState;/// The state of subscribing to a location.
 List<SubscribeToLocationStateWrapper> get subscribeToLocationStateWrappers;/// The state of unsubscribing from a location.
 List<UnsubscribeFromLocationStateWrapper> get unsubscribeFromLocationStateWrappers;/// The state of updating a location subscription's location.
 UpdateUserLocationSubscriptionLocationState get updateUserLocationSubscriptionLocationState;/// The state of updating a location subscription's radius.
 UpdateUserLocationSubscriptionRadiusState get updateUserLocationSubscriptionRadiusState;
/// Create a copy of MyLocationSubscriptionsProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyLocationSubscriptionsProviderStateCopyWith<MyLocationSubscriptionsProviderState> get copyWith => _$MyLocationSubscriptionsProviderStateCopyWithImpl<MyLocationSubscriptionsProviderState>(this as MyLocationSubscriptionsProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyLocationSubscriptionsProviderState&&const DeepCollectionEquality().equals(other.locationSubscriptions, locationSubscriptions)&&(identical(other.getLocationSubscriptionsState, getLocationSubscriptionsState) || other.getLocationSubscriptionsState == getLocationSubscriptionsState)&&const DeepCollectionEquality().equals(other.subscribeToLocationStateWrappers, subscribeToLocationStateWrappers)&&const DeepCollectionEquality().equals(other.unsubscribeFromLocationStateWrappers, unsubscribeFromLocationStateWrappers)&&(identical(other.updateUserLocationSubscriptionLocationState, updateUserLocationSubscriptionLocationState) || other.updateUserLocationSubscriptionLocationState == updateUserLocationSubscriptionLocationState)&&(identical(other.updateUserLocationSubscriptionRadiusState, updateUserLocationSubscriptionRadiusState) || other.updateUserLocationSubscriptionRadiusState == updateUserLocationSubscriptionRadiusState));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(locationSubscriptions),getLocationSubscriptionsState,const DeepCollectionEquality().hash(subscribeToLocationStateWrappers),const DeepCollectionEquality().hash(unsubscribeFromLocationStateWrappers),updateUserLocationSubscriptionLocationState,updateUserLocationSubscriptionRadiusState);

@override
String toString() {
  return 'MyLocationSubscriptionsProviderState(locationSubscriptions: $locationSubscriptions, getLocationSubscriptionsState: $getLocationSubscriptionsState, subscribeToLocationStateWrappers: $subscribeToLocationStateWrappers, unsubscribeFromLocationStateWrappers: $unsubscribeFromLocationStateWrappers, updateUserLocationSubscriptionLocationState: $updateUserLocationSubscriptionLocationState, updateUserLocationSubscriptionRadiusState: $updateUserLocationSubscriptionRadiusState)';
}


}

/// @nodoc
abstract mixin class $MyLocationSubscriptionsProviderStateCopyWith<$Res>  {
  factory $MyLocationSubscriptionsProviderStateCopyWith(MyLocationSubscriptionsProviderState value, $Res Function(MyLocationSubscriptionsProviderState) _then) = _$MyLocationSubscriptionsProviderStateCopyWithImpl;
@useResult
$Res call({
 List<LocationSubscription> locationSubscriptions, GetLocationSubscriptionsState getLocationSubscriptionsState, List<SubscribeToLocationStateWrapper> subscribeToLocationStateWrappers, List<UnsubscribeFromLocationStateWrapper> unsubscribeFromLocationStateWrappers, UpdateUserLocationSubscriptionLocationState updateUserLocationSubscriptionLocationState, UpdateUserLocationSubscriptionRadiusState updateUserLocationSubscriptionRadiusState
});


$GetLocationSubscriptionsStateCopyWith<$Res> get getLocationSubscriptionsState;$UpdateUserLocationSubscriptionLocationStateCopyWith<$Res> get updateUserLocationSubscriptionLocationState;$UpdateUserLocationSubscriptionRadiusStateCopyWith<$Res> get updateUserLocationSubscriptionRadiusState;

}
/// @nodoc
class _$MyLocationSubscriptionsProviderStateCopyWithImpl<$Res>
    implements $MyLocationSubscriptionsProviderStateCopyWith<$Res> {
  _$MyLocationSubscriptionsProviderStateCopyWithImpl(this._self, this._then);

  final MyLocationSubscriptionsProviderState _self;
  final $Res Function(MyLocationSubscriptionsProviderState) _then;

/// Create a copy of MyLocationSubscriptionsProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locationSubscriptions = null,Object? getLocationSubscriptionsState = null,Object? subscribeToLocationStateWrappers = null,Object? unsubscribeFromLocationStateWrappers = null,Object? updateUserLocationSubscriptionLocationState = null,Object? updateUserLocationSubscriptionRadiusState = null,}) {
  return _then(_self.copyWith(
locationSubscriptions: null == locationSubscriptions ? _self.locationSubscriptions : locationSubscriptions // ignore: cast_nullable_to_non_nullable
as List<LocationSubscription>,getLocationSubscriptionsState: null == getLocationSubscriptionsState ? _self.getLocationSubscriptionsState : getLocationSubscriptionsState // ignore: cast_nullable_to_non_nullable
as GetLocationSubscriptionsState,subscribeToLocationStateWrappers: null == subscribeToLocationStateWrappers ? _self.subscribeToLocationStateWrappers : subscribeToLocationStateWrappers // ignore: cast_nullable_to_non_nullable
as List<SubscribeToLocationStateWrapper>,unsubscribeFromLocationStateWrappers: null == unsubscribeFromLocationStateWrappers ? _self.unsubscribeFromLocationStateWrappers : unsubscribeFromLocationStateWrappers // ignore: cast_nullable_to_non_nullable
as List<UnsubscribeFromLocationStateWrapper>,updateUserLocationSubscriptionLocationState: null == updateUserLocationSubscriptionLocationState ? _self.updateUserLocationSubscriptionLocationState : updateUserLocationSubscriptionLocationState // ignore: cast_nullable_to_non_nullable
as UpdateUserLocationSubscriptionLocationState,updateUserLocationSubscriptionRadiusState: null == updateUserLocationSubscriptionRadiusState ? _self.updateUserLocationSubscriptionRadiusState : updateUserLocationSubscriptionRadiusState // ignore: cast_nullable_to_non_nullable
as UpdateUserLocationSubscriptionRadiusState,
  ));
}
/// Create a copy of MyLocationSubscriptionsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetLocationSubscriptionsStateCopyWith<$Res> get getLocationSubscriptionsState {
  
  return $GetLocationSubscriptionsStateCopyWith<$Res>(_self.getLocationSubscriptionsState, (value) {
    return _then(_self.copyWith(getLocationSubscriptionsState: value));
  });
}/// Create a copy of MyLocationSubscriptionsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateUserLocationSubscriptionLocationStateCopyWith<$Res> get updateUserLocationSubscriptionLocationState {
  
  return $UpdateUserLocationSubscriptionLocationStateCopyWith<$Res>(_self.updateUserLocationSubscriptionLocationState, (value) {
    return _then(_self.copyWith(updateUserLocationSubscriptionLocationState: value));
  });
}/// Create a copy of MyLocationSubscriptionsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateUserLocationSubscriptionRadiusStateCopyWith<$Res> get updateUserLocationSubscriptionRadiusState {
  
  return $UpdateUserLocationSubscriptionRadiusStateCopyWith<$Res>(_self.updateUserLocationSubscriptionRadiusState, (value) {
    return _then(_self.copyWith(updateUserLocationSubscriptionRadiusState: value));
  });
}
}


/// Adds pattern-matching-related methods to [MyLocationSubscriptionsProviderState].
extension MyLocationSubscriptionsProviderStatePatterns on MyLocationSubscriptionsProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyLocationSubscriptionsProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyLocationSubscriptionsProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyLocationSubscriptionsProviderState value)  $default,){
final _that = this;
switch (_that) {
case _MyLocationSubscriptionsProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyLocationSubscriptionsProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _MyLocationSubscriptionsProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LocationSubscription> locationSubscriptions,  GetLocationSubscriptionsState getLocationSubscriptionsState,  List<SubscribeToLocationStateWrapper> subscribeToLocationStateWrappers,  List<UnsubscribeFromLocationStateWrapper> unsubscribeFromLocationStateWrappers,  UpdateUserLocationSubscriptionLocationState updateUserLocationSubscriptionLocationState,  UpdateUserLocationSubscriptionRadiusState updateUserLocationSubscriptionRadiusState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyLocationSubscriptionsProviderState() when $default != null:
return $default(_that.locationSubscriptions,_that.getLocationSubscriptionsState,_that.subscribeToLocationStateWrappers,_that.unsubscribeFromLocationStateWrappers,_that.updateUserLocationSubscriptionLocationState,_that.updateUserLocationSubscriptionRadiusState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LocationSubscription> locationSubscriptions,  GetLocationSubscriptionsState getLocationSubscriptionsState,  List<SubscribeToLocationStateWrapper> subscribeToLocationStateWrappers,  List<UnsubscribeFromLocationStateWrapper> unsubscribeFromLocationStateWrappers,  UpdateUserLocationSubscriptionLocationState updateUserLocationSubscriptionLocationState,  UpdateUserLocationSubscriptionRadiusState updateUserLocationSubscriptionRadiusState)  $default,) {final _that = this;
switch (_that) {
case _MyLocationSubscriptionsProviderState():
return $default(_that.locationSubscriptions,_that.getLocationSubscriptionsState,_that.subscribeToLocationStateWrappers,_that.unsubscribeFromLocationStateWrappers,_that.updateUserLocationSubscriptionLocationState,_that.updateUserLocationSubscriptionRadiusState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LocationSubscription> locationSubscriptions,  GetLocationSubscriptionsState getLocationSubscriptionsState,  List<SubscribeToLocationStateWrapper> subscribeToLocationStateWrappers,  List<UnsubscribeFromLocationStateWrapper> unsubscribeFromLocationStateWrappers,  UpdateUserLocationSubscriptionLocationState updateUserLocationSubscriptionLocationState,  UpdateUserLocationSubscriptionRadiusState updateUserLocationSubscriptionRadiusState)?  $default,) {final _that = this;
switch (_that) {
case _MyLocationSubscriptionsProviderState() when $default != null:
return $default(_that.locationSubscriptions,_that.getLocationSubscriptionsState,_that.subscribeToLocationStateWrappers,_that.unsubscribeFromLocationStateWrappers,_that.updateUserLocationSubscriptionLocationState,_that.updateUserLocationSubscriptionRadiusState);case _:
  return null;

}
}

}

/// @nodoc


class _MyLocationSubscriptionsProviderState implements MyLocationSubscriptionsProviderState {
  const _MyLocationSubscriptionsProviderState({final  List<LocationSubscription> locationSubscriptions = const <LocationSubscription>[], this.getLocationSubscriptionsState = const GetLocationSubscriptionsState.initial(), final  List<SubscribeToLocationStateWrapper> subscribeToLocationStateWrappers = const <SubscribeToLocationStateWrapper>[], final  List<UnsubscribeFromLocationStateWrapper> unsubscribeFromLocationStateWrappers = const <UnsubscribeFromLocationStateWrapper>[], this.updateUserLocationSubscriptionLocationState = const UpdateUserLocationSubscriptionLocationState.initial(), this.updateUserLocationSubscriptionRadiusState = const UpdateUserLocationSubscriptionRadiusState.initial()}): _locationSubscriptions = locationSubscriptions,_subscribeToLocationStateWrappers = subscribeToLocationStateWrappers,_unsubscribeFromLocationStateWrappers = unsubscribeFromLocationStateWrappers;
  

/// The list of location subscriptions of the user.
 final  List<LocationSubscription> _locationSubscriptions;
/// The list of location subscriptions of the user.
@override@JsonKey() List<LocationSubscription> get locationSubscriptions {
  if (_locationSubscriptions is EqualUnmodifiableListView) return _locationSubscriptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locationSubscriptions);
}

/// The state of getting location subscriptions.
@override@JsonKey() final  GetLocationSubscriptionsState getLocationSubscriptionsState;
/// The state of subscribing to a location.
 final  List<SubscribeToLocationStateWrapper> _subscribeToLocationStateWrappers;
/// The state of subscribing to a location.
@override@JsonKey() List<SubscribeToLocationStateWrapper> get subscribeToLocationStateWrappers {
  if (_subscribeToLocationStateWrappers is EqualUnmodifiableListView) return _subscribeToLocationStateWrappers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subscribeToLocationStateWrappers);
}

/// The state of unsubscribing from a location.
 final  List<UnsubscribeFromLocationStateWrapper> _unsubscribeFromLocationStateWrappers;
/// The state of unsubscribing from a location.
@override@JsonKey() List<UnsubscribeFromLocationStateWrapper> get unsubscribeFromLocationStateWrappers {
  if (_unsubscribeFromLocationStateWrappers is EqualUnmodifiableListView) return _unsubscribeFromLocationStateWrappers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unsubscribeFromLocationStateWrappers);
}

/// The state of updating a location subscription's location.
@override@JsonKey() final  UpdateUserLocationSubscriptionLocationState updateUserLocationSubscriptionLocationState;
/// The state of updating a location subscription's radius.
@override@JsonKey() final  UpdateUserLocationSubscriptionRadiusState updateUserLocationSubscriptionRadiusState;

/// Create a copy of MyLocationSubscriptionsProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyLocationSubscriptionsProviderStateCopyWith<_MyLocationSubscriptionsProviderState> get copyWith => __$MyLocationSubscriptionsProviderStateCopyWithImpl<_MyLocationSubscriptionsProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyLocationSubscriptionsProviderState&&const DeepCollectionEquality().equals(other._locationSubscriptions, _locationSubscriptions)&&(identical(other.getLocationSubscriptionsState, getLocationSubscriptionsState) || other.getLocationSubscriptionsState == getLocationSubscriptionsState)&&const DeepCollectionEquality().equals(other._subscribeToLocationStateWrappers, _subscribeToLocationStateWrappers)&&const DeepCollectionEquality().equals(other._unsubscribeFromLocationStateWrappers, _unsubscribeFromLocationStateWrappers)&&(identical(other.updateUserLocationSubscriptionLocationState, updateUserLocationSubscriptionLocationState) || other.updateUserLocationSubscriptionLocationState == updateUserLocationSubscriptionLocationState)&&(identical(other.updateUserLocationSubscriptionRadiusState, updateUserLocationSubscriptionRadiusState) || other.updateUserLocationSubscriptionRadiusState == updateUserLocationSubscriptionRadiusState));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_locationSubscriptions),getLocationSubscriptionsState,const DeepCollectionEquality().hash(_subscribeToLocationStateWrappers),const DeepCollectionEquality().hash(_unsubscribeFromLocationStateWrappers),updateUserLocationSubscriptionLocationState,updateUserLocationSubscriptionRadiusState);

@override
String toString() {
  return 'MyLocationSubscriptionsProviderState(locationSubscriptions: $locationSubscriptions, getLocationSubscriptionsState: $getLocationSubscriptionsState, subscribeToLocationStateWrappers: $subscribeToLocationStateWrappers, unsubscribeFromLocationStateWrappers: $unsubscribeFromLocationStateWrappers, updateUserLocationSubscriptionLocationState: $updateUserLocationSubscriptionLocationState, updateUserLocationSubscriptionRadiusState: $updateUserLocationSubscriptionRadiusState)';
}


}

/// @nodoc
abstract mixin class _$MyLocationSubscriptionsProviderStateCopyWith<$Res> implements $MyLocationSubscriptionsProviderStateCopyWith<$Res> {
  factory _$MyLocationSubscriptionsProviderStateCopyWith(_MyLocationSubscriptionsProviderState value, $Res Function(_MyLocationSubscriptionsProviderState) _then) = __$MyLocationSubscriptionsProviderStateCopyWithImpl;
@override @useResult
$Res call({
 List<LocationSubscription> locationSubscriptions, GetLocationSubscriptionsState getLocationSubscriptionsState, List<SubscribeToLocationStateWrapper> subscribeToLocationStateWrappers, List<UnsubscribeFromLocationStateWrapper> unsubscribeFromLocationStateWrappers, UpdateUserLocationSubscriptionLocationState updateUserLocationSubscriptionLocationState, UpdateUserLocationSubscriptionRadiusState updateUserLocationSubscriptionRadiusState
});


@override $GetLocationSubscriptionsStateCopyWith<$Res> get getLocationSubscriptionsState;@override $UpdateUserLocationSubscriptionLocationStateCopyWith<$Res> get updateUserLocationSubscriptionLocationState;@override $UpdateUserLocationSubscriptionRadiusStateCopyWith<$Res> get updateUserLocationSubscriptionRadiusState;

}
/// @nodoc
class __$MyLocationSubscriptionsProviderStateCopyWithImpl<$Res>
    implements _$MyLocationSubscriptionsProviderStateCopyWith<$Res> {
  __$MyLocationSubscriptionsProviderStateCopyWithImpl(this._self, this._then);

  final _MyLocationSubscriptionsProviderState _self;
  final $Res Function(_MyLocationSubscriptionsProviderState) _then;

/// Create a copy of MyLocationSubscriptionsProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationSubscriptions = null,Object? getLocationSubscriptionsState = null,Object? subscribeToLocationStateWrappers = null,Object? unsubscribeFromLocationStateWrappers = null,Object? updateUserLocationSubscriptionLocationState = null,Object? updateUserLocationSubscriptionRadiusState = null,}) {
  return _then(_MyLocationSubscriptionsProviderState(
locationSubscriptions: null == locationSubscriptions ? _self._locationSubscriptions : locationSubscriptions // ignore: cast_nullable_to_non_nullable
as List<LocationSubscription>,getLocationSubscriptionsState: null == getLocationSubscriptionsState ? _self.getLocationSubscriptionsState : getLocationSubscriptionsState // ignore: cast_nullable_to_non_nullable
as GetLocationSubscriptionsState,subscribeToLocationStateWrappers: null == subscribeToLocationStateWrappers ? _self._subscribeToLocationStateWrappers : subscribeToLocationStateWrappers // ignore: cast_nullable_to_non_nullable
as List<SubscribeToLocationStateWrapper>,unsubscribeFromLocationStateWrappers: null == unsubscribeFromLocationStateWrappers ? _self._unsubscribeFromLocationStateWrappers : unsubscribeFromLocationStateWrappers // ignore: cast_nullable_to_non_nullable
as List<UnsubscribeFromLocationStateWrapper>,updateUserLocationSubscriptionLocationState: null == updateUserLocationSubscriptionLocationState ? _self.updateUserLocationSubscriptionLocationState : updateUserLocationSubscriptionLocationState // ignore: cast_nullable_to_non_nullable
as UpdateUserLocationSubscriptionLocationState,updateUserLocationSubscriptionRadiusState: null == updateUserLocationSubscriptionRadiusState ? _self.updateUserLocationSubscriptionRadiusState : updateUserLocationSubscriptionRadiusState // ignore: cast_nullable_to_non_nullable
as UpdateUserLocationSubscriptionRadiusState,
  ));
}

/// Create a copy of MyLocationSubscriptionsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetLocationSubscriptionsStateCopyWith<$Res> get getLocationSubscriptionsState {
  
  return $GetLocationSubscriptionsStateCopyWith<$Res>(_self.getLocationSubscriptionsState, (value) {
    return _then(_self.copyWith(getLocationSubscriptionsState: value));
  });
}/// Create a copy of MyLocationSubscriptionsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateUserLocationSubscriptionLocationStateCopyWith<$Res> get updateUserLocationSubscriptionLocationState {
  
  return $UpdateUserLocationSubscriptionLocationStateCopyWith<$Res>(_self.updateUserLocationSubscriptionLocationState, (value) {
    return _then(_self.copyWith(updateUserLocationSubscriptionLocationState: value));
  });
}/// Create a copy of MyLocationSubscriptionsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateUserLocationSubscriptionRadiusStateCopyWith<$Res> get updateUserLocationSubscriptionRadiusState {
  
  return $UpdateUserLocationSubscriptionRadiusStateCopyWith<$Res>(_self.updateUserLocationSubscriptionRadiusState, (value) {
    return _then(_self.copyWith(updateUserLocationSubscriptionRadiusState: value));
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

/// @nodoc
mixin _$SubscribeToLocationStateWrapper {

 String get id; LocationSubscription get locationSubscription; SubscribeToLocationState get subscribeToLocationState;
/// Create a copy of SubscribeToLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscribeToLocationStateWrapperCopyWith<SubscribeToLocationStateWrapper> get copyWith => _$SubscribeToLocationStateWrapperCopyWithImpl<SubscribeToLocationStateWrapper>(this as SubscribeToLocationStateWrapper, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscribeToLocationStateWrapper&&(identical(other.id, id) || other.id == id)&&(identical(other.locationSubscription, locationSubscription) || other.locationSubscription == locationSubscription)&&(identical(other.subscribeToLocationState, subscribeToLocationState) || other.subscribeToLocationState == subscribeToLocationState));
}


@override
int get hashCode => Object.hash(runtimeType,id,locationSubscription,subscribeToLocationState);

@override
String toString() {
  return 'SubscribeToLocationStateWrapper(id: $id, locationSubscription: $locationSubscription, subscribeToLocationState: $subscribeToLocationState)';
}


}

/// @nodoc
abstract mixin class $SubscribeToLocationStateWrapperCopyWith<$Res>  {
  factory $SubscribeToLocationStateWrapperCopyWith(SubscribeToLocationStateWrapper value, $Res Function(SubscribeToLocationStateWrapper) _then) = _$SubscribeToLocationStateWrapperCopyWithImpl;
@useResult
$Res call({
 String id, LocationSubscription locationSubscription, SubscribeToLocationState subscribeToLocationState
});


$LocationSubscriptionCopyWith<$Res> get locationSubscription;$SubscribeToLocationStateCopyWith<$Res> get subscribeToLocationState;

}
/// @nodoc
class _$SubscribeToLocationStateWrapperCopyWithImpl<$Res>
    implements $SubscribeToLocationStateWrapperCopyWith<$Res> {
  _$SubscribeToLocationStateWrapperCopyWithImpl(this._self, this._then);

  final SubscribeToLocationStateWrapper _self;
  final $Res Function(SubscribeToLocationStateWrapper) _then;

/// Create a copy of SubscribeToLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? locationSubscription = null,Object? subscribeToLocationState = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,locationSubscription: null == locationSubscription ? _self.locationSubscription : locationSubscription // ignore: cast_nullable_to_non_nullable
as LocationSubscription,subscribeToLocationState: null == subscribeToLocationState ? _self.subscribeToLocationState : subscribeToLocationState // ignore: cast_nullable_to_non_nullable
as SubscribeToLocationState,
  ));
}
/// Create a copy of SubscribeToLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationSubscriptionCopyWith<$Res> get locationSubscription {
  
  return $LocationSubscriptionCopyWith<$Res>(_self.locationSubscription, (value) {
    return _then(_self.copyWith(locationSubscription: value));
  });
}/// Create a copy of SubscribeToLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscribeToLocationStateCopyWith<$Res> get subscribeToLocationState {
  
  return $SubscribeToLocationStateCopyWith<$Res>(_self.subscribeToLocationState, (value) {
    return _then(_self.copyWith(subscribeToLocationState: value));
  });
}
}


/// Adds pattern-matching-related methods to [SubscribeToLocationStateWrapper].
extension SubscribeToLocationStateWrapperPatterns on SubscribeToLocationStateWrapper {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscribeToLocationStateWrapper value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscribeToLocationStateWrapper() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscribeToLocationStateWrapper value)  $default,){
final _that = this;
switch (_that) {
case _SubscribeToLocationStateWrapper():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscribeToLocationStateWrapper value)?  $default,){
final _that = this;
switch (_that) {
case _SubscribeToLocationStateWrapper() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocationSubscription locationSubscription,  SubscribeToLocationState subscribeToLocationState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscribeToLocationStateWrapper() when $default != null:
return $default(_that.id,_that.locationSubscription,_that.subscribeToLocationState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocationSubscription locationSubscription,  SubscribeToLocationState subscribeToLocationState)  $default,) {final _that = this;
switch (_that) {
case _SubscribeToLocationStateWrapper():
return $default(_that.id,_that.locationSubscription,_that.subscribeToLocationState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocationSubscription locationSubscription,  SubscribeToLocationState subscribeToLocationState)?  $default,) {final _that = this;
switch (_that) {
case _SubscribeToLocationStateWrapper() when $default != null:
return $default(_that.id,_that.locationSubscription,_that.subscribeToLocationState);case _:
  return null;

}
}

}

/// @nodoc


class _SubscribeToLocationStateWrapper implements SubscribeToLocationStateWrapper {
  const _SubscribeToLocationStateWrapper({required this.id, required this.locationSubscription, required this.subscribeToLocationState});
  

@override final  String id;
@override final  LocationSubscription locationSubscription;
@override final  SubscribeToLocationState subscribeToLocationState;

/// Create a copy of SubscribeToLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscribeToLocationStateWrapperCopyWith<_SubscribeToLocationStateWrapper> get copyWith => __$SubscribeToLocationStateWrapperCopyWithImpl<_SubscribeToLocationStateWrapper>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscribeToLocationStateWrapper&&(identical(other.id, id) || other.id == id)&&(identical(other.locationSubscription, locationSubscription) || other.locationSubscription == locationSubscription)&&(identical(other.subscribeToLocationState, subscribeToLocationState) || other.subscribeToLocationState == subscribeToLocationState));
}


@override
int get hashCode => Object.hash(runtimeType,id,locationSubscription,subscribeToLocationState);

@override
String toString() {
  return 'SubscribeToLocationStateWrapper(id: $id, locationSubscription: $locationSubscription, subscribeToLocationState: $subscribeToLocationState)';
}


}

/// @nodoc
abstract mixin class _$SubscribeToLocationStateWrapperCopyWith<$Res> implements $SubscribeToLocationStateWrapperCopyWith<$Res> {
  factory _$SubscribeToLocationStateWrapperCopyWith(_SubscribeToLocationStateWrapper value, $Res Function(_SubscribeToLocationStateWrapper) _then) = __$SubscribeToLocationStateWrapperCopyWithImpl;
@override @useResult
$Res call({
 String id, LocationSubscription locationSubscription, SubscribeToLocationState subscribeToLocationState
});


@override $LocationSubscriptionCopyWith<$Res> get locationSubscription;@override $SubscribeToLocationStateCopyWith<$Res> get subscribeToLocationState;

}
/// @nodoc
class __$SubscribeToLocationStateWrapperCopyWithImpl<$Res>
    implements _$SubscribeToLocationStateWrapperCopyWith<$Res> {
  __$SubscribeToLocationStateWrapperCopyWithImpl(this._self, this._then);

  final _SubscribeToLocationStateWrapper _self;
  final $Res Function(_SubscribeToLocationStateWrapper) _then;

/// Create a copy of SubscribeToLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? locationSubscription = null,Object? subscribeToLocationState = null,}) {
  return _then(_SubscribeToLocationStateWrapper(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,locationSubscription: null == locationSubscription ? _self.locationSubscription : locationSubscription // ignore: cast_nullable_to_non_nullable
as LocationSubscription,subscribeToLocationState: null == subscribeToLocationState ? _self.subscribeToLocationState : subscribeToLocationState // ignore: cast_nullable_to_non_nullable
as SubscribeToLocationState,
  ));
}

/// Create a copy of SubscribeToLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationSubscriptionCopyWith<$Res> get locationSubscription {
  
  return $LocationSubscriptionCopyWith<$Res>(_self.locationSubscription, (value) {
    return _then(_self.copyWith(locationSubscription: value));
  });
}/// Create a copy of SubscribeToLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscribeToLocationStateCopyWith<$Res> get subscribeToLocationState {
  
  return $SubscribeToLocationStateCopyWith<$Res>(_self.subscribeToLocationState, (value) {
    return _then(_self.copyWith(subscribeToLocationState: value));
  });
}
}

/// @nodoc
mixin _$UnsubscribeFromLocationStateWrapper {

 String get id; String get subscriptionId; UnsubscribeFromLocationState get unsubscribeFromLocationState;
/// Create a copy of UnsubscribeFromLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnsubscribeFromLocationStateWrapperCopyWith<UnsubscribeFromLocationStateWrapper> get copyWith => _$UnsubscribeFromLocationStateWrapperCopyWithImpl<UnsubscribeFromLocationStateWrapper>(this as UnsubscribeFromLocationStateWrapper, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnsubscribeFromLocationStateWrapper&&(identical(other.id, id) || other.id == id)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.unsubscribeFromLocationState, unsubscribeFromLocationState) || other.unsubscribeFromLocationState == unsubscribeFromLocationState));
}


@override
int get hashCode => Object.hash(runtimeType,id,subscriptionId,unsubscribeFromLocationState);

@override
String toString() {
  return 'UnsubscribeFromLocationStateWrapper(id: $id, subscriptionId: $subscriptionId, unsubscribeFromLocationState: $unsubscribeFromLocationState)';
}


}

/// @nodoc
abstract mixin class $UnsubscribeFromLocationStateWrapperCopyWith<$Res>  {
  factory $UnsubscribeFromLocationStateWrapperCopyWith(UnsubscribeFromLocationStateWrapper value, $Res Function(UnsubscribeFromLocationStateWrapper) _then) = _$UnsubscribeFromLocationStateWrapperCopyWithImpl;
@useResult
$Res call({
 String id, String subscriptionId, UnsubscribeFromLocationState unsubscribeFromLocationState
});


$UnsubscribeFromLocationStateCopyWith<$Res> get unsubscribeFromLocationState;

}
/// @nodoc
class _$UnsubscribeFromLocationStateWrapperCopyWithImpl<$Res>
    implements $UnsubscribeFromLocationStateWrapperCopyWith<$Res> {
  _$UnsubscribeFromLocationStateWrapperCopyWithImpl(this._self, this._then);

  final UnsubscribeFromLocationStateWrapper _self;
  final $Res Function(UnsubscribeFromLocationStateWrapper) _then;

/// Create a copy of UnsubscribeFromLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subscriptionId = null,Object? unsubscribeFromLocationState = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,unsubscribeFromLocationState: null == unsubscribeFromLocationState ? _self.unsubscribeFromLocationState : unsubscribeFromLocationState // ignore: cast_nullable_to_non_nullable
as UnsubscribeFromLocationState,
  ));
}
/// Create a copy of UnsubscribeFromLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnsubscribeFromLocationStateCopyWith<$Res> get unsubscribeFromLocationState {
  
  return $UnsubscribeFromLocationStateCopyWith<$Res>(_self.unsubscribeFromLocationState, (value) {
    return _then(_self.copyWith(unsubscribeFromLocationState: value));
  });
}
}


/// Adds pattern-matching-related methods to [UnsubscribeFromLocationStateWrapper].
extension UnsubscribeFromLocationStateWrapperPatterns on UnsubscribeFromLocationStateWrapper {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnsubscribeFromLocationStateWrapper value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateWrapper() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnsubscribeFromLocationStateWrapper value)  $default,){
final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateWrapper():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnsubscribeFromLocationStateWrapper value)?  $default,){
final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateWrapper() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String subscriptionId,  UnsubscribeFromLocationState unsubscribeFromLocationState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateWrapper() when $default != null:
return $default(_that.id,_that.subscriptionId,_that.unsubscribeFromLocationState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String subscriptionId,  UnsubscribeFromLocationState unsubscribeFromLocationState)  $default,) {final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateWrapper():
return $default(_that.id,_that.subscriptionId,_that.unsubscribeFromLocationState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String subscriptionId,  UnsubscribeFromLocationState unsubscribeFromLocationState)?  $default,) {final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateWrapper() when $default != null:
return $default(_that.id,_that.subscriptionId,_that.unsubscribeFromLocationState);case _:
  return null;

}
}

}

/// @nodoc


class _UnsubscribeFromLocationStateWrapper implements UnsubscribeFromLocationStateWrapper {
  const _UnsubscribeFromLocationStateWrapper({required this.id, required this.subscriptionId, required this.unsubscribeFromLocationState});
  

@override final  String id;
@override final  String subscriptionId;
@override final  UnsubscribeFromLocationState unsubscribeFromLocationState;

/// Create a copy of UnsubscribeFromLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnsubscribeFromLocationStateWrapperCopyWith<_UnsubscribeFromLocationStateWrapper> get copyWith => __$UnsubscribeFromLocationStateWrapperCopyWithImpl<_UnsubscribeFromLocationStateWrapper>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnsubscribeFromLocationStateWrapper&&(identical(other.id, id) || other.id == id)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.unsubscribeFromLocationState, unsubscribeFromLocationState) || other.unsubscribeFromLocationState == unsubscribeFromLocationState));
}


@override
int get hashCode => Object.hash(runtimeType,id,subscriptionId,unsubscribeFromLocationState);

@override
String toString() {
  return 'UnsubscribeFromLocationStateWrapper(id: $id, subscriptionId: $subscriptionId, unsubscribeFromLocationState: $unsubscribeFromLocationState)';
}


}

/// @nodoc
abstract mixin class _$UnsubscribeFromLocationStateWrapperCopyWith<$Res> implements $UnsubscribeFromLocationStateWrapperCopyWith<$Res> {
  factory _$UnsubscribeFromLocationStateWrapperCopyWith(_UnsubscribeFromLocationStateWrapper value, $Res Function(_UnsubscribeFromLocationStateWrapper) _then) = __$UnsubscribeFromLocationStateWrapperCopyWithImpl;
@override @useResult
$Res call({
 String id, String subscriptionId, UnsubscribeFromLocationState unsubscribeFromLocationState
});


@override $UnsubscribeFromLocationStateCopyWith<$Res> get unsubscribeFromLocationState;

}
/// @nodoc
class __$UnsubscribeFromLocationStateWrapperCopyWithImpl<$Res>
    implements _$UnsubscribeFromLocationStateWrapperCopyWith<$Res> {
  __$UnsubscribeFromLocationStateWrapperCopyWithImpl(this._self, this._then);

  final _UnsubscribeFromLocationStateWrapper _self;
  final $Res Function(_UnsubscribeFromLocationStateWrapper) _then;

/// Create a copy of UnsubscribeFromLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subscriptionId = null,Object? unsubscribeFromLocationState = null,}) {
  return _then(_UnsubscribeFromLocationStateWrapper(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,unsubscribeFromLocationState: null == unsubscribeFromLocationState ? _self.unsubscribeFromLocationState : unsubscribeFromLocationState // ignore: cast_nullable_to_non_nullable
as UnsubscribeFromLocationState,
  ));
}

/// Create a copy of UnsubscribeFromLocationStateWrapper
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnsubscribeFromLocationStateCopyWith<$Res> get unsubscribeFromLocationState {
  
  return $UnsubscribeFromLocationStateCopyWith<$Res>(_self.unsubscribeFromLocationState, (value) {
    return _then(_self.copyWith(unsubscribeFromLocationState: value));
  });
}
}

/// @nodoc
mixin _$SubscribeToLocationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscribeToLocationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscribeToLocationState()';
}


}

/// @nodoc
class $SubscribeToLocationStateCopyWith<$Res>  {
$SubscribeToLocationStateCopyWith(SubscribeToLocationState _, $Res Function(SubscribeToLocationState) __);
}


/// Adds pattern-matching-related methods to [SubscribeToLocationState].
extension SubscribeToLocationStatePatterns on SubscribeToLocationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SubscribeToLocationStateLoading value)?  loading,TResult Function( _SubscribeToLocationStateSuccess value)?  success,TResult Function( _SubscribeToLocationStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscribeToLocationStateLoading() when loading != null:
return loading(_that);case _SubscribeToLocationStateSuccess() when success != null:
return success(_that);case _SubscribeToLocationStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SubscribeToLocationStateLoading value)  loading,required TResult Function( _SubscribeToLocationStateSuccess value)  success,required TResult Function( _SubscribeToLocationStateError value)  error,}){
final _that = this;
switch (_that) {
case _SubscribeToLocationStateLoading():
return loading(_that);case _SubscribeToLocationStateSuccess():
return success(_that);case _SubscribeToLocationStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SubscribeToLocationStateLoading value)?  loading,TResult? Function( _SubscribeToLocationStateSuccess value)?  success,TResult? Function( _SubscribeToLocationStateError value)?  error,}){
final _that = this;
switch (_that) {
case _SubscribeToLocationStateLoading() when loading != null:
return loading(_that);case _SubscribeToLocationStateSuccess() when success != null:
return success(_that);case _SubscribeToLocationStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function()?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscribeToLocationStateLoading() when loading != null:
return loading();case _SubscribeToLocationStateSuccess() when success != null:
return success();case _SubscribeToLocationStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function()  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _SubscribeToLocationStateLoading():
return loading();case _SubscribeToLocationStateSuccess():
return success();case _SubscribeToLocationStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _SubscribeToLocationStateLoading() when loading != null:
return loading();case _SubscribeToLocationStateSuccess() when success != null:
return success();case _SubscribeToLocationStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _SubscribeToLocationStateLoading implements SubscribeToLocationState {
  const _SubscribeToLocationStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscribeToLocationStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscribeToLocationState.loading()';
}


}




/// @nodoc


class _SubscribeToLocationStateSuccess implements SubscribeToLocationState {
  const _SubscribeToLocationStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscribeToLocationStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscribeToLocationState.success()';
}


}




/// @nodoc


class _SubscribeToLocationStateError implements SubscribeToLocationState {
  const _SubscribeToLocationStateError(this.error);
  

 final  AppError error;

/// Create a copy of SubscribeToLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscribeToLocationStateErrorCopyWith<_SubscribeToLocationStateError> get copyWith => __$SubscribeToLocationStateErrorCopyWithImpl<_SubscribeToLocationStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscribeToLocationStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'SubscribeToLocationState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$SubscribeToLocationStateErrorCopyWith<$Res> implements $SubscribeToLocationStateCopyWith<$Res> {
  factory _$SubscribeToLocationStateErrorCopyWith(_SubscribeToLocationStateError value, $Res Function(_SubscribeToLocationStateError) _then) = __$SubscribeToLocationStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$SubscribeToLocationStateErrorCopyWithImpl<$Res>
    implements _$SubscribeToLocationStateErrorCopyWith<$Res> {
  __$SubscribeToLocationStateErrorCopyWithImpl(this._self, this._then);

  final _SubscribeToLocationStateError _self;
  final $Res Function(_SubscribeToLocationStateError) _then;

/// Create a copy of SubscribeToLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_SubscribeToLocationStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of SubscribeToLocationState
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
mixin _$UnsubscribeFromLocationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnsubscribeFromLocationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UnsubscribeFromLocationState()';
}


}

/// @nodoc
class $UnsubscribeFromLocationStateCopyWith<$Res>  {
$UnsubscribeFromLocationStateCopyWith(UnsubscribeFromLocationState _, $Res Function(UnsubscribeFromLocationState) __);
}


/// Adds pattern-matching-related methods to [UnsubscribeFromLocationState].
extension UnsubscribeFromLocationStatePatterns on UnsubscribeFromLocationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _UnsubscribeFromLocationStateLoading value)?  loading,TResult Function( _UnsubscribeFromLocationStateSuccess value)?  success,TResult Function( _UnsubscribeFromLocationStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateLoading() when loading != null:
return loading(_that);case _UnsubscribeFromLocationStateSuccess() when success != null:
return success(_that);case _UnsubscribeFromLocationStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _UnsubscribeFromLocationStateLoading value)  loading,required TResult Function( _UnsubscribeFromLocationStateSuccess value)  success,required TResult Function( _UnsubscribeFromLocationStateError value)  error,}){
final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateLoading():
return loading(_that);case _UnsubscribeFromLocationStateSuccess():
return success(_that);case _UnsubscribeFromLocationStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _UnsubscribeFromLocationStateLoading value)?  loading,TResult? Function( _UnsubscribeFromLocationStateSuccess value)?  success,TResult? Function( _UnsubscribeFromLocationStateError value)?  error,}){
final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateLoading() when loading != null:
return loading(_that);case _UnsubscribeFromLocationStateSuccess() when success != null:
return success(_that);case _UnsubscribeFromLocationStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function()?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateLoading() when loading != null:
return loading();case _UnsubscribeFromLocationStateSuccess() when success != null:
return success();case _UnsubscribeFromLocationStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function()  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateLoading():
return loading();case _UnsubscribeFromLocationStateSuccess():
return success();case _UnsubscribeFromLocationStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateLoading() when loading != null:
return loading();case _UnsubscribeFromLocationStateSuccess() when success != null:
return success();case _UnsubscribeFromLocationStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _UnsubscribeFromLocationStateLoading implements UnsubscribeFromLocationState {
  const _UnsubscribeFromLocationStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnsubscribeFromLocationStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UnsubscribeFromLocationState.loading()';
}


}




/// @nodoc


class _UnsubscribeFromLocationStateSuccess implements UnsubscribeFromLocationState {
  const _UnsubscribeFromLocationStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnsubscribeFromLocationStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UnsubscribeFromLocationState.success()';
}


}




/// @nodoc


class _UnsubscribeFromLocationStateError implements UnsubscribeFromLocationState {
  const _UnsubscribeFromLocationStateError(this.error);
  

 final  AppError error;

/// Create a copy of UnsubscribeFromLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnsubscribeFromLocationStateErrorCopyWith<_UnsubscribeFromLocationStateError> get copyWith => __$UnsubscribeFromLocationStateErrorCopyWithImpl<_UnsubscribeFromLocationStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnsubscribeFromLocationStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'UnsubscribeFromLocationState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$UnsubscribeFromLocationStateErrorCopyWith<$Res> implements $UnsubscribeFromLocationStateCopyWith<$Res> {
  factory _$UnsubscribeFromLocationStateErrorCopyWith(_UnsubscribeFromLocationStateError value, $Res Function(_UnsubscribeFromLocationStateError) _then) = __$UnsubscribeFromLocationStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$UnsubscribeFromLocationStateErrorCopyWithImpl<$Res>
    implements _$UnsubscribeFromLocationStateErrorCopyWith<$Res> {
  __$UnsubscribeFromLocationStateErrorCopyWithImpl(this._self, this._then);

  final _UnsubscribeFromLocationStateError _self;
  final $Res Function(_UnsubscribeFromLocationStateError) _then;

/// Create a copy of UnsubscribeFromLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_UnsubscribeFromLocationStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of UnsubscribeFromLocationState
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
mixin _$UpdateUserLocationSubscriptionLocationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserLocationSubscriptionLocationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserLocationSubscriptionLocationState()';
}


}

/// @nodoc
class $UpdateUserLocationSubscriptionLocationStateCopyWith<$Res>  {
$UpdateUserLocationSubscriptionLocationStateCopyWith(UpdateUserLocationSubscriptionLocationState _, $Res Function(UpdateUserLocationSubscriptionLocationState) __);
}


/// Adds pattern-matching-related methods to [UpdateUserLocationSubscriptionLocationState].
extension UpdateUserLocationSubscriptionLocationStatePatterns on UpdateUserLocationSubscriptionLocationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _UpdateUserLocationSubscriptionLocationStateInitial value)?  initial,TResult Function( _UpdateUserLocationSubscriptionLocationStateLoading value)?  loading,TResult Function( _UpdateUserLocationSubscriptionLocationStateSuccess value)?  success,TResult Function( _UpdateUserLocationSubscriptionLocationStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateUserLocationSubscriptionLocationStateInitial() when initial != null:
return initial(_that);case _UpdateUserLocationSubscriptionLocationStateLoading() when loading != null:
return loading(_that);case _UpdateUserLocationSubscriptionLocationStateSuccess() when success != null:
return success(_that);case _UpdateUserLocationSubscriptionLocationStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _UpdateUserLocationSubscriptionLocationStateInitial value)  initial,required TResult Function( _UpdateUserLocationSubscriptionLocationStateLoading value)  loading,required TResult Function( _UpdateUserLocationSubscriptionLocationStateSuccess value)  success,required TResult Function( _UpdateUserLocationSubscriptionLocationStateError value)  error,}){
final _that = this;
switch (_that) {
case _UpdateUserLocationSubscriptionLocationStateInitial():
return initial(_that);case _UpdateUserLocationSubscriptionLocationStateLoading():
return loading(_that);case _UpdateUserLocationSubscriptionLocationStateSuccess():
return success(_that);case _UpdateUserLocationSubscriptionLocationStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _UpdateUserLocationSubscriptionLocationStateInitial value)?  initial,TResult? Function( _UpdateUserLocationSubscriptionLocationStateLoading value)?  loading,TResult? Function( _UpdateUserLocationSubscriptionLocationStateSuccess value)?  success,TResult? Function( _UpdateUserLocationSubscriptionLocationStateError value)?  error,}){
final _that = this;
switch (_that) {
case _UpdateUserLocationSubscriptionLocationStateInitial() when initial != null:
return initial(_that);case _UpdateUserLocationSubscriptionLocationStateLoading() when loading != null:
return loading(_that);case _UpdateUserLocationSubscriptionLocationStateSuccess() when success != null:
return success(_that);case _UpdateUserLocationSubscriptionLocationStateError() when error != null:
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
case _UpdateUserLocationSubscriptionLocationStateInitial() when initial != null:
return initial();case _UpdateUserLocationSubscriptionLocationStateLoading() when loading != null:
return loading();case _UpdateUserLocationSubscriptionLocationStateSuccess() when success != null:
return success();case _UpdateUserLocationSubscriptionLocationStateError() when error != null:
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
case _UpdateUserLocationSubscriptionLocationStateInitial():
return initial();case _UpdateUserLocationSubscriptionLocationStateLoading():
return loading();case _UpdateUserLocationSubscriptionLocationStateSuccess():
return success();case _UpdateUserLocationSubscriptionLocationStateError():
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
case _UpdateUserLocationSubscriptionLocationStateInitial() when initial != null:
return initial();case _UpdateUserLocationSubscriptionLocationStateLoading() when loading != null:
return loading();case _UpdateUserLocationSubscriptionLocationStateSuccess() when success != null:
return success();case _UpdateUserLocationSubscriptionLocationStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateUserLocationSubscriptionLocationStateInitial implements UpdateUserLocationSubscriptionLocationState {
  const _UpdateUserLocationSubscriptionLocationStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserLocationSubscriptionLocationStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserLocationSubscriptionLocationState.initial()';
}


}




/// @nodoc


class _UpdateUserLocationSubscriptionLocationStateLoading implements UpdateUserLocationSubscriptionLocationState {
  const _UpdateUserLocationSubscriptionLocationStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserLocationSubscriptionLocationStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserLocationSubscriptionLocationState.loading()';
}


}




/// @nodoc


class _UpdateUserLocationSubscriptionLocationStateSuccess implements UpdateUserLocationSubscriptionLocationState {
  const _UpdateUserLocationSubscriptionLocationStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserLocationSubscriptionLocationStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserLocationSubscriptionLocationState.success()';
}


}




/// @nodoc


class _UpdateUserLocationSubscriptionLocationStateError implements UpdateUserLocationSubscriptionLocationState {
  const _UpdateUserLocationSubscriptionLocationStateError(this.error);
  

 final  AppError error;

/// Create a copy of UpdateUserLocationSubscriptionLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateUserLocationSubscriptionLocationStateErrorCopyWith<_UpdateUserLocationSubscriptionLocationStateError> get copyWith => __$UpdateUserLocationSubscriptionLocationStateErrorCopyWithImpl<_UpdateUserLocationSubscriptionLocationStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserLocationSubscriptionLocationStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'UpdateUserLocationSubscriptionLocationState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$UpdateUserLocationSubscriptionLocationStateErrorCopyWith<$Res> implements $UpdateUserLocationSubscriptionLocationStateCopyWith<$Res> {
  factory _$UpdateUserLocationSubscriptionLocationStateErrorCopyWith(_UpdateUserLocationSubscriptionLocationStateError value, $Res Function(_UpdateUserLocationSubscriptionLocationStateError) _then) = __$UpdateUserLocationSubscriptionLocationStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$UpdateUserLocationSubscriptionLocationStateErrorCopyWithImpl<$Res>
    implements _$UpdateUserLocationSubscriptionLocationStateErrorCopyWith<$Res> {
  __$UpdateUserLocationSubscriptionLocationStateErrorCopyWithImpl(this._self, this._then);

  final _UpdateUserLocationSubscriptionLocationStateError _self;
  final $Res Function(_UpdateUserLocationSubscriptionLocationStateError) _then;

/// Create a copy of UpdateUserLocationSubscriptionLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_UpdateUserLocationSubscriptionLocationStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of UpdateUserLocationSubscriptionLocationState
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
mixin _$UpdateUserLocationSubscriptionRadiusState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserLocationSubscriptionRadiusState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserLocationSubscriptionRadiusState()';
}


}

/// @nodoc
class $UpdateUserLocationSubscriptionRadiusStateCopyWith<$Res>  {
$UpdateUserLocationSubscriptionRadiusStateCopyWith(UpdateUserLocationSubscriptionRadiusState _, $Res Function(UpdateUserLocationSubscriptionRadiusState) __);
}


/// Adds pattern-matching-related methods to [UpdateUserLocationSubscriptionRadiusState].
extension UpdateUserLocationSubscriptionRadiusStatePatterns on UpdateUserLocationSubscriptionRadiusState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _UpdateUserLocationSubscriptionRadiusStateInitial value)?  initial,TResult Function( _UpdateUserLocationSubscriptionRadiusStateLoading value)?  loading,TResult Function( _UpdateUserLocationSubscriptionRadiusStateSuccess value)?  success,TResult Function( _UpdateUserLocationSubscriptionRadiusStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateUserLocationSubscriptionRadiusStateInitial() when initial != null:
return initial(_that);case _UpdateUserLocationSubscriptionRadiusStateLoading() when loading != null:
return loading(_that);case _UpdateUserLocationSubscriptionRadiusStateSuccess() when success != null:
return success(_that);case _UpdateUserLocationSubscriptionRadiusStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _UpdateUserLocationSubscriptionRadiusStateInitial value)  initial,required TResult Function( _UpdateUserLocationSubscriptionRadiusStateLoading value)  loading,required TResult Function( _UpdateUserLocationSubscriptionRadiusStateSuccess value)  success,required TResult Function( _UpdateUserLocationSubscriptionRadiusStateError value)  error,}){
final _that = this;
switch (_that) {
case _UpdateUserLocationSubscriptionRadiusStateInitial():
return initial(_that);case _UpdateUserLocationSubscriptionRadiusStateLoading():
return loading(_that);case _UpdateUserLocationSubscriptionRadiusStateSuccess():
return success(_that);case _UpdateUserLocationSubscriptionRadiusStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _UpdateUserLocationSubscriptionRadiusStateInitial value)?  initial,TResult? Function( _UpdateUserLocationSubscriptionRadiusStateLoading value)?  loading,TResult? Function( _UpdateUserLocationSubscriptionRadiusStateSuccess value)?  success,TResult? Function( _UpdateUserLocationSubscriptionRadiusStateError value)?  error,}){
final _that = this;
switch (_that) {
case _UpdateUserLocationSubscriptionRadiusStateInitial() when initial != null:
return initial(_that);case _UpdateUserLocationSubscriptionRadiusStateLoading() when loading != null:
return loading(_that);case _UpdateUserLocationSubscriptionRadiusStateSuccess() when success != null:
return success(_that);case _UpdateUserLocationSubscriptionRadiusStateError() when error != null:
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
case _UpdateUserLocationSubscriptionRadiusStateInitial() when initial != null:
return initial();case _UpdateUserLocationSubscriptionRadiusStateLoading() when loading != null:
return loading();case _UpdateUserLocationSubscriptionRadiusStateSuccess() when success != null:
return success();case _UpdateUserLocationSubscriptionRadiusStateError() when error != null:
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
case _UpdateUserLocationSubscriptionRadiusStateInitial():
return initial();case _UpdateUserLocationSubscriptionRadiusStateLoading():
return loading();case _UpdateUserLocationSubscriptionRadiusStateSuccess():
return success();case _UpdateUserLocationSubscriptionRadiusStateError():
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
case _UpdateUserLocationSubscriptionRadiusStateInitial() when initial != null:
return initial();case _UpdateUserLocationSubscriptionRadiusStateLoading() when loading != null:
return loading();case _UpdateUserLocationSubscriptionRadiusStateSuccess() when success != null:
return success();case _UpdateUserLocationSubscriptionRadiusStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateUserLocationSubscriptionRadiusStateInitial implements UpdateUserLocationSubscriptionRadiusState {
  const _UpdateUserLocationSubscriptionRadiusStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserLocationSubscriptionRadiusStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserLocationSubscriptionRadiusState.initial()';
}


}




/// @nodoc


class _UpdateUserLocationSubscriptionRadiusStateLoading implements UpdateUserLocationSubscriptionRadiusState {
  const _UpdateUserLocationSubscriptionRadiusStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserLocationSubscriptionRadiusStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserLocationSubscriptionRadiusState.loading()';
}


}




/// @nodoc


class _UpdateUserLocationSubscriptionRadiusStateSuccess implements UpdateUserLocationSubscriptionRadiusState {
  const _UpdateUserLocationSubscriptionRadiusStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserLocationSubscriptionRadiusStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateUserLocationSubscriptionRadiusState.success()';
}


}




/// @nodoc


class _UpdateUserLocationSubscriptionRadiusStateError implements UpdateUserLocationSubscriptionRadiusState {
  const _UpdateUserLocationSubscriptionRadiusStateError(this.error);
  

 final  AppError error;

/// Create a copy of UpdateUserLocationSubscriptionRadiusState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateUserLocationSubscriptionRadiusStateErrorCopyWith<_UpdateUserLocationSubscriptionRadiusStateError> get copyWith => __$UpdateUserLocationSubscriptionRadiusStateErrorCopyWithImpl<_UpdateUserLocationSubscriptionRadiusStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserLocationSubscriptionRadiusStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'UpdateUserLocationSubscriptionRadiusState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$UpdateUserLocationSubscriptionRadiusStateErrorCopyWith<$Res> implements $UpdateUserLocationSubscriptionRadiusStateCopyWith<$Res> {
  factory _$UpdateUserLocationSubscriptionRadiusStateErrorCopyWith(_UpdateUserLocationSubscriptionRadiusStateError value, $Res Function(_UpdateUserLocationSubscriptionRadiusStateError) _then) = __$UpdateUserLocationSubscriptionRadiusStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$UpdateUserLocationSubscriptionRadiusStateErrorCopyWithImpl<$Res>
    implements _$UpdateUserLocationSubscriptionRadiusStateErrorCopyWith<$Res> {
  __$UpdateUserLocationSubscriptionRadiusStateErrorCopyWithImpl(this._self, this._then);

  final _UpdateUserLocationSubscriptionRadiusStateError _self;
  final $Res Function(_UpdateUserLocationSubscriptionRadiusStateError) _then;

/// Create a copy of UpdateUserLocationSubscriptionRadiusState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_UpdateUserLocationSubscriptionRadiusStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of UpdateUserLocationSubscriptionRadiusState
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
