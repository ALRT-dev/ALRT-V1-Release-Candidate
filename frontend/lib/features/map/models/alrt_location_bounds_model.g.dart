// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alrt_location_bounds_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlrtLocationBounds _$AlrtLocationBoundsFromJson(Map<String, dynamic> json) =>
    _AlrtLocationBounds(
      northeastLat: (json['northeastLat'] as num).toDouble(),
      northeastLng: (json['northeastLng'] as num).toDouble(),
      southwestLat: (json['southwestLat'] as num).toDouble(),
      southwestLng: (json['southwestLng'] as num).toDouble(),
    );

Map<String, dynamic> _$AlrtLocationBoundsToJson(_AlrtLocationBounds instance) =>
    <String, dynamic>{
      'northeastLat': instance.northeastLat,
      'northeastLng': instance.northeastLng,
      'southwestLat': instance.southwestLat,
      'southwestLng': instance.southwestLng,
    };
