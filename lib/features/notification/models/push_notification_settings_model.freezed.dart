// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'push_notification_settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PushNotificationSettings {

/// Whether AWS Emergency level "Emergency" is selected.
 bool get awsEmergency;/// Whether AWS Emergency level "Watch and Act" is selected.
 bool get awsWatchAndAct;/// Whether AWS Emergency level "Advice" is selected.
 bool get awsAdvice;/// Whether Official Non-AWS sources are selected.
 bool get officialNonAws;/// Whether User Reported sources are selected.
 bool get userReported;/// The IDs of the categories the user is subscribed to.
 Set<String> get subscribedCategoryIds;
/// Create a copy of PushNotificationSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushNotificationSettingsCopyWith<PushNotificationSettings> get copyWith => _$PushNotificationSettingsCopyWithImpl<PushNotificationSettings>(this as PushNotificationSettings, _$identity);

  /// Serializes this PushNotificationSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushNotificationSettings&&(identical(other.awsEmergency, awsEmergency) || other.awsEmergency == awsEmergency)&&(identical(other.awsWatchAndAct, awsWatchAndAct) || other.awsWatchAndAct == awsWatchAndAct)&&(identical(other.awsAdvice, awsAdvice) || other.awsAdvice == awsAdvice)&&(identical(other.officialNonAws, officialNonAws) || other.officialNonAws == officialNonAws)&&(identical(other.userReported, userReported) || other.userReported == userReported)&&const DeepCollectionEquality().equals(other.subscribedCategoryIds, subscribedCategoryIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,awsEmergency,awsWatchAndAct,awsAdvice,officialNonAws,userReported,const DeepCollectionEquality().hash(subscribedCategoryIds));

@override
String toString() {
  return 'PushNotificationSettings(awsEmergency: $awsEmergency, awsWatchAndAct: $awsWatchAndAct, awsAdvice: $awsAdvice, officialNonAws: $officialNonAws, userReported: $userReported, subscribedCategoryIds: $subscribedCategoryIds)';
}


}

/// @nodoc
abstract mixin class $PushNotificationSettingsCopyWith<$Res>  {
  factory $PushNotificationSettingsCopyWith(PushNotificationSettings value, $Res Function(PushNotificationSettings) _then) = _$PushNotificationSettingsCopyWithImpl;
@useResult
$Res call({
 bool awsEmergency, bool awsWatchAndAct, bool awsAdvice, bool officialNonAws, bool userReported, Set<String> subscribedCategoryIds
});




}
/// @nodoc
class _$PushNotificationSettingsCopyWithImpl<$Res>
    implements $PushNotificationSettingsCopyWith<$Res> {
  _$PushNotificationSettingsCopyWithImpl(this._self, this._then);

  final PushNotificationSettings _self;
  final $Res Function(PushNotificationSettings) _then;

/// Create a copy of PushNotificationSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? awsEmergency = null,Object? awsWatchAndAct = null,Object? awsAdvice = null,Object? officialNonAws = null,Object? userReported = null,Object? subscribedCategoryIds = null,}) {
  return _then(_self.copyWith(
awsEmergency: null == awsEmergency ? _self.awsEmergency : awsEmergency // ignore: cast_nullable_to_non_nullable
as bool,awsWatchAndAct: null == awsWatchAndAct ? _self.awsWatchAndAct : awsWatchAndAct // ignore: cast_nullable_to_non_nullable
as bool,awsAdvice: null == awsAdvice ? _self.awsAdvice : awsAdvice // ignore: cast_nullable_to_non_nullable
as bool,officialNonAws: null == officialNonAws ? _self.officialNonAws : officialNonAws // ignore: cast_nullable_to_non_nullable
as bool,userReported: null == userReported ? _self.userReported : userReported // ignore: cast_nullable_to_non_nullable
as bool,subscribedCategoryIds: null == subscribedCategoryIds ? _self.subscribedCategoryIds : subscribedCategoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PushNotificationSettings].
extension PushNotificationSettingsPatterns on PushNotificationSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PushNotificationSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PushNotificationSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PushNotificationSettings value)  $default,){
final _that = this;
switch (_that) {
case _PushNotificationSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PushNotificationSettings value)?  $default,){
final _that = this;
switch (_that) {
case _PushNotificationSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool awsEmergency,  bool awsWatchAndAct,  bool awsAdvice,  bool officialNonAws,  bool userReported,  Set<String> subscribedCategoryIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PushNotificationSettings() when $default != null:
return $default(_that.awsEmergency,_that.awsWatchAndAct,_that.awsAdvice,_that.officialNonAws,_that.userReported,_that.subscribedCategoryIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool awsEmergency,  bool awsWatchAndAct,  bool awsAdvice,  bool officialNonAws,  bool userReported,  Set<String> subscribedCategoryIds)  $default,) {final _that = this;
switch (_that) {
case _PushNotificationSettings():
return $default(_that.awsEmergency,_that.awsWatchAndAct,_that.awsAdvice,_that.officialNonAws,_that.userReported,_that.subscribedCategoryIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool awsEmergency,  bool awsWatchAndAct,  bool awsAdvice,  bool officialNonAws,  bool userReported,  Set<String> subscribedCategoryIds)?  $default,) {final _that = this;
switch (_that) {
case _PushNotificationSettings() when $default != null:
return $default(_that.awsEmergency,_that.awsWatchAndAct,_that.awsAdvice,_that.officialNonAws,_that.userReported,_that.subscribedCategoryIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PushNotificationSettings extends PushNotificationSettings {
  const _PushNotificationSettings({this.awsEmergency = false, this.awsWatchAndAct = false, this.awsAdvice = false, this.officialNonAws = false, this.userReported = false, final  Set<String> subscribedCategoryIds = const <String>{}}): _subscribedCategoryIds = subscribedCategoryIds,super._();
  factory _PushNotificationSettings.fromJson(Map<String, dynamic> json) => _$PushNotificationSettingsFromJson(json);

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
/// The IDs of the categories the user is subscribed to.
 final  Set<String> _subscribedCategoryIds;
/// The IDs of the categories the user is subscribed to.
@override@JsonKey() Set<String> get subscribedCategoryIds {
  if (_subscribedCategoryIds is EqualUnmodifiableSetView) return _subscribedCategoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_subscribedCategoryIds);
}


/// Create a copy of PushNotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PushNotificationSettingsCopyWith<_PushNotificationSettings> get copyWith => __$PushNotificationSettingsCopyWithImpl<_PushNotificationSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PushNotificationSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PushNotificationSettings&&(identical(other.awsEmergency, awsEmergency) || other.awsEmergency == awsEmergency)&&(identical(other.awsWatchAndAct, awsWatchAndAct) || other.awsWatchAndAct == awsWatchAndAct)&&(identical(other.awsAdvice, awsAdvice) || other.awsAdvice == awsAdvice)&&(identical(other.officialNonAws, officialNonAws) || other.officialNonAws == officialNonAws)&&(identical(other.userReported, userReported) || other.userReported == userReported)&&const DeepCollectionEquality().equals(other._subscribedCategoryIds, _subscribedCategoryIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,awsEmergency,awsWatchAndAct,awsAdvice,officialNonAws,userReported,const DeepCollectionEquality().hash(_subscribedCategoryIds));

@override
String toString() {
  return 'PushNotificationSettings(awsEmergency: $awsEmergency, awsWatchAndAct: $awsWatchAndAct, awsAdvice: $awsAdvice, officialNonAws: $officialNonAws, userReported: $userReported, subscribedCategoryIds: $subscribedCategoryIds)';
}


}

/// @nodoc
abstract mixin class _$PushNotificationSettingsCopyWith<$Res> implements $PushNotificationSettingsCopyWith<$Res> {
  factory _$PushNotificationSettingsCopyWith(_PushNotificationSettings value, $Res Function(_PushNotificationSettings) _then) = __$PushNotificationSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool awsEmergency, bool awsWatchAndAct, bool awsAdvice, bool officialNonAws, bool userReported, Set<String> subscribedCategoryIds
});




}
/// @nodoc
class __$PushNotificationSettingsCopyWithImpl<$Res>
    implements _$PushNotificationSettingsCopyWith<$Res> {
  __$PushNotificationSettingsCopyWithImpl(this._self, this._then);

  final _PushNotificationSettings _self;
  final $Res Function(_PushNotificationSettings) _then;

/// Create a copy of PushNotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? awsEmergency = null,Object? awsWatchAndAct = null,Object? awsAdvice = null,Object? officialNonAws = null,Object? userReported = null,Object? subscribedCategoryIds = null,}) {
  return _then(_PushNotificationSettings(
awsEmergency: null == awsEmergency ? _self.awsEmergency : awsEmergency // ignore: cast_nullable_to_non_nullable
as bool,awsWatchAndAct: null == awsWatchAndAct ? _self.awsWatchAndAct : awsWatchAndAct // ignore: cast_nullable_to_non_nullable
as bool,awsAdvice: null == awsAdvice ? _self.awsAdvice : awsAdvice // ignore: cast_nullable_to_non_nullable
as bool,officialNonAws: null == officialNonAws ? _self.officialNonAws : officialNonAws // ignore: cast_nullable_to_non_nullable
as bool,userReported: null == userReported ? _self.userReported : userReported // ignore: cast_nullable_to_non_nullable
as bool,subscribedCategoryIds: null == subscribedCategoryIds ? _self._subscribedCategoryIds : subscribedCategoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
