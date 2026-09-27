// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hazard_source_license_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HazardSourceLicense _$HazardSourceLicenseFromJson(Map<String, dynamic> json) =>
    _HazardSourceLicense(
      badgeText: json['badgeText'] as String,
      licenseText: json['licenseText'] as String,
      backgroundColor: json['backgroundColor'] == null
          ? AppColors.extraLightblue
          : const ColorConverter().fromJson(json['backgroundColor'] as String),
      foregroundColor: json['foregroundColor'] == null
          ? AppColors.blue
          : const ColorConverter().fromJson(json['foregroundColor'] as String),
      link: json['link'] as String?,
    );

Map<String, dynamic> _$HazardSourceLicenseToJson(
  _HazardSourceLicense instance,
) => <String, dynamic>{
  'badgeText': instance.badgeText,
  'licenseText': instance.licenseText,
  'backgroundColor': const ColorConverter().toJson(instance.backgroundColor),
  'foregroundColor': const ColorConverter().toJson(instance.foregroundColor),
  'link': ?instance.link,
};
