// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_update_report_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateUpdateReportProviderState {

/// The hazard to create or update.
 Hazard get hazardToCreateOrUpdate;/// The list of categories to select from.
 List<HazardCategory> get categoriesToSelect;/// The list of media associated with the hazard report.
 List<AlrtMedia> get medias;/// Whether the report has been submitted.
 bool get reportSubmitted;/// The list of [CreatingUpdatingHazardReport.id]s that have been acknowledged.
///
/// i.e A success or error toast has been shown for these reports.
 List<String> get acknowledgedReportIds;/// Whether to show the categories selector.
 bool get showCategoriesSelector;/// The state of getting categories to select.
 GetCategoriesToSelectState get getCategoriesToSelectState;/// The state of creating or updating hazard reports.
 List<CreatingUpdatingHazardReport> get creatingUpdatingHazardReports;
/// Create a copy of CreateUpdateReportProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateUpdateReportProviderStateCopyWith<CreateUpdateReportProviderState> get copyWith => _$CreateUpdateReportProviderStateCopyWithImpl<CreateUpdateReportProviderState>(this as CreateUpdateReportProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateUpdateReportProviderState&&(identical(other.hazardToCreateOrUpdate, hazardToCreateOrUpdate) || other.hazardToCreateOrUpdate == hazardToCreateOrUpdate)&&const DeepCollectionEquality().equals(other.categoriesToSelect, categoriesToSelect)&&const DeepCollectionEquality().equals(other.medias, medias)&&(identical(other.reportSubmitted, reportSubmitted) || other.reportSubmitted == reportSubmitted)&&const DeepCollectionEquality().equals(other.acknowledgedReportIds, acknowledgedReportIds)&&(identical(other.showCategoriesSelector, showCategoriesSelector) || other.showCategoriesSelector == showCategoriesSelector)&&(identical(other.getCategoriesToSelectState, getCategoriesToSelectState) || other.getCategoriesToSelectState == getCategoriesToSelectState)&&const DeepCollectionEquality().equals(other.creatingUpdatingHazardReports, creatingUpdatingHazardReports));
}


@override
int get hashCode => Object.hash(runtimeType,hazardToCreateOrUpdate,const DeepCollectionEquality().hash(categoriesToSelect),const DeepCollectionEquality().hash(medias),reportSubmitted,const DeepCollectionEquality().hash(acknowledgedReportIds),showCategoriesSelector,getCategoriesToSelectState,const DeepCollectionEquality().hash(creatingUpdatingHazardReports));

@override
String toString() {
  return 'CreateUpdateReportProviderState(hazardToCreateOrUpdate: $hazardToCreateOrUpdate, categoriesToSelect: $categoriesToSelect, medias: $medias, reportSubmitted: $reportSubmitted, acknowledgedReportIds: $acknowledgedReportIds, showCategoriesSelector: $showCategoriesSelector, getCategoriesToSelectState: $getCategoriesToSelectState, creatingUpdatingHazardReports: $creatingUpdatingHazardReports)';
}


}

/// @nodoc
abstract mixin class $CreateUpdateReportProviderStateCopyWith<$Res>  {
  factory $CreateUpdateReportProviderStateCopyWith(CreateUpdateReportProviderState value, $Res Function(CreateUpdateReportProviderState) _then) = _$CreateUpdateReportProviderStateCopyWithImpl;
@useResult
$Res call({
 Hazard hazardToCreateOrUpdate, List<HazardCategory> categoriesToSelect, List<AlrtMedia> medias, bool reportSubmitted, List<String> acknowledgedReportIds, bool showCategoriesSelector, GetCategoriesToSelectState getCategoriesToSelectState, List<CreatingUpdatingHazardReport> creatingUpdatingHazardReports
});


$HazardCopyWith<$Res> get hazardToCreateOrUpdate;$GetCategoriesToSelectStateCopyWith<$Res> get getCategoriesToSelectState;

}
/// @nodoc
class _$CreateUpdateReportProviderStateCopyWithImpl<$Res>
    implements $CreateUpdateReportProviderStateCopyWith<$Res> {
  _$CreateUpdateReportProviderStateCopyWithImpl(this._self, this._then);

  final CreateUpdateReportProviderState _self;
  final $Res Function(CreateUpdateReportProviderState) _then;

/// Create a copy of CreateUpdateReportProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hazardToCreateOrUpdate = null,Object? categoriesToSelect = null,Object? medias = null,Object? reportSubmitted = null,Object? acknowledgedReportIds = null,Object? showCategoriesSelector = null,Object? getCategoriesToSelectState = null,Object? creatingUpdatingHazardReports = null,}) {
  return _then(_self.copyWith(
hazardToCreateOrUpdate: null == hazardToCreateOrUpdate ? _self.hazardToCreateOrUpdate : hazardToCreateOrUpdate // ignore: cast_nullable_to_non_nullable
as Hazard,categoriesToSelect: null == categoriesToSelect ? _self.categoriesToSelect : categoriesToSelect // ignore: cast_nullable_to_non_nullable
as List<HazardCategory>,medias: null == medias ? _self.medias : medias // ignore: cast_nullable_to_non_nullable
as List<AlrtMedia>,reportSubmitted: null == reportSubmitted ? _self.reportSubmitted : reportSubmitted // ignore: cast_nullable_to_non_nullable
as bool,acknowledgedReportIds: null == acknowledgedReportIds ? _self.acknowledgedReportIds : acknowledgedReportIds // ignore: cast_nullable_to_non_nullable
as List<String>,showCategoriesSelector: null == showCategoriesSelector ? _self.showCategoriesSelector : showCategoriesSelector // ignore: cast_nullable_to_non_nullable
as bool,getCategoriesToSelectState: null == getCategoriesToSelectState ? _self.getCategoriesToSelectState : getCategoriesToSelectState // ignore: cast_nullable_to_non_nullable
as GetCategoriesToSelectState,creatingUpdatingHazardReports: null == creatingUpdatingHazardReports ? _self.creatingUpdatingHazardReports : creatingUpdatingHazardReports // ignore: cast_nullable_to_non_nullable
as List<CreatingUpdatingHazardReport>,
  ));
}
/// Create a copy of CreateUpdateReportProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HazardCopyWith<$Res> get hazardToCreateOrUpdate {
  
  return $HazardCopyWith<$Res>(_self.hazardToCreateOrUpdate, (value) {
    return _then(_self.copyWith(hazardToCreateOrUpdate: value));
  });
}/// Create a copy of CreateUpdateReportProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetCategoriesToSelectStateCopyWith<$Res> get getCategoriesToSelectState {
  
  return $GetCategoriesToSelectStateCopyWith<$Res>(_self.getCategoriesToSelectState, (value) {
    return _then(_self.copyWith(getCategoriesToSelectState: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateUpdateReportProviderState].
extension CreateUpdateReportProviderStatePatterns on CreateUpdateReportProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateUpdateReportProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateUpdateReportProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateUpdateReportProviderState value)  $default,){
final _that = this;
switch (_that) {
case _CreateUpdateReportProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateUpdateReportProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _CreateUpdateReportProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Hazard hazardToCreateOrUpdate,  List<HazardCategory> categoriesToSelect,  List<AlrtMedia> medias,  bool reportSubmitted,  List<String> acknowledgedReportIds,  bool showCategoriesSelector,  GetCategoriesToSelectState getCategoriesToSelectState,  List<CreatingUpdatingHazardReport> creatingUpdatingHazardReports)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateUpdateReportProviderState() when $default != null:
return $default(_that.hazardToCreateOrUpdate,_that.categoriesToSelect,_that.medias,_that.reportSubmitted,_that.acknowledgedReportIds,_that.showCategoriesSelector,_that.getCategoriesToSelectState,_that.creatingUpdatingHazardReports);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Hazard hazardToCreateOrUpdate,  List<HazardCategory> categoriesToSelect,  List<AlrtMedia> medias,  bool reportSubmitted,  List<String> acknowledgedReportIds,  bool showCategoriesSelector,  GetCategoriesToSelectState getCategoriesToSelectState,  List<CreatingUpdatingHazardReport> creatingUpdatingHazardReports)  $default,) {final _that = this;
switch (_that) {
case _CreateUpdateReportProviderState():
return $default(_that.hazardToCreateOrUpdate,_that.categoriesToSelect,_that.medias,_that.reportSubmitted,_that.acknowledgedReportIds,_that.showCategoriesSelector,_that.getCategoriesToSelectState,_that.creatingUpdatingHazardReports);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Hazard hazardToCreateOrUpdate,  List<HazardCategory> categoriesToSelect,  List<AlrtMedia> medias,  bool reportSubmitted,  List<String> acknowledgedReportIds,  bool showCategoriesSelector,  GetCategoriesToSelectState getCategoriesToSelectState,  List<CreatingUpdatingHazardReport> creatingUpdatingHazardReports)?  $default,) {final _that = this;
switch (_that) {
case _CreateUpdateReportProviderState() when $default != null:
return $default(_that.hazardToCreateOrUpdate,_that.categoriesToSelect,_that.medias,_that.reportSubmitted,_that.acknowledgedReportIds,_that.showCategoriesSelector,_that.getCategoriesToSelectState,_that.creatingUpdatingHazardReports);case _:
  return null;

}
}

}

/// @nodoc


class _CreateUpdateReportProviderState implements CreateUpdateReportProviderState {
  const _CreateUpdateReportProviderState({this.hazardToCreateOrUpdate = const Hazard(), final  List<HazardCategory> categoriesToSelect = const <HazardCategory>[], final  List<AlrtMedia> medias = const <AlrtMedia>[], this.reportSubmitted = false, final  List<String> acknowledgedReportIds = const <String>[], this.showCategoriesSelector = true, this.getCategoriesToSelectState = const GetCategoriesToSelectState.initial(), final  List<CreatingUpdatingHazardReport> creatingUpdatingHazardReports = const <CreatingUpdatingHazardReport>[]}): _categoriesToSelect = categoriesToSelect,_medias = medias,_acknowledgedReportIds = acknowledgedReportIds,_creatingUpdatingHazardReports = creatingUpdatingHazardReports;
  

/// The hazard to create or update.
@override@JsonKey() final  Hazard hazardToCreateOrUpdate;
/// The list of categories to select from.
 final  List<HazardCategory> _categoriesToSelect;
/// The list of categories to select from.
@override@JsonKey() List<HazardCategory> get categoriesToSelect {
  if (_categoriesToSelect is EqualUnmodifiableListView) return _categoriesToSelect;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoriesToSelect);
}

/// The list of media associated with the hazard report.
 final  List<AlrtMedia> _medias;
/// The list of media associated with the hazard report.
@override@JsonKey() List<AlrtMedia> get medias {
  if (_medias is EqualUnmodifiableListView) return _medias;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_medias);
}

/// Whether the report has been submitted.
@override@JsonKey() final  bool reportSubmitted;
/// The list of [CreatingUpdatingHazardReport.id]s that have been acknowledged.
///
/// i.e A success or error toast has been shown for these reports.
 final  List<String> _acknowledgedReportIds;
/// The list of [CreatingUpdatingHazardReport.id]s that have been acknowledged.
///
/// i.e A success or error toast has been shown for these reports.
@override@JsonKey() List<String> get acknowledgedReportIds {
  if (_acknowledgedReportIds is EqualUnmodifiableListView) return _acknowledgedReportIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_acknowledgedReportIds);
}

/// Whether to show the categories selector.
@override@JsonKey() final  bool showCategoriesSelector;
/// The state of getting categories to select.
@override@JsonKey() final  GetCategoriesToSelectState getCategoriesToSelectState;
/// The state of creating or updating hazard reports.
 final  List<CreatingUpdatingHazardReport> _creatingUpdatingHazardReports;
/// The state of creating or updating hazard reports.
@override@JsonKey() List<CreatingUpdatingHazardReport> get creatingUpdatingHazardReports {
  if (_creatingUpdatingHazardReports is EqualUnmodifiableListView) return _creatingUpdatingHazardReports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_creatingUpdatingHazardReports);
}


/// Create a copy of CreateUpdateReportProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateUpdateReportProviderStateCopyWith<_CreateUpdateReportProviderState> get copyWith => __$CreateUpdateReportProviderStateCopyWithImpl<_CreateUpdateReportProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateUpdateReportProviderState&&(identical(other.hazardToCreateOrUpdate, hazardToCreateOrUpdate) || other.hazardToCreateOrUpdate == hazardToCreateOrUpdate)&&const DeepCollectionEquality().equals(other._categoriesToSelect, _categoriesToSelect)&&const DeepCollectionEquality().equals(other._medias, _medias)&&(identical(other.reportSubmitted, reportSubmitted) || other.reportSubmitted == reportSubmitted)&&const DeepCollectionEquality().equals(other._acknowledgedReportIds, _acknowledgedReportIds)&&(identical(other.showCategoriesSelector, showCategoriesSelector) || other.showCategoriesSelector == showCategoriesSelector)&&(identical(other.getCategoriesToSelectState, getCategoriesToSelectState) || other.getCategoriesToSelectState == getCategoriesToSelectState)&&const DeepCollectionEquality().equals(other._creatingUpdatingHazardReports, _creatingUpdatingHazardReports));
}


@override
int get hashCode => Object.hash(runtimeType,hazardToCreateOrUpdate,const DeepCollectionEquality().hash(_categoriesToSelect),const DeepCollectionEquality().hash(_medias),reportSubmitted,const DeepCollectionEquality().hash(_acknowledgedReportIds),showCategoriesSelector,getCategoriesToSelectState,const DeepCollectionEquality().hash(_creatingUpdatingHazardReports));

@override
String toString() {
  return 'CreateUpdateReportProviderState(hazardToCreateOrUpdate: $hazardToCreateOrUpdate, categoriesToSelect: $categoriesToSelect, medias: $medias, reportSubmitted: $reportSubmitted, acknowledgedReportIds: $acknowledgedReportIds, showCategoriesSelector: $showCategoriesSelector, getCategoriesToSelectState: $getCategoriesToSelectState, creatingUpdatingHazardReports: $creatingUpdatingHazardReports)';
}


}

/// @nodoc
abstract mixin class _$CreateUpdateReportProviderStateCopyWith<$Res> implements $CreateUpdateReportProviderStateCopyWith<$Res> {
  factory _$CreateUpdateReportProviderStateCopyWith(_CreateUpdateReportProviderState value, $Res Function(_CreateUpdateReportProviderState) _then) = __$CreateUpdateReportProviderStateCopyWithImpl;
@override @useResult
$Res call({
 Hazard hazardToCreateOrUpdate, List<HazardCategory> categoriesToSelect, List<AlrtMedia> medias, bool reportSubmitted, List<String> acknowledgedReportIds, bool showCategoriesSelector, GetCategoriesToSelectState getCategoriesToSelectState, List<CreatingUpdatingHazardReport> creatingUpdatingHazardReports
});


@override $HazardCopyWith<$Res> get hazardToCreateOrUpdate;@override $GetCategoriesToSelectStateCopyWith<$Res> get getCategoriesToSelectState;

}
/// @nodoc
class __$CreateUpdateReportProviderStateCopyWithImpl<$Res>
    implements _$CreateUpdateReportProviderStateCopyWith<$Res> {
  __$CreateUpdateReportProviderStateCopyWithImpl(this._self, this._then);

  final _CreateUpdateReportProviderState _self;
  final $Res Function(_CreateUpdateReportProviderState) _then;

/// Create a copy of CreateUpdateReportProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hazardToCreateOrUpdate = null,Object? categoriesToSelect = null,Object? medias = null,Object? reportSubmitted = null,Object? acknowledgedReportIds = null,Object? showCategoriesSelector = null,Object? getCategoriesToSelectState = null,Object? creatingUpdatingHazardReports = null,}) {
  return _then(_CreateUpdateReportProviderState(
hazardToCreateOrUpdate: null == hazardToCreateOrUpdate ? _self.hazardToCreateOrUpdate : hazardToCreateOrUpdate // ignore: cast_nullable_to_non_nullable
as Hazard,categoriesToSelect: null == categoriesToSelect ? _self._categoriesToSelect : categoriesToSelect // ignore: cast_nullable_to_non_nullable
as List<HazardCategory>,medias: null == medias ? _self._medias : medias // ignore: cast_nullable_to_non_nullable
as List<AlrtMedia>,reportSubmitted: null == reportSubmitted ? _self.reportSubmitted : reportSubmitted // ignore: cast_nullable_to_non_nullable
as bool,acknowledgedReportIds: null == acknowledgedReportIds ? _self._acknowledgedReportIds : acknowledgedReportIds // ignore: cast_nullable_to_non_nullable
as List<String>,showCategoriesSelector: null == showCategoriesSelector ? _self.showCategoriesSelector : showCategoriesSelector // ignore: cast_nullable_to_non_nullable
as bool,getCategoriesToSelectState: null == getCategoriesToSelectState ? _self.getCategoriesToSelectState : getCategoriesToSelectState // ignore: cast_nullable_to_non_nullable
as GetCategoriesToSelectState,creatingUpdatingHazardReports: null == creatingUpdatingHazardReports ? _self._creatingUpdatingHazardReports : creatingUpdatingHazardReports // ignore: cast_nullable_to_non_nullable
as List<CreatingUpdatingHazardReport>,
  ));
}

/// Create a copy of CreateUpdateReportProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HazardCopyWith<$Res> get hazardToCreateOrUpdate {
  
  return $HazardCopyWith<$Res>(_self.hazardToCreateOrUpdate, (value) {
    return _then(_self.copyWith(hazardToCreateOrUpdate: value));
  });
}/// Create a copy of CreateUpdateReportProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetCategoriesToSelectStateCopyWith<$Res> get getCategoriesToSelectState {
  
  return $GetCategoriesToSelectStateCopyWith<$Res>(_self.getCategoriesToSelectState, (value) {
    return _then(_self.copyWith(getCategoriesToSelectState: value));
  });
}
}

/// @nodoc
mixin _$GetCategoriesToSelectState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetCategoriesToSelectState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetCategoriesToSelectState()';
}


}

/// @nodoc
class $GetCategoriesToSelectStateCopyWith<$Res>  {
$GetCategoriesToSelectStateCopyWith(GetCategoriesToSelectState _, $Res Function(GetCategoriesToSelectState) __);
}


/// Adds pattern-matching-related methods to [GetCategoriesToSelectState].
extension GetCategoriesToSelectStatePatterns on GetCategoriesToSelectState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetCategoriesToSelectStateInitial value)?  initial,TResult Function( _GetCategoriesToSelectStateLoading value)?  loading,TResult Function( _GetCategoriesToSelectStateSuccess value)?  success,TResult Function( _GetCategoriesToSelectStateFailure value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetCategoriesToSelectStateInitial() when initial != null:
return initial(_that);case _GetCategoriesToSelectStateLoading() when loading != null:
return loading(_that);case _GetCategoriesToSelectStateSuccess() when success != null:
return success(_that);case _GetCategoriesToSelectStateFailure() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetCategoriesToSelectStateInitial value)  initial,required TResult Function( _GetCategoriesToSelectStateLoading value)  loading,required TResult Function( _GetCategoriesToSelectStateSuccess value)  success,required TResult Function( _GetCategoriesToSelectStateFailure value)  error,}){
final _that = this;
switch (_that) {
case _GetCategoriesToSelectStateInitial():
return initial(_that);case _GetCategoriesToSelectStateLoading():
return loading(_that);case _GetCategoriesToSelectStateSuccess():
return success(_that);case _GetCategoriesToSelectStateFailure():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetCategoriesToSelectStateInitial value)?  initial,TResult? Function( _GetCategoriesToSelectStateLoading value)?  loading,TResult? Function( _GetCategoriesToSelectStateSuccess value)?  success,TResult? Function( _GetCategoriesToSelectStateFailure value)?  error,}){
final _that = this;
switch (_that) {
case _GetCategoriesToSelectStateInitial() when initial != null:
return initial(_that);case _GetCategoriesToSelectStateLoading() when loading != null:
return loading(_that);case _GetCategoriesToSelectStateSuccess() when success != null:
return success(_that);case _GetCategoriesToSelectStateFailure() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<HazardCategory> categories)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetCategoriesToSelectStateInitial() when initial != null:
return initial();case _GetCategoriesToSelectStateLoading() when loading != null:
return loading();case _GetCategoriesToSelectStateSuccess() when success != null:
return success(_that.categories);case _GetCategoriesToSelectStateFailure() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<HazardCategory> categories)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _GetCategoriesToSelectStateInitial():
return initial();case _GetCategoriesToSelectStateLoading():
return loading();case _GetCategoriesToSelectStateSuccess():
return success(_that.categories);case _GetCategoriesToSelectStateFailure():
return error(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<HazardCategory> categories)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _GetCategoriesToSelectStateInitial() when initial != null:
return initial();case _GetCategoriesToSelectStateLoading() when loading != null:
return loading();case _GetCategoriesToSelectStateSuccess() when success != null:
return success(_that.categories);case _GetCategoriesToSelectStateFailure() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetCategoriesToSelectStateInitial implements GetCategoriesToSelectState {
  const _GetCategoriesToSelectStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetCategoriesToSelectStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetCategoriesToSelectState.initial()';
}


}




/// @nodoc


class _GetCategoriesToSelectStateLoading implements GetCategoriesToSelectState {
  const _GetCategoriesToSelectStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetCategoriesToSelectStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetCategoriesToSelectState.loading()';
}


}




/// @nodoc


class _GetCategoriesToSelectStateSuccess implements GetCategoriesToSelectState {
  const _GetCategoriesToSelectStateSuccess(final  List<HazardCategory> categories): _categories = categories;
  

 final  List<HazardCategory> _categories;
 List<HazardCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of GetCategoriesToSelectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetCategoriesToSelectStateSuccessCopyWith<_GetCategoriesToSelectStateSuccess> get copyWith => __$GetCategoriesToSelectStateSuccessCopyWithImpl<_GetCategoriesToSelectStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetCategoriesToSelectStateSuccess&&const DeepCollectionEquality().equals(other._categories, _categories));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'GetCategoriesToSelectState.success(categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$GetCategoriesToSelectStateSuccessCopyWith<$Res> implements $GetCategoriesToSelectStateCopyWith<$Res> {
  factory _$GetCategoriesToSelectStateSuccessCopyWith(_GetCategoriesToSelectStateSuccess value, $Res Function(_GetCategoriesToSelectStateSuccess) _then) = __$GetCategoriesToSelectStateSuccessCopyWithImpl;
@useResult
$Res call({
 List<HazardCategory> categories
});




}
/// @nodoc
class __$GetCategoriesToSelectStateSuccessCopyWithImpl<$Res>
    implements _$GetCategoriesToSelectStateSuccessCopyWith<$Res> {
  __$GetCategoriesToSelectStateSuccessCopyWithImpl(this._self, this._then);

  final _GetCategoriesToSelectStateSuccess _self;
  final $Res Function(_GetCategoriesToSelectStateSuccess) _then;

/// Create a copy of GetCategoriesToSelectState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? categories = null,}) {
  return _then(_GetCategoriesToSelectStateSuccess(
null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<HazardCategory>,
  ));
}


}

/// @nodoc


class _GetCategoriesToSelectStateFailure implements GetCategoriesToSelectState {
  const _GetCategoriesToSelectStateFailure(this.error);
  

 final  AppError error;

/// Create a copy of GetCategoriesToSelectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetCategoriesToSelectStateFailureCopyWith<_GetCategoriesToSelectStateFailure> get copyWith => __$GetCategoriesToSelectStateFailureCopyWithImpl<_GetCategoriesToSelectStateFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetCategoriesToSelectStateFailure&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetCategoriesToSelectState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetCategoriesToSelectStateFailureCopyWith<$Res> implements $GetCategoriesToSelectStateCopyWith<$Res> {
  factory _$GetCategoriesToSelectStateFailureCopyWith(_GetCategoriesToSelectStateFailure value, $Res Function(_GetCategoriesToSelectStateFailure) _then) = __$GetCategoriesToSelectStateFailureCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GetCategoriesToSelectStateFailureCopyWithImpl<$Res>
    implements _$GetCategoriesToSelectStateFailureCopyWith<$Res> {
  __$GetCategoriesToSelectStateFailureCopyWithImpl(this._self, this._then);

  final _GetCategoriesToSelectStateFailure _self;
  final $Res Function(_GetCategoriesToSelectStateFailure) _then;

/// Create a copy of GetCategoriesToSelectState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GetCategoriesToSelectStateFailure(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetCategoriesToSelectState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res> get error {
  
  return $AppErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

/// @nodoc
mixin _$CreatingUpdatingHazardReport {

 String get id; Hazard get hazard; CreatingUpdatingHazardReportState get state;
/// Create a copy of CreatingUpdatingHazardReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatingUpdatingHazardReportCopyWith<CreatingUpdatingHazardReport> get copyWith => _$CreatingUpdatingHazardReportCopyWithImpl<CreatingUpdatingHazardReport>(this as CreatingUpdatingHazardReport, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatingUpdatingHazardReport&&(identical(other.id, id) || other.id == id)&&(identical(other.hazard, hazard) || other.hazard == hazard)&&(identical(other.state, state) || other.state == state));
}


@override
int get hashCode => Object.hash(runtimeType,id,hazard,state);

@override
String toString() {
  return 'CreatingUpdatingHazardReport(id: $id, hazard: $hazard, state: $state)';
}


}

/// @nodoc
abstract mixin class $CreatingUpdatingHazardReportCopyWith<$Res>  {
  factory $CreatingUpdatingHazardReportCopyWith(CreatingUpdatingHazardReport value, $Res Function(CreatingUpdatingHazardReport) _then) = _$CreatingUpdatingHazardReportCopyWithImpl;
@useResult
$Res call({
 String id, Hazard hazard, CreatingUpdatingHazardReportState state
});


$HazardCopyWith<$Res> get hazard;$CreatingUpdatingHazardReportStateCopyWith<$Res> get state;

}
/// @nodoc
class _$CreatingUpdatingHazardReportCopyWithImpl<$Res>
    implements $CreatingUpdatingHazardReportCopyWith<$Res> {
  _$CreatingUpdatingHazardReportCopyWithImpl(this._self, this._then);

  final CreatingUpdatingHazardReport _self;
  final $Res Function(CreatingUpdatingHazardReport) _then;

/// Create a copy of CreatingUpdatingHazardReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hazard = null,Object? state = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hazard: null == hazard ? _self.hazard : hazard // ignore: cast_nullable_to_non_nullable
as Hazard,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CreatingUpdatingHazardReportState,
  ));
}
/// Create a copy of CreatingUpdatingHazardReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HazardCopyWith<$Res> get hazard {
  
  return $HazardCopyWith<$Res>(_self.hazard, (value) {
    return _then(_self.copyWith(hazard: value));
  });
}/// Create a copy of CreatingUpdatingHazardReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatingUpdatingHazardReportStateCopyWith<$Res> get state {
  
  return $CreatingUpdatingHazardReportStateCopyWith<$Res>(_self.state, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreatingUpdatingHazardReport].
extension CreatingUpdatingHazardReportPatterns on CreatingUpdatingHazardReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatingUpdatingHazardReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatingUpdatingHazardReport value)  $default,){
final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatingUpdatingHazardReport value)?  $default,){
final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Hazard hazard,  CreatingUpdatingHazardReportState state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReport() when $default != null:
return $default(_that.id,_that.hazard,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Hazard hazard,  CreatingUpdatingHazardReportState state)  $default,) {final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReport():
return $default(_that.id,_that.hazard,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Hazard hazard,  CreatingUpdatingHazardReportState state)?  $default,) {final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReport() when $default != null:
return $default(_that.id,_that.hazard,_that.state);case _:
  return null;

}
}

}

/// @nodoc


class _CreatingUpdatingHazardReport implements CreatingUpdatingHazardReport {
  const _CreatingUpdatingHazardReport({required this.id, required this.hazard, required this.state});
  

@override final  String id;
@override final  Hazard hazard;
@override final  CreatingUpdatingHazardReportState state;

/// Create a copy of CreatingUpdatingHazardReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatingUpdatingHazardReportCopyWith<_CreatingUpdatingHazardReport> get copyWith => __$CreatingUpdatingHazardReportCopyWithImpl<_CreatingUpdatingHazardReport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatingUpdatingHazardReport&&(identical(other.id, id) || other.id == id)&&(identical(other.hazard, hazard) || other.hazard == hazard)&&(identical(other.state, state) || other.state == state));
}


@override
int get hashCode => Object.hash(runtimeType,id,hazard,state);

@override
String toString() {
  return 'CreatingUpdatingHazardReport(id: $id, hazard: $hazard, state: $state)';
}


}

/// @nodoc
abstract mixin class _$CreatingUpdatingHazardReportCopyWith<$Res> implements $CreatingUpdatingHazardReportCopyWith<$Res> {
  factory _$CreatingUpdatingHazardReportCopyWith(_CreatingUpdatingHazardReport value, $Res Function(_CreatingUpdatingHazardReport) _then) = __$CreatingUpdatingHazardReportCopyWithImpl;
@override @useResult
$Res call({
 String id, Hazard hazard, CreatingUpdatingHazardReportState state
});


@override $HazardCopyWith<$Res> get hazard;@override $CreatingUpdatingHazardReportStateCopyWith<$Res> get state;

}
/// @nodoc
class __$CreatingUpdatingHazardReportCopyWithImpl<$Res>
    implements _$CreatingUpdatingHazardReportCopyWith<$Res> {
  __$CreatingUpdatingHazardReportCopyWithImpl(this._self, this._then);

  final _CreatingUpdatingHazardReport _self;
  final $Res Function(_CreatingUpdatingHazardReport) _then;

/// Create a copy of CreatingUpdatingHazardReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hazard = null,Object? state = null,}) {
  return _then(_CreatingUpdatingHazardReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hazard: null == hazard ? _self.hazard : hazard // ignore: cast_nullable_to_non_nullable
as Hazard,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CreatingUpdatingHazardReportState,
  ));
}

/// Create a copy of CreatingUpdatingHazardReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HazardCopyWith<$Res> get hazard {
  
  return $HazardCopyWith<$Res>(_self.hazard, (value) {
    return _then(_self.copyWith(hazard: value));
  });
}/// Create a copy of CreatingUpdatingHazardReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatingUpdatingHazardReportStateCopyWith<$Res> get state {
  
  return $CreatingUpdatingHazardReportStateCopyWith<$Res>(_self.state, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}

/// @nodoc
mixin _$CreatingUpdatingHazardReportState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatingUpdatingHazardReportState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreatingUpdatingHazardReportState()';
}


}

/// @nodoc
class $CreatingUpdatingHazardReportStateCopyWith<$Res>  {
$CreatingUpdatingHazardReportStateCopyWith(CreatingUpdatingHazardReportState _, $Res Function(CreatingUpdatingHazardReportState) __);
}


/// Adds pattern-matching-related methods to [CreatingUpdatingHazardReportState].
extension CreatingUpdatingHazardReportStatePatterns on CreatingUpdatingHazardReportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CreatingUpdatingHazardReportStateInitial value)?  initial,TResult Function( _CreatingUpdatingHazardReportStateLoading value)?  loading,TResult Function( _CreatingUpdatingHazardReportStateSuccess value)?  success,TResult Function( _CreatingUpdatingHazardReportStateFailure value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReportStateInitial() when initial != null:
return initial(_that);case _CreatingUpdatingHazardReportStateLoading() when loading != null:
return loading(_that);case _CreatingUpdatingHazardReportStateSuccess() when success != null:
return success(_that);case _CreatingUpdatingHazardReportStateFailure() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CreatingUpdatingHazardReportStateInitial value)  initial,required TResult Function( _CreatingUpdatingHazardReportStateLoading value)  loading,required TResult Function( _CreatingUpdatingHazardReportStateSuccess value)  success,required TResult Function( _CreatingUpdatingHazardReportStateFailure value)  error,}){
final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReportStateInitial():
return initial(_that);case _CreatingUpdatingHazardReportStateLoading():
return loading(_that);case _CreatingUpdatingHazardReportStateSuccess():
return success(_that);case _CreatingUpdatingHazardReportStateFailure():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CreatingUpdatingHazardReportStateInitial value)?  initial,TResult? Function( _CreatingUpdatingHazardReportStateLoading value)?  loading,TResult? Function( _CreatingUpdatingHazardReportStateSuccess value)?  success,TResult? Function( _CreatingUpdatingHazardReportStateFailure value)?  error,}){
final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReportStateInitial() when initial != null:
return initial(_that);case _CreatingUpdatingHazardReportStateLoading() when loading != null:
return loading(_that);case _CreatingUpdatingHazardReportStateSuccess() when success != null:
return success(_that);case _CreatingUpdatingHazardReportStateFailure() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Hazard hazard)?  success,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReportStateInitial() when initial != null:
return initial();case _CreatingUpdatingHazardReportStateLoading() when loading != null:
return loading();case _CreatingUpdatingHazardReportStateSuccess() when success != null:
return success(_that.hazard);case _CreatingUpdatingHazardReportStateFailure() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Hazard hazard)  success,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReportStateInitial():
return initial();case _CreatingUpdatingHazardReportStateLoading():
return loading();case _CreatingUpdatingHazardReportStateSuccess():
return success(_that.hazard);case _CreatingUpdatingHazardReportStateFailure():
return error(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Hazard hazard)?  success,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case _CreatingUpdatingHazardReportStateInitial() when initial != null:
return initial();case _CreatingUpdatingHazardReportStateLoading() when loading != null:
return loading();case _CreatingUpdatingHazardReportStateSuccess() when success != null:
return success(_that.hazard);case _CreatingUpdatingHazardReportStateFailure() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CreatingUpdatingHazardReportStateInitial implements CreatingUpdatingHazardReportState {
  const _CreatingUpdatingHazardReportStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatingUpdatingHazardReportStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreatingUpdatingHazardReportState.initial()';
}


}




/// @nodoc


class _CreatingUpdatingHazardReportStateLoading implements CreatingUpdatingHazardReportState {
  const _CreatingUpdatingHazardReportStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatingUpdatingHazardReportStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreatingUpdatingHazardReportState.loading()';
}


}




/// @nodoc


class _CreatingUpdatingHazardReportStateSuccess implements CreatingUpdatingHazardReportState {
  const _CreatingUpdatingHazardReportStateSuccess(this.hazard);
  

 final  Hazard hazard;

/// Create a copy of CreatingUpdatingHazardReportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatingUpdatingHazardReportStateSuccessCopyWith<_CreatingUpdatingHazardReportStateSuccess> get copyWith => __$CreatingUpdatingHazardReportStateSuccessCopyWithImpl<_CreatingUpdatingHazardReportStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatingUpdatingHazardReportStateSuccess&&(identical(other.hazard, hazard) || other.hazard == hazard));
}


@override
int get hashCode => Object.hash(runtimeType,hazard);

@override
String toString() {
  return 'CreatingUpdatingHazardReportState.success(hazard: $hazard)';
}


}

/// @nodoc
abstract mixin class _$CreatingUpdatingHazardReportStateSuccessCopyWith<$Res> implements $CreatingUpdatingHazardReportStateCopyWith<$Res> {
  factory _$CreatingUpdatingHazardReportStateSuccessCopyWith(_CreatingUpdatingHazardReportStateSuccess value, $Res Function(_CreatingUpdatingHazardReportStateSuccess) _then) = __$CreatingUpdatingHazardReportStateSuccessCopyWithImpl;
@useResult
$Res call({
 Hazard hazard
});


$HazardCopyWith<$Res> get hazard;

}
/// @nodoc
class __$CreatingUpdatingHazardReportStateSuccessCopyWithImpl<$Res>
    implements _$CreatingUpdatingHazardReportStateSuccessCopyWith<$Res> {
  __$CreatingUpdatingHazardReportStateSuccessCopyWithImpl(this._self, this._then);

  final _CreatingUpdatingHazardReportStateSuccess _self;
  final $Res Function(_CreatingUpdatingHazardReportStateSuccess) _then;

/// Create a copy of CreatingUpdatingHazardReportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hazard = null,}) {
  return _then(_CreatingUpdatingHazardReportStateSuccess(
null == hazard ? _self.hazard : hazard // ignore: cast_nullable_to_non_nullable
as Hazard,
  ));
}

/// Create a copy of CreatingUpdatingHazardReportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HazardCopyWith<$Res> get hazard {
  
  return $HazardCopyWith<$Res>(_self.hazard, (value) {
    return _then(_self.copyWith(hazard: value));
  });
}
}

/// @nodoc


class _CreatingUpdatingHazardReportStateFailure implements CreatingUpdatingHazardReportState {
  const _CreatingUpdatingHazardReportStateFailure(this.error);
  

 final  AppError error;

/// Create a copy of CreatingUpdatingHazardReportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatingUpdatingHazardReportStateFailureCopyWith<_CreatingUpdatingHazardReportStateFailure> get copyWith => __$CreatingUpdatingHazardReportStateFailureCopyWithImpl<_CreatingUpdatingHazardReportStateFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatingUpdatingHazardReportStateFailure&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'CreatingUpdatingHazardReportState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$CreatingUpdatingHazardReportStateFailureCopyWith<$Res> implements $CreatingUpdatingHazardReportStateCopyWith<$Res> {
  factory _$CreatingUpdatingHazardReportStateFailureCopyWith(_CreatingUpdatingHazardReportStateFailure value, $Res Function(_CreatingUpdatingHazardReportStateFailure) _then) = __$CreatingUpdatingHazardReportStateFailureCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$CreatingUpdatingHazardReportStateFailureCopyWithImpl<$Res>
    implements _$CreatingUpdatingHazardReportStateFailureCopyWith<$Res> {
  __$CreatingUpdatingHazardReportStateFailureCopyWithImpl(this._self, this._then);

  final _CreatingUpdatingHazardReportStateFailure _self;
  final $Res Function(_CreatingUpdatingHazardReportStateFailure) _then;

/// Create a copy of CreatingUpdatingHazardReportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_CreatingUpdatingHazardReportStateFailure(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of CreatingUpdatingHazardReportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res> get error {
  
  return $AppErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
