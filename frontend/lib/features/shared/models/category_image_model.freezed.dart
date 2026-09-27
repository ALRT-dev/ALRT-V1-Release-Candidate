// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_image_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoryImage {

 String get id; String get categoryId; CategoryImageType get imageType;@JsonKey(name: 'presignedUrl') String get url; String get s3Key; int? get width; int? get height; int? get fileSizeBytes;
/// Create a copy of CategoryImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryImageCopyWith<CategoryImage> get copyWith => _$CategoryImageCopyWithImpl<CategoryImage>(this as CategoryImage, _$identity);

  /// Serializes this CategoryImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryImage&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.imageType, imageType) || other.imageType == imageType)&&(identical(other.url, url) || other.url == url)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,imageType,url,s3Key,width,height,fileSizeBytes);

@override
String toString() {
  return 'CategoryImage(id: $id, categoryId: $categoryId, imageType: $imageType, url: $url, s3Key: $s3Key, width: $width, height: $height, fileSizeBytes: $fileSizeBytes)';
}


}

/// @nodoc
abstract mixin class $CategoryImageCopyWith<$Res>  {
  factory $CategoryImageCopyWith(CategoryImage value, $Res Function(CategoryImage) _then) = _$CategoryImageCopyWithImpl;
@useResult
$Res call({
 String id, String categoryId, CategoryImageType imageType,@JsonKey(name: 'presignedUrl') String url, String s3Key, int? width, int? height, int? fileSizeBytes
});




}
/// @nodoc
class _$CategoryImageCopyWithImpl<$Res>
    implements $CategoryImageCopyWith<$Res> {
  _$CategoryImageCopyWithImpl(this._self, this._then);

  final CategoryImage _self;
  final $Res Function(CategoryImage) _then;

/// Create a copy of CategoryImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = null,Object? imageType = null,Object? url = null,Object? s3Key = null,Object? width = freezed,Object? height = freezed,Object? fileSizeBytes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,imageType: null == imageType ? _self.imageType : imageType // ignore: cast_nullable_to_non_nullable
as CategoryImageType,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,s3Key: null == s3Key ? _self.s3Key : s3Key // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,fileSizeBytes: freezed == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryImage].
extension CategoryImagePatterns on CategoryImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryImage value)  $default,){
final _that = this;
switch (_that) {
case _CategoryImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryImage value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String categoryId,  CategoryImageType imageType, @JsonKey(name: 'presignedUrl')  String url,  String s3Key,  int? width,  int? height,  int? fileSizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryImage() when $default != null:
return $default(_that.id,_that.categoryId,_that.imageType,_that.url,_that.s3Key,_that.width,_that.height,_that.fileSizeBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String categoryId,  CategoryImageType imageType, @JsonKey(name: 'presignedUrl')  String url,  String s3Key,  int? width,  int? height,  int? fileSizeBytes)  $default,) {final _that = this;
switch (_that) {
case _CategoryImage():
return $default(_that.id,_that.categoryId,_that.imageType,_that.url,_that.s3Key,_that.width,_that.height,_that.fileSizeBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String categoryId,  CategoryImageType imageType, @JsonKey(name: 'presignedUrl')  String url,  String s3Key,  int? width,  int? height,  int? fileSizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _CategoryImage() when $default != null:
return $default(_that.id,_that.categoryId,_that.imageType,_that.url,_that.s3Key,_that.width,_that.height,_that.fileSizeBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryImage extends CategoryImage {
  const _CategoryImage({required this.id, required this.categoryId, required this.imageType, @JsonKey(name: 'presignedUrl') required this.url, required this.s3Key, this.width, this.height, this.fileSizeBytes}): super._();
  factory _CategoryImage.fromJson(Map<String, dynamic> json) => _$CategoryImageFromJson(json);

@override final  String id;
@override final  String categoryId;
@override final  CategoryImageType imageType;
@override@JsonKey(name: 'presignedUrl') final  String url;
@override final  String s3Key;
@override final  int? width;
@override final  int? height;
@override final  int? fileSizeBytes;

/// Create a copy of CategoryImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryImageCopyWith<_CategoryImage> get copyWith => __$CategoryImageCopyWithImpl<_CategoryImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryImage&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.imageType, imageType) || other.imageType == imageType)&&(identical(other.url, url) || other.url == url)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,imageType,url,s3Key,width,height,fileSizeBytes);

@override
String toString() {
  return 'CategoryImage(id: $id, categoryId: $categoryId, imageType: $imageType, url: $url, s3Key: $s3Key, width: $width, height: $height, fileSizeBytes: $fileSizeBytes)';
}


}

/// @nodoc
abstract mixin class _$CategoryImageCopyWith<$Res> implements $CategoryImageCopyWith<$Res> {
  factory _$CategoryImageCopyWith(_CategoryImage value, $Res Function(_CategoryImage) _then) = __$CategoryImageCopyWithImpl;
@override @useResult
$Res call({
 String id, String categoryId, CategoryImageType imageType,@JsonKey(name: 'presignedUrl') String url, String s3Key, int? width, int? height, int? fileSizeBytes
});




}
/// @nodoc
class __$CategoryImageCopyWithImpl<$Res>
    implements _$CategoryImageCopyWith<$Res> {
  __$CategoryImageCopyWithImpl(this._self, this._then);

  final _CategoryImage _self;
  final $Res Function(_CategoryImage) _then;

/// Create a copy of CategoryImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = null,Object? imageType = null,Object? url = null,Object? s3Key = null,Object? width = freezed,Object? height = freezed,Object? fileSizeBytes = freezed,}) {
  return _then(_CategoryImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,imageType: null == imageType ? _self.imageType : imageType // ignore: cast_nullable_to_non_nullable
as CategoryImageType,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,s3Key: null == s3Key ? _self.s3Key : s3Key // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,fileSizeBytes: freezed == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
