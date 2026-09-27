// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hazard_filters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HazardFilters _$HazardFiltersFromJson(Map<String, dynamic> json) =>
    _HazardFilters(
      categoryFilters:
          (json['categoryFilters'] as List<dynamic>?)
              ?.map((e) => HazardCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <HazardCategory>[],
      severityFiltersAws:
          (json['severityFiltersAws'] as List<dynamic>?)
              ?.map(
                (e) =>
                    HazardSeverityWithCount.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <HazardSeverityWithCount>[],
      severityFiltersNonAws:
          (json['severityFiltersNonAws'] as List<dynamic>?)
              ?.map(
                (e) =>
                    HazardSeverityWithCount.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <HazardSeverityWithCount>[],
    );

Map<String, dynamic> _$HazardFiltersToJson(
  _HazardFilters instance,
) => <String, dynamic>{
  'categoryFilters': instance.categoryFilters.map((e) => e.toJson()).toList(),
  'severityFiltersAws': instance.severityFiltersAws
      .map((e) => e.toJson())
      .toList(),
  'severityFiltersNonAws': instance.severityFiltersNonAws
      .map((e) => e.toJson())
      .toList(),
};
