// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_success_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthSuccess _$AuthSuccessFromJson(Map<String, dynamic> json) => _AuthSuccess(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$AuthSuccessToJson(_AuthSuccess instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
