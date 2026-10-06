import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/endpoints.dart';
import 'package:hazard_app/features/app_update/utils/version_policy.dart';
import 'package:hazard_app/features/shared/providers/base_url_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The version-policy check never holds the app up for long: 8 seconds,
/// then the app carries on as if there were no minimum.
const kVersionPolicyTimeout = Duration(seconds: 8);

/// Reads GET /api/app/version-policy. Public, so a plain Dio without the
/// auth interceptors or retries: it must work signed out, and it must not
/// trigger a token refresh or a sign-out on a 401.
final providerOfVersionPolicySource = Provider<Future<Object?> Function()>((
  ref,
) {
  final baseUrl = ref.watch(providerOfBaseUrl);
  return () async {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: kVersionPolicyTimeout,
        receiveTimeout: kVersionPolicyTimeout,
        sendTimeout: kVersionPolicyTimeout,
      ),
    );
    try {
      final response = await dio
          .get<dynamic>(kUrlAppVersionPolicy)
          .timeout(kVersionPolicyTimeout);
      return response.data;
    } finally {
      dio.close();
    }
  };
});

/// The installed version and build number (package_info_plus).
final providerOfInstalledVersion =
    Provider<Future<({String version, String buildNumber})> Function()>(
      (ref) => () async {
        final info = await PackageInfo.fromPlatform();
        return (version: info.version, buildNumber: info.buildNumber);
      },
    );

/// True on iPhone, false on Android, null anywhere a store minimum does
/// not apply (web, desktop, tests).
final providerOfVersionPolicyPlatform = Provider<bool?>((ref) {
  if (kIsWeb) return null;
  if (Platform.isIOS) return true;
  if (Platform.isAndroid) return false;
  return null;
});

/// This build is below the platform's minimum: the store page to update
/// from (null when the backend gave none).
class RequiredUpdate {
  const RequiredUpdate({this.storeUrl});

  final String? storeUrl;
}

/// Null while the app may run; a [RequiredUpdate] once the backend says
/// this build is no longer supported. Checked once per launch; any
/// failure (offline, timeout, bad answer, endpoint missing) leaves it null.
class ForceUpdateNotifier extends Notifier<RequiredUpdate?> {
  bool _checked = false;

  @override
  RequiredUpdate? build() => null;

  Future<void> check() async {
    if (_checked) return;
    _checked = true;
    final isIOS = ref.read(providerOfVersionPolicyPlatform);
    if (isIOS == null) return;
    try {
      final json = await ref
          .read(providerOfVersionPolicySource)()
          .timeout(kVersionPolicyTimeout);
      final installed = await ref.read(providerOfInstalledVersion)();
      if (!ref.mounted) return;
      final policy = policyForPlatform(json, isIOS: isIOS);
      if (isUpdateRequired(
        version: installed.version,
        buildNumber: installed.buildNumber,
        policy: policy,
      )) {
        state = RequiredUpdate(storeUrl: policy.storeUrl);
      }
    } catch (_) {
      // Ignored on purpose: never lock anyone out on a failed check.
    }
  }
}

final providerOfForceUpdate =
    NotifierProvider<ForceUpdateNotifier, RequiredUpdate?>(
      ForceUpdateNotifier.new,
    );
