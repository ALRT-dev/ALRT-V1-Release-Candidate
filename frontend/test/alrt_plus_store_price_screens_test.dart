import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:hazard_app/features/subscription/utils/trial_copy.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_choose_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_group_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_manage_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'support/fake_store_gateway.dart';

/// V1 purchase screens (master spec 28 Sep 2026, §6, §8, §9): exact
/// wording, store prices only, a trial only for an eligible Individual
/// account, and "Continue with ALRT Free", Restore, Terms and Privacy
/// always reachable. A fake store answers like Google Play for an
/// Australian account (AUD formatted with a bare "$").

Future<RevenueCatService> _service({
  bool trial = false,
  IntroEligibilityStatus eligibility =
      IntroEligibilityStatus.introEligibilityStatusEligible,
}) async {
  final service = RevenueCatService(
    gateway: FakeStoreGateway(trial: trial, eligibility: eligibility),
    apiKeyOverride: 'test-key',
  );
  await service.ensureConfigured('u-test');
  return service;
}

GroupAccess _group({
  String id = 'g1',
  String name = 'Nixon Family',
  String role = 'owner',
  int people = 3,
  GroupSponsorship? sponsorship,
  GroupFundingMode mode = GroupFundingMode.individual,
}) => GroupAccess(
  circleId: id,
  name: name,
  role: role,
  fundingMode: mode,
  peopleCount: people,
  capacity: sponsorship == null ? null : sponsoredCapacity(sponsorship.tier),
  sponsorship: sponsorship,
  connectionAllowed: true,
  connectionReason: 'individual',
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

Widget _app(
  Widget home,
  RevenueCatService service, {
  AccessSummary? access,
}) => ProviderScope(
  overrides: [
    providerOfRevenueCat.overrideWithValue(service),
    providerOfAccess.overrideWith((ref) async => access ?? _access()),
    providerOfAlrtPlus.overrideWith(
      (ref) async => access?.personal.isIndividual ?? false,
    ),
    providerOfAlrtPlusBillingIssue.overrideWith((ref) async => false),
    providerOfExpiredAlrtPlus.overrideWith((ref) async => null),
  ],
  child: ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => MaterialApp(theme: AppTheme.lightPalette, home: home),
  ),
);

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    // A narrow phone, tall enough that every row builds without scrolling.
    view.physicalSize = const Size(1080, 7500);
    view.devicePixelRatio = 3.0;
  });
  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  group('Individual paywall', () {
    testWidgets('eligible Android account: exact copy, store price, trial CTA '
        'and disclosure', (tester) async {
      final service = await _service(trial: true);
      await tester.pumpWidget(
        _app(const AlrtPlusPaywallScreen(isAndroidOverride: true), service),
      );
      await tester.pumpAndSettle();

      expect(find.text(kIndividualHeading), findsOneWidget);
      expect(find.text(kIndividualIntro), findsOneWidget);
      for (final b in kIndividualBenefits) {
        expect(find.text(b), findsOneWidget);
      }
      expect(find.text(kIndividualUnlimitedGroupsLine), findsOneWidget);
      expect(find.text(kIndividualScope), findsOneWidget);
      expect(find.text(r'$5.99 AUD/month'), findsOneWidget);
      expect(find.text('Start 1 month free'), findsOneWidget);
      expect(
        find.text(
          r'Eligible subscribers only. $0.00 today, then $5.99 AUD/month '
          'after 1 month. Renews automatically unless cancelled. Manage or '
          'cancel in your Google Play account.',
        ),
        findsOneWidget,
      );
      expect(find.text(kContinueFree), findsOneWidget);
      expect(find.text('Restore purchases'), findsOneWidget);
      expect(find.text('Terms'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
    });

    testWidgets('iPhone account the store says is ineligible: no trial '
        'wording anywhere', (tester) async {
      final service = await _service(
        trial: true,
        eligibility: IntroEligibilityStatus.introEligibilityStatusIneligible,
      );
      await tester.pumpWidget(
        _app(const AlrtPlusPaywallScreen(isAndroidOverride: false), service),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'Subscribe for $5.99 AUD/month'), findsOneWidget);
      expect(find.textContaining('month free'), findsNothing);
      expect(find.textContaining('free trial'), findsNothing);
      expect(find.textContaining('Eligible subscribers'), findsNothing);
      expect(
        find.textContaining('Manage or cancel in your App Store account.'),
        findsOneWidget,
      );
    });

    testWidgets('unknown iPhone eligibility never claims a trial', (
      tester,
    ) async {
      final service = await _service(
        trial: true,
        eligibility: IntroEligibilityStatus.introEligibilityStatusUnknown,
      );
      await tester.pumpWidget(
        _app(const AlrtPlusPaywallScreen(isAndroidOverride: false), service),
      );
      await tester.pumpAndSettle();
      expect(find.text('Start 1 month free'), findsNothing);
      expect(find.text(r'Subscribe for $5.99 AUD/month'), findsOneWidget);
    });

    testWidgets('the saved-place reason says what Free includes', (
      tester,
    ) async {
      final service = await _service();
      await tester.pumpWidget(
        _app(
          const AlrtPlusPaywallScreen(
            isAndroidOverride: true,
            args: AlrtPlusPaywallArgs(
              reason: AlrtPlusPaywallReason.savedLocation,
            ),
          ),
          service,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'ALRT Free includes one saved place as well as where you are.',
        ),
        findsOneWidget,
      );
    });
  });

  group('Cover a group', () {
    testWidgets('lists hosted groups, three plans with store prices, no '
        'trial, and scope for the chosen group', (tester) async {
      final service = await _service();
      await tester.pumpWidget(
        _app(
          const AlrtPlusGroupPaywallScreen(isAndroidOverride: true),
          service,
          access: _access(
            groups: [
              _group(),
              _group(id: 'g2', name: 'Weekend Crew', role: 'adult'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(kGroupHeading), findsOneWidget);
      expect(find.text(kGroupExplanation), findsOneWidget);
      expect(find.text('GROUP YOU WILL COVER'), findsOneWidget);
      expect(find.text('PLAN SIZE'), findsOneWidget);
      expect(find.text('Nixon Family'), findsOneWidget);
      // Only groups you host can be covered.
      expect(find.text('Weekend Crew'), findsNothing);
      // The hero badge names the selected plan.
      expect(find.text('ALRT + Family'), findsOneWidget);
      // Three equal size tiles, each with its capacity and store price.
      expect(find.text('Family'), findsOneWidget);
      expect(find.text('Group 20'), findsOneWidget);
      expect(find.text('Group 50'), findsOneWidget);
      expect(find.text('up to 6'), findsOneWidget);
      expect(find.text('up to 20'), findsOneWidget);
      expect(find.text('up to 50'), findsOneWidget);
      expect(find.text(r'$15.99 AUD/month'), findsOneWidget);
      expect(find.text(r'$24.99 AUD/month'), findsOneWidget);
      expect(find.text(r'$49.99 AUD/month'), findsOneWidget);
      expect(find.text(r'Subscribe for $15.99 AUD/month'), findsOneWidget);
      expect(
        find.text(groupScope(capacity: 6, group: 'Nixon Family')),
        findsOneWidget,
      );
      expect(
        find.text(
          r'$15.99 AUD charged on confirmation. No free trial. Renews '
          'monthly unless cancelled. Manage or cancel in your Google Play '
          'account.',
        ),
        findsOneWidget,
      );
      expect(find.text(kSosSafetyStatement), findsOneWidget);
      expect(find.text(kContinueFree), findsOneWidget);

      await tester.tap(find.text('Group 20'));
      await tester.pumpAndSettle();
      expect(find.text('ALRT + Group 20'), findsOneWidget);
      expect(find.text(r'Subscribe for $24.99 AUD/month'), findsOneWidget);
      expect(
        find.text(groupScope(capacity: 20, group: 'Nixon Family')),
        findsOneWidget,
      );
    });

    testWidgets('a plan smaller than the group is marked too small', (
      tester,
    ) async {
      final service = await _service();
      await tester.pumpWidget(
        _app(
          const AlrtPlusGroupPaywallScreen(isAndroidOverride: true),
          service,
          access: _access(groups: [_group(people: 7)]),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Too small for this group'), findsOneWidget);
      // The tile still says its size; only the state line explains.
      expect(find.text('up to 6'), findsOneWidget);
    });

    testWidgets('someone who hosts no group is told to create one first', (
      tester,
    ) async {
      final service = await _service();
      await tester.pumpWidget(
        _app(
          const AlrtPlusGroupPaywallScreen(isAndroidOverride: true),
          service,
          access: _access(groups: [_group(role: 'adult')]),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('You need to host a group before you can cover'),
        findsOneWidget,
      );
    });
  });

  group('My plans', () {
    testWidgets('a Family payer without Individual is personally on ALRT '
        'Free, and sees the group they cover', (tester) async {
      final service = await _service();
      await tester.pumpWidget(
        _app(
          const AlrtPlusManageScreen(),
          service,
          access: _access(
            groups: [
              _group(
                mode: GroupFundingMode.sponsored,
                sponsorship: const GroupSponsorship(
                  tier: PlanTier.family,
                  live: true,
                  status: 'active',
                  expiresAt: null,
                  coveredBy: 'Sarah',
                  youPay: true,
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('PERSONAL PLAN'), findsOneWidget);
      expect(find.text('GROUP COVERAGE'), findsOneWidget);
      expect(find.text('ALRT Free'), findsOneWidget);
      expect(find.text('ALRT + Family'), findsOneWidget);
      expect(
        find.text('Covered by ALRT + Family · 3 of 6 people'),
        findsOneWidget,
      );
      expect(find.textContaining('Paid by you.'), findsOneWidget);
      expect(find.text('Upgrade to ALRT + Group 20'), findsOneWidget);
      expect(find.textContaining('seat'), findsNothing);
      // Restore is an outlined button at the bottom, never a bare link.
      expect(
        find.widgetWithText(OutlinedButton, 'Restore purchases'),
        findsOneWidget,
      );
    });

    testWidgets('a covered member sees who covers the group, never that '
        'they own a plan', (tester) async {
      final service = await _service();
      await tester.pumpWidget(
        _app(
          const AlrtPlusManageScreen(),
          service,
          access: _access(
            groups: [
              _group(
                role: 'adult',
                mode: GroupFundingMode.sponsored,
                sponsorship: const GroupSponsorship(
                  tier: PlanTier.group20,
                  live: true,
                  status: 'active',
                  expiresAt: null,
                  coveredBy: 'Sarah',
                  youPay: false,
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ALRT Free'), findsOneWidget);
      expect(
        find.text('Covered by ALRT + Group 20 · 3 of 20 people'),
        findsOneWidget,
      );
      expect(find.textContaining('Paid by Sarah.'), findsOneWidget);
      // Only the payer can upgrade.
      expect(find.textContaining('Upgrade to'), findsNothing);
    });
  });

  group('My plans: Cover button', () {
    testWidgets('a hosted group with no plan offers an outlined Cover '
        'button; a member sees none', (tester) async {
      final service = await _service();
      await tester.pumpWidget(
        _app(
          const AlrtPlusManageScreen(),
          service,
          access: _access(
            groups: [
              _group(),
              _group(id: 'g2', name: 'Weekend Crew', role: 'adult'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(OutlinedButton, 'Cover'), findsOneWidget);
      expect(find.text('No group plan'), findsNWidgets(2));
    });
  });

  group('Choose screen', () {
    testWidgets('each card carries the store\'s price line: personal with '
        'the trial, group from the cheapest plan', (tester) async {
      final service = await _service(trial: true);
      await tester.pumpWidget(
        _app(const AlrtPlusChooseScreen(isAndroidOverride: true), service),
      );
      await tester.pumpAndSettle();

      expect(find.text(kChooseHeading), findsOneWidget);
      expect(find.text('ALRT +'), findsOneWidget);
      expect(find.text('ALRT + Family · Group'), findsOneWidget);
      expect(
        find.text(r'$5.99 AUD a month · 1-month free trial'),
        findsOneWidget,
      );
      expect(find.text(r'from $15.99 AUD a month'), findsOneWidget);
      expect(find.text(kContinueFree), findsOneWidget);
    });

    testWidgets('an account the store says is ineligible gets the price '
        'without a trial', (tester) async {
      final service = await _service(
        trial: true,
        eligibility: IntroEligibilityStatus.introEligibilityStatusIneligible,
      );
      await tester.pumpWidget(
        _app(const AlrtPlusChooseScreen(isAndroidOverride: false), service),
      );
      await tester.pumpAndSettle();
      expect(find.text(r'$5.99 AUD a month'), findsOneWidget);
      expect(find.textContaining('free trial'), findsNothing);
    });

    testWidgets('a build without a billing key shows no price at all', (
      tester,
    ) async {
      final service = RevenueCatService(
        gateway: FakeStoreGateway(),
        apiKeyOverride: '',
      );
      await tester.pumpWidget(
        _app(const AlrtPlusChooseScreen(isAndroidOverride: true), service),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining(r'$'), findsNothing);
      expect(find.textContaining('a month'), findsNothing);
      expect(find.text(kChooseForMyselfTitle), findsOneWidget);
      expect(find.text(kChooseCoverGroupTitle), findsOneWidget);
    });
  });

  group('Price line helpers', () {
    test('personalPriceLine joins price and trial, or is null with no package',
        () {
      expect(personalPriceLine(package: null, trial: null), isNull);
      final offering = FakeStoreGateway(trial: true).personalOffering();
      final package = offering.monthly!;
      expect(
        personalPriceLine(package: package, trial: null),
        r'$5.99 AUD a month',
      );
      expect(
        personalPriceLine(
          package: package,
          trial: const TrialOffer(1, PeriodUnit.month),
        ),
        r'$5.99 AUD a month · 1-month free trial',
      );
    });

    test('groupPriceLine names the cheapest group plan', () {
      expect(groupPriceLine(null), isNull);
      expect(
        groupPriceLine(FakeStoreGateway.groupsOffering),
        r'from $15.99 AUD a month',
      );
    });
  });
}
