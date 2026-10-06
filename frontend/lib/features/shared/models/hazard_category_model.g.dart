// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hazard_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HazardCategory _$HazardCategoryFromJson(Map<String, dynamic> json) =>
    _HazardCategory(
      id: json['id'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      color: const ColorConverter().fromJson(json['color'] as String?),
      parentId: json['parentId'] as String?,
      parent: json['parent'] == null
          ? null
          : HazardCategory.fromJson(json['parent'] as Map<String, dynamic>),
      hazardsCount: (json['hazardsCount'] as num?)?.toInt() ?? 0,
      isFireRelated: json['isFireRelated'] as bool? ?? false,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => CategoryImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HazardCategoryToJson(_HazardCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': ?instance.name,
      'description': ?instance.description,
      'color': ?const ColorConverter().toJson(instance.color),
      'parentId': ?instance.parentId,
      'parent': ?instance.parent?.toJson(),
      'hazardsCount': instance.hazardsCount,
      'isFireRelated': instance.isFireRelated,
      'images': ?instance.images?.map((e) => e.toJson()).toList(),
    };
