// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_id_priority_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoIdPriority _$VideoIdPriorityFromJson(Map<String, dynamic> json) =>
    _VideoIdPriority(
      id: json['id'] as String,
      priority: $enumDecode(_$VideoPriorityEnumMap, json['priority']),
    );

Map<String, dynamic> _$VideoIdPriorityToJson(_VideoIdPriority instance) =>
    <String, dynamic>{
      'id': instance.id,
      'priority': _$VideoPriorityEnumMap[instance.priority]!,
    };

const _$VideoPriorityEnumMap = {
  VideoPriority.level1: 'level1',
  VideoPriority.level2: 'level2',
  VideoPriority.level3: 'level3',
};
