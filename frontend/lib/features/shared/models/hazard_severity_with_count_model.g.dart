// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hazard_severity_with_count_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HazardSeverityWithCount _$HazardSeverityWithCountFromJson(
  Map<String, dynamic> json,
) => _HazardSeverityWithCount(
  severity: $enumDecode(_$HazardSeverityEnumMap, json['severity']),
  hazardsCount: (json['hazardsCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$HazardSeverityWithCountToJson(
  _HazardSeverityWithCount instance,
) => <String, dynamic>{
  'severity': _$HazardSeverityEnumMap[instance.severity]!,
  'hazardsCount': instance.hazardsCount,
};

const _$HazardSeverityEnumMap = {
  HazardSeverity.unknown: 'unknown',
  HazardSeverity.info: 'info',
  HazardSeverity.advice: 'advice',
  HazardSeverity.watchAndAct: 'watchAndAct',
  HazardSeverity.emergency: 'emergency',
};
