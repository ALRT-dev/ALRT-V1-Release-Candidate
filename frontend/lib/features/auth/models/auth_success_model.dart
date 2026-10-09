import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_success_model.freezed.dart';
part 'auth_success_model.g.dart';

@freezed
abstract class AuthSuccess with _$AuthSuccess {
  const factory AuthSuccess({
    required final String accessToken,
    required final String refreshToken,
  }) = _AuthSuccess;

  factory AuthSuccess.fromJson(Map<String, dynamic> json) =>
      _$AuthSuccessFromJson(json);
}
