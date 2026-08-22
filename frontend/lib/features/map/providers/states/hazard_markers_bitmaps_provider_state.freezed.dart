// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hazard_markers_bitmaps_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HazardMarkersBitmapsProviderState {

/// The map of hazard (severity and category emoji) to their corresponding marker bitmaps.
 Map<String, BitmapDescriptor> get markerBitmaps;/// Bitmap for small red dot icon used at low zoom levels.
 BitmapDescriptor? get redDotBitmap;/// The state of generating marker bitmaps.
 GenerateMarkerBitmaps get generateMarkerBitmaps;
/// Create a copy of HazardMarkersBitmapsProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HazardMarkersBitmapsProviderStateCopyWith<HazardMarkersBitmapsProviderState> get copyWith => _$HazardMarkersBitmapsProviderStateCopyWithImpl<HazardMarkersBitmapsProviderState>(this as HazardMarkersBitmapsProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HazardMarkersBitmapsProviderState&&const DeepCollectionEquality().equals(other.markerBitmaps, markerBitmaps)&&(identical(other.redDotBitmap, redDotBitmap) || other.redDotBitmap == redDotBitmap)&&(identical(other.generateMarkerBitmaps, generateMarkerBitmaps) || other.generateMarkerBitmaps == generateMarkerBitmaps));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(markerBitmaps),redDotBitmap,generateMarkerBitmaps);

@override
String toString() {
  return 'HazardMarkersBitmapsProviderState(markerBitmaps: $markerBitmaps, redDotBitmap: $redDotBitmap, generateMarkerBitmaps: $generateMarkerBitmaps)';
}


}

/// @nodoc
abstract mixin class $HazardMarkersBitmapsProviderStateCopyWith<$Res>  {
  factory $HazardMarkersBitmapsProviderStateCopyWith(HazardMarkersBitmapsProviderState value, $Res Function(HazardMarkersBitmapsProviderState) _then) = _$HazardMarkersBitmapsProviderStateCopyWithImpl;
@useResult
$Res call({
 Map<String, BitmapDescriptor> markerBitmaps, BitmapDescriptor? redDotBitmap, GenerateMarkerBitmaps generateMarkerBitmaps
});


$GenerateMarkerBitmapsCopyWith<$Res> get generateMarkerBitmaps;

}
/// @nodoc
class _$HazardMarkersBitmapsProviderStateCopyWithImpl<$Res>
    implements $HazardMarkersBitmapsProviderStateCopyWith<$Res> {
  _$HazardMarkersBitmapsProviderStateCopyWithImpl(this._self, this._then);

  final HazardMarkersBitmapsProviderState _self;
  final $Res Function(HazardMarkersBitmapsProviderState) _then;

/// Create a copy of HazardMarkersBitmapsProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? markerBitmaps = null,Object? redDotBitmap = freezed,Object? generateMarkerBitmaps = null,}) {
  return _then(_self.copyWith(
markerBitmaps: null == markerBitmaps ? _self.markerBitmaps : markerBitmaps // ignore: cast_nullable_to_non_nullable
as Map<String, BitmapDescriptor>,redDotBitmap: freezed == redDotBitmap ? _self.redDotBitmap : redDotBitmap // ignore: cast_nullable_to_non_nullable
as BitmapDescriptor?,generateMarkerBitmaps: null == generateMarkerBitmaps ? _self.generateMarkerBitmaps : generateMarkerBitmaps // ignore: cast_nullable_to_non_nullable
as GenerateMarkerBitmaps,
  ));
}
/// Create a copy of HazardMarkersBitmapsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenerateMarkerBitmapsCopyWith<$Res> get generateMarkerBitmaps {
  
  return $GenerateMarkerBitmapsCopyWith<$Res>(_self.generateMarkerBitmaps, (value) {
    return _then(_self.copyWith(generateMarkerBitmaps: value));
  });
}
}


/// Adds pattern-matching-related methods to [HazardMarkersBitmapsProviderState].
extension HazardMarkersBitmapsProviderStatePatterns on HazardMarkersBitmapsProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HazardMarkersBitmapsProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HazardMarkersBitmapsProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HazardMarkersBitmapsProviderState value)  $default,){
final _that = this;
switch (_that) {
case _HazardMarkersBitmapsProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HazardMarkersBitmapsProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _HazardMarkersBitmapsProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, BitmapDescriptor> markerBitmaps,  BitmapDescriptor? redDotBitmap,  GenerateMarkerBitmaps generateMarkerBitmaps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HazardMarkersBitmapsProviderState() when $default != null:
return $default(_that.markerBitmaps,_that.redDotBitmap,_that.generateMarkerBitmaps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, BitmapDescriptor> markerBitmaps,  BitmapDescriptor? redDotBitmap,  GenerateMarkerBitmaps generateMarkerBitmaps)  $default,) {final _that = this;
switch (_that) {
case _HazardMarkersBitmapsProviderState():
return $default(_that.markerBitmaps,_that.redDotBitmap,_that.generateMarkerBitmaps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, BitmapDescriptor> markerBitmaps,  BitmapDescriptor? redDotBitmap,  GenerateMarkerBitmaps generateMarkerBitmaps)?  $default,) {final _that = this;
switch (_that) {
case _HazardMarkersBitmapsProviderState() when $default != null:
return $default(_that.markerBitmaps,_that.redDotBitmap,_that.generateMarkerBitmaps);case _:
  return null;

}
}

}

/// @nodoc


class _HazardMarkersBitmapsProviderState implements HazardMarkersBitmapsProviderState {
  const _HazardMarkersBitmapsProviderState({final  Map<String, BitmapDescriptor> markerBitmaps = const {}, this.redDotBitmap, this.generateMarkerBitmaps = const GenerateMarkerBitmaps.initial()}): _markerBitmaps = markerBitmaps;
  

/// The map of hazard (severity and category emoji) to their corresponding marker bitmaps.
 final  Map<String, BitmapDescriptor> _markerBitmaps;
/// The map of hazard (severity and category emoji) to their corresponding marker bitmaps.
@override@JsonKey() Map<String, BitmapDescriptor> get markerBitmaps {
  if (_markerBitmaps is EqualUnmodifiableMapView) return _markerBitmaps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_markerBitmaps);
}

/// Bitmap for small red dot icon used at low zoom levels.
@override final  BitmapDescriptor? redDotBitmap;
/// The state of generating marker bitmaps.
@override@JsonKey() final  GenerateMarkerBitmaps generateMarkerBitmaps;

/// Create a copy of HazardMarkersBitmapsProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HazardMarkersBitmapsProviderStateCopyWith<_HazardMarkersBitmapsProviderState> get copyWith => __$HazardMarkersBitmapsProviderStateCopyWithImpl<_HazardMarkersBitmapsProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HazardMarkersBitmapsProviderState&&const DeepCollectionEquality().equals(other._markerBitmaps, _markerBitmaps)&&(identical(other.redDotBitmap, redDotBitmap) || other.redDotBitmap == redDotBitmap)&&(identical(other.generateMarkerBitmaps, generateMarkerBitmaps) || other.generateMarkerBitmaps == generateMarkerBitmaps));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_markerBitmaps),redDotBitmap,generateMarkerBitmaps);

@override
String toString() {
  return 'HazardMarkersBitmapsProviderState(markerBitmaps: $markerBitmaps, redDotBitmap: $redDotBitmap, generateMarkerBitmaps: $generateMarkerBitmaps)';
}


}

/// @nodoc
abstract mixin class _$HazardMarkersBitmapsProviderStateCopyWith<$Res> implements $HazardMarkersBitmapsProviderStateCopyWith<$Res> {
  factory _$HazardMarkersBitmapsProviderStateCopyWith(_HazardMarkersBitmapsProviderState value, $Res Function(_HazardMarkersBitmapsProviderState) _then) = __$HazardMarkersBitmapsProviderStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, BitmapDescriptor> markerBitmaps, BitmapDescriptor? redDotBitmap, GenerateMarkerBitmaps generateMarkerBitmaps
});


@override $GenerateMarkerBitmapsCopyWith<$Res> get generateMarkerBitmaps;

}
/// @nodoc
class __$HazardMarkersBitmapsProviderStateCopyWithImpl<$Res>
    implements _$HazardMarkersBitmapsProviderStateCopyWith<$Res> {
  __$HazardMarkersBitmapsProviderStateCopyWithImpl(this._self, this._then);

  final _HazardMarkersBitmapsProviderState _self;
  final $Res Function(_HazardMarkersBitmapsProviderState) _then;

/// Create a copy of HazardMarkersBitmapsProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? markerBitmaps = null,Object? redDotBitmap = freezed,Object? generateMarkerBitmaps = null,}) {
  return _then(_HazardMarkersBitmapsProviderState(
markerBitmaps: null == markerBitmaps ? _self._markerBitmaps : markerBitmaps // ignore: cast_nullable_to_non_nullable
as Map<String, BitmapDescriptor>,redDotBitmap: freezed == redDotBitmap ? _self.redDotBitmap : redDotBitmap // ignore: cast_nullable_to_non_nullable
as BitmapDescriptor?,generateMarkerBitmaps: null == generateMarkerBitmaps ? _self.generateMarkerBitmaps : generateMarkerBitmaps // ignore: cast_nullable_to_non_nullable
as GenerateMarkerBitmaps,
  ));
}

/// Create a copy of HazardMarkersBitmapsProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenerateMarkerBitmapsCopyWith<$Res> get generateMarkerBitmaps {
  
  return $GenerateMarkerBitmapsCopyWith<$Res>(_self.generateMarkerBitmaps, (value) {
    return _then(_self.copyWith(generateMarkerBitmaps: value));
  });
}
}

/// @nodoc
mixin _$GenerateMarkerBitmaps {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateMarkerBitmaps);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GenerateMarkerBitmaps()';
}


}

/// @nodoc
class $GenerateMarkerBitmapsCopyWith<$Res>  {
$GenerateMarkerBitmapsCopyWith(GenerateMarkerBitmaps _, $Res Function(GenerateMarkerBitmaps) __);
}


/// Adds pattern-matching-related methods to [GenerateMarkerBitmaps].
extension GenerateMarkerBitmapsPatterns on GenerateMarkerBitmaps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GenerateMarkerBitmapsInitial value)?  initial,TResult Function( _GenerateMarkerBitmapsLoading value)?  loading,TResult Function( _GenerateMarkerBitmapsSuccess value)?  success,TResult Function( _GenerateMarkerBitmapsFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerateMarkerBitmapsInitial() when initial != null:
return initial(_that);case _GenerateMarkerBitmapsLoading() when loading != null:
return loading(_that);case _GenerateMarkerBitmapsSuccess() when success != null:
return success(_that);case _GenerateMarkerBitmapsFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GenerateMarkerBitmapsInitial value)  initial,required TResult Function( _GenerateMarkerBitmapsLoading value)  loading,required TResult Function( _GenerateMarkerBitmapsSuccess value)  success,required TResult Function( _GenerateMarkerBitmapsFailure value)  failure,}){
final _that = this;
switch (_that) {
case _GenerateMarkerBitmapsInitial():
return initial(_that);case _GenerateMarkerBitmapsLoading():
return loading(_that);case _GenerateMarkerBitmapsSuccess():
return success(_that);case _GenerateMarkerBitmapsFailure():
return failure(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GenerateMarkerBitmapsInitial value)?  initial,TResult? Function( _GenerateMarkerBitmapsLoading value)?  loading,TResult? Function( _GenerateMarkerBitmapsSuccess value)?  success,TResult? Function( _GenerateMarkerBitmapsFailure value)?  failure,}){
final _that = this;
switch (_that) {
case _GenerateMarkerBitmapsInitial() when initial != null:
return initial(_that);case _GenerateMarkerBitmapsLoading() when loading != null:
return loading(_that);case _GenerateMarkerBitmapsSuccess() when success != null:
return success(_that);case _GenerateMarkerBitmapsFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Map<String, BitmapDescriptor> markerBitmaps)?  success,TResult Function( AppError error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerateMarkerBitmapsInitial() when initial != null:
return initial();case _GenerateMarkerBitmapsLoading() when loading != null:
return loading();case _GenerateMarkerBitmapsSuccess() when success != null:
return success(_that.markerBitmaps);case _GenerateMarkerBitmapsFailure() when failure != null:
return failure(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Map<String, BitmapDescriptor> markerBitmaps)  success,required TResult Function( AppError error)  failure,}) {final _that = this;
switch (_that) {
case _GenerateMarkerBitmapsInitial():
return initial();case _GenerateMarkerBitmapsLoading():
return loading();case _GenerateMarkerBitmapsSuccess():
return success(_that.markerBitmaps);case _GenerateMarkerBitmapsFailure():
return failure(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Map<String, BitmapDescriptor> markerBitmaps)?  success,TResult? Function( AppError error)?  failure,}) {final _that = this;
switch (_that) {
case _GenerateMarkerBitmapsInitial() when initial != null:
return initial();case _GenerateMarkerBitmapsLoading() when loading != null:
return loading();case _GenerateMarkerBitmapsSuccess() when success != null:
return success(_that.markerBitmaps);case _GenerateMarkerBitmapsFailure() when failure != null:
return failure(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GenerateMarkerBitmapsInitial implements GenerateMarkerBitmaps {
  const _GenerateMarkerBitmapsInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateMarkerBitmapsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GenerateMarkerBitmaps.initial()';
}


}




/// @nodoc


class _GenerateMarkerBitmapsLoading implements GenerateMarkerBitmaps {
  const _GenerateMarkerBitmapsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateMarkerBitmapsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GenerateMarkerBitmaps.loading()';
}


}




/// @nodoc


class _GenerateMarkerBitmapsSuccess implements GenerateMarkerBitmaps {
  const _GenerateMarkerBitmapsSuccess(final  Map<String, BitmapDescriptor> markerBitmaps): _markerBitmaps = markerBitmaps;
  

 final  Map<String, BitmapDescriptor> _markerBitmaps;
 Map<String, BitmapDescriptor> get markerBitmaps {
  if (_markerBitmaps is EqualUnmodifiableMapView) return _markerBitmaps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_markerBitmaps);
}


/// Create a copy of GenerateMarkerBitmaps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerateMarkerBitmapsSuccessCopyWith<_GenerateMarkerBitmapsSuccess> get copyWith => __$GenerateMarkerBitmapsSuccessCopyWithImpl<_GenerateMarkerBitmapsSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateMarkerBitmapsSuccess&&const DeepCollectionEquality().equals(other._markerBitmaps, _markerBitmaps));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_markerBitmaps));

@override
String toString() {
  return 'GenerateMarkerBitmaps.success(markerBitmaps: $markerBitmaps)';
}


}

/// @nodoc
abstract mixin class _$GenerateMarkerBitmapsSuccessCopyWith<$Res> implements $GenerateMarkerBitmapsCopyWith<$Res> {
  factory _$GenerateMarkerBitmapsSuccessCopyWith(_GenerateMarkerBitmapsSuccess value, $Res Function(_GenerateMarkerBitmapsSuccess) _then) = __$GenerateMarkerBitmapsSuccessCopyWithImpl;
@useResult
$Res call({
 Map<String, BitmapDescriptor> markerBitmaps
});




}
/// @nodoc
class __$GenerateMarkerBitmapsSuccessCopyWithImpl<$Res>
    implements _$GenerateMarkerBitmapsSuccessCopyWith<$Res> {
  __$GenerateMarkerBitmapsSuccessCopyWithImpl(this._self, this._then);

  final _GenerateMarkerBitmapsSuccess _self;
  final $Res Function(_GenerateMarkerBitmapsSuccess) _then;

/// Create a copy of GenerateMarkerBitmaps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? markerBitmaps = null,}) {
  return _then(_GenerateMarkerBitmapsSuccess(
null == markerBitmaps ? _self._markerBitmaps : markerBitmaps // ignore: cast_nullable_to_non_nullable
as Map<String, BitmapDescriptor>,
  ));
}


}

/// @nodoc


class _GenerateMarkerBitmapsFailure implements GenerateMarkerBitmaps {
  const _GenerateMarkerBitmapsFailure(this.error);
  

 final  AppError error;

/// Create a copy of GenerateMarkerBitmaps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerateMarkerBitmapsFailureCopyWith<_GenerateMarkerBitmapsFailure> get copyWith => __$GenerateMarkerBitmapsFailureCopyWithImpl<_GenerateMarkerBitmapsFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateMarkerBitmapsFailure&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GenerateMarkerBitmaps.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GenerateMarkerBitmapsFailureCopyWith<$Res> implements $GenerateMarkerBitmapsCopyWith<$Res> {
  factory _$GenerateMarkerBitmapsFailureCopyWith(_GenerateMarkerBitmapsFailure value, $Res Function(_GenerateMarkerBitmapsFailure) _then) = __$GenerateMarkerBitmapsFailureCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GenerateMarkerBitmapsFailureCopyWithImpl<$Res>
    implements _$GenerateMarkerBitmapsFailureCopyWith<$Res> {
  __$GenerateMarkerBitmapsFailureCopyWithImpl(this._self, this._then);

  final _GenerateMarkerBitmapsFailure _self;
  final $Res Function(_GenerateMarkerBitmapsFailure) _then;

/// Create a copy of GenerateMarkerBitmaps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GenerateMarkerBitmapsFailure(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GenerateMarkerBitmaps
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
