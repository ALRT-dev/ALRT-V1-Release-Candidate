import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/utils/check_in_roll.dart';
import 'package:hazard_app/features/family/utils/group_state.dart';
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
import 'package:hazard_app/features/family/views/widgets/family_check_in_consent_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_ask_check_in_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_avatar.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';
import 'package:hazard_app/features/family/views/widgets/family_leave_confirm_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_list_item.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/providers/live_connection_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/subscription/views/widgets/billing_issue_banner.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:intl/intl.dart';
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

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      body: RefreshIndicator(
        onRefresh: () => ref.read(providerOfFamily.notifier).load(silent: true),
        color: FamilyColors.indigo,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _headerBuilder(circle, memberIdsNearAlert),
            _circleSwitcherBuilder(circle),
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
                    if (circle.isPaused) ...[
                      _pausedBannerBuilder(circle),
                      SizedBox(height: 12.spMin),
                    ],
                    _checkInRequestBannerBuilder(circle, checkInState),
                    _imSafeButtonBuilder(circle, checkInState),
                    SizedBox(height: 10.spMin),
                    _quickTilesRowBuilder(),
                    SizedBox(height: 12.spMin),
                    _addMemberCardBuilder(circle),
                    _setUpCardBuilder(),
                    SizedBox(height: 16.spMin),
                    _privacyBannerBuilder(),
                    SizedBox(height: 20.spMin),
                    _membersSectionBuilder(circle, memberIdsNearAlert),
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

  /// Your groups, as state tiles, not name chips: each says at a glance
  /// whether everyone is in, who is still owed ("2 of 3 · waiting on
  /// Amy"), or that an SOS is running there ("SOS live · Tom") - for the
  /// groups you do NOT have open as much as the one you do. Tapping a tile
  /// rescopes the whole family tab; the last tile opens the groups page.
  ///
  /// Shown from one group up, not two: with a single group the row was
  /// hidden entirely, which left the only path to creating another buried
  /// in the overflow menu. Being in one group is exactly when someone
  /// wants a second.
  Widget _circleSwitcherBuilder(final FamilyCircle circle) {
    final circles = ref.watch(providerOfFamily.select((s) => s.circles));
    if (circles.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final activeSos = ref.watch(
      providerOfFamily.select((s) => s.activeSosEvents),
    );

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(0, 12.spMin, 0, 12.spMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.spMin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionLabelBuilder('Your groups', count: circles.length),
                  GestureDetector(
                    onTap: () => context.push(FamilySwitchGroupScreen.route),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w700,
                        color: FamilyColors.indigo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.spMin),
            SizedBox(
              height: 66.spMin,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.spMin),
                scrollDirection: Axis.horizontal,
                // One extra slot: the tiles switch, the last one manages.
                itemCount: circles.length + 1,
                separatorBuilder: (_, _) => SizedBox(width: 8.spMin),
                itemBuilder: (context, index) {
                  if (index == circles.length) return _manageGroupsChipBuilder();
                  final summary = circles[index];
                  return _groupStateTileBuilder(
                    summary,
                    isSelected: summary.circleId == circle.id,
                    state: groupStateOf(
                      summary,
                      openCircle: circle,
                      activeSosEvents: activeSos,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupStateTileBuilder(
    final FamilyCircleSummary summary, {
    required final bool isSelected,
    required final GroupState state,
  }) {
    final Color ink;
    final Color background;
    final Color border;
    switch (state.kind) {
      case GroupStateKind.sos:
        ink = FamilyColors.sosRed;
        background = FamilyColors.sosRedLight;
        border = FamilyColors.sosRed;
      case GroupStateKind.waiting:
        ink = FamilyColors.amber;
        background = isSelected ? FamilyColors.indigoLight : FamilyColors.v31Page;
        border = isSelected ? FamilyColors.indigo : Colors.transparent;
      case GroupStateKind.allIn:
        ink = FamilyColors.safeGreen;
        background = isSelected ? FamilyColors.indigoLight : FamilyColors.v31Page;
        border = isSelected ? FamilyColors.indigo : Colors.transparent;
      case GroupStateKind.alone:
        ink = AppColors.grey;
        background = isSelected ? FamilyColors.indigoLight : FamilyColors.v31Page;
        border = isSelected ? FamilyColors.indigo : Colors.transparent;
    }
    return GestureDetector(
      onTap: () =>
          ref.read(providerOfFamily.notifier).selectCircle(summary.circleId),
      child: Container(
        width: 156.spMin,
        padding: EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 9.spMin),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(color: border, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 10.spMin,
                  height: 10.spMin,
                  decoration: BoxDecoration(
                    color: FamilyColors.beaconOf(summary.themeColor),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.spMin),
                if (summary.isOwned) ...[
                  Icon(LucideIcons.crown, size: 12.spMin, color: AppColors.grey),
                  SizedBox(width: 4.spMin),
                ],
                Expanded(
                  child: Text(
                    summary.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.spMin,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.spMin),
            Text(
              state.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The amber strip that says the group is paused and opens the ways
  /// forward. Renders only when the backend says so, which can only happen
  /// once billing is switched on.
  Widget _pausedBannerBuilder(final FamilyCircle circle) {
    return GestureDetector(
      onTap: _openPausedScreen,
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
                    '${circle.name} is paused',
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "${circle.pausedHostName ?? 'The host'}'s ALRT+ ended — "
                    'see what that means and the ways forward',
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

  /// The paused screen hands its host-side choices back as a pop result so
  /// the existing transfer sheet and delete flow stay the single owners of
  /// those actions.
  void _openPausedScreen() async {
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
  Widget _manageGroupsChipBuilder() {
    return GestureDetector(
      onTap: () => context.push(FamilySwitchGroupScreen.route),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.spMin),
        alignment: Alignment.center,
        height: 66.spMin,
        decoration: BoxDecoration(
          color: FamilyColors.v31Page,
          borderRadius: BorderRadius.circular(18.spMin),
          border: Border.all(color: FamilyColors.v31Border),
        ),
        child: Row(
          children: [
            Text(
              // Names the thing people come here for. A group can be made
              // any time and stands on its own until someone accepts.
              'Add or manage groups',
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: FontWeight.w700,
                color: FamilyColors.v31Ink,
              ),
            ),
            SizedBox(width: 4.spMin),
            Icon(
              LucideIcons.chevronRight,
              size: 14.spMin,
              color: FamilyColors.v31Ink,
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _headerBuilder(
    final FamilyCircle circle,
    final Set<String> memberIdsNearAlert,
  ) {
    // One roll for the title, the sentence and the chips, so the header
    // never says "waiting" over a list that says everyone is in.
    final roll = CheckInRoll.of(circle);
    final myId = circle.myMemberId;
    final notYetOthers =
        roll.notYet.where((m) => m.id != myId).map((m) => m.name).toList();
    final checkedInOthers =
        roll.checkedIn.where((m) => m.id != myId).map((m) => m.name).toList();
    final iAnswered = roll.checkedIn.any((m) => m.id == myId);
    final nearCount = memberIdsNearAlert.length;
    final allAccounted = roll.everyoneAccountedFor && nearCount == 0;

    final String title;
    if (allAccounted) {
      title = 'Everyone is accounted for';
    } else if (notYetOthers.isEmpty && !iAnswered) {
      title = 'Your check-in is owed';
    } else if (notYetOthers.isEmpty) {
      title = '$nearCount near an active alert';
    } else {
      title = waitingOnLabel(notYetOthers);
    }
    final sentence = [
      checkedInLabel(checkedInOthers, meIncluded: iAnswered),
      '${roll.checkedIn.length} of ${circle.members.length}',
      if (nearCount > 0) '$nearCount near an active alert',
    ].join(' · ');

    // Others first, then me, so the people you are waiting on lead.
    final chipMembers = [
      ...circle.members.where((m) => m.id != myId),
      ...circle.members.where((m) => m.id == myId),
    ];

    return SliverToBoxAdapter(
      // Uses the shared family header blend (FamilyColors.headerGradient +
      // headerHighlight) rather than the old flat two-stop indigo, so the
      // hub reads as the same purple/gradient family as ALRT+ instead of a
      // plain blue slab that made this the only rich header in the section.
      child: FamilyHeaderSurface(
        padding: EdgeInsets.fromLTRB(20.spMin, 0, 20.spMin, 24.spMin),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.spMin),
              Row(
                children: [
                  FamilyGroupAvatar(
                    name: circle.name,
                    photoUrl: circle.photoUrl,
                    themeColorHex: circle.themeColor,
                    size: 46.spMin,
                    borderColor: Colors.white.withValues(alpha: 0.45),
                    borderWidth: 1.8,
                  ),
                  SizedBox(width: 12.spMin),
                  Expanded(
                    child: Text(
                      circle.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.spMin,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _livePillBuilder(),
                  SizedBox(width: 4.spMin),
                  _overflowMenuBuilder(circle),
                ],
              ),
              SizedBox(height: 14.spMin),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.spMin),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.spMin),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40.spMin,
                          height: 40.spMin,
                          decoration: BoxDecoration(
                            color: allAccounted
                                ? FamilyColors.safeGreen
                                : FamilyColors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            allAccounted ? Icons.check : LucideIcons.clock,
                            color: Colors.white,
                            size: 22.spMin,
                          ),
                        ),
                        SizedBox(width: 12.spMin),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.spMin,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                sentence,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12.spMin,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (circle.members.length > 1) ...[
                      SizedBox(height: 12.spMin),
                      Wrap(
                        spacing: 6.spMin,
                        runSpacing: 6.spMin,
                        children: [
                          for (final member in chipMembers)
                            _memberStateChipBuilder(
                              member,
                              isMe: member.id == myId,
                              answered: roll.hasAnswered(member),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// One chip per member: "Tom · 8:10 am" in green when they have checked
  /// in on this roll, "Amy · not yet" outlined in amber when they have
  /// not. The names are the point - a count never told anyone who to ring.
  Widget _memberStateChipBuilder(
    final FamilyMember member, {
    required final bool isMe,
    required final bool answered,
  }) {
    final name = isMe ? 'You' : member.name;
    final last = member.lastCheckInAt;
    final String when;
    if (!answered) {
      when = 'not yet';
    } else if (last == null) {
      when = 'checked in';
    } else {
      final now = DateTime.now();
      final sameDay =
          last.year == now.year && last.month == now.month && last.day == now.day;
      when = sameDay ? DateFormat.jm().format(last) : timeago.format(last);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.spMin, vertical: 6.spMin),
      decoration: BoxDecoration(
        color: answered
            ? FamilyColors.safeGreen.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12.spMin),
        border: answered
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.spMin,
            height: 8.spMin,
            decoration: BoxDecoration(
              color: answered
                  ? const Color(0xFF6EE7A0)
                  : const Color(0xFFFBBF24),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.spMin),
          Text(
            '$name · $when',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// The one thing a new host needs first and previously could only find
  /// inside the overflow menu: adding people. Owner-only, because joiners
  /// use the OWNER's seats and the server refuses invites from anyone else.
  /// Opens the Family invite flow (code + QR + copy/send + revoke), which
  /// is deliberately separate from Profile's "Share ALRT".
  Widget _addMemberCardBuilder(final FamilyCircle circle) {
    if (circle.me?.role != FamilyRole.owner) return const SizedBox.shrink();
    final alone = circle.members.length <= 1;
    return Padding(
      padding: EdgeInsets.only(bottom: 16.spMin),
      child: GestureDetector(
        onTap: () => context.push(FamilyInviteScreen.route),
        child: Container(
          padding: EdgeInsets.all(14.spMin),
          decoration: BoxDecoration(
            color: alone ? FamilyColors.indigo : Colors.white,
            borderRadius: BorderRadius.circular(16.spMin),
            border: alone
                ? null
                : Border.all(color: FamilyColors.indigo.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: alone
                    ? FamilyColors.indigo.withValues(alpha: 0.3)
                    : FamilyColors.v31CardShadow,
                blurRadius: 12.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40.spMin,
                height: 40.spMin,
                decoration: BoxDecoration(
                  color: alone
                      ? Colors.white.withValues(alpha: 0.18)
                      : FamilyColors.indigoLight,
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
                child: Icon(
                  LucideIcons.userPlus,
                  size: 20.spMin,
                  color: alone ? Colors.white : FamilyColors.indigo,
                ),
              ),
              SizedBox(width: 12.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alone ? 'Add your first member' : 'Add member',
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w800,
                        color: alone ? Colors.white : AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2.spMin),
                    Text(
                      'Invite code or QR · joining is always free',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: alone
                            ? Colors.white.withValues(alpha: 0.85)
                            : AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18.spMin,
                color: alone ? Colors.white : FamilyColors.indigo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The three things people set up once and could not find: their own
  /// name and picture in the group, their daily check-in, and who their
  /// SOS reaches. All three were only in the overflow menu, which is why
  /// testers reported them missing (QA 2026-08-06).
  Widget _setUpCardBuilder() {
    return _cardBuilder(
      padding: EdgeInsets.symmetric(vertical: 4.spMin),
      child: Column(
        children: [
          _setUpRowBuilder(
            icon: LucideIcons.userRoundPen,
            label: 'My name & picture here',
            sub: 'What this group sees you as',
            onTap: () => context.push(
              FamilyCircleProfileScreen.route,
              extra: const FamilyCircleProfileArgs(),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 56.spMin,
            color: FamilyColors.v31Divider,
          ),
          _setUpRowBuilder(
            icon: LucideIcons.alarmClock,
            label: 'Daily check-in',
            sub: 'A reminder to say you are safe',
            onTap: () => context.push(
              FamilyCircleProfileScreen.route,
              extra: const FamilyCircleProfileArgs(
                section: FamilyProfileSection.dailyCheckIn,
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 56.spMin,
            color: FamilyColors.v31Divider,
          ),
          _setUpRowBuilder(
            icon: LucideIcons.siren,
            label: 'Who your SOS reaches',
            sub: 'Chosen in advance, across all your groups',
            onTap: () => context.push(FamilySosListsScreen.route),
          ),
        ],
      ),
    );
  }

  Widget _setUpRowBuilder({
    required final IconData icon,
    required final String label,
    required final String sub,
    required final VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.spMin),
      leading: Icon(icon, size: 20.spMin, color: FamilyColors.indigo),
      title: Text(
        label,
        style: TextStyle(fontSize: 14.5.spMin, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        sub,
        style: TextStyle(fontSize: 12.spMin, color: AppColors.mediumGrey),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20.spMin,
        color: AppColors.grey,
      ),
    );
  }

  Widget _overflowMenuBuilder(final FamilyCircle circle) {
    final isOwner = circle.me?.role == FamilyRole.owner;
    return PopupMenuButton<String>(
      icon: Icon(LucideIcons.ellipsisVertical, color: Colors.white, size: 22.spMin),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      onSelected: (value) {
        switch (value) {
          case 'places':
            context.push(FamilyPlacesScreen.route);
          case 'invite':
            context.push(FamilyInviteScreen.route);
          case 'sharing':
            context.push(FamilySharingLevelScreen.route);
          case 'profile':
            context.push(FamilyCircleProfileScreen.route);
          case 'groupSettings':
            _showGroupSettingsSheet(circle);
          case 'beacon':
            context.push(FamilyGroupSettingsScreen.route);
          case 'switchGroups':
            context.push(FamilySwitchGroupScreen.route);
          case 'sosLists':
            context.push(FamilySosListsScreen.route);
          case 'transferHosting':
            _showTransferHostingSheet(circle);
          case 'leave':
            _confirmLeaveOrDelete(isOwner: isOwner);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'switchGroups',
          child: Text('Add, join or switch groups'),
        ),
        const PopupMenuItem(
          value: 'sosLists',
          child: Text('Who your SOS reaches'),
        ),
        const PopupMenuItem(value: 'places', child: Text('Places')),
        // Owner-only: joiners consume the OWNER's paid seats, so nobody
        // may invite people into another payer's group (product owner
        // 2026-08-07). The server enforces the same rule.
        if (isOwner)
          const PopupMenuItem(value: 'invite', child: Text('Add member')),
        const PopupMenuItem(value: 'sharing', child: Text('My sharing level')),
        const PopupMenuItem(value: 'profile', child: Text('My circle profile')),
        if (isOwner)
          const PopupMenuItem(
            value: 'groupSettings',
            child: Text('Group name & rules'),
          ),
        if (isOwner)
          const PopupMenuItem(
            value: 'beacon',
            child: Text('Beacon colour'),
          ),
        if (isOwner)
          const PopupMenuItem(
            value: 'transferHosting',
            child: Text('Transfer hosting'),
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

  /// Owner-only sheet: group name + the locked rule toggles.
  Future<void> _showGroupSettingsSheet(final FamilyCircle circle) async {
    final nameController = TextEditingController(text: circle.name);
    var anyoneCanRequest = circle.anyoneCanRequestSnapshot;
    var sosWholeGroup = circle.sosToWholeGroup;
    var snapPointsOnly = circle.journeysSnapPointsOnly;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.spMin)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20.spMin,
            20.spMin,
            20.spMin,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20.spMin,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Group settings',
                style: TextStyle(
                  fontSize: 17.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.spMin),
              TextField(
                controller: nameController,
                maxLength: 50,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Group name',
                  counterText: '',
                ),
              ),
              SizedBox(height: 6.spMin),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeThumbColor: FamilyColors.indigo,
                value: anyoneCanRequest,
                onChanged: (value) =>
                    setSheetState(() => anyoneCanRequest = value),
                title: Text(
                  'Anyone can ask for a snapshot',
                  style: TextStyle(fontSize: 14.spMin),
                ),
                subtitle: Text(
                  'Off: only you can send location requests',
                  style: TextStyle(fontSize: 11.5.spMin),
                ),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeThumbColor: FamilyColors.indigo,
                value: sosWholeGroup,
                onChanged: (value) =>
                    setSheetState(() => sosWholeGroup = value),
                title: Text(
                  'SOS goes to the whole group',
                  style: TextStyle(fontSize: 14.spMin),
                ),
                subtitle: Text(
                  'Off: members are nudged to pick an SOS list',
                  style: TextStyle(fontSize: 11.5.spMin),
                ),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeThumbColor: FamilyColors.indigo,
                value: snapPointsOnly,
                onChanged: (value) =>
                    setSheetState(() => snapPointsOnly = value),
                title: Text(
                  'Journeys are snap points only',
                  style: TextStyle(fontSize: 14.spMin),
                ),
                subtitle: Text(
                  'Never a live trail — departure, ~10 min points, arrival',
                  style: TextStyle(fontSize: 11.5.spMin),
                ),
              ),
              SizedBox(height: 10.spMin),
              SizedBox(
                height: 48.spMin,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FamilyColors.indigo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                    ),
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(
                    'Save settings',
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final newName = nameController.text.trim();
    if (saved != true || !mounted) return;

    final ok = await ref.read(providerOfFamily.notifier).updateGroupSettings(
          name: newName.isEmpty || newName == circle.name ? null : newName,
          anyoneCanRequestSnapshot: anyoneCanRequest,
          sosToWholeGroup: sosWholeGroup,
          journeysSnapPointsOnly: snapPointsOnly,
        );
    if (!mounted) return;
    ok
        ? context.showSuccessToast(message: 'Group settings saved.')
        : context.showErrorToast(
            message: 'Could not save settings. Please try again.',
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
    final isMine =
        sos.memberId == ref.read(providerOfFamily).circle?.myMemberId ||
        (sos.member?.user?.id != null &&
            sos.member?.user?.id == ref.read(providerOfLoggedInUser)?.id);
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColorLight,
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

    final roll = CheckInRoll.of(circle);
    // Once you have checked in since the ask, it stops nagging.
    final me = circle.me;
    if (!iAsked && (me == null || roll.hasAnswered(me))) {
      return const SizedBox.shrink();
    }

    // Who this ask is waiting on: its targets, or everyone but the asker.
    final asked = circle.members
        .where((m) => m.id != request.requestedById && request.isAimedAt(m.id))
        .toList();
    final outstanding = asked.where((m) => !roll.hasAnswered(m)).toList();
    final answered = asked.where(roll.hasAnswered).toList();

    // The requester's job ends when the last answer lands.
    if (iAsked && outstanding.isEmpty) return const SizedBox.shrink();

    final who = request.requestedBy?.displayName ?? 'Someone';
    final when = askedAt == null ? null : timeago.format(askedAt);
    final targeted = request.targetMemberIds.isNotEmpty;
    final String title;
    if (iAsked) {
      title = targeted
          ? 'You asked ${namesLabel(asked.map((m) => m.name).toList())} to check in'
          : 'You asked everyone to check in';
    } else if (targeted) {
      title = '$who asked you to check in';
    } else {
      title = outstanding.length > 1
          ? '$who asked everyone to check in · ${outstanding.length} still to answer'
          : '$who asked everyone to check in';
    }
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
              if (iAsked) ...[
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
              ] else ...[
                SizedBox(height: 12.spMin),
                SizedBox(
                  height: 46.spMin,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FamilyColors.safeGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.spMin),
                      ),
                    ),
                    onPressed: checkInState.isLoading
                        ? null
                        : () => _checkInWithConsent(
                              context,
                              ref,
                              requesterName: who,
                            ),
                    icon: Icon(Icons.check, size: 20.spMin),
                    label: Text(
                      "I'm Safe · lets $who know",
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (!targeted) ...[
                  SizedBox(height: 4.spMin),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () =>
                          context.push(FamilyCheckInRollCallScreen.route),
                      child: Text(
                        "See who's answered",
                        style: TextStyle(
                          fontSize: 13.spMin,
                          fontWeight: FontWeight.w700,
                          color: FamilyColors.amber,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        SizedBox(height: 16.spMin),
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

  /// Who this "I'm Safe" tap would actually be answering, if anyone.
  String? _requesterNameStillOwedAnAnswer(final FamilyCircle circle) {
    final request = circle.checkInRequestOwedByMe;
    if (request == null) return null;
    return request.requestedBy?.displayName ?? 'Someone';
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF078551), Color(0xFF0FBE70)],
        ),
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12B476).withValues(alpha: 0.3),
            blurRadius: 20.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 50.spMin,
        width: double.infinity,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.spMin),
            ),
          ),
          onPressed: checkInState.isLoading
              ? null
              : () => _checkInWithConsent(
                    context,
                    ref,
                    requesterName: _requesterNameStillOwedAnAnswer(circle),
                  ),
          icon: checkInState.isLoading
              ? SizedBox(
                  width: 18.spMin,
                  height: 18.spMin,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(Icons.check_rounded, size: 20.spMin),
          label: Text(
            "I'm Safe",
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

        return Row(
          spacing: 8.spMin,
          children: [
            Expanded(
              child: _quickTileBuilder(
                icon: LucideIcons.bellRing,
                label: 'Check-in',
                tint: const Color(0xFFE8F4FF),
                // 1D7FE0 on the tint is ~4.6:1, the old 4DA8FF was ~2.6:1.
                ink: const Color(0xFF1D7FE0),
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
                tint: const Color(0xFFF5E9FA),
                ink: const Color(0xFF9C27B0),
                isLit: isSharing,
                onTap: () => context.push(FamilyJourneyScreen.route),
              ),
            ),
            Expanded(
              child: _quickTileBuilder(
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
            ),
            Expanded(child: _sosTileBuilder()),
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
        padding: EdgeInsets.symmetric(vertical: 12.spMin, horizontal: 4.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.spMin),
          border: isLit ? Border.all(color: ink, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: FamilyColors.v31CardShadow,
              blurRadius: 10.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30.spMin,
              height: 30.spMin,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(9.spMin),
              ),
              child: Icon(icon, size: 16.spMin, color: ink),
            ),
            SizedBox(height: 5.spMin),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.spMin,
                fontWeight: FontWeight.w800,
                color: FamilyColors.v31Ink,
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
        padding: EdgeInsets.symmetric(vertical: 12.spMin, horizontal: 4.spMin),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF4B3E), Color(0xFFE01B0F), Color(0xFFB80000)],
            stops: [0.0, 0.55, 1.0],
          ),
          borderRadius: BorderRadius.circular(14.spMin),
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
              width: 30.spMin,
              height: 30.spMin,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.24),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                LucideIcons.siren,
                size: 15.spMin,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5.spMin),
            Text(
              'SOS',
              style: TextStyle(
                fontSize: 10.spMin,
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




  Widget _privacyBannerBuilder() {
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border(
          left: BorderSide(color: FamilyColors.safeGreen, width: 3.spMin),
        ),
        boxShadow: [
          BoxShadow(color: AppColors.shadowColorLight, blurRadius: 2.0),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.shieldCheck,
            color: FamilyColors.safeGreen,
            size: 18.spMin,
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'ALRT never live-tracks. ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text:
                        'What you see is each member\'s last shared snapshot. '
                        'Ask for a fresh one anytime; they choose whether to '
                        'send it.',
                  ),
                ],
              ),
              style: TextStyle(
                fontSize: 12.spMin,
                height: 1.4,
                color: AppColors.black,
              ),
            ),
          ),
        ],
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
    final split = roll.notYet.isNotEmpty;

    Widget rowFor(final FamilyMember member) {
      final isMe = member.id == circle.myMemberId;
      return FamilyMemberListItem(
        member: member,
        isMe: isMe,
        isNearAlert: memberIdsNearAlert.contains(member.id),
        hasAnswered: roll.hasAnswered(member),
        askedAt: roll.askedAt,
        onLongPress: isOwner && !isMe ? () => _confirmRemoveMember(member) : null,
        onRequestLocation:
            !iAmGuest && !isMe ? () => _requestLocationSnapshot(member) : null,
        onAskToCheckIn: !isMe && !roll.hasAnswered(member)
            ? () => _askMemberToCheckIn(member)
            : null,
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
                  color: const Color(0xFFF0F0F2),
                ),
              rowFor(member),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabelBuilder(
              split ? 'Not yet checked in' : 'Members',
              count: split ? roll.notYet.length : circle.members.length,
            ),
            Row(
              children: [
                if (!iAmGuest && circle.members.length > 1)
                  TextButton(
                    onPressed: () => _requestEveryoneLocation(circle),
                    child: const Text('Ask for snapshots'),
                  ),
                if (isOwner)
                  TextButton.icon(
                    onPressed: () => context.push(FamilyInviteScreen.route),
                    icon: Icon(LucideIcons.userPlus, size: 16.spMin),
                    label: const Text('Add member'),
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.spMin),
        if (split) ...[
          card(roll.notYet),
          if (roll.checkedIn.isNotEmpty) ...[
            SizedBox(height: 16.spMin),
            _sectionLabelBuilder('Checked in', count: roll.checkedIn.length),
            SizedBox(height: 10.spMin),
            card(roll.checkedIn),
          ],
        ] else
          card(circle.members),
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
    final circleName = state.circle?.name ?? 'this group';
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
    listenTo((s) => s.requestCheckInState);
    listenTo((s) => s.leaveDeleteState);
    listenTo((s) => s.memberUpdateState);
  }
}
