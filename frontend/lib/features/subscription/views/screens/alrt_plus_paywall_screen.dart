import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_welcome_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_style.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';

/// The ALRT+ gate sheet. Per the product rules this appears only at the
/// "premium moment" (hosting a family circle), never during onboarding, and
/// always renders store prices — never hardcoded ones. Pops `true` if the user
/// ends up entitled to ALRT+.
class AlrtPlusPaywallScreen extends ConsumerStatefulWidget {
  const AlrtPlusPaywallScreen({super.key});

  static const route = '/alrt-plus';

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
    final offering = await rc.currentOffering();
    if (!mounted) return;
    setState(() {
      _offering = offering;
      _selected = offering?.annual ?? offering?.availablePackages.firstOrNull;
      _dummy = false;
      _loading = false;
      _error = offering == null
          ? 'ALRT + is not available right now. Please try again later.'
          : null;
    });
  }

  Future<void> _finishEntitled() async {
    ref.invalidate(providerOfAlrtPlus);
    if (!mounted) return;
    // The welcome moment is for new hosts; a plan change from an existing
    // circle skips straight back.
    final hasCircle = ref.read(providerOfFamily).circle != null;
    if (!hasCircle) await context.push(AlrtPlusWelcomeScreen.route);
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
      if (ok) await _finishEntitled();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'That purchase could not be completed.');
      }
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
                      const AlrtPlusLavNote(
                        lead: 'You stay in control.',
                        text:
                            'You pay once, everyone else joins free. Core '
                            'safety alerts, the map and emergency guidance '
                            'stay free for everyone, always.',
                      ),
                      SizedBox(height: 14.spMin),
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
                      SizedBox(height: 14.spMin),
                      AlrtPlusCta(
                        label: 'Start free month',
                        busy: _busy,
                        onPressed:
                            (_selected == null && !_dummy) ? null : _subscribe,
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
                        'Billed through your app store after the free month. '
                        'Cancel anytime in your store account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.spMin,
                          height: 1.6,
                          color: AlrtPlusStyle.inkFaint,
                        ),
                      ),
                      // Apple 3.1.2: terms and privacy must be IN the
                      // purchase flow, not just at sign-up.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                  'Let your family stay connected',
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
                  'Host your own family circle with check-ins, saved places '
                  'and SOS. Joining a circle is always free.',
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

  Widget _planRowBuilder() {
    final monthly = _offering?.monthly;
    final annual = _offering?.annual;
    return Row(
      children: [
        if (monthly != null)
          Expanded(child: _planCardBuilder(monthly, title: 'MONTHLY')),
        if (monthly != null && annual != null) SizedBox(width: 10.spMin),
        if (annual != null)
          Expanded(child: _planCardBuilder(annual, title: 'YEARLY')),
      ],
    );
  }

  Widget _planCardBuilder(final Package package, {required final String title}) {
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
            Text(
              package.packageType == PackageType.annual
                  ? 'per year'
                  : 'per month',
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
                color:
                    selected ? AlrtPlusStyle.magenta : AlrtPlusStyle.cardLine,
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
              price: '\$9.99',
              per: 'per month',
              selected: !_dummyYearlySelected,
              onTap: () => setState(() => _dummyYearlySelected = false),
            ),
            SizedBox(width: 10.spMin),
            card(
              title: 'YEARLY',
              price: '\$99.99',
              per: 'per year',
              selected: _dummyYearlySelected,
              onTap: () => setState(() => _dummyYearlySelected = true),
            ),
          ],
        ),
        SizedBox(height: 8.spMin),
        Text(
          'Preview prices · test build only, no real purchase',
          style: TextStyle(
            fontSize: 10.spMin,
            color: AlrtPlusStyle.inkFaint,
          ),
        ),
      ],
    );
  }

  Widget _priceLineBuilder() {
    final monthly =
        _dummy ? '\$9.99' : _offering?.monthly?.storeProduct.priceString;
    final annual =
        _dummy ? '\$99.99' : _offering?.annual?.storeProduct.priceString;
    final pricePart = (monthly != null && annual != null)
        ? '1 month free, then $monthly a month or $annual a year'
        : '1 month free, then the price shown above';
    return Text(
      '$pricePart · 8 seats · cancel anytime',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11.spMin,
        height: 1.5,
        color: AlrtPlusStyle.inkFaint,
      ),
    );
  }
}
