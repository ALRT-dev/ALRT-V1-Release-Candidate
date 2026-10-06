// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hazard_source_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HazardSource _$HazardSourceFromJson(Map<String, dynamic> json) =>
    _HazardSource(
      id: json['id'] as String,
      name: json['name'] as String?,
      url: json['url'] as String?,
      license: json['license'] == null
          ? null
          : HazardSourceLicense.fromJson(
              json['license'] as Map<String, dynamic>,
            ),
      copyrightText: json['copyrightText'] as String?,
      copyrightLink: json['copyrightLink'] as String?,
      advisoryText: json['advisoryText'] as String?,
      shape: $enumDecodeNullable(
        _$HazardSourceShapeEnumMap,
        json['shape'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
    );

Map<String, dynamic> _$HazardSourceToJson(_HazardSource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': ?instance.name,
      'url': ?instance.url,
      'license': ?instance.license?.toJson(),
      'copyrightText': ?instance.copyrightText,
      'copyrightLink': ?instance.copyrightLink,
      'advisoryText': ?instance.advisoryText,
      'shape': ?_$HazardSourceShapeEnumMap[instance.shape],
    };

const _$HazardSourceShapeEnumMap = {
  HazardSourceShape.triangle: 'triangle',
  HazardSourceShape.diamond: 'diamond',
  HazardSourceShape.circle: 'circle',
  HazardSourceShape.square: 'square',
  HazardSourceShape.shield: 'shield',
};
