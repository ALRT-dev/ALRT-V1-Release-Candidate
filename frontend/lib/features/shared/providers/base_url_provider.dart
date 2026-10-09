import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/endpoints.dart';

/// Provides the base URL for the API.
final providerOfBaseUrl = Provider<String>((ref) => kUrlBase);

/// Provides the development base URL for the API.
///
/// Defaults to the local dev server ([kUrlBaseDev]); a `DEV_BASE_URL` entry in
/// the build-time defines overrides it, so CI can build a dev-flavour APK
/// (side-by-side install) that talks to the production backend.
final providerOfBaseUrlDev = Provider<String>((ref) {
  const override = String.fromEnvironment('DEV_BASE_URL');
  return override.isNotEmpty ? override : kUrlBaseDev;
});
