import 'package:hazard_app/features/subscription/views/widgets/access_refusal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/utils/check_in_roll.dart';
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
import 'package:hazard_app/features/family/views/screens/family_past_sos_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_places_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sharing_level_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_screen.dart';
import 'package:hazard_app/features/family/views/screens/shared_journey_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_widgets.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_consent_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_choose_circle_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_ask_check_in_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_actions.dart';
import 'package:hazard_app/features/family/views/widgets/family_leave_confirm_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_details_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_list_item.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/providers/live_connection_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_plan_and_cover_screen.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_surface_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

/// The family hub (approved Family board, 12 Oct 2026 mockup): the state
/// header, the one Check in button, Ask / Journey / Daily, the SOS card,
/// the member list and the "More" card. Embedded as the Family tab body.
/// FamilySosStrip renders above it, in home.
class FamilyHubScreen extends ConsumerStatefulWidget {
  const FamilyHubScreen({super.key});

  static const route = '/family-hub';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilyHubScreenState();
}

/// How this group is paid for, as the header says it.
enum _Coverage { notCovered, groupPlan, ownPlan }

class _FamilyHubScreenState extends ConsumerState<FamilyHubScreen> {
  /// The "MEMBERS" label takes the V3.1 prototype's brighter section-label
  /// orange (board exception to the #B84500 default).
  static const _membersLabelOrange = Color(0xFFFF6B01);

  /// The peach notice card for a group with no plan (the boards' #FFF4EE).
  static const _noticeCream = Color(0xFFFFF4EE);

  /// The light teal behind the asker's check-in tracker.
  static const _tealWash = Color(0xFFE6F7F5);

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
    // Who is covered and how: GET /api/access, never decided on the phone.
    // Null while it loads or when ALRT cannot be reached.
    final access = ref.watch(providerOfAccess).asData?.value;
    final coverage = _coverageOf(circle, access);

    final roll = CheckInRoll.of(circle);
    final isAskedOfMe = roll.isAskedOf(circle.myMemberId);

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
            _headerBuilder(
              circle,
              coverage: coverage,
              access: access,
              isAskedOfMe: isAskedOfMe,
              isSosActive: activeSosEvents.isNotEmpty,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.spMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A running SOS is announced by FamilySosStrip above
                    // every home tab (Family-SOSLive board): the header
                    // turns red and the member row carries the SOS pill,
                    // so the hub adds no second banner of its own.
                    if (circle.hostTransitionActive) ...[
                      _hostTransitionBannerBuilder(circle),
                      SizedBox(height: 12.spMin),
                    ],
                    // The boards' order above the Check in card: the ask
                    // owed by me, the asker's tracker, shared journeys,
                    // then the uncovered-group note.
                    if (isAskedOfMe) ...[
                      _askedOfMeCardBuilder(circle),
                      SizedBox(height: 12.spMin),
                    ],
                    _checkInRequestBannerBuilder(circle, checkInState),
                    for (final journey in sharedJourneys) ...[
                      _sharedJourneyCardBuilder(journey),
                      SizedBox(height: 12.spMin),
                    ],
                    if (coverage == _Coverage.notCovered) ...[
                      _coverageNoticeBuilder(circle, access),
                      SizedBox(height: 12.spMin),
                    ],
                    _checkInCardBuilder(circle, checkInState),
                    SizedBox(height: 12.spMin),
                    _quickTilesRowBuilder(),
                    SizedBox(height: 12.spMin),
                    _sosCardBuilder(),
                    SizedBox(height: 22.spMin),
                    _membersSectionBuilder(
                      circle,
                      roll,
                      memberIdsNearAlert: memberIdsNearAlert,
                      activeSosEvents: activeSosEvents,
                    ),
                    SizedBox(height: 22.spMin),
                    _moreSectionBuilder(circle, coverage: coverage, access: access),
                    SizedBox(height: 14.spMin),
                    _bottomActionsBuilder(circle),
                    SizedBox(height: 10.spMin),
                    Text(
                      'A location sent to your group is one moment, sent on '
                      'purpose. It expires after an hour.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.spMin,
                        height: 1.4,
                        color: context.onSurfaceMuted,
                      ),
                    ),
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

  // ── Header ─────────────────────────────────────────────────────────────

  /// Where this group's cover comes from, from GET /api/access. A live
  /// Family/Group plan covers everyone in it; otherwise my own ALRT +
  /// covers me; otherwise nothing does yet. Null access = unknown.
  _Coverage? _coverageOf(
    final FamilyCircle circle,
    final AccessSummary? access,
  ) {
    if (access == null) return null;
    final group = access.groupById(circle.id);
    if (group != null && group.isSponsoredAndLive) return _Coverage.groupPlan;
    if (access.personal.isIndividual) return _Coverage.ownPlan;
    return _Coverage.notCovered;
  }

  /// "Covered by ALRT + Family" / "Using your own ALRT +" / "Not covered
  /// yet", or null while coverage is unknown (never guessed).
  String? _coverageLine(
    final FamilyCircle circle,
    final _Coverage? coverage,
    final AccessSummary? access,
  ) => switch (coverage) {
    null => null,
    _Coverage.notCovered => 'Not covered yet',
    _Coverage.ownPlan => 'Using your own ALRT +',
    _Coverage.groupPlan =>
      'Covered by '
          '${_planName(access?.groupById(circle.id)?.sponsorship?.tier)}',
  };

  /// Plan names as the UI says them (never "Individual").
  static String _planName(final PlanTier? tier) => switch (tier) {
    PlanTier.group20 => 'ALRT + Group 20',
    PlanTier.group50 => 'ALRT + Group 50',
    PlanTier.family => 'ALRT + Family',
    PlanTier.individual || null => 'ALRT +',
  };

  /// The state header: group name with the switch-group chevron, the
  /// overflow menu, and ONE line of facts ("4 people · you host · Covered
  /// by ALRT + Family"). Indigo at rest, teal while a check-in is asked of
  /// me, red while any SOS is live. The Reconnecting pill shows only while
  /// the socket is down: a dead connection is never silent, and a live one
  /// needs no badge.
  Widget _headerBuilder(
    final FamilyCircle circle, {
    required final _Coverage? coverage,
    required final AccessSummary? access,
    required final bool isAskedOfMe,
    required final bool isSosActive,
  }) {
    final Gradient base;
    final Gradient highlight;
    if (isSosActive) {
      base = FamilyColors.sosHeaderGradient;
      highlight = FamilyColors.headerHighlight;
    } else if (isAskedOfMe) {
      base = FamilyColors.tealHeaderGradient;
      highlight = FamilyColors.tealHeaderHighlight;
    } else {
      base = FamilyColors.headerGradient;
      highlight = FamilyColors.headerHighlight;
    }

    final isOwner = circle.me?.role == FamilyRole.owner;
    final host = circle.members
        .where((m) => m.role == FamilyRole.owner)
        .map((m) => m.name)
        .firstOrNull;
    final coverageText = _coverageLine(circle, coverage, access);
    final subLine = [
      peopleLine(circle.members.length),
      if (isOwner)
        'you host'
      else if (host != null && host.isNotEmpty)
        'hosted by $host',
      if (coverageText != null) coverageText,
    ].join(' · ');

    return SliverToBoxAdapter(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: base),
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: highlight),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.spMin, 0, 16.spMin, 18.spMin),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.spMin),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => showChooseCircleSheet(context, ref),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  circle.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26.spMin,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.spMin),
                              Icon(
                                LucideIcons.chevronDown,
                                size: 22.spMin,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.spMin),
                      _overflowMenuBuilder(circle),
                    ],
                  ),
                  SizedBox(height: 6.spMin),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subLine,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.spMin,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.3,
                          ),
                        ),
                      ),
                      _reconnectingPillBuilder(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Amber "Reconnecting" while live updates are down (the hub refreshes
  /// itself every 30 s meanwhile, see FamilyProvider). Nothing while the
  /// socket is up.
  Widget _reconnectingPillBuilder() {
    return Consumer(
      builder: (context, ref, _) {
        final isLive = ref.watch(providerOfLiveConnection);
        if (isLive) return const SizedBox.shrink();
        return Semantics(
          label: 'Live updates reconnecting',
          child: Container(
            margin: EdgeInsets.only(left: 8.spMin),
            padding: EdgeInsets.symmetric(
              horizontal: 8.spMin,
              vertical: 4.spMin,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10.spMin),
              border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.spMin,
                  height: 6.spMin,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBBF24),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.spMin),
                Text(
                  'Reconnecting',
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

  /// The 36 px outlined-white rounded square that opens the group menu.
  Widget _overflowMenuBuilder(final FamilyCircle circle) {
    final isOwner = circle.me?.role == FamilyRole.owner;
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      tooltip: 'Group menu',
      color: context.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      onSelected: (value) {
        switch (value) {
          case 'sharing':
            context.push(FamilySharingLevelScreen.route);
          case 'profile':
            context.push(FamilyCircleProfileScreen.route);
          case 'circleSettings':
            context.push(FamilyGroupSettingsScreen.route);
          case 'switchGroups':
            context.push(FamilySwitchGroupScreen.route);
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
          child: Text('Add, join or switch groups'),
        ),
        const PopupMenuItem(value: 'sharing', child: Text('My sharing level')),
        const PopupMenuItem(value: 'profile', child: Text('My group profile')),
        // One destination for name, rules, picture and beacon colour.
        // Members can open it too: they see the group's settings without
        // the controls, instead of a menu that hides where they live.
        const PopupMenuItem(
          value: 'circleSettings',
          child: Text('Group settings'),
        ),
        if (isOwner)
          const PopupMenuItem(
            value: 'transferHosting',
            child: Text('Transfer hosting'),
          ),
        // Leaving without naming a successor starts a 7-day host-transition
        // window instead of deleting the group - a real, separate choice
        // from "Delete group" below, only offered when there's someone
        // left to keep the group running for.
        if (isOwner && circle.members.length > 1)
          const PopupMenuItem(
            value: 'stepBackAsHost',
            child: Text('Step back as host'),
          ),
        PopupMenuItem(
          value: 'leave',
          child: Text(
            isOwner ? 'Delete group' : 'Leave group',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
      child: Container(
        width: 36.spMin,
        height: 36.spMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.spMin),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.7),
            width: 1.5,
          ),
        ),
        child: Icon(
          LucideIcons.ellipsisVertical,
          color: Colors.white,
          size: 18.spMin,
        ),
      ),
    );
  }

  // ── Coverage ───────────────────────────────────────────────────────────

  /// The peach notice for a group nobody is paying for yet. Connection
  /// features are gated by the backend (402/409/422), never here; this
  /// just says so before the first refusal.
  Widget _coverageNoticeBuilder(
    final FamilyCircle circle,
    final AccessSummary? access,
  ) {
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: _noticeCream,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check in, Check on, SOS and Journey in this group need ALRT + '
            'for each person, or a plan covering the group.',
            style: TextStyle(
              fontSize: 13.spMin,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: AppColors.sectionLabel,
            ),
          ),
          SizedBox(height: 6.spMin),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openPlanAndCover(circle, access),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Plan and cover',
                  style: TextStyle(
                    fontSize: 13.5.spMin,
                    fontWeight: FontWeight.w800,
                    color: AppColors.sectionLabel,
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16.spMin,
                  color: AppColors.sectionLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "Plan and cover": this group's own plan screen (board PlanAndCover),
  /// which offers Cover this group, Everyone uses their own ALRT + or My
  /// plans from what GET /api/access says about the group.
  void _openPlanAndCover(
    final FamilyCircle circle,
    final AccessSummary? access,
  ) {
    context.push(AlrtPlusPlanAndCoverScreen.route, extra: circle.id);
  }

  // ── Banners kept from the previous hub ────────────────────────────────

  /// The amber strip that says this circle needs a new host and opens the
  /// ways forward. Never implies SOS, check-ins or journeys have stopped -
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
                              'to choose one. Everything else keeps working',
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
  /// the "shared with you" push notification the moment it landed - miss it
  /// or dismiss it, and there was no other way into the private viewer from
  /// the Family tab. Shows only what the backend actually returns (name,
  /// status, last-updated time) - never a destination, route, ETA or trail,
  /// since the journey model carries none of those.
  Widget _sharedJourneyCardBuilder(final FamilyJourney journey) {
    // The boards' white card with the indigo left edge: who, and how
    // often it updates. Nothing about where they are going.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(
        SharedJourneyScreen.route,
        extra: SharedJourneyScreenArgs(journeyId: journey.id),
      ),
      child: FamilyBoardCard(
        leftEdge: FamilyColors.indigo,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${journey.memberName} is sharing a journey',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.spMin),
                    Text(
                      journey.isLive ? 'Live' : 'Updates every 10 min',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 12.spMin,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: AppColors.mediumGrey,
                size: 20.spMin,
              ),
            ],
          ),
        ],
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
        message:
            'Invite someone first. There is no one to hand the '
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
                'The new host runs invites and group settings. How the group '
                'is paid for does not change, and you stay on as a member.',
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
          '${picked.name} will run invites and group settings. Everything '
          'keeps working, how the group is paid for does not change, and '
          'you stay on as a member. Only ${picked.name} can hand hosting '
          'back.',
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

  // ── Check in ───────────────────────────────────────────────────────────

  /// Every check-in from this screen - answering someone's ask or a
  /// spontaneous one - goes through the same consent sheet first (locked
  /// rule: location leaves a phone only by the owner's action). "Just
  /// check in" is the primary button; sharing a snapshot is the deliberate
  /// extra step; "I need help" is a needsHelp check-in without location;
  /// dismissing the sheet sends nothing.
  Future<void> _checkInWithConsent(
    final BuildContext context,
    final WidgetRef ref, {
    final String? requesterName,
  }) async {
    final choice = await showCheckInConsentSheet(
      context,
      requesterName: requesterName,
      sharingLevel: ref.read(providerOfFamily).circle?.me?.sharingLevel,
      offerNeedHelp: true,
    );
    if (choice == null || !context.mounted) return;
    await ref
        .read(providerOfFamily.notifier)
        .checkIn(
          status: choice == CheckInConsentChoice.needHelp
              ? FamilyCheckInStatus.needsHelp
              : FamilyCheckInStatus.safe,
          shareLocation: choice == CheckInConsentChoice.checkInAndShareLocation,
        );
  }

  /// "`<Name>` asked you to check in": the card the person ASKED sees, above
  /// the Check in button, with the ask's time and note. Check in opens the
  /// consent sheet; See who has opens the roll call.
  Widget _askedOfMeCardBuilder(final FamilyCircle circle) {
    final request =
        circle.checkInRequestOwedByMe ?? circle.latestCheckInRequest;
    if (request == null) return const SizedBox.shrink();
    final who = request.requestedBy?.displayName ??
        circle.members
            .where((m) => m.id == request.requestedById)
            .map((m) => m.name)
            .firstOrNull ??
        'Someone';
    // The time is on my own member row ("Asked to check in 12:04 PM");
    // the card carries only the asker's note, when there is one.
    final message = request.message ?? '';
    final detail = message.isEmpty ? '' : '"$message"';

    // The 4 px orange left edge is a strip inside the clipped card, not a
    // one-sided Border: a BoxDecoration refuses a radius with a border
    // whose sides differ in colour.
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: const [
          BoxShadow(
            color: FamilyColors.v31CardShadow,
            blurRadius: 18.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 5.spMin, color: AppColors.orange),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(14.spMin),
              child: _askedOfMeBodyBuilder(circle, who, detail),
            ),
          ),
        ],
      ),
    );
  }

  Widget _askedOfMeBodyBuilder(
    final FamilyCircle circle,
    final String who,
    final String detail,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$who asked you to check in',
          style: TextStyle(
            fontSize: 15.spMin,
            fontWeight: FontWeight.w700,
            color: context.onSurface,
          ),
        ),
        if (detail.isNotEmpty) ...[
          SizedBox(height: 4.spMin),
          Text(
            detail,
            style: TextStyle(
              fontSize: 12.5.spMin,
              color: context.onSurfaceMuted,
            ),
          ),
        ],
        SizedBox(height: 12.spMin),
        Wrap(
          spacing: 8.spMin,
          runSpacing: 8.spMin,
          children: [
            FamilyBoardSmallButton(
              label: 'Check in',
              onPressed: () => _answerAsks(circle),
            ),
            FamilyBoardSmallButton(
              label: 'See who has',
              onPressed: () => context.push(FamilyCheckInRollCallScreen.route),
            ),
          ],
        ),
      ],
    );
  }

  /// The white card with the one Check in button (indigo gradient, 54 px,
  /// approved board) and the caption that says location is optional,
  /// because the consent sheet comes next and nothing is sent until it is
  /// answered.
  Widget _checkInCardBuilder(
    final FamilyCircle circle,
    final FamilyActionState checkInState,
  ) {
    return Container(
      padding: EdgeInsets.all(16.spMin),
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
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: FamilyColors.headerGradient,
              borderRadius: BorderRadius.circular(16.spMin),
              boxShadow: [
                BoxShadow(
                  color: FamilyColors.indigo.withValues(alpha: 0.25),
                  blurRadius: 14.0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SizedBox(
              height: 54.spMin,
              width: double.infinity,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed:
                    checkInState.isLoading ? null : () => _answerAsks(circle),
                icon: checkInState.isLoading
                    ? SizedBox(
                        width: 18.spMin,
                        height: 18.spMin,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(LucideIcons.check, size: 20.spMin),
                label: Text(
                  'Check in',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.spMin),
          Text(
            'Tells your group you are okay. Sharing your location is '
            'optional.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.spMin,
              height: 1.4,
              color: context.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Ask / Journey / Daily ──────────────────────────────────────────────

  /// Three white tiles: Ask (asks OTHERS to check in; the one control that
  /// checks YOU in is the button above), Journey, and Daily (scheduled
  /// check-ins).
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

        return Row(
          spacing: 10.spMin,
          children: [
            Expanded(
              child: _quickTileBuilder(
                icon: LucideIcons.bell,
                label: 'Ask',
                // Everyone, or exactly the people you pick: the sheet names
                // who will be asked before anything is sent, and the
                // tracker card above shows the answers as they land.
                onTap: () => showFamilyAskCheckInSheet(context, ref),
              ),
            ),
            Expanded(
              child: _quickTileBuilder(
                icon: LucideIcons.navigation,
                label: isSharing
                    ? '${journey.remaining.inMinutes} min'
                    : 'Journey',
                isLit: isSharing,
                onTap: () => context.push(FamilyJourneyScreen.route),
              ),
            ),
            Expanded(
              child: _quickTileBuilder(
                icon: LucideIcons.clock,
                label: scheduledCount == 0 ? 'Daily' : '$scheduledCount daily',
                isLit: scheduledCount > 0,
                // Lands on the check-in times, not on the nickname field.
                onTap: () => context.push(
                  FamilyCircleProfileScreen.route,
                  extra: const FamilyCircleProfileArgs(
                    section: FamilyProfileSection.dailyCheckIn,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _quickTileBuilder({
    required final IconData icon,
    required final String label,
    required final VoidCallback onTap,
    final bool isLit = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80.spMin,
        padding: EdgeInsets.symmetric(horizontal: 4.spMin),
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: BorderRadius.circular(16.spMin),
          border: isLit
              ? Border.all(color: FamilyColors.indigo, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: context.cardShadow,
              blurRadius: 10.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24.spMin, color: context.onSurface),
            SizedBox(height: 8.spMin),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: FontWeight.w600,
                color: context.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SOS ────────────────────────────────────────────────────────────────

  /// The full-width SOS card. Tapping opens the SOS screen, where the
  /// 3-second hold, the recipients and the location choice live.
  Widget _sosCardBuilder() {
    return GestureDetector(
      onTap: () => context.push(FamilySosScreen.route),
      child: Container(
        padding: EdgeInsets.all(14.spMin),
        decoration: BoxDecoration(
          gradient: FamilyColors.sosHeaderGradient,
          borderRadius: BorderRadius.circular(18.spMin),
          boxShadow: [
            BoxShadow(
              color: FamilyColors.sosRed.withValues(alpha: 0.3),
              blurRadius: 18.0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.spMin,
              height: 44.spMin,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Icon(
                LucideIcons.siren,
                size: 22.spMin,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 16.spMin,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3.spMin),
                  Text(
                    'Hold 3 seconds. Reaches the people you chose. Runs for '
                    '1 hour, you can extend it. ALRT never contacts '
                    'emergency services.',
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.spMin),
            Icon(LucideIcons.chevronRight, color: Colors.white, size: 20.spMin),
          ],
        ),
      ),
    );
  }

  // ── Members ────────────────────────────────────────────────────────────

  /// The member list, one row per person, every row read from the same
  /// CheckInRoll as the header and footer. Waiting members first (only
  /// while an ask is open), then everyone else, then who has checked in.
  Widget _membersSectionBuilder(
    final FamilyCircle circle,
    final CheckInRoll roll, {
    required final Set<String> memberIdsNearAlert,
    required final List<FamilySosEvent> activeSosEvents,
  }) {
    final isOwner = circle.me?.role == FamilyRole.owner;
    // Guests never request locations, so they never see the affordance.
    final iAmGuest = circle.me?.role == FamilyRole.guest;

    Widget rowFor(final FamilyMember member) {
      final isMe = member.id == circle.myMemberId;
      final isNearAlert = memberIdsNearAlert.contains(member.id);
      final liveSos = activeSosEvents
          .where((sos) => sos.memberId == member.id)
          .firstOrNull;
      // "Waiting" and the teal ring only for a real, open ask; without one
      // a quiet member is simply not checked in today (never "waiting").
      final isAsked = roll.isAskedOf(member.id);
      final bool? hasAnswered = roll.hasAnswered(member)
          ? true
          : isAsked
              ? false
              : null;
      final canAsk = !isMe && !isAsked && hasAnswered != true && liveSos == null;
      final canRequest = !iAmGuest && !isMe;

      final Color? ringColor;
      if (liveSos != null) {
        ringColor = FamilyColors.sosRed;
      } else if (isAsked) {
        ringColor = FamilyColors.teal;
      } else {
        ringColor = null;
      }

      return FamilyMemberListItem(
        member: member,
        isMe: isMe,
        isNearAlert: isNearAlert,
        hasAnswered: hasAnswered,
        askedAt: isAsked ? roll.askedAt : null,
        liveSos: liveSos,
        ringColor: ringColor,
        // Every action on a person - ask, request, and the host's remove -
        // sits in one visible sheet, permission-checked here. Nothing is
        // long-press-only.
        onTap: () => showFamilyMemberDetailsSheet(
          context,
          member: member,
          isMe: isMe,
          isNearAlert: isNearAlert,
          hasAnswered: hasAnswered,
          askedAt: isAsked ? roll.askedAt : null,
          lastCheckIn: ref
              .read(providerOfFamily)
              .recentCheckIns
              .where((c) => c.memberId == member.id)
              .firstOrNull,
          onAskToCheckIn: canAsk ? () => _askMemberToCheckIn(member) : null,
          onRequestLocation: canRequest
              ? () => _requestLocationSnapshot(member)
              : null,
          onChangeMySharing: isMe
              ? () => context.push(FamilySharingLevelScreen.route)
              : null,
          onRemove: isOwner && !isMe
              ? () => _confirmRemoveMember(member)
              : null,
        ),
        onAskToCheckIn: canAsk ? () => _askMemberToCheckIn(member) : null,
      );
    }

    final ordered = [...roll.notYet, ...roll.notAsked, ...roll.checkedIn];
    final long = ordered.length > 6;
    final visible = long ? ordered.take(5).toList() : ordered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'MEMBERS',
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: _membersLabelOrange,
                ),
              ),
            ),
            if (long)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: FamilyColors.indigo,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () =>
                    context.push(FamilyCheckInRollCallScreen.route),
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.spMin),
        // One white card per person, as on the boards.
        for (final (index, member) in visible.indexed) ...[
          if (index > 0) SizedBox(height: 10.spMin),
          _cardBuilder(padding: EdgeInsets.zero, child: rowFor(member)),
        ],
      ],
    );
  }

  /// The two ways to grow the group, under the list: hosts add a person
  /// or join another group; everyone else joins or switches. Same flows as
  /// the "Choose a group" sheet, nothing extra.
  Widget _bottomActionsBuilder(final FamilyCircle circle) {
    final isOwner = circle.me?.role == FamilyRole.owner;
    Widget button(
      final IconData icon,
      final String label,
      final VoidCallback onTap,
    ) {
      return Expanded(
        child: SizedBox(
          height: 48.spMin,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: FamilyColors.indigoDark,
              backgroundColor: context.surfaceCard,
              side: BorderSide(
                color: FamilyColors.indigo.withValues(alpha: 0.35),
              ),
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
          button(
            LucideIcons.userPlus,
            'Add a person',
            () => context.push(FamilyInviteScreen.route),
          ),
        button(
          LucideIcons.qrCode,
          'Join with code',
          () => showJoinGroupSheet(context, ref),
        ),
        if (!isOwner)
          button(
            LucideIcons.arrowLeftRight,
            'Switch group',
            () => showChooseCircleSheet(context, ref),
          ),
      ],
    );
  }

  // ── More ───────────────────────────────────────────────────────────────

  /// The grouped "More" card: who my SOS reaches, places, plan and cover,
  /// past SOS. These replace the inline sections and menu rows they used
  /// to be.
  Widget _moreSectionBuilder(
    final FamilyCircle circle, {
    required final _Coverage? coverage,
    required final AccessSummary? access,
  }) {
    final rows = <Widget>[
      _moreRowBuilder(
        icon: LucideIcons.shieldAlert,
        label: 'Who my SOS reaches',
        onTap: () => context.push(FamilySosListsScreen.route),
      ),
      _moreRowBuilder(
        icon: LucideIcons.mapPin,
        label: 'Family places',
        onTap: () => context.push(FamilyPlacesScreen.route),
      ),
      _moreRowBuilder(
        icon: LucideIcons.star,
        label: 'Plan and cover',
        detail: _coverageLine(circle, coverage, access),
        onTap: () => _openPlanAndCover(circle, access),
      ),
      _moreRowBuilder(
        icon: LucideIcons.history,
        label: 'Past SOS',
        detail: 'Last 30 days',
        onTap: () => FamilyPastSosScreen.open(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabelBuilder('More'),
        SizedBox(height: 10.spMin),
        _cardBuilder(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (index, row) in rows.indexed) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    indent: 56.spMin,
                    color: context.outline.withValues(alpha: 0.5),
                  ),
                row,
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _moreRowBuilder({
    required final IconData icon,
    required final String label,
    required final VoidCallback onTap,
    final String? detail,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.spMin),
      leading: Container(
        width: 32.spMin,
        height: 32.spMin,
        decoration: BoxDecoration(
          color: FamilyColors.indigoLight,
          borderRadius: BorderRadius.circular(10.spMin),
        ),
        child: Icon(icon, size: 16.spMin, color: FamilyColors.indigo),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.5.spMin,
          fontWeight: FontWeight.w700,
          color: context.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (detail != null)
            Text(
              detail,
              style: TextStyle(
                fontSize: 12.5.spMin,
                color: context.onSurfaceMuted,
              ),
            ),
          Icon(
            LucideIcons.chevronRight,
            size: 20.spMin,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }

  /// Section labels on this screen (More): quiet uppercase, letter-spaced.
  Widget _sectionLabelBuilder(final String title) {
    return Text(
      title.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13.spMin,
        fontWeight: FontWeight.w700,
        color: _membersLabelOrange,
        letterSpacing: 0.8,
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
        borderRadius: BorderRadius.circular(18.spMin),
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
            color: _tealWash,
            borderRadius: BorderRadius.circular(16.spMin),
            border: Border.all(color: FamilyColors.teal, width: 1.5),
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
                      color: FamilyColors.teal,
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
              color: answered
                  ? FamilyColors.safeGreen
                  : FamilyColors.teal,
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
          color: filled ? FamilyColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(12.spMin),
          border: Border.all(color: FamilyColors.teal, width: 1.4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w800,
            color: filled ? Colors.white : FamilyColors.tealDeep,
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
    final sent = await ref
        .read(providerOfFamily.notifier)
        .requestCheckIn(
          message: request.message,
          memberIds: outstanding.map((m) => m.id).toList(),
        );
    if (!mounted || !sent) return;
    context.showSuccessToast(
      message: 'Nudged ${namesLabel(outstanding.map((m) => m.name).toList())}.',
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
        message: '${member.name} has been asked to share a one-time snapshot.',
      );
    }
  }

  void _confirmRemoveMember(final FamilyMember member) {
    showConfirmationSheet(
      context: context,
      title: 'Remove ${member.name} from the circle?',
      confirmButtonText: 'Remove',
      onPressedConfirm: (_, __) =>
          ref.read(providerOfFamily.notifier).removeMember(memberId: member.id),
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
          // A coded refusal (plan ended, ALRT + needed...) gets its own
          // sheet; anything else stays a toast.
          showFamilyActionError(context, ref, next.error!);
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
