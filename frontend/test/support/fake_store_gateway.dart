import 'package:hazard_app/features/subscription/services/purchases_gateway.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// A store that answers the way Google Play does for an Australian
/// account: a current offering with a monthly and an annual package whose
/// prices are AUD formatted with a bare "$", store periods P1M / P1Y, and
/// (when [entitled]) an active `plus` entitlement on the monthly product.
/// Nothing here is a real store; it exists so the paywall and the manage
/// screen can be rendered and asserted without RevenueCat.
class FakeStoreGateway implements PurchasesGateway {
  FakeStoreGateway({this.entitled = false});

  bool entitled;
  String? userId;

  static const monthlyProduct = StoreProduct(
    'alrt_plus_monthly',
    'ALRT+ monthly',
    'ALRT+ Monthly',
    9.99,
    r'$9.99',
    'AUD',
    subscriptionPeriod: 'P1M',
  );
  static const yearlyProduct = StoreProduct(
    'alrt_plus_yearly',
    'ALRT+ yearly',
    'ALRT+ Yearly',
    99.99,
    r'$99.99',
    'AUD',
    subscriptionPeriod: 'P1Y',
  );
  static const _context = PresentedOfferingContext('default', null, null);
  static const monthlyPackage = Package(
    r'$rc_monthly',
    PackageType.monthly,
    monthlyProduct,
    _context,
  );
  static const annualPackage = Package(
    r'$rc_annual',
    PackageType.annual,
    yearlyProduct,
    _context,
  );
  static const offering = Offering(
    'default',
    'Default offering',
    <String, Object>{},
    [monthlyPackage, annualPackage],
    monthly: monthlyPackage,
    annual: annualPackage,
  );

  static const _plus = EntitlementInfo(
    'plus',
    true,
    true,
    '2026-09-09T00:00:00Z',
    '2026-09-09T00:00:00Z',
    'alrt_plus_monthly:monthly',
    true,
    store: Store.playStore,
    expirationDate: '2026-10-09T00:00:00Z',
  );

  @override
  Future<void> configure({
    required String apiKey,
    required String userId,
  }) async => this.userId = userId;

  @override
  Future<void> logIn(String userId) async => this.userId = userId;

  @override
  Future<void> logOut() async => userId = null;

  @override
  Future<Set<String>> activeEntitlements() async =>
      entitled ? {'plus'} : <String>{};

  @override
  Future<CustomerInfo> customerInfo() async => CustomerInfo(
    EntitlementInfos(
      entitled ? {'plus': _plus} : const {},
      entitled ? {'plus': _plus} : const {},
    ),
    const {},
    entitled ? const ['alrt_plus_monthly:monthly'] : const [],
    entitled ? const ['alrt_plus_monthly:monthly'] : const [],
    const [],
    '2026-09-09T00:00:00Z',
    userId ?? 'anonymous',
    const {},
    '2026-09-09T00:00:00Z',
  );

  @override
  Future<Offering?> currentOffering() async => offering;

  @override
  Future<Set<String>> purchase(Package package) async {
    entitled = true;
    return {'plus'};
  }

  @override
  Future<Set<String>> restore() async => entitled ? {'plus'} : <String>{};

  @override
  Future<List<StoreProduct>> products(List<String> identifiers) async => [
    for (final p in const [monthlyProduct, yearlyProduct])
      if (identifiers.contains(p.identifier)) p,
  ];
}
