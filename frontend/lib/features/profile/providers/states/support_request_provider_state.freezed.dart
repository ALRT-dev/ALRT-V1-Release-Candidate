// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_request_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SupportRequestProviderState {

/// The type of support request.
 SupportRequestType? get requestType;/// The details of the support request.
 String get details;/// Whether the request has been submitted.
 bool get requestSubmitted;/// The state of submitting the support request.
 SubmitSupportRequestState get submitState;
/// Create a copy of SupportRequestProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportRequestProviderStateCopyWith<SupportRequestProviderState> get copyWith => _$SupportRequestProviderStateCopyWithImpl<SupportRequestProviderState>(this as SupportRequestProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportRequestProviderState&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.details, details) || other.details == details)&&(identical(other.requestSubmitted, requestSubmitted) || other.requestSubmitted == requestSubmitted)&&(identical(other.submitState, submitState) || other.submitState == submitState));
}


@override
int get hashCode => Object.hash(runtimeType,requestType,details,requestSubmitted,submitState);

@override
String toString() {
  return 'SupportRequestProviderState(requestType: $requestType, details: $details, requestSubmitted: $requestSubmitted, submitState: $submitState)';
}


}

/// @nodoc
abstract mixin class $SupportRequestProviderStateCopyWith<$Res>  {
  factory $SupportRequestProviderStateCopyWith(SupportRequestProviderState value, $Res Function(SupportRequestProviderState) _then) = _$SupportRequestProviderStateCopyWithImpl;
@useResult
$Res call({
 SupportRequestType? requestType, String details, bool requestSubmitted, SubmitSupportRequestState submitState
});


$SubmitSupportRequestStateCopyWith<$Res> get submitState;

}
/// @nodoc
class _$SupportRequestProviderStateCopyWithImpl<$Res>
    implements $SupportRequestProviderStateCopyWith<$Res> {
  _$SupportRequestProviderStateCopyWithImpl(this._self, this._then);

  final SupportRequestProviderState _self;
  final $Res Function(SupportRequestProviderState) _then;

/// Create a copy of SupportRequestProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestType = freezed,Object? details = null,Object? requestSubmitted = null,Object? submitState = null,}) {
  return _then(_self.copyWith(
requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as SupportRequestType?,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,requestSubmitted: null == requestSubmitted ? _self.requestSubmitted : requestSubmitted // ignore: cast_nullable_to_non_nullable
as bool,submitState: null == submitState ? _self.submitState : submitState // ignore: cast_nullable_to_non_nullable
as SubmitSupportRequestState,
  ));
}
/// Create a copy of SupportRequestProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubmitSupportRequestStateCopyWith<$Res> get submitState {
  
  return $SubmitSupportRequestStateCopyWith<$Res>(_self.submitState, (value) {
    return _then(_self.copyWith(submitState: value));
  });
}
}


/// Adds pattern-matching-related methods to [SupportRequestProviderState].
extension SupportRequestProviderStatePatterns on SupportRequestProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportRequestProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportRequestProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportRequestProviderState value)  $default,){
final _that = this;
switch (_that) {
case _SupportRequestProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportRequestProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _SupportRequestProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SupportRequestType? requestType,  String details,  bool requestSubmitted,  SubmitSupportRequestState submitState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportRequestProviderState() when $default != null:
return $default(_that.requestType,_that.details,_that.requestSubmitted,_that.submitState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SupportRequestType? requestType,  String details,  bool requestSubmitted,  SubmitSupportRequestState submitState)  $default,) {final _that = this;
switch (_that) {
case _SupportRequestProviderState():
return $default(_that.requestType,_that.details,_that.requestSubmitted,_that.submitState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SupportRequestType? requestType,  String details,  bool requestSubmitted,  SubmitSupportRequestState submitState)?  $default,) {final _that = this;
switch (_that) {
case _SupportRequestProviderState() when $default != null:
return $default(_that.requestType,_that.details,_that.requestSubmitted,_that.submitState);case _:
  return null;

}
}

}

/// @nodoc


class _SupportRequestProviderState implements SupportRequestProviderState {
  const _SupportRequestProviderState({this.requestType, this.details = '', this.requestSubmitted = false, this.submitState = const SubmitSupportRequestState.initial()});
  

/// The type of support request.
@override final  SupportRequestType? requestType;
/// The details of the support request.
@override@JsonKey() final  String details;
/// Whether the request has been submitted.
@override@JsonKey() final  bool requestSubmitted;
/// The state of submitting the support request.
@override@JsonKey() final  SubmitSupportRequestState submitState;

/// Create a copy of SupportRequestProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportRequestProviderStateCopyWith<_SupportRequestProviderState> get copyWith => __$SupportRequestProviderStateCopyWithImpl<_SupportRequestProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportRequestProviderState&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.details, details) || other.details == details)&&(identical(other.requestSubmitted, requestSubmitted) || other.requestSubmitted == requestSubmitted)&&(identical(other.submitState, submitState) || other.submitState == submitState));
}


@override
int get hashCode => Object.hash(runtimeType,requestType,details,requestSubmitted,submitState);

@override
String toString() {
  return 'SupportRequestProviderState(requestType: $requestType, details: $details, requestSubmitted: $requestSubmitted, submitState: $submitState)';
}


}

/// @nodoc
abstract mixin class _$SupportRequestProviderStateCopyWith<$Res> implements $SupportRequestProviderStateCopyWith<$Res> {
  factory _$SupportRequestProviderStateCopyWith(_SupportRequestProviderState value, $Res Function(_SupportRequestProviderState) _then) = __$SupportRequestProviderStateCopyWithImpl;
@override @useResult
$Res call({
 SupportRequestType? requestType, String details, bool requestSubmitted, SubmitSupportRequestState submitState
});


@override $SubmitSupportRequestStateCopyWith<$Res> get submitState;

}
/// @nodoc
class __$SupportRequestProviderStateCopyWithImpl<$Res>
    implements _$SupportRequestProviderStateCopyWith<$Res> {
  __$SupportRequestProviderStateCopyWithImpl(this._self, this._then);

  final _SupportRequestProviderState _self;
  final $Res Function(_SupportRequestProviderState) _then;

/// Create a copy of SupportRequestProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestType = freezed,Object? details = null,Object? requestSubmitted = null,Object? submitState = null,}) {
  return _then(_SupportRequestProviderState(
requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as SupportRequestType?,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,requestSubmitted: null == requestSubmitted ? _self.requestSubmitted : requestSubmitted // ignore: cast_nullable_to_non_nullable
as bool,submitState: null == submitState ? _self.submitState : submitState // ignore: cast_nullable_to_non_nullable
as SubmitSupportRequestState,
  ));
}

/// Create a copy of SupportRequestProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubmitSupportRequestStateCopyWith<$Res> get submitState {
  
  return $SubmitSupportRequestStateCopyWith<$Res>(_self.submitState, (value) {
    return _then(_self.copyWith(submitState: value));
  });
}
}

/// @nodoc
mixin _$SubmitSupportRequestState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitSupportRequestState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubmitSupportRequestState()';
}


}

/// @nodoc
class $SubmitSupportRequestStateCopyWith<$Res>  {
$SubmitSupportRequestStateCopyWith(SubmitSupportRequestState _, $Res Function(SubmitSupportRequestState) __);
}


/// Adds pattern-matching-related methods to [SubmitSupportRequestState].
extension SubmitSupportRequestStatePatterns on SubmitSupportRequestState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SubmitSupportRequestStateInitial value)?  initial,TResult Function( _SubmitSupportRequestStateLoading value)?  loading,TResult Function( _SubmitSupportRequestStateSuccess value)?  success,TResult Function( _SubmitSupportRequestStateFailure value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmitSupportRequestStateInitial() when initial != null:
return initial(_that);case _SubmitSupportRequestStateLoading() when loading != null:
return loading(_that);case _SubmitSupportRequestStateSuccess() when success != null:
return success(_that);case _SubmitSupportRequestStateFailure() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SubmitSupportRequestStateInitial value)  initial,required TResult Function( _SubmitSupportRequestStateLoading value)  loading,required TResult Function( _SubmitSupportRequestStateSuccess value)  success,required TResult Function( _SubmitSupportRequestStateFailure value)  error,}){
final _that = this;
switch (_that) {
case _SubmitSupportRequestStateInitial():
return initial(_that);case _SubmitSupportRequestStateLoading():
return loading(_that);case _SubmitSupportRequestStateSuccess():
return success(_that);case _SubmitSupportRequestStateFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SubmitSupportRequestStateInitial value)?  initial,TResult? Function( _SubmitSupportRequestStateLoading value)?  loading,TResult? Function( _SubmitSupportRequestStateSuccess value)?  success,TResult? Function( _SubmitSupportRequestStateFailure value)?  error,}){
final _that = this;
switch (_that) {
case _SubmitSupportRequestStateInitial() when initial != null:
return initial(_that);case _SubmitSupportRequestStateLoading() when loading != null:
return loading(_that);case _SubmitSupportRequestStateSuccess() when success != null:
return success(_that);case _SubmitSupportRequestStateFailure() when error != null:
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
case _SubmitSupportRequestStateInitial() when initial != null:
return initial();case _SubmitSupportRequestStateLoading() when loading != null:
return loading();case _SubmitSupportRequestStateSuccess() when success != null:
return success();case _SubmitSupportRequestStateFailure() when error != null:
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
case _SubmitSupportRequestStateInitial():
return initial();case _SubmitSupportRequestStateLoading():
return loading();case _SubmitSupportRequestStateSuccess():
return success();case _SubmitSupportRequestStateFailure():
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
case _SubmitSupportRequestStateInitial() when initial != null:
return initial();case _SubmitSupportRequestStateLoading() when loading != null:
return loading();case _SubmitSupportRequestStateSuccess() when success != null:
return success();case _SubmitSupportRequestStateFailure() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _SubmitSupportRequestStateInitial implements SubmitSupportRequestState {
  const _SubmitSupportRequestStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitSupportRequestStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubmitSupportRequestState.initial()';
}


}




/// @nodoc


class _SubmitSupportRequestStateLoading implements SubmitSupportRequestState {
  const _SubmitSupportRequestStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitSupportRequestStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubmitSupportRequestState.loading()';
}


}




/// @nodoc


class _SubmitSupportRequestStateSuccess implements SubmitSupportRequestState {
  const _SubmitSupportRequestStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitSupportRequestStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubmitSupportRequestState.success()';
}


}




/// @nodoc


class _SubmitSupportRequestStateFailure implements SubmitSupportRequestState {
  const _SubmitSupportRequestStateFailure(this.error);
  

 final  AppError error;

/// Create a copy of SubmitSupportRequestState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmitSupportRequestStateFailureCopyWith<_SubmitSupportRequestStateFailure> get copyWith => __$SubmitSupportRequestStateFailureCopyWithImpl<_SubmitSupportRequestStateFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitSupportRequestStateFailure&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'SubmitSupportRequestState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$SubmitSupportRequestStateFailureCopyWith<$Res> implements $SubmitSupportRequestStateCopyWith<$Res> {
  factory _$SubmitSupportRequestStateFailureCopyWith(_SubmitSupportRequestStateFailure value, $Res Function(_SubmitSupportRequestStateFailure) _then) = __$SubmitSupportRequestStateFailureCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$SubmitSupportRequestStateFailureCopyWithImpl<$Res>
    implements _$SubmitSupportRequestStateFailureCopyWith<$Res> {
  __$SubmitSupportRequestStateFailureCopyWithImpl(this._self, this._then);

  final _SubmitSupportRequestStateFailure _self;
  final $Res Function(_SubmitSupportRequestStateFailure) _then;

/// Create a copy of SubmitSupportRequestState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_SubmitSupportRequestStateFailure(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of SubmitSupportRequestState
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
