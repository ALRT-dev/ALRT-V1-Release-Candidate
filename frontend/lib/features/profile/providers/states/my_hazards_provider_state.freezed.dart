// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_hazards_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MyHazardsProviderState {

/// The list of hazards reported by the logged-in user which were accepted.
 List<Hazard> get myAcceptedHazards;/// The list of hazards reported by the logged-in user which were rejected.
 List<Hazard> get myRejectedHazards;/// The state of fetching hazards reported by the logged-in user.
 GetMyHazardsState get getMyAcceptedHazardsState;/// The state of fetching hazards reported by the logged-in user.
 GetMyHazardsState get getMyRejectedHazardsState;
/// Create a copy of MyHazardsProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyHazardsProviderStateCopyWith<MyHazardsProviderState> get copyWith => _$MyHazardsProviderStateCopyWithImpl<MyHazardsProviderState>(this as MyHazardsProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyHazardsProviderState&&const DeepCollectionEquality().equals(other.myAcceptedHazards, myAcceptedHazards)&&const DeepCollectionEquality().equals(other.myRejectedHazards, myRejectedHazards)&&(identical(other.getMyAcceptedHazardsState, getMyAcceptedHazardsState) || other.getMyAcceptedHazardsState == getMyAcceptedHazardsState)&&(identical(other.getMyRejectedHazardsState, getMyRejectedHazardsState) || other.getMyRejectedHazardsState == getMyRejectedHazardsState));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(myAcceptedHazards),const DeepCollectionEquality().hash(myRejectedHazards),getMyAcceptedHazardsState,getMyRejectedHazardsState);

@override
String toString() {
  return 'MyHazardsProviderState(myAcceptedHazards: $myAcceptedHazards, myRejectedHazards: $myRejectedHazards, getMyAcceptedHazardsState: $getMyAcceptedHazardsState, getMyRejectedHazardsState: $getMyRejectedHazardsState)';
}


}

/// @nodoc
abstract mixin class $MyHazardsProviderStateCopyWith<$Res>  {
  factory $MyHazardsProviderStateCopyWith(MyHazardsProviderState value, $Res Function(MyHazardsProviderState) _then) = _$MyHazardsProviderStateCopyWithImpl;
@useResult
$Res call({
 List<Hazard> myAcceptedHazards, List<Hazard> myRejectedHazards, GetMyHazardsState getMyAcceptedHazardsState, GetMyHazardsState getMyRejectedHazardsState
});


$GetMyHazardsStateCopyWith<$Res> get getMyAcceptedHazardsState;$GetMyHazardsStateCopyWith<$Res> get getMyRejectedHazardsState;

}
/// @nodoc
class _$MyHazardsProviderStateCopyWithImpl<$Res>
    implements $MyHazardsProviderStateCopyWith<$Res> {
  _$MyHazardsProviderStateCopyWithImpl(this._self, this._then);

  final MyHazardsProviderState _self;
  final $Res Function(MyHazardsProviderState) _then;

/// Create a copy of MyHazardsProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? myAcceptedHazards = null,Object? myRejectedHazards = null,Object? getMyAcceptedHazardsState = null,Object? getMyRejectedHazardsState = null,}) {
  return _then(_self.copyWith(
myAcceptedHazards: null == myAcceptedHazards ? _self.myAcceptedHazards : myAcceptedHazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,myRejectedHazards: null == myRejectedHazards ? _self.myRejectedHazards : myRejectedHazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,getMyAcceptedHazardsState: null == getMyAcceptedHazardsState ? _self.getMyAcceptedHazardsState : getMyAcceptedHazardsState // ignore: cast_nullable_to_non_nullable
as GetMyHazardsState,getMyRejectedHazardsState: null == getMyRejectedHazardsState ? _self.getMyRejectedHazardsState : getMyRejectedHazardsState // ignore: cast_nullable_to_non_nullable
as GetMyHazardsState,
  ));
}
/// Create a copy of MyHazardsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetMyHazardsStateCopyWith<$Res> get getMyAcceptedHazardsState {
  
  return $GetMyHazardsStateCopyWith<$Res>(_self.getMyAcceptedHazardsState, (value) {
    return _then(_self.copyWith(getMyAcceptedHazardsState: value));
  });
}/// Create a copy of MyHazardsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetMyHazardsStateCopyWith<$Res> get getMyRejectedHazardsState {
  
  return $GetMyHazardsStateCopyWith<$Res>(_self.getMyRejectedHazardsState, (value) {
    return _then(_self.copyWith(getMyRejectedHazardsState: value));
  });
}
}


/// Adds pattern-matching-related methods to [MyHazardsProviderState].
extension MyHazardsProviderStatePatterns on MyHazardsProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyHazardsProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyHazardsProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyHazardsProviderState value)  $default,){
final _that = this;
switch (_that) {
case _MyHazardsProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyHazardsProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _MyHazardsProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Hazard> myAcceptedHazards,  List<Hazard> myRejectedHazards,  GetMyHazardsState getMyAcceptedHazardsState,  GetMyHazardsState getMyRejectedHazardsState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyHazardsProviderState() when $default != null:
return $default(_that.myAcceptedHazards,_that.myRejectedHazards,_that.getMyAcceptedHazardsState,_that.getMyRejectedHazardsState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Hazard> myAcceptedHazards,  List<Hazard> myRejectedHazards,  GetMyHazardsState getMyAcceptedHazardsState,  GetMyHazardsState getMyRejectedHazardsState)  $default,) {final _that = this;
switch (_that) {
case _MyHazardsProviderState():
return $default(_that.myAcceptedHazards,_that.myRejectedHazards,_that.getMyAcceptedHazardsState,_that.getMyRejectedHazardsState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Hazard> myAcceptedHazards,  List<Hazard> myRejectedHazards,  GetMyHazardsState getMyAcceptedHazardsState,  GetMyHazardsState getMyRejectedHazardsState)?  $default,) {final _that = this;
switch (_that) {
case _MyHazardsProviderState() when $default != null:
return $default(_that.myAcceptedHazards,_that.myRejectedHazards,_that.getMyAcceptedHazardsState,_that.getMyRejectedHazardsState);case _:
  return null;

}
}

}

/// @nodoc


class _MyHazardsProviderState implements MyHazardsProviderState {
  const _MyHazardsProviderState({final  List<Hazard> myAcceptedHazards = const <Hazard>[], final  List<Hazard> myRejectedHazards = const <Hazard>[], this.getMyAcceptedHazardsState = const GetMyHazardsState.initial(), this.getMyRejectedHazardsState = const GetMyHazardsState.initial()}): _myAcceptedHazards = myAcceptedHazards,_myRejectedHazards = myRejectedHazards;
  

/// The list of hazards reported by the logged-in user which were accepted.
 final  List<Hazard> _myAcceptedHazards;
/// The list of hazards reported by the logged-in user which were accepted.
@override@JsonKey() List<Hazard> get myAcceptedHazards {
  if (_myAcceptedHazards is EqualUnmodifiableListView) return _myAcceptedHazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_myAcceptedHazards);
}

/// The list of hazards reported by the logged-in user which were rejected.
 final  List<Hazard> _myRejectedHazards;
/// The list of hazards reported by the logged-in user which were rejected.
@override@JsonKey() List<Hazard> get myRejectedHazards {
  if (_myRejectedHazards is EqualUnmodifiableListView) return _myRejectedHazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_myRejectedHazards);
}

/// The state of fetching hazards reported by the logged-in user.
@override@JsonKey() final  GetMyHazardsState getMyAcceptedHazardsState;
/// The state of fetching hazards reported by the logged-in user.
@override@JsonKey() final  GetMyHazardsState getMyRejectedHazardsState;

/// Create a copy of MyHazardsProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyHazardsProviderStateCopyWith<_MyHazardsProviderState> get copyWith => __$MyHazardsProviderStateCopyWithImpl<_MyHazardsProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyHazardsProviderState&&const DeepCollectionEquality().equals(other._myAcceptedHazards, _myAcceptedHazards)&&const DeepCollectionEquality().equals(other._myRejectedHazards, _myRejectedHazards)&&(identical(other.getMyAcceptedHazardsState, getMyAcceptedHazardsState) || other.getMyAcceptedHazardsState == getMyAcceptedHazardsState)&&(identical(other.getMyRejectedHazardsState, getMyRejectedHazardsState) || other.getMyRejectedHazardsState == getMyRejectedHazardsState));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_myAcceptedHazards),const DeepCollectionEquality().hash(_myRejectedHazards),getMyAcceptedHazardsState,getMyRejectedHazardsState);

@override
String toString() {
  return 'MyHazardsProviderState(myAcceptedHazards: $myAcceptedHazards, myRejectedHazards: $myRejectedHazards, getMyAcceptedHazardsState: $getMyAcceptedHazardsState, getMyRejectedHazardsState: $getMyRejectedHazardsState)';
}


}

/// @nodoc
abstract mixin class _$MyHazardsProviderStateCopyWith<$Res> implements $MyHazardsProviderStateCopyWith<$Res> {
  factory _$MyHazardsProviderStateCopyWith(_MyHazardsProviderState value, $Res Function(_MyHazardsProviderState) _then) = __$MyHazardsProviderStateCopyWithImpl;
@override @useResult
$Res call({
 List<Hazard> myAcceptedHazards, List<Hazard> myRejectedHazards, GetMyHazardsState getMyAcceptedHazardsState, GetMyHazardsState getMyRejectedHazardsState
});


@override $GetMyHazardsStateCopyWith<$Res> get getMyAcceptedHazardsState;@override $GetMyHazardsStateCopyWith<$Res> get getMyRejectedHazardsState;

}
/// @nodoc
class __$MyHazardsProviderStateCopyWithImpl<$Res>
    implements _$MyHazardsProviderStateCopyWith<$Res> {
  __$MyHazardsProviderStateCopyWithImpl(this._self, this._then);

  final _MyHazardsProviderState _self;
  final $Res Function(_MyHazardsProviderState) _then;

/// Create a copy of MyHazardsProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? myAcceptedHazards = null,Object? myRejectedHazards = null,Object? getMyAcceptedHazardsState = null,Object? getMyRejectedHazardsState = null,}) {
  return _then(_MyHazardsProviderState(
myAcceptedHazards: null == myAcceptedHazards ? _self._myAcceptedHazards : myAcceptedHazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,myRejectedHazards: null == myRejectedHazards ? _self._myRejectedHazards : myRejectedHazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,getMyAcceptedHazardsState: null == getMyAcceptedHazardsState ? _self.getMyAcceptedHazardsState : getMyAcceptedHazardsState // ignore: cast_nullable_to_non_nullable
as GetMyHazardsState,getMyRejectedHazardsState: null == getMyRejectedHazardsState ? _self.getMyRejectedHazardsState : getMyRejectedHazardsState // ignore: cast_nullable_to_non_nullable
as GetMyHazardsState,
  ));
}

/// Create a copy of MyHazardsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetMyHazardsStateCopyWith<$Res> get getMyAcceptedHazardsState {
  
  return $GetMyHazardsStateCopyWith<$Res>(_self.getMyAcceptedHazardsState, (value) {
    return _then(_self.copyWith(getMyAcceptedHazardsState: value));
  });
}/// Create a copy of MyHazardsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetMyHazardsStateCopyWith<$Res> get getMyRejectedHazardsState {
  
  return $GetMyHazardsStateCopyWith<$Res>(_self.getMyRejectedHazardsState, (value) {
    return _then(_self.copyWith(getMyRejectedHazardsState: value));
  });
}
}

/// @nodoc
mixin _$GetMyHazardsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMyHazardsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetMyHazardsState()';
}


}

/// @nodoc
class $GetMyHazardsStateCopyWith<$Res>  {
$GetMyHazardsStateCopyWith(GetMyHazardsState _, $Res Function(GetMyHazardsState) __);
}


/// Adds pattern-matching-related methods to [GetMyHazardsState].
extension GetMyHazardsStatePatterns on GetMyHazardsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetMyHazardsStateInitial value)?  initial,TResult Function( _GetMyHazardsStateLoading value)?  loading,TResult Function( _GetMyHazardsStateSuccess value)?  success,TResult Function( _GetMyHazardsStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetMyHazardsStateInitial() when initial != null:
return initial(_that);case _GetMyHazardsStateLoading() when loading != null:
return loading(_that);case _GetMyHazardsStateSuccess() when success != null:
return success(_that);case _GetMyHazardsStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetMyHazardsStateInitial value)  initial,required TResult Function( _GetMyHazardsStateLoading value)  loading,required TResult Function( _GetMyHazardsStateSuccess value)  success,required TResult Function( _GetMyHazardsStateError value)  error,}){
final _that = this;
switch (_that) {
case _GetMyHazardsStateInitial():
return initial(_that);case _GetMyHazardsStateLoading():
return loading(_that);case _GetMyHazardsStateSuccess():
return success(_that);case _GetMyHazardsStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetMyHazardsStateInitial value)?  initial,TResult? Function( _GetMyHazardsStateLoading value)?  loading,TResult? Function( _GetMyHazardsStateSuccess value)?  success,TResult? Function( _GetMyHazardsStateError value)?  error,}){
final _that = this;
switch (_that) {
case _GetMyHazardsStateInitial() when initial != null:
return initial(_that);case _GetMyHazardsStateLoading() when loading != null:
return loading(_that);case _GetMyHazardsStateSuccess() when success != null:
return success(_that);case _GetMyHazardsStateError() when error != null:
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
case _GetMyHazardsStateInitial() when initial != null:
return initial();case _GetMyHazardsStateLoading() when loading != null:
return loading();case _GetMyHazardsStateSuccess() when success != null:
return success(_that.hazards);case _GetMyHazardsStateError() when error != null:
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
case _GetMyHazardsStateInitial():
return initial();case _GetMyHazardsStateLoading():
return loading();case _GetMyHazardsStateSuccess():
return success(_that.hazards);case _GetMyHazardsStateError():
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
case _GetMyHazardsStateInitial() when initial != null:
return initial();case _GetMyHazardsStateLoading() when loading != null:
return loading();case _GetMyHazardsStateSuccess() when success != null:
return success(_that.hazards);case _GetMyHazardsStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetMyHazardsStateInitial implements GetMyHazardsState {
  const _GetMyHazardsStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMyHazardsStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetMyHazardsState.initial()';
}


}




/// @nodoc


class _GetMyHazardsStateLoading implements GetMyHazardsState {
  const _GetMyHazardsStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMyHazardsStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetMyHazardsState.loading()';
}


}




/// @nodoc


class _GetMyHazardsStateSuccess implements GetMyHazardsState {
  const _GetMyHazardsStateSuccess(final  List<Hazard> hazards): _hazards = hazards;
  

 final  List<Hazard> _hazards;
 List<Hazard> get hazards {
  if (_hazards is EqualUnmodifiableListView) return _hazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazards);
}


/// Create a copy of GetMyHazardsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetMyHazardsStateSuccessCopyWith<_GetMyHazardsStateSuccess> get copyWith => __$GetMyHazardsStateSuccessCopyWithImpl<_GetMyHazardsStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMyHazardsStateSuccess&&const DeepCollectionEquality().equals(other._hazards, _hazards));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_hazards));

@override
String toString() {
  return 'GetMyHazardsState.success(hazards: $hazards)';
}


}

/// @nodoc
abstract mixin class _$GetMyHazardsStateSuccessCopyWith<$Res> implements $GetMyHazardsStateCopyWith<$Res> {
  factory _$GetMyHazardsStateSuccessCopyWith(_GetMyHazardsStateSuccess value, $Res Function(_GetMyHazardsStateSuccess) _then) = __$GetMyHazardsStateSuccessCopyWithImpl;
@useResult
$Res call({
 List<Hazard> hazards
});




}
/// @nodoc
class __$GetMyHazardsStateSuccessCopyWithImpl<$Res>
    implements _$GetMyHazardsStateSuccessCopyWith<$Res> {
  __$GetMyHazardsStateSuccessCopyWithImpl(this._self, this._then);

  final _GetMyHazardsStateSuccess _self;
  final $Res Function(_GetMyHazardsStateSuccess) _then;

/// Create a copy of GetMyHazardsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hazards = null,}) {
  return _then(_GetMyHazardsStateSuccess(
null == hazards ? _self._hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<Hazard>,
  ));
}


}

/// @nodoc


class _GetMyHazardsStateError implements GetMyHazardsState {
  const _GetMyHazardsStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetMyHazardsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetMyHazardsStateErrorCopyWith<_GetMyHazardsStateError> get copyWith => __$GetMyHazardsStateErrorCopyWithImpl<_GetMyHazardsStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMyHazardsStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetMyHazardsState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetMyHazardsStateErrorCopyWith<$Res> implements $GetMyHazardsStateCopyWith<$Res> {
  factory _$GetMyHazardsStateErrorCopyWith(_GetMyHazardsStateError value, $Res Function(_GetMyHazardsStateError) _then) = __$GetMyHazardsStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GetMyHazardsStateErrorCopyWithImpl<$Res>
    implements _$GetMyHazardsStateErrorCopyWith<$Res> {
  __$GetMyHazardsStateErrorCopyWithImpl(this._self, this._then);

  final _GetMyHazardsStateError _self;
  final $Res Function(_GetMyHazardsStateError) _then;

/// Create a copy of GetMyHazardsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GetMyHazardsStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetMyHazardsState
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
