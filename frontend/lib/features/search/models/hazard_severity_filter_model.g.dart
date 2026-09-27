// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hazard_severity_filter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HazardSeverityFilter _$HazardSeverityFilterFromJson(
  Map<String, dynamic> json,
) => _HazardSeverityFilter(
  aws:
      (json['aws'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$HazardSeverityEnumMap, e))
          .toList() ??
      const <HazardSeverity>[],
  nonAws:
      (json['nonAws'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$HazardSeverityEnumMap, e))
          .toList() ??
      const <HazardSeverity>[],
);

Map<String, dynamic> _$HazardSeverityFilterToJson(
  _HazardSeverityFilter instance,
) => <String, dynamic>{
  'aws': instance.aws.map((e) => _$HazardSeverityEnumMap[e]!).toList(),
  'nonAws': instance.nonAws.map((e) => _$HazardSeverityEnumMap[e]!).toList(),
};

const _$HazardSeverityEnumMap = {
  HazardSeverity.unknown: 'unknown',
  HazardSeverity.info: 'info',
  HazardSeverity.advice: 'advice',
  HazardSeverity.watchAndAct: 'watchAndAct',
  HazardSeverity.emergency: 'emergency',
};
