import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:hazard_app/features/subscription/utils/purchase_error_message.dart';
import 'package:hazard_app/features/subscription/utils/store_price.dart';
import 'package:hazard_app/features/subscription/views/widgets/paywall_parts.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class AlrtPlusGroupPaywallArgs {
  const AlrtPlusGroupPaywallArgs({this.circleId});

  /// Pre-selects this group when the person hosts it.
  final String? circleId;
}

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
        _notice = 'This build has no billing key, so group plans cannot be '
            'bought here.';
        _noticeIsError = true;
      });
      return;
    }
    setState(() => _loading = true);
    final offering = await rc.offering(RevenueCatService.groupsOfferingId);
    if (!mounted) return;
    setState(() {
      _offering = offering;
      _loading = false;
      if (offering == null) {
        _notice = 'Group plans could not be loaded from the store. Check '
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
    final hosted = access.hostedGroups;
    if (hosted.isEmpty) return null;
    return hosted.firstWhere(
      (g) => g.circleId == _circleId,
      orElse: () => hosted.first,
    );
  }

  bool _tierFits(final PlanTier tier, final GroupAccess? group) =>
      group == null || group.peopleCount <= sponsoredCapacity(tier);

  Future<void> _subscribe(final GroupAccess group) async {
    if (_busy) return;
    if (_dummy) {
      Navigator.of(context).pop(true);
      return;
    }
    final package = packageForTier(_offering, _tier);
    if (package == null) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    // Capacity and "already covered" are checked by the backend before
    // the store sheet opens, and again when the purchase is bound.
    final intent = await ref
        .read(providerOfAccessRepository)
        .createSponsorshipIntent(circleId: group.circleId, tier: _tier);
    if (!mounted) return;
    if (intent.isFailure) {
      setState(() {
        _busy = false;
        _notice = intent.failure.message;
        _noticeIsError = true;
      });
      return;
    }
    try {
      await ref.read(providerOfRevenueCat).purchasePackage(package);
      await _confirmWithBackend(group.circleId);
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

  Future<void> _confirmWithBackend(final String circleId) async {
    final repo = ref.read(providerOfAccessRepository);
    for (var attempt = 0; attempt < 5; attempt++) {
      final result = await repo.getAccess();
      final group = result.isSuccess ? result.success.groupById(circleId) : null;
      if (group != null && group.isSponsoredAndLive) {
        ref.invalidate(providerOfAccess);
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
    }
    ref.invalidate(providerOfAccess);
    if (mounted) {
      setState(() {
        _confirmedUpdating = true;
        _notice = kPurchaseConfirmedUpdating;
        _noticeIsError = false;
      });
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref.read(providerOfRevenueCat).restore();
    ref.invalidate(providerOfAccess);
    if (mounted) setState(() => _busy = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Purchases restored. Any group plan now shows under My plans.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessAsync = ref.watch(providerOfAccess);
    final access = accessAsync.asData?.value;
    final group = _selectedGroup(access);
    final identity = PlanIdentity.of(_tier);
    final capacity = sponsoredCapacity(_tier);
    final price = _priceFor(_tier);
    final period = _periodFor(_tier);
    final canBuy = !_loading &&
        group != null &&
        _tierFits(_tier, group) &&
        !(group.isSponsoredAndLive) &&
        (_dummy || packageForTier(_offering, _tier) != null);

    return Scaffold(
      backgroundColor: kPaywallBody,
      body: Column(
        children: [
          PlanHero(
            identity: identity,
            heading: kGroupHeading,
            intro: kGroupExplanation,
            badgeLabel: planTierName(_tier),
            onClose: _busy ? null : () => Navigator.of(context).pop(false),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(18.spMin, 16.spMin, 18.spMin, 24.spMin),
              children: [
                _sectionLabel(kGroupSelectorLabel),
                if (accessAsync.isLoading)
                  const PaywallNotice(text: 'Loading your groups…')
                else if (access == null)
                  const PaywallNotice(
                    text: 'Your groups could not be loaded. Check your '
                        'connection and try again.',
                    isError: true,
                  )
                else if (access.hostedGroups.isEmpty)
                  const PaywallNotice(
                    text: 'You need to host a group before you can cover it. '
                        'Create one in Family, then come back here.',
                  )
                else
                  PaywallCard(
                    padding: EdgeInsets.symmetric(vertical: 4.spMin),
                    child: Column(
                      children: [
                        for (final g in access.hostedGroups)
                          _groupRow(g, selected: g.circleId == group?.circleId),
                      ],
                    ),
                  ),
                SizedBox(height: 16.spMin),
                _sectionLabel('Plan'),
                for (final tier in _tiers) ...[
                  _tierRow(tier, group),
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
                if (group != null && group.isSponsoredAndLive) ...[
                  PaywallNotice(
                    text: '${group.name} already has a plan. Change it from '
                        'My plans.',
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
                        : subscribeCta(price: price, period: period),
                    identity: identity,
                    busy: _busy,
                    onPressed: canBuy ? () => _subscribe(group) : null,
                  ),
                SizedBox(height: 10.spMin),
                if (!_loading && price.isNotEmpty)
                  PaywallFinePrint(
                    groupDisclosure(
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
                  ? PlanIdentity.of(_tier).accentFor(context)
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
  Widget _tierRow(final PlanTier tier, final GroupAccess? group) {
    final identity = PlanIdentity.of(tier);
    final selected = _tier == tier;
    final fits = _tierFits(tier, group);
    final price = _priceFor(tier);
    final period = _periodFor(tier);
    final accent = identity.accentFor(context);
    return Opacity(
      opacity: fits ? 1 : 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.spMin),
        onTap: fits ? () => setState(() => _tier = tier) : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
          decoration: BoxDecoration(
            color: selected ? identity.tint : Colors.white,
            borderRadius: BorderRadius.circular(16.spMin),
            border: Border.all(
              color: selected ? accent : kPaywallLine,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? accent : kPaywallInkFaint,
                size: 22.spMin,
              ),
              SizedBox(width: 10.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ALRT + ${planTierName(tier)}',
                      style: TextStyle(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w700,
                        color: kPaywallInk,
                      ),
                    ),
                    Text(
                      fits
                          ? 'Up to ${sponsoredCapacity(tier)} people'
                          : 'Up to ${sponsoredCapacity(tier)} people · too small for this group',
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
            ],
          ),
        ),
      ),
    );
  }
}
