import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

/// Used to abstract the error handling when making API requests.
/// For a function [future], executes the [onError]
/// and catches the error. Also logs the error.
///
/// This function is based on the premise that exceptions should not
/// propagate further unhandled from the repository layer.
Future<T> runAsyncCall<T>({
  required final String name,
  required Future<T> Function() future,
  required T Function(AppError) onError,
  final bool withLog = true,
}) async {
  try {
    final response = await future();

    if (withLog && name.trim().isNotEmpty) {
      log(
        '$name executed successfully',
        name: 'runAsyncCall',
      );
    }

    return response;
  } catch (e, stkTrace) {
    final stackTrace = stkTrace == StackTrace.empty
        ? StackTrace.current
        : stkTrace;

    var appError = AppError(
      message: 'unknown_error'.tr(),
      detailedMessage: e.toString(),
    );

    if (e is DioException) {
      var message = e.message ?? 'unknown_error'.tr();

      if (e.response?.data is Map) {
        message =
            (e.response?.data['message']?.toString() ??
            e.response?.data['error']?.toString() ??
            'unknown_error'.tr());
      }
      appError = AppError(
        message: message,
        code: e.response?.statusCode?.toString(),
        detailedMessage: e.response?.data is Map
            ? (e.response?.data?.toString() ?? (e.message ?? ''))
            : (e.message ?? ''),
        extraData: e.response?.data is Map
            ? Map<String, dynamic>.from(e.response?.data)
            : <String, dynamic>{},
        requestMethod: e.requestOptions.method,
        requestUri: e.requestOptions.uri,
      );
    } else if (e is Exception) {
      appError = AppError(
        message: e.toString(),
      );
    } else if (e is Error) {
      if (e is ArgumentError) {
        appError = AppError(
          message: e.message,
        );
      } else if (e is AssertionError) {
        appError = AppError(
          message: e.message.toString(),
        );
      } else {
        appError = AppError(
          message: e.toString(),
        );
      }
    } else if (e is AppError) {
      appError = e;
    }

    if (withLog && name.trim().isNotEmpty) {
      log(
        '$name executed with an error',
        name: 'runAsyncCall',
        error: appError.code == null
            ? appError.message
            : '[${appError.code}]: ${appError.message}',
        stackTrace: stackTrace,
      );
    }

    return onError(appError);
  }
}
