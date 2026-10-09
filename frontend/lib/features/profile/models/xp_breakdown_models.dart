import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/profile/models/xp_summary_models.dart';

part 'xp_breakdown_models.freezed.dart';
part 'xp_breakdown_models.g.dart';

/// Payload from GET /api/xp/breakdown: where the points actually came from.
///
/// Every figure here is read from the XP ledger, the single writer for all
/// points, so the parts add up to the total on the same screen. The old
/// version recomputed an estimate from views and upvotes, which stopped
/// awarding points long ago and never matched.
@freezed
abstract class XpBreakdown with _$XpBreakdown {
  const XpBreakdown._();

  const factory XpBreakdown({
    @Default(0) final int currentXpPoints,
    @Default(0.0) final double reliabilityScore,

    /// Everything the ledger has applied. Equal to [currentXpPoints] unless
    /// a total was floored at zero along the way.
    @Default(0) final int ledgerTotal,
    @Default(0) final int rank,
    @Default(0) final int totalUsers,
    @Default(0) final int percentile,
    final XpBreakdownStats? stats,

    /// Points grouped by the kind of event that earned them.
    @Default(<XpTypeTotal>[]) final List<XpTypeTotal> byType,

    /// The reports that earned or cost the most, biggest first.
    @Default(<XpReportBreakdown>[]) final List<XpReportBreakdown> reports,

    /// Learning, itemised like reports: guides by name, challenges by week.
    final XpLearningBreakdown? learning,
  }) = _XpBreakdown;

  /// True when the shown total and the ledger disagree, which only happens
  /// when a penalty was clamped at zero. Worth saying rather than hiding.
  bool get isFloored => ledgerTotal != currentXpPoints;

  factory XpBreakdown.fromJson(Map<String, dynamic> json) =>
      _$XpBreakdownFromJson(json);
}

@freezed
abstract class XpBreakdownStats with _$XpBreakdownStats {
  const factory XpBreakdownStats({
    @Default(0) final int totalHazardsReported,
    @Default(0) final int approvedReports,

    /// How many people confirmed the caller's reports. This is what the
    /// badges are earned on.
    @Default(0) final int corroborationsReceived,
  }) = _XpBreakdownStats;

  factory XpBreakdownStats.fromJson(Map<String, dynamic> json) =>
      _$XpBreakdownStatsFromJson(json);
}

/// One row of "where your points came from".
@freezed
abstract class XpTypeTotal with _$XpTypeTotal {
  const factory XpTypeTotal({
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    final XpEventType? type,
    @Default(0) final int count,
    @Default(0) final int points,
  }) = _XpTypeTotal;

  factory XpTypeTotal.fromJson(Map<String, dynamic> json) =>
      _$XpTypeTotalFromJson(json);
}

/// Learning on the points screen, named like reports are: which guide,
/// what it paid, and each completed weekly challenge.
@freezed
abstract class XpLearningBreakdown with _$XpLearningBreakdown {
  const factory XpLearningBreakdown({
    @Default(<XpGuideCompletion>[]) final List<XpGuideCompletion> guides,
    @Default(<XpChallengeCompletion>[])
    final List<XpChallengeCompletion> challenges,
  }) = _XpLearningBreakdown;

  factory XpLearningBreakdown.fromJson(Map<String, dynamic> json) =>
      _$XpLearningBreakdownFromJson(json);
}

@freezed
abstract class XpGuideCompletion with _$XpGuideCompletion {
  const factory XpGuideCompletion({
    final String? guideId,
    @Default('Safety guide') final String title,
    @Default(0) final int points,
    final DateTime? createdAt,
  }) = _XpGuideCompletion;

  factory XpGuideCompletion.fromJson(Map<String, dynamic> json) =>
      _$XpGuideCompletionFromJson(json);
}

@freezed
abstract class XpChallengeCompletion with _$XpChallengeCompletion {
  const factory XpChallengeCompletion({
    @Default(0) final int points,
    final DateTime? createdAt,
  }) = _XpChallengeCompletion;

  factory XpChallengeCompletion.fromJson(Map<String, dynamic> json) =>
      _$XpChallengeCompletionFromJson(json);
}

/// What one report earned, and the ledger events behind it.
@freezed
abstract class XpReportBreakdown with _$XpReportBreakdown {
  const factory XpReportBreakdown({
    required final String hazardId,
    @Default('') final String title,
    @Default('pending') final String reviewStatus,
    @Default(0) final int points,
    @Default(<XpReportEvent>[]) final List<XpReportEvent> events,
    final DateTime? createdAt,
  }) = _XpReportBreakdown;

  factory XpReportBreakdown.fromJson(Map<String, dynamic> json) =>
      _$XpReportBreakdownFromJson(json);
}

@freezed
abstract class XpReportEvent with _$XpReportEvent {
  const factory XpReportEvent({
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    final XpEventType? type,
    @Default(0) final int points,
    final DateTime? createdAt,
  }) = _XpReportEvent;

  factory XpReportEvent.fromJson(Map<String, dynamic> json) =>
      _$XpReportEventFromJson(json);
}
