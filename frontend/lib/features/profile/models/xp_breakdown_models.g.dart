// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_breakdown_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_XpBreakdown _$XpBreakdownFromJson(Map<String, dynamic> json) => _XpBreakdown(
  currentXpPoints: (json['currentXpPoints'] as num?)?.toInt() ?? 0,
  reliabilityScore: (json['reliabilityScore'] as num?)?.toDouble() ?? 0.0,
  ledgerTotal: (json['ledgerTotal'] as num?)?.toInt() ?? 0,
  rank: (json['rank'] as num?)?.toInt() ?? 0,
  totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
  percentile: (json['percentile'] as num?)?.toInt() ?? 0,
  stats: json['stats'] == null
      ? null
      : XpBreakdownStats.fromJson(json['stats'] as Map<String, dynamic>),
  byType:
      (json['byType'] as List<dynamic>?)
          ?.map((e) => XpTypeTotal.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <XpTypeTotal>[],
  reports:
      (json['reports'] as List<dynamic>?)
          ?.map((e) => XpReportBreakdown.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <XpReportBreakdown>[],
  learning: json['learning'] == null
      ? null
      : XpLearningBreakdown.fromJson(json['learning'] as Map<String, dynamic>),
);

Map<String, dynamic> _$XpBreakdownToJson(_XpBreakdown instance) =>
    <String, dynamic>{
      'currentXpPoints': instance.currentXpPoints,
      'reliabilityScore': instance.reliabilityScore,
      'ledgerTotal': instance.ledgerTotal,
      'rank': instance.rank,
      'totalUsers': instance.totalUsers,
      'percentile': instance.percentile,
      'stats': ?instance.stats?.toJson(),
      'byType': instance.byType.map((e) => e.toJson()).toList(),
      'reports': instance.reports.map((e) => e.toJson()).toList(),
      'learning': ?instance.learning?.toJson(),
    };

_XpBreakdownStats _$XpBreakdownStatsFromJson(Map<String, dynamic> json) =>
    _XpBreakdownStats(
      totalHazardsReported:
          (json['totalHazardsReported'] as num?)?.toInt() ?? 0,
      approvedReports: (json['approvedReports'] as num?)?.toInt() ?? 0,
      corroborationsReceived:
          (json['corroborationsReceived'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$XpBreakdownStatsToJson(_XpBreakdownStats instance) =>
    <String, dynamic>{
      'totalHazardsReported': instance.totalHazardsReported,
      'approvedReports': instance.approvedReports,
      'corroborationsReceived': instance.corroborationsReceived,
    };

_XpTypeTotal _$XpTypeTotalFromJson(Map<String, dynamic> json) => _XpTypeTotal(
  type: $enumDecodeNullable(
    _$XpEventTypeEnumMap,
    json['type'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  count: (json['count'] as num?)?.toInt() ?? 0,
  points: (json['points'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$XpTypeTotalToJson(_XpTypeTotal instance) =>
    <String, dynamic>{
      'type': ?_$XpEventTypeEnumMap[instance.type],
      'count': instance.count,
      'points': instance.points,
    };

const _$XpEventTypeEnumMap = {
  XpEventType.reportApproved: 'reportApproved',
  XpEventType.reportRejected: 'reportRejected',
  XpEventType.reportCorroborated: 'reportCorroborated',
  XpEventType.officialMatch: 'officialMatch',
  XpEventType.onboardingCompleted: 'onboardingCompleted',
  XpEventType.firstReportPosted: 'firstReportPosted',
  XpEventType.profileCompleted: 'profileCompleted',
  XpEventType.familyJoined: 'familyJoined',
  XpEventType.savedPlaceAdded: 'savedPlaceAdded',
  XpEventType.reportWidelyCorroborated: 'reportWidelyCorroborated',
  XpEventType.guideCompleted: 'guideCompleted',
  XpEventType.questCompleted: 'questCompleted',
  XpEventType.shareInstall: 'shareInstall',
};

_XpLearningBreakdown _$XpLearningBreakdownFromJson(Map<String, dynamic> json) =>
    _XpLearningBreakdown(
      guides:
          (json['guides'] as List<dynamic>?)
              ?.map(
                (e) => XpGuideCompletion.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <XpGuideCompletion>[],
      challenges:
          (json['challenges'] as List<dynamic>?)
              ?.map(
                (e) =>
                    XpChallengeCompletion.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <XpChallengeCompletion>[],
    );

Map<String, dynamic> _$XpLearningBreakdownToJson(
  _XpLearningBreakdown instance,
) => <String, dynamic>{
  'guides': instance.guides.map((e) => e.toJson()).toList(),
  'challenges': instance.challenges.map((e) => e.toJson()).toList(),
};

_XpGuideCompletion _$XpGuideCompletionFromJson(Map<String, dynamic> json) =>
    _XpGuideCompletion(
      guideId: json['guideId'] as String?,
      title: json['title'] as String? ?? 'Safety guide',
      points: (json['points'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$XpGuideCompletionToJson(_XpGuideCompletion instance) =>
    <String, dynamic>{
      'guideId': ?instance.guideId,
      'title': instance.title,
      'points': instance.points,
      'createdAt': ?instance.createdAt?.toIso8601String(),
    };

_XpChallengeCompletion _$XpChallengeCompletionFromJson(
  Map<String, dynamic> json,
) => _XpChallengeCompletion(
  points: (json['points'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$XpChallengeCompletionToJson(
  _XpChallengeCompletion instance,
) => <String, dynamic>{
  'points': instance.points,
  'createdAt': ?instance.createdAt?.toIso8601String(),
};

_XpReportBreakdown _$XpReportBreakdownFromJson(Map<String, dynamic> json) =>
    _XpReportBreakdown(
      hazardId: json['hazardId'] as String,
      title: json['title'] as String? ?? '',
      reviewStatus: json['reviewStatus'] as String? ?? 'pending',
      points: (json['points'] as num?)?.toInt() ?? 0,
      events:
          (json['events'] as List<dynamic>?)
              ?.map((e) => XpReportEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <XpReportEvent>[],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$XpReportBreakdownToJson(_XpReportBreakdown instance) =>
    <String, dynamic>{
      'hazardId': instance.hazardId,
      'title': instance.title,
      'reviewStatus': instance.reviewStatus,
      'points': instance.points,
      'events': instance.events.map((e) => e.toJson()).toList(),
      'createdAt': ?instance.createdAt?.toIso8601String(),
    };

_XpReportEvent _$XpReportEventFromJson(Map<String, dynamic> json) =>
    _XpReportEvent(
      type: $enumDecodeNullable(
        _$XpEventTypeEnumMap,
        json['type'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      points: (json['points'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$XpReportEventToJson(_XpReportEvent instance) =>
    <String, dynamic>{
      'type': ?_$XpEventTypeEnumMap[instance.type],
      'points': instance.points,
      'createdAt': ?instance.createdAt?.toIso8601String(),
    };
