import 'package:freezed_annotation/freezed_annotation.dart';

part 'guide_models.freezed.dart';
part 'guide_models.g.dart';

/// Response of `GET /api/guides/topics` — all topics with per-user progress.
@freezed
abstract class GuideTopicsResponse with _$GuideTopicsResponse {
  const factory GuideTopicsResponse({
    @Default(<GuideTopic>[]) final List<GuideTopic> topics,
    @Default(0) final int completedCount,
    @Default(0) final int totalCount,
    @Default(<String>[]) final List<String> completedGuideIds,
    @Default(0) final int totalXpEarned,
  }) = _GuideTopicsResponse;

  factory GuideTopicsResponse.fromJson(Map<String, dynamic> json) =>
      _$GuideTopicsResponseFromJson(json);
}

@freezed
abstract class GuideTopic with _$GuideTopic {
  const GuideTopic._();

  const factory GuideTopic({
    required final String id,
    required final String slug,
    required final String name,
    final String? description,
    final String? icon,
    final String? color,
    @Default(0) final int sortOrder,
    @Default(<GuideListItem>[]) final List<GuideListItem> guides,
    @Default(0) final int completedCount,
    @Default(0) final int totalCount,
  }) = _GuideTopic;

  /// Completion ratio 0..1 for the topic progress bar.
  double get progress =>
      totalCount == 0 ? 0 : (completedCount / totalCount).clamp(0, 1);

  bool get isDone => totalCount > 0 && completedCount == totalCount;

  factory GuideTopic.fromJson(Map<String, dynamic> json) =>
      _$GuideTopicFromJson(json);
}

@freezed
abstract class GuideListItem with _$GuideListItem {
  const factory GuideListItem({
    required final String id,
    required final String slug,
    required final String title,
    final String? summary,
    @Default(10) final int xpReward,
    @Default(0) final int sortOrder,
    @Default(false) final bool completed,
  }) = _GuideListItem;

  factory GuideListItem.fromJson(Map<String, dynamic> json) =>
      _$GuideListItemFromJson(json);
}

/// A single numbered step within a guide phase.
@freezed
abstract class GuideStep with _$GuideStep {
  const factory GuideStep({
    required final String title,
    required final String body,
  }) = _GuideStep;

  factory GuideStep.fromJson(Map<String, dynamic> json) =>
      _$GuideStepFromJson(json);
}

/// Before / During / After sections of a guide.
@freezed
abstract class GuideSections with _$GuideSections {
  const factory GuideSections({
    @Default(<GuideStep>[]) final List<GuideStep> before,
    @Default(<GuideStep>[]) final List<GuideStep> during,
    @Default(<GuideStep>[]) final List<GuideStep> after,
  }) = _GuideSections;

  factory GuideSections.fromJson(Map<String, dynamic> json) =>
      _$GuideSectionsFromJson(json);
}

/// Response of `GET /api/guides/:slugOrId` — a full guide.
@freezed
abstract class GuideDetail with _$GuideDetail {
  const factory GuideDetail({
    required final String id,
    required final String slug,
    required final String title,
    final String? summary,
    required final GuideSections sections,
    final String? sourceName,
    final String? sourceUrl,
    final String? sourceNote,
    @Default(10) final int xpReward,
    @Default(<String>[]) final List<String> categoryIds,
    @Default(false) final bool completed,
    final DateTime? completedAt,
  }) = _GuideDetail;

  factory GuideDetail.fromJson(Map<String, dynamic> json) =>
      _$GuideDetailFromJson(json);
}

/// Response of `POST /api/guides/:slugOrId/complete`.
@freezed
abstract class GuideCompletionResponse with _$GuideCompletionResponse {
  const factory GuideCompletionResponse({
    @Default(false) final bool alreadyCompleted,
    @Default(0) final int xpAwarded,
    @Default(0) final int newXpTotal,
  }) = _GuideCompletionResponse;

  factory GuideCompletionResponse.fromJson(Map<String, dynamic> json) =>
      _$GuideCompletionResponseFromJson(json);
}

/// Response of `GET /api/guides/for-category/:categoryId` — the guide to
/// deep-link from an alert card ("What to do in a bushfire"). May be null.
@freezed
abstract class GuideForCategory with _$GuideForCategory {
  const factory GuideForCategory({
    required final String id,
    required final String slug,
    required final String title,
    final GuideForCategoryTopic? topic,
  }) = _GuideForCategory;

  factory GuideForCategory.fromJson(Map<String, dynamic> json) =>
      _$GuideForCategoryFromJson(json);
}

@freezed
abstract class GuideForCategoryTopic with _$GuideForCategoryTopic {
  const factory GuideForCategoryTopic({
    final String? name,
    final String? icon,
    final String? color,
  }) = _GuideForCategoryTopic;

  factory GuideForCategoryTopic.fromJson(Map<String, dynamic> json) =>
      _$GuideForCategoryTopicFromJson(json);
}
