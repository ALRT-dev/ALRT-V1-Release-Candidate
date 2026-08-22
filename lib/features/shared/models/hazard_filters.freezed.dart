// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hazard_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HazardFilters {

/// List of hazard category filters
 List<HazardCategory> get categoryFilters;/// List of hazard severity filters for AWS hazards
 List<HazardSeverityWithCount> get severityFiltersAws;/// List of hazard severity filters for non-AWS hazards
 List<HazardSeverityWithCount> get severityFiltersNonAws;
/// Create a copy of HazardFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HazardFiltersCopyWith<HazardFilters> get copyWith => _$HazardFiltersCopyWithImpl<HazardFilters>(this as HazardFilters, _$identity);

  /// Serializes this HazardFilters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HazardFilters&&const DeepCollectionEquality().equals(other.categoryFilters, categoryFilters)&&const DeepCollectionEquality().equals(other.severityFiltersAws, severityFiltersAws)&&const DeepCollectionEquality().equals(other.severityFiltersNonAws, severityFiltersNonAws));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(categoryFilters),const DeepCollectionEquality().hash(severityFiltersAws),const DeepCollectionEquality().hash(severityFiltersNonAws));

@override
String toString() {
  return 'HazardFilters(categoryFilters: $categoryFilters, severityFiltersAws: $severityFiltersAws, severityFiltersNonAws: $severityFiltersNonAws)';
}


}

/// @nodoc
abstract mixin class $HazardFiltersCopyWith<$Res>  {
  factory $HazardFiltersCopyWith(HazardFilters value, $Res Function(HazardFilters) _then) = _$HazardFiltersCopyWithImpl;
@useResult
$Res call({
 List<HazardCategory> categoryFilters, List<HazardSeverityWithCount> severityFiltersAws, List<HazardSeverityWithCount> severityFiltersNonAws
});




}
/// @nodoc
class _$HazardFiltersCopyWithImpl<$Res>
    implements $HazardFiltersCopyWith<$Res> {
  _$HazardFiltersCopyWithImpl(this._self, this._then);

  final HazardFilters _self;
  final $Res Function(HazardFilters) _then;

/// Create a copy of HazardFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryFilters = null,Object? severityFiltersAws = null,Object? severityFiltersNonAws = null,}) {
  return _then(_self.copyWith(
categoryFilters: null == categoryFilters ? _self.categoryFilters : categoryFilters // ignore: cast_nullable_to_non_nullable
as List<HazardCategory>,severityFiltersAws: null == severityFiltersAws ? _self.severityFiltersAws : severityFiltersAws // ignore: cast_nullable_to_non_nullable
as List<HazardSeverityWithCount>,severityFiltersNonAws: null == severityFiltersNonAws ? _self.severityFiltersNonAws : severityFiltersNonAws // ignore: cast_nullable_to_non_nullable
as List<HazardSeverityWithCount>,
  ));
}

}


/// Adds pattern-matching-related methods to [HazardFilters].
extension HazardFiltersPatterns on HazardFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HazardFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HazardFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HazardFilters value)  $default,){
final _that = this;
switch (_that) {
case _HazardFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HazardFilters value)?  $default,){
final _that = this;
switch (_that) {
case _HazardFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HazardCategory> categoryFilters,  List<HazardSeverityWithCount> severityFiltersAws,  List<HazardSeverityWithCount> severityFiltersNonAws)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HazardFilters() when $default != null:
return $default(_that.categoryFilters,_that.severityFiltersAws,_that.severityFiltersNonAws);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HazardCategory> categoryFilters,  List<HazardSeverityWithCount> severityFiltersAws,  List<HazardSeverityWithCount> severityFiltersNonAws)  $default,) {final _that = this;
switch (_that) {
case _HazardFilters():
return $default(_that.categoryFilters,_that.severityFiltersAws,_that.severityFiltersNonAws);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HazardCategory> categoryFilters,  List<HazardSeverityWithCount> severityFiltersAws,  List<HazardSeverityWithCount> severityFiltersNonAws)?  $default,) {final _that = this;
switch (_that) {
case _HazardFilters() when $default != null:
return $default(_that.categoryFilters,_that.severityFiltersAws,_that.severityFiltersNonAws);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HazardFilters implements HazardFilters {
  const _HazardFilters({final  List<HazardCategory> categoryFilters = const <HazardCategory>[], final  List<HazardSeverityWithCount> severityFiltersAws = const <HazardSeverityWithCount>[], final  List<HazardSeverityWithCount> severityFiltersNonAws = const <HazardSeverityWithCount>[]}): _categoryFilters = categoryFilters,_severityFiltersAws = severityFiltersAws,_severityFiltersNonAws = severityFiltersNonAws;
  factory _HazardFilters.fromJson(Map<String, dynamic> json) => _$HazardFiltersFromJson(json);

/// List of hazard category filters
 final  List<HazardCategory> _categoryFilters;
/// List of hazard category filters
@override@JsonKey() List<HazardCategory> get categoryFilters {
  if (_categoryFilters is EqualUnmodifiableListView) return _categoryFilters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryFilters);
}

/// List of hazard severity filters for AWS hazards
 final  List<HazardSeverityWithCount> _severityFiltersAws;
/// List of hazard severity filters for AWS hazards
@override@JsonKey() List<HazardSeverityWithCount> get severityFiltersAws {
  if (_severityFiltersAws is EqualUnmodifiableListView) return _severityFiltersAws;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_severityFiltersAws);
}

/// List of hazard severity filters for non-AWS hazards
 final  List<HazardSeverityWithCount> _severityFiltersNonAws;
/// List of hazard severity filters for non-AWS hazards
@override@JsonKey() List<HazardSeverityWithCount> get severityFiltersNonAws {
  if (_severityFiltersNonAws is EqualUnmodifiableListView) return _severityFiltersNonAws;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_severityFiltersNonAws);
}


/// Create a copy of HazardFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HazardFiltersCopyWith<_HazardFilters> get copyWith => __$HazardFiltersCopyWithImpl<_HazardFilters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HazardFiltersToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HazardFilters&&const DeepCollectionEquality().equals(other._categoryFilters, _categoryFilters)&&const DeepCollectionEquality().equals(other._severityFiltersAws, _severityFiltersAws)&&const DeepCollectionEquality().equals(other._severityFiltersNonAws, _severityFiltersNonAws));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categoryFilters),const DeepCollectionEquality().hash(_severityFiltersAws),const DeepCollectionEquality().hash(_severityFiltersNonAws));

@override
String toString() {
  return 'HazardFilters(categoryFilters: $categoryFilters, severityFiltersAws: $severityFiltersAws, severityFiltersNonAws: $severityFiltersNonAws)';
}


}

/// @nodoc
abstract mixin class _$HazardFiltersCopyWith<$Res> implements $HazardFiltersCopyWith<$Res> {
  factory _$HazardFiltersCopyWith(_HazardFilters value, $Res Function(_HazardFilters) _then) = __$HazardFiltersCopyWithImpl;
@override @useResult
$Res call({
 List<HazardCategory> categoryFilters, List<HazardSeverityWithCount> severityFiltersAws, List<HazardSeverityWithCount> severityFiltersNonAws
});




}
/// @nodoc
class __$HazardFiltersCopyWithImpl<$Res>
    implements _$HazardFiltersCopyWith<$Res> {
  __$HazardFiltersCopyWithImpl(this._self, this._then);

  final _HazardFilters _self;
  final $Res Function(_HazardFilters) _then;

/// Create a copy of HazardFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryFilters = null,Object? severityFiltersAws = null,Object? severityFiltersNonAws = null,}) {
  return _then(_HazardFilters(
categoryFilters: null == categoryFilters ? _self._categoryFilters : categoryFilters // ignore: cast_nullable_to_non_nullable
as List<HazardCategory>,severityFiltersAws: null == severityFiltersAws ? _self._severityFiltersAws : severityFiltersAws // ignore: cast_nullable_to_non_nullable
as List<HazardSeverityWithCount>,severityFiltersNonAws: null == severityFiltersNonAws ? _self._severityFiltersNonAws : severityFiltersNonAws // ignore: cast_nullable_to_non_nullable
as List<HazardSeverityWithCount>,
  ));
}


}

// dart format on
