import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/subscription/utils/store_price.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Prices are the store's own words: amount and currency from the
/// product, never formatted, chosen or converted by the app. The ISO code
/// is added only when the store's string is ambiguous (a bare "$").
StoreProduct product({
  String price = r'$9.99',
  String currency = 'AUD',
  String? period,
  String id = 'alrt_plus_monthly',
}) => StoreProduct(
  id,
  'ALRT+',
  'ALRT+',
  9.99,
  price,
  currency,
  subscriptionPeriod: period,
);

void main() {
  group('storePriceLabel', () {
    test('a bare "\$" gets the ISO code: Play formats AUD that way', () {
      expect(storePriceLabel(product()), r'$9.99 AUD');
      expect(storeCurrencySuffix(product()), 'AUD');
    });

    test('USD with a bare "\$" is labelled USD, never assumed to be local', () {
      expect(storePriceLabel(product(currency: 'USD')), r'$9.99 USD');
    });

    test('an amount that already names its currency is left alone', () {
      expect(storePriceLabel(product(price: r'A$9.99')), r'A$9.99');
      expect(
        storePriceLabel(product(price: r'US$9.99', currency: 'USD')),
        r'US$9.99',
      );
      expect(storePriceLabel(product(price: 'AUD 9.99')), 'AUD 9.99');
      expect(storeCurrencySuffix(product(price: r'A$9.99')), isNull);
    });

    test('other bare symbols get their code too', () {
      expect(
        storePriceLabel(product(price: '9,99 €', currency: 'EUR')),
        '9,99 € EUR',
      );
    });

    test('never invents an amount when the store gives none', () {
      expect(storePriceLabel(product(price: '', currency: 'AUD')), 'AUD');
      expect(storePriceLabel(product(price: r'$9.99', currency: '')), r'$9.99');
    });
  });

  group('billing period', () {
    test('comes from the store period first', () {
      expect(
        billingPeriodNoun(product(period: 'P1M'), PackageType.annual),
        'month',
      );
      expect(billingPeriodNoun(product(period: 'P1Y')), 'year');
      expect(billingPeriodNoun(product(period: 'P1W')), 'week');
      expect(billingPeriodNoun(product(period: 'P3M')), '3 months');
    });

    test('falls back to the package type, then to nothing', () {
      expect(billingPeriodNoun(product(), PackageType.monthly), 'month');
      expect(billingPeriodNoun(product(), PackageType.annual), 'year');
      expect(billingPeriodNoun(product(), PackageType.lifetime), isNull);
      expect(perPeriodLabel(product(), PackageType.lifetime), '');
    });

    test('phrases read as the store priced them', () {
      expect(
        pricePerPeriodPhrase(product(period: 'P1M')),
        r'$9.99 AUD a month',
      );
      expect(
        pricePerPeriodPhrase(product(price: r'$99.99', period: 'P1Y')),
        r'$99.99 AUD a year',
      );
      expect(
        pricePerPeriodPhrase(product(period: 'P3M')),
        r'$9.99 AUD every 3 months',
      );
      expect(perPeriodLabel(product(period: 'P1Y')), 'per year');
    });
  });
}
