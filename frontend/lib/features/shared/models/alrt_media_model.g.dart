// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alrt_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlrtMedia _$AlrtMediaFromJson(Map<String, dynamic> json) => _AlrtMedia(
  id: json['id'] as String,
  value: json['value'] as String,
  type: $enumDecode(_$AlrtMediaTypeEnumMap, json['type']),
  source: $enumDecode(_$AlrtMediaSourceEnumMap, json['source']),
  s3Key: json['s3Key'] as String?,
);

Map<String, dynamic> _$AlrtMediaToJson(_AlrtMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'type': _$AlrtMediaTypeEnumMap[instance.type]!,
      'source': _$AlrtMediaSourceEnumMap[instance.source]!,
      's3Key': ?instance.s3Key,
    };

const _$AlrtMediaTypeEnumMap = {
  AlrtMediaType.unknown: 'unknown',
  AlrtMediaType.image: 'image',
  AlrtMediaType.video: 'video',
};

const _$AlrtMediaSourceEnumMap = {
  AlrtMediaSource.file: 'file',
  AlrtMediaSource.networkUrl: 'networkUrl',
  AlrtMediaSource.asset: 'asset',
};
