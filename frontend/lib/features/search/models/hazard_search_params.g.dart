// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hazard_search_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HazardSearchParams _$HazardSearchParamsFromJson(
  Map<String, dynamic> json,
) => _HazardSearchParams(
  searchString: json['searchString'] as String?,
  categoryIds:
      (json['categoryIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  sourceIds:
      (json['sourceIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  locationIds:
      (json['locationIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  reportedById: json['reportedById'] as String?,
  reviewStatus:
      $enumDecodeNullable(_$HazardReviewStatusEnumMap, json['reviewStatus']) ??
      HazardReviewStatus.accepted,
  northeastLat: (json['northeastLat'] as num?)?.toDouble(),
  northeastLng: (json['northeastLng'] as num?)?.toDouble(),
  southwestLat: (json['southwestLat'] as num?)?.toDouble(),
  southwestLng: (json['southwestLng'] as num?)?.toDouble(),
  ignoreHazardLatLngBounds: json['ignoreHazardLatLngBounds'] as bool? ?? false,
  showExpired: json['showExpired'] as bool? ?? false,
  awsEmergency: json['awsEmergency'] as bool? ?? true,
  awsWatchAndAct: json['awsWatchAndAct'] as bool? ?? true,
  awsAdvice: json['awsAdvice'] as bool? ?? true,
  officialNonAws: json['officialNonAws'] as bool? ?? true,
  userReported: json['userReported'] as bool? ?? true,
  sortSettings:
      (json['sortSettings'] as List<dynamic>?)
          ?.map(
            (e) => (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(
                $enumDecode(_$SortCategoryEnumMap, k),
                $enumDecode(_$SortOrderEnumMap, e),
              ),
            ),
          )
          .toList() ??
      const <Map<SortCategory, SortOrder>>[
        {SortCategory.severityBand: SortOrder.desc},
        {SortCategory.distance: SortOrder.asc},
        {SortCategory.createdAt: SortOrder.desc},
        {SortCategory.confidenceScore: SortOrder.desc},
      ],
  page: (json['page'] as num?)?.toInt() ?? 1,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$HazardSearchParamsToJson(_HazardSearchParams instance) =>
    <String, dynamic>{
      'searchString': ?instance.searchString,
      'categoryIds': instance.categoryIds,
      'sourceIds': instance.sourceIds,
      'locationIds': instance.locationIds,
      'reportedById': ?instance.reportedById,
      'reviewStatus': _$HazardReviewStatusEnumMap[instance.reviewStatus]!,
      'northeastLat': ?instance.northeastLat,
      'northeastLng': ?instance.northeastLng,
      'southwestLat': ?instance.southwestLat,
      'southwestLng': ?instance.southwestLng,
      'ignoreHazardLatLngBounds': instance.ignoreHazardLatLngBounds,
      'showExpired': instance.showExpired,
      'awsEmergency': instance.awsEmergency,
      'awsWatchAndAct': instance.awsWatchAndAct,
      'awsAdvice': instance.awsAdvice,
      'officialNonAws': instance.officialNonAws,
      'userReported': instance.userReported,
      'sortSettings': instance.sortSettings
          .map(
            (e) => e.map(
              (k, e) =>
                  MapEntry(_$SortCategoryEnumMap[k]!, _$SortOrderEnumMap[e]!),
            ),
          )
          .toList(),
      'page': instance.page,
      'pageSize': instance.pageSize,
    };

const _$HazardReviewStatusEnumMap = {
  HazardReviewStatus.pending: 'pending',
  HazardReviewStatus.accepted: 'accepted',
  HazardReviewStatus.rejected: 'rejected',
};

const _$SortOrderEnumMap = {SortOrder.asc: 'asc', SortOrder.desc: 'desc'};

const _$SortCategoryEnumMap = {
  SortCategory.severityBand: 'severityBand',
  SortCategory.distance: 'distance',
  SortCategory.createdAt: 'createdAt',
  SortCategory.confidenceScore: 'confidenceScore',
};
