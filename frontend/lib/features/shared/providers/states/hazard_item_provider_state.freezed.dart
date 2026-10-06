// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hazard_item_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HazardItemProviderState {

/// The hazard item being managed.
 Hazard? get hazard;/// The state of voting on the hazard.
 VoteHazardState get voteState;
/// Create a copy of HazardItemProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HazardItemProviderStateCopyWith<HazardItemProviderState> get copyWith => _$HazardItemProviderStateCopyWithImpl<HazardItemProviderState>(this as HazardItemProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HazardItemProviderState&&(identical(other.hazard, hazard) || other.hazard == hazard)&&(identical(other.voteState, voteState) || other.voteState == voteState));
}


@override
int get hashCode => Object.hash(runtimeType,hazard,voteState);

@override
String toString() {
  return 'HazardItemProviderState(hazard: $hazard, voteState: $voteState)';
}


}

/// @nodoc
abstract mixin class $HazardItemProviderStateCopyWith<$Res>  {
  factory $HazardItemProviderStateCopyWith(HazardItemProviderState value, $Res Function(HazardItemProviderState) _then) = _$HazardItemProviderStateCopyWithImpl;
@useResult
$Res call({
 Hazard? hazard, VoteHazardState voteState
});


$HazardCopyWith<$Res>? get hazard;$VoteHazardStateCopyWith<$Res> get voteState;

}
/// @nodoc
class _$HazardItemProviderStateCopyWithImpl<$Res>
    implements $HazardItemProviderStateCopyWith<$Res> {
  _$HazardItemProviderStateCopyWithImpl(this._self, this._then);

  final HazardItemProviderState _self;
  final $Res Function(HazardItemProviderState) _then;

/// Create a copy of HazardItemProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hazard = freezed,Object? voteState = null,}) {
  return _then(_self.copyWith(
hazard: freezed == hazard ? _self.hazard : hazard // ignore: cast_nullable_to_non_nullable
as Hazard?,voteState: null == voteState ? _self.voteState : voteState // ignore: cast_nullable_to_non_nullable
as VoteHazardState,
  ));
}
/// Create a copy of HazardItemProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HazardCopyWith<$Res>? get hazard {
    if (_self.hazard == null) {
    return null;
  }

  return $HazardCopyWith<$Res>(_self.hazard!, (value) {
    return _then(_self.copyWith(hazard: value));
  });
}/// Create a copy of HazardItemProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoteHazardStateCopyWith<$Res> get voteState {
  
  return $VoteHazardStateCopyWith<$Res>(_self.voteState, (value) {
    return _then(_self.copyWith(voteState: value));
  });
}
}


/// Adds pattern-matching-related methods to [HazardItemProviderState].
extension HazardItemProviderStatePatterns on HazardItemProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HazardItemProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HazardItemProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HazardItemProviderState value)  $default,){
final _that = this;
switch (_that) {
case _HazardItemProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HazardItemProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _HazardItemProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Hazard? hazard,  VoteHazardState voteState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HazardItemProviderState() when $default != null:
return $default(_that.hazard,_that.voteState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Hazard? hazard,  VoteHazardState voteState)  $default,) {final _that = this;
switch (_that) {
case _HazardItemProviderState():
return $default(_that.hazard,_that.voteState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Hazard? hazard,  VoteHazardState voteState)?  $default,) {final _that = this;
switch (_that) {
case _HazardItemProviderState() when $default != null:
return $default(_that.hazard,_that.voteState);case _:
  return null;

}
}

}

/// @nodoc


class _HazardItemProviderState implements HazardItemProviderState {
  const _HazardItemProviderState({this.hazard, this.voteState = const VoteHazardState.initial()});
  

/// The hazard item being managed.
@override final  Hazard? hazard;
/// The state of voting on the hazard.
@override@JsonKey() final  VoteHazardState voteState;

/// Create a copy of HazardItemProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HazardItemProviderStateCopyWith<_HazardItemProviderState> get copyWith => __$HazardItemProviderStateCopyWithImpl<_HazardItemProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HazardItemProviderState&&(identical(other.hazard, hazard) || other.hazard == hazard)&&(identical(other.voteState, voteState) || other.voteState == voteState));
}


@override
int get hashCode => Object.hash(runtimeType,hazard,voteState);

@override
String toString() {
  return 'HazardItemProviderState(hazard: $hazard, voteState: $voteState)';
}


}

/// @nodoc
abstract mixin class _$HazardItemProviderStateCopyWith<$Res> implements $HazardItemProviderStateCopyWith<$Res> {
  factory _$HazardItemProviderStateCopyWith(_HazardItemProviderState value, $Res Function(_HazardItemProviderState) _then) = __$HazardItemProviderStateCopyWithImpl;
@override @useResult
$Res call({
 Hazard? hazard, VoteHazardState voteState
});


@override $HazardCopyWith<$Res>? get hazard;@override $VoteHazardStateCopyWith<$Res> get voteState;

}
/// @nodoc
class __$HazardItemProviderStateCopyWithImpl<$Res>
    implements _$HazardItemProviderStateCopyWith<$Res> {
  __$HazardItemProviderStateCopyWithImpl(this._self, this._then);

  final _HazardItemProviderState _self;
  final $Res Function(_HazardItemProviderState) _then;

/// Create a copy of HazardItemProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hazard = freezed,Object? voteState = null,}) {
  return _then(_HazardItemProviderState(
hazard: freezed == hazard ? _self.hazard : hazard // ignore: cast_nullable_to_non_nullable
as Hazard?,voteState: null == voteState ? _self.voteState : voteState // ignore: cast_nullable_to_non_nullable
as VoteHazardState,
  ));
}

/// Create a copy of HazardItemProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HazardCopyWith<$Res>? get hazard {
    if (_self.hazard == null) {
    return null;
  }

  return $HazardCopyWith<$Res>(_self.hazard!, (value) {
    return _then(_self.copyWith(hazard: value));
  });
}/// Create a copy of HazardItemProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoteHazardStateCopyWith<$Res> get voteState {
  
  return $VoteHazardStateCopyWith<$Res>(_self.voteState, (value) {
    return _then(_self.copyWith(voteState: value));
  });
}
}

/// @nodoc
mixin _$VoteHazardState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteHazardState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VoteHazardState()';
}


}

/// @nodoc
class $VoteHazardStateCopyWith<$Res>  {
$VoteHazardStateCopyWith(VoteHazardState _, $Res Function(VoteHazardState) __);
}


/// Adds pattern-matching-related methods to [VoteHazardState].
extension VoteHazardStatePatterns on VoteHazardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _VoteHazardStateInitial value)?  initial,TResult Function( _VoteHazardStateLoading value)?  loading,TResult Function( _VoteHazardStateSuccess value)?  success,TResult Function( _VoteHazardStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteHazardStateInitial() when initial != null:
return initial(_that);case _VoteHazardStateLoading() when loading != null:
return loading(_that);case _VoteHazardStateSuccess() when success != null:
return success(_that);case _VoteHazardStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _VoteHazardStateInitial value)  initial,required TResult Function( _VoteHazardStateLoading value)  loading,required TResult Function( _VoteHazardStateSuccess value)  success,required TResult Function( _VoteHazardStateError value)  error,}){
final _that = this;
switch (_that) {
case _VoteHazardStateInitial():
return initial(_that);case _VoteHazardStateLoading():
return loading(_that);case _VoteHazardStateSuccess():
return success(_that);case _VoteHazardStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _VoteHazardStateInitial value)?  initial,TResult? Function( _VoteHazardStateLoading value)?  loading,TResult? Function( _VoteHazardStateSuccess value)?  success,TResult? Function( _VoteHazardStateError value)?  error,}){
final _that = this;
switch (_that) {
case _VoteHazardStateInitial() when initial != null:
return initial(_that);case _VoteHazardStateLoading() when loading != null:
return loading(_that);case _VoteHazardStateSuccess() when success != null:
return success(_that);case _VoteHazardStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  success,TResult Function( AppError message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteHazardStateInitial() when initial != null:
return initial();case _VoteHazardStateLoading() when loading != null:
return loading();case _VoteHazardStateSuccess() when success != null:
return success();case _VoteHazardStateError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  success,required TResult Function( AppError message)  error,}) {final _that = this;
switch (_that) {
case _VoteHazardStateInitial():
return initial();case _VoteHazardStateLoading():
return loading();case _VoteHazardStateSuccess():
return success();case _VoteHazardStateError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( AppError message)?  error,}) {final _that = this;
switch (_that) {
case _VoteHazardStateInitial() when initial != null:
return initial();case _VoteHazardStateLoading() when loading != null:
return loading();case _VoteHazardStateSuccess() when success != null:
return success();case _VoteHazardStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _VoteHazardStateInitial implements VoteHazardState {
  const _VoteHazardStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteHazardStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VoteHazardState.initial()';
}


}




/// @nodoc


class _VoteHazardStateLoading implements VoteHazardState {
  const _VoteHazardStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteHazardStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VoteHazardState.loading()';
}


}




/// @nodoc


class _VoteHazardStateSuccess implements VoteHazardState {
  const _VoteHazardStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteHazardStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VoteHazardState.success()';
}


}




/// @nodoc


class _VoteHazardStateError implements VoteHazardState {
  const _VoteHazardStateError(this.message);
  

 final  AppError message;

/// Create a copy of VoteHazardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteHazardStateErrorCopyWith<_VoteHazardStateError> get copyWith => __$VoteHazardStateErrorCopyWithImpl<_VoteHazardStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteHazardStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VoteHazardState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$VoteHazardStateErrorCopyWith<$Res> implements $VoteHazardStateCopyWith<$Res> {
  factory _$VoteHazardStateErrorCopyWith(_VoteHazardStateError value, $Res Function(_VoteHazardStateError) _then) = __$VoteHazardStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError message
});


$AppErrorCopyWith<$Res> get message;

}
/// @nodoc
class __$VoteHazardStateErrorCopyWithImpl<$Res>
    implements _$VoteHazardStateErrorCopyWith<$Res> {
  __$VoteHazardStateErrorCopyWithImpl(this._self, this._then);

  final _VoteHazardStateError _self;
  final $Res Function(_VoteHazardStateError) _then;

/// Create a copy of VoteHazardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_VoteHazardStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of VoteHazardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res> get message {
  
  return $AppErrorCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}

// dart format on
