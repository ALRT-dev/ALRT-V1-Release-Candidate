// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hazard_source_license_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HazardSourceLicense {

/// The badge for the hazard source license.
 String get badgeText;/// The full text of the hazard source license.
 String get licenseText;/// The background color for the hazard source license badge.
@ColorConverter() Color get backgroundColor;/// The foreground color for the hazard source license badge.
@ColorConverter() Color get foregroundColor;/// The link associated with the hazard source license.
 String? get link;
/// Create a copy of HazardSourceLicense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HazardSourceLicenseCopyWith<HazardSourceLicense> get copyWith => _$HazardSourceLicenseCopyWithImpl<HazardSourceLicense>(this as HazardSourceLicense, _$identity);

  /// Serializes this HazardSourceLicense to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HazardSourceLicense&&(identical(other.badgeText, badgeText) || other.badgeText == badgeText)&&(identical(other.licenseText, licenseText) || other.licenseText == licenseText)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor)&&(identical(other.foregroundColor, foregroundColor) || other.foregroundColor == foregroundColor)&&(identical(other.link, link) || other.link == link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,badgeText,licenseText,backgroundColor,foregroundColor,link);

@override
String toString() {
  return 'HazardSourceLicense(badgeText: $badgeText, licenseText: $licenseText, backgroundColor: $backgroundColor, foregroundColor: $foregroundColor, link: $link)';
}


}

/// @nodoc
abstract mixin class $HazardSourceLicenseCopyWith<$Res>  {
  factory $HazardSourceLicenseCopyWith(HazardSourceLicense value, $Res Function(HazardSourceLicense) _then) = _$HazardSourceLicenseCopyWithImpl;
@useResult
$Res call({
 String badgeText, String licenseText,@ColorConverter() Color backgroundColor,@ColorConverter() Color foregroundColor, String? link
});




}
/// @nodoc
class _$HazardSourceLicenseCopyWithImpl<$Res>
    implements $HazardSourceLicenseCopyWith<$Res> {
  _$HazardSourceLicenseCopyWithImpl(this._self, this._then);

  final HazardSourceLicense _self;
  final $Res Function(HazardSourceLicense) _then;

/// Create a copy of HazardSourceLicense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? badgeText = null,Object? licenseText = null,Object? backgroundColor = null,Object? foregroundColor = null,Object? link = freezed,}) {
  return _then(_self.copyWith(
badgeText: null == badgeText ? _self.badgeText : badgeText // ignore: cast_nullable_to_non_nullable
as String,licenseText: null == licenseText ? _self.licenseText : licenseText // ignore: cast_nullable_to_non_nullable
as String,backgroundColor: null == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as Color,foregroundColor: null == foregroundColor ? _self.foregroundColor : foregroundColor // ignore: cast_nullable_to_non_nullable
as Color,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HazardSourceLicense].
extension HazardSourceLicensePatterns on HazardSourceLicense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HazardSourceLicense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HazardSourceLicense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HazardSourceLicense value)  $default,){
final _that = this;
switch (_that) {
case _HazardSourceLicense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HazardSourceLicense value)?  $default,){
final _that = this;
switch (_that) {
case _HazardSourceLicense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String badgeText,  String licenseText, @ColorConverter()  Color backgroundColor, @ColorConverter()  Color foregroundColor,  String? link)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HazardSourceLicense() when $default != null:
return $default(_that.badgeText,_that.licenseText,_that.backgroundColor,_that.foregroundColor,_that.link);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String badgeText,  String licenseText, @ColorConverter()  Color backgroundColor, @ColorConverter()  Color foregroundColor,  String? link)  $default,) {final _that = this;
switch (_that) {
case _HazardSourceLicense():
return $default(_that.badgeText,_that.licenseText,_that.backgroundColor,_that.foregroundColor,_that.link);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String badgeText,  String licenseText, @ColorConverter()  Color backgroundColor, @ColorConverter()  Color foregroundColor,  String? link)?  $default,) {final _that = this;
switch (_that) {
case _HazardSourceLicense() when $default != null:
return $default(_that.badgeText,_that.licenseText,_that.backgroundColor,_that.foregroundColor,_that.link);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HazardSourceLicense implements HazardSourceLicense {
  const _HazardSourceLicense({required this.badgeText, required this.licenseText, @ColorConverter() this.backgroundColor = AppColors.extraLightblue, @ColorConverter() this.foregroundColor = AppColors.blue, this.link});
  factory _HazardSourceLicense.fromJson(Map<String, dynamic> json) => _$HazardSourceLicenseFromJson(json);

/// The badge for the hazard source license.
@override final  String badgeText;
/// The full text of the hazard source license.
@override final  String licenseText;
/// The background color for the hazard source license badge.
@override@JsonKey()@ColorConverter() final  Color backgroundColor;
/// The foreground color for the hazard source license badge.
@override@JsonKey()@ColorConverter() final  Color foregroundColor;
/// The link associated with the hazard source license.
@override final  String? link;

/// Create a copy of HazardSourceLicense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HazardSourceLicenseCopyWith<_HazardSourceLicense> get copyWith => __$HazardSourceLicenseCopyWithImpl<_HazardSourceLicense>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HazardSourceLicenseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HazardSourceLicense&&(identical(other.badgeText, badgeText) || other.badgeText == badgeText)&&(identical(other.licenseText, licenseText) || other.licenseText == licenseText)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor)&&(identical(other.foregroundColor, foregroundColor) || other.foregroundColor == foregroundColor)&&(identical(other.link, link) || other.link == link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,badgeText,licenseText,backgroundColor,foregroundColor,link);

@override
String toString() {
  return 'HazardSourceLicense(badgeText: $badgeText, licenseText: $licenseText, backgroundColor: $backgroundColor, foregroundColor: $foregroundColor, link: $link)';
}


}

/// @nodoc
abstract mixin class _$HazardSourceLicenseCopyWith<$Res> implements $HazardSourceLicenseCopyWith<$Res> {
  factory _$HazardSourceLicenseCopyWith(_HazardSourceLicense value, $Res Function(_HazardSourceLicense) _then) = __$HazardSourceLicenseCopyWithImpl;
@override @useResult
$Res call({
 String badgeText, String licenseText,@ColorConverter() Color backgroundColor,@ColorConverter() Color foregroundColor, String? link
});




}
/// @nodoc
class __$HazardSourceLicenseCopyWithImpl<$Res>
    implements _$HazardSourceLicenseCopyWith<$Res> {
  __$HazardSourceLicenseCopyWithImpl(this._self, this._then);

  final _HazardSourceLicense _self;
  final $Res Function(_HazardSourceLicense) _then;

/// Create a copy of HazardSourceLicense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? badgeText = null,Object? licenseText = null,Object? backgroundColor = null,Object? foregroundColor = null,Object? link = freezed,}) {
  return _then(_HazardSourceLicense(
badgeText: null == badgeText ? _self.badgeText : badgeText // ignore: cast_nullable_to_non_nullable
as String,licenseText: null == licenseText ? _self.licenseText : licenseText // ignore: cast_nullable_to_non_nullable
as String,backgroundColor: null == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as Color,foregroundColor: null == foregroundColor ? _self.foregroundColor : foregroundColor // ignore: cast_nullable_to_non_nullable
as Color,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
