// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_hazard_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ViewHazardResponse _$ViewHazardResponseFromJson(Map<String, dynamic> json) =>
    _ViewHazardResponse(
      message: json['message'] as String?,
      isViewRecorded: json['isViewRecorded'] as bool? ?? false,
    );

Map<String, dynamic> _$ViewHazardResponseToJson(_ViewHazardResponse instance) =>
    <String, dynamic>{
      'message': ?instance.message,
      'isViewRecorded': instance.isViewRecorded,
    };
