import 'package:freezed_annotation/freezed_annotation.dart';

part 'xp_summary_models.freezed.dart';
part 'xp_summary_models.g.dart';

/// The kind of ledger event that changed the XP total.
enum XpEventType {
  reportApproved,
  reportRejected,
  reportCorroborated,
  officialMatch,
  onboardingCompleted,
  firstReportPosted,
  profileCompleted,
  familyJoined,
  savedPlaceAdded,
  reportWidelyCorroborated,
  guideCompleted,
  questCompleted,
  shareInstall,
}

/// Scoring v2 payload from GET /api/xp/summary.
@freezed
abstract class XpSummary with _$XpSummary {
  const factory XpSummary({
    @Default(0) final int xpPoints,
    @Default(0) final int streakDays,
    @Default(false) final bool streakMultiplierActive,
    final TrustTier? trustTier,
    final WeeklyQuest? weeklyQuest,
    @Default(<XpLedgerEvent>[]) final List<XpLedgerEvent> recentEvents,
    @Default(<SafetyBadge>[]) final List<SafetyBadge> badges,
  }) = _XpSummary;

  factory XpSummary.fromJson(Map<String, dynamic> json) =>
      _$XpSummaryFromJson(json);
}

@freezed
abstract class TrustTier with _$TrustTier {
  const factory TrustTier({
    @Default(1) final int tier,
    @Default('Newcomer') final String name,
    @Default(0) final int approvedCount,
    @Default(0) final int rejectedCount,
    @Default(0.0) final double verificationRate,
    final NextTrustTier? next,
  }) = _TrustTier;

  factory TrustTier.fromJson(Map<String, dynamic> json) =>
      _$TrustTierFromJson(json);
}

@freezed
abstract class NextTrustTier with _$NextTrustTier {
  const factory NextTrustTier({
    required final String name,
    @Default(0) final int approvedNeeded,
    @Default(0.0) final double rateNeeded,
  }) = _NextTrustTier;

  factory NextTrustTier.fromJson(Map<String, dynamic> json) =>
      _$NextTrustTierFromJson(json);
}

@freezed
abstract class WeeklyQuest with _$WeeklyQuest {
  const factory WeeklyQuest({
    required final String id,
    required final String title,
    final String? description,
    @Default(1) final int target,
    @Default(0) final int progress,
    @Default(0) final int xpReward,
    @Default(false) final bool completed,
  }) = _WeeklyQuest;

  factory WeeklyQuest.fromJson(Map<String, dynamic> json) =>
      _$WeeklyQuestFromJson(json);
}

/// One badge from Points and Badge Logic v1.1: earned, or locked with how
/// far off it is. Every badge counts what other people confirmed about your
/// reports, never how much you posted.
@freezed
abstract class SafetyBadge with _$SafetyBadge {
  const SafetyBadge._();

  const factory SafetyBadge({
    required final String id,
    required final String name,
    @Default('') final String description,
    @Default(1) final int threshold,
    @Default(0) final int progress,
    @Default(false) final bool earned,
    final DateTime? earnedAt,
  }) = _SafetyBadge;

  /// 0..1 for the progress ring on a locked badge.
  double get fraction =>
      threshold <= 0 ? 0 : (progress / threshold).clamp(0.0, 1.0);

  factory SafetyBadge.fromJson(Map<String, dynamic> json) =>
      _$SafetyBadgeFromJson(json);
}

@freezed
abstract class XpLedgerEvent with _$XpLedgerEvent {
  const factory XpLedgerEvent({
    required final String id,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    final XpEventType? type,
    @Default(0) final int points,
    final String? hazardId,
    final String? guideId,
    final DateTime? createdAt,
  }) = _XpLedgerEvent;

  factory XpLedgerEvent.fromJson(Map<String, dynamic> json) =>
      _$XpLedgerEventFromJson(json);
}

extension XpEventTypeX on XpEventType {
  /// Human-readable label for the ledger list.
  String get label => switch (this) {
    XpEventType.reportApproved => 'Report approved',
    XpEventType.reportRejected => 'Report rejected',
    XpEventType.reportCorroborated => 'Report corroborated by others',
    XpEventType.officialMatch => 'Matched an official alert',
    XpEventType.onboardingCompleted => 'Finished setting up ALRT',
    XpEventType.firstReportPosted => 'Posted your first ALRT',
    XpEventType.profileCompleted => 'Completed your profile',
    XpEventType.familyJoined => 'Joined a family group',
    XpEventType.savedPlaceAdded => 'Added a saved place',
    XpEventType.reportWidelyCorroborated =>
      'Your report was widely corroborated',
    XpEventType.guideCompleted => 'Safety guide completed',
    XpEventType.questCompleted => 'Weekly quest completed',
    XpEventType.shareInstall => 'Friend joined via your share',
  };
}
