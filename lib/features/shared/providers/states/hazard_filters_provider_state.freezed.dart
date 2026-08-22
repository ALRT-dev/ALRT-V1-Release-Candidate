// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hazard_filters_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HazardFiltersProviderState {

/// Whether AWS Emergency level "Emergency" is selected.
 bool get awsEmergency;/// Whether AWS Emergency level "Watch and Act" is selected.
 bool get awsWatchAndAct;/// Whether AWS Emergency level "Advice" is selected.
 bool get awsAdvice;/// Whether Official Non-AWS sources are selected.
 bool get officialNonAws;/// Whether User Reported sources are selected.
 bool get userReported;/// Whether global humanitarian feeds (the rounded square) are shown.
 bool get globalHumanitarian;/// Whether ALRT Intel (the shield) is shown.
 bool get alrtIntel;/// All available category IDs.
 Set<String> get allCategoryIds;/// Selected category IDs.
 Set<String> get selectedCategoryIds;/// Selected location subscription IDs.
 Set<String> get selectedLocationIds;
/// Create a copy of HazardFiltersProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HazardFiltersProviderStateCopyWith<HazardFiltersProviderState> get copyWith => _$HazardFiltersProviderStateCopyWithImpl<HazardFiltersProviderState>(this as HazardFiltersProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HazardFiltersProviderState&&(identical(other.awsEmergency, awsEmergency) || other.awsEmergency == awsEmergency)&&(identical(other.awsWatchAndAct, awsWatchAndAct) || other.awsWatchAndAct == awsWatchAndAct)&&(identical(other.awsAdvice, awsAdvice) || other.awsAdvice == awsAdvice)&&(identical(other.officialNonAws, officialNonAws) || other.officialNonAws == officialNonAws)&&(identical(other.userReported, userReported) || other.userReported == userReported)&&(identical(other.globalHumanitarian, globalHumanitarian) || other.globalHumanitarian == globalHumanitarian)&&(identical(other.alrtIntel, alrtIntel) || other.alrtIntel == alrtIntel)&&const DeepCollectionEquality().equals(other.allCategoryIds, allCategoryIds)&&const DeepCollectionEquality().equals(other.selectedCategoryIds, selectedCategoryIds)&&const DeepCollectionEquality().equals(other.selectedLocationIds, selectedLocationIds));
}


@override
int get hashCode => Object.hash(runtimeType,awsEmergency,awsWatchAndAct,awsAdvice,officialNonAws,userReported,globalHumanitarian,alrtIntel,const DeepCollectionEquality().hash(allCategoryIds),const DeepCollectionEquality().hash(selectedCategoryIds),const DeepCollectionEquality().hash(selectedLocationIds));

@override
String toString() {
  return 'HazardFiltersProviderState(awsEmergency: $awsEmergency, awsWatchAndAct: $awsWatchAndAct, awsAdvice: $awsAdvice, officialNonAws: $officialNonAws, userReported: $userReported, globalHumanitarian: $globalHumanitarian, alrtIntel: $alrtIntel, allCategoryIds: $allCategoryIds, selectedCategoryIds: $selectedCategoryIds, selectedLocationIds: $selectedLocationIds)';
}


}

/// @nodoc
abstract mixin class $HazardFiltersProviderStateCopyWith<$Res>  {
  factory $HazardFiltersProviderStateCopyWith(HazardFiltersProviderState value, $Res Function(HazardFiltersProviderState) _then) = _$HazardFiltersProviderStateCopyWithImpl;
@useResult
$Res call({
 bool awsEmergency, bool awsWatchAndAct, bool awsAdvice, bool officialNonAws, bool userReported, bool globalHumanitarian, bool alrtIntel, Set<String> allCategoryIds, Set<String> selectedCategoryIds, Set<String> selectedLocationIds
});




}
/// @nodoc
class _$HazardFiltersProviderStateCopyWithImpl<$Res>
    implements $HazardFiltersProviderStateCopyWith<$Res> {
  _$HazardFiltersProviderStateCopyWithImpl(this._self, this._then);

  final HazardFiltersProviderState _self;
  final $Res Function(HazardFiltersProviderState) _then;

/// Create a copy of HazardFiltersProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? awsEmergency = null,Object? awsWatchAndAct = null,Object? awsAdvice = null,Object? officialNonAws = null,Object? userReported = null,Object? globalHumanitarian = null,Object? alrtIntel = null,Object? allCategoryIds = null,Object? selectedCategoryIds = null,Object? selectedLocationIds = null,}) {
  return _then(_self.copyWith(
awsEmergency: null == awsEmergency ? _self.awsEmergency : awsEmergency // ignore: cast_nullable_to_non_nullable
as bool,awsWatchAndAct: null == awsWatchAndAct ? _self.awsWatchAndAct : awsWatchAndAct // ignore: cast_nullable_to_non_nullable
as bool,awsAdvice: null == awsAdvice ? _self.awsAdvice : awsAdvice // ignore: cast_nullable_to_non_nullable
as bool,officialNonAws: null == officialNonAws ? _self.officialNonAws : officialNonAws // ignore: cast_nullable_to_non_nullable
as bool,userReported: null == userReported ? _self.userReported : userReported // ignore: cast_nullable_to_non_nullable
as bool,globalHumanitarian: null == globalHumanitarian ? _self.globalHumanitarian : globalHumanitarian // ignore: cast_nullable_to_non_nullable
as bool,alrtIntel: null == alrtIntel ? _self.alrtIntel : alrtIntel // ignore: cast_nullable_to_non_nullable
as bool,allCategoryIds: null == allCategoryIds ? _self.allCategoryIds : allCategoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,selectedCategoryIds: null == selectedCategoryIds ? _self.selectedCategoryIds : selectedCategoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,selectedLocationIds: null == selectedLocationIds ? _self.selectedLocationIds : selectedLocationIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [HazardFiltersProviderState].
extension HazardFiltersProviderStatePatterns on HazardFiltersProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HazardFiltersProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HazardFiltersProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HazardFiltersProviderState value)  $default,){
final _that = this;
switch (_that) {
case _HazardFiltersProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HazardFiltersProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _HazardFiltersProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool awsEmergency,  bool awsWatchAndAct,  bool awsAdvice,  bool officialNonAws,  bool userReported,  bool globalHumanitarian,  bool alrtIntel,  Set<String> allCategoryIds,  Set<String> selectedCategoryIds,  Set<String> selectedLocationIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HazardFiltersProviderState() when $default != null:
return $default(_that.awsEmergency,_that.awsWatchAndAct,_that.awsAdvice,_that.officialNonAws,_that.userReported,_that.globalHumanitarian,_that.alrtIntel,_that.allCategoryIds,_that.selectedCategoryIds,_that.selectedLocationIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool awsEmergency,  bool awsWatchAndAct,  bool awsAdvice,  bool officialNonAws,  bool userReported,  bool globalHumanitarian,  bool alrtIntel,  Set<String> allCategoryIds,  Set<String> selectedCategoryIds,  Set<String> selectedLocationIds)  $default,) {final _that = this;
switch (_that) {
case _HazardFiltersProviderState():
return $default(_that.awsEmergency,_that.awsWatchAndAct,_that.awsAdvice,_that.officialNonAws,_that.userReported,_that.globalHumanitarian,_that.alrtIntel,_that.allCategoryIds,_that.selectedCategoryIds,_that.selectedLocationIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool awsEmergency,  bool awsWatchAndAct,  bool awsAdvice,  bool officialNonAws,  bool userReported,  bool globalHumanitarian,  bool alrtIntel,  Set<String> allCategoryIds,  Set<String> selectedCategoryIds,  Set<String> selectedLocationIds)?  $default,) {final _that = this;
switch (_that) {
case _HazardFiltersProviderState() when $default != null:
return $default(_that.awsEmergency,_that.awsWatchAndAct,_that.awsAdvice,_that.officialNonAws,_that.userReported,_that.globalHumanitarian,_that.alrtIntel,_that.allCategoryIds,_that.selectedCategoryIds,_that.selectedLocationIds);case _:
  return null;

}
}

}

/// @nodoc


class _HazardFiltersProviderState extends HazardFiltersProviderState {
  const _HazardFiltersProviderState({this.awsEmergency = true, this.awsWatchAndAct = true, this.awsAdvice = true, this.officialNonAws = true, this.userReported = true, this.globalHumanitarian = true, this.alrtIntel = true, final  Set<String> allCategoryIds = const <String>{}, final  Set<String> selectedCategoryIds = const <String>{}, final  Set<String> selectedLocationIds = const <String>{}}): _allCategoryIds = allCategoryIds,_selectedCategoryIds = selectedCategoryIds,_selectedLocationIds = selectedLocationIds,super._();
  

/// Whether AWS Emergency level "Emergency" is selected.
@override@JsonKey() final  bool awsEmergency;
/// Whether AWS Emergency level "Watch and Act" is selected.
@override@JsonKey() final  bool awsWatchAndAct;
/// Whether AWS Emergency level "Advice" is selected.
@override@JsonKey() final  bool awsAdvice;
/// Whether Official Non-AWS sources are selected.
@override@JsonKey() final  bool officialNonAws;
/// Whether User Reported sources are selected.
@override@JsonKey() final  bool userReported;
/// Whether global humanitarian feeds (the rounded square) are shown.
@override@JsonKey() final  bool globalHumanitarian;
/// Whether ALRT Intel (the shield) is shown.
@override@JsonKey() final  bool alrtIntel;
/// All available category IDs.
 final  Set<String> _allCategoryIds;
/// All available category IDs.
@override@JsonKey() Set<String> get allCategoryIds {
  if (_allCategoryIds is EqualUnmodifiableSetView) return _allCategoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_allCategoryIds);
}

/// Selected category IDs.
 final  Set<String> _selectedCategoryIds;
/// Selected category IDs.
@override@JsonKey() Set<String> get selectedCategoryIds {
  if (_selectedCategoryIds is EqualUnmodifiableSetView) return _selectedCategoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedCategoryIds);
}

/// Selected location subscription IDs.
 final  Set<String> _selectedLocationIds;
/// Selected location subscription IDs.
@override@JsonKey() Set<String> get selectedLocationIds {
  if (_selectedLocationIds is EqualUnmodifiableSetView) return _selectedLocationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedLocationIds);
}


/// Create a copy of HazardFiltersProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HazardFiltersProviderStateCopyWith<_HazardFiltersProviderState> get copyWith => __$HazardFiltersProviderStateCopyWithImpl<_HazardFiltersProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HazardFiltersProviderState&&(identical(other.awsEmergency, awsEmergency) || other.awsEmergency == awsEmergency)&&(identical(other.awsWatchAndAct, awsWatchAndAct) || other.awsWatchAndAct == awsWatchAndAct)&&(identical(other.awsAdvice, awsAdvice) || other.awsAdvice == awsAdvice)&&(identical(other.officialNonAws, officialNonAws) || other.officialNonAws == officialNonAws)&&(identical(other.userReported, userReported) || other.userReported == userReported)&&(identical(other.globalHumanitarian, globalHumanitarian) || other.globalHumanitarian == globalHumanitarian)&&(identical(other.alrtIntel, alrtIntel) || other.alrtIntel == alrtIntel)&&const DeepCollectionEquality().equals(other._allCategoryIds, _allCategoryIds)&&const DeepCollectionEquality().equals(other._selectedCategoryIds, _selectedCategoryIds)&&const DeepCollectionEquality().equals(other._selectedLocationIds, _selectedLocationIds));
}


@override
int get hashCode => Object.hash(runtimeType,awsEmergency,awsWatchAndAct,awsAdvice,officialNonAws,userReported,globalHumanitarian,alrtIntel,const DeepCollectionEquality().hash(_allCategoryIds),const DeepCollectionEquality().hash(_selectedCategoryIds),const DeepCollectionEquality().hash(_selectedLocationIds));

@override
String toString() {
  return 'HazardFiltersProviderState(awsEmergency: $awsEmergency, awsWatchAndAct: $awsWatchAndAct, awsAdvice: $awsAdvice, officialNonAws: $officialNonAws, userReported: $userReported, globalHumanitarian: $globalHumanitarian, alrtIntel: $alrtIntel, allCategoryIds: $allCategoryIds, selectedCategoryIds: $selectedCategoryIds, selectedLocationIds: $selectedLocationIds)';
}


}

/// @nodoc
abstract mixin class _$HazardFiltersProviderStateCopyWith<$Res> implements $HazardFiltersProviderStateCopyWith<$Res> {
  factory _$HazardFiltersProviderStateCopyWith(_HazardFiltersProviderState value, $Res Function(_HazardFiltersProviderState) _then) = __$HazardFiltersProviderStateCopyWithImpl;
@override @useResult
$Res call({
 bool awsEmergency, bool awsWatchAndAct, bool awsAdvice, bool officialNonAws, bool userReported, bool globalHumanitarian, bool alrtIntel, Set<String> allCategoryIds, Set<String> selectedCategoryIds, Set<String> selectedLocationIds
});




}
/// @nodoc
class __$HazardFiltersProviderStateCopyWithImpl<$Res>
    implements _$HazardFiltersProviderStateCopyWith<$Res> {
  __$HazardFiltersProviderStateCopyWithImpl(this._self, this._then);

  final _HazardFiltersProviderState _self;
  final $Res Function(_HazardFiltersProviderState) _then;

/// Create a copy of HazardFiltersProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? awsEmergency = null,Object? awsWatchAndAct = null,Object? awsAdvice = null,Object? officialNonAws = null,Object? userReported = null,Object? globalHumanitarian = null,Object? alrtIntel = null,Object? allCategoryIds = null,Object? selectedCategoryIds = null,Object? selectedLocationIds = null,}) {
  return _then(_HazardFiltersProviderState(
awsEmergency: null == awsEmergency ? _self.awsEmergency : awsEmergency // ignore: cast_nullable_to_non_nullable
as bool,awsWatchAndAct: null == awsWatchAndAct ? _self.awsWatchAndAct : awsWatchAndAct // ignore: cast_nullable_to_non_nullable
as bool,awsAdvice: null == awsAdvice ? _self.awsAdvice : awsAdvice // ignore: cast_nullable_to_non_nullable
as bool,officialNonAws: null == officialNonAws ? _self.officialNonAws : officialNonAws // ignore: cast_nullable_to_non_nullable
as bool,userReported: null == userReported ? _self.userReported : userReported // ignore: cast_nullable_to_non_nullable
as bool,globalHumanitarian: null == globalHumanitarian ? _self.globalHumanitarian : globalHumanitarian // ignore: cast_nullable_to_non_nullable
as bool,alrtIntel: null == alrtIntel ? _self.alrtIntel : alrtIntel // ignore: cast_nullable_to_non_nullable
as bool,allCategoryIds: null == allCategoryIds ? _self._allCategoryIds : allCategoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,selectedCategoryIds: null == selectedCategoryIds ? _self._selectedCategoryIds : selectedCategoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,selectedLocationIds: null == selectedLocationIds ? _self._selectedLocationIds : selectedLocationIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
