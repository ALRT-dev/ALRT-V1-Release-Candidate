// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_available_filters_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GetAvailableFiltersResponse {

/// The list of hazard categories that can be used as filters.
 List<HazardCategory> get categoryFilters;/// The list of hazard severities that can be used as filters.
 List<HazardSeverityWithCount> get severityFiltersAws;/// The list of hazard severities that can be used as filters.
 List<HazardSeverityWithCount> get severityFiltersNonAws;
/// Create a copy of GetAvailableFiltersResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetAvailableFiltersResponseCopyWith<GetAvailableFiltersResponse> get copyWith => _$GetAvailableFiltersResponseCopyWithImpl<GetAvailableFiltersResponse>(this as GetAvailableFiltersResponse, _$identity);

  /// Serializes this GetAvailableFiltersResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAvailableFiltersResponse&&const DeepCollectionEquality().equals(other.categoryFilters, categoryFilters)&&const DeepCollectionEquality().equals(other.severityFiltersAws, severityFiltersAws)&&const DeepCollectionEquality().equals(other.severityFiltersNonAws, severityFiltersNonAws));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(categoryFilters),const DeepCollectionEquality().hash(severityFiltersAws),const DeepCollectionEquality().hash(severityFiltersNonAws));

@override
String toString() {
  return 'GetAvailableFiltersResponse(categoryFilters: $categoryFilters, severityFiltersAws: $severityFiltersAws, severityFiltersNonAws: $severityFiltersNonAws)';
}


}

/// @nodoc
abstract mixin class $GetAvailableFiltersResponseCopyWith<$Res>  {
  factory $GetAvailableFiltersResponseCopyWith(GetAvailableFiltersResponse value, $Res Function(GetAvailableFiltersResponse) _then) = _$GetAvailableFiltersResponseCopyWithImpl;
@useResult
$Res call({
 List<HazardCategory> categoryFilters, List<HazardSeverityWithCount> severityFiltersAws, List<HazardSeverityWithCount> severityFiltersNonAws
});




}
/// @nodoc
class _$GetAvailableFiltersResponseCopyWithImpl<$Res>
    implements $GetAvailableFiltersResponseCopyWith<$Res> {
  _$GetAvailableFiltersResponseCopyWithImpl(this._self, this._then);

  final GetAvailableFiltersResponse _self;
  final $Res Function(GetAvailableFiltersResponse) _then;

/// Create a copy of GetAvailableFiltersResponse
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


/// Adds pattern-matching-related methods to [GetAvailableFiltersResponse].
extension GetAvailableFiltersResponsePatterns on GetAvailableFiltersResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GetAvailableFiltersResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetAvailableFiltersResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GetAvailableFiltersResponse value)  $default,){
final _that = this;
switch (_that) {
case _GetAvailableFiltersResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GetAvailableFiltersResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GetAvailableFiltersResponse() when $default != null:
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
case _GetAvailableFiltersResponse() when $default != null:
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
case _GetAvailableFiltersResponse():
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
case _GetAvailableFiltersResponse() when $default != null:
return $default(_that.categoryFilters,_that.severityFiltersAws,_that.severityFiltersNonAws);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GetAvailableFiltersResponse implements GetAvailableFiltersResponse {
  const _GetAvailableFiltersResponse({final  List<HazardCategory> categoryFilters = const <HazardCategory>[], final  List<HazardSeverityWithCount> severityFiltersAws = const <HazardSeverityWithCount>[], final  List<HazardSeverityWithCount> severityFiltersNonAws = const <HazardSeverityWithCount>[]}): _categoryFilters = categoryFilters,_severityFiltersAws = severityFiltersAws,_severityFiltersNonAws = severityFiltersNonAws;
  factory _GetAvailableFiltersResponse.fromJson(Map<String, dynamic> json) => _$GetAvailableFiltersResponseFromJson(json);

/// The list of hazard categories that can be used as filters.
 final  List<HazardCategory> _categoryFilters;
/// The list of hazard categories that can be used as filters.
@override@JsonKey() List<HazardCategory> get categoryFilters {
  if (_categoryFilters is EqualUnmodifiableListView) return _categoryFilters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryFilters);
}

/// The list of hazard severities that can be used as filters.
 final  List<HazardSeverityWithCount> _severityFiltersAws;
/// The list of hazard severities that can be used as filters.
@override@JsonKey() List<HazardSeverityWithCount> get severityFiltersAws {
  if (_severityFiltersAws is EqualUnmodifiableListView) return _severityFiltersAws;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_severityFiltersAws);
}

/// The list of hazard severities that can be used as filters.
 final  List<HazardSeverityWithCount> _severityFiltersNonAws;
/// The list of hazard severities that can be used as filters.
@override@JsonKey() List<HazardSeverityWithCount> get severityFiltersNonAws {
  if (_severityFiltersNonAws is EqualUnmodifiableListView) return _severityFiltersNonAws;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_severityFiltersNonAws);
}


/// Create a copy of GetAvailableFiltersResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetAvailableFiltersResponseCopyWith<_GetAvailableFiltersResponse> get copyWith => __$GetAvailableFiltersResponseCopyWithImpl<_GetAvailableFiltersResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GetAvailableFiltersResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetAvailableFiltersResponse&&const DeepCollectionEquality().equals(other._categoryFilters, _categoryFilters)&&const DeepCollectionEquality().equals(other._severityFiltersAws, _severityFiltersAws)&&const DeepCollectionEquality().equals(other._severityFiltersNonAws, _severityFiltersNonAws));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categoryFilters),const DeepCollectionEquality().hash(_severityFiltersAws),const DeepCollectionEquality().hash(_severityFiltersNonAws));

@override
String toString() {
  return 'GetAvailableFiltersResponse(categoryFilters: $categoryFilters, severityFiltersAws: $severityFiltersAws, severityFiltersNonAws: $severityFiltersNonAws)';
}


}

/// @nodoc
abstract mixin class _$GetAvailableFiltersResponseCopyWith<$Res> implements $GetAvailableFiltersResponseCopyWith<$Res> {
  factory _$GetAvailableFiltersResponseCopyWith(_GetAvailableFiltersResponse value, $Res Function(_GetAvailableFiltersResponse) _then) = __$GetAvailableFiltersResponseCopyWithImpl;
@override @useResult
$Res call({
 List<HazardCategory> categoryFilters, List<HazardSeverityWithCount> severityFiltersAws, List<HazardSeverityWithCount> severityFiltersNonAws
});




}
/// @nodoc
class __$GetAvailableFiltersResponseCopyWithImpl<$Res>
    implements _$GetAvailableFiltersResponseCopyWith<$Res> {
  __$GetAvailableFiltersResponseCopyWithImpl(this._self, this._then);

  final _GetAvailableFiltersResponse _self;
  final $Res Function(_GetAvailableFiltersResponse) _then;

/// Create a copy of GetAvailableFiltersResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryFilters = null,Object? severityFiltersAws = null,Object? severityFiltersNonAws = null,}) {
  return _then(_GetAvailableFiltersResponse(
categoryFilters: null == categoryFilters ? _self._categoryFilters : categoryFilters // ignore: cast_nullable_to_non_nullable
as List<HazardCategory>,severityFiltersAws: null == severityFiltersAws ? _self._severityFiltersAws : severityFiltersAws // ignore: cast_nullable_to_non_nullable
as List<HazardSeverityWithCount>,severityFiltersNonAws: null == severityFiltersNonAws ? _self._severityFiltersNonAws : severityFiltersNonAws // ignore: cast_nullable_to_non_nullable
as List<HazardSeverityWithCount>,
  ));
}


}

// dart format on
