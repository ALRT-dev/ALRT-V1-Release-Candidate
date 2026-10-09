// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guide_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuideTopicsResponse _$GuideTopicsResponseFromJson(Map<String, dynamic> json) =>
    _GuideTopicsResponse(
      topics:
          (json['topics'] as List<dynamic>?)
              ?.map((e) => GuideTopic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GuideTopic>[],
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      completedGuideIds:
          (json['completedGuideIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      totalXpEarned: (json['totalXpEarned'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GuideTopicsResponseToJson(
  _GuideTopicsResponse instance,
) => <String, dynamic>{
  'topics': instance.topics.map((e) => e.toJson()).toList(),
  'completedCount': instance.completedCount,
  'totalCount': instance.totalCount,
  'completedGuideIds': instance.completedGuideIds,
  'totalXpEarned': instance.totalXpEarned,
};

_GuideTopic _$GuideTopicFromJson(Map<String, dynamic> json) => _GuideTopic(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  icon: json['icon'] as String?,
  color: json['color'] as String?,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  guides:
      (json['guides'] as List<dynamic>?)
          ?.map((e) => GuideListItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GuideListItem>[],
  completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
  totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GuideTopicToJson(_GuideTopic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'description': ?instance.description,
      'icon': ?instance.icon,
      'color': ?instance.color,
      'sortOrder': instance.sortOrder,
      'guides': instance.guides.map((e) => e.toJson()).toList(),
      'completedCount': instance.completedCount,
      'totalCount': instance.totalCount,
    };

_GuideListItem _$GuideListItemFromJson(Map<String, dynamic> json) =>
    _GuideListItem(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 10,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$GuideListItemToJson(_GuideListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'summary': ?instance.summary,
      'xpReward': instance.xpReward,
      'sortOrder': instance.sortOrder,
      'completed': instance.completed,
    };

_GuideStep _$GuideStepFromJson(Map<String, dynamic> json) =>
    _GuideStep(title: json['title'] as String, body: json['body'] as String);

Map<String, dynamic> _$GuideStepToJson(_GuideStep instance) =>
    <String, dynamic>{'title': instance.title, 'body': instance.body};

_GuideSections _$GuideSectionsFromJson(Map<String, dynamic> json) =>
    _GuideSections(
      before:
          (json['before'] as List<dynamic>?)
              ?.map((e) => GuideStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GuideStep>[],
      during:
          (json['during'] as List<dynamic>?)
              ?.map((e) => GuideStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GuideStep>[],
      after:
          (json['after'] as List<dynamic>?)
              ?.map((e) => GuideStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GuideStep>[],
    );

Map<String, dynamic> _$GuideSectionsToJson(_GuideSections instance) =>
    <String, dynamic>{
      'before': instance.before.map((e) => e.toJson()).toList(),
      'during': instance.during.map((e) => e.toJson()).toList(),
      'after': instance.after.map((e) => e.toJson()).toList(),
    };

_GuideDetail _$GuideDetailFromJson(Map<String, dynamic> json) => _GuideDetail(
  id: json['id'] as String,
  slug: json['slug'] as String,
  title: json['title'] as String,
  summary: json['summary'] as String?,
  sections: GuideSections.fromJson(json['sections'] as Map<String, dynamic>),
  sourceName: json['sourceName'] as String?,
  sourceUrl: json['sourceUrl'] as String?,
  sourceNote: json['sourceNote'] as String?,
  xpReward: (json['xpReward'] as num?)?.toInt() ?? 10,
  categoryIds:
      (json['categoryIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  completed: json['completed'] as bool? ?? false,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$GuideDetailToJson(_GuideDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'summary': ?instance.summary,
      'sections': instance.sections.toJson(),
      'sourceName': ?instance.sourceName,
      'sourceUrl': ?instance.sourceUrl,
      'sourceNote': ?instance.sourceNote,
      'xpReward': instance.xpReward,
      'categoryIds': instance.categoryIds,
      'completed': instance.completed,
      'completedAt': ?instance.completedAt?.toIso8601String(),
    };

_GuideCompletionResponse _$GuideCompletionResponseFromJson(
  Map<String, dynamic> json,
) => _GuideCompletionResponse(
  alreadyCompleted: json['alreadyCompleted'] as bool? ?? false,
  xpAwarded: (json['xpAwarded'] as num?)?.toInt() ?? 0,
  newXpTotal: (json['newXpTotal'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GuideCompletionResponseToJson(
  _GuideCompletionResponse instance,
) => <String, dynamic>{
  'alreadyCompleted': instance.alreadyCompleted,
  'xpAwarded': instance.xpAwarded,
  'newXpTotal': instance.newXpTotal,
};

_GuideForCategory _$GuideForCategoryFromJson(Map<String, dynamic> json) =>
    _GuideForCategory(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      topic: json['topic'] == null
          ? null
          : GuideForCategoryTopic.fromJson(
              json['topic'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$GuideForCategoryToJson(_GuideForCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'topic': ?instance.topic?.toJson(),
    };

_GuideForCategoryTopic _$GuideForCategoryTopicFromJson(
  Map<String, dynamic> json,
) => _GuideForCategoryTopic(
  name: json['name'] as String?,
  icon: json['icon'] as String?,
  color: json['color'] as String?,
);

Map<String, dynamic> _$GuideForCategoryTopicToJson(
  _GuideForCategoryTopic instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'icon': ?instance.icon,
  'color': ?instance.color,
};
