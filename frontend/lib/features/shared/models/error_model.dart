import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_model.freezed.dart';

@freezed
abstract class AppError with _$AppError {
  const factory AppError({
    required final String message,
    final String? code,
    final String? detailedMessage,
    final String? requestMethod,
    final Uri? requestUri,
    @Default(<String, dynamic>{}) final Map<String, dynamic> extraData,
  }) = _AppError;
}
