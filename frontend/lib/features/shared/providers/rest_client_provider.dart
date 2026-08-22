import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/shared/providers/dio_instance_provider.dart';

/// A provider that provides a new instance of [RestClient] for production
final providerOfRestClient = Provider<RestClient>((ref) {
  return RestClient(ref.watch(providerOfDioInstance(false)));
});

/// A provider that provides a new instance of [RestClient] for production but without retry functionality.
final providerOfRestClientWithoutRetry = Provider<RestClient>((ref) {
  return RestClient(ref.watch(providerOfDioInstance(true)));
});

/// A provider that provides a new instance of [RestClient] for production but with increased timeout time.
final providerOfRestClientWithIncresedTimeout = Provider<RestClient>((ref) {
  final dio = ref.watch(providerOfDioInstance(true));

  dio.options.connectTimeout = const Duration(minutes: 3);
  dio.options.receiveTimeout = const Duration(minutes: 3);
  // sendTimeout does not work on web
  dio.options.sendTimeout = kIsWeb ? null : const Duration(minutes: 3);

  return RestClient(dio);
});
