// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_summary_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_XpSummary _$XpSummaryFromJson(Map<String, dynamic> json) => _XpSummary(
  xpPoints: (json['xpPoints'] as num?)?.toInt() ?? 0,
  streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
  streakMultiplierActive: json['streakMultiplierActive'] as bool? ?? false,
  trustTier: json['trustTier'] == null
      ? null
      : TrustTier.fromJson(json['trustTier'] as Map<String, dynamic>),
  weeklyQuest: json['weeklyQuest'] == null
      ? null
      : WeeklyQuest.fromJson(json['weeklyQuest'] as Map<String, dynamic>),
  recentEvents:
      (json['recentEvents'] as List<dynamic>?)
          ?.map((e) => XpLedgerEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <XpLedgerEvent>[],
  badges:
      (json['badges'] as List<dynamic>?)
          ?.map((e) => SafetyBadge.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SafetyBadge>[],
);

Map<String, dynamic> _$XpSummaryToJson(_XpSummary instance) =>
    <String, dynamic>{
      'xpPoints': instance.xpPoints,
      'streakDays': instance.streakDays,
      'streakMultiplierActive': instance.streakMultiplierActive,
      'trustTier': ?instance.trustTier?.toJson(),
      'weeklyQuest': ?instance.weeklyQuest?.toJson(),
      'recentEvents': instance.recentEvents.map((e) => e.toJson()).toList(),
      'badges': instance.badges.map((e) => e.toJson()).toList(),
    };

_TrustTier _$TrustTierFromJson(Map<String, dynamic> json) => _TrustTier(
  tier: (json['tier'] as num?)?.toInt() ?? 1,
  name: json['name'] as String? ?? 'Newcomer',
  approvedCount: (json['approvedCount'] as num?)?.toInt() ?? 0,
  rejectedCount: (json['rejectedCount'] as num?)?.toInt() ?? 0,
  verificationRate: (json['verificationRate'] as num?)?.toDouble() ?? 0.0,
  next: json['next'] == null
      ? null
      : NextTrustTier.fromJson(json['next'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TrustTierToJson(_TrustTier instance) =>
    <String, dynamic>{
      'tier': instance.tier,
      'name': instance.name,
      'approvedCount': instance.approvedCount,
      'rejectedCount': instance.rejectedCount,
      'verificationRate': instance.verificationRate,
      'next': ?instance.next?.toJson(),
    };

_NextTrustTier _$NextTrustTierFromJson(Map<String, dynamic> json) =>
    _NextTrustTier(
      name: json['name'] as String,
      approvedNeeded: (json['approvedNeeded'] as num?)?.toInt() ?? 0,
      rateNeeded: (json['rateNeeded'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$NextTrustTierToJson(_NextTrustTier instance) =>
    <String, dynamic>{
      'name': instance.name,
      'approvedNeeded': instance.approvedNeeded,
      'rateNeeded': instance.rateNeeded,
    };

_WeeklyQuest _$WeeklyQuestFromJson(Map<String, dynamic> json) => _WeeklyQuest(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  target: (json['target'] as num?)?.toInt() ?? 1,
  progress: (json['progress'] as num?)?.toInt() ?? 0,
  xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
  completed: json['completed'] as bool? ?? false,
);

Map<String, dynamic> _$WeeklyQuestToJson(_WeeklyQuest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': ?instance.description,
      'target': instance.target,
      'progress': instance.progress,
      'xpReward': instance.xpReward,
      'completed': instance.completed,
    };

_SafetyBadge _$SafetyBadgeFromJson(Map<String, dynamic> json) => _SafetyBadge(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  threshold: (json['threshold'] as num?)?.toInt() ?? 1,
  progress: (json['progress'] as num?)?.toInt() ?? 0,
  earned: json['earned'] as bool? ?? false,
  earnedAt: json['earnedAt'] == null
      ? null
      : DateTime.parse(json['earnedAt'] as String),
);

Map<String, dynamic> _$SafetyBadgeToJson(_SafetyBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'threshold': instance.threshold,
      'progress': instance.progress,
      'earned': instance.earned,
      'earnedAt': ?instance.earnedAt?.toIso8601String(),
    };

_XpLedgerEvent _$XpLedgerEventFromJson(Map<String, dynamic> json) =>
    _XpLedgerEvent(
      id: json['id'] as String,
      type: $enumDecodeNullable(
        _$XpEventTypeEnumMap,
        json['type'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      points: (json['points'] as num?)?.toInt() ?? 0,
      hazardId: json['hazardId'] as String?,
      guideId: json['guideId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$XpLedgerEventToJson(_XpLedgerEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': ?_$XpEventTypeEnumMap[instance.type],
      'points': instance.points,
      'hazardId': ?instance.hazardId,
      'guideId': ?instance.guideId,
      'createdAt': ?instance.createdAt?.toIso8601String(),
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
