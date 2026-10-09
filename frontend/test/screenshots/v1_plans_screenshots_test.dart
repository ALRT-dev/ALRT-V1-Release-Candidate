// Renders the implemented V1 plan screens with the app's fonts and writes
// PNGs, so the real UI can be reviewed without a device. Test renders
// only: a fake store supplies sample prices; nothing here is a purchase.
//
// Opt-in: `ALRT_SCREENSHOTS=1 flutter test --update-goldens
// test/screenshots/v1_plans_screenshots_test.dart` writes
// test/screenshots/goldens/v1_*.png (git-ignored).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_alrt_plus_screen.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';
import 'package:hazard_app/features/subscription/utils/access_refusal.dart';
import 'package:hazard_app/features/subscription/views/widgets/access_refusal_sheet.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_choose_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_group_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_manage_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_upsell_sheet.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../support/fake_access_repository.dart';
import '../support/fake_store_gateway.dart';
import 'screenshot_fonts.dart';

final _enabled = Platform.environment['ALRT_SCREENSHOTS'] == '1';

Future<RevenueCatService> _service({
  bool trial = false,
  IntroEligibilityStatus eligibility =
      IntroEligibilityStatus.introEligibilityStatusEligible,
}) async {
  final s = RevenueCatService(
    gateway: FakeStoreGateway(trial: trial, eligibility: eligibility),
    apiKeyOverride: 'test-key',
  );
  await s.ensureConfigured('u-test');
  return s;
}

GroupAccess _group(
  String id,
  String name, {
  String role = 'owner',
  int people = 3,
  GroupSponsorship? sponsorship,
  bool allowed = true,
  String reason = 'individual',
}) => GroupAccess(
  circleId: id,
  name: name,
  role: role,
  fundingMode: sponsorship == null
      ? GroupFundingMode.individual
      : GroupFundingMode.sponsored,
  peopleCount: people,
  capacity: sponsorship == null ? null : sponsoredCapacity(sponsorship.tier),
  sponsorship: sponsorship,
  connectionAllowed: allowed,
  connectionReason: reason,
);

AccessSummary _access({
  PersonalAccess personal = PersonalAccess.free,
  List<GroupAccess> groups = const [],
}) => AccessSummary(
  billingEnabled: true,
  personal: personal,
  groups: groups,
  unboundSponsorships: const [],
  computedAt: DateTime(2026, 9, 28),
);

Widget _app(Widget home, RevenueCatService service, AccessSummary access) =>
    ProviderScope(
      overrides: [
        providerOfRevenueCat.overrideWithValue(service),
        providerOfAccess.overrideWith((ref) async => access),
        providerOfAccessRepository.overrideWithValue(
          FakeAccessRepository(access: access),
        ),
        providerOfAlrtPlus.overrideWith(
          (ref) async => access.personal.isIndividual,
        ),
        providerOfAlrtPlusBillingIssue.overrideWith((ref) async => false),
        providerOfExpiredAlrtPlus.overrideWith((ref) async => null),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightPalette,
          home: home,
        ),
      ),
    );

Future<void> _shoot(
  WidgetTester tester,
  String name, {
  Size size = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  await tester.pump(const Duration(milliseconds: 300));
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  setUpAll(() async {
    dotenv.loadFromString(envString: 'ALRT_PLUS_TEST_UNLOCK=false\n');
    if (_enabled) await loadScreenshotFonts();
  });

  const tall = Size(390, 1250);

  testWidgets('chooser', (tester) async {
    await tester.pumpWidget(
      _app(const AlrtPlusChooseScreen(), await _service(), _access()),
    );
    await tester.pumpAndSettle();
    await _shoot(tester, 'v1_01_choose');
  }, skip: !_enabled);

  testWidgets('Individual, eligible Android trial', (tester) async {
    await tester.pumpWidget(
      _app(
        const AlrtPlusPaywallScreen(isAndroidOverride: true),
        await _service(trial: true),
        _access(),
      ),
    );
    await tester.pumpAndSettle();
    await _shoot(tester, 'v1_02_individual_trial', size: tall);
  }, skip: !_enabled);

  testWidgets('Individual, iPhone not eligible', (tester) async {
    await tester.pumpWidget(
      _app(
        const AlrtPlusPaywallScreen(
          isAndroidOverride: false,
          args: AlrtPlusPaywallArgs(
            reason: AlrtPlusPaywallReason.savedLocation,
          ),
        ),
        await _service(
          trial: true,
          eligibility: IntroEligibilityStatus.introEligibilityStatusIneligible,
        ),
        _access(),
      ),
    );
    await tester.pumpAndSettle();
    await _shoot(tester, 'v1_03_individual_no_trial', size: tall);
  }, skip: !_enabled);

  testWidgets('Cover a group, Family selected', (tester) async {
    await tester.pumpWidget(
      _app(
        const AlrtPlusGroupPaywallScreen(isAndroidOverride: true),
        await _service(),
        _access(
          groups: [
            _group('g1', 'Nixon Family', people: 4),
            _group('g2', 'Netball Mums', people: 14),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _shoot(tester, 'v1_04_group_family', size: const Size(390, 1500));
  }, skip: !_enabled);

  testWidgets('Cover a group, 14 people: Family too small, Group 20', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const AlrtPlusGroupPaywallScreen(
          isAndroidOverride: true,
          args: AlrtPlusGroupPaywallArgs(circleId: 'g2'),
        ),
        await _service(),
        _access(
          groups: [
            _group('g1', 'Nixon Family', people: 4),
            _group('g2', 'Netball Mums', people: 14),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('ALRT + Group 20').last);
    await tester.pumpAndSettle();
    await _shoot(tester, 'v1_05_group_20', size: const Size(390, 1500));
  }, skip: !_enabled);

  testWidgets('My plans: Family payer without Individual', (tester) async {
    await tester.pumpWidget(
      _app(
        const AlrtPlusManageScreen(),
        await _service(),
        _access(
          groups: [
            _group(
              'g1',
              'Nixon Family',
              people: 4,
              sponsorship: const GroupSponsorship(
                tier: PlanTier.family,
                live: true,
                status: 'active',
                expiresAt: null,
                coveredBy: 'Sarah',
                youPay: true,
              ),
              reason: 'sponsored',
            ),
            _group(
              'g2',
              'Weekend Crew',
              role: 'adult',
              people: 5,
              allowed: false,
              reason: 'needs_individual',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _shoot(tester, 'v1_06_my_plans_payer', size: tall);
  }, skip: !_enabled);

  testWidgets('My plans: Individual subscriber on a trial, covered member', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const AlrtPlusManageScreen(),
        await _service(),
        _access(
          personal: PersonalAccess(
            plan: PersonalPlan.individual,
            reason: 'trial',
            isTrial: true,
            expiresAt: DateTime(2026, 10, 28),
            willRenew: true,
            extraSavedPlaces: null,
            askPerDay: 10,
          ),
          groups: [
            _group(
              'g3',
              'Club Committee',
              role: 'adult',
              people: 17,
              sponsorship: const GroupSponsorship(
                tier: PlanTier.group20,
                live: true,
                status: 'active',
                expiresAt: null,
                coveredBy: 'Priya',
                youPay: false,
              ),
              reason: 'sponsored',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _shoot(tester, 'v1_07_my_plans_individual', size: tall);
  }, skip: !_enabled);

  testWidgets('saved-place upsell sheet', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox.shrink();
            },
          ),
        ),
        await _service(),
        _access(),
      ),
    );
    showAlrtPlusUpsellSheet(
      context: ctx,
      icon: AlrtPlusUpsellIcons.savedLocation,
      title: 'One saved place on ALRT Free',
      message:
          'ALRT Free includes 1 saved place as well as where you are. '
          'ALRT + Individual gives you unlimited saved places. Family and '
          "Group plans don't change this.",
      primaryLabel: 'See ALRT + Individual',
      onPrimary: (_) async => false,
    );
    await tester.pumpAndSettle();
    await _shoot(tester, 'v1_08_upsell_saved_place');
  }, skip: !_enabled);

  testWidgets('upgrade Family -> Group 20 (Android)', (tester) async {
    await tester.pumpWidget(
      _app(
        const AlrtPlusGroupPaywallScreen(
          isAndroidOverride: true,
          args: AlrtPlusGroupPaywallArgs(circleId: 'g1', tier: PlanTier.group20),
        ),
        await _service(),
        _access(
          groups: [
            _group(
              'g1',
              'Netball Mums',
              people: 6,
              sponsorship: const GroupSponsorship(
                tier: PlanTier.family,
                live: true,
                status: 'active',
                expiresAt: null,
                coveredBy: 'Sarah',
                youPay: true,
                productId: 'alrt_family_monthly',
              ),
              reason: 'sponsored',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _shoot(tester, 'v1_09_upgrade_group20', size: const Size(390, 1500));
  }, skip: !_enabled);

  testWidgets('onboarding ALRT + step', (tester) async {
    await tester.pumpWidget(
      _app(OnboardingAlrtPlusScreen(onDone: () {}), await _service(), _access()),
    );
    await tester.pumpAndSettle();
    await _shoot(tester, 'v1_10_onboarding_alrt_plus');
  }, skip: !_enabled);

  for (final (name, code, details, group) in [
    (
      'v1_11_refusal_plan_ended',
      'GROUP_PLAN_ENDED',
      <String, dynamic>{'circleId': 'g1'},
      _group('g1', 'Club Committee', role: 'adult', people: 17,
          sponsorship: const GroupSponsorship(
            tier: PlanTier.group20,
            live: false,
            status: 'expired',
            expiresAt: null,
            coveredBy: 'Priya',
            youPay: false,
          ),
          allowed: false,
          reason: 'sponsorship_paused'),
    ),
    (
      'v1_12_refusal_alrt_plus_needed',
      'INDIVIDUAL_REQUIRED',
      <String, dynamic>{'circleId': 'g1'},
      _group('g1', 'Weekend Crew', role: 'owner', people: 5,
          allowed: false, reason: 'needs_individual'),
    ),
    (
      'v1_13_refusal_group_full',
      'GROUP_FULL',
      <String, dynamic>{'circleId': 'g1', 'capacity': 6, 'sponsored': true},
      _group('g1', 'Nixon Family', people: 6,
          sponsorship: const GroupSponsorship(
            tier: PlanTier.family,
            live: true,
            status: 'active',
            expiresAt: null,
            coveredBy: 'Sarah',
            youPay: true,
          ),
          reason: 'sponsored'),
    ),
  ]) {
    testWidgets(name, (tester) async {
      late WidgetRef ref;
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Consumer(
              builder: (c, r, _) {
                ref = r;
                ctx = c;
                return const SizedBox.shrink();
              },
            ),
          ),
          await _service(),
          _access(groups: [group]),
        ),
      );
      await tester.pumpAndSettle();
      final refusal = AccessRefusal.fromError(
        AppError(
          message: 'server wording',
          extraData: {'code': code, 'details': details},
        ),
      )!;
      showAccessRefusalSheet(ctx, ref, refusal);
      await tester.pumpAndSettle();
      await _shoot(tester, name);
    }, skip: !_enabled);
  }
}
