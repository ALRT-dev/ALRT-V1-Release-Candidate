// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alrt_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlrtLocation _$AlrtLocationFromJson(Map<String, dynamic> json) =>
    _AlrtLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      name: json['name'] as String?,
      bounds: json['bounds'] == null
          ? null
          : AlrtLocationBounds.fromJson(json['bounds'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AlrtLocationToJson(_AlrtLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': ?instance.address,
      'name': ?instance.name,
      'bounds': ?instance.bounds?.toJson(),
    };
