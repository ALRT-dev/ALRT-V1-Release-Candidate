// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alrt_media_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlrtMedia {

/// The unique identifier for the media.
 String get id;/// The [value] parameter represents either the local path of the file or network url of the file.
 String get value;/// The type of media.
///
/// E.g: image or video.
 AlrtMediaType get type;/// The source of the media.
///
/// E.g: file, networkUrl, or asset.
 AlrtMediaSource get source;/// The S3 key of the media file if it's stored in S3.
 String? get s3Key;
/// Create a copy of AlrtMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlrtMediaCopyWith<AlrtMedia> get copyWith => _$AlrtMediaCopyWithImpl<AlrtMedia>(this as AlrtMedia, _$identity);

  /// Serializes this AlrtMedia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlrtMedia&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value)&&(identical(other.type, type) || other.type == type)&&(identical(other.source, source) || other.source == source)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,value,type,source,s3Key);

@override
String toString() {
  return 'AlrtMedia(id: $id, value: $value, type: $type, source: $source, s3Key: $s3Key)';
}


}

/// @nodoc
abstract mixin class $AlrtMediaCopyWith<$Res>  {
  factory $AlrtMediaCopyWith(AlrtMedia value, $Res Function(AlrtMedia) _then) = _$AlrtMediaCopyWithImpl;
@useResult
$Res call({
 String id, String value, AlrtMediaType type, AlrtMediaSource source, String? s3Key
});




}
/// @nodoc
class _$AlrtMediaCopyWithImpl<$Res>
    implements $AlrtMediaCopyWith<$Res> {
  _$AlrtMediaCopyWithImpl(this._self, this._then);

  final AlrtMedia _self;
  final $Res Function(AlrtMedia) _then;

/// Create a copy of AlrtMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? value = null,Object? type = null,Object? source = null,Object? s3Key = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AlrtMediaType,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AlrtMediaSource,s3Key: freezed == s3Key ? _self.s3Key : s3Key // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AlrtMedia].
extension AlrtMediaPatterns on AlrtMedia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlrtMedia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlrtMedia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlrtMedia value)  $default,){
final _that = this;
switch (_that) {
case _AlrtMedia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlrtMedia value)?  $default,){
final _that = this;
switch (_that) {
case _AlrtMedia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String value,  AlrtMediaType type,  AlrtMediaSource source,  String? s3Key)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlrtMedia() when $default != null:
return $default(_that.id,_that.value,_that.type,_that.source,_that.s3Key);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String value,  AlrtMediaType type,  AlrtMediaSource source,  String? s3Key)  $default,) {final _that = this;
switch (_that) {
case _AlrtMedia():
return $default(_that.id,_that.value,_that.type,_that.source,_that.s3Key);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String value,  AlrtMediaType type,  AlrtMediaSource source,  String? s3Key)?  $default,) {final _that = this;
switch (_that) {
case _AlrtMedia() when $default != null:
return $default(_that.id,_that.value,_that.type,_that.source,_that.s3Key);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlrtMedia implements AlrtMedia {
  const _AlrtMedia({required this.id, required this.value, required this.type, required this.source, this.s3Key});
  factory _AlrtMedia.fromJson(Map<String, dynamic> json) => _$AlrtMediaFromJson(json);

/// The unique identifier for the media.
@override final  String id;
/// The [value] parameter represents either the local path of the file or network url of the file.
@override final  String value;
/// The type of media.
///
/// E.g: image or video.
@override final  AlrtMediaType type;
/// The source of the media.
///
/// E.g: file, networkUrl, or asset.
@override final  AlrtMediaSource source;
/// The S3 key of the media file if it's stored in S3.
@override final  String? s3Key;

/// Create a copy of AlrtMedia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlrtMediaCopyWith<_AlrtMedia> get copyWith => __$AlrtMediaCopyWithImpl<_AlrtMedia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlrtMediaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlrtMedia&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value)&&(identical(other.type, type) || other.type == type)&&(identical(other.source, source) || other.source == source)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,value,type,source,s3Key);

@override
String toString() {
  return 'AlrtMedia(id: $id, value: $value, type: $type, source: $source, s3Key: $s3Key)';
}


}

/// @nodoc
abstract mixin class _$AlrtMediaCopyWith<$Res> implements $AlrtMediaCopyWith<$Res> {
  factory _$AlrtMediaCopyWith(_AlrtMedia value, $Res Function(_AlrtMedia) _then) = __$AlrtMediaCopyWithImpl;
@override @useResult
$Res call({
 String id, String value, AlrtMediaType type, AlrtMediaSource source, String? s3Key
});




}
/// @nodoc
class __$AlrtMediaCopyWithImpl<$Res>
    implements _$AlrtMediaCopyWith<$Res> {
  __$AlrtMediaCopyWithImpl(this._self, this._then);

  final _AlrtMedia _self;
  final $Res Function(_AlrtMedia) _then;

/// Create a copy of AlrtMedia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? value = null,Object? type = null,Object? source = null,Object? s3Key = freezed,}) {
  return _then(_AlrtMedia(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AlrtMediaType,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AlrtMediaSource,s3Key: freezed == s3Key ? _self.s3Key : s3Key // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
