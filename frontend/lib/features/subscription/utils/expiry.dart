import 'package:purchases_flutter/purchases_flutter.dart';

/// The ALRT+ entitlement if [info] shows a customer who was subscribed
/// before but it has since lapsed — present in `entitlements.all` (every
/// entitlement RevenueCat has ever granted) but no longer in
/// `entitlements.active` (current only). Null both for a customer who has
/// never subscribed (absent from `.all` too) and for one currently
/// subscribed, so callers can route a genuinely-expired customer to a
/// free-plan explanation instead of the plain paywall, with no backend
/// change.
EntitlementInfo? expiredEntitlementOf(
  final CustomerInfo? info,
  final String entitlementId,
) {
  if (info == null) return null;
  if (info.entitlements.active.containsKey(entitlementId)) return null;
  final entitlement = info.entitlements.all[entitlementId];
  if (entitlement == null || entitlement.isActive) return null;
  return entitlement;
}
