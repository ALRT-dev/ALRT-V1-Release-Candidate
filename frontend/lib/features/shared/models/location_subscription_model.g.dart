// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationSubscription _$LocationSubscriptionFromJson(
  Map<String, dynamic> json,
) => _LocationSubscription(
  id: json['id'] as String?,
  northeastLat: (json['northeastLat'] as num).toDouble(),
  northeastLng: (json['northeastLng'] as num).toDouble(),
  southwestLat: (json['southwestLat'] as num).toDouble(),
  southwestLng: (json['southwestLng'] as num).toDouble(),
  isOwnLocation: json['isOwnLocation'] as bool? ?? false,
  name: json['name'] as String?,
  address: json['address'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LocationSubscriptionToJson(
  _LocationSubscription instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'northeastLat': instance.northeastLat,
  'northeastLng': instance.northeastLng,
  'southwestLat': instance.southwestLat,
  'southwestLng': instance.southwestLng,
  'isOwnLocation': instance.isOwnLocation,
  'name': ?instance.name,
  'address': ?instance.address,
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'updatedAt': ?instance.updatedAt?.toIso8601String(),
};
