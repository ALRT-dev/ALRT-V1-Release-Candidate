// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hazard_category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HazardCategory {

/// The unique identifier for the hazard category.
 String get id;/// The name of the hazard category.
 String? get name;/// The description of the hazard category.
 String? get description;/// The color associated with the hazard category.
@ColorConverter() Color? get color;/// The ID of the parent category, if any.
 String? get parentId;/// The parent category of this hazard category, if any.
 HazardCategory? get parent;/// The number of hazards associated with this category.
 int get hazardsCount;/// Whether the hazard category is fire-related.
 bool get isFireRelated;/// The images associated with the hazard category.
 List<CategoryImage>? get images;
/// Create a copy of HazardCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HazardCategoryCopyWith<HazardCategory> get copyWith => _$HazardCategoryCopyWithImpl<HazardCategory>(this as HazardCategory, _$identity);

  /// Serializes this HazardCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HazardCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.color, color) || other.color == color)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.parent, parent) || other.parent == parent)&&(identical(other.hazardsCount, hazardsCount) || other.hazardsCount == hazardsCount)&&(identical(other.isFireRelated, isFireRelated) || other.isFireRelated == isFireRelated)&&const DeepCollectionEquality().equals(other.images, images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,color,parentId,parent,hazardsCount,isFireRelated,const DeepCollectionEquality().hash(images));

@override
String toString() {
  return 'HazardCategory(id: $id, name: $name, description: $description, color: $color, parentId: $parentId, parent: $parent, hazardsCount: $hazardsCount, isFireRelated: $isFireRelated, images: $images)';
}


}

/// @nodoc
abstract mixin class $HazardCategoryCopyWith<$Res>  {
  factory $HazardCategoryCopyWith(HazardCategory value, $Res Function(HazardCategory) _then) = _$HazardCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? description,@ColorConverter() Color? color, String? parentId, HazardCategory? parent, int hazardsCount, bool isFireRelated, List<CategoryImage>? images
});


$HazardCategoryCopyWith<$Res>? get parent;

}
/// @nodoc
class _$HazardCategoryCopyWithImpl<$Res>
    implements $HazardCategoryCopyWith<$Res> {
  _$HazardCategoryCopyWithImpl(this._self, this._then);

  final HazardCategory _self;
  final $Res Function(HazardCategory) _then;

/// Create a copy of HazardCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? description = freezed,Object? color = freezed,Object? parentId = freezed,Object? parent = freezed,Object? hazardsCount = null,Object? isFireRelated = null,Object? images = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as HazardCategory?,hazardsCount: null == hazardsCount ? _self.hazardsCount : hazardsCount // ignore: cast_nullable_to_non_nullable
as int,isFireRelated: null == isFireRelated ? _self.isFireRelated : isFireRelated // ignore: cast_nullable_to_non_nullable
as bool,images: freezed == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<CategoryImage>?,
  ));
}
/// Create a copy of HazardCategory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HazardCategoryCopyWith<$Res>? get parent {
    if (_self.parent == null) {
    return null;
  }

  return $HazardCategoryCopyWith<$Res>(_self.parent!, (value) {
    return _then(_self.copyWith(parent: value));
  });
}
}


/// Adds pattern-matching-related methods to [HazardCategory].
extension HazardCategoryPatterns on HazardCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HazardCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HazardCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HazardCategory value)  $default,){
final _that = this;
switch (_that) {
case _HazardCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HazardCategory value)?  $default,){
final _that = this;
switch (_that) {
case _HazardCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? description, @ColorConverter()  Color? color,  String? parentId,  HazardCategory? parent,  int hazardsCount,  bool isFireRelated,  List<CategoryImage>? images)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HazardCategory() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.color,_that.parentId,_that.parent,_that.hazardsCount,_that.isFireRelated,_that.images);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? description, @ColorConverter()  Color? color,  String? parentId,  HazardCategory? parent,  int hazardsCount,  bool isFireRelated,  List<CategoryImage>? images)  $default,) {final _that = this;
switch (_that) {
case _HazardCategory():
return $default(_that.id,_that.name,_that.description,_that.color,_that.parentId,_that.parent,_that.hazardsCount,_that.isFireRelated,_that.images);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? description, @ColorConverter()  Color? color,  String? parentId,  HazardCategory? parent,  int hazardsCount,  bool isFireRelated,  List<CategoryImage>? images)?  $default,) {final _that = this;
switch (_that) {
case _HazardCategory() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.color,_that.parentId,_that.parent,_that.hazardsCount,_that.isFireRelated,_that.images);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HazardCategory extends HazardCategory {
  const _HazardCategory({required this.id, this.name, this.description, @ColorConverter() this.color, this.parentId, this.parent, this.hazardsCount = 0, this.isFireRelated = false, final  List<CategoryImage>? images}): _images = images,super._();
  factory _HazardCategory.fromJson(Map<String, dynamic> json) => _$HazardCategoryFromJson(json);

/// The unique identifier for the hazard category.
@override final  String id;
/// The name of the hazard category.
@override final  String? name;
/// The description of the hazard category.
@override final  String? description;
/// The color associated with the hazard category.
@override@ColorConverter() final  Color? color;
/// The ID of the parent category, if any.
@override final  String? parentId;
/// The parent category of this hazard category, if any.
@override final  HazardCategory? parent;
/// The number of hazards associated with this category.
@override@JsonKey() final  int hazardsCount;
/// Whether the hazard category is fire-related.
@override@JsonKey() final  bool isFireRelated;
/// The images associated with the hazard category.
 final  List<CategoryImage>? _images;
/// The images associated with the hazard category.
@override List<CategoryImage>? get images {
  final value = _images;
  if (value == null) return null;
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of HazardCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HazardCategoryCopyWith<_HazardCategory> get copyWith => __$HazardCategoryCopyWithImpl<_HazardCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HazardCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HazardCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.color, color) || other.color == color)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.parent, parent) || other.parent == parent)&&(identical(other.hazardsCount, hazardsCount) || other.hazardsCount == hazardsCount)&&(identical(other.isFireRelated, isFireRelated) || other.isFireRelated == isFireRelated)&&const DeepCollectionEquality().equals(other._images, _images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,color,parentId,parent,hazardsCount,isFireRelated,const DeepCollectionEquality().hash(_images));

@override
String toString() {
  return 'HazardCategory(id: $id, name: $name, description: $description, color: $color, parentId: $parentId, parent: $parent, hazardsCount: $hazardsCount, isFireRelated: $isFireRelated, images: $images)';
}


}

/// @nodoc
abstract mixin class _$HazardCategoryCopyWith<$Res> implements $HazardCategoryCopyWith<$Res> {
  factory _$HazardCategoryCopyWith(_HazardCategory value, $Res Function(_HazardCategory) _then) = __$HazardCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? description,@ColorConverter() Color? color, String? parentId, HazardCategory? parent, int hazardsCount, bool isFireRelated, List<CategoryImage>? images
});


@override $HazardCategoryCopyWith<$Res>? get parent;

}
/// @nodoc
class __$HazardCategoryCopyWithImpl<$Res>
    implements _$HazardCategoryCopyWith<$Res> {
  __$HazardCategoryCopyWithImpl(this._self, this._then);

  final _HazardCategory _self;
  final $Res Function(_HazardCategory) _then;

/// Create a copy of HazardCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? description = freezed,Object? color = freezed,Object? parentId = freezed,Object? parent = freezed,Object? hazardsCount = null,Object? isFireRelated = null,Object? images = freezed,}) {
  return _then(_HazardCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as HazardCategory?,hazardsCount: null == hazardsCount ? _self.hazardsCount : hazardsCount // ignore: cast_nullable_to_non_nullable
as int,isFireRelated: null == isFireRelated ? _self.isFireRelated : isFireRelated // ignore: cast_nullable_to_non_nullable
as bool,images: freezed == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<CategoryImage>?,
  ));
}

/// Create a copy of HazardCategory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HazardCategoryCopyWith<$Res>? get parent {
    if (_self.parent == null) {
    return null;
  }

  return $HazardCategoryCopyWith<$Res>(_self.parent!, (value) {
    return _then(_self.copyWith(parent: value));
  });
}
}

// dart format on
