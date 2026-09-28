import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_group_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:hazard_app/features/subscription/utils/restore_outcome.dart';
import 'package:hazard_app/features/subscription/views/widgets/billing_issue_banner.dart';
import 'package:hazard_app/features/subscription/views/widgets/paywall_parts.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// "My plans" (master spec §8, §16): the personal plan and each group's
/// coverage, shown SEPARATELY, as the backend computed them
/// (GET /api/access). A Family payer without Individual is personally on
/// ALRT Free; a covered member sees who covers which group without being
/// told they own a plan. No seats.
class AlrtPlusManageScreen extends ConsumerStatefulWidget {
  const AlrtPlusManageScreen({super.key});

  static const route = '/alrt-plus/manage';

  @override
  ConsumerState<AlrtPlusManageScreen> createState() =>
      _AlrtPlusManageScreenState();
}

class _AlrtPlusManageScreenState extends ConsumerState<AlrtPlusManageScreen> {
  static final _date = DateFormat('d MMMM y');

  Future<void> _openStoreManagement() async {
    const fallback =
        'Manage your subscription in your app store account settings.';
    if (isAlrtPlusTestUnlocked) {
      _snack(fallback);
      return;
    }
    final url = await ref.read(providerOfRevenueCat).managementUrl();
    if (url == null) {
      _snack(fallback);
      return;
    }
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      _snack(fallback);
    }
  }

  bool _restoring = false;

  Future<void> _restore() async {
    if (_restoring) return;
    if (isAlrtPlusTestUnlocked) {
      _snack('Preview build: nothing to restore.');
      return;
    }
    setState(() => _restoring = true);
    final outcome = await runRestore(ref);
    if (!mounted) return;
    setState(() => _restoring = false);
    _snack(outcome.message);
  }

  Future<void> _applyUnbound(
    final UnboundSponsorship plan,
    final List<GroupAccess> hosted,
  ) async {
    final eligible = hosted
        .where((g) => g.peopleCount <= sponsoredCapacity(plan.tier))
        .where((g) => !g.isSponsoredAndLive)
        .toList();
    if (eligible.isEmpty) {
      _snack('None of the groups you host can take this plan right now.');
      return;
    }
    final chosen = await showModalBottomSheet<GroupAccess>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Which group should your ${planTierName(plan.tier)} plan '
                'cover? This can\'t be changed later.',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            for (final g in eligible)
              ListTile(
                title: Text(g.name),
                subtitle: Text('${g.peopleCount} people'),
                onTap: () => Navigator.of(context).pop(g),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    final result = await ref
        .read(providerOfAccessRepository)
        .bindSponsorship(subscriptionId: plan.id, circleId: chosen.circleId);
    ref.invalidate(providerOfAccess);
    _snack(
      result.isSuccess
          ? 'Your plan now covers ${chosen.name}.'
          : result.failure.message,
    );
  }

  void _snack(final String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final accessAsync = ref.watch(providerOfAccess);
    return Scaffold(
      backgroundColor: kPaywallBody,
      appBar: AppBar(
        backgroundColor: kPaywallBody,
        title: const Text('My plans'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(HomeScreen.route),
        ),
      ),
      body: accessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _unavailable(),
        data: (access) => access == null ? _unavailable() : _body(access),
      ),
    );
  }

  Widget _unavailable() => Padding(
    padding: EdgeInsets.all(18.spMin),
    child: Column(
      children: [
        const PaywallNotice(
          text:
              'Your plans could not be loaded. Check your connection and '
              'try again.',
          isError: true,
        ),
        TextButton(
          onPressed: () => ref.invalidate(providerOfAccess),
          child: const Text('Try again'),
        ),
      ],
    ),
  );

  Widget _body(final AccessSummary access) {
    return ListView(
      padding: EdgeInsets.fromLTRB(18.spMin, 8.spMin, 18.spMin, 32.spMin),
      children: [
        // A failed renewal is said here, on the plan surface, not on the
        // connection screens (master spec §11).
        const BillingIssueBanner(),
        _label('Personal plan'),
        _personalCard(access.personal),
        SizedBox(height: 18.spMin),
        _label('Group coverage'),
        if (access.groups.isEmpty)
          const PaywallNotice(
            text:
                'You are not in any groups yet. Groups are free to create '
                'and join.',
          )
        else
          for (final g in access.groups) ...[
            _groupCard(g),
            SizedBox(height: 10.spMin),
          ],
        if (access.unboundSponsorships.isNotEmpty) ...[
          SizedBox(height: 8.spMin),
          for (final plan in access.unboundSponsorships)
            PaywallCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlanBadge(identity: PlanIdentity.of(plan.tier)),
                  SizedBox(height: 8.spMin),
                  Text(
                    'You have a ${planTierName(plan.tier)} plan that isn\'t '
                    'covering a group yet.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () => _applyUnbound(plan, access.hostedGroups),
                    child: const Text('Choose the group it covers'),
                  ),
                ],
              ),
            ),
        ],
        SizedBox(height: 18.spMin),
        PaywallCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _action(
                LucideIcons.users,
                'Cover a group',
                () => context.push(AlrtPlusGroupPaywallScreen.route),
              ),
              const Divider(height: 1),
              _action(
                LucideIcons.externalLink,
                'Manage in your app store',
                _openStoreManagement,
              ),
              const Divider(height: 1),
              _action(
                LucideIcons.refreshCw,
                _restoring ? 'Restoring purchases…' : 'Restore purchases',
                _restore,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(final String text) => Padding(
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

  Widget _personalCard(final PersonalAccess personal) {
    if (personal.isIndividual) {
      final until = personal.expiresAt;
      final String? chip;
      if (personal.billingDisabled) {
        chip = 'Billing is off on this server: everything is open';
      } else if (personal.isTrial && until != null) {
        chip = 'Free trial until ${_date.format(until.toLocal())}';
      } else if (until != null) {
        chip = personal.willRenew
            ? 'Renews ${_date.format(until.toLocal())}'
            : 'Ends ${_date.format(until.toLocal())}, won\'t renew';
      } else {
        chip = 'Active';
      }
      return PlanCoverageCard(
        identity: PlanIdentity.individual,
        eyebrow: 'ALRT +',
        title: 'Covers you',
        covers: kPersonalCoversLine(personal.askPerDay),
        chip: chip,
      );
    }
    return PlanCoverageCard(
      eyebrow: 'ALRT Free',
      title: 'You',
      covers:
          '${personal.extraSavedPlaces ?? 1} saved place as well as where '
          'you are, and ${personal.askPerDay} Ask ALRT questions a day. '
          'Group plans don\'t change these.',
      actionLabel: 'See ALRT +',
      actionIdentity: PlanIdentity.individual,
      onAction: () => context.push(
        AlrtPlusPaywallScreen.route,
        extra: const AlrtPlusPaywallArgs(),
      ),
    );
  }

  Widget _groupCard(final GroupAccess g) {
    final s = g.sponsorship;
    if (g.fundingMode == GroupFundingMode.sponsored && s != null && s.live) {
      final who = s.youPay ? 'you' : (s.coveredBy ?? 'the group\'s payer');
      final capacity = g.capacity ?? sponsoredCapacity(s.tier);
      final pending = s.pendingTier;
      final upgrade = s.youPay ? s.upgradeTier : null;
      return PlanCoverageCard(
        identity: PlanIdentity.of(s.tier),
        eyebrow: planDisplayName(s.tier),
        title: g.name,
        chip: 'Covers everyone here · ${g.peopleCount} of $capacity people',
        covers:
            'Check in, Check on, SOS and Journey for everyone in this '
            'group. Paid by $who.',
        note: pending == null
            ? null
            : sponsorRank(pending) > sponsorRank(s.tier)
            ? 'Upgrade to ${planDisplayName(pending)} requested. This '
                  'group stays on ${planTierName(s.tier)} until your store '
                  'confirms it.'
            : 'Changing to ${planDisplayName(pending)} at renewal. Until '
                  'then it stays ${planTierName(s.tier)}.',
        actionLabel: upgrade != null && pending == null
            ? 'Upgrade to ${planDisplayName(upgrade)}'
            : null,
        onAction: upgrade == null
            ? null
            : () => context.push(
                AlrtPlusGroupPaywallScreen.route,
                extra: AlrtPlusGroupPaywallArgs(
                  circleId: g.circleId,
                  tier: upgrade,
                ),
              ),
      );
    }
    if (g.fundingMode == GroupFundingMode.sponsored) {
      return PlanCoverageCard(
        eyebrow: s == null
            ? 'Group plan ended'
            : '${planDisplayName(s.tier)} ended',
        title: g.name,
        covers:
            'Check in, Check on, SOS and Journey are paused here. Stopping '
            'and ending still work.',
        note: s?.youPay ?? false
            ? 'Renew it in your app store to switch them back on.'
            : g.isHost
            ? 'You can cover this group again with a new plan.'
            : 'The host can renew or replace the plan.',
        actionLabel: s?.youPay ?? false
            ? 'Renew in your app store'
            : g.isHost
            ? 'Cover this group'
            : null,
        onAction: s?.youPay ?? false
            ? _openStoreManagement
            : g.isHost
            ? () => context.push(
                AlrtPlusGroupPaywallScreen.route,
                extra: AlrtPlusGroupPaywallArgs(circleId: g.circleId),
              )
            : null,
      );
    }
    return PlanCoverageCard(
      eyebrow: 'No group plan',
      title: g.name,
      covers: g.connectionAllowed
          ? 'Your ALRT + covers you here. Others need their own ALRT +, or '
                'the host can cover everyone with a Family or Group plan.'
          : 'Each person needs ALRT + to use Check in, Check on, SOS and '
                'Journey here, or the host can cover everyone.',
      actionLabel: g.isHost ? 'Cover this group' : null,
      onAction: g.isHost
          ? () => context.push(
              AlrtPlusGroupPaywallScreen.route,
              extra: AlrtPlusGroupPaywallArgs(circleId: g.circleId),
            )
          : null,
    );
  }

  Widget _action(
    final IconData icon,
    final String label,
    final VoidCallback onTap,
  ) => ListTile(
    leading: Icon(icon, size: 20.spMin),
    title: Text(label, style: TextStyle(fontSize: 14.spMin)),
    trailing: const Icon(LucideIcons.chevronRight, size: 18),
    onTap: onTap,
  );
}
