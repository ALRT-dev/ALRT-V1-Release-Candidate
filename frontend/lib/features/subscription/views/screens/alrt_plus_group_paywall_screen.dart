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
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  /// V3 section label rust, and the selected size tile's fill and border.
  static const _sectionLabelColor = Color(0xFFB84500);
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _body = Color(0xFF3A3A42);
  static const _line = Color(0xFFE3E6EA);
  static const _groupIconTile = Color(0xFFEEEEFB);
  static const _groupIcon = Color(0xFF3D3DDF);

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
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          PlanHero(
            identity: identity,
            heading: kGroupHeading,
            intro: kGroupExplanation,
            badgeLabel: planTierName(tier),
            benefits: kGroupBenefits,
            onClose: _busy ? null : () => Navigator.of(context).pop(false),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20.spMin,
                18.spMin,
                20.spMin,
                32.spMin,
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
                else
                  _groupCard(group, access.coverableGroups),
                SizedBox(height: 18.spMin),
                _sectionLabel('Plan size'),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < _tiers.length; i++) ...[
                        if (i > 0) SizedBox(width: 8.spMin),
                        Expanded(
                          child: _tierTile(_tiers[i], group, selectedTier: tier),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 12.spMin),
                _scopeNote(
                  groupScope(
                    capacity: capacity,
                    group: group?.name ?? 'your group',
                  ),
                  identity,
                ),
                SizedBox(height: 18.spMin),
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
                SizedBox(height: 8.spMin),
                PaywallFinePrint(kSosSafetyStatement, center: true),
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

  /// V3 section label: #B84500, uppercase, letter-spaced.
  Widget _sectionLabel(final String text) => Padding(
    padding: EdgeInsets.only(bottom: 12.spMin),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12.spMin,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: _sectionLabelColor,
      ),
    ),
  );

  /// The board's "Group you will cover" card: the group's name and size
  /// with a chevron. With more than one group you host, tapping it opens
  /// a short list to pick from. With none, it says how to get one.
  Widget _groupCard(
    final GroupAccess? group,
    final List<GroupAccess> groups,
  ) {
    final canPick = groups.length > 1;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.spMin),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.spMin),
        onTap: canPick ? () => _pickGroup(groups) : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.spMin,
            vertical: 12.spMin,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.spMin),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32.spMin,
                height: 32.spMin,
                decoration: BoxDecoration(
                  color: _groupIconTile,
                  borderRadius: BorderRadius.circular(10.spMin),
                ),
                child: Icon(
                  LucideIcons.users,
                  size: 18.spMin,
                  color: _groupIcon,
                ),
              ),
              SizedBox(width: 10.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group?.name ?? 'No group yet',
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    Text(
                      group == null
                          ? 'You need to host a group before you can cover '
                                'it. Create a group in Family first.'
                          : '${_people(group.peopleCount)} · '
                                '${group.isHost ? 'you host' : 'you pay'}',
                      style: TextStyle(fontSize: 12.spMin, color: _muted),
                    ),
                  ],
                ),
              ),
              if (canPick)
                Icon(
                  LucideIcons.chevronDown,
                  size: 20.spMin,
                  color: _muted,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _people(final int n) => n == 1 ? '1 person' : '$n people';

  Future<void> _pickGroup(final List<GroupAccess> groups) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.spMin, 16.spMin, 16.spMin, 12.spMin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Group you will cover',
                style: TextStyle(
                  fontSize: 22.spMin,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              SizedBox(height: 8.spMin),
              for (final g in groups)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    g.name,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  subtitle: Text(_people(g.peopleCount)),
                  trailing: g.circleId == _circleId
                      ? Icon(LucideIcons.check, color: _ink, size: 20.spMin)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(g.circleId),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _circleId = picked);
  }

  /// The tinted note under the sizes: who the plan covers and what it
  /// does not change.
  Widget _scopeNote(final String text, final PlanIdentity identity) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: identity.tint,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13.spMin, height: 1.5, color: _body),
      ),
    );
  }

  /// One of three equal tiles, centred: the size name, "up to N people",
  /// the store's price and its period. The selected tile wears the plan's
  /// gradient with white text. A state line shows when the plan can't
  /// simply be bought (your current plan, upgrade, too small, change in
  /// store).
  Widget _tierTile(
    final PlanTier tier,
    final GroupAccess? group, {
    required final PlanTier selectedTier,
  }) {
    final selected = selectedTier == tier;
    final choice = _choice(tier, group);
    final enabled = choice == TierChoice.buy || choice == TierChoice.upgrade;
    final price = _priceFor(tier);
    final period = _periodFor(tier);
    final String? state = switch (choice) {
      TierChoice.buy => null,
      TierChoice.upgrade => 'Upgrade',
      TierChoice.current => 'Your current plan',
      TierChoice.smaller => 'Change in your app store',
      TierChoice.tooSmall => 'Too small for this group',
    };
    final on = selected && enabled;
    final identity = PlanIdentity.of(tier);
    final strong = on ? Colors.white : _ink;
    final soft = on ? Colors.white.withValues(alpha: 0.85) : _muted;
    return Opacity(
      opacity: enabled || choice == TierChoice.current ? 1 : 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.spMin),
        onTap: enabled ? () => setState(() => _tier = tier) : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.spMin,
            vertical: 12.spMin,
          ),
          decoration: BoxDecoration(
            color: on ? null : Colors.white,
            gradient: on ? identity.linearGradient : null,
            borderRadius: BorderRadius.circular(14.spMin),
            border: on ? null : Border.all(color: _line, width: 1.5),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: identity.accent.withValues(alpha: 0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                planTierName(tier),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w700,
                  color: strong,
                ),
              ),
              SizedBox(height: 2.spMin),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'up to ${sponsoredCapacity(tier)}',
                    style: TextStyle(fontSize: 12.spMin, color: soft),
                  ),
                  Text(
                    ' people',
                    style: TextStyle(fontSize: 12.spMin, color: soft),
                  ),
                ],
              ),
              SizedBox(height: 6.spMin),
              if (_loading)
                Text('…', style: TextStyle(fontSize: 16.spMin, color: strong))
              else if (price.isNotEmpty)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: price,
                        style: TextStyle(
                          fontSize: 16.spMin,
                          fontWeight: FontWeight.w700,
                          color: strong,
                        ),
                      ),
                      TextSpan(
                        text: '/$period',
                        style: TextStyle(fontSize: 11.spMin, color: soft),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              if (state != null) ...[
                SizedBox(height: 4.spMin),
                Text(
                  state,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.spMin,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: soft,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
