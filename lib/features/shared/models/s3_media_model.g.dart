// GENERATED CODE - DO NOT MODIFY BY HAND

part of 's3_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_S3Media _$S3MediaFromJson(Map<String, dynamic> json) => _S3Media(
  id: json['id'] as String,
  url: json['presignedUrl'] as String,
  s3Key: json['s3Key'] as String,
  type: $enumDecode(_$AlrtMediaTypeEnumMap, json['type']),
  fileSize: (json['fileSize'] as num?)?.toInt(),
  thumbnailUrl: json['thumbnailUrl'] as String?,
);

Map<String, dynamic> _$S3MediaToJson(_S3Media instance) => <String, dynamic>{
  'id': instance.id,
  'presignedUrl': instance.url,
  's3Key': instance.s3Key,
  'type': _$AlrtMediaTypeEnumMap[instance.type]!,
  'fileSize': ?instance.fileSize,
  'thumbnailUrl': ?instance.thumbnailUrl,
};

const _$AlrtMediaTypeEnumMap = {
  AlrtMediaType.unknown: 'unknown',
  AlrtMediaType.image: 'image',
  AlrtMediaType.video: 'video',
};
