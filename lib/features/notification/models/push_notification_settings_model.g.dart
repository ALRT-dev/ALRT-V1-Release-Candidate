// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PushNotificationSettings _$PushNotificationSettingsFromJson(
  Map<String, dynamic> json,
) => _PushNotificationSettings(
  awsEmergency: json['awsEmergency'] as bool? ?? false,
  awsWatchAndAct: json['awsWatchAndAct'] as bool? ?? false,
  awsAdvice: json['awsAdvice'] as bool? ?? false,
  officialNonAws: json['officialNonAws'] as bool? ?? false,
  userReported: json['userReported'] as bool? ?? false,
  subscribedCategoryIds:
      (json['subscribedCategoryIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet() ??
      const <String>{},
);

Map<String, dynamic> _$PushNotificationSettingsToJson(
  _PushNotificationSettings instance,
) => <String, dynamic>{
  'awsEmergency': instance.awsEmergency,
  'awsWatchAndAct': instance.awsWatchAndAct,
  'awsAdvice': instance.awsAdvice,
  'officialNonAws': instance.officialNonAws,
  'userReported': instance.userReported,
  'subscribedCategoryIds': instance.subscribedCategoryIds.toList(),
};
