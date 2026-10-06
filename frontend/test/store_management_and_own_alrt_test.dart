import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:hazard_app/features/subscription/utils/access_refusal.dart';
import 'package:hazard_app/features/subscription/utils/store_management.dart';

import 'support/fake_store_gateway.dart';

/// Manage subscription when RevenueCat has no managementURL, the lapsed
/// group's "Use my own ALRT +", and RevenueCat configured before use.

GroupAccess _group({final String role = 'owner'}) => GroupAccess(
  circleId: 'g1',
  name: 'Nixons',
  role: role,
  fundingMode: GroupFundingMode.sponsored,
  peopleCount: 3,
  capacity: 6,
  connectionAllowed: false,
  connectionReason: 'sponsorship_paused',
  sponsorship: const GroupSponsorship(
    tier: PlanTier.family,
    live: false,
    status: 'expired',
    expiresAt: null,
    coveredBy: 'Sam',
    youPay: false,
  ),
);

AccessRefusal _ended() => AccessRefusal.fromError(
  const AppError(
    message: 'ended',
    extraData: {
      'code': 'GROUP_PLAN_ENDED',
      'details': {'circleId': 'g1'},
    },
  ),
)!;

void main() {
  group('store subscriptions fallback', () {
    test('RevenueCat\'s managementURL wins when it has one', () {
      expect(
        subscriptionManagementUrl(
          managementUrl: 'https://rc/manage',
          isAndroid: true,
          packageName: 'com.safetyalrt.alrt',
        ),
        'https://rc/manage',
      );
    });

    test('iPhone falls back to the App Store subscriptions page', () {
      expect(
        subscriptionManagementUrl(managementUrl: null, isAndroid: false),
        'https://apps.apple.com/account/subscriptions',
      );
    });

    test('Android falls back to Play, on this app', () {
      expect(
        subscriptionManagementUrl(
          managementUrl: '  ',
          isAndroid: true,
          packageName: 'com.safetyalrt.alrt',
        ),
        'https://play.google.com/store/account/subscriptions'
        '?package=com.safetyalrt.alrt',
      );
      expect(
        playSubscriptionsUrl(null),
        'https://play.google.com/store/account/subscriptions',
      );
    });

    test('a build without keys still opens the store page', () async {
      Uri? opened;
      final ok = await openSubscriptionManagement(
        RevenueCatService(apiKeyOverride: ''),
        isAndroidOverride: false,
        launcher: (uri) async {
          opened = uri;
          return true;
        },
      );
      expect(ok, isTrue);
      expect(opened, Uri.parse(kAppleSubscriptionsUrl));
    });
  });

  group('a lapsed sponsored group', () {
    test('a host with their own ALRT + can use it here', () {
      final p = refusalPresentation(
        _ended(),
        group: _group(),
        hasIndividual: true,
      );
      expect(p.primary, RefusalAction.coverGroup);
      expect(p.secondary, RefusalAction.useOwnAlrtPlus);
      expect(p.secondaryLabel, 'Use my own ALRT +');
      expect(p.body, isNot(contains('seat')));
    });

    test('never offered without ALRT +, nor to someone who isn\'t the host '
        '(the backend allows the host only)', () {
      expect(
        refusalPresentation(_ended(), group: _group()).secondary,
        isNull,
      );
      final member = refusalPresentation(
        _ended(),
        group: _group(role: 'adult'),
        hasIndividual: true,
      );
      expect(member.primary, isNull);
      expect(member.secondary, isNull);
    });
  });

  group('RevenueCat is configured before a paywall reads it', () {
    test('ensureConfiguredFor signs in once, and skips no user', () async {
      final gateway = FakeStoreGateway();
      final rc = RevenueCatService(gateway: gateway, apiKeyOverride: 'k');
      await rc.ensureConfiguredFor(null);
      expect(rc.activeUserId, isNull);
      await rc.ensureConfiguredFor('u1');
      await rc.ensureConfiguredFor('u1');
      expect(rc.activeUserId, 'u1');
    });

    test('a bypass build (no keys) is a quiet no-op', () async {
      final rc = RevenueCatService(
        gateway: FakeStoreGateway(),
        apiKeyOverride: '',
      );
      await rc.ensureConfiguredFor('u1');
      expect(rc.activeUserId, isNull);
      expect(rc.hasKeys, isFalse);
    });
  });
}
