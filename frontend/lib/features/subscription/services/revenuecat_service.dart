import 'dart:io' show Platform;

import 'package:flutter/services.dart' show PlatformException;
import 'package:hazard_app/others/env.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Wraps RevenueCat (the cross-platform subscription layer for ALRT+).
///
/// RevenueCat is the source of truth on-device; the backend keeps its own copy
/// in sync via the RevenueCat webhook. The app never grants entitlements — it
/// only reads them and starts purchases.
class RevenueCatService {
  /// The entitlement identifier configured in the RevenueCat dashboard.
  static const String entitlementId = 'plus';

  bool _configured = false;

  bool get _hasKeys =>
      (Platform.isIOS
              ? Env.revenueCatApiKeyApple
              : Env.revenueCatApiKeyGoogle)
          .isNotEmpty;

  /// Configures RevenueCat for [userId] (idempotent). Uses the platform's
  /// public SDK key. No-op if keys aren't set yet (paywall then shows as
  /// unavailable rather than crashing).
  Future<void> ensureConfigured(final String userId) async {
    if (!_hasKeys) return;
    if (_configured) {
      try {
        await Purchases.logIn(userId);
      } catch (_) {}
      return;
    }
    final apiKey = Platform.isIOS
        ? Env.revenueCatApiKeyApple
        : Env.revenueCatApiKeyGoogle;
    await Purchases.configure(
      PurchasesConfiguration(apiKey)..appUserID = userId,
    );
    _configured = true;
  }

  bool _isActive(final CustomerInfo info) =>
      info.entitlements.active.containsKey(entitlementId);

  /// Whether the current user has an active ALRT+ entitlement.
  Future<bool> isPlus() async {
    if (!_hasKeys) return false;
    try {
      return _isActive(await Purchases.getCustomerInfo());
    } catch (_) {
      return false;
    }
  }

  /// The current offering (its packages hold store-rendered prices).
  Future<Offering?> currentOffering() async {
    if (!_hasKeys) return null;
    try {
      return (await Purchases.getOfferings()).current;
    } catch (_) {
      return null;
    }
  }

  /// Starts the store purchase flow. Returns true if ALRT+ is now active,
  /// false if the user cancelled.
  Future<bool> purchase(final Package package) async {
    final result = await Purchases.purchasePackage(package);
    return _isActive(result.customerInfo);
  }

  /// Restores prior purchases (e.g. new device). Returns whether ALRT+ is now
  /// active.
  Future<bool> restore() async {
    if (!_hasKeys) return false;
    try {
      return _isActive(await Purchases.restorePurchases());
    } on PlatformException {
      return false;
    }
  }

  /// The current RevenueCat customer info, or null when unavailable.
  Future<CustomerInfo?> customerInfo() async {
    if (!_hasKeys) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (_) {
      return null;
    }
  }

  /// The active ALRT+ entitlement, or null when not subscribed.
  Future<EntitlementInfo?> plusEntitlement() async {
    final info = await customerInfo();
    return info?.entitlements.active[entitlementId];
  }

  /// The store's subscription-management URL for this customer, if known.
  Future<String?> managementUrl() async {
    return (await customerInfo())?.managementURL;
  }
}
