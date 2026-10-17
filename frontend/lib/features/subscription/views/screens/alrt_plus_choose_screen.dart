import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:hazard_app/features/subscription/utils/store_price.dart';
import 'package:hazard_app/features/subscription/utils/trial_copy.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_group_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/paywall_parts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// "A$5.99 a month · 2-week free trial" for the personal card: the
/// store's price and period, plus the trial only when [trial] applies to
/// this account. Null when the store gave no package (nothing is shown).
String? personalPriceLine({
  required final Package? package,
  required final TrialOffer? trial,
}) {
  if (package == null) return null;
  final price = pricePerPeriodPhrase(package.storeProduct, package.packageType);
  final trialPhrase = trial == null ? null : freeTrialPhrase(package.storeProduct);
  return trialPhrase == null ? price : '$price · $trialPhrase';
}

/// "from A$15.99 a month" for the group card: the cheapest of the Family,
/// Group 20 and Group 50 packages in the store's `groups` offering. Null
/// when none of them is there.
String? groupPriceLine(final Offering? offering) {
  if (offering == null) return null;
  Package? cheapest;
  for (final tier in const [PlanTier.family, PlanTier.group20, PlanTier.group50]) {
    final p = packageForTier(offering, tier);
    if (p == null) continue;
    if (cheapest == null || p.storeProduct.price < cheapest.storeProduct.price) {
      cheapest = p;
    }
  }
  if (cheapest == null) return null;
  return 'from ${pricePerPeriodPhrase(cheapest.storeProduct, cheapest.packageType)}';
}

/// The one ALRT + entry (master spec §8, §10): two clearly separate
/// choices, "For myself" (ALRT +) and "Cover a group" (Family, Group 20,
/// Group 50), with ALRT Free always one tap away. Each card carries the
/// store's own price line once the offerings load; a build without a
/// billing key, or a store that can't be reached, shows no price at all.
/// Pops the result of whichever purchase screen was opened.
class AlrtPlusChooseScreen extends ConsumerStatefulWidget {
  const AlrtPlusChooseScreen({super.key, this.isAndroidOverride});

  static const route = '/alrt-plus/choose';

  /// Tests pin the platform; the app reads it from the device.
  final bool? isAndroidOverride;

  @override
  ConsumerState<AlrtPlusChooseScreen> createState() =>
      _AlrtPlusChooseScreenState();
}

class _AlrtPlusChooseScreenState extends ConsumerState<AlrtPlusChooseScreen> {
  String? _personalLine;
  String? _groupLine;

  bool get _isAndroid =>
      widget.isAndroidOverride ?? (!kIsWeb && Platform.isAndroid);

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  /// Reads both offerings the way the paywalls do (signed in as this ALRT
  /// user first, so trial eligibility answers for the right account).
  Future<void> _loadPrices() async {
    if (isAlrtPlusTestUnlocked) return; // preview build: no store prices
    final rc = ref.read(providerOfRevenueCat);
    if (!rc.hasKeys) return;
    await rc.ensureConfiguredFor(ref.read(providerOfLoggedInUser)?.id);
    if (!mounted) return;
    final personal = await rc.offering(RevenueCatService.personalOfferingId);
    final groups = await rc.offering(RevenueCatService.groupsOfferingId);
    final package = personal?.monthly ?? personal?.availablePackages.firstOrNull;

    TrialOffer? trial;
    if (package != null) {
      Map<String, IntroEligibilityStatus> eligibility = const {};
      if (!_isAndroid) {
        eligibility = await rc.introEligibility([
          package.storeProduct.identifier,
        ]);
      }
      final access = await ref.read(providerOfAccess.future);
      if (access?.trialEligible ?? true) {
        trial = eligibleTrialOffer(
          product: package.storeProduct,
          eligibility: eligibility[package.storeProduct.identifier],
          isAndroid: _isAndroid,
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _personalLine = personalPriceLine(package: package, trial: trial);
      _groupLine = groupPriceLine(groups);
    });
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF1C1C1E);
    const muted = Color(0xFF5C5C66);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.spMin, 8.spMin, 20.spMin, 24.spMin),
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40.spMin,
                  child: IconButton(
                    tooltip: 'Back',
                    padding: EdgeInsets.zero,
                    icon: const Icon(LucideIcons.chevronLeft, color: ink),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                Expanded(
                  child: Text(
                    'ALRT +',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
                SizedBox(width: 40.spMin),
              ],
            ),
            SizedBox(height: 8.spMin),
            Text(
              kChooseHeading,
              style: TextStyle(
                fontSize: 28.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                height: 1.15,
                color: ink,
              ),
            ),
            SizedBox(height: 8.spMin),
            Text(
              'Alerts, the live map, navigation, one saved place and 3 Ask '
              'ALRT questions a day are always free.',
              style: TextStyle(
                fontSize: 15.spMin,
                height: 1.5,
                color: muted,
              ),
            ),
            SizedBox(height: 18.spMin),
            PlanChoiceCard(
              gradient: kAlrtPlusGradient,
              eyebrow: 'ALRT +',
              priceLine: _personalLine,
              title: kChooseForMyselfTitle,
              body: kChooseForMyselfBody,
              onTap: () async {
                final ok = await context.push<bool>(
                  AlrtPlusPaywallScreen.route,
                  extra: const AlrtPlusPaywallArgs(),
                );
                if (ok == true && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
            SizedBox(height: 12.spMin),
            PlanChoiceCard(
              gradient: kGroupPlansGradient,
              eyebrow: 'ALRT + Family · Group',
              priceLine: _groupLine,
              title: kChooseCoverGroupTitle,
              body: kChooseCoverGroupBody,
              onTap: () async {
                final ok = await context.push<bool>(
                  AlrtPlusGroupPaywallScreen.route,
                );
                if (ok == true && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
            SizedBox(height: 14.spMin),
            // Prices are the store's, never typed here; a group plan buys
            // nobody personal extras, the payer included.
            Text(
              'Prices come from your app store. No annual plan. A group plan '
              'gives nobody personal extras, including the payer.',
              style: TextStyle(fontSize: 12.spMin, height: 1.5, color: muted),
            ),
            SizedBox(height: 24.spMin),
            SizedBox(
              height: 44.spMin,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: muted),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  kContinueFree,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
