// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'places_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlacesProviderState {

/// The search string used to fetch places.
 String get searchString;/// The places fetched from the map service after a successful fetch.
 List<GooglePlace> get places;/// The state of fetching places.
 GetPlacesState get getPlacesState;
/// Create a copy of PlacesProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlacesProviderStateCopyWith<PlacesProviderState> get copyWith => _$PlacesProviderStateCopyWithImpl<PlacesProviderState>(this as PlacesProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlacesProviderState&&(identical(other.searchString, searchString) || other.searchString == searchString)&&const DeepCollectionEquality().equals(other.places, places)&&(identical(other.getPlacesState, getPlacesState) || other.getPlacesState == getPlacesState));
}


@override
int get hashCode => Object.hash(runtimeType,searchString,const DeepCollectionEquality().hash(places),getPlacesState);

@override
String toString() {
  return 'PlacesProviderState(searchString: $searchString, places: $places, getPlacesState: $getPlacesState)';
}


}

/// @nodoc
abstract mixin class $PlacesProviderStateCopyWith<$Res>  {
  factory $PlacesProviderStateCopyWith(PlacesProviderState value, $Res Function(PlacesProviderState) _then) = _$PlacesProviderStateCopyWithImpl;
@useResult
$Res call({
 String searchString, List<GooglePlace> places, GetPlacesState getPlacesState
});


$GetPlacesStateCopyWith<$Res> get getPlacesState;

}
/// @nodoc
class _$PlacesProviderStateCopyWithImpl<$Res>
    implements $PlacesProviderStateCopyWith<$Res> {
  _$PlacesProviderStateCopyWithImpl(this._self, this._then);

  final PlacesProviderState _self;
  final $Res Function(PlacesProviderState) _then;

/// Create a copy of PlacesProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchString = null,Object? places = null,Object? getPlacesState = null,}) {
  return _then(_self.copyWith(
searchString: null == searchString ? _self.searchString : searchString // ignore: cast_nullable_to_non_nullable
as String,places: null == places ? _self.places : places // ignore: cast_nullable_to_non_nullable
as List<GooglePlace>,getPlacesState: null == getPlacesState ? _self.getPlacesState : getPlacesState // ignore: cast_nullable_to_non_nullable
as GetPlacesState,
  ));
}
/// Create a copy of PlacesProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetPlacesStateCopyWith<$Res> get getPlacesState {
  
  return $GetPlacesStateCopyWith<$Res>(_self.getPlacesState, (value) {
    return _then(_self.copyWith(getPlacesState: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlacesProviderState].
extension PlacesProviderStatePatterns on PlacesProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlacesProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlacesProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlacesProviderState value)  $default,){
final _that = this;
switch (_that) {
case _PlacesProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlacesProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _PlacesProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchString,  List<GooglePlace> places,  GetPlacesState getPlacesState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlacesProviderState() when $default != null:
return $default(_that.searchString,_that.places,_that.getPlacesState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchString,  List<GooglePlace> places,  GetPlacesState getPlacesState)  $default,) {final _that = this;
switch (_that) {
case _PlacesProviderState():
return $default(_that.searchString,_that.places,_that.getPlacesState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchString,  List<GooglePlace> places,  GetPlacesState getPlacesState)?  $default,) {final _that = this;
switch (_that) {
case _PlacesProviderState() when $default != null:
return $default(_that.searchString,_that.places,_that.getPlacesState);case _:
  return null;

}
}

}

/// @nodoc


class _PlacesProviderState implements PlacesProviderState {
  const _PlacesProviderState({this.searchString = '', final  List<GooglePlace> places = const <GooglePlace>[], this.getPlacesState = const GetPlacesState.initial()}): _places = places;
  

/// The search string used to fetch places.
@override@JsonKey() final  String searchString;
/// The places fetched from the map service after a successful fetch.
 final  List<GooglePlace> _places;
/// The places fetched from the map service after a successful fetch.
@override@JsonKey() List<GooglePlace> get places {
  if (_places is EqualUnmodifiableListView) return _places;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_places);
}

/// The state of fetching places.
@override@JsonKey() final  GetPlacesState getPlacesState;

/// Create a copy of PlacesProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlacesProviderStateCopyWith<_PlacesProviderState> get copyWith => __$PlacesProviderStateCopyWithImpl<_PlacesProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlacesProviderState&&(identical(other.searchString, searchString) || other.searchString == searchString)&&const DeepCollectionEquality().equals(other._places, _places)&&(identical(other.getPlacesState, getPlacesState) || other.getPlacesState == getPlacesState));
}


@override
int get hashCode => Object.hash(runtimeType,searchString,const DeepCollectionEquality().hash(_places),getPlacesState);

@override
String toString() {
  return 'PlacesProviderState(searchString: $searchString, places: $places, getPlacesState: $getPlacesState)';
}


}

/// @nodoc
abstract mixin class _$PlacesProviderStateCopyWith<$Res> implements $PlacesProviderStateCopyWith<$Res> {
  factory _$PlacesProviderStateCopyWith(_PlacesProviderState value, $Res Function(_PlacesProviderState) _then) = __$PlacesProviderStateCopyWithImpl;
@override @useResult
$Res call({
 String searchString, List<GooglePlace> places, GetPlacesState getPlacesState
});


@override $GetPlacesStateCopyWith<$Res> get getPlacesState;

}
/// @nodoc
class __$PlacesProviderStateCopyWithImpl<$Res>
    implements _$PlacesProviderStateCopyWith<$Res> {
  __$PlacesProviderStateCopyWithImpl(this._self, this._then);

  final _PlacesProviderState _self;
  final $Res Function(_PlacesProviderState) _then;

/// Create a copy of PlacesProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchString = null,Object? places = null,Object? getPlacesState = null,}) {
  return _then(_PlacesProviderState(
searchString: null == searchString ? _self.searchString : searchString // ignore: cast_nullable_to_non_nullable
as String,places: null == places ? _self._places : places // ignore: cast_nullable_to_non_nullable
as List<GooglePlace>,getPlacesState: null == getPlacesState ? _self.getPlacesState : getPlacesState // ignore: cast_nullable_to_non_nullable
as GetPlacesState,
  ));
}

/// Create a copy of PlacesProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetPlacesStateCopyWith<$Res> get getPlacesState {
  
  return $GetPlacesStateCopyWith<$Res>(_self.getPlacesState, (value) {
    return _then(_self.copyWith(getPlacesState: value));
  });
}
}

/// @nodoc
mixin _$GetPlacesState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetPlacesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetPlacesState()';
}


}

/// @nodoc
class $GetPlacesStateCopyWith<$Res>  {
$GetPlacesStateCopyWith(GetPlacesState _, $Res Function(GetPlacesState) __);
}


/// Adds pattern-matching-related methods to [GetPlacesState].
extension GetPlacesStatePatterns on GetPlacesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetPlacesStateInitial value)?  initial,TResult Function( _GetPlacesStateLoading value)?  loading,TResult Function( _GetPlacesStateSuccess value)?  success,TResult Function( _GetPlacesStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetPlacesStateInitial() when initial != null:
return initial(_that);case _GetPlacesStateLoading() when loading != null:
return loading(_that);case _GetPlacesStateSuccess() when success != null:
return success(_that);case _GetPlacesStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetPlacesStateInitial value)  initial,required TResult Function( _GetPlacesStateLoading value)  loading,required TResult Function( _GetPlacesStateSuccess value)  success,required TResult Function( _GetPlacesStateError value)  error,}){
final _that = this;
switch (_that) {
case _GetPlacesStateInitial():
return initial(_that);case _GetPlacesStateLoading():
return loading(_that);case _GetPlacesStateSuccess():
return success(_that);case _GetPlacesStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetPlacesStateInitial value)?  initial,TResult? Function( _GetPlacesStateLoading value)?  loading,TResult? Function( _GetPlacesStateSuccess value)?  success,TResult? Function( _GetPlacesStateError value)?  error,}){
final _that = this;
switch (_that) {
case _GetPlacesStateInitial() when initial != null:
return initial(_that);case _GetPlacesStateLoading() when loading != null:
return loading(_that);case _GetPlacesStateSuccess() when success != null:
return success(_that);case _GetPlacesStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<GooglePlace> places)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetPlacesStateInitial() when initial != null:
return initial();case _GetPlacesStateLoading() when loading != null:
return loading();case _GetPlacesStateSuccess() when success != null:
return success(_that.places);case _GetPlacesStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<GooglePlace> places)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _GetPlacesStateInitial():
return initial();case _GetPlacesStateLoading():
return loading();case _GetPlacesStateSuccess():
return success(_that.places);case _GetPlacesStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<GooglePlace> places)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _GetPlacesStateInitial() when initial != null:
return initial();case _GetPlacesStateLoading() when loading != null:
return loading();case _GetPlacesStateSuccess() when success != null:
return success(_that.places);case _GetPlacesStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetPlacesStateInitial implements GetPlacesState {
  const _GetPlacesStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetPlacesStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetPlacesState.initial()';
}


}




/// @nodoc


class _GetPlacesStateLoading implements GetPlacesState {
  const _GetPlacesStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetPlacesStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetPlacesState.loading()';
}


}




/// @nodoc


class _GetPlacesStateSuccess implements GetPlacesState {
  const _GetPlacesStateSuccess(final  List<GooglePlace> places): _places = places;
  

 final  List<GooglePlace> _places;
 List<GooglePlace> get places {
  if (_places is EqualUnmodifiableListView) return _places;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_places);
}


/// Create a copy of GetPlacesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetPlacesStateSuccessCopyWith<_GetPlacesStateSuccess> get copyWith => __$GetPlacesStateSuccessCopyWithImpl<_GetPlacesStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetPlacesStateSuccess&&const DeepCollectionEquality().equals(other._places, _places));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_places));

@override
String toString() {
  return 'GetPlacesState.success(places: $places)';
}


}

/// @nodoc
abstract mixin class _$GetPlacesStateSuccessCopyWith<$Res> implements $GetPlacesStateCopyWith<$Res> {
  factory _$GetPlacesStateSuccessCopyWith(_GetPlacesStateSuccess value, $Res Function(_GetPlacesStateSuccess) _then) = __$GetPlacesStateSuccessCopyWithImpl;
@useResult
$Res call({
 List<GooglePlace> places
});




}
/// @nodoc
class __$GetPlacesStateSuccessCopyWithImpl<$Res>
    implements _$GetPlacesStateSuccessCopyWith<$Res> {
  __$GetPlacesStateSuccessCopyWithImpl(this._self, this._then);

  final _GetPlacesStateSuccess _self;
  final $Res Function(_GetPlacesStateSuccess) _then;

/// Create a copy of GetPlacesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? places = null,}) {
  return _then(_GetPlacesStateSuccess(
null == places ? _self._places : places // ignore: cast_nullable_to_non_nullable
as List<GooglePlace>,
  ));
}


}

/// @nodoc


class _GetPlacesStateError implements GetPlacesState {
  const _GetPlacesStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetPlacesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetPlacesStateErrorCopyWith<_GetPlacesStateError> get copyWith => __$GetPlacesStateErrorCopyWithImpl<_GetPlacesStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetPlacesStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetPlacesState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetPlacesStateErrorCopyWith<$Res> implements $GetPlacesStateCopyWith<$Res> {
  factory _$GetPlacesStateErrorCopyWith(_GetPlacesStateError value, $Res Function(_GetPlacesStateError) _then) = __$GetPlacesStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GetPlacesStateErrorCopyWithImpl<$Res>
    implements _$GetPlacesStateErrorCopyWith<$Res> {
  __$GetPlacesStateErrorCopyWithImpl(this._self, this._then);

  final _GetPlacesStateError _self;
  final $Res Function(_GetPlacesStateError) _then;

/// Create a copy of GetPlacesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GetPlacesStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetPlacesState
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
