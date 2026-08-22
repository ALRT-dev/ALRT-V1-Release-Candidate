// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mute_video_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MuteVideoProviderState {

 bool get isMuted;
/// Create a copy of MuteVideoProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuteVideoProviderStateCopyWith<MuteVideoProviderState> get copyWith => _$MuteVideoProviderStateCopyWithImpl<MuteVideoProviderState>(this as MuteVideoProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuteVideoProviderState&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}


@override
int get hashCode => Object.hash(runtimeType,isMuted);

@override
String toString() {
  return 'MuteVideoProviderState(isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class $MuteVideoProviderStateCopyWith<$Res>  {
  factory $MuteVideoProviderStateCopyWith(MuteVideoProviderState value, $Res Function(MuteVideoProviderState) _then) = _$MuteVideoProviderStateCopyWithImpl;
@useResult
$Res call({
 bool isMuted
});




}
/// @nodoc
class _$MuteVideoProviderStateCopyWithImpl<$Res>
    implements $MuteVideoProviderStateCopyWith<$Res> {
  _$MuteVideoProviderStateCopyWithImpl(this._self, this._then);

  final MuteVideoProviderState _self;
  final $Res Function(MuteVideoProviderState) _then;

/// Create a copy of MuteVideoProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isMuted = null,}) {
  return _then(_self.copyWith(
isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MuteVideoProviderState].
extension MuteVideoProviderStatePatterns on MuteVideoProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuteVideoProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuteVideoProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuteVideoProviderState value)  $default,){
final _that = this;
switch (_that) {
case _MuteVideoProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuteVideoProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _MuteVideoProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isMuted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuteVideoProviderState() when $default != null:
return $default(_that.isMuted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isMuted)  $default,) {final _that = this;
switch (_that) {
case _MuteVideoProviderState():
return $default(_that.isMuted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isMuted)?  $default,) {final _that = this;
switch (_that) {
case _MuteVideoProviderState() when $default != null:
return $default(_that.isMuted);case _:
  return null;

}
}

}

/// @nodoc


class _MuteVideoProviderState implements MuteVideoProviderState {
  const _MuteVideoProviderState({this.isMuted = false});
  

@override@JsonKey() final  bool isMuted;

/// Create a copy of MuteVideoProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuteVideoProviderStateCopyWith<_MuteVideoProviderState> get copyWith => __$MuteVideoProviderStateCopyWithImpl<_MuteVideoProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuteVideoProviderState&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}


@override
int get hashCode => Object.hash(runtimeType,isMuted);

@override
String toString() {
  return 'MuteVideoProviderState(isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class _$MuteVideoProviderStateCopyWith<$Res> implements $MuteVideoProviderStateCopyWith<$Res> {
  factory _$MuteVideoProviderStateCopyWith(_MuteVideoProviderState value, $Res Function(_MuteVideoProviderState) _then) = __$MuteVideoProviderStateCopyWithImpl;
@override @useResult
$Res call({
 bool isMuted
});




}
/// @nodoc
class __$MuteVideoProviderStateCopyWithImpl<$Res>
    implements _$MuteVideoProviderStateCopyWith<$Res> {
  __$MuteVideoProviderStateCopyWithImpl(this._self, this._then);

  final _MuteVideoProviderState _self;
  final $Res Function(_MuteVideoProviderState) _then;

/// Create a copy of MuteVideoProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isMuted = null,}) {
  return _then(_MuteVideoProviderState(
isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
