// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_available_filters_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GetAvailableFiltersResponse _$GetAvailableFiltersResponseFromJson(
  Map<String, dynamic> json,
) => _GetAvailableFiltersResponse(
  categoryFilters:
      (json['categoryFilters'] as List<dynamic>?)
          ?.map((e) => HazardCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <HazardCategory>[],
  severityFiltersAws:
      (json['severityFiltersAws'] as List<dynamic>?)
          ?.map(
            (e) => HazardSeverityWithCount.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <HazardSeverityWithCount>[],
  severityFiltersNonAws:
      (json['severityFiltersNonAws'] as List<dynamic>?)
          ?.map(
            (e) => HazardSeverityWithCount.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <HazardSeverityWithCount>[],
);

Map<String, dynamic> _$GetAvailableFiltersResponseToJson(
  _GetAvailableFiltersResponse instance,
) => <String, dynamic>{
  'categoryFilters': instance.categoryFilters.map((e) => e.toJson()).toList(),
  'severityFiltersAws': instance.severityFiltersAws
      .map((e) => e.toJson())
      .toList(),
  'severityFiltersNonAws': instance.severityFiltersNonAws
      .map((e) => e.toJson())
      .toList(),
};
