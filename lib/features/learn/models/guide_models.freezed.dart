// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guide_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuideTopicsResponse {

 List<GuideTopic> get topics; int get completedCount; int get totalCount; List<String> get completedGuideIds; int get totalXpEarned;
/// Create a copy of GuideTopicsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuideTopicsResponseCopyWith<GuideTopicsResponse> get copyWith => _$GuideTopicsResponseCopyWithImpl<GuideTopicsResponse>(this as GuideTopicsResponse, _$identity);

  /// Serializes this GuideTopicsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuideTopicsResponse&&const DeepCollectionEquality().equals(other.topics, topics)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other.completedGuideIds, completedGuideIds)&&(identical(other.totalXpEarned, totalXpEarned) || other.totalXpEarned == totalXpEarned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(topics),completedCount,totalCount,const DeepCollectionEquality().hash(completedGuideIds),totalXpEarned);

@override
String toString() {
  return 'GuideTopicsResponse(topics: $topics, completedCount: $completedCount, totalCount: $totalCount, completedGuideIds: $completedGuideIds, totalXpEarned: $totalXpEarned)';
}


}

/// @nodoc
abstract mixin class $GuideTopicsResponseCopyWith<$Res>  {
  factory $GuideTopicsResponseCopyWith(GuideTopicsResponse value, $Res Function(GuideTopicsResponse) _then) = _$GuideTopicsResponseCopyWithImpl;
@useResult
$Res call({
 List<GuideTopic> topics, int completedCount, int totalCount, List<String> completedGuideIds, int totalXpEarned
});




}
/// @nodoc
class _$GuideTopicsResponseCopyWithImpl<$Res>
    implements $GuideTopicsResponseCopyWith<$Res> {
  _$GuideTopicsResponseCopyWithImpl(this._self, this._then);

  final GuideTopicsResponse _self;
  final $Res Function(GuideTopicsResponse) _then;

/// Create a copy of GuideTopicsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topics = null,Object? completedCount = null,Object? totalCount = null,Object? completedGuideIds = null,Object? totalXpEarned = null,}) {
  return _then(_self.copyWith(
topics: null == topics ? _self.topics : topics // ignore: cast_nullable_to_non_nullable
as List<GuideTopic>,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,completedGuideIds: null == completedGuideIds ? _self.completedGuideIds : completedGuideIds // ignore: cast_nullable_to_non_nullable
as List<String>,totalXpEarned: null == totalXpEarned ? _self.totalXpEarned : totalXpEarned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GuideTopicsResponse].
extension GuideTopicsResponsePatterns on GuideTopicsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuideTopicsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuideTopicsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuideTopicsResponse value)  $default,){
final _that = this;
switch (_that) {
case _GuideTopicsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuideTopicsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GuideTopicsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GuideTopic> topics,  int completedCount,  int totalCount,  List<String> completedGuideIds,  int totalXpEarned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuideTopicsResponse() when $default != null:
return $default(_that.topics,_that.completedCount,_that.totalCount,_that.completedGuideIds,_that.totalXpEarned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GuideTopic> topics,  int completedCount,  int totalCount,  List<String> completedGuideIds,  int totalXpEarned)  $default,) {final _that = this;
switch (_that) {
case _GuideTopicsResponse():
return $default(_that.topics,_that.completedCount,_that.totalCount,_that.completedGuideIds,_that.totalXpEarned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GuideTopic> topics,  int completedCount,  int totalCount,  List<String> completedGuideIds,  int totalXpEarned)?  $default,) {final _that = this;
switch (_that) {
case _GuideTopicsResponse() when $default != null:
return $default(_that.topics,_that.completedCount,_that.totalCount,_that.completedGuideIds,_that.totalXpEarned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuideTopicsResponse implements GuideTopicsResponse {
  const _GuideTopicsResponse({final  List<GuideTopic> topics = const <GuideTopic>[], this.completedCount = 0, this.totalCount = 0, final  List<String> completedGuideIds = const <String>[], this.totalXpEarned = 0}): _topics = topics,_completedGuideIds = completedGuideIds;
  factory _GuideTopicsResponse.fromJson(Map<String, dynamic> json) => _$GuideTopicsResponseFromJson(json);

 final  List<GuideTopic> _topics;
@override@JsonKey() List<GuideTopic> get topics {
  if (_topics is EqualUnmodifiableListView) return _topics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topics);
}

@override@JsonKey() final  int completedCount;
@override@JsonKey() final  int totalCount;
 final  List<String> _completedGuideIds;
@override@JsonKey() List<String> get completedGuideIds {
  if (_completedGuideIds is EqualUnmodifiableListView) return _completedGuideIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedGuideIds);
}

@override@JsonKey() final  int totalXpEarned;

/// Create a copy of GuideTopicsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuideTopicsResponseCopyWith<_GuideTopicsResponse> get copyWith => __$GuideTopicsResponseCopyWithImpl<_GuideTopicsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuideTopicsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuideTopicsResponse&&const DeepCollectionEquality().equals(other._topics, _topics)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other._completedGuideIds, _completedGuideIds)&&(identical(other.totalXpEarned, totalXpEarned) || other.totalXpEarned == totalXpEarned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_topics),completedCount,totalCount,const DeepCollectionEquality().hash(_completedGuideIds),totalXpEarned);

@override
String toString() {
  return 'GuideTopicsResponse(topics: $topics, completedCount: $completedCount, totalCount: $totalCount, completedGuideIds: $completedGuideIds, totalXpEarned: $totalXpEarned)';
}


}

/// @nodoc
abstract mixin class _$GuideTopicsResponseCopyWith<$Res> implements $GuideTopicsResponseCopyWith<$Res> {
  factory _$GuideTopicsResponseCopyWith(_GuideTopicsResponse value, $Res Function(_GuideTopicsResponse) _then) = __$GuideTopicsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<GuideTopic> topics, int completedCount, int totalCount, List<String> completedGuideIds, int totalXpEarned
});




}
/// @nodoc
class __$GuideTopicsResponseCopyWithImpl<$Res>
    implements _$GuideTopicsResponseCopyWith<$Res> {
  __$GuideTopicsResponseCopyWithImpl(this._self, this._then);

  final _GuideTopicsResponse _self;
  final $Res Function(_GuideTopicsResponse) _then;

/// Create a copy of GuideTopicsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topics = null,Object? completedCount = null,Object? totalCount = null,Object? completedGuideIds = null,Object? totalXpEarned = null,}) {
  return _then(_GuideTopicsResponse(
topics: null == topics ? _self._topics : topics // ignore: cast_nullable_to_non_nullable
as List<GuideTopic>,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,completedGuideIds: null == completedGuideIds ? _self._completedGuideIds : completedGuideIds // ignore: cast_nullable_to_non_nullable
as List<String>,totalXpEarned: null == totalXpEarned ? _self.totalXpEarned : totalXpEarned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GuideTopic {

 String get id; String get slug; String get name; String? get description; String? get icon; String? get color; int get sortOrder; List<GuideListItem> get guides; int get completedCount; int get totalCount;
/// Create a copy of GuideTopic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuideTopicCopyWith<GuideTopic> get copyWith => _$GuideTopicCopyWithImpl<GuideTopic>(this as GuideTopic, _$identity);

  /// Serializes this GuideTopic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuideTopic&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other.guides, guides)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,icon,color,sortOrder,const DeepCollectionEquality().hash(guides),completedCount,totalCount);

@override
String toString() {
  return 'GuideTopic(id: $id, slug: $slug, name: $name, description: $description, icon: $icon, color: $color, sortOrder: $sortOrder, guides: $guides, completedCount: $completedCount, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $GuideTopicCopyWith<$Res>  {
  factory $GuideTopicCopyWith(GuideTopic value, $Res Function(GuideTopic) _then) = _$GuideTopicCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String name, String? description, String? icon, String? color, int sortOrder, List<GuideListItem> guides, int completedCount, int totalCount
});




}
/// @nodoc
class _$GuideTopicCopyWithImpl<$Res>
    implements $GuideTopicCopyWith<$Res> {
  _$GuideTopicCopyWithImpl(this._self, this._then);

  final GuideTopic _self;
  final $Res Function(GuideTopic) _then;

/// Create a copy of GuideTopic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = freezed,Object? icon = freezed,Object? color = freezed,Object? sortOrder = null,Object? guides = null,Object? completedCount = null,Object? totalCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,guides: null == guides ? _self.guides : guides // ignore: cast_nullable_to_non_nullable
as List<GuideListItem>,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GuideTopic].
extension GuideTopicPatterns on GuideTopic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuideTopic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuideTopic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuideTopic value)  $default,){
final _that = this;
switch (_that) {
case _GuideTopic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuideTopic value)?  $default,){
final _that = this;
switch (_that) {
case _GuideTopic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String? description,  String? icon,  String? color,  int sortOrder,  List<GuideListItem> guides,  int completedCount,  int totalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuideTopic() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.icon,_that.color,_that.sortOrder,_that.guides,_that.completedCount,_that.totalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String? description,  String? icon,  String? color,  int sortOrder,  List<GuideListItem> guides,  int completedCount,  int totalCount)  $default,) {final _that = this;
switch (_that) {
case _GuideTopic():
return $default(_that.id,_that.slug,_that.name,_that.description,_that.icon,_that.color,_that.sortOrder,_that.guides,_that.completedCount,_that.totalCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String name,  String? description,  String? icon,  String? color,  int sortOrder,  List<GuideListItem> guides,  int completedCount,  int totalCount)?  $default,) {final _that = this;
switch (_that) {
case _GuideTopic() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.icon,_that.color,_that.sortOrder,_that.guides,_that.completedCount,_that.totalCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuideTopic extends GuideTopic {
  const _GuideTopic({required this.id, required this.slug, required this.name, this.description, this.icon, this.color, this.sortOrder = 0, final  List<GuideListItem> guides = const <GuideListItem>[], this.completedCount = 0, this.totalCount = 0}): _guides = guides,super._();
  factory _GuideTopic.fromJson(Map<String, dynamic> json) => _$GuideTopicFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String name;
@override final  String? description;
@override final  String? icon;
@override final  String? color;
@override@JsonKey() final  int sortOrder;
 final  List<GuideListItem> _guides;
@override@JsonKey() List<GuideListItem> get guides {
  if (_guides is EqualUnmodifiableListView) return _guides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_guides);
}

@override@JsonKey() final  int completedCount;
@override@JsonKey() final  int totalCount;

/// Create a copy of GuideTopic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuideTopicCopyWith<_GuideTopic> get copyWith => __$GuideTopicCopyWithImpl<_GuideTopic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuideTopicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuideTopic&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other._guides, _guides)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,icon,color,sortOrder,const DeepCollectionEquality().hash(_guides),completedCount,totalCount);

@override
String toString() {
  return 'GuideTopic(id: $id, slug: $slug, name: $name, description: $description, icon: $icon, color: $color, sortOrder: $sortOrder, guides: $guides, completedCount: $completedCount, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class _$GuideTopicCopyWith<$Res> implements $GuideTopicCopyWith<$Res> {
  factory _$GuideTopicCopyWith(_GuideTopic value, $Res Function(_GuideTopic) _then) = __$GuideTopicCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String name, String? description, String? icon, String? color, int sortOrder, List<GuideListItem> guides, int completedCount, int totalCount
});




}
/// @nodoc
class __$GuideTopicCopyWithImpl<$Res>
    implements _$GuideTopicCopyWith<$Res> {
  __$GuideTopicCopyWithImpl(this._self, this._then);

  final _GuideTopic _self;
  final $Res Function(_GuideTopic) _then;

/// Create a copy of GuideTopic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = freezed,Object? icon = freezed,Object? color = freezed,Object? sortOrder = null,Object? guides = null,Object? completedCount = null,Object? totalCount = null,}) {
  return _then(_GuideTopic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,guides: null == guides ? _self._guides : guides // ignore: cast_nullable_to_non_nullable
as List<GuideListItem>,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GuideListItem {

 String get id; String get slug; String get title; String? get summary; int get xpReward; int get sortOrder; bool get completed;
/// Create a copy of GuideListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuideListItemCopyWith<GuideListItem> get copyWith => _$GuideListItemCopyWithImpl<GuideListItem>(this as GuideListItem, _$identity);

  /// Serializes this GuideListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuideListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,summary,xpReward,sortOrder,completed);

@override
String toString() {
  return 'GuideListItem(id: $id, slug: $slug, title: $title, summary: $summary, xpReward: $xpReward, sortOrder: $sortOrder, completed: $completed)';
}


}

/// @nodoc
abstract mixin class $GuideListItemCopyWith<$Res>  {
  factory $GuideListItemCopyWith(GuideListItem value, $Res Function(GuideListItem) _then) = _$GuideListItemCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String title, String? summary, int xpReward, int sortOrder, bool completed
});




}
/// @nodoc
class _$GuideListItemCopyWithImpl<$Res>
    implements $GuideListItemCopyWith<$Res> {
  _$GuideListItemCopyWithImpl(this._self, this._then);

  final GuideListItem _self;
  final $Res Function(GuideListItem) _then;

/// Create a copy of GuideListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? summary = freezed,Object? xpReward = null,Object? sortOrder = null,Object? completed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GuideListItem].
extension GuideListItemPatterns on GuideListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuideListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuideListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuideListItem value)  $default,){
final _that = this;
switch (_that) {
case _GuideListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuideListItem value)?  $default,){
final _that = this;
switch (_that) {
case _GuideListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? summary,  int xpReward,  int sortOrder,  bool completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuideListItem() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.summary,_that.xpReward,_that.sortOrder,_that.completed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? summary,  int xpReward,  int sortOrder,  bool completed)  $default,) {final _that = this;
switch (_that) {
case _GuideListItem():
return $default(_that.id,_that.slug,_that.title,_that.summary,_that.xpReward,_that.sortOrder,_that.completed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String title,  String? summary,  int xpReward,  int sortOrder,  bool completed)?  $default,) {final _that = this;
switch (_that) {
case _GuideListItem() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.summary,_that.xpReward,_that.sortOrder,_that.completed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuideListItem implements GuideListItem {
  const _GuideListItem({required this.id, required this.slug, required this.title, this.summary, this.xpReward = 10, this.sortOrder = 0, this.completed = false});
  factory _GuideListItem.fromJson(Map<String, dynamic> json) => _$GuideListItemFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String title;
@override final  String? summary;
@override@JsonKey() final  int xpReward;
@override@JsonKey() final  int sortOrder;
@override@JsonKey() final  bool completed;

/// Create a copy of GuideListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuideListItemCopyWith<_GuideListItem> get copyWith => __$GuideListItemCopyWithImpl<_GuideListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuideListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuideListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,summary,xpReward,sortOrder,completed);

@override
String toString() {
  return 'GuideListItem(id: $id, slug: $slug, title: $title, summary: $summary, xpReward: $xpReward, sortOrder: $sortOrder, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$GuideListItemCopyWith<$Res> implements $GuideListItemCopyWith<$Res> {
  factory _$GuideListItemCopyWith(_GuideListItem value, $Res Function(_GuideListItem) _then) = __$GuideListItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String title, String? summary, int xpReward, int sortOrder, bool completed
});




}
/// @nodoc
class __$GuideListItemCopyWithImpl<$Res>
    implements _$GuideListItemCopyWith<$Res> {
  __$GuideListItemCopyWithImpl(this._self, this._then);

  final _GuideListItem _self;
  final $Res Function(_GuideListItem) _then;

/// Create a copy of GuideListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? summary = freezed,Object? xpReward = null,Object? sortOrder = null,Object? completed = null,}) {
  return _then(_GuideListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$GuideStep {

 String get title; String get body;
/// Create a copy of GuideStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuideStepCopyWith<GuideStep> get copyWith => _$GuideStepCopyWithImpl<GuideStep>(this as GuideStep, _$identity);

  /// Serializes this GuideStep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuideStep&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body);

@override
String toString() {
  return 'GuideStep(title: $title, body: $body)';
}


}

/// @nodoc
abstract mixin class $GuideStepCopyWith<$Res>  {
  factory $GuideStepCopyWith(GuideStep value, $Res Function(GuideStep) _then) = _$GuideStepCopyWithImpl;
@useResult
$Res call({
 String title, String body
});




}
/// @nodoc
class _$GuideStepCopyWithImpl<$Res>
    implements $GuideStepCopyWith<$Res> {
  _$GuideStepCopyWithImpl(this._self, this._then);

  final GuideStep _self;
  final $Res Function(GuideStep) _then;

/// Create a copy of GuideStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? body = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GuideStep].
extension GuideStepPatterns on GuideStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuideStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuideStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuideStep value)  $default,){
final _that = this;
switch (_that) {
case _GuideStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuideStep value)?  $default,){
final _that = this;
switch (_that) {
case _GuideStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuideStep() when $default != null:
return $default(_that.title,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String body)  $default,) {final _that = this;
switch (_that) {
case _GuideStep():
return $default(_that.title,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String body)?  $default,) {final _that = this;
switch (_that) {
case _GuideStep() when $default != null:
return $default(_that.title,_that.body);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuideStep implements GuideStep {
  const _GuideStep({required this.title, required this.body});
  factory _GuideStep.fromJson(Map<String, dynamic> json) => _$GuideStepFromJson(json);

@override final  String title;
@override final  String body;

/// Create a copy of GuideStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuideStepCopyWith<_GuideStep> get copyWith => __$GuideStepCopyWithImpl<_GuideStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuideStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuideStep&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body);

@override
String toString() {
  return 'GuideStep(title: $title, body: $body)';
}


}

/// @nodoc
abstract mixin class _$GuideStepCopyWith<$Res> implements $GuideStepCopyWith<$Res> {
  factory _$GuideStepCopyWith(_GuideStep value, $Res Function(_GuideStep) _then) = __$GuideStepCopyWithImpl;
@override @useResult
$Res call({
 String title, String body
});




}
/// @nodoc
class __$GuideStepCopyWithImpl<$Res>
    implements _$GuideStepCopyWith<$Res> {
  __$GuideStepCopyWithImpl(this._self, this._then);

  final _GuideStep _self;
  final $Res Function(_GuideStep) _then;

/// Create a copy of GuideStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? body = null,}) {
  return _then(_GuideStep(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GuideSections {

 List<GuideStep> get before; List<GuideStep> get during; List<GuideStep> get after;
/// Create a copy of GuideSections
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuideSectionsCopyWith<GuideSections> get copyWith => _$GuideSectionsCopyWithImpl<GuideSections>(this as GuideSections, _$identity);

  /// Serializes this GuideSections to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuideSections&&const DeepCollectionEquality().equals(other.before, before)&&const DeepCollectionEquality().equals(other.during, during)&&const DeepCollectionEquality().equals(other.after, after));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(before),const DeepCollectionEquality().hash(during),const DeepCollectionEquality().hash(after));

@override
String toString() {
  return 'GuideSections(before: $before, during: $during, after: $after)';
}


}

/// @nodoc
abstract mixin class $GuideSectionsCopyWith<$Res>  {
  factory $GuideSectionsCopyWith(GuideSections value, $Res Function(GuideSections) _then) = _$GuideSectionsCopyWithImpl;
@useResult
$Res call({
 List<GuideStep> before, List<GuideStep> during, List<GuideStep> after
});




}
/// @nodoc
class _$GuideSectionsCopyWithImpl<$Res>
    implements $GuideSectionsCopyWith<$Res> {
  _$GuideSectionsCopyWithImpl(this._self, this._then);

  final GuideSections _self;
  final $Res Function(GuideSections) _then;

/// Create a copy of GuideSections
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? before = null,Object? during = null,Object? after = null,}) {
  return _then(_self.copyWith(
before: null == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as List<GuideStep>,during: null == during ? _self.during : during // ignore: cast_nullable_to_non_nullable
as List<GuideStep>,after: null == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as List<GuideStep>,
  ));
}

}


/// Adds pattern-matching-related methods to [GuideSections].
extension GuideSectionsPatterns on GuideSections {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuideSections value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuideSections() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuideSections value)  $default,){
final _that = this;
switch (_that) {
case _GuideSections():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuideSections value)?  $default,){
final _that = this;
switch (_that) {
case _GuideSections() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GuideStep> before,  List<GuideStep> during,  List<GuideStep> after)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuideSections() when $default != null:
return $default(_that.before,_that.during,_that.after);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GuideStep> before,  List<GuideStep> during,  List<GuideStep> after)  $default,) {final _that = this;
switch (_that) {
case _GuideSections():
return $default(_that.before,_that.during,_that.after);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GuideStep> before,  List<GuideStep> during,  List<GuideStep> after)?  $default,) {final _that = this;
switch (_that) {
case _GuideSections() when $default != null:
return $default(_that.before,_that.during,_that.after);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuideSections implements GuideSections {
  const _GuideSections({final  List<GuideStep> before = const <GuideStep>[], final  List<GuideStep> during = const <GuideStep>[], final  List<GuideStep> after = const <GuideStep>[]}): _before = before,_during = during,_after = after;
  factory _GuideSections.fromJson(Map<String, dynamic> json) => _$GuideSectionsFromJson(json);

 final  List<GuideStep> _before;
@override@JsonKey() List<GuideStep> get before {
  if (_before is EqualUnmodifiableListView) return _before;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_before);
}

 final  List<GuideStep> _during;
@override@JsonKey() List<GuideStep> get during {
  if (_during is EqualUnmodifiableListView) return _during;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_during);
}

 final  List<GuideStep> _after;
@override@JsonKey() List<GuideStep> get after {
  if (_after is EqualUnmodifiableListView) return _after;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_after);
}


/// Create a copy of GuideSections
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuideSectionsCopyWith<_GuideSections> get copyWith => __$GuideSectionsCopyWithImpl<_GuideSections>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuideSectionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuideSections&&const DeepCollectionEquality().equals(other._before, _before)&&const DeepCollectionEquality().equals(other._during, _during)&&const DeepCollectionEquality().equals(other._after, _after));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_before),const DeepCollectionEquality().hash(_during),const DeepCollectionEquality().hash(_after));

@override
String toString() {
  return 'GuideSections(before: $before, during: $during, after: $after)';
}


}

/// @nodoc
abstract mixin class _$GuideSectionsCopyWith<$Res> implements $GuideSectionsCopyWith<$Res> {
  factory _$GuideSectionsCopyWith(_GuideSections value, $Res Function(_GuideSections) _then) = __$GuideSectionsCopyWithImpl;
@override @useResult
$Res call({
 List<GuideStep> before, List<GuideStep> during, List<GuideStep> after
});




}
/// @nodoc
class __$GuideSectionsCopyWithImpl<$Res>
    implements _$GuideSectionsCopyWith<$Res> {
  __$GuideSectionsCopyWithImpl(this._self, this._then);

  final _GuideSections _self;
  final $Res Function(_GuideSections) _then;

/// Create a copy of GuideSections
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? before = null,Object? during = null,Object? after = null,}) {
  return _then(_GuideSections(
before: null == before ? _self._before : before // ignore: cast_nullable_to_non_nullable
as List<GuideStep>,during: null == during ? _self._during : during // ignore: cast_nullable_to_non_nullable
as List<GuideStep>,after: null == after ? _self._after : after // ignore: cast_nullable_to_non_nullable
as List<GuideStep>,
  ));
}


}


/// @nodoc
mixin _$GuideDetail {

 String get id; String get slug; String get title; String? get summary; GuideSections get sections; String? get sourceName; String? get sourceUrl; String? get sourceNote; int get xpReward; List<String> get categoryIds; bool get completed; DateTime? get completedAt;
/// Create a copy of GuideDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuideDetailCopyWith<GuideDetail> get copyWith => _$GuideDetailCopyWithImpl<GuideDetail>(this as GuideDetail, _$identity);

  /// Serializes this GuideDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuideDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.sections, sections) || other.sections == sections)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.sourceNote, sourceNote) || other.sourceNote == sourceNote)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,summary,sections,sourceName,sourceUrl,sourceNote,xpReward,const DeepCollectionEquality().hash(categoryIds),completed,completedAt);

@override
String toString() {
  return 'GuideDetail(id: $id, slug: $slug, title: $title, summary: $summary, sections: $sections, sourceName: $sourceName, sourceUrl: $sourceUrl, sourceNote: $sourceNote, xpReward: $xpReward, categoryIds: $categoryIds, completed: $completed, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $GuideDetailCopyWith<$Res>  {
  factory $GuideDetailCopyWith(GuideDetail value, $Res Function(GuideDetail) _then) = _$GuideDetailCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String title, String? summary, GuideSections sections, String? sourceName, String? sourceUrl, String? sourceNote, int xpReward, List<String> categoryIds, bool completed, DateTime? completedAt
});


$GuideSectionsCopyWith<$Res> get sections;

}
/// @nodoc
class _$GuideDetailCopyWithImpl<$Res>
    implements $GuideDetailCopyWith<$Res> {
  _$GuideDetailCopyWithImpl(this._self, this._then);

  final GuideDetail _self;
  final $Res Function(GuideDetail) _then;

/// Create a copy of GuideDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? summary = freezed,Object? sections = null,Object? sourceName = freezed,Object? sourceUrl = freezed,Object? sourceNote = freezed,Object? xpReward = null,Object? categoryIds = null,Object? completed = null,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as GuideSections,sourceName: freezed == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,sourceNote: freezed == sourceNote ? _self.sourceNote : sourceNote // ignore: cast_nullable_to_non_nullable
as String?,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of GuideDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuideSectionsCopyWith<$Res> get sections {
  
  return $GuideSectionsCopyWith<$Res>(_self.sections, (value) {
    return _then(_self.copyWith(sections: value));
  });
}
}


/// Adds pattern-matching-related methods to [GuideDetail].
extension GuideDetailPatterns on GuideDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuideDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuideDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuideDetail value)  $default,){
final _that = this;
switch (_that) {
case _GuideDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuideDetail value)?  $default,){
final _that = this;
switch (_that) {
case _GuideDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? summary,  GuideSections sections,  String? sourceName,  String? sourceUrl,  String? sourceNote,  int xpReward,  List<String> categoryIds,  bool completed,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuideDetail() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.summary,_that.sections,_that.sourceName,_that.sourceUrl,_that.sourceNote,_that.xpReward,_that.categoryIds,_that.completed,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? summary,  GuideSections sections,  String? sourceName,  String? sourceUrl,  String? sourceNote,  int xpReward,  List<String> categoryIds,  bool completed,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _GuideDetail():
return $default(_that.id,_that.slug,_that.title,_that.summary,_that.sections,_that.sourceName,_that.sourceUrl,_that.sourceNote,_that.xpReward,_that.categoryIds,_that.completed,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String title,  String? summary,  GuideSections sections,  String? sourceName,  String? sourceUrl,  String? sourceNote,  int xpReward,  List<String> categoryIds,  bool completed,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _GuideDetail() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.summary,_that.sections,_that.sourceName,_that.sourceUrl,_that.sourceNote,_that.xpReward,_that.categoryIds,_that.completed,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuideDetail implements GuideDetail {
  const _GuideDetail({required this.id, required this.slug, required this.title, this.summary, required this.sections, this.sourceName, this.sourceUrl, this.sourceNote, this.xpReward = 10, final  List<String> categoryIds = const <String>[], this.completed = false, this.completedAt}): _categoryIds = categoryIds;
  factory _GuideDetail.fromJson(Map<String, dynamic> json) => _$GuideDetailFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String title;
@override final  String? summary;
@override final  GuideSections sections;
@override final  String? sourceName;
@override final  String? sourceUrl;
@override final  String? sourceNote;
@override@JsonKey() final  int xpReward;
 final  List<String> _categoryIds;
@override@JsonKey() List<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryIds);
}

@override@JsonKey() final  bool completed;
@override final  DateTime? completedAt;

/// Create a copy of GuideDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuideDetailCopyWith<_GuideDetail> get copyWith => __$GuideDetailCopyWithImpl<_GuideDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuideDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuideDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.sections, sections) || other.sections == sections)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.sourceNote, sourceNote) || other.sourceNote == sourceNote)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&const DeepCollectionEquality().equals(other._categoryIds, _categoryIds)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,summary,sections,sourceName,sourceUrl,sourceNote,xpReward,const DeepCollectionEquality().hash(_categoryIds),completed,completedAt);

@override
String toString() {
  return 'GuideDetail(id: $id, slug: $slug, title: $title, summary: $summary, sections: $sections, sourceName: $sourceName, sourceUrl: $sourceUrl, sourceNote: $sourceNote, xpReward: $xpReward, categoryIds: $categoryIds, completed: $completed, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$GuideDetailCopyWith<$Res> implements $GuideDetailCopyWith<$Res> {
  factory _$GuideDetailCopyWith(_GuideDetail value, $Res Function(_GuideDetail) _then) = __$GuideDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String title, String? summary, GuideSections sections, String? sourceName, String? sourceUrl, String? sourceNote, int xpReward, List<String> categoryIds, bool completed, DateTime? completedAt
});


@override $GuideSectionsCopyWith<$Res> get sections;

}
/// @nodoc
class __$GuideDetailCopyWithImpl<$Res>
    implements _$GuideDetailCopyWith<$Res> {
  __$GuideDetailCopyWithImpl(this._self, this._then);

  final _GuideDetail _self;
  final $Res Function(_GuideDetail) _then;

/// Create a copy of GuideDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? summary = freezed,Object? sections = null,Object? sourceName = freezed,Object? sourceUrl = freezed,Object? sourceNote = freezed,Object? xpReward = null,Object? categoryIds = null,Object? completed = null,Object? completedAt = freezed,}) {
  return _then(_GuideDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as GuideSections,sourceName: freezed == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,sourceNote: freezed == sourceNote ? _self.sourceNote : sourceNote // ignore: cast_nullable_to_non_nullable
as String?,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of GuideDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuideSectionsCopyWith<$Res> get sections {
  
  return $GuideSectionsCopyWith<$Res>(_self.sections, (value) {
    return _then(_self.copyWith(sections: value));
  });
}
}


/// @nodoc
mixin _$GuideCompletionResponse {

 bool get alreadyCompleted; int get xpAwarded; int get newXpTotal;
/// Create a copy of GuideCompletionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuideCompletionResponseCopyWith<GuideCompletionResponse> get copyWith => _$GuideCompletionResponseCopyWithImpl<GuideCompletionResponse>(this as GuideCompletionResponse, _$identity);

  /// Serializes this GuideCompletionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuideCompletionResponse&&(identical(other.alreadyCompleted, alreadyCompleted) || other.alreadyCompleted == alreadyCompleted)&&(identical(other.xpAwarded, xpAwarded) || other.xpAwarded == xpAwarded)&&(identical(other.newXpTotal, newXpTotal) || other.newXpTotal == newXpTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,alreadyCompleted,xpAwarded,newXpTotal);

@override
String toString() {
  return 'GuideCompletionResponse(alreadyCompleted: $alreadyCompleted, xpAwarded: $xpAwarded, newXpTotal: $newXpTotal)';
}


}

/// @nodoc
abstract mixin class $GuideCompletionResponseCopyWith<$Res>  {
  factory $GuideCompletionResponseCopyWith(GuideCompletionResponse value, $Res Function(GuideCompletionResponse) _then) = _$GuideCompletionResponseCopyWithImpl;
@useResult
$Res call({
 bool alreadyCompleted, int xpAwarded, int newXpTotal
});




}
/// @nodoc
class _$GuideCompletionResponseCopyWithImpl<$Res>
    implements $GuideCompletionResponseCopyWith<$Res> {
  _$GuideCompletionResponseCopyWithImpl(this._self, this._then);

  final GuideCompletionResponse _self;
  final $Res Function(GuideCompletionResponse) _then;

/// Create a copy of GuideCompletionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? alreadyCompleted = null,Object? xpAwarded = null,Object? newXpTotal = null,}) {
  return _then(_self.copyWith(
alreadyCompleted: null == alreadyCompleted ? _self.alreadyCompleted : alreadyCompleted // ignore: cast_nullable_to_non_nullable
as bool,xpAwarded: null == xpAwarded ? _self.xpAwarded : xpAwarded // ignore: cast_nullable_to_non_nullable
as int,newXpTotal: null == newXpTotal ? _self.newXpTotal : newXpTotal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GuideCompletionResponse].
extension GuideCompletionResponsePatterns on GuideCompletionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuideCompletionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuideCompletionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuideCompletionResponse value)  $default,){
final _that = this;
switch (_that) {
case _GuideCompletionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuideCompletionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GuideCompletionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool alreadyCompleted,  int xpAwarded,  int newXpTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuideCompletionResponse() when $default != null:
return $default(_that.alreadyCompleted,_that.xpAwarded,_that.newXpTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool alreadyCompleted,  int xpAwarded,  int newXpTotal)  $default,) {final _that = this;
switch (_that) {
case _GuideCompletionResponse():
return $default(_that.alreadyCompleted,_that.xpAwarded,_that.newXpTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool alreadyCompleted,  int xpAwarded,  int newXpTotal)?  $default,) {final _that = this;
switch (_that) {
case _GuideCompletionResponse() when $default != null:
return $default(_that.alreadyCompleted,_that.xpAwarded,_that.newXpTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuideCompletionResponse implements GuideCompletionResponse {
  const _GuideCompletionResponse({this.alreadyCompleted = false, this.xpAwarded = 0, this.newXpTotal = 0});
  factory _GuideCompletionResponse.fromJson(Map<String, dynamic> json) => _$GuideCompletionResponseFromJson(json);

@override@JsonKey() final  bool alreadyCompleted;
@override@JsonKey() final  int xpAwarded;
@override@JsonKey() final  int newXpTotal;

/// Create a copy of GuideCompletionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuideCompletionResponseCopyWith<_GuideCompletionResponse> get copyWith => __$GuideCompletionResponseCopyWithImpl<_GuideCompletionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuideCompletionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuideCompletionResponse&&(identical(other.alreadyCompleted, alreadyCompleted) || other.alreadyCompleted == alreadyCompleted)&&(identical(other.xpAwarded, xpAwarded) || other.xpAwarded == xpAwarded)&&(identical(other.newXpTotal, newXpTotal) || other.newXpTotal == newXpTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,alreadyCompleted,xpAwarded,newXpTotal);

@override
String toString() {
  return 'GuideCompletionResponse(alreadyCompleted: $alreadyCompleted, xpAwarded: $xpAwarded, newXpTotal: $newXpTotal)';
}


}

/// @nodoc
abstract mixin class _$GuideCompletionResponseCopyWith<$Res> implements $GuideCompletionResponseCopyWith<$Res> {
  factory _$GuideCompletionResponseCopyWith(_GuideCompletionResponse value, $Res Function(_GuideCompletionResponse) _then) = __$GuideCompletionResponseCopyWithImpl;
@override @useResult
$Res call({
 bool alreadyCompleted, int xpAwarded, int newXpTotal
});




}
/// @nodoc
class __$GuideCompletionResponseCopyWithImpl<$Res>
    implements _$GuideCompletionResponseCopyWith<$Res> {
  __$GuideCompletionResponseCopyWithImpl(this._self, this._then);

  final _GuideCompletionResponse _self;
  final $Res Function(_GuideCompletionResponse) _then;

/// Create a copy of GuideCompletionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? alreadyCompleted = null,Object? xpAwarded = null,Object? newXpTotal = null,}) {
  return _then(_GuideCompletionResponse(
alreadyCompleted: null == alreadyCompleted ? _self.alreadyCompleted : alreadyCompleted // ignore: cast_nullable_to_non_nullable
as bool,xpAwarded: null == xpAwarded ? _self.xpAwarded : xpAwarded // ignore: cast_nullable_to_non_nullable
as int,newXpTotal: null == newXpTotal ? _self.newXpTotal : newXpTotal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GuideForCategory {

 String get id; String get slug; String get title; GuideForCategoryTopic? get topic;
/// Create a copy of GuideForCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuideForCategoryCopyWith<GuideForCategory> get copyWith => _$GuideForCategoryCopyWithImpl<GuideForCategory>(this as GuideForCategory, _$identity);

  /// Serializes this GuideForCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuideForCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.topic, topic) || other.topic == topic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,topic);

@override
String toString() {
  return 'GuideForCategory(id: $id, slug: $slug, title: $title, topic: $topic)';
}


}

/// @nodoc
abstract mixin class $GuideForCategoryCopyWith<$Res>  {
  factory $GuideForCategoryCopyWith(GuideForCategory value, $Res Function(GuideForCategory) _then) = _$GuideForCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String title, GuideForCategoryTopic? topic
});


$GuideForCategoryTopicCopyWith<$Res>? get topic;

}
/// @nodoc
class _$GuideForCategoryCopyWithImpl<$Res>
    implements $GuideForCategoryCopyWith<$Res> {
  _$GuideForCategoryCopyWithImpl(this._self, this._then);

  final GuideForCategory _self;
  final $Res Function(GuideForCategory) _then;

/// Create a copy of GuideForCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? topic = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as GuideForCategoryTopic?,
  ));
}
/// Create a copy of GuideForCategory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuideForCategoryTopicCopyWith<$Res>? get topic {
    if (_self.topic == null) {
    return null;
  }

  return $GuideForCategoryTopicCopyWith<$Res>(_self.topic!, (value) {
    return _then(_self.copyWith(topic: value));
  });
}
}


/// Adds pattern-matching-related methods to [GuideForCategory].
extension GuideForCategoryPatterns on GuideForCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuideForCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuideForCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuideForCategory value)  $default,){
final _that = this;
switch (_that) {
case _GuideForCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuideForCategory value)?  $default,){
final _that = this;
switch (_that) {
case _GuideForCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  GuideForCategoryTopic? topic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuideForCategory() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.topic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  GuideForCategoryTopic? topic)  $default,) {final _that = this;
switch (_that) {
case _GuideForCategory():
return $default(_that.id,_that.slug,_that.title,_that.topic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String title,  GuideForCategoryTopic? topic)?  $default,) {final _that = this;
switch (_that) {
case _GuideForCategory() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.topic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuideForCategory implements GuideForCategory {
  const _GuideForCategory({required this.id, required this.slug, required this.title, this.topic});
  factory _GuideForCategory.fromJson(Map<String, dynamic> json) => _$GuideForCategoryFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String title;
@override final  GuideForCategoryTopic? topic;

/// Create a copy of GuideForCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuideForCategoryCopyWith<_GuideForCategory> get copyWith => __$GuideForCategoryCopyWithImpl<_GuideForCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuideForCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuideForCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.topic, topic) || other.topic == topic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,topic);

@override
String toString() {
  return 'GuideForCategory(id: $id, slug: $slug, title: $title, topic: $topic)';
}


}

/// @nodoc
abstract mixin class _$GuideForCategoryCopyWith<$Res> implements $GuideForCategoryCopyWith<$Res> {
  factory _$GuideForCategoryCopyWith(_GuideForCategory value, $Res Function(_GuideForCategory) _then) = __$GuideForCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String title, GuideForCategoryTopic? topic
});


@override $GuideForCategoryTopicCopyWith<$Res>? get topic;

}
/// @nodoc
class __$GuideForCategoryCopyWithImpl<$Res>
    implements _$GuideForCategoryCopyWith<$Res> {
  __$GuideForCategoryCopyWithImpl(this._self, this._then);

  final _GuideForCategory _self;
  final $Res Function(_GuideForCategory) _then;

/// Create a copy of GuideForCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? topic = freezed,}) {
  return _then(_GuideForCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as GuideForCategoryTopic?,
  ));
}

/// Create a copy of GuideForCategory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuideForCategoryTopicCopyWith<$Res>? get topic {
    if (_self.topic == null) {
    return null;
  }

  return $GuideForCategoryTopicCopyWith<$Res>(_self.topic!, (value) {
    return _then(_self.copyWith(topic: value));
  });
}
}


/// @nodoc
mixin _$GuideForCategoryTopic {

 String? get name; String? get icon; String? get color;
/// Create a copy of GuideForCategoryTopic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuideForCategoryTopicCopyWith<GuideForCategoryTopic> get copyWith => _$GuideForCategoryTopicCopyWithImpl<GuideForCategoryTopic>(this as GuideForCategoryTopic, _$identity);

  /// Serializes this GuideForCategoryTopic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuideForCategoryTopic&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,icon,color);

@override
String toString() {
  return 'GuideForCategoryTopic(name: $name, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $GuideForCategoryTopicCopyWith<$Res>  {
  factory $GuideForCategoryTopicCopyWith(GuideForCategoryTopic value, $Res Function(GuideForCategoryTopic) _then) = _$GuideForCategoryTopicCopyWithImpl;
@useResult
$Res call({
 String? name, String? icon, String? color
});




}
/// @nodoc
class _$GuideForCategoryTopicCopyWithImpl<$Res>
    implements $GuideForCategoryTopicCopyWith<$Res> {
  _$GuideForCategoryTopicCopyWithImpl(this._self, this._then);

  final GuideForCategoryTopic _self;
  final $Res Function(GuideForCategoryTopic) _then;

/// Create a copy of GuideForCategoryTopic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GuideForCategoryTopic].
extension GuideForCategoryTopicPatterns on GuideForCategoryTopic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuideForCategoryTopic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuideForCategoryTopic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuideForCategoryTopic value)  $default,){
final _that = this;
switch (_that) {
case _GuideForCategoryTopic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuideForCategoryTopic value)?  $default,){
final _that = this;
switch (_that) {
case _GuideForCategoryTopic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? icon,  String? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuideForCategoryTopic() when $default != null:
return $default(_that.name,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? icon,  String? color)  $default,) {final _that = this;
switch (_that) {
case _GuideForCategoryTopic():
return $default(_that.name,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? icon,  String? color)?  $default,) {final _that = this;
switch (_that) {
case _GuideForCategoryTopic() when $default != null:
return $default(_that.name,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuideForCategoryTopic implements GuideForCategoryTopic {
  const _GuideForCategoryTopic({this.name, this.icon, this.color});
  factory _GuideForCategoryTopic.fromJson(Map<String, dynamic> json) => _$GuideForCategoryTopicFromJson(json);

@override final  String? name;
@override final  String? icon;
@override final  String? color;

/// Create a copy of GuideForCategoryTopic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuideForCategoryTopicCopyWith<_GuideForCategoryTopic> get copyWith => __$GuideForCategoryTopicCopyWithImpl<_GuideForCategoryTopic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuideForCategoryTopicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuideForCategoryTopic&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,icon,color);

@override
String toString() {
  return 'GuideForCategoryTopic(name: $name, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$GuideForCategoryTopicCopyWith<$Res> implements $GuideForCategoryTopicCopyWith<$Res> {
  factory _$GuideForCategoryTopicCopyWith(_GuideForCategoryTopic value, $Res Function(_GuideForCategoryTopic) _then) = __$GuideForCategoryTopicCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? icon, String? color
});




}
/// @nodoc
class __$GuideForCategoryTopicCopyWithImpl<$Res>
    implements _$GuideForCategoryTopicCopyWith<$Res> {
  __$GuideForCategoryTopicCopyWithImpl(this._self, this._then);

  final _GuideForCategoryTopic _self;
  final $Res Function(_GuideForCategoryTopic) _then;

/// Create a copy of GuideForCategoryTopic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_GuideForCategoryTopic(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
