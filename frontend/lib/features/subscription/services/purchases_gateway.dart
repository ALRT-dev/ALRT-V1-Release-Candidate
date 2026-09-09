import 'package:purchases_flutter/purchases_flutter.dart';

/// The thin seam between ALRT and the RevenueCat SDK, so the account
/// rules in [RevenueCatService] (whose entitlement is read, when the
/// identity switches, what a failed switch means) can be tested without
/// a store. The default implementation forwards to [Purchases].
abstract class PurchasesGateway {
  Future<void> configure({required String apiKey, required String userId});
  Future<void> logIn(String userId);
  Future<void> logOut();

  /// Identifiers of the entitlements active for the CURRENT SDK identity.
  Future<Set<String>> activeEntitlements();
  Future<CustomerInfo> customerInfo();
  Future<Offering?> currentOffering();

  /// Active entitlements after the store purchase of [package].
  Future<Set<String>> purchase(Package package);

  /// Active entitlements after restoring the store account's purchases.
  Future<Set<String>> restore();

  /// Store products by identifier (subscriptions), with the store's own
  /// price, currency and period. Empty when the store knows none of them.
  Future<List<StoreProduct>> products(List<String> identifiers);
}

class SdkPurchasesGateway implements PurchasesGateway {
  const SdkPurchasesGateway();

  @override
  Future<void> configure({required String apiKey, required String userId}) =>
      Purchases.configure(PurchasesConfiguration(apiKey)..appUserID = userId);

  @override
  Future<void> logIn(String userId) => Purchases.logIn(userId);

  @override
  Future<void> logOut() => Purchases.logOut();

  @override
  Future<Set<String>> activeEntitlements() async =>
      (await Purchases.getCustomerInfo()).entitlements.active.keys.toSet();

  @override
  Future<CustomerInfo> customerInfo() => Purchases.getCustomerInfo();

  @override
  Future<Offering?> currentOffering() async =>
      (await Purchases.getOfferings()).current;

  @override
  Future<Set<String>> purchase(Package package) async =>
      // ignore: deprecated_member_use
      (await Purchases.purchasePackage(
        package,
      )).customerInfo.entitlements.active.keys.toSet();

  @override
  Future<Set<String>> restore() async =>
      (await Purchases.restorePurchases()).entitlements.active.keys.toSet();

  @override
  Future<List<StoreProduct>> products(final List<String> identifiers) =>
      Purchases.getProducts(identifiers);
}
