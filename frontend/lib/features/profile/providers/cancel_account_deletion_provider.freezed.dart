// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cancel_account_deletion_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CancelAccountDeletionProviderState {

 CancelAccountDeletionState get cancelState;
/// Create a copy of CancelAccountDeletionProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelAccountDeletionProviderStateCopyWith<CancelAccountDeletionProviderState> get copyWith => _$CancelAccountDeletionProviderStateCopyWithImpl<CancelAccountDeletionProviderState>(this as CancelAccountDeletionProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelAccountDeletionProviderState&&(identical(other.cancelState, cancelState) || other.cancelState == cancelState));
}


@override
int get hashCode => Object.hash(runtimeType,cancelState);

@override
String toString() {
  return 'CancelAccountDeletionProviderState(cancelState: $cancelState)';
}


}

/// @nodoc
abstract mixin class $CancelAccountDeletionProviderStateCopyWith<$Res>  {
  factory $CancelAccountDeletionProviderStateCopyWith(CancelAccountDeletionProviderState value, $Res Function(CancelAccountDeletionProviderState) _then) = _$CancelAccountDeletionProviderStateCopyWithImpl;
@useResult
$Res call({
 CancelAccountDeletionState cancelState
});


$CancelAccountDeletionStateCopyWith<$Res> get cancelState;

}
/// @nodoc
class _$CancelAccountDeletionProviderStateCopyWithImpl<$Res>
    implements $CancelAccountDeletionProviderStateCopyWith<$Res> {
  _$CancelAccountDeletionProviderStateCopyWithImpl(this._self, this._then);

  final CancelAccountDeletionProviderState _self;
  final $Res Function(CancelAccountDeletionProviderState) _then;

/// Create a copy of CancelAccountDeletionProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cancelState = null,}) {
  return _then(_self.copyWith(
cancelState: null == cancelState ? _self.cancelState : cancelState // ignore: cast_nullable_to_non_nullable
as CancelAccountDeletionState,
  ));
}
/// Create a copy of CancelAccountDeletionProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CancelAccountDeletionStateCopyWith<$Res> get cancelState {
  
  return $CancelAccountDeletionStateCopyWith<$Res>(_self.cancelState, (value) {
    return _then(_self.copyWith(cancelState: value));
  });
}
}


/// Adds pattern-matching-related methods to [CancelAccountDeletionProviderState].
extension CancelAccountDeletionProviderStatePatterns on CancelAccountDeletionProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CancelAccountDeletionProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CancelAccountDeletionProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CancelAccountDeletionProviderState value)  $default,){
final _that = this;
switch (_that) {
case _CancelAccountDeletionProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CancelAccountDeletionProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _CancelAccountDeletionProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CancelAccountDeletionState cancelState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CancelAccountDeletionProviderState() when $default != null:
return $default(_that.cancelState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CancelAccountDeletionState cancelState)  $default,) {final _that = this;
switch (_that) {
case _CancelAccountDeletionProviderState():
return $default(_that.cancelState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CancelAccountDeletionState cancelState)?  $default,) {final _that = this;
switch (_that) {
case _CancelAccountDeletionProviderState() when $default != null:
return $default(_that.cancelState);case _:
  return null;

}
}

}

/// @nodoc


class _CancelAccountDeletionProviderState implements CancelAccountDeletionProviderState {
  const _CancelAccountDeletionProviderState({this.cancelState = const CancelAccountDeletionState.initial()});
  

@override@JsonKey() final  CancelAccountDeletionState cancelState;

/// Create a copy of CancelAccountDeletionProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelAccountDeletionProviderStateCopyWith<_CancelAccountDeletionProviderState> get copyWith => __$CancelAccountDeletionProviderStateCopyWithImpl<_CancelAccountDeletionProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelAccountDeletionProviderState&&(identical(other.cancelState, cancelState) || other.cancelState == cancelState));
}


@override
int get hashCode => Object.hash(runtimeType,cancelState);

@override
String toString() {
  return 'CancelAccountDeletionProviderState(cancelState: $cancelState)';
}


}

/// @nodoc
abstract mixin class _$CancelAccountDeletionProviderStateCopyWith<$Res> implements $CancelAccountDeletionProviderStateCopyWith<$Res> {
  factory _$CancelAccountDeletionProviderStateCopyWith(_CancelAccountDeletionProviderState value, $Res Function(_CancelAccountDeletionProviderState) _then) = __$CancelAccountDeletionProviderStateCopyWithImpl;
@override @useResult
$Res call({
 CancelAccountDeletionState cancelState
});


@override $CancelAccountDeletionStateCopyWith<$Res> get cancelState;

}
/// @nodoc
class __$CancelAccountDeletionProviderStateCopyWithImpl<$Res>
    implements _$CancelAccountDeletionProviderStateCopyWith<$Res> {
  __$CancelAccountDeletionProviderStateCopyWithImpl(this._self, this._then);

  final _CancelAccountDeletionProviderState _self;
  final $Res Function(_CancelAccountDeletionProviderState) _then;

/// Create a copy of CancelAccountDeletionProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cancelState = null,}) {
  return _then(_CancelAccountDeletionProviderState(
cancelState: null == cancelState ? _self.cancelState : cancelState // ignore: cast_nullable_to_non_nullable
as CancelAccountDeletionState,
  ));
}

/// Create a copy of CancelAccountDeletionProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CancelAccountDeletionStateCopyWith<$Res> get cancelState {
  
  return $CancelAccountDeletionStateCopyWith<$Res>(_self.cancelState, (value) {
    return _then(_self.copyWith(cancelState: value));
  });
}
}

/// @nodoc
mixin _$CancelAccountDeletionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelAccountDeletionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CancelAccountDeletionState()';
}


}

/// @nodoc
class $CancelAccountDeletionStateCopyWith<$Res>  {
$CancelAccountDeletionStateCopyWith(CancelAccountDeletionState _, $Res Function(CancelAccountDeletionState) __);
}


/// Adds pattern-matching-related methods to [CancelAccountDeletionState].
extension CancelAccountDeletionStatePatterns on CancelAccountDeletionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CancelAccountDeletionStateInitial value)?  initial,TResult Function( _CancelAccountDeletionStateLoading value)?  loading,TResult Function( _CancelAccountDeletionStateSuccess value)?  success,TResult Function( _CancelAccountDeletionStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CancelAccountDeletionStateInitial() when initial != null:
return initial(_that);case _CancelAccountDeletionStateLoading() when loading != null:
return loading(_that);case _CancelAccountDeletionStateSuccess() when success != null:
return success(_that);case _CancelAccountDeletionStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CancelAccountDeletionStateInitial value)  initial,required TResult Function( _CancelAccountDeletionStateLoading value)  loading,required TResult Function( _CancelAccountDeletionStateSuccess value)  success,required TResult Function( _CancelAccountDeletionStateError value)  error,}){
final _that = this;
switch (_that) {
case _CancelAccountDeletionStateInitial():
return initial(_that);case _CancelAccountDeletionStateLoading():
return loading(_that);case _CancelAccountDeletionStateSuccess():
return success(_that);case _CancelAccountDeletionStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CancelAccountDeletionStateInitial value)?  initial,TResult? Function( _CancelAccountDeletionStateLoading value)?  loading,TResult? Function( _CancelAccountDeletionStateSuccess value)?  success,TResult? Function( _CancelAccountDeletionStateError value)?  error,}){
final _that = this;
switch (_that) {
case _CancelAccountDeletionStateInitial() when initial != null:
return initial(_that);case _CancelAccountDeletionStateLoading() when loading != null:
return loading(_that);case _CancelAccountDeletionStateSuccess() when success != null:
return success(_that);case _CancelAccountDeletionStateError() when error != null:
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
case _CancelAccountDeletionStateInitial() when initial != null:
return initial();case _CancelAccountDeletionStateLoading() when loading != null:
return loading();case _CancelAccountDeletionStateSuccess() when success != null:
return success();case _CancelAccountDeletionStateError() when error != null:
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
case _CancelAccountDeletionStateInitial():
return initial();case _CancelAccountDeletionStateLoading():
return loading();case _CancelAccountDeletionStateSuccess():
return success();case _CancelAccountDeletionStateError():
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
case _CancelAccountDeletionStateInitial() when initial != null:
return initial();case _CancelAccountDeletionStateLoading() when loading != null:
return loading();case _CancelAccountDeletionStateSuccess() when success != null:
return success();case _CancelAccountDeletionStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CancelAccountDeletionStateInitial implements CancelAccountDeletionState {
  const _CancelAccountDeletionStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelAccountDeletionStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CancelAccountDeletionState.initial()';
}


}




/// @nodoc


class _CancelAccountDeletionStateLoading implements CancelAccountDeletionState {
  const _CancelAccountDeletionStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelAccountDeletionStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CancelAccountDeletionState.loading()';
}


}




/// @nodoc


class _CancelAccountDeletionStateSuccess implements CancelAccountDeletionState {
  const _CancelAccountDeletionStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelAccountDeletionStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CancelAccountDeletionState.success()';
}


}




/// @nodoc


class _CancelAccountDeletionStateError implements CancelAccountDeletionState {
  const _CancelAccountDeletionStateError(this.error);
  

 final  AppError error;

/// Create a copy of CancelAccountDeletionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelAccountDeletionStateErrorCopyWith<_CancelAccountDeletionStateError> get copyWith => __$CancelAccountDeletionStateErrorCopyWithImpl<_CancelAccountDeletionStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelAccountDeletionStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'CancelAccountDeletionState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$CancelAccountDeletionStateErrorCopyWith<$Res> implements $CancelAccountDeletionStateCopyWith<$Res> {
  factory _$CancelAccountDeletionStateErrorCopyWith(_CancelAccountDeletionStateError value, $Res Function(_CancelAccountDeletionStateError) _then) = __$CancelAccountDeletionStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$CancelAccountDeletionStateErrorCopyWithImpl<$Res>
    implements _$CancelAccountDeletionStateErrorCopyWith<$Res> {
  __$CancelAccountDeletionStateErrorCopyWithImpl(this._self, this._then);

  final _CancelAccountDeletionStateError _self;
  final $Res Function(_CancelAccountDeletionStateError) _then;

/// Create a copy of CancelAccountDeletionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_CancelAccountDeletionStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of CancelAccountDeletionState
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
