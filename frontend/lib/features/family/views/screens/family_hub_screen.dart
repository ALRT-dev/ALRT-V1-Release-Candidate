import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/utils/check_in_roll.dart';
import 'package:hazard_app/features/family/utils/family_sos_authorization.dart';
import 'package:hazard_app/features/family/utils/family_hub_labels.dart';
import 'package:hazard_app/features/family/views/screens/family_group_settings_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_switch_group_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_check_in_roll_call_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_lists_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_group_paused_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_journey_screen.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/views/screens/family_circle_profile_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_invite_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_places_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sharing_level_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_receiver_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_resolved_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_screen.dart';
import 'package:hazard_app/features/family/views/screens/shared_journey_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_consent_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_requests_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_choose_circle_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/features/family/views/widgets/family_ask_check_in_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_actions.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_avatar.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';
import 'package:hazard_app/features/family/views/widgets/family_leave_confirm_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_details_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_list_item.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/providers/live_connection_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/subscription/views/widgets/billing_issue_banner.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_surface_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

/// The family hub: status banner, one-tap "I'm Safe", check-in requests and
/// the member list. Embedded as the Family tab body.
class FamilyHubScreen extends ConsumerStatefulWidget {
  const FamilyHubScreen({super.key});

  static const route = '/family-hub';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilyHubScreenState();
}

class _FamilyHubScreenState extends ConsumerState<FamilyHubScreen> {
  @override
  Widget build(BuildContext context) {
    _listenToActionErrors();

    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    if (circle == null) return const SizedBox.shrink();

    final memberIdsNearAlert = ref.watch(
      providerOfFamily.select((s) => s.memberIdsNearAlert),
    );
    final activeSosEvents = ref.watch(
      providerOfFamily.select((s) => s.activeSosEvents),
    );
    final checkInState = ref.watch(
      providerOfFamily.select((s) => s.checkInState),
    );
    final sharedJourneys = ref
        .watch(providerOfFamily.select((s) => s.sharedJourneys))
        .where((j) => j.isActive)
        .toList();

    return Scaffold(
      // The prototype's lavender page in light mode; the app's dark
      // scaffold in dark mode.
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? context.surfaceScaffold
          : FamilyColors.v31Page,
      body: RefreshIndicator(
        onRefresh: () => ref.read(providerOfFamily.notifier).load(silent: true),
        color: FamilyColors.indigo,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _headerBuilder(circle),
            const SliverToBoxAdapter(child: BillingIssueBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.spMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final sos in activeSosEvents) ...[
                      _sosBannerBuilder(sos),
                      SizedBox(height: 12.spMin),
                    ],
                    if (circle.hostTransitionActive) ...[
                      _hostTransitionBannerBuilder(circle),
                      SizedBox(height: 12.spMin),
                    ],
                    for (final journey in sharedJourneys) ...[
                      _sharedJourneyCardBuilder(journey),
                      SizedBox(height: 12.spMin),
                    ],
                    _checkInRequestBannerBuilder(circle, checkInState),
                    _checkInCardBuilder(circle, checkInState),
                    SizedBox(height: 10.spMin),
                    _quickTilesRowBuilder(),
                    SizedBox(height: 22.spMin),
                    _membersSectionBuilder(circle, memberIdsNearAlert),
                    SizedBox(height: 14.spMin),
                    _bottomActionsBuilder(circle),
                    SizedBox(height: 20.spMin),
                    _sosHistorySectionBuilder(circle),
                    SizedBox(height: 120.spMin),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The amber strip that says this circle needs a new host and opens the
  /// ways forward. Never implies SOS, check-ins or journeys have stopped —
  /// they haven't, for anyone, at any point in this window.
  Widget _hostTransitionBannerBuilder(final FamilyCircle circle) {
    return GestureDetector(
      onTap: _openHostTransitionScreen,
      child: Container(
        padding: EdgeInsets.all(13.spMin),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF0A030), Color(0xFFE08812)],
          ),
          borderRadius: BorderRadius.circular(16.spMin),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE08812).withValues(alpha: 0.3),
              blurRadius: 14.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30.spMin,
              height: 30.spMin,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.spMin),
              ),
              child: Icon(
                LucideIcons.pause,
                size: 16.spMin,
                color: const Color(0xFFE08812),
              ),
            ),
            SizedBox(width: 11.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circle.hostTransitionLocked
                        ? '${circle.name} needs a new host'
                        : '${circle.name} needs a new host soon',
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    circle.hostTransitionLocked
                        ? 'Invites and circle settings are locked until '
                              'then. SOS, check-ins and journeys still work'
                        : '${circle.hostTransitionDaysLeft ?? 7} days left '
                              'to choose one — everything else keeps working',
                    style: TextStyle(
                      fontSize: 10.5.spMin,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 16.spMin,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  /// A member is sharing a journey with the caller. This is the whole point
  /// of this card: before it existed, the only way to find out was catching
  /// the "shared with you" push notification the moment it landed — miss it
  /// or dismiss it, and there was no other way into the private viewer from
  /// the Family tab. Shows only what the backend actually returns (name,
  /// status, last-updated time) — never a destination, route, ETA or trail,
  /// since the journey model carries none of those.
  Widget _sharedJourneyCardBuilder(final FamilyJourney journey) {
    final label = journey.isLive ? 'Live journey' : 'Journey';
    final updatedAt = journey.createdAt;
    return GestureDetector(
      onTap: () => context.push(
        SharedJourneyScreen.route,
        extra: SharedJourneyScreenArgs(journeyId: journey.id),
      ),
      child: Container(
        padding: EdgeInsets.all(14.spMin),
        decoration: BoxDecoration(
          gradient: FamilyColors.headerGradient,
          borderRadius: BorderRadius.circular(16.spMin),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.navigation, color: Colors.white, size: 22.spMin),
            SizedBox(width: 10.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${journey.memberName} is sharing a $label with you',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.spMin),
                  Text(
                    [
                      '${journey.remaining.inMinutes} min left',
                      if (updatedAt != null) 'started ${timeago.format(updatedAt)}',
                    ].join(' · '),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 12.spMin,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: Colors.white, size: 20.spMin),
          ],
        ),
      ),
    );
  }

  /// The host-transition screen hands its host-side choices back as a pop
  /// result so the existing transfer sheet and delete flow stay the single
  /// owners of those actions.
  void _openHostTransitionScreen() async {
    final action = await context.push(FamilyGroupPausedScreen.route);
    if (!mounted) return;
    final circle = ref.read(providerOfFamily).circle;
    if (circle == null) return;
    switch (action) {
      case 'transfer':
        _showTransferHostingSheet(circle);
      case 'close':
        _confirmLeaveOrDelete(isOwner: true);
    }
  }

  /// The way out of the chip row: every group on one page, with its beacon
  /// and what it costs in seats.
  /// Whether live updates are arriving right now, said out loud. A dropped
  /// connection used to be invisible: the screen simply stopped changing
  /// and looked broken. Green "Live" while the socket is up; amber
  /// "Reconnecting" while it is down (and the hub refreshes itself every
  /// 30 s in the meantime, see FamilyProvider).
  Widget _livePillBuilder() {
    return Consumer(
      builder: (context, ref, _) {
        final isLive = ref.watch(providerOfLiveConnection);
        final dot = isLive ? const Color(0xFF6EE7A0) : const Color(0xFFFBBF24);
        return Semantics(
          label: isLive
              ? 'Live updates connected'
              : 'Live updates reconnecting',
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.spMin,
              vertical: 4.spMin,
            ),
            decoration: BoxDecoration(
              color: isLive
                  ? FamilyColors.safeGreen.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10.spMin),
              border: isLive
                  ? null
                  : Border.all(color: Colors.white.withValues(alpha: 0.55)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.spMin,
                  height: 6.spMin,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
                SizedBox(width: 5.spMin),
                Text(
                  isLive ? 'Live' : 'Reconnecting',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// The approved hub header, kept calm: the circle's picture and name
  /// (tap for "Choose a circle"), the members as a small avatar stack, the
  /// live pill and the menu, then one seat line with a bar. No status card,
  /// no buttons: what needs answering shows up as the ask card and the
  /// members' chips below, and the ways in and across live in the sheet.
  Widget _headerBuilder(final FamilyCircle circle) {
    return SliverToBoxAdapter(
      child: FamilyHeaderSurface(
        padding: EdgeInsets.fromLTRB(20.spMin, 0, 16.spMin, 18.spMin),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.spMin),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => showChooseCircleSheet(context, ref),
                      child: Row(
                        children: [
                          FamilyGroupAvatar(
                            name: circle.name,
                            photoUrl: circle.photoUrl,
                            themeColorHex: circle.themeColor,
                            size: 40.spMin,
                            borderColor: Colors.white.withValues(alpha: 0.45),
                            borderWidth: 1.8,
                          ),
                          SizedBox(width: 10.spMin),
                          Flexible(
                            child: Text(
                              circle.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.spMin,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.spMin),
                          Icon(
                            LucideIcons.chevronDown,
                            size: 20.spMin,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.spMin),
                  _avatarStackBuilder(circle),
                  _overflowMenuBuilder(circle),
                ],
              ),
              SizedBox(height: 12.spMin),
              _seatLineBuilder(circle),
            ],
          ),
        ),
      ),
    );
  }

  /// Up to three members as overlapping circles, then "+N". Tapping it
  /// scrolls nowhere: the list is right below.
  Widget _avatarStackBuilder(final FamilyCircle circle) {
    final members = circle.members;
    final shown = members.take(2).toList();
    final extra = members.length - shown.length;
    final size = 30.0;
    final step = 21.spMin;
    final width = step * (shown.length + (extra > 0 ? 1 : 0)) + 9.spMin;
    return SizedBox(
      width: width,
      height: size.spMin,
      child: Stack(
        children: [
          for (final (index, member) in shown.indexed)
            Positioned(
              left: step * index,
              child: Container(
                padding: EdgeInsets.all(1.5.spMin),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: FamilyMemberAvatar(
                  member: member,
                  size: size - 3,
                  showStatusDot: false,
                ),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: step * shown.length,
              child: Container(
                width: size.spMin,
                height: size.spMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Hosts: "2 of 8 seats used" with a bar and "you and guests are free";
  /// everyone else: who hosts, and that joining costs them nothing.
  /// Billing rules are unchanged; this only shows them.
  Widget _seatLineBuilder(final FamilyCircle circle) {
    final isOwner = circle.me?.role == FamilyRole.owner;
    if (!isOwner) {
      final host = circle.members
          .where((m) => m.role == FamilyRole.owner)
          .map((m) => m.name)
          .firstOrNull;
      return Row(
        children: [
          Expanded(
            child: Text(
              hostedByLine(host),
              style: TextStyle(
                fontSize: 12.5.spMin,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          _livePillBuilder(),
        ],
      );
    }
    final circles = ref.watch(providerOfFamily.select((s) => s.circles));
    final used = seatsUsedAcrossHostedCircles(circles).clamp(0, kFamilyMaxSeats);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.armchair, size: 14.spMin, color: Colors.white),
            SizedBox(width: 6.spMin),
            Expanded(
              child: Text(
                '$used of $kFamilyMaxSeats seats used',
                style: TextStyle(
                  fontSize: 12.5.spMin,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              'you and guests are free',
              style: TextStyle(
                fontSize: 11.5.spMin,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(width: 8.spMin),
            _livePillBuilder(),
          ],
        ),
        SizedBox(height: 7.spMin),
        ClipRRect(
          borderRadius: BorderRadius.circular(3.spMin),
          child: SizedBox(
            height: 5.spMin,
            child: LinearProgressIndicator(
              value: used / kFamilyMaxSeats,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFE879F9)),
            ),
          ),
        ),
      ],
    );
  }

  /// The two ways to grow the circle, at the end of the list where the
  /// approved design puts them: hosts add or join, everyone else joins or
  /// switches. Same flows as the "Choose a circle" sheet, nothing extra.
  Widget _bottomActionsBuilder(final FamilyCircle circle) {
    final isOwner = circle.me?.role == FamilyRole.owner;
    Widget button(final IconData icon, final String label, final VoidCallback onTap) {
      return Expanded(
        child: SizedBox(
          height: 48.spMin,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: FamilyColors.indigoDark,
              backgroundColor: context.surfaceCard,
              side: BorderSide(color: FamilyColors.indigo.withValues(alpha: 0.35)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.spMin),
              ),
            ),
            onPressed: onTap,
            icon: Icon(icon, size: 18.spMin),
            label: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.spMin, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    }

    return Row(
      spacing: 10.spMin,
      children: [
        if (isOwner)
          button(LucideIcons.userPlus, 'Add a person', () => context.push(FamilyInviteScreen.route)),
        button(LucideIcons.qrCode, 'Join with code', () => showJoinGroupSheet(context, ref)),
        if (!isOwner)
          button(LucideIcons.arrowLeftRight, 'Switch circle', () => showChooseCircleSheet(context, ref)),
      ],
    );
  }

  Widget _overflowMenuBuilder(final FamilyCircle circle) {
    final isOwner = circle.me?.role == FamilyRole.owner;
    return PopupMenuButton<String>(
      icon: Icon(LucideIcons.ellipsisVertical, color: Colors.white, size: 22.spMin),
      color: context.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      onSelected: (value) {
        switch (value) {
          case 'places':
            context.push(FamilyPlacesScreen.route);
          case 'sharing':
            context.push(FamilySharingLevelScreen.route);
          case 'profile':
            context.push(FamilyCircleProfileScreen.route);
          case 'circleSettings':
            context.push(FamilyGroupSettingsScreen.route);
          case 'switchGroups':
            context.push(FamilySwitchGroupScreen.route);
          case 'sosLists':
            context.push(FamilySosListsScreen.route);
          case 'transferHosting':
            _showTransferHostingSheet(circle);
          case 'stepBackAsHost':
            _confirmStepBackAsHost(circle);
          case 'leave':
            _confirmLeaveOrDelete(isOwner: isOwner);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'switchGroups',
          child: Text('Add, join or switch circles'),
        ),
        const PopupMenuItem(
          value: 'sosLists',
          child: Text('Who your SOS reaches'),
        ),
        const PopupMenuItem(value: 'places', child: Text('Places')),
        const PopupMenuItem(value: 'sharing', child: Text('My sharing level')),
        const PopupMenuItem(value: 'profile', child: Text('My circle profile')),
        // One destination for name, rules, picture and beacon colour.
        // Members can open it too: they see the circle's settings without
        // the controls, instead of a menu that hides where they live.
        const PopupMenuItem(
          value: 'circleSettings',
          child: Text('Circle settings'),
        ),
        if (isOwner)
          const PopupMenuItem(
            value: 'transferHosting',
            child: Text('Transfer hosting'),
          ),
        // Leaving without naming a successor starts a 7-day host-transition
        // window instead of deleting the circle — a real, separate choice
        // from "Delete circle" below, only offered when there's someone
        // left to keep the circle running for.
        if (isOwner && circle.members.length > 1)
          const PopupMenuItem(
            value: 'stepBackAsHost',
            child: Text('Step back as host'),
          ),
        PopupMenuItem(
          value: 'leave',
          child: Text(
            isOwner ? 'Delete circle' : 'Leave circle',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  /// Owner-only sheet (§29 TRANSFER): hand the circle to an eligible member.
  /// Ineligible members are shown greyed with the reason, never hidden.
  Future<void> _showTransferHostingSheet(final FamilyCircle circle) async {
    final candidates = await ref
        .read(providerOfFamily.notifier)
        .loadTransferCandidates();
    if (!mounted) return;
    if (candidates == null) {
      context.showErrorToast(
        message: 'Could not load members. Please try again.',
      );
      return;
    }
    if (candidates.candidates.isEmpty) {
      context.showErrorToast(
        message: 'Invite someone first — there is no one to hand the '
            'circle to yet.',
      );
      return;
    }

    final picked = await showModalBottomSheet<FamilyTransferCandidate>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.spMin)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.spMin, 20.spMin, 20.spMin, 12.spMin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transfer hosting',
                style: TextStyle(
                  fontSize: 17.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.spMin),
              Text(
                'The new host covers every invited member here with their '
                'own ALRT+ seats (guests and the host are free). You stay on '
                'as a member.',
                style: TextStyle(
                  fontSize: 12.5.spMin,
                  color: AppColors.mediumGrey,
                ),
              ),
              SizedBox(height: 8.spMin),
              ...candidates.candidates.map(
                (candidate) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  enabled: candidate.eligible,
                  onTap: candidate.eligible
                      ? () => Navigator.of(sheetContext).pop(candidate)
                      : null,
                  leading: CircleAvatar(
                    radius: 18.spMin,
                    backgroundColor: FamilyColors.indigo.withValues(
                      alpha: candidate.eligible ? 0.15 : 0.06,
                    ),
                    foregroundImage: candidate.profilePictureUrl != null
                        ? NetworkImage(candidate.profilePictureUrl!)
                        : null,
                    child: Text(
                      candidate.name.isEmpty
                          ? '?'
                          : candidate.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w700,
                        color: candidate.eligible
                            ? FamilyColors.indigo
                            : AppColors.grey,
                      ),
                    ),
                  ),
                  title: Text(
                    candidate.name,
                    style: TextStyle(
                      fontSize: 14.5.spMin,
                      fontWeight: FontWeight.w600,
                      color: candidate.eligible
                          ? Colors.black87
                          : AppColors.grey,
                    ),
                  ),
                  subtitle: candidate.eligible
                      ? null
                      : Text(
                          candidate.reason ?? 'Not eligible right now',
                          style: TextStyle(
                            fontSize: 11.5.spMin,
                            color: AppColors.grey,
                          ),
                        ),
                  trailing: candidate.eligible
                      ? Icon(
                          LucideIcons.chevronRight,
                          size: 18.spMin,
                          color: AppColors.grey,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;

    var confirmed = false;
    await showConfirmationSheet(
      context: context,
      title: 'Hand the circle to ${picked.name}?',
      description:
          'Everyone here moves onto ${picked.name}\'s ALRT+ seats and '
          'everything keeps working. You stay on as a member and use one of '
          'their seats; ${picked.name} uses none as the new host — only '
          'they can hand hosting back.',
      confirmButtonText: 'Transfer hosting',
      onPressedConfirm: (_, __) => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    final ok = await ref
        .read(providerOfFamily.notifier)
        .transferOwnership(newOwnerMemberId: picked.memberId);
    if (!mounted) return;
    ok
        ? context.showSuccessToast(
            message: '${picked.name} is now hosting this circle.',
          )
        : context.showErrorToast(
            message: 'Could not transfer hosting. Please try again.',
          );
  }

  Widget _sosBannerBuilder(final FamilySosEvent sos) {
    final name = sos.member?.displayName ?? 'A family member';
    // The same banner reads completely differently on the two phones:
    // the person IN SOS is being watched over, everyone else is being
    // asked to respond. Two-phone testing showed neither could tell
    // which side they were on. "Mine" is checked by user as well as
    // member id, because member ids differ per circle.
    final isMine = isSosMine(
      sos,
      myMemberId: ref.read(providerOfFamily).circle?.myMemberId,
      myUserId: ref.read(providerOfLoggedInUser)?.id,
    );
    return GestureDetector(
      onTap: () => context.push(
        FamilySosReceiverScreen.route,
        extra: FamilySosReceiverScreenArgs(sosEvent: sos),
      ),
      child: Container(
        padding: EdgeInsets.all(14.spMin),
        decoration: BoxDecoration(
          color: FamilyColors.sosRed,
          borderRadius: BorderRadius.circular(16.spMin),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.siren, color: Colors.white, size: 24.spMin),
            SizedBox(width: 10.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMine
                        ? (sos.isLive ? 'Your SOS is live' : 'Your SOS is active')
                        : '$name needs help · SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (sos.createdAt != null)
                    Text(
                      isMine
                          ? (sos.isLive
                                ? 'Your family can watch your movements · tap '
                                      'to update or stand down'
                                : 'Your family has been alerted · tap to stand '
                                      'down')
                          : 'Started ${timeago.format(sos.createdAt!)} · '
                                'tap to see them on the map and respond',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.spMin,
                      ),
                    ),
                  // Who has answered, on the banner itself. Replying used
                  // to leave no trace until you opened the SOS.
                  if (sos.responses.isNotEmpty) ...[
                    SizedBox(height: 6.spMin),
                    Text(
                      _sosResponseSummary(sos),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: Colors.white, size: 20.spMin),
          ],
        ),
      ),
    );
  }

  /// A one-line read of who has acknowledged an SOS, by name, newest
  /// last, with the most recent time. The sender reads this on their own
  /// banner: knowing WHO has seen it is the reassurance (product owner
  /// 2026-08-07), so it is never reduced to a bare count.
  String _sosResponseSummary(final FamilySosEvent sos) {
    final responding = sos.responses
        .where(
          (r) =>
              r.type == FamilySosResponseType.onMyWay ||
              r.type == FamilySosResponseType.called,
        )
        .map((r) => r.member?.displayName ?? 'Someone')
        .toList();
    final seen = sos.responses
        .where((r) => r.type == FamilySosResponseType.seen)
        .toList()
      ..sort((a, b) {
        final at = a.createdAt;
        final bt = b.createdAt;
        if (at == null || bt == null) return 0;
        return at.compareTo(bt);
      });
    final seenNames = seen.map((r) => r.member?.displayName ?? 'Someone');
    final latestSeenAt = seen.isEmpty ? null : seen.last.createdAt;

    final parts = <String>[
      if (responding.isNotEmpty) '${responding.join(', ')} responding',
      if (seen.isNotEmpty)
        'Seen by ${seenNames.join(', ')}'
            '${latestSeenAt != null ? ' · ${timeago.format(latestSeenAt)}' : ''}',
    ];
    return parts.join(' · ');
  }

  /// Retained SOS history: every stood-down SOS in this circle (last 30
  /// days), with who acknowledged it. Tapping opens the after-event record.
  /// The server never returns locations for these - who and when only.
  Widget _sosHistorySectionBuilder(final FamilyCircle circle) {
    final history = ref.watch(providerOfFamily.select((s) => s.sosHistory));
    if (history.isEmpty) return const SizedBox.shrink();
    final shown = history.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabelBuilder('Past SOS', count: history.length),
        SizedBox(height: 10.spMin),
        _cardBuilder(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (index, sos) in shown.indexed) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    indent: 56.spMin,
                    color: const Color(0xFFF0F0F2),
                  ),
                _sosHistoryRowBuilder(circle, sos),
              ],
            ],
          ),
        ),
        SizedBox(height: 20.spMin),
      ],
    );
  }

  Widget _sosHistoryRowBuilder(
    final FamilyCircle circle,
    final FamilySosEvent sos,
  ) {
    final isMine =
        sos.memberId == circle.myMemberId ||
        (sos.member?.user?.id != null &&
            sos.member?.user?.id == ref.read(providerOfLoggedInUser)?.id);
    final who = isMine ? 'Your SOS' : "${sos.member?.displayName ?? 'A member'}'s SOS";
    final endedAt = sos.resolvedAt ?? sos.createdAt;
    final seen = sos.responses
        .where((r) => r.type == FamilySosResponseType.seen)
        .map((r) => r.member?.displayName ?? 'Someone')
        .toList();
    final ack = seen.isEmpty
        ? 'Nobody acknowledged it'
        : 'Seen by ${seen.join(', ')}';

    return ListTile(
      onTap: () => context.push(
        FamilySosResolvedScreen.route,
        extra: FamilySosResolvedScreenArgs(
          event: sos,
          circleName: circle.name,
          recipientCount: circle.members.length - 1,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.spMin),
      leading: Container(
        width: 32.spMin,
        height: 32.spMin,
        decoration: const BoxDecoration(
          color: FamilyColors.sosRedLight,
          shape: BoxShape.circle,
        ),
        child: Icon(LucideIcons.siren, size: 16.spMin, color: FamilyColors.sosRed),
      ),
      title: Text(
        endedAt == null ? '$who · ended' : '$who · ended ${timeago.format(endedAt)}',
        style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        ack,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.spMin, color: AppColors.mediumGrey),
      ),
      trailing: Icon(Icons.chevron_right, size: 20.spMin, color: AppColors.grey),
    );
  }

  /// The one section label on this screen: indigo, uppercase, letter-spaced,
  /// with an optional count so a section says how much is in it.
  Widget _sectionLabelBuilder(final String title, {final int? count}) {
    return Text(
      count == null
          ? title.toUpperCase()
          : '${title.toUpperCase()} · $count',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13.spMin,
        fontWeight: FontWeight.w700,
        color: FamilyColors.v31Label,
        letterSpacing: 0.5,
      ),
    );
  }

  /// The one white card on this screen, so every section sits on the same
  /// surface instead of some floating loose on the grey.
  Widget _cardBuilder({
    required final Widget child,
    final EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(20.spMin),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Every check-in from this screen - answering someone's ask or a
  /// spontaneous "I'm Safe" - goes through the same consent sheet first
  /// (locked rule: location leaves a phone only by the owner's action).
  /// "Just check in" is the primary button; sharing a snapshot is the
  /// deliberate extra step, and dismissing the sheet sends nothing.
  Future<void> _checkInWithConsent(
    final BuildContext context,
    final WidgetRef ref, {
    final String? requesterName,
  }) async {
    final choice = await showCheckInConsentSheet(
      context,
      requesterName: requesterName,
      sharingLevel: ref.read(providerOfFamily).circle?.me?.sharingLevel,
    );
    if (choice == null || !context.mounted) return;
    await ref.read(providerOfFamily.notifier).checkIn(
          shareLocation:
              choice == CheckInConsentChoice.checkInAndShareLocation,
        );
  }

  /// Someone asked for a check-in - or you did. The two sides read
  /// completely differently: the person who ASKED is watching answers
  /// come in (a tracker, by name), the people asked are being asked to
  /// answer (one tap). Showing the requester their own green "I'm Safe"
  /// button was the single most confusing thing in two-phone testing.
  Widget _checkInRequestBannerBuilder(
    final FamilyCircle circle,
    final FamilyActionState checkInState,
  ) {
    final request = circle.latestCheckInRequest;
    if (request == null) return const SizedBox.shrink();

    final askedAt = request.createdAt;
    final iAsked = request.requestedById == circle.myMemberId;
    // An ask aimed at other people is not mine to answer (the server only
    // sends me those I am in, but a stale circle can still hold one).
    if (!iAsked && !request.isAimedAt(circle.myMemberId)) {
      return const SizedBox.shrink();
    }

    // The people asked answer on the check-in card below (it names who
    // is waiting); this amber card is the asker's tracker only.
    if (!iAsked) return const SizedBox.shrink();

    final roll = CheckInRoll.of(circle);

    // Who this ask is waiting on: its targets, or everyone but the asker.
    final asked = circle.members
        .where((m) => m.id != request.requestedById && request.isAimedAt(m.id))
        .toList();
    final outstanding = asked.where((m) => !roll.hasAnswered(m)).toList();
    final answered = asked.where(roll.hasAnswered).toList();

    // The requester's job ends when the last answer lands.
    if (iAsked && outstanding.isEmpty) return const SizedBox.shrink();

    final when = askedAt == null ? null : timeago.format(askedAt);
    final targeted = request.targetMemberIds.isNotEmpty;
    final title = targeted
        ? 'You asked ${namesLabel(asked.map((m) => m.name).toList())} to check in'
        : 'You asked everyone to check in';
    final detail = [
      if (when != null) when,
      if ((request.message ?? '').isNotEmpty) '"${request.message}"',
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(14.spMin),
          decoration: BoxDecoration(
            color: FamilyColors.amberLight,
            borderRadius: BorderRadius.circular(16.spMin),
            border: Border.all(color: FamilyColors.amber, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2.spMin),
                    child: Icon(
                      LucideIcons.bellRing,
                      size: 18.spMin,
                      color: FamilyColors.amber,
                    ),
                  ),
                  SizedBox(width: 10.spMin),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              if (detail.isNotEmpty) ...[
                SizedBox(height: 6.spMin),
                Padding(
                  padding: EdgeInsets.only(left: 28.spMin),
                  child: Text(
                    detail,
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ),
              ],
              ...[
                // The tracker: every person asked, by name, with their
                // answer or the lack of it. Never a bare count.
                SizedBox(height: 10.spMin),
                Padding(
                  padding: EdgeInsets.only(left: 28.spMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final member in answered)
                        _askAnswerRowBuilder(member, answered: true),
                      for (final member in outstanding)
                        _askAnswerRowBuilder(member, answered: false),
                    ],
                  ),
                ),
                SizedBox(height: 12.spMin),
                Padding(
                  padding: EdgeInsets.only(left: 28.spMin),
                  child: Wrap(
                    spacing: 8.spMin,
                    runSpacing: 8.spMin,
                    children: [
                      _askActionBuilder(
                        label:
                            'Nudge ${namesLabel(outstanding.map((m) => m.name).toList())}',
                        filled: true,
                        onTap: () => _nudge(outstanding, request),
                      ),
                      _askActionBuilder(
                        label: 'Cancel ask',
                        filled: false,
                        onTap: () => _cancelAsk(request),
                      ),
                      _askActionBuilder(
                        label: 'Details',
                        filled: false,
                        onTap: () =>
                            context.push(FamilyCheckInRollCallScreen.route),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.spMin),
      ],
    );
  }

  /// One line of the requester's tracker: "Tom answered · 2 min ago" with
  /// a green tick, or "Amy hasn't answered yet" with an amber clock.
  Widget _askAnswerRowBuilder(
    final FamilyMember member, {
    required final bool answered,
  }) {
    final last = member.lastCheckInAt;
    final text = answered
        ? '${member.name} answered${last == null ? '' : ' · ${timeago.format(last)}'}'
        : "${member.name} hasn't answered yet";
    return Padding(
      padding: EdgeInsets.only(bottom: 6.spMin),
      child: Row(
        children: [
          Container(
            width: 18.spMin,
            height: 18.spMin,
            decoration: BoxDecoration(
              color: answered ? FamilyColors.safeGreen : const Color(0xFFFBBF24),
              shape: BoxShape.circle,
            ),
            child: Icon(
              answered ? Icons.check : LucideIcons.clock,
              size: 11.spMin,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8.spMin),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: member.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: text.substring(member.name.length)),
                ],
              ),
              style: TextStyle(fontSize: 13.spMin, color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _askActionBuilder({
    required final String label,
    required final bool filled,
    required final VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 9.spMin),
        decoration: BoxDecoration(
          color: filled ? FamilyColors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(12.spMin),
          border: Border.all(color: FamilyColors.amber, width: 1.4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w800,
            color: filled ? Colors.white : FamilyColors.amber,
          ),
        ),
      ),
    );
  }

  /// A fresh ask to exactly the people still outstanding, with the same
  /// note. They are notified again; nobody who has answered is bothered.
  Future<void> _nudge(
    final List<FamilyMember> outstanding,
    final FamilyCheckInRequest request,
  ) async {
    if (outstanding.isEmpty) return;
    final sent = await ref.read(providerOfFamily.notifier).requestCheckIn(
          message: request.message,
          memberIds: outstanding.map((m) => m.id).toList(),
        );
    if (!mounted || !sent) return;
    context.showSuccessToast(
      message:
          'Nudged ${namesLabel(outstanding.map((m) => m.name).toList())}.',
    );
  }

  Future<void> _cancelAsk(final FamilyCheckInRequest request) async {
    var confirmed = false;
    await showConfirmationSheet(
      context: context,
      title: 'Cancel this check-in ask?',
      description: 'Nobody will be nagged about it any more.',
      confirmButtonText: 'Cancel ask',
      onPressedConfirm: (_, __) => confirmed = true,
    );
    if (!confirmed || !mounted) return;
    await ref.read(providerOfFamily.notifier).cancelCheckInRequest(request.id);
  }

  /// Who this Check in tap would actually be answering, as one short
  /// phrase ("Amy", "Amy and Tom", "Amy, Tom +2"), or null.
  String? _askersStillOwedAnAnswer(final FamilyCircle circle) {
    final names = circle.namesOwedMyCheckIn;
    return names.isEmpty ? null : askersLabel(names);
  }

  /// Answer every open ask in this circle, after the consent sheet.
  Future<void> _answerAsks(final FamilyCircle circle) => _checkInWithConsent(
        context,
        ref,
        requesterName: _askersStillOwedAnAnswer(circle),
      );

  /// The white card that holds the one Check in button. With asks open it
  /// leads with who is waiting (faces, names, how long ago, "View N
  /// requests"); with none it is the plain invitation. Either way the
  /// caption says location is optional, because the consent sheet comes
  /// next and nothing is sent until it is answered.
  Widget _checkInCardBuilder(
    final FamilyCircle circle,
    final FamilyActionState checkInState,
  ) {
    final asks = circle.checkInRequestsOwedByMe;
    final askers = circle.namesOwedMyCheckIn;
    final newest = asks.firstOrNull?.createdAt;
    final viewLabel = viewRequestsLabel(asks.length);
    final askerMembers = [
      for (final ask in asks)
        circle.members.where((m) => m.id == ask.requestedById).firstOrNull,
    ].nonNulls.toList();

    return Container(
      padding: EdgeInsets.fromLTRB(16.spMin, 16.spMin, 16.spMin, 12.spMin),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: const [
          BoxShadow(
            color: FamilyColors.v31CardShadow,
            blurRadius: 18.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (asks.isNotEmpty) ...[
            if (askerMembers.isNotEmpty) ...[
              Center(
                child: _askerFacesBuilder(
                  askerMembers,
                  extra: asks.length - askerMembers.length,
                ),
              ),
              SizedBox(height: 10.spMin),
            ],
          ],
          Text(
            checkInCardTitle(askers),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.spMin,
              fontWeight: FontWeight.w800,
              color: context.onSurface,
              height: 1.2,
            ),
          ),
          if (asks.isNotEmpty) ...[
            SizedBox(height: 4.spMin),
            Text(
              [
                if (newest != null) timeago.format(newest),
                'In ${circle.name}',
              ].join(' · '),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5.spMin, color: context.onSurfaceMuted),
            ),
            if (viewLabel != null)
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.spMin),
                    minimumSize: Size(0, 32.spMin),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => showCheckInRequestsSheet(
                    context,
                    onCheckIn: () => _answerAsks(circle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        viewLabel,
                        style: TextStyle(
                          fontSize: 13.5.spMin,
                          fontWeight: FontWeight.w700,
                          color: FamilyColors.indigo,
                        ),
                      ),
                      Icon(LucideIcons.chevronRight, size: 16.spMin, color: FamilyColors.indigo),
                    ],
                  ),
                ),
              ),
          ],
          SizedBox(height: asks.isNotEmpty && viewLabel != null ? 4.spMin : 12.spMin),
          _imSafeButtonBuilder(circle, checkInState),
          SizedBox(height: 8.spMin),
          Text(
            'Location sharing is optional',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5.spMin, color: context.onSurfaceMuted),
          ),
        ],
      ),
    );
  }

  /// The askers' faces, overlapping, then "+N" for any not in the list.
  Widget _askerFacesBuilder(
    final List<FamilyMember> members, {
    required final int extra,
  }) {
    final shown = members.take(3).toList();
    final more = extra + (members.length - shown.length);
    final size = 44.0;
    final step = 32.spMin;
    final width = step * (shown.length + (more > 0 ? 1 : 0)) + 12.spMin;
    return SizedBox(
      width: width,
      height: size.spMin,
      child: Stack(
        children: [
          for (final (index, member) in shown.indexed)
            Positioned(
              left: step * index,
              child: Container(
                padding: EdgeInsets.all(2.spMin),
                decoration: BoxDecoration(
                  color: context.surfaceCard,
                  shape: BoxShape.circle,
                ),
                child: FamilyMemberAvatar(
                  member: member,
                  size: size - 4,
                  showStatusDot: false,
                ),
              ),
            ),
          if (more > 0)
            Positioned(
              left: step * shown.length,
              child: Container(
                width: size.spMin,
                height: size.spMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FamilyColors.indigoLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.surfaceCard, width: 2),
                ),
                child: Text(
                  '+$more',
                  style: TextStyle(
                    color: FamilyColors.indigo,
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// The one action that matters most, and the only one that looks like it.
  ///
  /// Four identical outlined pills stacked down the page gave every action
  /// the same weight, so nothing led. "I'm Safe" now carries the green
  /// gradient and its own glow, and everything else drops to a compact tile.
  Widget _imSafeButtonBuilder(
    final FamilyCircle circle,
    final FamilyActionState checkInState,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // The approved mockup's bright green with DARK green text and icon:
        // dark ink on this gradient measures 7.6:1 at the light end and
        // 5.7:1 at the dark end (WCAG AA is 4.5:1). White text on the
        // previous mint→emerald pair measured 1.9:1 and 3.8:1, and dark
        // text on that pair's emerald end only 3.3:1, so the dark end is
        // the mockup's #22C887 rather than #059669. The button stays
        // bright; only the ink changed.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FamilyColors.safeBright, FamilyColors.safeBrightDeep],
        ),
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: [
          BoxShadow(
            color: FamilyColors.safeBright.withValues(alpha: 0.25),
            blurRadius: 14.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        height: 50.spMin,
        width: double.infinity,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: FamilyColors.safeInk,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.spMin),
            ),
          ),
          onPressed: checkInState.isLoading ? null : () => _answerAsks(circle),
          icon: checkInState.isLoading
              ? SizedBox(
                  width: 18.spMin,
                  height: 18.spMin,
                  child: const CircularProgressIndicator(
                    color: FamilyColors.safeInk,
                    strokeWidth: 2,
                  ),
                )
              : Icon(Icons.check_rounded, size: 20.spMin),
          label: Text(
            imSafeLabel(requesterNames: circle.namesOwedMyCheckIn),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  /// The supporting actions, as a row of compact tiles.
  ///
  /// SOS used to sit at the very bottom of the page as an outlined button,
  /// below the whole member list. It is the most urgent thing here, so it
  /// takes the red gradient and comes up to the top with the others.
  Widget _quickTilesRowBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final journey = ref.watch(
          providerOfFamily.select((s) => s.activeJourney),
        );
        final scheduledCount = ref.watch(
          providerOfFamily.select((s) => s.scheduledCheckIns.length),
        );
        final isSharing = journey != null && journey.isActive;

        final tiles = <Widget>[
              _quickTileBuilder(
                icon: LucideIcons.bellRing,
                // "Ask": this tile asks OTHERS to check in. The one control
                // that checks YOU in is the big green button above it.
                label: 'Ask',
                tint: const Color(0xFFE8F4FF),
                // 1D7FE0 on the tint is ~4.6:1, the old 4DA8FF was ~2.6:1.
                ink: const Color(0xFF1D7FE0),
                // Everyone, or exactly the people you pick: the sheet names
                // who will be asked before anything is sent, and the
                // tracker card above shows the answers as they land.
                onTap: () => showFamilyAskCheckInSheet(context, ref),
              ),
              _quickTileBuilder(
                icon: LucideIcons.navigation,
                label: isSharing
                    ? '${journey.remaining.inMinutes} min'
                    : 'Journey',
                tint: const Color(0xFFF5E9FA),
                ink: const Color(0xFF9C27B0),
                isLit: isSharing,
                onTap: () => context.push(FamilyJourneyScreen.route),
              ),
              _quickTileBuilder(
                icon: LucideIcons.clock,
                label: scheduledCount == 0 ? 'Daily' : '$scheduledCount daily',
                tint: const Color(0xFFFFF3E8),
                ink: const Color(0xFFE05A00),
                isLit: scheduledCount > 0,
                // Lands on the check-in times, not on the nickname field.
                onTap: () => context.push(
                  FamilyCircleProfileScreen.route,
                  extra: const FamilyCircleProfileArgs(
                    section: FamilyProfileSection.dailyCheckIn,
                  ),
                ),
              ),
              _sosTileBuilder(),
            ];

        // Four across up to a modest text scale; two rows of two past it,
        // so "Check-in" and "Journey" never clip at the large text sizes
        // the app allows.
        final stacked = useStackedQuickTiles(
          MediaQuery.textScalerOf(context).scale(1.0),
        );
        if (!stacked) {
          return Row(
            spacing: 8.spMin,
            children: [for (final tile in tiles) Expanded(child: tile)],
          );
        }
        return Column(
          spacing: 8.spMin,
          children: [
            Row(
              spacing: 8.spMin,
              children: [
                Expanded(child: tiles[0]),
                Expanded(child: tiles[1]),
              ],
            ),
            Row(
              spacing: 8.spMin,
              children: [
                Expanded(child: tiles[2]),
                Expanded(child: tiles[3]),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _quickTileBuilder({
    required final IconData icon,
    required final String label,
    required final Color tint,
    required final Color ink,
    required final VoidCallback onTap,
    final bool isLit = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.spMin, horizontal: 4.spMin),
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: BorderRadius.circular(16.spMin),
          border: isLit ? Border.all(color: ink, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: context.cardShadow,
              blurRadius: 10.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34.spMin,
              height: 34.spMin,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(11.spMin),
              ),
              child: Icon(icon, size: 18.spMin, color: ink),
            ),
            SizedBox(height: 7.spMin),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w800,
                color: context.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sosTileBuilder() {
    return GestureDetector(
      onTap: () => context.push(FamilySosScreen.route),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.spMin, horizontal: 4.spMin),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF4B3E), Color(0xFFE01B0F), Color(0xFFB80000)],
            stops: [0.0, 0.55, 1.0],
          ),
          borderRadius: BorderRadius.circular(16.spMin),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE01B0F).withValues(alpha: 0.45),
              blurRadius: 18.0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34.spMin,
              height: 34.spMin,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.24),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                LucideIcons.siren,
                size: 17.spMin,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 7.spMin),
            Text(
              'SOS',
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }




  /// The member list, split by state instead of one flat list: who still
  /// owes a check-in sits on top with an Ask button per row, who has
  /// answered sits below. Both halves read from the same CheckInRoll as
  /// the header. With nobody outstanding it is one plain "Members" card.
  Widget _membersSectionBuilder(
    final FamilyCircle circle,
    final Set<String> memberIdsNearAlert,
  ) {
    final isOwner = circle.me?.role == FamilyRole.owner;
    // Guests never request locations, so they never see the affordance.
    final iAmGuest = circle.me?.role == FamilyRole.guest;
    final roll = CheckInRoll.of(circle);

    Widget rowFor(final FamilyMember member) {
      final isMe = member.id == circle.myMemberId;
      final isNearAlert = memberIdsNearAlert.contains(member.id);
      final hasAnswered = roll.hasAnswered(member);
      final canAsk = !isMe && !hasAnswered;
      final canRequest = !iAmGuest && !isMe;
      return FamilyMemberListItem(
        member: member,
        isMe: isMe,
        isNearAlert: isNearAlert,
        hasAnswered: hasAnswered,
        askedAt: roll.askedAt,
        // Every action on a person — ask, request, and the host's remove —
        // sits in one visible sheet, permission-checked here. Nothing is
        // long-press-only any more.
        onTap: () => showFamilyMemberDetailsSheet(
          context,
          member: member,
          isMe: isMe,
          isNearAlert: isNearAlert,
          hasAnswered: hasAnswered,
          askedAt: roll.askedAt,
          onAskToCheckIn: canAsk ? () => _askMemberToCheckIn(member) : null,
          onRequestLocation:
              canRequest ? () => _requestLocationSnapshot(member) : null,
          onChangeMySharing: isMe
              ? () => context.push(FamilySharingLevelScreen.route)
              : null,
          onRemove: isOwner && !isMe ? () => _confirmRemoveMember(member) : null,
        ),
        onAskToCheckIn: canAsk ? () => _askMemberToCheckIn(member) : null,
      );
    }

    Widget card(final List<FamilyMember> members) {
      return _cardBuilder(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (final (index, member) in members.indexed) ...[
              if (index > 0)
                Divider(
                  height: 1,
                  indent: 70.spMin,
                  color: context.outline.withValues(alpha: 0.5),
                ),
              rowFor(member),
            ],
          ],
        ),
      );
    }

    // Waiting members first, then everyone who has checked in: one list,
    // the chips say who is which (approved design), no second heading.
    final ordered = [...roll.notYet, ...roll.checkedIn];
    final long = ordered.length > 6;
    final visible = long ? ordered.take(5).toList() : ordered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Members',
                style: TextStyle(
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w800,
                  color: context.onSurface,
                ),
              ),
            ),
            if (long)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: FamilyColors.indigo,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => context.push(FamilyCheckInRollCallScreen.route),
                child: Text(
                  'View all',
                  style: TextStyle(fontSize: 12.5.spMin, fontWeight: FontWeight.w700),
                ),
              ),
            if (!iAmGuest && circle.members.length > 1)
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: FamilyColors.indigo,
                  padding: EdgeInsets.symmetric(horizontal: 8.spMin),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _requestEveryoneLocation(circle),
                icon: Icon(LucideIcons.mapPin, size: 16.spMin),
                label: Text(
                  'Request location',
                  style: TextStyle(fontSize: 12.5.spMin, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.spMin),
        card(visible),
      ],
    );
  }

  /// "Ask" on one row: a check-in request to THAT person only. Nobody
  /// else is notified or sees it as owed.
  Future<void> _askMemberToCheckIn(final FamilyMember member) async {
    final sent = await ref
        .read(providerOfFamily.notifier)
        .requestCheckIn(memberIds: [member.id]);
    if (!mounted || !sent) return;
    context.showSuccessToast(
      message: '${member.name} has been asked to check in.',
    );
  }

  Future<void> _requestLocationSnapshot(final FamilyMember member) async {
    final sent = await ref
        .read(providerOfFamily.notifier)
        .requestMemberLocation(memberId: member.id);
    if (!mounted) return;
    if (sent) {
      context.showSuccessToast(
        message:
            '${member.name} has been asked to share a one-time snapshot.',
      );
    }
  }

  /// Asks the whole group at once — each member still gets their own
  /// request and their own consent prompt, this only sends every ask in
  /// one tap instead of one per member.
  Future<void> _requestEveryoneLocation(final FamilyCircle circle) async {
    final memberIds = circle.members
        .where((member) => member.id != circle.myMemberId)
        .map((member) => member.id)
        .toList();
    if (memberIds.isEmpty) return;

    final failed = await ref
        .read(providerOfFamily.notifier)
        .requestMembersLocation(memberIds: memberIds);
    if (!mounted) return;

    final askedCount = memberIds.length - failed.length;
    if (askedCount > 0) {
      context.showSuccessToast(
        message: askedCount == memberIds.length
            ? 'Everyone has been asked to share a one-time snapshot.'
            : '$askedCount of ${memberIds.length} have been asked to share a one-time snapshot.',
      );
    }
  }

  void _confirmRemoveMember(final FamilyMember member) {
    showConfirmationSheet(
      context: context,
      title: 'Remove ${member.name} from the circle?',
      confirmButtonText: 'Remove',
      onPressedConfirm: (_, __) => ref
          .read(providerOfFamily.notifier)
          .removeMember(memberId: member.id),
    );
  }

  /// The owner leaving without naming a successor first: the circle stays
  /// active for everyone else, with a 7-day window for an eligible member
  /// to take over before invites and settings lock. A real alternative to
  /// deleting the circle outright, and worded so the two are never confused.
  Future<void> _confirmStepBackAsHost(final FamilyCircle circle) async {
    await showConfirmationSheet(
      context: context,
      title: 'Step back as host of ${circle.name}?',
      description:
          "You'll leave the circle. Everyone else keeps SOS, check-ins, "
          'journeys and the member list. An eligible member has 7 days '
          "to take over hosting; if nobody does, invites and circle "
          "settings lock, but nothing else changes and nobody is removed.",
      confirmButtonText: 'Step back',
      onPressedConfirm: (_, __) => ref.read(providerOfFamily.notifier).leave(),
    );
  }

  Future<void> _confirmLeaveOrDelete({required final bool isOwner}) async {
    // Deleting a circle for everyone is a different decision from leaving
    // one, so it keeps the plain destructive confirmation.
    if (isOwner) {
      showConfirmationSheet(
        context: context,
        title: 'Delete this circle for everyone?',
        confirmButtonText: 'Delete',
        onPressedConfirm: (_, __) =>
            ref.read(providerOfFamily.notifier).deleteCircle(),
      );
      return;
    }

    final state = ref.read(providerOfFamily);
    final circleName = state.circle?.name ?? 'this circle';
    final myMemberId = state.circle?.myMemberId;
    // How many of your own SOS lists you drop off by leaving.
    final sosListCount = myMemberId == null
        ? 0
        : state.sosLists
              .where((list) => list.memberIds.contains(myMemberId))
              .length;

    final shouldLeave = await showFamilyLeaveConfirmSheet(
      context: context,
      circleName: circleName,
      sosListCount: sosListCount,
    );
    if (!shouldLeave || !mounted) return;

    await ref.read(providerOfFamily.notifier).leave();
  }

  void _listenToActionErrors() {
    void listenTo(
      FamilyActionState Function(FamilyProviderState) selector,
    ) {
      ref.listen(providerOfFamily.select(selector), (prev, next) {
        if (prev != next && next.isError && next.error != null) {
          context.showErrorToast(message: next.error!.message);
        }
      });
    }

    listenTo((s) => s.checkInState);
    // The one confirmation after the one control: "Checked in".
    ref.listen(providerOfFamily.select((s) => s.checkInState), (prev, next) {
      if (prev != next && next.isSuccess) {
        context.showSuccessToast(message: 'Checked in');
      }
    });
    listenTo((s) => s.requestCheckInState);
    listenTo((s) => s.leaveDeleteState);
    listenTo((s) => s.memberUpdateState);
  }
}
