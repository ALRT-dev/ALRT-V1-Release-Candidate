// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 's3_media_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$S3Media {

/// The unique identifier for the media.
 String get id;/// The presigned URL where the media can be accessed.
@JsonKey(name: 'presignedUrl') String get url;/// The S3 key of the media file.
 String get s3Key;/// The type of the media (e.g., image, video).
 AlrtMediaType get type;/// The size of the media file in bytes.
 int? get fileSize;/// The URL of the thumbnail for the media, if applicable.
 String? get thumbnailUrl;
/// Create a copy of S3Media
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$S3MediaCopyWith<S3Media> get copyWith => _$S3MediaCopyWithImpl<S3Media>(this as S3Media, _$identity);

  /// Serializes this S3Media to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is S3Media&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key)&&(identical(other.type, type) || other.type == type)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,s3Key,type,fileSize,thumbnailUrl);

@override
String toString() {
  return 'S3Media(id: $id, url: $url, s3Key: $s3Key, type: $type, fileSize: $fileSize, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class $S3MediaCopyWith<$Res>  {
  factory $S3MediaCopyWith(S3Media value, $Res Function(S3Media) _then) = _$S3MediaCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'presignedUrl') String url, String s3Key, AlrtMediaType type, int? fileSize, String? thumbnailUrl
});




}
/// @nodoc
class _$S3MediaCopyWithImpl<$Res>
    implements $S3MediaCopyWith<$Res> {
  _$S3MediaCopyWithImpl(this._self, this._then);

  final S3Media _self;
  final $Res Function(S3Media) _then;

/// Create a copy of S3Media
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? s3Key = null,Object? type = null,Object? fileSize = freezed,Object? thumbnailUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,s3Key: null == s3Key ? _self.s3Key : s3Key // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AlrtMediaType,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [S3Media].
extension S3MediaPatterns on S3Media {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _S3Media value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _S3Media() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _S3Media value)  $default,){
final _that = this;
switch (_that) {
case _S3Media():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _S3Media value)?  $default,){
final _that = this;
switch (_that) {
case _S3Media() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'presignedUrl')  String url,  String s3Key,  AlrtMediaType type,  int? fileSize,  String? thumbnailUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _S3Media() when $default != null:
return $default(_that.id,_that.url,_that.s3Key,_that.type,_that.fileSize,_that.thumbnailUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'presignedUrl')  String url,  String s3Key,  AlrtMediaType type,  int? fileSize,  String? thumbnailUrl)  $default,) {final _that = this;
switch (_that) {
case _S3Media():
return $default(_that.id,_that.url,_that.s3Key,_that.type,_that.fileSize,_that.thumbnailUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'presignedUrl')  String url,  String s3Key,  AlrtMediaType type,  int? fileSize,  String? thumbnailUrl)?  $default,) {final _that = this;
switch (_that) {
case _S3Media() when $default != null:
return $default(_that.id,_that.url,_that.s3Key,_that.type,_that.fileSize,_that.thumbnailUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _S3Media extends S3Media {
  const _S3Media({required this.id, @JsonKey(name: 'presignedUrl') required this.url, required this.s3Key, required this.type, this.fileSize, this.thumbnailUrl}): super._();
  factory _S3Media.fromJson(Map<String, dynamic> json) => _$S3MediaFromJson(json);

/// The unique identifier for the media.
@override final  String id;
/// The presigned URL where the media can be accessed.
@override@JsonKey(name: 'presignedUrl') final  String url;
/// The S3 key of the media file.
@override final  String s3Key;
/// The type of the media (e.g., image, video).
@override final  AlrtMediaType type;
/// The size of the media file in bytes.
@override final  int? fileSize;
/// The URL of the thumbnail for the media, if applicable.
@override final  String? thumbnailUrl;

/// Create a copy of S3Media
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$S3MediaCopyWith<_S3Media> get copyWith => __$S3MediaCopyWithImpl<_S3Media>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$S3MediaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _S3Media&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key)&&(identical(other.type, type) || other.type == type)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,s3Key,type,fileSize,thumbnailUrl);

@override
String toString() {
  return 'S3Media(id: $id, url: $url, s3Key: $s3Key, type: $type, fileSize: $fileSize, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class _$S3MediaCopyWith<$Res> implements $S3MediaCopyWith<$Res> {
  factory _$S3MediaCopyWith(_S3Media value, $Res Function(_S3Media) _then) = __$S3MediaCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'presignedUrl') String url, String s3Key, AlrtMediaType type, int? fileSize, String? thumbnailUrl
});




}
/// @nodoc
class __$S3MediaCopyWithImpl<$Res>
    implements _$S3MediaCopyWith<$Res> {
  __$S3MediaCopyWithImpl(this._self, this._then);

  final _S3Media _self;
  final $Res Function(_S3Media) _then;

/// Create a copy of S3Media
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? s3Key = null,Object? type = null,Object? fileSize = freezed,Object? thumbnailUrl = freezed,}) {
  return _then(_S3Media(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,s3Key: null == s3Key ? _self.s3Key : s3Key // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AlrtMediaType,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
