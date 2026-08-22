// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'error_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppError {

 String get message; String? get code; String? get detailedMessage; String? get requestMethod; Uri? get requestUri; Map<String, dynamic> get extraData;
/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppErrorCopyWith<AppError> get copyWith => _$AppErrorCopyWithImpl<AppError>(this as AppError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppError&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code)&&(identical(other.detailedMessage, detailedMessage) || other.detailedMessage == detailedMessage)&&(identical(other.requestMethod, requestMethod) || other.requestMethod == requestMethod)&&(identical(other.requestUri, requestUri) || other.requestUri == requestUri)&&const DeepCollectionEquality().equals(other.extraData, extraData));
}


@override
int get hashCode => Object.hash(runtimeType,message,code,detailedMessage,requestMethod,requestUri,const DeepCollectionEquality().hash(extraData));

@override
String toString() {
  return 'AppError(message: $message, code: $code, detailedMessage: $detailedMessage, requestMethod: $requestMethod, requestUri: $requestUri, extraData: $extraData)';
}


}

/// @nodoc
abstract mixin class $AppErrorCopyWith<$Res>  {
  factory $AppErrorCopyWith(AppError value, $Res Function(AppError) _then) = _$AppErrorCopyWithImpl;
@useResult
$Res call({
 String message, String? code, String? detailedMessage, String? requestMethod, Uri? requestUri, Map<String, dynamic> extraData
});




}
/// @nodoc
class _$AppErrorCopyWithImpl<$Res>
    implements $AppErrorCopyWith<$Res> {
  _$AppErrorCopyWithImpl(this._self, this._then);

  final AppError _self;
  final $Res Function(AppError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? code = freezed,Object? detailedMessage = freezed,Object? requestMethod = freezed,Object? requestUri = freezed,Object? extraData = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,detailedMessage: freezed == detailedMessage ? _self.detailedMessage : detailedMessage // ignore: cast_nullable_to_non_nullable
as String?,requestMethod: freezed == requestMethod ? _self.requestMethod : requestMethod // ignore: cast_nullable_to_non_nullable
as String?,requestUri: freezed == requestUri ? _self.requestUri : requestUri // ignore: cast_nullable_to_non_nullable
as Uri?,extraData: null == extraData ? _self.extraData : extraData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [AppError].
extension AppErrorPatterns on AppError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppError value)  $default,){
final _that = this;
switch (_that) {
case _AppError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppError value)?  $default,){
final _that = this;
switch (_that) {
case _AppError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  String? code,  String? detailedMessage,  String? requestMethod,  Uri? requestUri,  Map<String, dynamic> extraData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppError() when $default != null:
return $default(_that.message,_that.code,_that.detailedMessage,_that.requestMethod,_that.requestUri,_that.extraData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  String? code,  String? detailedMessage,  String? requestMethod,  Uri? requestUri,  Map<String, dynamic> extraData)  $default,) {final _that = this;
switch (_that) {
case _AppError():
return $default(_that.message,_that.code,_that.detailedMessage,_that.requestMethod,_that.requestUri,_that.extraData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  String? code,  String? detailedMessage,  String? requestMethod,  Uri? requestUri,  Map<String, dynamic> extraData)?  $default,) {final _that = this;
switch (_that) {
case _AppError() when $default != null:
return $default(_that.message,_that.code,_that.detailedMessage,_that.requestMethod,_that.requestUri,_that.extraData);case _:
  return null;

}
}

}

/// @nodoc


class _AppError implements AppError {
  const _AppError({required this.message, this.code, this.detailedMessage, this.requestMethod, this.requestUri, final  Map<String, dynamic> extraData = const <String, dynamic>{}}): _extraData = extraData;
  

@override final  String message;
@override final  String? code;
@override final  String? detailedMessage;
@override final  String? requestMethod;
@override final  Uri? requestUri;
 final  Map<String, dynamic> _extraData;
@override@JsonKey() Map<String, dynamic> get extraData {
  if (_extraData is EqualUnmodifiableMapView) return _extraData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extraData);
}


/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppErrorCopyWith<_AppError> get copyWith => __$AppErrorCopyWithImpl<_AppError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppError&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code)&&(identical(other.detailedMessage, detailedMessage) || other.detailedMessage == detailedMessage)&&(identical(other.requestMethod, requestMethod) || other.requestMethod == requestMethod)&&(identical(other.requestUri, requestUri) || other.requestUri == requestUri)&&const DeepCollectionEquality().equals(other._extraData, _extraData));
}


@override
int get hashCode => Object.hash(runtimeType,message,code,detailedMessage,requestMethod,requestUri,const DeepCollectionEquality().hash(_extraData));

@override
String toString() {
  return 'AppError(message: $message, code: $code, detailedMessage: $detailedMessage, requestMethod: $requestMethod, requestUri: $requestUri, extraData: $extraData)';
}


}

/// @nodoc
abstract mixin class _$AppErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory _$AppErrorCopyWith(_AppError value, $Res Function(_AppError) _then) = __$AppErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String? code, String? detailedMessage, String? requestMethod, Uri? requestUri, Map<String, dynamic> extraData
});




}
/// @nodoc
class __$AppErrorCopyWithImpl<$Res>
    implements _$AppErrorCopyWith<$Res> {
  __$AppErrorCopyWithImpl(this._self, this._then);

  final _AppError _self;
  final $Res Function(_AppError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? code = freezed,Object? detailedMessage = freezed,Object? requestMethod = freezed,Object? requestUri = freezed,Object? extraData = null,}) {
  return _then(_AppError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,detailedMessage: freezed == detailedMessage ? _self.detailedMessage : detailedMessage // ignore: cast_nullable_to_non_nullable
as String?,requestMethod: freezed == requestMethod ? _self.requestMethod : requestMethod // ignore: cast_nullable_to_non_nullable
as String?,requestUri: freezed == requestUri ? _self.requestUri : requestUri // ignore: cast_nullable_to_non_nullable
as Uri?,extraData: null == extraData ? _self._extraData : extraData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
