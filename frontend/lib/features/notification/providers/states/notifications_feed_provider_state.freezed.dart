// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifications_feed_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationsFeedProviderState {

/// The search string to filter hazards by their title or description.
 String get searchString;/// The list of hazards in the notifications feed.
 List<Hazard> get hazards;/// The current page of the notifications feed.
 int get currentPage;/// The state of fetching the notifications feed.
 GetNotificationsFeedHazardsState get getNotificationsFeedHazardsState;/// The state of fetching the next page of notifications feed.
 GetNotificationsFeedHazardsState get getNextNotificationsFeedHazardsState;
/// Create a copy of NotificationsFeedProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationsFeedProviderStateCopyWith<NotificationsFeedProviderState> get copyWith => _$NotificationsFeedProviderStateCopyWithImpl<NotificationsFeedProviderState>(this as NotificationsFeedProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationsFeedProviderState&&(identical(other.searchString, searchString) || other.searchString == searchString)&&const DeepCollectionEquality().equals(other.hazards, hazards)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.getNotificationsFeedHazardsState, getNotificationsFeedHazardsState) || other.getNotificationsFeedHazardsState == getNotificationsFeedHazardsState)&&(identical(other.getNextNotificationsFeedHazardsState, getNextNotificationsFeedHazardsState) || other.getNextNotificationsFeedHazardsState == getNextNotificationsFeedHazardsState));
}


@override
int get hashCode => Object.hash(runtimeType,searchString,const DeepCollectionEquality().hash(hazards),currentPage,getNotificationsFeedHazardsState,getNextNotificationsFeedHazardsState);

@override
String toString() {
  return 'NotificationsFeedProviderState(searchString: $searchString, hazards: $hazards, currentPage: $currentPage, getNotificationsFeedHazardsState: $getNotificationsFeedHazardsState, getNextNotificationsFeedHazardsState: $getNextNotificationsFeedHazardsState)';
}


}

/// @nodoc
abstract mixin class $NotificationsFeedProviderStateCopyWith<$Res>  {
  factory $NotificationsFeedProviderStateCopyWith(NotificationsFeedProviderState value, $Res Function(NotificationsFeedProviderState) _then) = _$NotificationsFeedProviderStateCopyWithImpl;
@useResult
$Res call({
 String searchString, List<Hazard> hazards, int currentPage, GetNotificationsFeedHazardsState getNotificationsFeedHazardsState, GetNotificationsFeedHazardsState getNextNotificationsFeedHazardsState
});


$GetNotificationsFeedHazardsStateCopyWith<$Res> get getNotificationsFeedHazardsState;$GetNotificationsFeedHazardsStateCopyWith<$Res> get getNextNotificationsFeedHazardsState;

}
/// @nodoc
class _$NotificationsFeedProviderStateCopyWithImpl<$Res>
    implements $NotificationsFeedProviderStateCopyWith<$Res> {
  _$NotificationsFeedProviderStateCopyWithImpl(this._self, this._then);

  final NotificationsFeedProviderState _self;
  final $Res Function(NotificationsFeedProviderState) _then;

/// Create a copy of NotificationsFeedProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchString = null,Object? hazards = null,Object? currentPage = null,Object? getNotificationsFeedHazardsState = null,Object? getNextNotificationsFeedHazardsState = null,}) {
  return _then(_self.copyWith(
searchString: null == searchString ? _self.searchString : searchString // ignore: cast_nullable_to_non_nullable
as String,hazards: null == hazards ? _self.hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,getNotificationsFeedHazardsState: null == getNotificationsFeedHazardsState ? _self.getNotificationsFeedHazardsState : getNotificationsFeedHazardsState // ignore: cast_nullable_to_non_nullable
as GetNotificationsFeedHazardsState,getNextNotificationsFeedHazardsState: null == getNextNotificationsFeedHazardsState ? _self.getNextNotificationsFeedHazardsState : getNextNotificationsFeedHazardsState // ignore: cast_nullable_to_non_nullable
as GetNotificationsFeedHazardsState,
  ));
}
/// Create a copy of NotificationsFeedProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetNotificationsFeedHazardsStateCopyWith<$Res> get getNotificationsFeedHazardsState {
  
  return $GetNotificationsFeedHazardsStateCopyWith<$Res>(_self.getNotificationsFeedHazardsState, (value) {
    return _then(_self.copyWith(getNotificationsFeedHazardsState: value));
  });
}/// Create a copy of NotificationsFeedProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetNotificationsFeedHazardsStateCopyWith<$Res> get getNextNotificationsFeedHazardsState {
  
  return $GetNotificationsFeedHazardsStateCopyWith<$Res>(_self.getNextNotificationsFeedHazardsState, (value) {
    return _then(_self.copyWith(getNextNotificationsFeedHazardsState: value));
  });
}
}


/// Adds pattern-matching-related methods to [NotificationsFeedProviderState].
extension NotificationsFeedProviderStatePatterns on NotificationsFeedProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationsFeedProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationsFeedProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationsFeedProviderState value)  $default,){
final _that = this;
switch (_that) {
case _NotificationsFeedProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationsFeedProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationsFeedProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchString,  List<Hazard> hazards,  int currentPage,  GetNotificationsFeedHazardsState getNotificationsFeedHazardsState,  GetNotificationsFeedHazardsState getNextNotificationsFeedHazardsState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationsFeedProviderState() when $default != null:
return $default(_that.searchString,_that.hazards,_that.currentPage,_that.getNotificationsFeedHazardsState,_that.getNextNotificationsFeedHazardsState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchString,  List<Hazard> hazards,  int currentPage,  GetNotificationsFeedHazardsState getNotificationsFeedHazardsState,  GetNotificationsFeedHazardsState getNextNotificationsFeedHazardsState)  $default,) {final _that = this;
switch (_that) {
case _NotificationsFeedProviderState():
return $default(_that.searchString,_that.hazards,_that.currentPage,_that.getNotificationsFeedHazardsState,_that.getNextNotificationsFeedHazardsState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchString,  List<Hazard> hazards,  int currentPage,  GetNotificationsFeedHazardsState getNotificationsFeedHazardsState,  GetNotificationsFeedHazardsState getNextNotificationsFeedHazardsState)?  $default,) {final _that = this;
switch (_that) {
case _NotificationsFeedProviderState() when $default != null:
return $default(_that.searchString,_that.hazards,_that.currentPage,_that.getNotificationsFeedHazardsState,_that.getNextNotificationsFeedHazardsState);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationsFeedProviderState implements NotificationsFeedProviderState {
  const _NotificationsFeedProviderState({this.searchString = '', final  List<Hazard> hazards = const <Hazard>[], this.currentPage = 1, this.getNotificationsFeedHazardsState = const GetNotificationsFeedHazardsState.initial(), this.getNextNotificationsFeedHazardsState = const GetNotificationsFeedHazardsState.initial()}): _hazards = hazards;
  

/// The search string to filter hazards by their title or description.
@override@JsonKey() final  String searchString;
/// The list of hazards in the notifications feed.
 final  List<Hazard> _hazards;
/// The list of hazards in the notifications feed.
@override@JsonKey() List<Hazard> get hazards {
  if (_hazards is EqualUnmodifiableListView) return _hazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazards);
}

/// The current page of the notifications feed.
@override@JsonKey() final  int currentPage;
/// The state of fetching the notifications feed.
@override@JsonKey() final  GetNotificationsFeedHazardsState getNotificationsFeedHazardsState;
/// The state of fetching the next page of notifications feed.
@override@JsonKey() final  GetNotificationsFeedHazardsState getNextNotificationsFeedHazardsState;

/// Create a copy of NotificationsFeedProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationsFeedProviderStateCopyWith<_NotificationsFeedProviderState> get copyWith => __$NotificationsFeedProviderStateCopyWithImpl<_NotificationsFeedProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationsFeedProviderState&&(identical(other.searchString, searchString) || other.searchString == searchString)&&const DeepCollectionEquality().equals(other._hazards, _hazards)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.getNotificationsFeedHazardsState, getNotificationsFeedHazardsState) || other.getNotificationsFeedHazardsState == getNotificationsFeedHazardsState)&&(identical(other.getNextNotificationsFeedHazardsState, getNextNotificationsFeedHazardsState) || other.getNextNotificationsFeedHazardsState == getNextNotificationsFeedHazardsState));
}


@override
int get hashCode => Object.hash(runtimeType,searchString,const DeepCollectionEquality().hash(_hazards),currentPage,getNotificationsFeedHazardsState,getNextNotificationsFeedHazardsState);

@override
String toString() {
  return 'NotificationsFeedProviderState(searchString: $searchString, hazards: $hazards, currentPage: $currentPage, getNotificationsFeedHazardsState: $getNotificationsFeedHazardsState, getNextNotificationsFeedHazardsState: $getNextNotificationsFeedHazardsState)';
}


}

/// @nodoc
abstract mixin class _$NotificationsFeedProviderStateCopyWith<$Res> implements $NotificationsFeedProviderStateCopyWith<$Res> {
  factory _$NotificationsFeedProviderStateCopyWith(_NotificationsFeedProviderState value, $Res Function(_NotificationsFeedProviderState) _then) = __$NotificationsFeedProviderStateCopyWithImpl;
@override @useResult
$Res call({
 String searchString, List<Hazard> hazards, int currentPage, GetNotificationsFeedHazardsState getNotificationsFeedHazardsState, GetNotificationsFeedHazardsState getNextNotificationsFeedHazardsState
});


@override $GetNotificationsFeedHazardsStateCopyWith<$Res> get getNotificationsFeedHazardsState;@override $GetNotificationsFeedHazardsStateCopyWith<$Res> get getNextNotificationsFeedHazardsState;

}
/// @nodoc
class __$NotificationsFeedProviderStateCopyWithImpl<$Res>
    implements _$NotificationsFeedProviderStateCopyWith<$Res> {
  __$NotificationsFeedProviderStateCopyWithImpl(this._self, this._then);

  final _NotificationsFeedProviderState _self;
  final $Res Function(_NotificationsFeedProviderState) _then;

/// Create a copy of NotificationsFeedProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchString = null,Object? hazards = null,Object? currentPage = null,Object? getNotificationsFeedHazardsState = null,Object? getNextNotificationsFeedHazardsState = null,}) {
  return _then(_NotificationsFeedProviderState(
searchString: null == searchString ? _self.searchString : searchString // ignore: cast_nullable_to_non_nullable
as String,hazards: null == hazards ? _self._hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,getNotificationsFeedHazardsState: null == getNotificationsFeedHazardsState ? _self.getNotificationsFeedHazardsState : getNotificationsFeedHazardsState // ignore: cast_nullable_to_non_nullable
as GetNotificationsFeedHazardsState,getNextNotificationsFeedHazardsState: null == getNextNotificationsFeedHazardsState ? _self.getNextNotificationsFeedHazardsState : getNextNotificationsFeedHazardsState // ignore: cast_nullable_to_non_nullable
as GetNotificationsFeedHazardsState,
  ));
}

/// Create a copy of NotificationsFeedProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetNotificationsFeedHazardsStateCopyWith<$Res> get getNotificationsFeedHazardsState {
  
  return $GetNotificationsFeedHazardsStateCopyWith<$Res>(_self.getNotificationsFeedHazardsState, (value) {
    return _then(_self.copyWith(getNotificationsFeedHazardsState: value));
  });
}/// Create a copy of NotificationsFeedProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetNotificationsFeedHazardsStateCopyWith<$Res> get getNextNotificationsFeedHazardsState {
  
  return $GetNotificationsFeedHazardsStateCopyWith<$Res>(_self.getNextNotificationsFeedHazardsState, (value) {
    return _then(_self.copyWith(getNextNotificationsFeedHazardsState: value));
  });
}
}

/// @nodoc
mixin _$GetNotificationsFeedHazardsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetNotificationsFeedHazardsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetNotificationsFeedHazardsState()';
}


}

/// @nodoc
class $GetNotificationsFeedHazardsStateCopyWith<$Res>  {
$GetNotificationsFeedHazardsStateCopyWith(GetNotificationsFeedHazardsState _, $Res Function(GetNotificationsFeedHazardsState) __);
}


/// Adds pattern-matching-related methods to [GetNotificationsFeedHazardsState].
extension GetNotificationsFeedHazardsStatePatterns on GetNotificationsFeedHazardsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetNotificationsFeedHazardsStateInitial value)?  initial,TResult Function( _GetNotificationsFeedHazardsStateLoading value)?  loading,TResult Function( _GetNotificationsFeedHazardsStateSuccess value)?  success,TResult Function( _GetNotificationsFeedHazardsStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetNotificationsFeedHazardsStateInitial() when initial != null:
return initial(_that);case _GetNotificationsFeedHazardsStateLoading() when loading != null:
return loading(_that);case _GetNotificationsFeedHazardsStateSuccess() when success != null:
return success(_that);case _GetNotificationsFeedHazardsStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetNotificationsFeedHazardsStateInitial value)  initial,required TResult Function( _GetNotificationsFeedHazardsStateLoading value)  loading,required TResult Function( _GetNotificationsFeedHazardsStateSuccess value)  success,required TResult Function( _GetNotificationsFeedHazardsStateError value)  error,}){
final _that = this;
switch (_that) {
case _GetNotificationsFeedHazardsStateInitial():
return initial(_that);case _GetNotificationsFeedHazardsStateLoading():
return loading(_that);case _GetNotificationsFeedHazardsStateSuccess():
return success(_that);case _GetNotificationsFeedHazardsStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetNotificationsFeedHazardsStateInitial value)?  initial,TResult? Function( _GetNotificationsFeedHazardsStateLoading value)?  loading,TResult? Function( _GetNotificationsFeedHazardsStateSuccess value)?  success,TResult? Function( _GetNotificationsFeedHazardsStateError value)?  error,}){
final _that = this;
switch (_that) {
case _GetNotificationsFeedHazardsStateInitial() when initial != null:
return initial(_that);case _GetNotificationsFeedHazardsStateLoading() when loading != null:
return loading(_that);case _GetNotificationsFeedHazardsStateSuccess() when success != null:
return success(_that);case _GetNotificationsFeedHazardsStateError() when error != null:
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
case _GetNotificationsFeedHazardsStateInitial() when initial != null:
return initial();case _GetNotificationsFeedHazardsStateLoading() when loading != null:
return loading();case _GetNotificationsFeedHazardsStateSuccess() when success != null:
return success(_that.hazards);case _GetNotificationsFeedHazardsStateError() when error != null:
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
case _GetNotificationsFeedHazardsStateInitial():
return initial();case _GetNotificationsFeedHazardsStateLoading():
return loading();case _GetNotificationsFeedHazardsStateSuccess():
return success(_that.hazards);case _GetNotificationsFeedHazardsStateError():
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
case _GetNotificationsFeedHazardsStateInitial() when initial != null:
return initial();case _GetNotificationsFeedHazardsStateLoading() when loading != null:
return loading();case _GetNotificationsFeedHazardsStateSuccess() when success != null:
return success(_that.hazards);case _GetNotificationsFeedHazardsStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetNotificationsFeedHazardsStateInitial implements GetNotificationsFeedHazardsState {
  const _GetNotificationsFeedHazardsStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetNotificationsFeedHazardsStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetNotificationsFeedHazardsState.initial()';
}


}




/// @nodoc


class _GetNotificationsFeedHazardsStateLoading implements GetNotificationsFeedHazardsState {
  const _GetNotificationsFeedHazardsStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetNotificationsFeedHazardsStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetNotificationsFeedHazardsState.loading()';
}


}




/// @nodoc


class _GetNotificationsFeedHazardsStateSuccess implements GetNotificationsFeedHazardsState {
  const _GetNotificationsFeedHazardsStateSuccess(final  List<Hazard> hazards): _hazards = hazards;
  

 final  List<Hazard> _hazards;
 List<Hazard> get hazards {
  if (_hazards is EqualUnmodifiableListView) return _hazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazards);
}


/// Create a copy of GetNotificationsFeedHazardsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetNotificationsFeedHazardsStateSuccessCopyWith<_GetNotificationsFeedHazardsStateSuccess> get copyWith => __$GetNotificationsFeedHazardsStateSuccessCopyWithImpl<_GetNotificationsFeedHazardsStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetNotificationsFeedHazardsStateSuccess&&const DeepCollectionEquality().equals(other._hazards, _hazards));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_hazards));

@override
String toString() {
  return 'GetNotificationsFeedHazardsState.success(hazards: $hazards)';
}


}

/// @nodoc
abstract mixin class _$GetNotificationsFeedHazardsStateSuccessCopyWith<$Res> implements $GetNotificationsFeedHazardsStateCopyWith<$Res> {
  factory _$GetNotificationsFeedHazardsStateSuccessCopyWith(_GetNotificationsFeedHazardsStateSuccess value, $Res Function(_GetNotificationsFeedHazardsStateSuccess) _then) = __$GetNotificationsFeedHazardsStateSuccessCopyWithImpl;
@useResult
$Res call({
 List<Hazard> hazards
});




}
/// @nodoc
class __$GetNotificationsFeedHazardsStateSuccessCopyWithImpl<$Res>
    implements _$GetNotificationsFeedHazardsStateSuccessCopyWith<$Res> {
  __$GetNotificationsFeedHazardsStateSuccessCopyWithImpl(this._self, this._then);

  final _GetNotificationsFeedHazardsStateSuccess _self;
  final $Res Function(_GetNotificationsFeedHazardsStateSuccess) _then;

/// Create a copy of GetNotificationsFeedHazardsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hazards = null,}) {
  return _then(_GetNotificationsFeedHazardsStateSuccess(
null == hazards ? _self._hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,
  ));
}


}

/// @nodoc


class _GetNotificationsFeedHazardsStateError implements GetNotificationsFeedHazardsState {
  const _GetNotificationsFeedHazardsStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetNotificationsFeedHazardsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetNotificationsFeedHazardsStateErrorCopyWith<_GetNotificationsFeedHazardsStateError> get copyWith => __$GetNotificationsFeedHazardsStateErrorCopyWithImpl<_GetNotificationsFeedHazardsStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetNotificationsFeedHazardsStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetNotificationsFeedHazardsState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetNotificationsFeedHazardsStateErrorCopyWith<$Res> implements $GetNotificationsFeedHazardsStateCopyWith<$Res> {
  factory _$GetNotificationsFeedHazardsStateErrorCopyWith(_GetNotificationsFeedHazardsStateError value, $Res Function(_GetNotificationsFeedHazardsStateError) _then) = __$GetNotificationsFeedHazardsStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GetNotificationsFeedHazardsStateErrorCopyWithImpl<$Res>
    implements _$GetNotificationsFeedHazardsStateErrorCopyWith<$Res> {
  __$GetNotificationsFeedHazardsStateErrorCopyWithImpl(this._self, this._then);

  final _GetNotificationsFeedHazardsStateError _self;
  final $Res Function(_GetNotificationsFeedHazardsStateError) _then;

/// Create a copy of GetNotificationsFeedHazardsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GetNotificationsFeedHazardsStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetNotificationsFeedHazardsState
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
