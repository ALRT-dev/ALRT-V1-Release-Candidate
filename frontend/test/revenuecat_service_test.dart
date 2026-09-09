import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/subscription/services/purchases_gateway.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:hazard_app/features/subscription/utils/purchase_error_message.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// A stand-in store: entitlements per ALRT user id, the identity the SDK
/// is signed in as, and switches that can be made to fail (offline).
class _FakeGateway implements PurchasesGateway {
  final entitlementsByUser = <String, Set<String>>{};
  String? signedInAs;
  bool logInFails = false;
  final calls = <String>[];

  @override
  Future<void> configure({required String apiKey, required String userId}) async {
    calls.add('configure:$userId');
    signedInAs = userId;
  }

  @override
  Future<void> logIn(String userId) async {
    calls.add('logIn:$userId');
    if (logInFails) throw PlatformException(code: '10', message: 'offline');
    signedInAs = userId;
  }

  @override
  Future<void> logOut() async {
    calls.add('logOut');
    signedInAs = null;
  }

  @override
  Future<Set<String>> activeEntitlements() async =>
      entitlementsByUser[signedInAs] ?? const {};

  @override
  Future<Set<String>> restore() async => activeEntitlements();

  @override
  Future<CustomerInfo> customerInfo() => throw UnimplementedError();

  @override
  Future<Offering?> currentOffering() async => null;

  @override
  Future<Set<String>> purchase(Package package) => throw UnimplementedError();
}

void main() {
  RevenueCatService service(_FakeGateway g) =>
      RevenueCatService(gateway: g, apiKeyOverride: 'test-key');

  test('an existing subscriber is entitled without any purchase prompt', () async {
    final g = _FakeGateway()..entitlementsByUser['amy'] = {'plus'};
    final rc = service(g);
    await rc.ensureConfigured('amy');
    expect(await rc.isPlus(forUserId: 'amy'), isTrue);
    expect(g.calls, ['configure:amy']);
  });

  test('a free account is not entitled', () async {
    final g = _FakeGateway();
    final rc = service(g);
    await rc.ensureConfigured('bob');
    expect(await rc.isPlus(forUserId: 'bob'), isFalse);
  });

  test('switching accounts signs the SDK in as the new id before reading', () async {
    final g = _FakeGateway()..entitlementsByUser['amy'] = {'plus'};
    final rc = service(g);
    await rc.ensureConfigured('amy');
    expect(await rc.isPlus(forUserId: 'amy'), isTrue);
    await rc.ensureConfigured('bob');
    expect(g.calls.last, 'logIn:bob');
    expect(await rc.isPlus(forUserId: 'bob'), isFalse,
        reason: "Bob never sees Amy's entitlement");
  });

  test("a failed switch (offline) reads nothing, never the previous account's entitlement", () async {
    final g = _FakeGateway()..entitlementsByUser['amy'] = {'plus'};
    final rc = service(g);
    await rc.ensureConfigured('amy');
    g.logInFails = true;
    await rc.ensureConfigured('bob');
    expect(rc.activeUserId, isNull);
    expect(await rc.isPlus(forUserId: 'bob'), isFalse);
    expect(await rc.isPlus(), isFalse, reason: 'unknown identity answers no');
    expect(await rc.restore(), isFalse, reason: 'restore needs a known identity');
  });

  test('a read for a different account than the one signed in answers no', () async {
    final g = _FakeGateway()..entitlementsByUser['amy'] = {'plus'};
    final rc = service(g);
    await rc.ensureConfigured('amy');
    expect(await rc.isPlus(forUserId: 'bob'), isFalse);
  });

  test('signing out of ALRT signs the store identity out; a new sign-in starts clean', () async {
    final g = _FakeGateway()..entitlementsByUser['amy'] = {'plus'};
    final rc = service(g);
    await rc.ensureConfigured('amy');
    await rc.signOut();
    expect(g.calls.last, 'logOut');
    expect(await rc.isPlus(), isFalse);
    await rc.ensureConfigured('bob');
    expect(g.calls.last, 'logIn:bob');
    expect(await rc.isPlus(forUserId: 'bob'), isFalse);
  });

  test('restore returns the entitlement the store account holds', () async {
    final g = _FakeGateway()..entitlementsByUser['amy'] = {'plus'};
    final rc = service(g);
    await rc.ensureConfigured('amy');
    expect(await rc.restore(), isTrue);
  });

  test('without a billing key nothing is configured and nothing is entitled', () async {
    final g = _FakeGateway()..entitlementsByUser['amy'] = {'plus'};
    final rc = RevenueCatService(gateway: g, apiKeyOverride: '');
    await rc.ensureConfigured('amy');
    expect(rc.hasKeys, isFalse);
    expect(g.calls, isEmpty);
    expect(await rc.isPlus(forUserId: 'amy'), isFalse);
  });

  group('store errors are explained, a cancel is not an error', () {
    String code(PurchasesErrorCode c) => '${PurchasesErrorCode.values.indexOf(c)}';

    test('cancelled purchase shows no error', () {
      expect(
        purchaseErrorMessage(
          PlatformException(code: code(PurchasesErrorCode.purchaseCancelledError)),
        ),
        isNull,
      );
    });

    test('network, unavailable product and unknown codes are named', () {
      expect(
        purchaseErrorMessage(
          PlatformException(code: code(PurchasesErrorCode.networkError)),
        ),
        contains('No connection'),
      );
      expect(
        purchaseErrorMessage(
          PlatformException(code: code(PurchasesErrorCode.productNotAvailableForPurchaseError)),
        ),
        contains('not available in the store'),
      );
      expect(
        purchaseErrorMessage(
          PlatformException(code: code(PurchasesErrorCode.storeProblemError)),
        ),
        contains('storeProblemError'),
      );
      expect(purchaseErrorMessage(StateError('x')), isNotNull);
    });
  });
}
