import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/others/app_info.dart';

/// Provider for the [AppInfo] class.
final providerOfAppInfo = Provider<AppInfo>((ref) {
  return AppInfo();
});

/// Provider for the [DevAppInfo] class.
final providerOfDevAppInfo = Provider<DevAppInfo>((ref) {
  return DevAppInfo();
});
