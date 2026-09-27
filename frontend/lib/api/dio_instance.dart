import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:hazard_app/api/interceptors/auth_interceptor.dart';
import 'package:hazard_app/features/shared/repositories/shared_prefs_repository.dart';

/// Creates a new instance of [Dio] with the given [baseUrl].
///
/// The [baseUrl] parameter is the base URL for the API.
///
/// The [sharedPreferencesRepository] parameter is used to get the current user token.
Dio dioInstance({
  required final String baseUrl,
  required final SharedPreferencesRepository sharedPreferencesRepository,
}) {
  return Dio()
    ..options.baseUrl = baseUrl
    ..options.validateStatus = (status) {
      return status != null && status >= 200 && status < 300;
    }
    ..options.connectTimeout = const Duration(minutes: 2)
    // sendTimeout does not work on web
    ..options.sendTimeout = kIsWeb ? null : const Duration(minutes: 2)
    ..options.receiveTimeout = const Duration(minutes: 2)
    ..interceptors.add(
      AuthInterceptor(
        dio: Dio()..options.baseUrl = baseUrl,
        sharedPreferencesRepository: sharedPreferencesRepository,
      ),
    )
    ..interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          log('[${response.requestOptions.method}]: ${response.requestOptions.path} ------------------------------------------------------- [${response.statusCode}]');
          return handler.next(response);
        },
      ),
    );
}

/// Returns a new instance of [RetryInterceptor] with the given [dio]
RetryInterceptor getRetryInterceptor(final Dio dio) {
  return RetryInterceptor(
    dio: dio,
    logPrint: log,
    retries: 2,
    retryDelays: const [
      Duration(seconds: 1),
      Duration(seconds: 2),
    ],
  );
}
