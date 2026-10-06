import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/endpoints.dart';

/// Provides the base URL for the API.
final providerOfBaseUrl = Provider<String>((ref) => kUrlBase);

/// Provides the development base URL for the API.
///
/// Defaults to the local dev server ([kUrlBaseDev]); a `DEV_BASE_URL` entry in
/// `.env` overrides it, so CI can build a dev-flavour APK (side-by-side
/// install) that talks to the production backend.
final providerOfBaseUrlDev = Provider<String>((ref) {
  final override = dotenv.env['DEV_BASE_URL'];
  return (override != null && override.isNotEmpty) ? override : kUrlBaseDev;
});
