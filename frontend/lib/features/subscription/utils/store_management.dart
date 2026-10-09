import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// The App Store's own subscriptions page (manage, renew, cancel).
const kAppleSubscriptionsUrl = 'https://apps.apple.com/account/subscriptions';

/// Google Play's subscriptions page, opened on this app when [packageName]
/// is known.
String playSubscriptionsUrl(final String? packageName) {
  const base = 'https://play.google.com/store/account/subscriptions';
  final id = packageName?.trim() ?? '';
  return id.isEmpty ? base : '$base?package=${Uri.encodeQueryComponent(id)}';
}

/// Where to manage a subscription: RevenueCat's managementURL when it has
/// one, else the store's own subscriptions page for this platform.
String subscriptionManagementUrl({
  required final String? managementUrl,
  required final bool isAndroid,
  final String? packageName,
}) {
  final url = managementUrl?.trim() ?? '';
  if (url.isNotEmpty) return url;
  return isAndroid ? playSubscriptionsUrl(packageName) : kAppleSubscriptionsUrl;
}

/// Opens the store's subscription management for the signed-in customer,
/// falling back to the store's subscriptions page when RevenueCat has no
/// managementURL (a store build before the first purchase syncs, a
/// customer whose purchase came from another store account). Returns
/// false when nothing could be opened, so the caller can say where to go.
Future<bool> openSubscriptionManagement(
  final RevenueCatService rc, {
  final bool? isAndroidOverride,
  final Future<bool> Function(Uri uri)? launcher,
}) async {
  final isAndroid = isAndroidOverride ?? (!kIsWeb && Platform.isAndroid);
  String? managementUrl;
  try {
    managementUrl = await rc.managementUrl();
  } catch (_) {
    managementUrl = null;
  }
  String? packageName;
  if (isAndroid && (managementUrl == null || managementUrl.trim().isEmpty)) {
    try {
      packageName = (await PackageInfo.fromPlatform()).packageName;
    } catch (_) {
      packageName = null;
    }
  }
  final uri = Uri.tryParse(
    subscriptionManagementUrl(
      managementUrl: managementUrl,
      isAndroid: isAndroid,
      packageName: packageName,
    ),
  );
  if (uri == null) return false;
  try {
    return await (launcher ??
        (u) => launchUrl(u, mode: LaunchMode.externalApplication))(uri);
  } catch (_) {
    return false;
  }
}
