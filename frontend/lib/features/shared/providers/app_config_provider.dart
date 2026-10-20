import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/endpoints.dart';
import 'package:hazard_app/features/shared/services/severity_labels.dart';

/// Fetches GET /api/app/config once at startup and populates [SeverityLabels].
///
/// Public endpoint (no auth), so it runs before sign-in.  Uses a plain Dio
/// instance (no token interceptor) matching the pattern in
/// force_update_provider.dart.  Silently succeeds even on failure so
/// a network error never blocks the app from starting.
final appConfigProvider = FutureProvider<void>((ref) async {
  await fetchAppConfig();
});

/// Fetches /api/app/config and populates [SeverityLabels].
/// Can be called directly from bootstrap before ProviderScope is ready.
Future<void> fetchAppConfig() async {
  try {
    final dio = Dio()
      ..options.connectTimeout = const Duration(seconds: 8)
      ..options.receiveTimeout = const Duration(seconds: 8);

    final response = await dio.get<Map<String, dynamic>>(kUrlAppConfig);
    final data = response.data;
    if (data == null) return;

    final rawLabels = data['severityLabels'];
    if (rawLabels is Map<String, dynamic>) {
      SeverityLabels.update(rawLabels);
    }
  } catch (_) {
    // Silently swallow — SeverityLabels retains hardcoded defaults.
  }
}

