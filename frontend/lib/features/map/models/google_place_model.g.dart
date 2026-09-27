// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GooglePlace _$GooglePlaceFromJson(Map<String, dynamic> json) => _GooglePlace(
  placeId: json['place_id'] as String,
  description: json['description'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  name: json['name'] as String,
  address: json['address'] as String,
  bounds: AlrtLocationBounds.fromJson(json['bounds'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GooglePlaceToJson(_GooglePlace instance) =>
    <String, dynamic>{
      'place_id': instance.placeId,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'name': instance.name,
      'address': instance.address,
      'bounds': instance.bounds.toJson(),
    };
