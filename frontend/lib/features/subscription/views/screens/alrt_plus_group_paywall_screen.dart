import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:hazard_app/features/subscription/utils/purchase_error_message.dart';
import 'package:hazard_app/features/subscription/utils/restore_outcome.dart';
import 'package:hazard_app/features/subscription/utils/store_price.dart';
import 'package:hazard_app/features/subscription/views/widgets/paywall_parts.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class AlrtPlusGroupPaywallArgs {
  const AlrtPlusGroupPaywallArgs({this.circleId, this.tier});

  /// Pre-selects this group when the person hosts it (or pays for it).
  final String? circleId;

  /// Pre-selects this plan (for example the next size up, from "Upgrade").
  final PlanTier? tier;
}

/// What the person can do with [tier] for a group whose live plan they
/// pay for at [current] (null = no live plan of theirs).
enum TierChoice { buy, upgrade, current, smaller, tooSmall }

TierChoice tierChoice({
  required final PlanTier tier,
  required final PlanTier? current,
  required final int peopleCount,
}) {
  if (current != null) {
    if (tier == current) return TierChoice.current;
    if (sponsorRank(tier) < sponsorRank(current)) return TierChoice.smaller;
    return TierChoice.upgrade;
  }
  return peopleCount <= sponsoredCapacity(tier)
      ? TierChoice.buy
      : TierChoice.tooSmall;
}

/// Store wording for an upgrade, before purchase. Google Play: prorated
/// charge now, same renewal date. App Store: immediate, unused time of
/// the old plan refunded.
String upgradeDisclosure({
  required final bool isAndroid,
  required final String price,
  required final String renewsEvery,
}) => isAndroid
    ? 'Google Play charges the prorated difference now and keeps your '
          'renewal date, then $price renews $renewsEvery. No free trial. '
          'Manage or cancel in your Google Play account.'
    : 'The upgrade starts straight away and the App Store refunds the '
          'unused part of your current plan, then $price renews '
          '$renewsEvery. No free trial. Manage or cancel in your App Store '
          'account.';

/// Which store package in the `groups` offering sells [tier]. RevenueCat
/// package identifiers `family`, `group20`, `group50` are the contract
/// (reconfiguration item C10); a product id naming the tier also matches,
/// so a differently named package still renders rather than vanishing.
Package? packageForTier(final Offering? offering, final PlanTier tier) {
  if (offering == null) return null;
  final key = tier.name.toLowerCase();
  for (final p in offering.availablePackages) {
    if (p.identifier.toLowerCase() == key) return p;
  }
  for (final p in offering.availablePackages) {
    final id = p.storeProduct.identifier.toLowerCase();
    if (id.contains(key)) return p;
  }
  return null;
}

/// ALRT + Family / Group 20 / Group 50 purchase screen (master spec §5,
/// §6, §9). One payer covers the connection features of ONE group they
/// host. The group is chosen before the store sheet opens and recorded on
/// the backend (a sponsorship intent), so the purchase can only ever
/// cover that group. No trial. Personal limits are not part of this plan.
class AlrtPlusGroupPaywallScreen extends ConsumerStatefulWidget {
  const AlrtPlusGroupPaywallScreen({
    super.key,
    this.args,
    this.isAndroidOverride,
  });

  static const route = '/alrt-plus/groups';

  final AlrtPlusGroupPaywallArgs? args;
  final bool? isAndroidOverride;

  @override
  ConsumerState<AlrtPlusGroupPaywallScreen> createState() =>
      _AlrtPlusGroupPaywallScreenState();
}

class _AlrtPlusGroupPaywallScreenState
    extends ConsumerState<AlrtPlusGroupPaywallScreen> {
  static const _tiers = [PlanTier.family, PlanTier.group20, PlanTier.group50];

  Offering? _offering;
  bool _loading = true;
  bool _busy = false;
  String? _notice;
  bool _noticeIsError = false;
  bool _confirmedUpdating = false;
  String? _circleId;
  PlanTier _tier = PlanTier.family;
  bool _dummy = false;

  bool get _isAndroid =>
      widget.isAndroidOverride ?? (!kIsWeb && Platform.isAndroid);

  @override
  void initState() {
    super.initState();
    _circleId = widget.args?.circleId;
    _tier = widget.args?.tier ?? PlanTier.family;
    _load();
  }

  Future<void> _load() async {
    if (isAlrtPlusTestUnlocked) {
      setState(() {
        _dummy = true;
        _loading = false;
      });
      return;
    }
    final rc = ref.read(providerOfRevenueCat);
    if (!rc.hasKeys) {
      setState(() {
        _loading = false;
        _notice =
            'This build has no billing key, so group plans cannot be '
            'bought here.';
        _noticeIsError = true;
      });
      return;
    }
    setState(() => _loading = true);
    // Signed in as this ALRT user before the store is read, so the
    // purchase that follows is attributed to the right account.
    await rc.ensureConfiguredFor(ref.read(providerOfLoggedInUser)?.id);
    if (!mounted) return;
    final offering = await rc.offering(RevenueCatService.groupsOfferingId);
    if (!mounted) return;
    setState(() {
      _offering = offering;
      _loading = false;
      if (offering == null) {
        _notice =
            'Group plans could not be loaded from the store. Check '
            'your connection and try again.';
        _noticeIsError = true;
      }
    });
  }

  String _priceFor(final PlanTier tier) {
    if (_dummy) {
      return switch (tier) {
        PlanTier.family => 'A\$15.99',
        PlanTier.group20 => 'A\$24.99',
        PlanTier.group50 => 'A\$49.99',
        PlanTier.individual => '',
      };
    }
    final p = packageForTier(_offering, tier);
    return p == null ? '' : storePriceLabel(p.storeProduct);
  }

  String _periodFor(final PlanTier tier) {
    if (_dummy) return 'month';
    final p = packageForTier(_offering, tier);
    return p == null
        ? ''
        : billingPeriodNoun(p.storeProduct, p.packageType) ?? 'period';
  }

  GroupAccess? _selectedGroup(final AccessSummary? access) {
    if (access == null) return null;
    final groups = access.coverableGroups;
    if (groups.isEmpty) return null;
    return groups.firstWhere(
      (g) => g.circleId == _circleId,
      orElse: () => groups.first,
    );
  }

  /// The live plan this person pays for on [group], if any.
  PlanTier? _currentTier(final GroupAccess? group) {
    final s = group?.sponsorship;
    return group != null && group.isSponsoredAndLive && s != null && s.youPay
        ? s.tier
        : null;
  }

  /// Covered by someone else's live plan: nothing to buy here.
  bool _coveredByOther(final GroupAccess? group) =>
      group != null &&
      group.isSponsoredAndLive &&
      !(group.sponsorship?.youPay ?? false);

  TierChoice _choice(final PlanTier tier, final GroupAccess? group) =>
      tierChoice(
        tier: tier,
        current: _currentTier(group),
        peopleCount: group?.peopleCount ?? 0,
      );

  bool _selectable(final PlanTier tier, final GroupAccess? group) {
    final c = _choice(tier, group);
    return c == TierChoice.buy || c == TierChoice.upgrade;
  }

  /// Keeps the selected plan valid for the selected group.
  PlanTier _effectiveTier(final GroupAccess? group) {
    if (_selectable(_tier, group)) return _tier;
    for (final t in _tiers) {
      if (_selectable(t, group)) return t;
    }
    return _tier;
  }

  Future<void> _subscribe(final GroupAccess group, final PlanTier tier) async {
    if (_busy) return;
    if (_dummy) {
      Navigator.of(context).pop(true);
      return;
    }
    final package = packageForTier(_offering, tier);
    if (package == null) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    // Capacity, "already covered" and "only the payer can upgrade" are
    // checked by the backend before the store sheet opens.
    final intent = await ref
        .read(providerOfAccessRepository)
        .createSponsorshipIntent(circleId: group.circleId, tier: tier);
    if (!mounted) return;
    if (intent.isFailure) {
      setState(() {
        _busy = false;
        _notice = intent.failure.message;
        _noticeIsError = true;
      });
      return;
    }
    final upgrade = intent.success;
    try {
      await ref
          .read(providerOfRevenueCat)
          .purchasePackage(
            package,
            // Google Play replaces the old subscription in place; the App
            // Store upgrades within the subscription group by itself.
            replacingProductId: _isAndroid && upgrade.isUpgrade
                ? upgrade.replacesProductId
                : null,
          );
      await _confirmWithBackend(group, tier, isUpgrade: upgrade.isUpgrade);
    } catch (error) {
      final message = purchaseErrorMessage(error);
      if (mounted && message != null) {
        setState(() {
          _notice = message;
          _noticeIsError = message != kPurchasePending;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Waits for ALRT to confirm the plan is in force: the group covered at
  /// [tier]. The store accepting a purchase is not enough; an upgrade in
  /// particular stays pending until the store confirms it took effect.
  Future<void> _confirmWithBackend(
    final GroupAccess group,
    final PlanTier tier, {
    required final bool isUpgrade,
  }) async {
    final repo = ref.read(providerOfAccessRepository);
    for (var attempt = 0; attempt < 5; attempt++) {
      final result = await repo.reconcile();
      final g = result.isSuccess
          ? result.success.access.groupById(group.circleId)
          : null;
      if (g != null && g.isSponsoredAndLive && g.sponsorship?.tier == tier) {
        ref.invalidate(providerOfAccess);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUpgrade
                  ? 'Upgrade confirmed. ${group.name} is now covered for up '
                        'to ${sponsoredCapacity(tier)} people.'
                  : '${group.name} is now covered by ${planDisplayName(tier)}.',
            ),
          ),
        );
        Navigator.of(context).pop(true);
        return;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
    }
    ref.invalidate(providerOfAccess);
    if (mounted) {
      setState(() {
        _confirmedUpdating = true;
        _notice = isUpgrade
            ? 'Your store accepted the upgrade. ${group.name} stays on '
                  '${planTierName(group.sponsorship?.tier ?? PlanTier.family)} '
                  'until it is confirmed, which usually takes a minute. My '
                  'plans shows the change when it lands.'
            : kPurchaseConfirmedUpdating;
        _noticeIsError = false;
      });
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    if (_dummy) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    final outcome = await runRestore(ref);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _notice = outcome.message;
      _noticeIsError = outcome.isError;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accessAsync = ref.watch(providerOfAccess);
    final access = accessAsync.asData?.value;
    final group = _selectedGroup(access);
    final tier = _effectiveTier(group);
    final identity = PlanIdentity.of(tier);
    final capacity = sponsoredCapacity(tier);
    final price = _priceFor(tier);
    final period = _periodFor(tier);
    final current = _currentTier(group);
    final isUpgrade = current != null;
    final canBuy =
        !_loading &&
        group != null &&
        _selectable(tier, group) &&
        !_coveredByOther(group) &&
        (_dummy || packageForTier(_offering, tier) != null);

    return Scaffold(
      backgroundColor: kPaywallBody,
      body: Column(
        children: [
          PlanHero(
            identity: identity,
            heading: kGroupHeading,
            intro: kGroupExplanation,
            badgeLabel: planTierName(tier),
            coverLine: group == null
                ? 'Covers everyone in one group'
                : 'Covers everyone in ${group.name} · up to $capacity people',
            onClose: _busy ? null : () => Navigator.of(context).pop(false),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                18.spMin,
                16.spMin,
                18.spMin,
                24.spMin,
              ),
              children: [
                _sectionLabel(kGroupSelectorLabel),
                if (accessAsync.isLoading)
                  const PaywallNotice(text: 'Loading your groups…')
                else if (access == null)
                  const PaywallNotice(
                    text:
                        'Your groups could not be loaded. Check your '
                        'connection and try again.',
                    isError: true,
                  )
                else if (access.coverableGroups.isEmpty)
                  const PaywallNotice(
                    text:
                        'You need to host a group before you can cover it. '
                        'Create one in Family, then come back here.',
                  )
                else
                  PaywallCard(
                    padding: EdgeInsets.symmetric(vertical: 4.spMin),
                    child: Column(
                      children: [
                        for (final g in access.coverableGroups)
                          _groupRow(g, selected: g.circleId == group?.circleId),
                      ],
                    ),
                  ),
                SizedBox(height: 16.spMin),
                _sectionLabel('Plan'),
                for (final t in _tiers) ...[
                  _tierRow(t, group, selectedTier: tier),
                  SizedBox(height: 8.spMin),
                ],
                SizedBox(height: 8.spMin),
                PaywallCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final b in kGroupBenefits)
                        PlanBenefit(text: b, identity: identity),
                    ],
                  ),
                ),
                SizedBox(height: 12.spMin),
                if (group != null)
                  PaywallFinePrint(
                    groupScope(capacity: capacity, group: group.name),
                  ),
                SizedBox(height: 10.spMin),
                PaywallFinePrint(kSosSafetyStatement),
                SizedBox(height: 16.spMin),
                if (_coveredByOther(group)) ...[
                  PaywallNotice(
                    text:
                        '${group!.name} is already covered by '
                        '${group.sponsorship?.coveredBy ?? 'someone else'}\'s '
                        'plan. Only the person who pays for it can change it.',
                  ),
                  SizedBox(height: 12.spMin),
                ] else if (isUpgrade && !_selectable(tier, group)) ...[
                  PaywallNotice(
                    text:
                        '${group!.name} is on ${planDisplayName(current)}, '
                        'the biggest plan. To move to a smaller plan, change '
                        'it in your app store; it applies when your current '
                        'period renews.',
                  ),
                  SizedBox(height: 12.spMin),
                ],
                if (_notice != null) ...[
                  PaywallNotice(text: _notice!, isError: _noticeIsError),
                  SizedBox(height: 12.spMin),
                ],
                if (_confirmedUpdating)
                  PlanCta(
                    label: 'Done',
                    identity: identity,
                    onPressed: () => Navigator.of(context).pop(true),
                  )
                else
                  PlanCta(
                    label: _loading
                        ? kCheckingPlans
                        : isUpgrade
                        ? 'Upgrade for $price/$period'
                        : subscribeCta(price: price, period: period),
                    identity: identity,
                    busy: _busy,
                    onPressed: canBuy ? () => _subscribe(group, tier) : null,
                  ),
                SizedBox(height: 10.spMin),
                if (!_loading && price.isNotEmpty)
                  PaywallFinePrint(
                    isUpgrade
                        ? upgradeDisclosure(
                            isAndroid: _isAndroid,
                            price: price,
                            renewsEvery: renewsEveryPhrase(period),
                          )
                        : groupDisclosure(
                            price: price,
                            renewsEvery: renewsEveryPhrase(period),
                            store: storeName(isAndroid: _isAndroid),
                          ),
                    center: true,
                  ),
                if (_dummy)
                  PaywallFinePrint(
                    'Preview build: not store prices, no real purchase.',
                    center: true,
                  ),
                SizedBox(height: 14.spMin),
                PaywallFooter(
                  busy: _busy,
                  onContinueFree: () => Navigator.of(context).pop(false),
                  onRestore: _restore,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(final String text) => Padding(
    padding: EdgeInsets.only(left: 4.spMin, bottom: 8.spMin),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11.spMin,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: kPaywallInkFaint,
      ),
    ),
  );

  Widget _groupRow(final GroupAccess g, {required final bool selected}) {
    return InkWell(
      onTap: () => setState(() => _circleId = g.circleId),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 10.spMin),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? PlanIdentity.of(_effectiveTier(g)).accentFor(context)
                  : kPaywallInkFaint,
              size: 22.spMin,
            ),
            SizedBox(width: 10.spMin),
            Expanded(
              child: Text(
                g.name,
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w600,
                  color: kPaywallInk,
                ),
              ),
            ),
            Text(
              g.peopleCount == 1 ? '1 person' : '${g.peopleCount} people',
              style: TextStyle(fontSize: 12.5.spMin, color: kPaywallInkSoft),
            ),
          ],
        ),
      ),
    );
  }

  /// Name and capacity on the left, the store's monthly price on the right.
  Widget _tierRow(
    final PlanTier tier,
    final GroupAccess? group, {
    required final PlanTier selectedTier,
  }) {
    final identity = PlanIdentity.of(tier);
    final selected = selectedTier == tier;
    final choice = _choice(tier, group);
    final enabled = choice == TierChoice.buy || choice == TierChoice.upgrade;
    final price = _priceFor(tier);
    final period = _periodFor(tier);
    final accent = identity.accentFor(context);
    final people = 'Up to ${sponsoredCapacity(tier)} people';
    final subtitle = switch (choice) {
      TierChoice.buy => people,
      TierChoice.upgrade => '$people · upgrade',
      TierChoice.current => '$people · your current plan',
      TierChoice.smaller => '$people · change in your app store',
      TierChoice.tooSmall => '$people · too small for this group',
    };
    return Opacity(
      opacity: enabled || choice == TierChoice.current ? 1 : 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.spMin),
        onTap: enabled ? () => setState(() => _tier = tier) : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.spMin,
            vertical: 12.spMin,
          ),
          decoration: BoxDecoration(
            color: selected && enabled ? identity.tint : Colors.white,
            borderRadius: BorderRadius.circular(16.spMin),
            border: Border.all(
              color: selected && enabled ? accent : kPaywallLine,
              width: selected && enabled ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12.spMin,
                height: 36.spMin,
                decoration: BoxDecoration(
                  gradient: identity.linearGradient,
                  borderRadius: BorderRadius.circular(6.spMin),
                ),
              ),
              SizedBox(width: 12.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planDisplayName(tier),
                      style: TextStyle(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w700,
                        color: kPaywallInk,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: kPaywallInkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _loading ? '…' : (price.isEmpty ? '' : '$price/$period'),
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w700,
                  color: kPaywallInk,
                ),
              ),
              if (enabled) ...[
                SizedBox(width: 8.spMin),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? accent : kPaywallInkFaint,
                  size: 20.spMin,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
