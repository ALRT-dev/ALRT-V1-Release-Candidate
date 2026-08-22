// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hazard_severity_filter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HazardSeverityFilter {

/// The list of AWS compliant severity levels to filter hazards.
 List<HazardSeverity> get aws;/// The list of non-AWS compliant severity levels to filter hazards.
 List<HazardSeverity> get nonAws;
/// Create a copy of HazardSeverityFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HazardSeverityFilterCopyWith<HazardSeverityFilter> get copyWith => _$HazardSeverityFilterCopyWithImpl<HazardSeverityFilter>(this as HazardSeverityFilter, _$identity);

  /// Serializes this HazardSeverityFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HazardSeverityFilter&&const DeepCollectionEquality().equals(other.aws, aws)&&const DeepCollectionEquality().equals(other.nonAws, nonAws));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(aws),const DeepCollectionEquality().hash(nonAws));

@override
String toString() {
  return 'HazardSeverityFilter(aws: $aws, nonAws: $nonAws)';
}


}

/// @nodoc
abstract mixin class $HazardSeverityFilterCopyWith<$Res>  {
  factory $HazardSeverityFilterCopyWith(HazardSeverityFilter value, $Res Function(HazardSeverityFilter) _then) = _$HazardSeverityFilterCopyWithImpl;
@useResult
$Res call({
 List<HazardSeverity> aws, List<HazardSeverity> nonAws
});




}
/// @nodoc
class _$HazardSeverityFilterCopyWithImpl<$Res>
    implements $HazardSeverityFilterCopyWith<$Res> {
  _$HazardSeverityFilterCopyWithImpl(this._self, this._then);

  final HazardSeverityFilter _self;
  final $Res Function(HazardSeverityFilter) _then;

/// Create a copy of HazardSeverityFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? aws = null,Object? nonAws = null,}) {
  return _then(_self.copyWith(
aws: null == aws ? _self.aws : aws // ignore: cast_nullable_to_non_nullable
as List<HazardSeverity>,nonAws: null == nonAws ? _self.nonAws : nonAws // ignore: cast_nullable_to_non_nullable
as List<HazardSeverity>,
  ));
}

}


/// Adds pattern-matching-related methods to [HazardSeverityFilter].
extension HazardSeverityFilterPatterns on HazardSeverityFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HazardSeverityFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HazardSeverityFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HazardSeverityFilter value)  $default,){
final _that = this;
switch (_that) {
case _HazardSeverityFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HazardSeverityFilter value)?  $default,){
final _that = this;
switch (_that) {
case _HazardSeverityFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HazardSeverity> aws,  List<HazardSeverity> nonAws)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HazardSeverityFilter() when $default != null:
return $default(_that.aws,_that.nonAws);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HazardSeverity> aws,  List<HazardSeverity> nonAws)  $default,) {final _that = this;
switch (_that) {
case _HazardSeverityFilter():
return $default(_that.aws,_that.nonAws);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HazardSeverity> aws,  List<HazardSeverity> nonAws)?  $default,) {final _that = this;
switch (_that) {
case _HazardSeverityFilter() when $default != null:
return $default(_that.aws,_that.nonAws);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HazardSeverityFilter implements HazardSeverityFilter {
  const _HazardSeverityFilter({final  List<HazardSeverity> aws = const <HazardSeverity>[], final  List<HazardSeverity> nonAws = const <HazardSeverity>[]}): _aws = aws,_nonAws = nonAws;
  factory _HazardSeverityFilter.fromJson(Map<String, dynamic> json) => _$HazardSeverityFilterFromJson(json);

/// The list of AWS compliant severity levels to filter hazards.
 final  List<HazardSeverity> _aws;
/// The list of AWS compliant severity levels to filter hazards.
@override@JsonKey() List<HazardSeverity> get aws {
  if (_aws is EqualUnmodifiableListView) return _aws;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aws);
}

/// The list of non-AWS compliant severity levels to filter hazards.
 final  List<HazardSeverity> _nonAws;
/// The list of non-AWS compliant severity levels to filter hazards.
@override@JsonKey() List<HazardSeverity> get nonAws {
  if (_nonAws is EqualUnmodifiableListView) return _nonAws;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nonAws);
}


/// Create a copy of HazardSeverityFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HazardSeverityFilterCopyWith<_HazardSeverityFilter> get copyWith => __$HazardSeverityFilterCopyWithImpl<_HazardSeverityFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HazardSeverityFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HazardSeverityFilter&&const DeepCollectionEquality().equals(other._aws, _aws)&&const DeepCollectionEquality().equals(other._nonAws, _nonAws));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_aws),const DeepCollectionEquality().hash(_nonAws));

@override
String toString() {
  return 'HazardSeverityFilter(aws: $aws, nonAws: $nonAws)';
}


}

/// @nodoc
abstract mixin class _$HazardSeverityFilterCopyWith<$Res> implements $HazardSeverityFilterCopyWith<$Res> {
  factory _$HazardSeverityFilterCopyWith(_HazardSeverityFilter value, $Res Function(_HazardSeverityFilter) _then) = __$HazardSeverityFilterCopyWithImpl;
@override @useResult
$Res call({
 List<HazardSeverity> aws, List<HazardSeverity> nonAws
});




}
/// @nodoc
class __$HazardSeverityFilterCopyWithImpl<$Res>
    implements _$HazardSeverityFilterCopyWith<$Res> {
  __$HazardSeverityFilterCopyWithImpl(this._self, this._then);

  final _HazardSeverityFilter _self;
  final $Res Function(_HazardSeverityFilter) _then;

/// Create a copy of HazardSeverityFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? aws = null,Object? nonAws = null,}) {
  return _then(_HazardSeverityFilter(
aws: null == aws ? _self._aws : aws // ignore: cast_nullable_to_non_nullable
as List<HazardSeverity>,nonAws: null == nonAws ? _self._nonAws : nonAws // ignore: cast_nullable_to_non_nullable
as List<HazardSeverity>,
  ));
}


}

// dart format on
