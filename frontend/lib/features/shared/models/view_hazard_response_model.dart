import 'package:freezed_annotation/freezed_annotation.dart';

part 'view_hazard_response_model.freezed.dart';
part 'view_hazard_response_model.g.dart';

@freezed
abstract class ViewHazardResponse with _$ViewHazardResponse {
  const factory ViewHazardResponse({
    final String? message,
    @Default(false) final bool isViewRecorded,
  }) = _ViewHazardResponse;

  factory ViewHazardResponse.fromJson(Map<String, dynamic> json) =>
      _$ViewHazardResponseFromJson(json);
}
