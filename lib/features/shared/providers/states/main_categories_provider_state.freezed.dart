// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_categories_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MainCategoriesProviderState {

/// The list of main hazard categories.
 List<HazardCategory> get mainCategories;/// The state of getting main categories.
 GetMainCategoriesState get getMainCategoriesState;
/// Create a copy of MainCategoriesProviderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MainCategoriesProviderStateCopyWith<MainCategoriesProviderState> get copyWith => _$MainCategoriesProviderStateCopyWithImpl<MainCategoriesProviderState>(this as MainCategoriesProviderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MainCategoriesProviderState&&const DeepCollectionEquality().equals(other.mainCategories, mainCategories)&&(identical(other.getMainCategoriesState, getMainCategoriesState) || other.getMainCategoriesState == getMainCategoriesState));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mainCategories),getMainCategoriesState);

@override
String toString() {
  return 'MainCategoriesProviderState(mainCategories: $mainCategories, getMainCategoriesState: $getMainCategoriesState)';
}


}

/// @nodoc
abstract mixin class $MainCategoriesProviderStateCopyWith<$Res>  {
  factory $MainCategoriesProviderStateCopyWith(MainCategoriesProviderState value, $Res Function(MainCategoriesProviderState) _then) = _$MainCategoriesProviderStateCopyWithImpl;
@useResult
$Res call({
 List<HazardCategory> mainCategories, GetMainCategoriesState getMainCategoriesState
});


$GetMainCategoriesStateCopyWith<$Res> get getMainCategoriesState;

}
/// @nodoc
class _$MainCategoriesProviderStateCopyWithImpl<$Res>
    implements $MainCategoriesProviderStateCopyWith<$Res> {
  _$MainCategoriesProviderStateCopyWithImpl(this._self, this._then);

  final MainCategoriesProviderState _self;
  final $Res Function(MainCategoriesProviderState) _then;

/// Create a copy of MainCategoriesProviderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mainCategories = null,Object? getMainCategoriesState = null,}) {
  return _then(_self.copyWith(
mainCategories: null == mainCategories ? _self.mainCategories : mainCategories // ignore: cast_nullable_to_non_nullable
as List<HazardCategory>,getMainCategoriesState: null == getMainCategoriesState ? _self.getMainCategoriesState : getMainCategoriesState // ignore: cast_nullable_to_non_nullable
as GetMainCategoriesState,
  ));
}
/// Create a copy of MainCategoriesProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetMainCategoriesStateCopyWith<$Res> get getMainCategoriesState {
  
  return $GetMainCategoriesStateCopyWith<$Res>(_self.getMainCategoriesState, (value) {
    return _then(_self.copyWith(getMainCategoriesState: value));
  });
}
}


/// Adds pattern-matching-related methods to [MainCategoriesProviderState].
extension MainCategoriesProviderStatePatterns on MainCategoriesProviderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MainCategoriesProviderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MainCategoriesProviderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MainCategoriesProviderState value)  $default,){
final _that = this;
switch (_that) {
case _MainCategoriesProviderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MainCategoriesProviderState value)?  $default,){
final _that = this;
switch (_that) {
case _MainCategoriesProviderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HazardCategory> mainCategories,  GetMainCategoriesState getMainCategoriesState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MainCategoriesProviderState() when $default != null:
return $default(_that.mainCategories,_that.getMainCategoriesState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HazardCategory> mainCategories,  GetMainCategoriesState getMainCategoriesState)  $default,) {final _that = this;
switch (_that) {
case _MainCategoriesProviderState():
return $default(_that.mainCategories,_that.getMainCategoriesState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HazardCategory> mainCategories,  GetMainCategoriesState getMainCategoriesState)?  $default,) {final _that = this;
switch (_that) {
case _MainCategoriesProviderState() when $default != null:
return $default(_that.mainCategories,_that.getMainCategoriesState);case _:
  return null;

}
}

}

/// @nodoc


class _MainCategoriesProviderState implements MainCategoriesProviderState {
  const _MainCategoriesProviderState({final  List<HazardCategory> mainCategories = const <HazardCategory>[], this.getMainCategoriesState = const GetMainCategoriesState.initial()}): _mainCategories = mainCategories;
  

/// The list of main hazard categories.
 final  List<HazardCategory> _mainCategories;
/// The list of main hazard categories.
@override@JsonKey() List<HazardCategory> get mainCategories {
  if (_mainCategories is EqualUnmodifiableListView) return _mainCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mainCategories);
}

/// The state of getting main categories.
@override@JsonKey() final  GetMainCategoriesState getMainCategoriesState;

/// Create a copy of MainCategoriesProviderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MainCategoriesProviderStateCopyWith<_MainCategoriesProviderState> get copyWith => __$MainCategoriesProviderStateCopyWithImpl<_MainCategoriesProviderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MainCategoriesProviderState&&const DeepCollectionEquality().equals(other._mainCategories, _mainCategories)&&(identical(other.getMainCategoriesState, getMainCategoriesState) || other.getMainCategoriesState == getMainCategoriesState));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mainCategories),getMainCategoriesState);

@override
String toString() {
  return 'MainCategoriesProviderState(mainCategories: $mainCategories, getMainCategoriesState: $getMainCategoriesState)';
}


}

/// @nodoc
abstract mixin class _$MainCategoriesProviderStateCopyWith<$Res> implements $MainCategoriesProviderStateCopyWith<$Res> {
  factory _$MainCategoriesProviderStateCopyWith(_MainCategoriesProviderState value, $Res Function(_MainCategoriesProviderState) _then) = __$MainCategoriesProviderStateCopyWithImpl;
@override @useResult
$Res call({
 List<HazardCategory> mainCategories, GetMainCategoriesState getMainCategoriesState
});


@override $GetMainCategoriesStateCopyWith<$Res> get getMainCategoriesState;

}
/// @nodoc
class __$MainCategoriesProviderStateCopyWithImpl<$Res>
    implements _$MainCategoriesProviderStateCopyWith<$Res> {
  __$MainCategoriesProviderStateCopyWithImpl(this._self, this._then);

  final _MainCategoriesProviderState _self;
  final $Res Function(_MainCategoriesProviderState) _then;

/// Create a copy of MainCategoriesProviderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mainCategories = null,Object? getMainCategoriesState = null,}) {
  return _then(_MainCategoriesProviderState(
mainCategories: null == mainCategories ? _self._mainCategories : mainCategories // ignore: cast_nullable_to_non_nullable
as List<HazardCategory>,getMainCategoriesState: null == getMainCategoriesState ? _self.getMainCategoriesState : getMainCategoriesState // ignore: cast_nullable_to_non_nullable
as GetMainCategoriesState,
  ));
}

/// Create a copy of MainCategoriesProviderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetMainCategoriesStateCopyWith<$Res> get getMainCategoriesState {
  
  return $GetMainCategoriesStateCopyWith<$Res>(_self.getMainCategoriesState, (value) {
    return _then(_self.copyWith(getMainCategoriesState: value));
  });
}
}

/// @nodoc
mixin _$GetMainCategoriesState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMainCategoriesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetMainCategoriesState()';
}


}

/// @nodoc
class $GetMainCategoriesStateCopyWith<$Res>  {
$GetMainCategoriesStateCopyWith(GetMainCategoriesState _, $Res Function(GetMainCategoriesState) __);
}


/// Adds pattern-matching-related methods to [GetMainCategoriesState].
extension GetMainCategoriesStatePatterns on GetMainCategoriesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GetMainCategoriesStateInitial value)?  initial,TResult Function( _GetMainCategoriesStateLoading value)?  loading,TResult Function( _GetMainCategoriesStateSuccess value)?  success,TResult Function( _GetMainCategoriesStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetMainCategoriesStateInitial() when initial != null:
return initial(_that);case _GetMainCategoriesStateLoading() when loading != null:
return loading(_that);case _GetMainCategoriesStateSuccess() when success != null:
return success(_that);case _GetMainCategoriesStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GetMainCategoriesStateInitial value)  initial,required TResult Function( _GetMainCategoriesStateLoading value)  loading,required TResult Function( _GetMainCategoriesStateSuccess value)  success,required TResult Function( _GetMainCategoriesStateError value)  error,}){
final _that = this;
switch (_that) {
case _GetMainCategoriesStateInitial():
return initial(_that);case _GetMainCategoriesStateLoading():
return loading(_that);case _GetMainCategoriesStateSuccess():
return success(_that);case _GetMainCategoriesStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GetMainCategoriesStateInitial value)?  initial,TResult? Function( _GetMainCategoriesStateLoading value)?  loading,TResult? Function( _GetMainCategoriesStateSuccess value)?  success,TResult? Function( _GetMainCategoriesStateError value)?  error,}){
final _that = this;
switch (_that) {
case _GetMainCategoriesStateInitial() when initial != null:
return initial(_that);case _GetMainCategoriesStateLoading() when loading != null:
return loading(_that);case _GetMainCategoriesStateSuccess() when success != null:
return success(_that);case _GetMainCategoriesStateError() when error != null:
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
case _GetMainCategoriesStateInitial() when initial != null:
return initial();case _GetMainCategoriesStateLoading() when loading != null:
return loading();case _GetMainCategoriesStateSuccess() when success != null:
return success(_that.categories);case _GetMainCategoriesStateError() when error != null:
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
case _GetMainCategoriesStateInitial():
return initial();case _GetMainCategoriesStateLoading():
return loading();case _GetMainCategoriesStateSuccess():
return success(_that.categories);case _GetMainCategoriesStateError():
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
case _GetMainCategoriesStateInitial() when initial != null:
return initial();case _GetMainCategoriesStateLoading() when loading != null:
return loading();case _GetMainCategoriesStateSuccess() when success != null:
return success(_that.categories);case _GetMainCategoriesStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GetMainCategoriesStateInitial implements GetMainCategoriesState {
  const _GetMainCategoriesStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMainCategoriesStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetMainCategoriesState.initial()';
}


}




/// @nodoc


class _GetMainCategoriesStateLoading implements GetMainCategoriesState {
  const _GetMainCategoriesStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMainCategoriesStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetMainCategoriesState.loading()';
}


}




/// @nodoc


class _GetMainCategoriesStateSuccess implements GetMainCategoriesState {
  const _GetMainCategoriesStateSuccess(final  List<HazardCategory> categories): _categories = categories;
  

 final  List<HazardCategory> _categories;
 List<HazardCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of GetMainCategoriesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetMainCategoriesStateSuccessCopyWith<_GetMainCategoriesStateSuccess> get copyWith => __$GetMainCategoriesStateSuccessCopyWithImpl<_GetMainCategoriesStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMainCategoriesStateSuccess&&const DeepCollectionEquality().equals(other._categories, _categories));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'GetMainCategoriesState.success(categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$GetMainCategoriesStateSuccessCopyWith<$Res> implements $GetMainCategoriesStateCopyWith<$Res> {
  factory _$GetMainCategoriesStateSuccessCopyWith(_GetMainCategoriesStateSuccess value, $Res Function(_GetMainCategoriesStateSuccess) _then) = __$GetMainCategoriesStateSuccessCopyWithImpl;
@useResult
$Res call({
 List<HazardCategory> categories
});




}
/// @nodoc
class __$GetMainCategoriesStateSuccessCopyWithImpl<$Res>
    implements _$GetMainCategoriesStateSuccessCopyWith<$Res> {
  __$GetMainCategoriesStateSuccessCopyWithImpl(this._self, this._then);

  final _GetMainCategoriesStateSuccess _self;
  final $Res Function(_GetMainCategoriesStateSuccess) _then;

/// Create a copy of GetMainCategoriesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? categories = null,}) {
  return _then(_GetMainCategoriesStateSuccess(
null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<HazardCategory>,
  ));
}


}

/// @nodoc


class _GetMainCategoriesStateError implements GetMainCategoriesState {
  const _GetMainCategoriesStateError(this.error);
  

 final  AppError error;

/// Create a copy of GetMainCategoriesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetMainCategoriesStateErrorCopyWith<_GetMainCategoriesStateError> get copyWith => __$GetMainCategoriesStateErrorCopyWithImpl<_GetMainCategoriesStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetMainCategoriesStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'GetMainCategoriesState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$GetMainCategoriesStateErrorCopyWith<$Res> implements $GetMainCategoriesStateCopyWith<$Res> {
  factory _$GetMainCategoriesStateErrorCopyWith(_GetMainCategoriesStateError value, $Res Function(_GetMainCategoriesStateError) _then) = __$GetMainCategoriesStateErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class __$GetMainCategoriesStateErrorCopyWithImpl<$Res>
    implements _$GetMainCategoriesStateErrorCopyWith<$Res> {
  __$GetMainCategoriesStateErrorCopyWithImpl(this._self, this._then);

  final _GetMainCategoriesStateError _self;
  final $Res Function(_GetMainCategoriesStateError) _then;

/// Create a copy of GetMainCategoriesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_GetMainCategoriesStateError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of GetMainCategoriesState
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
