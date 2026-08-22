// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hazard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Hazard _$HazardFromJson(Map<String, dynamic> json) => _Hazard(
  id: json['id'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  severity: $enumDecodeNullable(_$HazardSeverityEnumMap, json['severity']),
  severityBand: $enumDecodeNullable(
    _$HazardSeverityBandEnumMap,
    json['severityBand'],
  ),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  locationName: json['locationName'] as String?,
  northeastLat: (json['northeastLat'] as num?)?.toDouble(),
  northeastLng: (json['northeastLng'] as num?)?.toDouble(),
  southwestLat: (json['southwestLat'] as num?)?.toDouble(),
  southwestLng: (json['southwestLng'] as num?)?.toDouble(),
  categoryId: json['categoryId'] as String?,
  category: json['category'] == null
      ? null
      : HazardCategory.fromJson(json['category'] as Map<String, dynamic>),
  fireStatus: $enumDecodeNullable(_$FireStatusEnumMap, json['fireStatus']),
  source: json['source'] == null
      ? null
      : HazardSource.fromJson(json['source'] as Map<String, dynamic>),
  aiSummary: json['aiSummary'] as String?,
  aiConfidence: $enumDecodeNullable(
    _$AIConfidenceEnumMap,
    json['aiConfidence'],
  ),
  callsToAction: (json['callsToAction'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isAwsCompliant: json['isAwsCompliant'] as bool?,
  reportedBy: json['reportedBy'] == null
      ? null
      : AppUser.fromJson(json['reportedBy'] as Map<String, dynamic>),
  reviewStatus: $enumDecodeNullable(
    _$HazardReviewStatusEnumMap,
    json['reviewStatus'],
  ),
  reviewFeedback: json['reviewFeedback'] as String?,
  reviewedById: json['reviewedById'] as String?,
  reviewedAt: _$JsonConverterFromJson<String, DateTime>(
    json['reviewedAt'],
    const DateTimeConverter().fromJson,
  ),
  userVoteType: $enumDecodeNullable(
    _$HazardVoteTypeEnumMap,
    json['userVoteType'],
  ),
  upvoteCount: (json['upvoteCount'] as num?)?.toInt() ?? 0,
  downvoteCount: (json['downvoteCount'] as num?)?.toInt() ?? 0,
  confidenceScore: (json['confidenceScore'] as num?)?.toInt(),
  medias:
      (json['medias'] as List<dynamic>?)
          ?.map((e) => S3Media.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <S3Media>[],
  link: json['link'] as String?,
  occurredAt: _$JsonConverterFromJson<String, DateTime>(
    json['occurredAt'],
    const DateTimeConverter().fromJson,
  ),
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['createdAt'],
    const DateTimeConverter().fromJson,
  ),
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAt'],
    const DateTimeConverter().fromJson,
  ),
  expiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['expiresAt'],
    const DateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$HazardToJson(_Hazard instance) => <String, dynamic>{
  'id': ?instance.id,
  'title': ?instance.title,
  'description': ?instance.description,
  'severity': ?_$HazardSeverityEnumMap[instance.severity],
  'severityBand': ?_$HazardSeverityBandEnumMap[instance.severityBand],
  'latitude': ?instance.latitude,
  'longitude': ?instance.longitude,
  'locationName': ?instance.locationName,
  'northeastLat': ?instance.northeastLat,
  'northeastLng': ?instance.northeastLng,
  'southwestLat': ?instance.southwestLat,
  'southwestLng': ?instance.southwestLng,
  'categoryId': ?instance.categoryId,
  'category': ?instance.category?.toJson(),
  'fireStatus': ?_$FireStatusEnumMap[instance.fireStatus],
  'source': ?instance.source?.toJson(),
  'aiSummary': ?instance.aiSummary,
  'aiConfidence': ?_$AIConfidenceEnumMap[instance.aiConfidence],
  'callsToAction': ?instance.callsToAction,
  'isAwsCompliant': ?instance.isAwsCompliant,
  'reportedBy': ?instance.reportedBy?.toJson(),
  'reviewStatus': ?_$HazardReviewStatusEnumMap[instance.reviewStatus],
  'reviewFeedback': ?instance.reviewFeedback,
  'reviewedById': ?instance.reviewedById,
  'reviewedAt': ?_$JsonConverterToJson<String, DateTime>(
    instance.reviewedAt,
    const DateTimeConverter().toJson,
  ),
  'userVoteType': ?_$HazardVoteTypeEnumMap[instance.userVoteType],
  'upvoteCount': instance.upvoteCount,
  'downvoteCount': instance.downvoteCount,
  'confidenceScore': ?instance.confidenceScore,
  'medias': instance.medias.map((e) => e.toJson()).toList(),
  'link': ?instance.link,
  'occurredAt': ?_$JsonConverterToJson<String, DateTime>(
    instance.occurredAt,
    const DateTimeConverter().toJson,
  ),
  'createdAt': ?_$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const DateTimeConverter().toJson,
  ),
  'updatedAt': ?_$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const DateTimeConverter().toJson,
  ),
  'expiresAt': ?_$JsonConverterToJson<String, DateTime>(
    instance.expiresAt,
    const DateTimeConverter().toJson,
  ),
};

const _$HazardSeverityEnumMap = {
  HazardSeverity.unknown: 'unknown',
  HazardSeverity.info: 'info',
  HazardSeverity.advice: 'advice',
  HazardSeverity.watchAndAct: 'watchAndAct',
  HazardSeverity.emergency: 'emergency',
};

const _$HazardSeverityBandEnumMap = {
  HazardSeverityBand.info: 'info',
  HazardSeverityBand.monitor: 'monitor',
  HazardSeverityBand.action: 'action',
  HazardSeverityBand.critical: 'critical',
};

const _$FireStatusEnumMap = {
  FireStatus.active: 'active',
  FireStatus.beingControlled: 'beingControlled',
  FireStatus.underControl: 'underControl',
  FireStatus.closed: 'closed',
};

const _$AIConfidenceEnumMap = {
  AIConfidence.low: 'low',
  AIConfidence.medium: 'medium',
  AIConfidence.high: 'high',
};

const _$HazardReviewStatusEnumMap = {
  HazardReviewStatus.pending: 'pending',
  HazardReviewStatus.accepted: 'accepted',
  HazardReviewStatus.rejected: 'rejected',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$HazardVoteTypeEnumMap = {
  HazardVoteType.upvote: 'upvote',
  HazardVoteType.downvote: 'downvote',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
