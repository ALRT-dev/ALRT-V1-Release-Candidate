import 'package:purchases_flutter/purchases_flutter.dart';

/// Store-provided price wording, used by every screen that names a price:
/// the paywall's plan cards, the line under the purchase button and the
/// subscription summary on the manage screen.
///
/// Rules (product decision 2026-09-09):
/// - The amount is always the store's own formatted string
///   ([StoreProduct.priceString]) in the store's own currency
///   ([StoreProduct.currencyCode]). ALRT never formats an amount, picks a
///   currency for a country, or converts between currencies.
/// - The ISO currency code is shown beside the amount whenever the store's
///   string carries no letters, because several dollar currencies are
///   formatted with a bare "$": Google Play renders AUD as "$9.99" on an
///   en-AU phone, which looks exactly like USD. "A$9.99" or "US$9.99"
///   already say which currency they are and are left alone.
/// - The billing period comes from the store's ISO-8601 period (P1M, P1Y,
///   P1W, P3M) when it is present, else from the package type.
String storePriceLabel(final StoreProduct product) {
  final price = product.priceString.trim();
  final code = product.currencyCode.trim().toUpperCase();
  if (price.isEmpty) return code; // never invent an amount
  if (code.isEmpty) return price;
  if (price.toUpperCase().contains(code)) return price;
  if (RegExp('[A-Za-z]').hasMatch(price)) return price;
  return '$price $code';
}

/// The ISO code to print beside the store's amount, or null when the
/// amount already names its currency (see [storePriceLabel]).
String? storeCurrencySuffix(final StoreProduct product) {
  final price = product.priceString.trim();
  final code = product.currencyCode.trim().toUpperCase();
  if (price.isEmpty || code.isEmpty) return null;
  if (price.toUpperCase().contains(code)) return null;
  if (RegExp('[A-Za-z]').hasMatch(price)) return null;
  return code;
}

/// "month", "year", "week", "3 months" … from the store's period, else
/// from [type]; null when neither says.
String? billingPeriodNoun(
  final StoreProduct product, [
  final PackageType? type,
]) {
  final raw = product.subscriptionPeriod?.trim().toUpperCase();
  if (raw != null && raw.isNotEmpty) {
    final match = RegExp(r'^P(\d+)([DWMY])$').firstMatch(raw);
    if (match != null) {
      final count = int.parse(match.group(1)!);
      final unit = switch (match.group(2)) {
        'D' => 'day',
        'W' => 'week',
        'M' => 'month',
        _ => 'year',
      };
      if (count == 1) return unit;
      if (count > 1) return '$count ${unit}s';
    }
  }
  return switch (type) {
    PackageType.monthly => 'month',
    PackageType.annual => 'year',
    PackageType.weekly => 'week',
    PackageType.twoMonth => '2 months',
    PackageType.threeMonth => '3 months',
    PackageType.sixMonth => '6 months',
    _ => null,
  };
}

/// "per month" / "per year" / "per 3 months"; empty when the period is
/// unknown (a lifetime or custom product), so nothing is asserted.
String perPeriodLabel(final StoreProduct product, [final PackageType? type]) {
  final noun = billingPeriodNoun(product, type);
  return noun == null ? '' : 'per $noun';
}

/// "$9.99 AUD a month" / "$99.99 AUD a year" / "$9.99 AUD every 3 months".
String pricePerPeriodPhrase(
  final StoreProduct product, [
  final PackageType? type,
]) {
  final noun = billingPeriodNoun(product, type);
  final price = storePriceLabel(product);
  if (noun == null) return price;
  if (noun.startsWith(RegExp(r'\d'))) return '$price every $noun';
  return '$price a $noun';
}
