// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_search_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MainSearchProviderState {

/// The location selected from the search results.
 AlrtLocation? get searchedLocation;/// The hazards fetched from the search results after a successful fetch.
 List<Hazard> get hazards;/// The current page of hazards being viewed.
 int get currentPage;/// The ID of the subscription to the current searched location.
 String? get subscriptionId;/// The state of fetching hazards by location.
 GetHazardsByLocationState get getHazardsByLocationState;/// The state of fetching the next page of hazards by location.
 GetHazardsByLocationState get getNextHazardsByLocationState;/// The state of subscribing to location.
 SubscribeToLocationState get subscribeToLocationState;/// The state of unsubscribing from location.
 UnsubscribeFromLocationState get unsubscribeFromLocationState;
/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MainSearchProviderStateCopyWith<MainSearchProviderState> get copyWith => _$MainSearchProviderStateCopyWithImpl<MainSearchProviderState>(this as MainSearchProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MainSearchProviderState&&(identical(other.searchedLocation, searchedLocation) || other.searchedLocation == searchedLocation)&&const DeepCollectionEquality().equals(other.hazards, hazards)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.getHazardsByLocationState, getHazardsByLocationState) || other.getHazardsByLocationState == getHazardsByLocationState)&&(identical(other.getNextHazardsByLocationState, getNextHazardsByLocationState) || other.getNextHazardsByLocationState == getNextHazardsByLocationState)&&(identical(other.subscribeToLocationState, subscribeToLocationState) || other.subscribeToLocationState == subscribeToLocationState)&&(identical(other.unsubscribeFromLocationState, unsubscribeFromLocationState) || other.unsubscribeFromLocationState == unsubscribeFromLocationState));
}


@override
int get hashCode => Object.hash(runtimeType,searchedLocation,const DeepCollectionEquality().hash(hazards),currentPage,subscriptionId,getHazardsByLocationState,getNextHazardsByLocationState,subscribeToLocationState,unsubscribeFromLocationState);

@override
String toString() {
  return 'MainSearchProviderState(searchedLocation: $searchedLocation, hazards: $hazards, currentPage: $currentPage, subscriptionId: $subscriptionId, getHazardsByLocationState: $getHazardsByLocationState, getNextHazardsByLocationState: $getNextHazardsByLocationState, subscribeToLocationState: $subscribeToLocationState, unsubscribeFromLocationState: $unsubscribeFromLocationState)';
}


}

/// @nodoc
abstract mixin class $MainSearchProviderStateCopyWith<$Res>  {
  factory $MainSearchProviderStateCopyWith(MainSearchProviderState value, $Res Function(MainSearchProviderState) _then) = _$MainSearchProviderStateCopyWithImpl;
@useResult
$Res call({
 AlrtLocation? searchedLocation, List<Hazard> hazards, int currentPage, String? subscriptionId, GetHazardsByLocationState getHazardsByLocationState, GetHazardsByLocationState getNextHazardsByLocationState, SubscribeToLocationState subscribeToLocationState, UnsubscribeFromLocationState unsubscribeFromLocationState
});


$AlrtLocationCopyWith<$Res>? get searchedLocation;$GetHazardsByLocationStateCopyWith<$Res> get getHazardsByLocationState;$GetHazardsByLocationStateCopyWith<$Res> get getNextHazardsByLocationState;$SubscribeToLocationStateCopyWith<$Res> get subscribeToLocationState;$UnsubscribeFromLocationStateCopyWith<$Res> get unsubscribeFromLocationState;

}
/// @nodoc
class _$MainSearchProviderStateCopyWithImpl<$Res>
    implements $MainSearchProviderStateCopyWith<$Res> {
  _$MainSearchProviderStateCopyWithImpl(this._self, this._then);

  final MainSearchProviderState _self;
  final $Res Function(MainSearchProviderState) _then;

/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchedLocation = freezed,Object? hazards = null,Object? currentPage = null,Object? subscriptionId = freezed,Object? getHazardsByLocationState = null,Object? getNextHazardsByLocationState = null,Object? subscribeToLocationState = null,Object? unsubscribeFromLocationState = null,}) {
  return _then(_self.copyWith(
searchedLocation: freezed == searchedLocation ? _self.searchedLocation : searchedLocation // ignore: cast_nullable_to_non_nullable
as AlrtLocation?,hazards: null == hazards ? _self.hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,getHazardsByLocationState: null == getHazardsByLocationState ? _self.getHazardsByLocationState : getHazardsByLocationState // ignore: cast_nullable_to_non_nullable
as GetHazardsByLocationState,getNextHazardsByLocationState: null == getNextHazardsByLocationState ? _self.getNextHazardsByLocationState : getNextHazardsByLocationState // ignore: cast_nullable_to_non_nullable
as GetHazardsByLocationState,subscribeToLocationState: null == subscribeToLocationState ? _self.subscribeToLocationState : subscribeToLocationState // ignore: cast_nullable_to_non_nullable
as SubscribeToLocationState,unsubscribeFromLocationState: null == unsubscribeFromLocationState ? _self.unsubscribeFromLocationState : unsubscribeFromLocationState // ignore: cast_nullable_to_non_nullable
as UnsubscribeFromLocationState,
  ));
}
/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res>? get searchedLocation {
    if (_self.searchedLocation == null) {
    return null;
  }

  return $AlrtLocationCopyWith<$Res>(_self.searchedLocation!, (value) {
    return _then(_self.copyWith(searchedLocation: value));
  });
}/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetHazardsByLocationStateCopyWith<$Res> get getHazardsByLocationState {
  
  return $GetHazardsByLocationStateCopyWith<$Res>(_self.getHazardsByLocationState, (value) {
    return _then(_self.copyWith(getHazardsByLocationState: value));
  });
}/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetHazardsByLocationStateCopyWith<$Res> get getNextHazardsByLocationState {
  
  return $GetHazardsByLocationStateCopyWith<$Res>(_self.getNextHazardsByLocationState, (value) {
    return _then(_self.copyWith(getNextHazardsByLocationState: value));
  });
}/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscribeToLocationStateCopyWith<$Res> get subscribeToLocationState {
  
  return $SubscribeToLocationStateCopyWith<$Res>(_self.subscribeToLocationState, (value) {
    return _then(_self.copyWith(subscribeToLocationState: value));
  });
}/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnsubscribeFromLocationStateCopyWith<$Res> get unsubscribeFromLocationState {
  
  return $UnsubscribeFromLocationStateCopyWith<$Res>(_self.unsubscribeFromLocationState, (value) {
    return _then(_self.copyWith(unsubscribeFromLocationState: value));
  });
}
}


/// Adds pattern-matching-related methods to [MainSearchProviderState].
extension MainSearchProviderStatePatterns on MainSearchProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MainSearchProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MainSearchProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MainSearchProviderState value)  $default,){
final _that = this;
switch (_that) {
case _MainSearchProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MainSearchProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _MainSearchProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AlrtLocation? searchedLocation,  List<Hazard> hazards,  int currentPage,  String? subscriptionId,  GetHazardsByLocationState getHazardsByLocationState,  GetHazardsByLocationState getNextHazardsByLocationState,  SubscribeToLocationState subscribeToLocationState,  UnsubscribeFromLocationState unsubscribeFromLocationState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MainSearchProviderState() when $default != null:
return $default(_that.searchedLocation,_that.hazards,_that.currentPage,_that.subscriptionId,_that.getHazardsByLocationState,_that.getNextHazardsByLocationState,_that.subscribeToLocationState,_that.unsubscribeFromLocationState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AlrtLocation? searchedLocation,  List<Hazard> hazards,  int currentPage,  String? subscriptionId,  GetHazardsByLocationState getHazardsByLocationState,  GetHazardsByLocationState getNextHazardsByLocationState,  SubscribeToLocationState subscribeToLocationState,  UnsubscribeFromLocationState unsubscribeFromLocationState)  $default,) {final _that = this;
switch (_that) {
case _MainSearchProviderState():
return $default(_that.searchedLocation,_that.hazards,_that.currentPage,_that.subscriptionId,_that.getHazardsByLocationState,_that.getNextHazardsByLocationState,_that.subscribeToLocationState,_that.unsubscribeFromLocationState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AlrtLocation? searchedLocation,  List<Hazard> hazards,  int currentPage,  String? subscriptionId,  GetHazardsByLocationState getHazardsByLocationState,  GetHazardsByLocationState getNextHazardsByLocationState,  SubscribeToLocationState subscribeToLocationState,  UnsubscribeFromLocationState unsubscribeFromLocationState)?  $default,) {final _that = this;
switch (_that) {
case _MainSearchProviderState() when $default != null:
return $default(_that.searchedLocation,_that.hazards,_that.currentPage,_that.subscriptionId,_that.getHazardsByLocationState,_that.getNextHazardsByLocationState,_that.subscribeToLocationState,_that.unsubscribeFromLocationState);case _:
  return null;

}
}

}

/// @nodoc


class _MainSearchProviderState implements MainSearchProviderState {
  const _MainSearchProviderState({this.searchedLocation, final  List<Hazard> hazards = const <Hazard>[], this.currentPage = 1, this.subscriptionId, this.getHazardsByLocationState = const GetHazardsByLocationState.initial(), this.getNextHazardsByLocationState = const GetHazardsByLocationState.initial(), this.subscribeToLocationState = const SubscribeToLocationState.initial(), this.unsubscribeFromLocationState = const UnsubscribeFromLocationState.initial()}): _hazards = hazards;
  

/// The location selected from the search results.
@override final  AlrtLocation? searchedLocation;
/// The hazards fetched from the search results after a successful fetch.
 final  List<Hazard> _hazards;
/// The hazards fetched from the search results after a successful fetch.
@override@JsonKey() List<Hazard> get hazards {
  if (_hazards is EqualUnmodifiableListView) return _hazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazards);
}

/// The current page of hazards being viewed.
@override@JsonKey() final  int currentPage;
/// The ID of the subscription to the current searched location.
@override final  String? subscriptionId;
/// The state of fetching hazards by location.
@override@JsonKey() final  GetHazardsByLocationState getHazardsByLocationState;
/// The state of fetching the next page of hazards by location.
@override@JsonKey() final  GetHazardsByLocationState getNextHazardsByLocationState;
/// The state of subscribing to location.
@override@JsonKey() final  SubscribeToLocationState subscribeToLocationState;
/// The state of unsubscribing from location.
@override@JsonKey() final  UnsubscribeFromLocationState unsubscribeFromLocationState;

/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MainSearchProviderStateCopyWith<_MainSearchProviderState> get copyWith => __$MainSearchProviderStateCopyWithImpl<_MainSearchProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MainSearchProviderState&&(identical(other.searchedLocation, searchedLocation) || other.searchedLocation == searchedLocation)&&const DeepCollectionEquality().equals(other._hazards, _hazards)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.getHazardsByLocationState, getHazardsByLocationState) || other.getHazardsByLocationState == getHazardsByLocationState)&&(identical(other.getNextHazardsByLocationState, getNextHazardsByLocationState) || other.getNextHazardsByLocationState == getNextHazardsByLocationState)&&(identical(other.subscribeToLocationState, subscribeToLocationState) || other.subscribeToLocationState == subscribeToLocationState)&&(identical(other.unsubscribeFromLocationState, unsubscribeFromLocationState) || other.unsubscribeFromLocationState == unsubscribeFromLocationState));
}


@override
int get hashCode => Object.hash(runtimeType,searchedLocation,const DeepCollectionEquality().hash(_hazards),currentPage,subscriptionId,getHazardsByLocationState,getNextHazardsByLocationState,subscribeToLocationState,unsubscribeFromLocationState);

@override
String toString() {
  return 'MainSearchProviderState(searchedLocation: $searchedLocation, hazards: $hazards, currentPage: $currentPage, subscriptionId: $subscriptionId, getHazardsByLocationState: $getHazardsByLocationState, getNextHazardsByLocationState: $getNextHazardsByLocationState, subscribeToLocationState: $subscribeToLocationState, unsubscribeFromLocationState: $unsubscribeFromLocationState)';
}


}

/// @nodoc
abstract mixin class _$MainSearchProviderStateCopyWith<$Res> implements $MainSearchProviderStateCopyWith<$Res> {
  factory _$MainSearchProviderStateCopyWith(_MainSearchProviderState value, $Res Function(_MainSearchProviderState) _then) = __$MainSearchProviderStateCopyWithImpl;
@override @useResult
$Res call({
 AlrtLocation? searchedLocation, List<Hazard> hazards, int currentPage, String? subscriptionId, GetHazardsByLocationState getHazardsByLocationState, GetHazardsByLocationState getNextHazardsByLocationState, SubscribeToLocationState subscribeToLocationState, UnsubscribeFromLocationState unsubscribeFromLocationState
});


@override $AlrtLocationCopyWith<$Res>? get searchedLocation;@override $GetHazardsByLocationStateCopyWith<$Res> get getHazardsByLocationState;@override $GetHazardsByLocationStateCopyWith<$Res> get getNextHazardsByLocationState;@override $SubscribeToLocationStateCopyWith<$Res> get subscribeToLocationState;@override $UnsubscribeFromLocationStateCopyWith<$Res> get unsubscribeFromLocationState;

}
/// @nodoc
class __$MainSearchProviderStateCopyWithImpl<$Res>
    implements _$MainSearchProviderStateCopyWith<$Res> {
  __$MainSearchProviderStateCopyWithImpl(this._self, this._then);

  final _MainSearchProviderState _self;
  final $Res Function(_MainSearchProviderState) _then;

/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchedLocation = freezed,Object? hazards = null,Object? currentPage = null,Object? subscriptionId = freezed,Object? getHazardsByLocationState = null,Object? getNextHazardsByLocationState = null,Object? subscribeToLocationState = null,Object? unsubscribeFromLocationState = null,}) {
  return _then(_MainSearchProviderState(
searchedLocation: freezed == searchedLocation ? _self.searchedLocation : searchedLocation // ignore: cast_nullable_to_non_nullable
as AlrtLocation?,hazards: null == hazards ? _self._hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,getHazardsByLocationState: null == getHazardsByLocationState ? _self.getHazardsByLocationState : getHazardsByLocationState // ignore: cast_nullable_to_non_nullable
as GetHazardsByLocationState,getNextHazardsByLocationState: null == getNextHazardsByLocationState ? _self.getNextHazardsByLocationState : getNextHazardsByLocationState // ignore: cast_nullable_to_non_nullable
as GetHazardsByLocationState,subscribeToLocationState: null == subscribeToLocationState ? _self.subscribeToLocationState : subscribeToLocationState // ignore: cast_nullable_to_non_nullable
as SubscribeToLocationState,unsubscribeFromLocationState: null == unsubscribeFromLocationState ? _self.unsubscribeFromLocationState : unsubscribeFromLocationState // ignore: cast_nullable_to_non_nullable
as UnsubscribeFromLocationState,
  ));
}

/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlrtLocationCopyWith<$Res>? get searchedLocation {
    if (_self.searchedLocation == null) {
    return null;
  }

  return $AlrtLocationCopyWith<$Res>(_self.searchedLocation!, (value) {
    return _then(_self.copyWith(searchedLocation: value));
  });
}/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetHazardsByLocationStateCopyWith<$Res> get getHazardsByLocationState {
  
  return $GetHazardsByLocationStateCopyWith<$Res>(_self.getHazardsByLocationState, (value) {
    return _then(_self.copyWith(getHazardsByLocationState: value));
  });
}/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetHazardsByLocationStateCopyWith<$Res> get getNextHazardsByLocationState {
  
  return $GetHazardsByLocationStateCopyWith<$Res>(_self.getNextHazardsByLocationState, (value) {
    return _then(_self.copyWith(getNextHazardsByLocationState: value));
  });
}/// Create a copy of MainSearchProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscribeToLocationStateCopyWith<$Res> get subscribeToLocationState {
  
  return $SubscribeToLocationStateCopyWith<$Res>(_self.subscribeToLocationState, (value) {
    return _then(_self.copyWith(subscribeToLocationState: value));
  });
}/// Create a copy of MainSearchProviderState
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
mixin _$GetHazardsByLocationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetHazardsByLocationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetHazardsByLocationState()';
}


}

/// @nodoc
class $GetHazardsByLocationStateCopyWith<$Res>  {
$GetHazardsByLocationStateCopyWith(GetHazardsByLocationState _, $Res Function(GetHazardsByLocationState) __);
}


/// Adds pattern-matching-related methods to [GetHazardsByLocationState].
extension GetHazardsByLocationStatePatterns on GetHazardsByLocationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetHazardsByLocationStateInitial value)?  initial,TResult Function( _GetHazardsByLocationStateLoading value)?  loading,TResult Function( _GetHazardsByLocationStateSuccess value)?  success,TResult Function( _GetHazardsByLocationStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetHazardsByLocationStateInitial() when initial != null:
return initial(_that);case _GetHazardsByLocationStateLoading() when loading != null:
return loading(_that);case _GetHazardsByLocationStateSuccess() when success != null:
return success(_that);case _GetHazardsByLocationStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetHazardsByLocationStateInitial value)  initial,required TResult Function( _GetHazardsByLocationStateLoading value)  loading,required TResult Function( _GetHazardsByLocationStateSuccess value)  success,required TResult Function( _GetHazardsByLocationStateError value)  error,}){
final _that = this;
switch (_that) {
case _GetHazardsByLocationStateInitial():
return initial(_that);case _GetHazardsByLocationStateLoading():
return loading(_that);case _GetHazardsByLocationStateSuccess():
return success(_that);case _GetHazardsByLocationStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetHazardsByLocationStateInitial value)?  initial,TResult? Function( _GetHazardsByLocationStateLoading value)?  loading,TResult? Function( _GetHazardsByLocationStateSuccess value)?  success,TResult? Function( _GetHazardsByLocationStateError value)?  error,}){
final _that = this;
switch (_that) {
case _GetHazardsByLocationStateInitial() when initial != null:
return initial(_that);case _GetHazardsByLocationStateLoading() when loading != null:
return loading(_that);case _GetHazardsByLocationStateSuccess() when success != null:
return success(_that);case _GetHazardsByLocationStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Hazard> hazards)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetHazardsByLocationStateInitial() when initial != null:
return initial();case _GetHazardsByLocationStateLoading() when loading != null:
return loading();case _GetHazardsByLocationStateSuccess() when success != null:
return success(_that.hazards);case _GetHazardsByLocationStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Hazard> hazards)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _GetHazardsByLocationStateInitial():
return initial();case _GetHazardsByLocationStateLoading():
return loading();case _GetHazardsByLocationStateSuccess():
return success(_that.hazards);case _GetHazardsByLocationStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Hazard> hazards)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _GetHazardsByLocationStateInitial() when initial != null:
return initial();case _GetHazardsByLocationStateLoading() when loading != null:
return loading();case _GetHazardsByLocationStateSuccess() when success != null:
return success(_that.hazards);case _GetHazardsByLocationStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetHazardsByLocationStateInitial implements GetHazardsByLocationState {
  const _GetHazardsByLocationStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetHazardsByLocationStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetHazardsByLocationState.initial()';
}


}




/// @nodoc


class _GetHazardsByLocationStateLoading implements GetHazardsByLocationState {
  const _GetHazardsByLocationStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetHazardsByLocationStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetHazardsByLocationState.loading()';
}


}




/// @nodoc


class _GetHazardsByLocationStateSuccess implements GetHazardsByLocationState {
  const _GetHazardsByLocationStateSuccess(final  List<Hazard> hazards): _hazards = hazards;
  

 final  List<Hazard> _hazards;
 List<Hazard> get hazards {
  if (_hazards is EqualUnmodifiableListView) return _hazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazards);
}


/// Create a copy of GetHazardsByLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetHazardsByLocationStateSuccessCopyWith<_GetHazardsByLocationStateSuccess> get copyWith => __$GetHazardsByLocationStateSuccessCopyWithImpl<_GetHazardsByLocationStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetHazardsByLocationStateSuccess&&const DeepCollectionEquality().equals(other._hazards, _hazards));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_hazards));

@override
String toString() {
  return 'GetHazardsByLocationState.success(hazards: $hazards)';
}


}

/// @nodoc
abstract mixin class _$GetHazardsByLocationStateSuccessCopyWith<$Res> implements $GetHazardsByLocationStateCopyWith<$Res> {
  factory _$GetHazardsByLocationStateSuccessCopyWith(_GetHazardsByLocationStateSuccess value, $Res Function(_GetHazardsByLocationStateSuccess) _then) = __$GetHazardsByLocationStateSuccessCopyWithImpl;
@useResult
$Res call({
 List<Hazard> hazards
});




}
/// @nodoc
class __$GetHazardsByLocationStateSuccessCopyWithImpl<$Res>
    implements _$GetHazardsByLocationStateSuccessCopyWith<$Res> {
  __$GetHazardsByLocationStateSuccessCopyWithImpl(this._self, this._then);

  final _GetHazardsByLocationStateSuccess _self;
  final $Res Function(_GetHazardsByLocationStateSuccess) _then;

/// Create a copy of GetHazardsByLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hazards = null,}) {
  return _then(_GetHazardsByLocationStateSuccess(
null == hazards ? _self._hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,
  ));
}


}

/// @nodoc


class _GetHazardsByLocationStateError implements GetHazardsByLocationState {
  const _GetHazardsByLocationStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetHazardsByLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetHazardsByLocationStateErrorCopyWith<_GetHazardsByLocationStateError> get copyWith => __$GetHazardsByLocationStateErrorCopyWithImpl<_GetHazardsByLocationStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetHazardsByLocationStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetHazardsByLocationState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetHazardsByLocationStateErrorCopyWith<$Res> implements $GetHazardsByLocationStateCopyWith<$Res> {
  factory _$GetHazardsByLocationStateErrorCopyWith(_GetHazardsByLocationStateError value, $Res Function(_GetHazardsByLocationStateError) _then) = __$GetHazardsByLocationStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GetHazardsByLocationStateErrorCopyWithImpl<$Res>
    implements _$GetHazardsByLocationStateErrorCopyWith<$Res> {
  __$GetHazardsByLocationStateErrorCopyWithImpl(this._self, this._then);

  final _GetHazardsByLocationStateError _self;
  final $Res Function(_GetHazardsByLocationStateError) _then;

/// Create a copy of GetHazardsByLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GetHazardsByLocationStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetHazardsByLocationState
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SubscribeToLocationStateInitial value)?  initial,TResult Function( _SubscribeToLocationStateLoading value)?  loading,TResult Function( _SubscribeToLocationStateSuccess value)?  success,TResult Function( _SubscribeToLocationStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscribeToLocationStateInitial() when initial != null:
return initial(_that);case _SubscribeToLocationStateLoading() when loading != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SubscribeToLocationStateInitial value)  initial,required TResult Function( _SubscribeToLocationStateLoading value)  loading,required TResult Function( _SubscribeToLocationStateSuccess value)  success,required TResult Function( _SubscribeToLocationStateError value)  error,}){
final _that = this;
switch (_that) {
case _SubscribeToLocationStateInitial():
return initial(_that);case _SubscribeToLocationStateLoading():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SubscribeToLocationStateInitial value)?  initial,TResult? Function( _SubscribeToLocationStateLoading value)?  loading,TResult? Function( _SubscribeToLocationStateSuccess value)?  success,TResult? Function( _SubscribeToLocationStateError value)?  error,}){
final _that = this;
switch (_that) {
case _SubscribeToLocationStateInitial() when initial != null:
return initial(_that);case _SubscribeToLocationStateLoading() when loading != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( LocationSubscription subscription)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscribeToLocationStateInitial() when initial != null:
return initial();case _SubscribeToLocationStateLoading() when loading != null:
return loading();case _SubscribeToLocationStateSuccess() when success != null:
return success(_that.subscription);case _SubscribeToLocationStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( LocationSubscription subscription)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _SubscribeToLocationStateInitial():
return initial();case _SubscribeToLocationStateLoading():
return loading();case _SubscribeToLocationStateSuccess():
return success(_that.subscription);case _SubscribeToLocationStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( LocationSubscription subscription)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _SubscribeToLocationStateInitial() when initial != null:
return initial();case _SubscribeToLocationStateLoading() when loading != null:
return loading();case _SubscribeToLocationStateSuccess() when success != null:
return success(_that.subscription);case _SubscribeToLocationStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _SubscribeToLocationStateInitial implements SubscribeToLocationState {
  const _SubscribeToLocationStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscribeToLocationStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscribeToLocationState.initial()';
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
  const _SubscribeToLocationStateSuccess(this.subscription);
  

 final  LocationSubscription subscription;

/// Create a copy of SubscribeToLocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscribeToLocationStateSuccessCopyWith<_SubscribeToLocationStateSuccess> get copyWith => __$SubscribeToLocationStateSuccessCopyWithImpl<_SubscribeToLocationStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscribeToLocationStateSuccess&&(identical(other.subscription, subscription) || other.subscription == subscription));
}


@override
int get hashCode => Object.hash(runtimeType,subscription);

@override
String toString() {
  return 'SubscribeToLocationState.success(subscription: $subscription)';
}


}

/// @nodoc
abstract mixin class _$SubscribeToLocationStateSuccessCopyWith<$Res> implements $SubscribeToLocationStateCopyWith<$Res> {
  factory _$SubscribeToLocationStateSuccessCopyWith(_SubscribeToLocationStateSuccess value, $Res Function(_SubscribeToLocationStateSuccess) _then) = __$SubscribeToLocationStateSuccessCopyWithImpl;
@useResult
$Res call({
 LocationSubscription subscription
});


$LocationSubscriptionCopyWith<$Res> get subscription;

}
/// @nodoc
class __$SubscribeToLocationStateSuccessCopyWithImpl<$Res>
    implements _$SubscribeToLocationStateSuccessCopyWith<$Res> {
  __$SubscribeToLocationStateSuccessCopyWithImpl(this._self, this._then);

  final _SubscribeToLocationStateSuccess _self;
  final $Res Function(_SubscribeToLocationStateSuccess) _then;

/// Create a copy of SubscribeToLocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? subscription = null,}) {
  return _then(_SubscribeToLocationStateSuccess(
null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as LocationSubscription,
  ));
}

/// Create a copy of SubscribeToLocationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationSubscriptionCopyWith<$Res> get subscription {
  
  return $LocationSubscriptionCopyWith<$Res>(_self.subscription, (value) {
    return _then(_self.copyWith(subscription: value));
  });
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _UnsubscribeFromLocationStateInitial value)?  initial,TResult Function( _UnsubscribeFromLocationStateLoading value)?  loading,TResult Function( _UnsubscribeFromLocationStateSuccess value)?  success,TResult Function( _UnsubscribeFromLocationStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateInitial() when initial != null:
return initial(_that);case _UnsubscribeFromLocationStateLoading() when loading != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _UnsubscribeFromLocationStateInitial value)  initial,required TResult Function( _UnsubscribeFromLocationStateLoading value)  loading,required TResult Function( _UnsubscribeFromLocationStateSuccess value)  success,required TResult Function( _UnsubscribeFromLocationStateError value)  error,}){
final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateInitial():
return initial(_that);case _UnsubscribeFromLocationStateLoading():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _UnsubscribeFromLocationStateInitial value)?  initial,TResult? Function( _UnsubscribeFromLocationStateLoading value)?  loading,TResult? Function( _UnsubscribeFromLocationStateSuccess value)?  success,TResult? Function( _UnsubscribeFromLocationStateError value)?  error,}){
final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateInitial() when initial != null:
return initial(_that);case _UnsubscribeFromLocationStateLoading() when loading != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateInitial() when initial != null:
return initial();case _UnsubscribeFromLocationStateLoading() when loading != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateInitial():
return initial();case _UnsubscribeFromLocationStateLoading():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _UnsubscribeFromLocationStateInitial() when initial != null:
return initial();case _UnsubscribeFromLocationStateLoading() when loading != null:
return loading();case _UnsubscribeFromLocationStateSuccess() when success != null:
return success();case _UnsubscribeFromLocationStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _UnsubscribeFromLocationStateInitial implements UnsubscribeFromLocationState {
  const _UnsubscribeFromLocationStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnsubscribeFromLocationStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UnsubscribeFromLocationState.initial()';
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

// dart format on
