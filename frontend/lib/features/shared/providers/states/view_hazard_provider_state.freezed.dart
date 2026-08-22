// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_hazard_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ViewHazardProviderState {

/// The hazard being viewed.
 Hazard? get hazard;/// The state of viewing the hazard.
 ViewHazardState get viewHazardState;/// The state of deleting the hazard.
 DeleteHazardState get deleteHazardState;
/// Create a copy of ViewHazardProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewHazardProviderStateCopyWith<ViewHazardProviderState> get copyWith => _$ViewHazardProviderStateCopyWithImpl<ViewHazardProviderState>(this as ViewHazardProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewHazardProviderState&&(identical(other.hazard, hazard) || other.hazard == hazard)&&(identical(other.viewHazardState, viewHazardState) || other.viewHazardState == viewHazardState)&&(identical(other.deleteHazardState, deleteHazardState) || other.deleteHazardState == deleteHazardState));
}


@override
int get hashCode => Object.hash(runtimeType,hazard,viewHazardState,deleteHazardState);

@override
String toString() {
  return 'ViewHazardProviderState(hazard: $hazard, viewHazardState: $viewHazardState, deleteHazardState: $deleteHazardState)';
}


}

/// @nodoc
abstract mixin class $ViewHazardProviderStateCopyWith<$Res>  {
  factory $ViewHazardProviderStateCopyWith(ViewHazardProviderState value, $Res Function(ViewHazardProviderState) _then) = _$ViewHazardProviderStateCopyWithImpl;
@useResult
$Res call({
 Hazard? hazard, ViewHazardState viewHazardState, DeleteHazardState deleteHazardState
});


$HazardCopyWith<$Res>? get hazard;$ViewHazardStateCopyWith<$Res> get viewHazardState;$DeleteHazardStateCopyWith<$Res> get deleteHazardState;

}
/// @nodoc
class _$ViewHazardProviderStateCopyWithImpl<$Res>
    implements $ViewHazardProviderStateCopyWith<$Res> {
  _$ViewHazardProviderStateCopyWithImpl(this._self, this._then);

  final ViewHazardProviderState _self;
  final $Res Function(ViewHazardProviderState) _then;

/// Create a copy of ViewHazardProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hazard = freezed,Object? viewHazardState = null,Object? deleteHazardState = null,}) {
  return _then(_self.copyWith(
hazard: freezed == hazard ? _self.hazard : hazard // ignore: cast_nullable_to_non_nullable
as Hazard?,viewHazardState: null == viewHazardState ? _self.viewHazardState : viewHazardState // ignore: cast_nullable_to_non_nullable
as ViewHazardState,deleteHazardState: null == deleteHazardState ? _self.deleteHazardState : deleteHazardState // ignore: cast_nullable_to_non_nullable
as DeleteHazardState,
  ));
}
/// Create a copy of ViewHazardProviderState
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
}/// Create a copy of ViewHazardProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViewHazardStateCopyWith<$Res> get viewHazardState {
  
  return $ViewHazardStateCopyWith<$Res>(_self.viewHazardState, (value) {
    return _then(_self.copyWith(viewHazardState: value));
  });
}/// Create a copy of ViewHazardProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeleteHazardStateCopyWith<$Res> get deleteHazardState {
  
  return $DeleteHazardStateCopyWith<$Res>(_self.deleteHazardState, (value) {
    return _then(_self.copyWith(deleteHazardState: value));
  });
}
}


/// Adds pattern-matching-related methods to [ViewHazardProviderState].
extension ViewHazardProviderStatePatterns on ViewHazardProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ViewHazardProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ViewHazardProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ViewHazardProviderState value)  $default,){
final _that = this;
switch (_that) {
case _ViewHazardProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ViewHazardProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _ViewHazardProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Hazard? hazard,  ViewHazardState viewHazardState,  DeleteHazardState deleteHazardState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ViewHazardProviderState() when $default != null:
return $default(_that.hazard,_that.viewHazardState,_that.deleteHazardState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Hazard? hazard,  ViewHazardState viewHazardState,  DeleteHazardState deleteHazardState)  $default,) {final _that = this;
switch (_that) {
case _ViewHazardProviderState():
return $default(_that.hazard,_that.viewHazardState,_that.deleteHazardState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Hazard? hazard,  ViewHazardState viewHazardState,  DeleteHazardState deleteHazardState)?  $default,) {final _that = this;
switch (_that) {
case _ViewHazardProviderState() when $default != null:
return $default(_that.hazard,_that.viewHazardState,_that.deleteHazardState);case _:
  return null;

}
}

}

/// @nodoc


class _ViewHazardProviderState implements ViewHazardProviderState {
  const _ViewHazardProviderState({this.hazard, this.viewHazardState = const ViewHazardState.initial(), this.deleteHazardState = const DeleteHazardState.initial()});
  

/// The hazard being viewed.
@override final  Hazard? hazard;
/// The state of viewing the hazard.
@override@JsonKey() final  ViewHazardState viewHazardState;
/// The state of deleting the hazard.
@override@JsonKey() final  DeleteHazardState deleteHazardState;

/// Create a copy of ViewHazardProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewHazardProviderStateCopyWith<_ViewHazardProviderState> get copyWith => __$ViewHazardProviderStateCopyWithImpl<_ViewHazardProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewHazardProviderState&&(identical(other.hazard, hazard) || other.hazard == hazard)&&(identical(other.viewHazardState, viewHazardState) || other.viewHazardState == viewHazardState)&&(identical(other.deleteHazardState, deleteHazardState) || other.deleteHazardState == deleteHazardState));
}


@override
int get hashCode => Object.hash(runtimeType,hazard,viewHazardState,deleteHazardState);

@override
String toString() {
  return 'ViewHazardProviderState(hazard: $hazard, viewHazardState: $viewHazardState, deleteHazardState: $deleteHazardState)';
}


}

/// @nodoc
abstract mixin class _$ViewHazardProviderStateCopyWith<$Res> implements $ViewHazardProviderStateCopyWith<$Res> {
  factory _$ViewHazardProviderStateCopyWith(_ViewHazardProviderState value, $Res Function(_ViewHazardProviderState) _then) = __$ViewHazardProviderStateCopyWithImpl;
@override @useResult
$Res call({
 Hazard? hazard, ViewHazardState viewHazardState, DeleteHazardState deleteHazardState
});


@override $HazardCopyWith<$Res>? get hazard;@override $ViewHazardStateCopyWith<$Res> get viewHazardState;@override $DeleteHazardStateCopyWith<$Res> get deleteHazardState;

}
/// @nodoc
class __$ViewHazardProviderStateCopyWithImpl<$Res>
    implements _$ViewHazardProviderStateCopyWith<$Res> {
  __$ViewHazardProviderStateCopyWithImpl(this._self, this._then);

  final _ViewHazardProviderState _self;
  final $Res Function(_ViewHazardProviderState) _then;

/// Create a copy of ViewHazardProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hazard = freezed,Object? viewHazardState = null,Object? deleteHazardState = null,}) {
  return _then(_ViewHazardProviderState(
hazard: freezed == hazard ? _self.hazard : hazard // ignore: cast_nullable_to_non_nullable
as Hazard?,viewHazardState: null == viewHazardState ? _self.viewHazardState : viewHazardState // ignore: cast_nullable_to_non_nullable
as ViewHazardState,deleteHazardState: null == deleteHazardState ? _self.deleteHazardState : deleteHazardState // ignore: cast_nullable_to_non_nullable
as DeleteHazardState,
  ));
}

/// Create a copy of ViewHazardProviderState
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
}/// Create a copy of ViewHazardProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViewHazardStateCopyWith<$Res> get viewHazardState {
  
  return $ViewHazardStateCopyWith<$Res>(_self.viewHazardState, (value) {
    return _then(_self.copyWith(viewHazardState: value));
  });
}/// Create a copy of ViewHazardProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeleteHazardStateCopyWith<$Res> get deleteHazardState {
  
  return $DeleteHazardStateCopyWith<$Res>(_self.deleteHazardState, (value) {
    return _then(_self.copyWith(deleteHazardState: value));
  });
}
}

/// @nodoc
mixin _$ViewHazardState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewHazardState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ViewHazardState()';
}


}

/// @nodoc
class $ViewHazardStateCopyWith<$Res>  {
$ViewHazardStateCopyWith(ViewHazardState _, $Res Function(ViewHazardState) __);
}


/// Adds pattern-matching-related methods to [ViewHazardState].
extension ViewHazardStatePatterns on ViewHazardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ViewHazardStateInitial value)?  initial,TResult Function( _ViewHazardStateLoading value)?  loading,TResult Function( _ViewHazardStateSuccess value)?  success,TResult Function( _ViewHazardStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ViewHazardStateInitial() when initial != null:
return initial(_that);case _ViewHazardStateLoading() when loading != null:
return loading(_that);case _ViewHazardStateSuccess() when success != null:
return success(_that);case _ViewHazardStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ViewHazardStateInitial value)  initial,required TResult Function( _ViewHazardStateLoading value)  loading,required TResult Function( _ViewHazardStateSuccess value)  success,required TResult Function( _ViewHazardStateError value)  error,}){
final _that = this;
switch (_that) {
case _ViewHazardStateInitial():
return initial(_that);case _ViewHazardStateLoading():
return loading(_that);case _ViewHazardStateSuccess():
return success(_that);case _ViewHazardStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ViewHazardStateInitial value)?  initial,TResult? Function( _ViewHazardStateLoading value)?  loading,TResult? Function( _ViewHazardStateSuccess value)?  success,TResult? Function( _ViewHazardStateError value)?  error,}){
final _that = this;
switch (_that) {
case _ViewHazardStateInitial() when initial != null:
return initial(_that);case _ViewHazardStateLoading() when loading != null:
return loading(_that);case _ViewHazardStateSuccess() when success != null:
return success(_that);case _ViewHazardStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ViewHazardResponse response)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ViewHazardStateInitial() when initial != null:
return initial();case _ViewHazardStateLoading() when loading != null:
return loading();case _ViewHazardStateSuccess() when success != null:
return success(_that.response);case _ViewHazardStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ViewHazardResponse response)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _ViewHazardStateInitial():
return initial();case _ViewHazardStateLoading():
return loading();case _ViewHazardStateSuccess():
return success(_that.response);case _ViewHazardStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ViewHazardResponse response)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _ViewHazardStateInitial() when initial != null:
return initial();case _ViewHazardStateLoading() when loading != null:
return loading();case _ViewHazardStateSuccess() when success != null:
return success(_that.response);case _ViewHazardStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ViewHazardStateInitial implements ViewHazardState {
  const _ViewHazardStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewHazardStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ViewHazardState.initial()';
}


}




/// @nodoc


class _ViewHazardStateLoading implements ViewHazardState {
  const _ViewHazardStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewHazardStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ViewHazardState.loading()';
}


}




/// @nodoc


class _ViewHazardStateSuccess implements ViewHazardState {
  const _ViewHazardStateSuccess(this.response);
  

 final  ViewHazardResponse response;

/// Create a copy of ViewHazardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewHazardStateSuccessCopyWith<_ViewHazardStateSuccess> get copyWith => __$ViewHazardStateSuccessCopyWithImpl<_ViewHazardStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewHazardStateSuccess&&(identical(other.response, response) || other.response == response));
}


@override
int get hashCode => Object.hash(runtimeType,response);

@override
String toString() {
  return 'ViewHazardState.success(response: $response)';
}


}

/// @nodoc
abstract mixin class _$ViewHazardStateSuccessCopyWith<$Res> implements $ViewHazardStateCopyWith<$Res> {
  factory _$ViewHazardStateSuccessCopyWith(_ViewHazardStateSuccess value, $Res Function(_ViewHazardStateSuccess) _then) = __$ViewHazardStateSuccessCopyWithImpl;
@useResult
$Res call({
 ViewHazardResponse response
});


$ViewHazardResponseCopyWith<$Res> get response;

}
/// @nodoc
class __$ViewHazardStateSuccessCopyWithImpl<$Res>
    implements _$ViewHazardStateSuccessCopyWith<$Res> {
  __$ViewHazardStateSuccessCopyWithImpl(this._self, this._then);

  final _ViewHazardStateSuccess _self;
  final $Res Function(_ViewHazardStateSuccess) _then;

/// Create a copy of ViewHazardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? response = null,}) {
  return _then(_ViewHazardStateSuccess(
null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as ViewHazardResponse,
  ));
}

/// Create a copy of ViewHazardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViewHazardResponseCopyWith<$Res> get response {
  
  return $ViewHazardResponseCopyWith<$Res>(_self.response, (value) {
    return _then(_self.copyWith(response: value));
  });
}
}

/// @nodoc


class _ViewHazardStateError implements ViewHazardState {
  const _ViewHazardStateError(this.error);
  

 final  AppError error;

/// Create a copy of ViewHazardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewHazardStateErrorCopyWith<_ViewHazardStateError> get copyWith => __$ViewHazardStateErrorCopyWithImpl<_ViewHazardStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewHazardStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ViewHazardState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$ViewHazardStateErrorCopyWith<$Res> implements $ViewHazardStateCopyWith<$Res> {
  factory _$ViewHazardStateErrorCopyWith(_ViewHazardStateError value, $Res Function(_ViewHazardStateError) _then) = __$ViewHazardStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$ViewHazardStateErrorCopyWithImpl<$Res>
    implements _$ViewHazardStateErrorCopyWith<$Res> {
  __$ViewHazardStateErrorCopyWithImpl(this._self, this._then);

  final _ViewHazardStateError _self;
  final $Res Function(_ViewHazardStateError) _then;

/// Create a copy of ViewHazardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_ViewHazardStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of ViewHazardState
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
mixin _$DeleteHazardState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteHazardState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeleteHazardState()';
}


}

/// @nodoc
class $DeleteHazardStateCopyWith<$Res>  {
$DeleteHazardStateCopyWith(DeleteHazardState _, $Res Function(DeleteHazardState) __);
}


/// Adds pattern-matching-related methods to [DeleteHazardState].
extension DeleteHazardStatePatterns on DeleteHazardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _DeleteHazardStateInitial value)?  initial,TResult Function( _DeleteHazardStateLoading value)?  loading,TResult Function( _DeleteHazardStateSuccess value)?  success,TResult Function( _DeleteHazardStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeleteHazardStateInitial() when initial != null:
return initial(_that);case _DeleteHazardStateLoading() when loading != null:
return loading(_that);case _DeleteHazardStateSuccess() when success != null:
return success(_that);case _DeleteHazardStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _DeleteHazardStateInitial value)  initial,required TResult Function( _DeleteHazardStateLoading value)  loading,required TResult Function( _DeleteHazardStateSuccess value)  success,required TResult Function( _DeleteHazardStateError value)  error,}){
final _that = this;
switch (_that) {
case _DeleteHazardStateInitial():
return initial(_that);case _DeleteHazardStateLoading():
return loading(_that);case _DeleteHazardStateSuccess():
return success(_that);case _DeleteHazardStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _DeleteHazardStateInitial value)?  initial,TResult? Function( _DeleteHazardStateLoading value)?  loading,TResult? Function( _DeleteHazardStateSuccess value)?  success,TResult? Function( _DeleteHazardStateError value)?  error,}){
final _that = this;
switch (_that) {
case _DeleteHazardStateInitial() when initial != null:
return initial(_that);case _DeleteHazardStateLoading() when loading != null:
return loading(_that);case _DeleteHazardStateSuccess() when success != null:
return success(_that);case _DeleteHazardStateError() when error != null:
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
case _DeleteHazardStateInitial() when initial != null:
return initial();case _DeleteHazardStateLoading() when loading != null:
return loading();case _DeleteHazardStateSuccess() when success != null:
return success();case _DeleteHazardStateError() when error != null:
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
case _DeleteHazardStateInitial():
return initial();case _DeleteHazardStateLoading():
return loading();case _DeleteHazardStateSuccess():
return success();case _DeleteHazardStateError():
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
case _DeleteHazardStateInitial() when initial != null:
return initial();case _DeleteHazardStateLoading() when loading != null:
return loading();case _DeleteHazardStateSuccess() when success != null:
return success();case _DeleteHazardStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _DeleteHazardStateInitial implements DeleteHazardState {
  const _DeleteHazardStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteHazardStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeleteHazardState.initial()';
}


}




/// @nodoc


class _DeleteHazardStateLoading implements DeleteHazardState {
  const _DeleteHazardStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteHazardStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeleteHazardState.loading()';
}


}




/// @nodoc


class _DeleteHazardStateSuccess implements DeleteHazardState {
  const _DeleteHazardStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteHazardStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeleteHazardState.success()';
}


}




/// @nodoc


class _DeleteHazardStateError implements DeleteHazardState {
  const _DeleteHazardStateError(this.error);
  

 final  AppError error;

/// Create a copy of DeleteHazardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteHazardStateErrorCopyWith<_DeleteHazardStateError> get copyWith => __$DeleteHazardStateErrorCopyWithImpl<_DeleteHazardStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteHazardStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'DeleteHazardState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$DeleteHazardStateErrorCopyWith<$Res> implements $DeleteHazardStateCopyWith<$Res> {
  factory _$DeleteHazardStateErrorCopyWith(_DeleteHazardStateError value, $Res Function(_DeleteHazardStateError) _then) = __$DeleteHazardStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$DeleteHazardStateErrorCopyWithImpl<$Res>
    implements _$DeleteHazardStateErrorCopyWith<$Res> {
  __$DeleteHazardStateErrorCopyWithImpl(this._self, this._then);

  final _DeleteHazardStateError _self;
  final $Res Function(_DeleteHazardStateError) _then;

/// Create a copy of DeleteHazardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_DeleteHazardStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of DeleteHazardState
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
