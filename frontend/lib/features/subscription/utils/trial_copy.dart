import 'package:purchases_flutter/purchases_flutter.dart';

/// Preview-only trial length for the QA dummy paywall, where there is no
/// real [StoreProduct] to read. V1 (decided 3 Oct 2026): only Individual
/// has a trial, 2 weeks on both iPhone and Android, subject to store
/// configuration; the earlier 14-day/1-month/30-day values are withdrawn.
/// Never used to override what a real product says.
const kConfiguredFreeTrialPhrase = '2-week free trial';

/// A free-trial phrase built from [product]'s own introductory-offer data,
/// e.g. "2-week free trial" — never assumed, never hardcoded against a real
/// product. Returns null when the store has not configured a free (price
/// zero) introductory offer for this product, so callers never claim a
/// trial that RevenueCat/the store says does not exist.
String? freeTrialPhrase(final StoreProduct product) {
  final offer = freeTrialOffer(product);
  if (offer == null) return null;
  // Compound-adjective form ("2-week", "30-day") is always singular.
  return '${offer.count}-${_unitWord(offer.unit)} free trial';
}

/// The length of a free introductory period, as the store describes it.
class TrialOffer {
  const TrialOffer(this.count, this.unit);

  final int count;
  final PeriodUnit unit;

  /// "2 weeks", "30 days", "1 month": exactly what the store configured.
  /// A store period is never rewritten into another unit.
  String get duration {
    final word = _unitWord(unit)!;
    return count == 1 ? '1 $word' : '$count ${word}s';
  }

  /// Button label: "Start 2 weeks free".
  String get startCta => 'Start $duration free';

  @override
  bool operator ==(Object other) =>
      other is TrialOffer && other.count == count && other.unit == unit;

  @override
  int get hashCode => Object.hash(count, unit);
}

/// The free introductory period [product] carries, from the App Store
/// introductory price or a Google Play free phase; null when there is none.
TrialOffer? freeTrialOffer(final StoreProduct product) {
  final intro = product.introductoryPrice;
  if (intro != null && intro.price == 0) {
    final n = intro.periodNumberOfUnits;
    if (n > 0 && _unitWord(intro.periodUnit) != null) {
      return TrialOffer(n, intro.periodUnit);
    }
  }
  final free = product.defaultOption?.freePhase?.billingPeriod;
  if (free != null && free.value > 0 && _unitWord(free.unit) != null) {
    return TrialOffer(free.value, free.unit);
  }
  return null;
}

/// Whether to offer [product]'s trial to THIS account (master spec §6):
/// - no free intro period configured -> no trial;
/// - iPhone: only when the store says eligible (unknown or ineligible
///   never shows trial wording);
/// - Android: Play only returns offers the account can use, so a free
///   phase on the product is the eligibility signal.
TrialOffer? eligibleTrialOffer({
  required final StoreProduct product,
  required final IntroEligibilityStatus? eligibility,
  required final bool isAndroid,
}) {
  final offer = freeTrialOffer(product);
  if (offer == null) return null;
  if (isAndroid) return offer;
  return eligibility == IntroEligibilityStatus.introEligibilityStatusEligible
      ? offer
      : null;
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
