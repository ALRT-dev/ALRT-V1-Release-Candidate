import 'package:purchases_flutter/purchases_flutter.dart';

/// The confirmed commercial offer's trial length, used only where no real
/// store product is available to read from (the TEST/QA dummy paywall
/// preview, where there is no [StoreProduct] at all). Never used to
/// override what a real product actually says.
const kConfiguredFreeTrialPhrase = '14-day free trial';

/// A free-trial phrase built from [product]'s own introductory-offer data,
/// e.g. "14-day free trial" — never assumed, never hardcoded against a real
/// product. Returns null when the store has not configured a free (price
/// zero) introductory offer for this product, so callers never claim a
/// trial that RevenueCat/the store says does not exist.
String? freeTrialPhrase(final StoreProduct product) {
  final intro = product.introductoryPrice;
  if (intro == null || intro.price != 0) return null;
  final n = intro.periodNumberOfUnits;
  if (n <= 0) return null;
  final unit = _unitWord(intro.periodUnit);
  if (unit == null) return null;
  // Compound-adjective form ("14-day", "1-month") is always singular,
  // regardless of n.
  return '$n-$unit free trial';
}

String? _unitWord(final PeriodUnit unit) {
  switch (unit) {
    case PeriodUnit.day:
      return 'day';
    case PeriodUnit.week:
      return 'week';
    case PeriodUnit.month:
      return 'month';
    case PeriodUnit.year:
      return 'year';
    case PeriodUnit.unknown:
      return null;
  }
}
