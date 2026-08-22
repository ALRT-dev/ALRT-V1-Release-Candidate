// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hazard_severity_with_count_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HazardSeverityWithCount {

/// The severity level of the hazard.
 HazardSeverity get severity;/// The number of hazards associated with this severity level.
 int get hazardsCount;
/// Create a copy of HazardSeverityWithCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HazardSeverityWithCountCopyWith<HazardSeverityWithCount> get copyWith => _$HazardSeverityWithCountCopyWithImpl<HazardSeverityWithCount>(this as HazardSeverityWithCount, _$identity);

  /// Serializes this HazardSeverityWithCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HazardSeverityWithCount&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.hazardsCount, hazardsCount) || other.hazardsCount == hazardsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,severity,hazardsCount);

@override
String toString() {
  return 'HazardSeverityWithCount(severity: $severity, hazardsCount: $hazardsCount)';
}


}

/// @nodoc
abstract mixin class $HazardSeverityWithCountCopyWith<$Res>  {
  factory $HazardSeverityWithCountCopyWith(HazardSeverityWithCount value, $Res Function(HazardSeverityWithCount) _then) = _$HazardSeverityWithCountCopyWithImpl;
@useResult
$Res call({
 HazardSeverity severity, int hazardsCount
});




}
/// @nodoc
class _$HazardSeverityWithCountCopyWithImpl<$Res>
    implements $HazardSeverityWithCountCopyWith<$Res> {
  _$HazardSeverityWithCountCopyWithImpl(this._self, this._then);

  final HazardSeverityWithCount _self;
  final $Res Function(HazardSeverityWithCount) _then;

/// Create a copy of HazardSeverityWithCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? severity = null,Object? hazardsCount = null,}) {
  return _then(_self.copyWith(
severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as HazardSeverity,hazardsCount: null == hazardsCount ? _self.hazardsCount : hazardsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HazardSeverityWithCount].
extension HazardSeverityWithCountPatterns on HazardSeverityWithCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HazardSeverityWithCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HazardSeverityWithCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HazardSeverityWithCount value)  $default,){
final _that = this;
switch (_that) {
case _HazardSeverityWithCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HazardSeverityWithCount value)?  $default,){
final _that = this;
switch (_that) {
case _HazardSeverityWithCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HazardSeverity severity,  int hazardsCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HazardSeverityWithCount() when $default != null:
return $default(_that.severity,_that.hazardsCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HazardSeverity severity,  int hazardsCount)  $default,) {final _that = this;
switch (_that) {
case _HazardSeverityWithCount():
return $default(_that.severity,_that.hazardsCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HazardSeverity severity,  int hazardsCount)?  $default,) {final _that = this;
switch (_that) {
case _HazardSeverityWithCount() when $default != null:
return $default(_that.severity,_that.hazardsCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HazardSeverityWithCount implements HazardSeverityWithCount {
  const _HazardSeverityWithCount({required this.severity, this.hazardsCount = 0});
  factory _HazardSeverityWithCount.fromJson(Map<String, dynamic> json) => _$HazardSeverityWithCountFromJson(json);

/// The severity level of the hazard.
@override final  HazardSeverity severity;
/// The number of hazards associated with this severity level.
@override@JsonKey() final  int hazardsCount;

/// Create a copy of HazardSeverityWithCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HazardSeverityWithCountCopyWith<_HazardSeverityWithCount> get copyWith => __$HazardSeverityWithCountCopyWithImpl<_HazardSeverityWithCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HazardSeverityWithCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HazardSeverityWithCount&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.hazardsCount, hazardsCount) || other.hazardsCount == hazardsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,severity,hazardsCount);

@override
String toString() {
  return 'HazardSeverityWithCount(severity: $severity, hazardsCount: $hazardsCount)';
}


}

/// @nodoc
abstract mixin class _$HazardSeverityWithCountCopyWith<$Res> implements $HazardSeverityWithCountCopyWith<$Res> {
  factory _$HazardSeverityWithCountCopyWith(_HazardSeverityWithCount value, $Res Function(_HazardSeverityWithCount) _then) = __$HazardSeverityWithCountCopyWithImpl;
@override @useResult
$Res call({
 HazardSeverity severity, int hazardsCount
});




}
/// @nodoc
class __$HazardSeverityWithCountCopyWithImpl<$Res>
    implements _$HazardSeverityWithCountCopyWith<$Res> {
  __$HazardSeverityWithCountCopyWithImpl(this._self, this._then);

  final _HazardSeverityWithCount _self;
  final $Res Function(_HazardSeverityWithCount) _then;

/// Create a copy of HazardSeverityWithCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? severity = null,Object? hazardsCount = null,}) {
  return _then(_HazardSeverityWithCount(
severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as HazardSeverity,hazardsCount: null == hazardsCount ? _self.hazardsCount : hazardsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
