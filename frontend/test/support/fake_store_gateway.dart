import 'package:hazard_app/features/subscription/services/purchases_gateway.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// A store that answers the way Google Play does for an Australian
/// account, with the V1 catalogue (master spec 28 Sep 2026): a `personal`
/// offering selling ALRT + Individual monthly (optionally with a free
/// trial) and a `groups` offering selling Family, Group 20 and Group 50
/// monthly. Prices are AUD formatted with a bare "$" and store period P1M.
/// When [entitled], the personal `individual` entitlement is active.
/// Nothing here is a real store; it exists so the purchase screens can be
/// rendered and asserted without RevenueCat. Prices are the target
/// prices, used here only as sample store values.
class FakeStoreGateway implements PurchasesGateway {
  FakeStoreGateway({
    this.entitled = false,
    this.trial = false,
    this.eligibility = IntroEligibilityStatus.introEligibilityStatusEligible,
  });

  bool entitled;

  /// Whether the Individual product carries a free introductory period.
  final bool trial;

  /// What the store says about trial eligibility (iPhone path).
  final IntroEligibilityStatus eligibility;
  String? userId;
  final purchased = <String>[];

  static StoreProduct individualProduct({final bool trial = false}) =>
      StoreProduct(
        'alrt_individual_monthly',
        'ALRT + Individual monthly',
        'ALRT + Individual',
        5.99,
        r'$5.99',
        'AUD',
        subscriptionPeriod: 'P1M',
        introductoryPrice: trial
            ? const IntroductoryPrice(0, r'$0.00', 'P1M', 1, PeriodUnit.month, 1)
            : null,
      );

  static const familyProduct = StoreProduct(
    'alrt_family_monthly',
    'ALRT + Family monthly',
    'ALRT + Family',
    15.99,
    r'$15.99',
    'AUD',
    subscriptionPeriod: 'P1M',
  );
  static const group20Product = StoreProduct(
    'alrt_group20_monthly',
    'ALRT + Group 20 monthly',
    'ALRT + Group 20',
    24.99,
    r'$24.99',
    'AUD',
    subscriptionPeriod: 'P1M',
  );
  static const group50Product = StoreProduct(
    'alrt_group50_monthly',
    'ALRT + Group 50 monthly',
    'ALRT + Group 50',
    49.99,
    r'$49.99',
    'AUD',
    subscriptionPeriod: 'P1M',
  );

  static const _personalContext = PresentedOfferingContext('personal', null, null);
  static const _groupsContext = PresentedOfferingContext('groups', null, null);

  Offering personalOffering() {
    final package = Package(
      r'$rc_monthly',
      PackageType.monthly,
      individualProduct(trial: trial),
      _personalContext,
    );
    return Offering(
      'personal',
      'Personal',
      const <String, Object>{},
      [package],
      monthly: package,
    );
  }

  static const _familyPackage = Package(
    'family',
    PackageType.custom,
    familyProduct,
    _groupsContext,
  );
  static const _group20Package = Package(
    'group20',
    PackageType.custom,
    group20Product,
    _groupsContext,
  );
  static const _group50Package = Package(
    'group50',
    PackageType.custom,
    group50Product,
    _groupsContext,
  );
  static const groupsOffering = Offering(
    'groups',
    'Groups',
    <String, Object>{},
    [_familyPackage, _group20Package, _group50Package],
  );

  static const _individual = EntitlementInfo(
    'individual',
    true,
    true,
    '2026-09-09T00:00:00Z',
    '2026-09-09T00:00:00Z',
    'alrt_individual_monthly:monthly',
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
      entitled ? {'individual'} : <String>{};

  @override
  Future<CustomerInfo> customerInfo() async => CustomerInfo(
    EntitlementInfos(
      entitled ? {'individual': _individual} : const {},
      entitled ? {'individual': _individual} : const {},
    ),
    const {},
    entitled ? const ['alrt_individual_monthly:monthly'] : const [],
    entitled ? const ['alrt_individual_monthly:monthly'] : const [],
    const [],
    '2026-09-09T00:00:00Z',
    userId ?? 'anonymous',
    const {},
    '2026-09-09T00:00:00Z',
  );

  @override
  Future<Offering?> currentOffering() async => personalOffering();

  @override
  Future<Offerings?> offerings() async => Offerings({
    'personal': personalOffering(),
    'groups': groupsOffering,
  }, current: personalOffering());

  @override
  Future<Map<String, IntroEligibilityStatus>> introEligibility(
    List<String> productIdentifiers,
  ) async => {for (final id in productIdentifiers) id: eligibility};

  @override
  Future<Set<String>> purchase(Package package) async {
    purchased.add(package.storeProduct.identifier);
    if (package.storeProduct.identifier == 'alrt_individual_monthly') {
      entitled = true;
    }
    return entitled ? {'individual'} : <String>{};
  }

  @override
  Future<Set<String>> restore() async =>
      entitled ? {'individual'} : <String>{};

  @override
  Future<List<StoreProduct>> products(List<String> identifiers) async => [
    for (final p in [
      individualProduct(trial: trial),
      familyProduct,
      group20Product,
      group50Product,
    ])
      if (identifiers.contains(p.identifier)) p,
  ];
}
