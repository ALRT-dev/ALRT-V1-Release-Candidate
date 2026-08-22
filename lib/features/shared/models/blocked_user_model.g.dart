// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BlockedUser _$BlockedUserFromJson(Map<String, dynamic> json) => _BlockedUser(
  userId: json['userId'] as String,
  name: json['name'] as String? ?? 'Community member',
  blockedAt: json['blockedAt'] == null
      ? null
      : DateTime.parse(json['blockedAt'] as String),
);

Map<String, dynamic> _$BlockedUserToJson(_BlockedUser instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'blockedAt': ?instance.blockedAt?.toIso8601String(),
    };

_BlockedUsersResponse _$BlockedUsersResponseFromJson(
  Map<String, dynamic> json,
) => _BlockedUsersResponse(
  blocked:
      (json['blocked'] as List<dynamic>?)
          ?.map((e) => BlockedUser.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <BlockedUser>[],
);

Map<String, dynamic> _$BlockedUsersResponseToJson(
  _BlockedUsersResponse instance,
) => <String, dynamic>{
  'blocked': instance.blocked.map((e) => e.toJson()).toList(),
};
