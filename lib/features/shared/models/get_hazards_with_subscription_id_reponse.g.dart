// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_hazards_with_subscription_id_reponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GetHazardsWithSubscriptionIdResponse
_$GetHazardsWithSubscriptionIdResponseFromJson(Map<String, dynamic> json) =>
    _GetHazardsWithSubscriptionIdResponse(
      hazards:
          (json['hazards'] as List<dynamic>?)
              ?.map((e) => Hazard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Hazard>[],
      subscriptionId: json['subscriptionId'] as String?,
    );

Map<String, dynamic> _$GetHazardsWithSubscriptionIdResponseToJson(
  _GetHazardsWithSubscriptionIdResponse instance,
) => <String, dynamic>{
  'hazards': instance.hazards.map((e) => e.toJson()).toList(),
  'subscriptionId': ?instance.subscriptionId,
};
