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

  Future<void> _restore() async {
    if (!isAlrtPlusTestUnlocked) {
      await ref.read(providerOfRevenueCat).restore();
    }
    ref.invalidate(providerOfAccess);
    ref.invalidate(providerOfAlrtPlus);
    _snack('Purchases restored. Your plans below are up to date.');
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
          text: 'Your plans could not be loaded. Check your connection and '
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
            text: 'You are not in any groups yet. Groups are free to create '
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
                    onPressed: () =>
                        _applyUnbound(plan, access.hostedGroups),
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
              _action(LucideIcons.refreshCw, 'Restore purchases', _restore),
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
      final String status;
      if (personal.billingDisabled) {
        status = 'Billing isn\'t switched on for this server yet, so every '
            'feature is open.';
      } else if (personal.isTrial && until != null) {
        status = 'Free trial until ${_date.format(until.toLocal())}.';
      } else if (until != null) {
        status = personal.willRenew
            ? 'Renews ${_date.format(until.toLocal())}.'
            : 'Ends ${_date.format(until.toLocal())}. It won\'t renew.';
      } else {
        status = 'Active.';
      }
      return PaywallCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlanBadge(identity: PlanIdentity.individual),
            SizedBox(height: 8.spMin),
            Text(status, style: const TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 4.spMin),
            PaywallFinePrint(
              'Unlimited saved places · ${personal.askPerDay} Ask ALRT '
              'questions a day · unlimited groups',
            ),
          ],
        ),
      );
    }
    return PaywallCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ALRT Free',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          SizedBox(height: 4.spMin),
          PaywallFinePrint(
            '${personal.extraSavedPlaces ?? 1} saved place as well as where '
            'you are · ${personal.askPerDay} Ask ALRT questions a day. Group '
            'plans don\'t change these.',
          ),
          SizedBox(height: 10.spMin),
          PlanCta(
            label: 'See ALRT + Individual',
            identity: PlanIdentity.individual,
            onPressed: () => context.push(
              AlrtPlusPaywallScreen.route,
              extra: const AlrtPlusPaywallArgs(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupCard(final GroupAccess g) {
    final s = g.sponsorship;
    final String line;
    final PlanIdentity? identity = s == null ? null : PlanIdentity.of(s.tier);
    if (g.fundingMode == GroupFundingMode.sponsored && s != null && s.live) {
      final who = s.youPay ? 'you' : (s.coveredBy ?? 'the group\'s payer');
      line = 'Covered by $who. ${planTierName(s.tier)} plan, '
          '${g.peopleCount} of ${g.capacity ?? sponsoredCapacity(s.tier)} '
          'people.';
    } else if (g.fundingMode == GroupFundingMode.sponsored) {
      line = 'This group\'s plan has ended. Check-ins, SOS and Journey are '
          'paused here until it is renewed or the host changes how the '
          'group is paid for.';
    } else if (g.connectionAllowed) {
      line = 'Funded by Individual. Your Individual plan covers you here.';
    } else {
      line = 'Funded by Individual. You need Individual or its trial to take '
          'part here.';
    }
    return PaywallCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  g.name,
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (identity != null) PlanBadge(identity: identity),
            ],
          ),
          SizedBox(height: 6.spMin),
          PaywallFinePrint(line),
          if (g.isHost && !g.isSponsoredAndLive)
            TextButton(
              onPressed: () => context.push(
                AlrtPlusGroupPaywallScreen.route,
                extra: AlrtPlusGroupPaywallArgs(circleId: g.circleId),
              ),
              child: const Text('Cover this group'),
            ),
        ],
      ),
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
