import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_alrt_plus_screen.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:hazard_app/features/subscription/utils/restore_outcome.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_group_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_manage_screen.dart';
import 'package:hazard_app/others/app_theme.dart';

import 'support/fake_access_repository.dart';
import 'support/fake_store_gateway.dart';

/// Widget-level evidence for upgrades (Android replacement vs App Store),
/// truthful Restore and the optional onboarding step. A fake store and a
/// fake backend: NOT store-sandbox or device evidence.

AccessSummary _access(List<GroupAccess> groups) => AccessSummary(
  billingEnabled: true,
  personal: PersonalAccess.free,
  groups: groups,
  unboundSponsorships: const [],
  computedAt: DateTime(2026, 9, 28),
);

GroupAccess _covered(PlanTier tier, {int people = 6, bool youPay = true}) =>
    GroupAccess(
      circleId: 'g1',
      name: 'Netball Mums',
      role: 'owner',
      fundingMode: GroupFundingMode.sponsored,
      peopleCount: people,
      capacity: sponsoredCapacity(tier),
      sponsorship: GroupSponsorship(
        tier: tier,
        live: true,
        status: 'active',
        expiresAt: null,
        coveredBy: 'Sarah',
        youPay: youPay,
        productId: youPay ? 'alrt_family_monthly' : null,
      ),
      connectionAllowed: true,
      connectionReason: 'sponsored',
    );

Future<(FakeStoreGateway, RevenueCatService)> _store() async {
  final gateway = FakeStoreGateway();
  final service = RevenueCatService(gateway: gateway, apiKeyOverride: 'k');
  await service.ensureConfigured('u-test');
  return (gateway, service);
}

Widget _app(
  Widget home,
  RevenueCatService service,
  FakeAccessRepository repo,
) => ProviderScope(
  overrides: [
    providerOfRevenueCat.overrideWithValue(service),
    providerOfAccessRepository.overrideWithValue(repo),
    providerOfAccess.overrideWith((ref) async => repo.access),
    providerOfAlrtPlus.overrideWith((ref) async => false),
    providerOfAlrtPlusBillingIssue.overrideWith((ref) async => false),
    providerOfExpiredAlrtPlus.overrideWith((ref) async => null),
  ],
  child: ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => MaterialApp(
      theme: AppTheme.lightPalette,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<bool>(builder: (_) => home)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'ALRT_PLUS_TEST_UNLOCK=false\n');
  });
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 7500);
    view.devicePixelRatio = 3.0;
  });
  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  group('Upgrade Family -> Group 20', () {
    testWidgets('Android: the purchase replaces the Family subscription and '
        'waits for ALRT to confirm Group 20', (tester) async {
      final (gateway, service) = await _store();
      final repo = FakeAccessRepository(
        access: _access([_covered(PlanTier.family)]),
        intent: const SponsorshipIntentResult(
          replacesTier: PlanTier.family,
          replacesProductId: 'alrt_family_monthly:monthly',
        ),
      );
      repo.reconcileResult = ReconcileResult(
        storeChecked: true,
        confirmedChanges: 1,
        unrecorded: const [],
        access: _access([_covered(PlanTier.group20)]),
      );
      await tester.pumpWidget(
        _app(
          const AlrtPlusGroupPaywallScreen(
            isAndroidOverride: true,
            args: AlrtPlusGroupPaywallArgs(
              circleId: 'g1',
              tier: PlanTier.group20,
            ),
          ),
          service,
          repo,
        ),
      );
      await _open(tester);

      expect(
        find.text('Up to 6 people · your current plan'),
        findsOneWidget,
      );
      expect(find.text('Up to 20 people · upgrade'), findsOneWidget);
      expect(find.text(r'Upgrade for $24.99 AUD/month'), findsOneWidget);
      expect(find.textContaining('prorated difference'), findsOneWidget);
      expect(find.textContaining('No free trial.'), findsOneWidget);
      expect(find.textContaining('month free'), findsNothing);

      await tester.tap(find.text(r'Upgrade for $24.99 AUD/month'));
      await tester.pumpAndSettle();
      expect(repo.intents.single, ('g1', PlanTier.group20));
      expect(gateway.purchased.single, 'alrt_group20_monthly');
      expect(gateway.replaced.single, 'alrt_family_monthly:monthly');
      expect(
        find.text(
          'Upgrade confirmed. Netball Mums is now covered for up to 20 people.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('App Store: no replacement id; while unconfirmed the group '
        'is said to stay on Family', (tester) async {
      final (gateway, service) = await _store();
      final repo = FakeAccessRepository(
        access: _access([_covered(PlanTier.family)]),
        intent: const SponsorshipIntentResult(
          replacesTier: PlanTier.family,
          replacesProductId: 'alrt_family_monthly',
        ),
      );
      await tester.pumpWidget(
        _app(
          const AlrtPlusGroupPaywallScreen(
            isAndroidOverride: false,
            args: AlrtPlusGroupPaywallArgs(
              circleId: 'g1',
              tier: PlanTier.group20,
            ),
          ),
          service,
          repo,
        ),
      );
      await _open(tester);
      expect(find.textContaining('refunds the unused part'), findsOneWidget);
      await tester.tap(find.text(r'Upgrade for $24.99 AUD/month'));
      // Five confirmation attempts, two seconds apart.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(seconds: 2));
      }
      await tester.pumpAndSettle();
      expect(gateway.replaced.single, isNull);
      expect(repo.reconcileCalls, 5);
      expect(
        find.textContaining('Netball Mums stays on Family until it is confirmed'),
        findsOneWidget,
      );
    });

    testWidgets('someone else\'s plan: nothing to buy, and it says who can '
        'change it', (tester) async {
      final (_, service) = await _store();
      final repo = FakeAccessRepository(
        access: _access([_covered(PlanTier.family, youPay: false)]),
      );
      await tester.pumpWidget(
        _app(
          const AlrtPlusGroupPaywallScreen(isAndroidOverride: true),
          service,
          repo,
        ),
      );
      await _open(tester);
      expect(
        find.textContaining('Only the person who pays for it can change it'),
        findsOneWidget,
      );
      final cta = tester.widget<FilledButton>(
        find.ancestor(
          of: find.textContaining('Subscribe for'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(cta.onPressed, isNull);
    });
  });

  group('Restore on My plans', () {
    testWidgets('store unreachable is said as such', (tester) async {
      final (gateway, service) = await _store();
      gateway.restoreFails = true;
      final repo = FakeAccessRepository(access: _access(const []));
      await tester.pumpWidget(_app(const AlrtPlusManageScreen(), service, repo));
      await _open(tester);
      await tester.tap(find.text('Restore purchases'));
      await tester.pumpAndSettle();
      expect(find.text(kRestoreStoreUnavailable), findsOneWidget);
      expect(repo.reconcileCalls, 0);
    });

    testWidgets('nothing on the store account', (tester) async {
      final (_, service) = await _store();
      final repo = FakeAccessRepository(access: _access(const []));
      await tester.pumpWidget(_app(const AlrtPlusManageScreen(), service, repo));
      await _open(tester);
      await tester.tap(find.text('Restore purchases'));
      await tester.pumpAndSettle();
      expect(find.text(kRestoreNothingFound), findsOneWidget);
    });

    testWidgets('found but not yet recorded: pending, after retrying', (
      tester,
    ) async {
      final (gateway, service) = await _store();
      gateway.restoredProducts = const ['alrt_family_monthly'];
      final repo = FakeAccessRepository(access: _access(const []));
      repo.reconcileResult = ReconcileResult(
        storeChecked: true,
        confirmedChanges: 0,
        unrecorded: const [PlanTier.family],
        products: const [
          ReconcileProduct(
            productId: 'alrt_family_monthly',
            tier: PlanTier.family,
            status: ReconcileProductStatus.pending,
          ),
        ],
        access: _access(const []),
      );
      await tester.pumpWidget(_app(const AlrtPlusManageScreen(), service, repo));
      await _open(tester);
      await tester.tap(find.text('Restore purchases'));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 2));
      }
      await tester.pumpAndSettle();
      expect(repo.reconcileCalls, 3);
      expect(repo.lastProductIds, ['alrt_family_monthly']);
      expect(find.text(kRestorePending), findsOneWidget);
    });

    testWidgets('confirmed names the plan', (tester) async {
      final (gateway, service) = await _store();
      gateway.restoredProducts = const ['alrt_family_monthly'];
      final repo = FakeAccessRepository(
        access: _access([_covered(PlanTier.family)]),
      );
      repo.reconcileResult = ReconcileResult(
        storeChecked: true,
        confirmedChanges: 0,
        unrecorded: const [],
        products: const [
          ReconcileProduct(
            productId: 'alrt_family_monthly',
            tier: PlanTier.family,
            status: ReconcileProductStatus.confirmed,
            bound: true,
          ),
        ],
        access: _access([_covered(PlanTier.family)]),
      );
      await tester.pumpWidget(_app(const AlrtPlusManageScreen(), service, repo));
      await _open(tester);
      await tester.tap(find.text('Restore purchases'));
      await tester.pumpAndSettle();
      expect(
        find.text('Purchases restored: ALRT + Family for Netball Mums.'),
        findsOneWidget,
      );
    });
  });

  group('Ambiguous upgrade recovery and dated changes (My plans)', () {
    testWidgets('the payer replaces their own smaller plan explicitly, and is '
        'told the old subscription may still renew', (tester) async {
      final (_, service) = await _store();
      final access = AccessSummary(
        billingEnabled: true,
        personal: PersonalAccess.free,
        groups: [_covered(PlanTier.family)],
        unboundSponsorships: const [
          UnboundSponsorship(id: 'sub-20', tier: PlanTier.group20, expiresAt: null),
        ],
        computedAt: DateTime(2026, 9, 29),
      );
      final repo = FakeAccessRepository(access: access)
        ..bindResult = const BindResult(
          replacedTier: PlanTier.family,
          replacedMayStillRenew: true,
        );
      await tester.pumpWidget(_app(const AlrtPlusManageScreen(), service, repo));
      await _open(tester);
      await tester.tap(find.text('Choose the group it covers'));
      await tester.pumpAndSettle();
      expect(find.text('Replace your ALRT + Family plan here'), findsOneWidget);
      await tester.tap(find.byKey(const Key('replace-g1')));
      await tester.pumpAndSettle();
      expect(find.textContaining('ALRT can\'t cancel store subscriptions'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm-replace')));
      await tester.pumpAndSettle();
      expect(repo.binds.single, ('sub-20', 'g1', true));
      expect(
        find.textContaining('may still renew: cancel it in your app store'),
        findsOneWidget,
      );
    });

    testWidgets('a change dated for later says when, and what holds until then', (
      tester,
    ) async {
      final (_, service) = await _store();
      final group = GroupAccess(
        circleId: 'g1',
        name: 'Netball Mums',
        role: 'owner',
        fundingMode: GroupFundingMode.sponsored,
        peopleCount: 9,
        capacity: 20,
        sponsorship: GroupSponsorship(
          tier: PlanTier.group20,
          live: true,
          status: 'active',
          expiresAt: null,
          coveredBy: 'Sarah',
          youPay: true,
          pendingTier: PlanTier.family,
          pendingEffectiveAt: DateTime(2026, 10, 28, 12),
        ),
        connectionAllowed: true,
        connectionReason: 'sponsored',
      );
      final repo = FakeAccessRepository(access: _access([group]));
      await tester.pumpWidget(_app(const AlrtPlusManageScreen(), service, repo));
      await _open(tester);
      expect(
        find.text(
          'Changes to ALRT + Family on 28 October 2026. Until then it stays '
          'Group 20, up to 20 people.',
        ),
        findsOneWidget,
      );
    });
  });

  group('Onboarding ALRT + step', () {
    testWidgets('optional: Continue with ALRT Free moves on, nothing is '
        'bought, group plans are explained for later', (tester) async {
      final (gateway, service) = await _store();
      final repo = FakeAccessRepository(access: _access(const []));
      var done = 0;
      await tester.pumpWidget(
        _app(OnboardingAlrtPlusScreen(onDone: () => done++), service, repo),
      );
      await _open(tester);
      expect(find.text('ALRT is free to use'), findsOneWidget);
      expect(find.text(kChooseForMyselfTitle), findsOneWidget);
      expect(find.text(kChooseCoverGroupTitle), findsOneWidget);
      expect(find.textContaining('Create or join a group in Family first'),
          findsOneWidget);
      await tester.tap(find.text(kContinueFree));
      await tester.pumpAndSettle();
      expect(done, 1);
      expect(gateway.purchased, isEmpty);
    });
  });
}
