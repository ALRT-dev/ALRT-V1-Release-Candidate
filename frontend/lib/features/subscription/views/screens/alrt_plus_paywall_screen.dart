import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/subscription/utils/store_price.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/utils/purchase_error_message.dart';
import 'package:hazard_app/features/subscription/utils/alrt_plus_limits.dart';
import 'package:hazard_app/features/subscription/utils/trial_copy.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_welcome_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_benefits.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_style.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';

/// Why the paywall opened; the headline speaks to that moment.
enum AlrtPlusPaywallReason { hostCircle, savedLocation, general }

class AlrtPlusPaywallArgs {
  const AlrtPlusPaywallArgs({this.reason = AlrtPlusPaywallReason.general});
  final AlrtPlusPaywallReason reason;
}

/// The ALRT+ gate sheet. Per the product rules this appears only at a
/// premium moment (hosting a family circle, a second saved location), never
/// during onboarding, and always renders store prices, never hardcoded
/// ones. Pops `true` if the user ends up entitled to ALRT+.
class AlrtPlusPaywallScreen extends ConsumerStatefulWidget {
  const AlrtPlusPaywallScreen({super.key, this.args});

  static const route = '/alrt-plus';

  final AlrtPlusPaywallArgs? args;

  @override
  ConsumerState<AlrtPlusPaywallScreen> createState() =>
      _AlrtPlusPaywallScreenState();
}

class _AlrtPlusPaywallScreenState extends ConsumerState<AlrtPlusPaywallScreen> {
  Offering? _offering;
  Package? _selected;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  /// QA builds without store keys show dummy plan cards so the whole
  /// gate -> purchase -> welcome flow can be walked. Never true in store
  /// builds (driven by ALRT_PLUS_TEST_UNLOCK, which CI sets only for the
  /// sideloaded dev flavour).
  bool _dummy = false;

  /// The full Free-versus-ALRT+ table, shown on request.
  bool _showComparison = false;
  bool _dummyYearlySelected = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Test-build escape hatch: never contact RevenueCat under test-unlock -
    // go straight to the dummy plan cards instead of calling the real SDK.
    if (isAlrtPlusTestUnlocked) {
      setState(() {
        _offering = null;
        _selected = null;
        _dummy = true;
        _loading = false;
        _error = null;
      });
      return;
    }
    final rc = ref.read(providerOfRevenueCat);
    if (!rc.hasKeys) {
      setState(() {
        _offering = null;
        _selected = null;
        _dummy = false;
        _loading = false;
        _error =
            'This build has no billing key, so ALRT+ cannot be bought here.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final offering = await rc.currentOffering();
    if (!mounted) return;
    final packages = offering?.availablePackages ?? const <Package>[];
    setState(() {
      _offering = offering;
      _selected = offering?.annual ?? packages.firstOrNull;
      _dummy = false;
      _loading = false;
      if (offering == null) {
        _error =
            'ALRT+ plans could not be loaded. Check your connection and '
            'tap Try again.';
      } else if (packages.isEmpty) {
        _error = 'ALRT+ has no plans in the store yet.';
      } else {
        _error = null;
      }
    });
  }

  /// The trial phrase to show, built from the real selected product's own
  /// introductory-offer data — never assumed. Null means the store hasn't
  /// configured a free trial for this product, so nothing claims one. The
  /// dummy/QA path has no real product to read, so it shows the confirmed
  /// commercial offer's trial length as a preview of the intended real one.
  String? get _trialPhrase {
    if (_dummy) return kConfiguredFreeTrialPhrase;
    final selected = _selected;
    return selected == null ? null : freeTrialPhrase(selected.storeProduct);
  }

  Future<void> _finishEntitled() async {
    ref.invalidate(providerOfAlrtPlus);
    ref.invalidate(providerOfExpiredAlrtPlus);
    ref.invalidate(providerOfAlrtPlusBillingIssue);
    if (!mounted) return;
    // The welcome moment is for new hosts; a plan change from an existing
    // circle skips straight back.
    final hasCircle = ref.read(providerOfFamily).circle != null;
    if (!hasCircle) {
      await context.push(
        AlrtPlusWelcomeScreen.route,
        extra: AlrtPlusWelcomeScreenArgs(trialPhrase: _trialPhrase),
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _subscribe() async {
    if (_dummy) {
      if (_busy) return;
      setState(() => _busy = true);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _busy = false);
      await _finishEntitled();
      return;
    }
    final package = _selected;
    if (package == null || _busy) return;
    setState(() => _busy = true);
    try {
      final ok = await ref.read(providerOfRevenueCat).purchase(package);
      if (ok) {
        await _finishEntitled();
      } else if (mounted) {
        setState(
          () => _error =
              'The store did not confirm ALRT+ for this account. '
              'Tap Restore purchases, or try again.',
        );
      }
    } catch (error) {
      final message = purchaseErrorMessage(error);
      if (mounted) setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    // Test-build escape hatch: never contact RevenueCat under test-unlock -
    // there is no real purchase to restore on a dummy plan.
    if (isAlrtPlusTestUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous ALRT + purchase found.')),
      );
      return;
    }
    setState(() => _busy = true);
    final ok = await ref.read(providerOfRevenueCat).restore();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      ref.invalidate(providerOfAlrtPlus);
      ref.invalidate(providerOfExpiredAlrtPlus);
      ref.invalidate(providerOfAlrtPlusBillingIssue);
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous ALRT + purchase found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AlrtPlusStyle.body,
      body: Column(
        children: [
          _bandBuilder(context),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AlrtPlusStyle.magenta,
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      18.spMin,
                      16.spMin,
                      18.spMin,
                      24.spMin,
                    ),
                    children: [
                      // Product decision 2026-09-10: the paywall leads with
                      // the three things ALRT+ adds and one line on what
                      // stays free; the full Free-versus-ALRT+ table is a
                      // tap away rather than the first thing on screen.
                      const AlrtPlusBenefitsSummary(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(
                            () => _showComparison = !_showComparison,
                          ),
                          icon: Icon(
                            _showComparison
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 18.spMin,
                            color: AlrtPlusStyle.magenta,
                          ),
                          label: Text(
                            _showComparison
                                ? 'Hide the comparison'
                                : 'Compare Free and ALRT+',
                            style: TextStyle(
                              fontSize: 12.5.spMin,
                              fontWeight: FontWeight.w700,
                              color: AlrtPlusStyle.magenta,
                            ),
                          ),
                        ),
                      ),
                      if (_showComparison) ...[
                        const AlrtPlusBenefitsTable(
                          title: 'Free versus ALRT+',
                        ),
                        SizedBox(height: 14.spMin),
                      ],
                      SizedBox(height: 4.spMin),
                      if (_offering != null) _planRowBuilder(),
                      if (_dummy) _dummyPlanRowBuilder(),
                      if (_error != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.spMin),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFCC1010),
                              fontSize: 13.spMin,
                            ),
                          ),
                        ),
                      if (_offering == null && !_dummy)
                        TextButton(
                          onPressed: _busy ? null : _load,
                          child: Text(
                            'Try again',
                            style: TextStyle(
                              fontSize: 13.spMin,
                              fontWeight: FontWeight.w700,
                              color: AlrtPlusStyle.magenta,
                            ),
                          ),
                        ),
                      SizedBox(height: 14.spMin),
                      AlrtPlusCta(
                        label: _trialPhrase != null
                            ? 'Start ${_trialPhrase!}'
                            : 'Subscribe now',
                        busy: _busy,
                        onPressed: (_selected == null && !_dummy)
                            ? null
                            : _subscribe,
                      ),
                      SizedBox(height: 9.spMin),
                      _priceLineBuilder(),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text(
                          'Maybe later',
                          style: TextStyle(
                            fontSize: 12.5.spMin,
                            fontWeight: FontWeight.w600,
                            color: AlrtPlusStyle.inkSoft,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _busy ? null : _restore,
                        child: Text(
                          'Restore purchases',
                          style: TextStyle(
                            fontSize: 12.spMin,
                            color: AlrtPlusStyle.inkFaint,
                          ),
                        ),
                      ),
                      Text(
                        _trialPhrase != null
                            ? 'Billed through your app store after your '
                                  'free trial. Cancel anytime in your store '
                                  'account.'
                            : 'Billed through your app store. Cancel '
                                  'anytime in your store account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.spMin,
                          height: 1.6,
                          color: AlrtPlusStyle.inkFaint,
                        ),
                      ),
                      // Apple 3.1.2: terms and privacy must be IN the
                      // purchase flow, not just at sign-up. A Wrap, not a
                      // Row: on a 360 px phone or at large text the two
                      // links overflowed the row.
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => openLink(
                              context: context,
                              link: AppLinks.termsOfUse,
                            ),
                            child: Text(
                              'Terms of Use',
                              style: TextStyle(
                                fontSize: 11.spMin,
                                color: AlrtPlusStyle.inkFaint,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            '·',
                            style: TextStyle(
                              color: AlrtPlusStyle.inkFaint,
                            ),
                          ),
                          TextButton(
                            onPressed: () => openLink(
                              context: context,
                              link: AppLinks.privacyPolicy,
                            ),
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 11.spMin,
                                color: AlrtPlusStyle.inkFaint,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bandBuilder(final BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AlrtPlusStyle.bandGradient),
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 4.spMin,
        left: 10.spMin,
        right: 22.spMin,
        bottom: 22.spMin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            icon: Icon(
              LucideIcons.arrowLeft,
              color: Colors.white,
              size: 22.spMin,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12.spMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AlrtPlusPill(onDark: true),
                SizedBox(height: 12.spMin),
                Text(
                  _headline,
                  style: TextStyle(
                    fontSize: 23.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 7.spMin),
                Text(
                  _subline,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    height: 1.55,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AlrtPlusPaywallReason get _reason =>
      widget.args?.reason ?? AlrtPlusPaywallReason.general;

  String get _headline => switch (_reason) {
    AlrtPlusPaywallReason.savedLocation => 'Save every place that matters',
    AlrtPlusPaywallReason.hostCircle ||
    AlrtPlusPaywallReason.general => 'Let your family stay connected',
  };

  String get _subline => switch (_reason) {
    AlrtPlusPaywallReason.savedLocation =>
      'Free accounts save one location. ALRT+ removes the limit, and '
          'lets you host your own family circle. Joining a circle is '
          'always free.',
    AlrtPlusPaywallReason.hostCircle || AlrtPlusPaywallReason.general =>
      'Host your own family circle with check-ins, saved places and '
          'SOS. Joining a circle is always free.',
  };

  /// The label for a package: the standard monthly/yearly names, or the
  /// store's own name for a custom package, so an offering set up with
  /// other identifiers still renders instead of an empty row.
  static String packageTitle(final Package package) =>
      switch (package.packageType) {
        PackageType.monthly => 'MONTHLY',
        PackageType.annual => 'YEARLY',
        PackageType.weekly => 'WEEKLY',
        PackageType.twoMonth => '2 MONTHS',
        PackageType.threeMonth => '3 MONTHS',
        PackageType.sixMonth => '6 MONTHS',
        PackageType.lifetime => 'LIFETIME',
        PackageType.custom || PackageType.unknown =>
          package.storeProduct.title.isNotEmpty
              ? package.storeProduct.title.toUpperCase()
              : package.identifier.toUpperCase(),
      };

  /// The packages to show, monthly and yearly first when present, then
  /// anything else the offering carries.
  static List<Package> packagesToShow(final Offering offering) {
    final ordered = <Package>[
      ?offering.monthly,
      ?offering.annual,
    ];
    for (final package in offering.availablePackages) {
      if (!ordered.contains(package)) ordered.add(package);
    }
    return ordered;
  }

  Widget _planRowBuilder() {
    final offering = _offering;
    if (offering == null) return const SizedBox.shrink();
    final packages = packagesToShow(offering);
    if (packages.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 10.spMin,
      runSpacing: 10.spMin,
      children: [
        for (final package in packages)
          SizedBox(
            width: packages.length == 1
                ? double.infinity
                : (MediaQuery.sizeOf(context).width - 36.spMin - 10.spMin) / 2,
            child: _planCardBuilder(package, title: packageTitle(package)),
          ),
      ],
    );
  }

  Widget _planCardBuilder(
    final Package package, {
    required final String title,
  }) {
    final selected = _selected == package;
    final product = package.storeProduct;
    return GestureDetector(
      onTap: () => setState(() => _selected = package),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.spMin, horizontal: 10.spMin),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF9F0FC) : Colors.white,
          borderRadius: BorderRadius.circular(18.spMin),
          border: Border.all(
            color: selected ? AlrtPlusStyle.magenta : AlrtPlusStyle.cardLine,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: selected
                    ? AlrtPlusStyle.magenta
                    : AlrtPlusStyle.inkFaint,
              ),
            ),
            SizedBox(height: 5.spMin),
            // The store's own formatted amount, exactly as it gave it.
            Text(
              product.priceString,
              style: TextStyle(
                fontSize: 22.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AlrtPlusStyle.ink,
              ),
            ),
            SizedBox(height: 2.spMin),
            // The ISO currency code when the amount is a bare "$" (Play
            // formats AUD that way), and the store's billing period.
            Text(
              [
                ?storeCurrencySuffix(product),
                perPeriodLabel(product, package.packageType),
              ].where((s) => s.isNotEmpty).join(' · '),
              style: TextStyle(
                fontSize: 11.spMin,
                color: selected ? AlrtPlusStyle.magenta : AlrtPlusStyle.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dummyPlanRowBuilder() {
    Widget card({
      required final String title,
      required final String price,
      required final String per,
      required final bool selected,
      required final VoidCallback onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 14.spMin,
              horizontal: 10.spMin,
            ),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF9F0FC) : Colors.white,
              borderRadius: BorderRadius.circular(18.spMin),
              border: Border.all(
                color: selected
                    ? AlrtPlusStyle.magenta
                    : AlrtPlusStyle.cardLine,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: selected
                        ? AlrtPlusStyle.magenta
                        : AlrtPlusStyle.inkFaint,
                  ),
                ),
                SizedBox(height: 5.spMin),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 22.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AlrtPlusStyle.ink,
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  per,
                  style: TextStyle(
                    fontSize: 11.spMin,
                    color: selected
                        ? AlrtPlusStyle.magenta
                        : AlrtPlusStyle.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            card(
              title: 'MONTHLY',
              price: 'US\$9.99',
              per: 'USD · per month',
              selected: !_dummyYearlySelected,
              onTap: () => setState(() => _dummyYearlySelected = false),
            ),
            SizedBox(width: 10.spMin),
            card(
              title: 'YEARLY',
              price: 'US\$99.99',
              per: 'USD · per year',
              selected: _dummyYearlySelected,
              onTap: () => setState(() => _dummyYearlySelected = true),
            ),
          ],
        ),
        SizedBox(height: 8.spMin),
        Text(
          'Preview prices in USD · billing bypass build only · not store '
          'prices, no real purchase',
          style: TextStyle(
            fontSize: 10.spMin,
            color: AlrtPlusStyle.inkFaint,
          ),
        ),
      ],
    );
  }

  /// Names the selected plan's store price and period (amount, currency
  /// and period all from the store), so the button above and this line
  /// always agree with the highlighted card.
  Widget _priceLineBuilder() {
    final selected = _selected;
    final trial = _trialPhrase;
    final String pricePart;
    if (_dummy) {
      final preview = _dummyYearlySelected
          ? 'US\$99.99 USD a year'
          : 'US\$9.99 USD a month';
      pricePart = trial != null
          ? '$trial, then $preview (preview, not a store price)'
          : '$preview (preview, not a store price)';
    } else if (selected != null) {
      final phrase = pricePerPeriodPhrase(
        selected.storeProduct,
        selected.packageType,
      );
      pricePart = trial != null ? '$trial, then $phrase' : phrase;
    } else {
      pricePart = trial != null
          ? '$trial, then the price shown above'
          : 'Price shown above';
    }
    return Text(
      '$pricePart · $kAlrtPlusSeats seats · cancel anytime',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11.spMin,
        height: 1.5,
        color: AlrtPlusStyle.inkFaint,
      ),
    );
  }
}
