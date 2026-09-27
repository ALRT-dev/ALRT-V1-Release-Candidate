import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/subscription/utils/expiry.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// expiredEntitlementOf must tell "was on ALRT+, now expired" apart from
// "has never subscribed" using only RevenueCat's own entitlements.all vs
// entitlements.active - no backend change. Getting this wrong either
// sends a first-time visitor to a "welcome back" screen, or sends a truly
// lapsed customer to the plain paywall with no explanation.
const entitlementId = 'plus';

EntitlementInfo entitlement({required final bool isActive}) => EntitlementInfo(
  entitlementId,
  isActive,
  false,
  '2026-01-01T00:00:00Z',
  '2026-01-01T00:00:00Z',
  'alrt_plus_monthly',
  false,
  ownershipType: OwnershipType.purchased,
  store: Store.playStore,
  periodType: PeriodType.normal,
);

CustomerInfo customerInfoWith(final EntitlementInfos entitlements) =>
    CustomerInfo(
      entitlements,
      const {},
      const [],
      const [],
      const [],
      '2026-01-01T00:00:00Z',
      'user-1',
      const {},
      '2026-01-01T00:00:00Z',
    );

void main() {
  group('expiredEntitlementOf', () {
    test('is null when there is no customer info at all', () {
      expect(expiredEntitlementOf(null, entitlementId), isNull);
    });

    test('is null for someone who has never subscribed', () {
      final info = customerInfoWith(const EntitlementInfos({}, {}));
      expect(expiredEntitlementOf(info, entitlementId), isNull);
    });

    test('is null while the entitlement is currently active', () {
      final active = entitlement(isActive: true);
      final info = customerInfoWith(
        EntitlementInfos({entitlementId: active}, {entitlementId: active}),
      );
      expect(expiredEntitlementOf(info, entitlementId), isNull);
    });

    test('returns the entitlement once it has genuinely lapsed', () {
      final lapsed = entitlement(isActive: false);
      final info = customerInfoWith(
        EntitlementInfos({entitlementId: lapsed}, const {}),
      );
      expect(expiredEntitlementOf(info, entitlementId), lapsed);
    });
  });
}
