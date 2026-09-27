// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingProviderState {

/// The selected notification radius during onboarding.
 int? get selectedRadius;/// The selected notification preference during onboarding.
 PushNotificationPreference? get selectedNotificationPreference;/// The state of continuing the onboarding process.
 ContinueOnboarding get continueOnboarding;
/// Create a copy of OnboardingProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingProviderStateCopyWith<OnboardingProviderState> get copyWith => _$OnboardingProviderStateCopyWithImpl<OnboardingProviderState>(this as OnboardingProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingProviderState&&(identical(other.selectedRadius, selectedRadius) || other.selectedRadius == selectedRadius)&&(identical(other.selectedNotificationPreference, selectedNotificationPreference) || other.selectedNotificationPreference == selectedNotificationPreference)&&(identical(other.continueOnboarding, continueOnboarding) || other.continueOnboarding == continueOnboarding));
}


@override
int get hashCode => Object.hash(runtimeType,selectedRadius,selectedNotificationPreference,continueOnboarding);

@override
String toString() {
  return 'OnboardingProviderState(selectedRadius: $selectedRadius, selectedNotificationPreference: $selectedNotificationPreference, continueOnboarding: $continueOnboarding)';
}


}

/// @nodoc
abstract mixin class $OnboardingProviderStateCopyWith<$Res>  {
  factory $OnboardingProviderStateCopyWith(OnboardingProviderState value, $Res Function(OnboardingProviderState) _then) = _$OnboardingProviderStateCopyWithImpl;
@useResult
$Res call({
 int? selectedRadius, PushNotificationPreference? selectedNotificationPreference, ContinueOnboarding continueOnboarding
});


$ContinueOnboardingCopyWith<$Res> get continueOnboarding;

}
/// @nodoc
class _$OnboardingProviderStateCopyWithImpl<$Res>
    implements $OnboardingProviderStateCopyWith<$Res> {
  _$OnboardingProviderStateCopyWithImpl(this._self, this._then);

  final OnboardingProviderState _self;
  final $Res Function(OnboardingProviderState) _then;

/// Create a copy of OnboardingProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedRadius = freezed,Object? selectedNotificationPreference = freezed,Object? continueOnboarding = null,}) {
  return _then(_self.copyWith(
selectedRadius: freezed == selectedRadius ? _self.selectedRadius : selectedRadius // ignore: cast_nullable_to_non_nullable
as int?,selectedNotificationPreference: freezed == selectedNotificationPreference ? _self.selectedNotificationPreference : selectedNotificationPreference // ignore: cast_nullable_to_non_nullable
as PushNotificationPreference?,continueOnboarding: null == continueOnboarding ? _self.continueOnboarding : continueOnboarding // ignore: cast_nullable_to_non_nullable
as ContinueOnboarding,
  ));
}
/// Create a copy of OnboardingProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContinueOnboardingCopyWith<$Res> get continueOnboarding {
  
  return $ContinueOnboardingCopyWith<$Res>(_self.continueOnboarding, (value) {
    return _then(_self.copyWith(continueOnboarding: value));
  });
}
}


/// Adds pattern-matching-related methods to [OnboardingProviderState].
extension OnboardingProviderStatePatterns on OnboardingProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingProviderState value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? selectedRadius,  PushNotificationPreference? selectedNotificationPreference,  ContinueOnboarding continueOnboarding)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingProviderState() when $default != null:
return $default(_that.selectedRadius,_that.selectedNotificationPreference,_that.continueOnboarding);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? selectedRadius,  PushNotificationPreference? selectedNotificationPreference,  ContinueOnboarding continueOnboarding)  $default,) {final _that = this;
switch (_that) {
case _OnboardingProviderState():
return $default(_that.selectedRadius,_that.selectedNotificationPreference,_that.continueOnboarding);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? selectedRadius,  PushNotificationPreference? selectedNotificationPreference,  ContinueOnboarding continueOnboarding)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingProviderState() when $default != null:
return $default(_that.selectedRadius,_that.selectedNotificationPreference,_that.continueOnboarding);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingProviderState implements OnboardingProviderState {
  const _OnboardingProviderState({this.selectedRadius, this.selectedNotificationPreference, this.continueOnboarding = const ContinueOnboarding.initial()});
  

/// The selected notification radius during onboarding.
@override final  int? selectedRadius;
/// The selected notification preference during onboarding.
@override final  PushNotificationPreference? selectedNotificationPreference;
/// The state of continuing the onboarding process.
@override@JsonKey() final  ContinueOnboarding continueOnboarding;

/// Create a copy of OnboardingProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingProviderStateCopyWith<_OnboardingProviderState> get copyWith => __$OnboardingProviderStateCopyWithImpl<_OnboardingProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingProviderState&&(identical(other.selectedRadius, selectedRadius) || other.selectedRadius == selectedRadius)&&(identical(other.selectedNotificationPreference, selectedNotificationPreference) || other.selectedNotificationPreference == selectedNotificationPreference)&&(identical(other.continueOnboarding, continueOnboarding) || other.continueOnboarding == continueOnboarding));
}


@override
int get hashCode => Object.hash(runtimeType,selectedRadius,selectedNotificationPreference,continueOnboarding);

@override
String toString() {
  return 'OnboardingProviderState(selectedRadius: $selectedRadius, selectedNotificationPreference: $selectedNotificationPreference, continueOnboarding: $continueOnboarding)';
}


}

/// @nodoc
abstract mixin class _$OnboardingProviderStateCopyWith<$Res> implements $OnboardingProviderStateCopyWith<$Res> {
  factory _$OnboardingProviderStateCopyWith(_OnboardingProviderState value, $Res Function(_OnboardingProviderState) _then) = __$OnboardingProviderStateCopyWithImpl;
@override @useResult
$Res call({
 int? selectedRadius, PushNotificationPreference? selectedNotificationPreference, ContinueOnboarding continueOnboarding
});


@override $ContinueOnboardingCopyWith<$Res> get continueOnboarding;

}
/// @nodoc
class __$OnboardingProviderStateCopyWithImpl<$Res>
    implements _$OnboardingProviderStateCopyWith<$Res> {
  __$OnboardingProviderStateCopyWithImpl(this._self, this._then);

  final _OnboardingProviderState _self;
  final $Res Function(_OnboardingProviderState) _then;

/// Create a copy of OnboardingProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedRadius = freezed,Object? selectedNotificationPreference = freezed,Object? continueOnboarding = null,}) {
  return _then(_OnboardingProviderState(
selectedRadius: freezed == selectedRadius ? _self.selectedRadius : selectedRadius // ignore: cast_nullable_to_non_nullable
as int?,selectedNotificationPreference: freezed == selectedNotificationPreference ? _self.selectedNotificationPreference : selectedNotificationPreference // ignore: cast_nullable_to_non_nullable
as PushNotificationPreference?,continueOnboarding: null == continueOnboarding ? _self.continueOnboarding : continueOnboarding // ignore: cast_nullable_to_non_nullable
as ContinueOnboarding,
  ));
}

/// Create a copy of OnboardingProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContinueOnboardingCopyWith<$Res> get continueOnboarding {
  
  return $ContinueOnboardingCopyWith<$Res>(_self.continueOnboarding, (value) {
    return _then(_self.copyWith(continueOnboarding: value));
  });
}
}

/// @nodoc
mixin _$ContinueOnboarding {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContinueOnboarding);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContinueOnboarding()';
}


}

/// @nodoc
class $ContinueOnboardingCopyWith<$Res>  {
$ContinueOnboardingCopyWith(ContinueOnboarding _, $Res Function(ContinueOnboarding) __);
}


/// Adds pattern-matching-related methods to [ContinueOnboarding].
extension ContinueOnboardingPatterns on ContinueOnboarding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ContinueOnboardingInitial value)?  initial,TResult Function( _ContinueOnboardingLoading value)?  loading,TResult Function( _ContinueOnboardingSuccess value)?  success,TResult Function( _ContinueOnboardingError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContinueOnboardingInitial() when initial != null:
return initial(_that);case _ContinueOnboardingLoading() when loading != null:
return loading(_that);case _ContinueOnboardingSuccess() when success != null:
return success(_that);case _ContinueOnboardingError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ContinueOnboardingInitial value)  initial,required TResult Function( _ContinueOnboardingLoading value)  loading,required TResult Function( _ContinueOnboardingSuccess value)  success,required TResult Function( _ContinueOnboardingError value)  error,}){
final _that = this;
switch (_that) {
case _ContinueOnboardingInitial():
return initial(_that);case _ContinueOnboardingLoading():
return loading(_that);case _ContinueOnboardingSuccess():
return success(_that);case _ContinueOnboardingError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ContinueOnboardingInitial value)?  initial,TResult? Function( _ContinueOnboardingLoading value)?  loading,TResult? Function( _ContinueOnboardingSuccess value)?  success,TResult? Function( _ContinueOnboardingError value)?  error,}){
final _that = this;
switch (_that) {
case _ContinueOnboardingInitial() when initial != null:
return initial(_that);case _ContinueOnboardingLoading() when loading != null:
return loading(_that);case _ContinueOnboardingSuccess() when success != null:
return success(_that);case _ContinueOnboardingError() when error != null:
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
case _ContinueOnboardingInitial() when initial != null:
return initial();case _ContinueOnboardingLoading() when loading != null:
return loading();case _ContinueOnboardingSuccess() when success != null:
return success();case _ContinueOnboardingError() when error != null:
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
case _ContinueOnboardingInitial():
return initial();case _ContinueOnboardingLoading():
return loading();case _ContinueOnboardingSuccess():
return success();case _ContinueOnboardingError():
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
case _ContinueOnboardingInitial() when initial != null:
return initial();case _ContinueOnboardingLoading() when loading != null:
return loading();case _ContinueOnboardingSuccess() when success != null:
return success();case _ContinueOnboardingError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ContinueOnboardingInitial implements ContinueOnboarding {
  const _ContinueOnboardingInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContinueOnboardingInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContinueOnboarding.initial()';
}


}




/// @nodoc


class _ContinueOnboardingLoading implements ContinueOnboarding {
  const _ContinueOnboardingLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContinueOnboardingLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContinueOnboarding.loading()';
}


}




/// @nodoc


class _ContinueOnboardingSuccess implements ContinueOnboarding {
  const _ContinueOnboardingSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContinueOnboardingSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContinueOnboarding.success()';
}


}




/// @nodoc


class _ContinueOnboardingError implements ContinueOnboarding {
  const _ContinueOnboardingError(this.error);
  

 final  AppError error;

/// Create a copy of ContinueOnboarding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContinueOnboardingErrorCopyWith<_ContinueOnboardingError> get copyWith => __$ContinueOnboardingErrorCopyWithImpl<_ContinueOnboardingError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContinueOnboardingError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ContinueOnboarding.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$ContinueOnboardingErrorCopyWith<$Res> implements $ContinueOnboardingCopyWith<$Res> {
  factory _$ContinueOnboardingErrorCopyWith(_ContinueOnboardingError value, $Res Function(_ContinueOnboardingError) _then) = __$ContinueOnboardingErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$ContinueOnboardingErrorCopyWithImpl<$Res>
    implements _$ContinueOnboardingErrorCopyWith<$Res> {
  __$ContinueOnboardingErrorCopyWithImpl(this._self, this._then);

  final _ContinueOnboardingError _self;
  final $Res Function(_ContinueOnboardingError) _then;

/// Create a copy of ContinueOnboarding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_ContinueOnboardingError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of ContinueOnboarding
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
