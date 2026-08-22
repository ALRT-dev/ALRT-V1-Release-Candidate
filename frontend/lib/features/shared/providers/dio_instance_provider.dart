import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/dio_instance.dart';
import 'package:hazard_app/features/shared/enums/network_connection_status.dart';
import 'package:hazard_app/features/shared/providers/base_url_provider.dart';
import 'package:hazard_app/features/shared/providers/network_connection_checker_provider.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';

/// A provider that provides a new instance of [Dio] with the given baseUrl.
///
/// The parameter [disableRetryFunction] is used to disable the retry interceptor.
final providerOfDioInstance = Provider.family<Dio, bool>((
  ref,
  disableRetryFunction,
) {
  final sharedPreferencesRepository = ref.watch(
    providerOfSharedPreferencesRepository,
  );
  final dio = dioInstance(
    baseUrl: ref.watch(providerOfBaseUrl),
    sharedPreferencesRepository: sharedPreferencesRepository,
  );

  // if the retry interceptor is not added to the dio instance, then add it
  final alreadyHasRetryInterceptor = dio.interceptors.any(
    (element) => element is RetryInterceptor,
  );
  if (!alreadyHasRetryInterceptor) {
    dio.interceptors.add(getRetryInterceptor(dio));
  }

  // check if the network connection is disconnected
  final isDisconnected = ref.watch(
    providerOfNetworkConnectionStatus.select(
      (value) => value == NetworkConnectionStatus.disconnected,
    ),
  );

  // if the network connection is disconnected, then remove the retry interceptor
  // because we don't need to retry the request if there is no network connection
  //
  // also, if the [disableRetryFunction] is true, then remove the retry interceptor
  if (isDisconnected || disableRetryFunction) {
    dio.interceptors.removeWhere(
      (element) => element is RetryInterceptor,
    );
  }

  return dio;
});
