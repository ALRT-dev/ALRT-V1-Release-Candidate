import 'dart:io' show Platform;

import 'package:hazard_app/features/subscription/services/purchases_gateway.dart';
import 'package:hazard_app/features/subscription/utils/expiry.dart';
import 'package:hazard_app/others/env.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Wraps RevenueCat (the cross-platform subscription layer for ALRT+).
///
/// RevenueCat is the source of truth on-device; the backend keeps its own
/// copy in sync via the RevenueCat webhook. The app never grants
/// entitlements, it only reads them and starts purchases.
///
/// Account rule (phone QA 2026-09-09): an entitlement is only ever read
/// for the ALRT account the SDK is signed in as. The SDK identity follows
/// the ALRT user id; switching accounts signs the SDK in as the new id
/// BEFORE anything is read, and a switch that fails (offline) reads
/// nothing rather than the previous person's entitlement. Signing out of
/// ALRT signs the SDK out too.
class RevenueCatService {
  RevenueCatService({
    PurchasesGateway gateway = const SdkPurchasesGateway(),
    String? apiKeyOverride,
  })  : _gateway = gateway,
        _apiKeyOverride = apiKeyOverride;

  /// The entitlement identifier configured in the RevenueCat dashboard.
  static const String entitlementId = 'plus';

  final PurchasesGateway _gateway;
  final String? _apiKeyOverride;

  bool _configured = false;

  /// The ALRT user id the SDK is currently signed in as, or null when the
  /// SDK identity is unknown (never configured, signed out, or the last
  /// switch failed).
  String? _activeUserId;

  String get _apiKey =>
      _apiKeyOverride ??
      (Platform.isIOS ? Env.revenueCatApiKeyApple : Env.revenueCatApiKeyGoogle);

  bool get _hasKeys => _apiKey.isNotEmpty;

  /// Whether this build carries a RevenueCat key for this platform. Without
  /// one the paywall says so instead of a generic "not available".
  bool get hasKeys => _hasKeys;

  /// The ALRT user the SDK is signed in as, for tests and diagnostics.
  String? get activeUserId => _activeUserId;

  /// Signs the SDK in as [userId] (idempotent). No-op if keys aren't set
  /// yet (the paywall then shows as unavailable rather than crashing).
  /// A failed identity switch leaves [activeUserId] null, so no read can
  /// answer with another account's entitlement.
  Future<void> ensureConfigured(final String userId) async {
    if (!_hasKeys) return;
    if (!_configured) {
      await _gateway.configure(apiKey: _apiKey, userId: userId);
      _configured = true;
      _activeUserId = userId;
      return;
    }
    if (_activeUserId == userId) return;
    _activeUserId = null;
    try {
      await _gateway.logIn(userId);
      _activeUserId = userId;
    } catch (_) {
      // Left unknown on purpose: see the class comment.
    }
  }

  /// Signs the SDK out when the ALRT account signs out, so the next person
  /// on this phone starts with no identity and no entitlement.
  Future<void> signOut() async {
    _activeUserId = null;
    if (!_hasKeys || !_configured) return;
    try {
      await _gateway.logOut();
    } catch (_) {
      // Nothing to read after this anyway.
    }
  }

  bool _ready(final String? forUserId) =>
      _hasKeys &&
      _configured &&
      _activeUserId != null &&
      (forUserId == null || forUserId == _activeUserId);

  /// Whether the signed-in user has an active ALRT+ entitlement. Pass
  /// [forUserId] to refuse an answer for any other identity.
  Future<bool> isPlus({final String? forUserId}) async {
    if (!_ready(forUserId)) return false;
    try {
      return (await _gateway.activeEntitlements()).contains(entitlementId);
    } catch (_) {
      return false;
    }
  }

  /// The current offering (its packages hold store-rendered prices).
  Future<Offering?> currentOffering() async {
    if (!_hasKeys) return null;
    try {
      return await _gateway.currentOffering();
    } catch (_) {
      return null;
    }
  }

  /// Starts the store purchase flow. Returns true if ALRT+ is now active.
  /// Throws the store's error (a cancelled dialog included) for the
  /// paywall to explain.
  Future<bool> purchase(final Package package) async {
    final active = await _gateway.purchase(package);
    return active.contains(entitlementId);
  }

  /// Restores prior purchases (e.g. new device). Returns whether ALRT+ is
  /// now active for the signed-in identity.
  Future<bool> restore() async {
    if (!_ready(null)) return false;
    try {
      return (await _gateway.restore()).contains(entitlementId);
    } catch (_) {
      return false;
    }
  }

  /// The current RevenueCat customer info, or null when unavailable.
  Future<CustomerInfo?> customerInfo() async {
    if (!_ready(null)) return null;
    try {
      return await _gateway.customerInfo();
    } catch (_) {
      return null;
    }
  }

  /// The active ALRT+ entitlement, or null when not subscribed.
  Future<EntitlementInfo?> plusEntitlement() async {
    final info = await customerInfo();
    return info?.entitlements.active[entitlementId];
  }

  /// The ALRT+ entitlement if this customer was subscribed before but it
  /// has since lapsed. See [expiredEntitlementOf] for the exact rule.
  Future<EntitlementInfo?> expiredEntitlement() async {
    return expiredEntitlementOf(await customerInfo(), entitlementId);
  }

  /// The store's subscription-management URL for this customer, if known.
  Future<String?> managementUrl() async {
    return (await customerInfo())?.managementURL;
  }
}
