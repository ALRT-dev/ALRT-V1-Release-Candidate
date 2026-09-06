import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/subscription/utils/trial_copy.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// freeTrialPhrase must only ever describe a trial that RevenueCat/the store
// actually configured on the purchased product - never a hardcoded "1
// month free" claim. These pin the mapping from real StoreProduct data to
// customer-facing copy, including the "no trial configured" case.
StoreProduct productWith({final IntroductoryPrice? introductoryPrice}) =>
    StoreProduct(
      'alrt_plus_monthly',
      'ALRT+ Monthly',
      'ALRT+ Monthly',
      9.99,
      r'$9.99',
      'AUD',
      introductoryPrice: introductoryPrice,
    );

void main() {
  group('freeTrialPhrase', () {
    test('is null when the store has no introductory price at all', () {
      expect(freeTrialPhrase(productWith()), isNull);
    });

    test('is null when the "introductory" price is not actually free', () {
      final product = productWith(
        introductoryPrice: const IntroductoryPrice(
          4.99,
          r'$4.99',
          'P1M',
          1,
          PeriodUnit.month,
          1,
        ),
      );
      expect(freeTrialPhrase(product), isNull);
    });

    test('reads the real configured length: 14 days', () {
      final product = productWith(
        introductoryPrice: const IntroductoryPrice(
          0,
          r'$0.00',
          'P14D',
          1,
          PeriodUnit.day,
          14,
        ),
      );
      expect(freeTrialPhrase(product), '14-day free trial');
    });

    test('reads a different configured length faithfully: 1 month', () {
      final product = productWith(
        introductoryPrice: const IntroductoryPrice(
          0,
          r'$0.00',
          'P1M',
          1,
          PeriodUnit.month,
          1,
        ),
      );
      expect(freeTrialPhrase(product), '1-month free trial');
    });

    test('is null when the store reports an unknown period unit', () {
      final product = productWith(
        introductoryPrice: const IntroductoryPrice(
          0,
          r'$0.00',
          'P14D',
          1,
          PeriodUnit.unknown,
          14,
        ),
      );
      expect(freeTrialPhrase(product), isNull);
    });

    test('is null for a non-positive period count', () {
      final product = productWith(
        introductoryPrice: const IntroductoryPrice(
          0,
          r'$0.00',
          'P0D',
          1,
          PeriodUnit.day,
          0,
        ),
      );
      expect(freeTrialPhrase(product), isNull);
    });
  });

  test('the dummy/TEST-unlock phrase matches the confirmed commercial offer', () {
    expect(kConfiguredFreeTrialPhrase, '14-day free trial');
  });
}
