// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryImage _$CategoryImageFromJson(Map<String, dynamic> json) =>
    _CategoryImage(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      imageType: $enumDecode(_$CategoryImageTypeEnumMap, json['imageType']),
      url: json['presignedUrl'] as String,
      s3Key: json['s3Key'] as String,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CategoryImageToJson(_CategoryImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'imageType': _$CategoryImageTypeEnumMap[instance.imageType]!,
      'presignedUrl': instance.url,
      's3Key': instance.s3Key,
      'width': ?instance.width,
      'height': ?instance.height,
      'fileSizeBytes': ?instance.fileSizeBytes,
    };

const _$CategoryImageTypeEnumMap = {
  CategoryImageType.info: 'info',
  CategoryImageType.monitor: 'monitor',
  CategoryImageType.action: 'action',
  CategoryImageType.critical: 'critical',
  CategoryImageType.advice: 'advice',
  CategoryImageType.watchAndAct: 'watchAndAct',
  CategoryImageType.emergency: 'emergency',
  CategoryImageType.user: 'user',
  CategoryImageType.fireActive: 'fireActive',
  CategoryImageType.fireBeingControlled: 'fireBeingControlled',
  CategoryImageType.fireUnderControl: 'fireUnderControl',
  CategoryImageType.fireClosed: 'fireClosed',
};
