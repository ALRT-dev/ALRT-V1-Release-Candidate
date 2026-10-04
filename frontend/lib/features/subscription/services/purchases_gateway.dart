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

  /// Every offering by identifier (V1: `personal` and `groups`), or null.
  Future<Offerings?> offerings();

  /// Introductory-offer eligibility per product, from the store. Android
  /// always answers unknown (Play only returns offers the account can use).
  Future<Map<String, IntroEligibilityStatus>> introEligibility(
    List<String> productIdentifiers,
  );

  /// Active entitlements after the store purchase of [package]. With
  /// [replacingProductId] (Google Play only) the purchase REPLACES that
  /// active subscription: an upgrade Family -> Group 20 -> Group 50,
  /// charged the prorated difference, same renewal date.
  Future<Set<String>> purchase(Package package, {String? replacingProductId});

  /// Active entitlements after restoring the store account's purchases.
  Future<Set<String>> restore();

  /// The store's full answer to a restore: which subscriptions are active
  /// for this store account. Throws when the store can't be reached.
  Future<CustomerInfo> restorePurchases();

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
  Future<Offerings?> offerings() => Purchases.getOfferings();

  @override
  Future<Map<String, IntroEligibilityStatus>> introEligibility(
    final List<String> productIdentifiers,
  ) async {
    final map = await Purchases.checkTrialOrIntroductoryPriceEligibility(
      productIdentifiers,
    );
    return map.map((key, value) => MapEntry(key, value.status));
  }

  @override
  Future<Set<String>> purchase(
    Package package, {
    String? replacingProductId,
  }) async => (await Purchases.purchase(
    PurchaseParams.package(
      package,
      productChangeInfo: replacingProductId == null
          ? null
          : StoreProductChangeInfo(
              // Play wants the subscription id, without ":base_plan".
              replacingProductId.split(':').first,
              replacementMode: StoreReplacementMode.chargeProratedPrice,
            ),
    ),
  )).customerInfo.entitlements.active.keys.toSet();

  @override
  Future<Set<String>> restore() async =>
      (await Purchases.restorePurchases()).entitlements.active.keys.toSet();

  @override
  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();

  @override
  Future<List<StoreProduct>> products(final List<String> identifiers) =>
      Purchases.getProducts(identifiers);
}
