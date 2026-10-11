import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:hazard_app/features/profile/utils/build_label.dart';
import 'package:hazard_app/others/env.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_journey_screen.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/notification/providers/accessible_alerts_provider.dart';
import 'package:hazard_app/features/notification/views/screens/manage_notifications_screen.dart';
import 'package:hazard_app/features/profile/enums/my_hazards_tab_types.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/providers/safety_profile_provider.dart';
import 'package:hazard_app/features/profile/providers/xp_summary_provider.dart';
import 'package:hazard_app/features/profile/views/screens/safety_profile_screen.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_choose_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_manage_screen.dart';
import 'package:hazard_app/features/profile/views/screens/support_request_screen.dart';
import 'package:hazard_app/features/profile/providers/profile_provider.dart';
import 'package:hazard_app/features/profile/providers/states/profile_provider_state.dart';
import 'package:hazard_app/features/profile/views/screens/delete_account_screen.dart';
import 'package:hazard_app/features/profile/views/screens/how_points_work_screen.dart';
import 'package:hazard_app/features/profile/views/screens/my_hazards_screen.dart';
import 'package:hazard_app/features/notification/views/screens/accessible_alerts_screen.dart';
import 'package:hazard_app/features/profile/views/screens/add_widget_screen.dart';
import 'package:hazard_app/features/profile/views/screens/leaderboard_screen.dart';
import 'package:hazard_app/features/profile/views/screens/points_breakdown_screen.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_xp_progress.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/profile/views/widgets/share_alrt_sheet.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_wrapper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:hazard_app/features/profile/views/screens/blocked_accounts_screen.dart';
import 'package:hazard_app/features/profile/views/screens/child_mode_screen.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';

/// The Profile ("Me") tab, rebuilt to the approved "Profile/Me" board
/// (9 Oct 2026): a plain white header with the avatar inside a thin
/// readiness ring, a "Finish setting up" card, the XP card, the one
/// ALRT + entry on the plan's purple gradient, then grouped list cards
/// (YOUR ALERTS, FAMILY, ACCOUNT, PRIVACY) with plain black Lucide icons,
/// and Log out / Delete account at the bottom.
///
/// Every navigation target is wired exactly as before: same screens, same
/// args, same route constants.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

/// The four "Finish setting up" steps, each true when done. "Widget
/// added" has no persisted flag today (the OS does not tell the app), so
/// it stays false until one exists.
class _Readiness {
  const _Readiness({
    required this.savedPlace,
    required this.safetyProfile,
    required this.accessibleAlerts,
    required this.widgetAdded,
  });

  final bool savedPlace;
  final bool safetyProfile;
  final bool accessibleAlerts;
  final bool widgetAdded;

  static const total = 4;

  int get done =>
      (savedPlace ? 1 : 0) +
      (safetyProfile ? 1 : 0) +
      (accessibleAlerts ? 1 : 0) +
      (widgetAdded ? 1 : 0);

  int get left => total - done;

  double get fraction => done / total;

  int get percent => (fraction * 100).round();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Board palette (approved 9 Oct 2026).
  static const _page = Color(0xFFF5F5F7);
  static const _muted = Color(0xFF5C5C66);
  static const _hairline = Color(0xFFE3E6EA);
  static const _ringTrack = Color(0xFFE6E6EA);
  static const _ready = Color(0xFF16A34A);
  static const _doneTile = Color(0xFFE6F7EC);
  static const _sectionLabel = Color(0xFFB84500);
  static const _plusStart = Color(0xFF4A1766);
  static const _plusEnd = Color(0xFF8E3FB3);
  static const _plusPurple = Color(0xFF7B359A);
  static const _danger = Color(0xFFDA1F2D);

  @override
  Widget build(BuildContext context) {
    _listenToUpdateProfilePictureState();
    _listenToLogoutState();

    final readiness = _watchReadiness();
    final hasPlus = ref.watch(providerOfAlrtPlus).value == true;

    return Scaffold(
      backgroundColor: _page,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(readiness: readiness, hasPlus: hasPlus),
          Padding(
            padding: EdgeInsets.fromLTRB(16.spMin, 16.spMin, 16.spMin, 32.spMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (readiness.left > 0) ...[
                  _buildFinishSettingUpCard(readiness),
                  SizedBox(height: 12.spMin),
                ],
                _buildXpCard(),
                SizedBox(height: 12.spMin),
                _buildAlrtPlusBanner(hasPlus: hasPlus),
                SizedBox(height: 20.spMin),
                _buildYourAlertsGroup(readiness: readiness, hasPlus: hasPlus),
                SizedBox(height: 20.spMin),
                _buildFamilyGroup(),
                SizedBox(height: 20.spMin),
                _buildAccountGroup(),
                SizedBox(height: 20.spMin),
                _buildPrivacyGroup(),
                SizedBox(height: 28.spMin),
                _buildLogoutButton(),
                SizedBox(height: 6.spMin),
                _buildDeleteAccountButton(),
                SizedBox(height: 16.spMin),
                _buildVersionFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Readiness
  // ---------------------------------------------------------------

  _Readiness _watchReadiness() {
    final savedPlace = ref.watch(
      providerOfMyLocationSubscriptions.select(
        (s) => s.locationSubscriptions.any((l) => !l.isOwnLocation),
      ),
    );
    final safetyProfile = ref.watch(
      providerOfSafetyProfile.select((cohorts) => cohorts.isNotEmpty),
    );
    final accessibleAlerts = ref.watch(
      providerOfAccessibleAlerts.select(
        (s) => s.strongVibration || s.readAloud,
      ),
    );
    return _Readiness(
      savedPlace: savedPlace,
      safetyProfile: safetyProfile,
      accessibleAlerts: accessibleAlerts,
      widgetAdded: false,
    );
  }

  // ---------------------------------------------------------------
  // 1. Header
  // ---------------------------------------------------------------

  Widget _buildHeader({
    required final _Readiness readiness,
    required final bool hasPlus,
  }) {
    final userName = ref.watch(
      providerOfLoggedInUser.select((value) => value?.name ?? 'User'),
    );
    final planLabel = hasPlus ? 'ALRT +' : 'ALRT Free';

    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.spMin, 16.spMin, 16.spMin, 18.spMin),
          child: Row(
            children: [
              _buildAvatarWithRing(
                userName: userName,
                fraction: readiness.fraction,
              ).onPressed(_showEditPhotoSheet),
              SizedBox(width: 14.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 3.spMin),
                    Text(
                      '$planLabel · ${readiness.percent}% ready',
                      style: TextStyle(
                        fontSize: 14.spMin,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.spMin),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.spMin,
                  vertical: 8.spMin,
                ),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ).onPressed(_showEditPhotoSheet),
            ],
          ),
        ),
      ),
    );
  }

  /// 64 px avatar (initials on the brand gradient, as before) inside a
  /// thin readiness ring: green arc for the done share, grey remainder.
  Widget _buildAvatarWithRing({
    required final String userName,
    required final double fraction,
  }) {
    final ringSize = 72.spMin;
    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 3,
              backgroundColor: _ringTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(_ready),
              strokeCap: StrokeCap.round,
            ),
          ),
          Container(
            width: 64.spMin,
            height: 64.spMin,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.orange300, AppColors.red200],
              ),
            ),
            child: Center(
              child: Text(
                _getInitials(userName),
                style: TextStyle(
                  fontSize: 26.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // 2. Finish setting up
  // ---------------------------------------------------------------

  Widget _buildFinishSettingUpCard(final _Readiness readiness) {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Finish setting up',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
              Text(
                '${readiness.left} left',
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.spMin),
          Row(
            children: [
              _buildSetupTile(
                icon: LucideIcons.mapPin,
                label: 'Save a place',
                done: readiness.savedPlace,
                onTap: () => context.push(
                  ManageNotificationsScreen.route,
                  extra: const ManageNotificationsScreenArgs(initialTab: 1),
                ),
              ),
              SizedBox(width: 8.spMin),
              _buildSetupTile(
                icon: LucideIcons.shield,
                label: 'Safety profile',
                done: readiness.safetyProfile,
                onTap: () => context.push(SafetyProfileScreen.route),
              ),
              SizedBox(width: 8.spMin),
              _buildSetupTile(
                icon: LucideIcons.volume2,
                label: 'Sound and vibration',
                done: readiness.accessibleAlerts,
                onTap: () => context.push(AccessibleAlertsScreen.route),
              ),
              SizedBox(width: 8.spMin),
              _buildSetupTile(
                icon: LucideIcons.layoutGrid,
                label: 'Add a widget',
                done: readiness.widgetAdded,
                onTap: () => context.push(AddWidgetScreen.route),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetupTile({
    required final IconData icon,
    required final String label,
    required final bool done,
    required final VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        height: 72.spMin,
        padding: EdgeInsets.symmetric(horizontal: 4.spMin, vertical: 8.spMin),
        decoration: BoxDecoration(
          color: done ? _doneTile : AppColors.white,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(color: done ? _ready : _hairline, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              done ? LucideIcons.check : icon,
              size: 22.spMin,
              color: done ? _ready : AppColors.orange,
            ),
            SizedBox(height: 6.spMin),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w600,
                height: 1.1,
                color: done ? _ready : AppColors.black,
              ),
            ),
          ],
        ),
      ).onPressed(onTap),
    );
  }

  // ---------------------------------------------------------------
  // 3. XP card
  // ---------------------------------------------------------------

  Widget _buildXpCard() {
    final int xpPoints = ref.watch(
          providerOfXpSummary.select((s) => s.value?.xpPoints),
        ) ??
        ref.watch(
          providerOfLoggedInUser.select((value) => value?.xpPoints),
        ) ??
        0;

    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$xpPoints',
                style: TextStyle(
                  fontSize: 30.spMin,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  color: AppColors.black,
                ),
              ),
              SizedBox(width: 4.spMin),
              Padding(
                padding: EdgeInsets.only(bottom: 3.spMin),
                child: Text(
                  'XP',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.spMin),
                child: Text(
                  'How points work',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ).onPressed(() => context.push(HowPointsWorkScreen.route)),
            ],
          ),
          SizedBox(height: 12.spMin),
          const ProfileXpProgress(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // 4. ALRT + banner
  // ---------------------------------------------------------------

  /// The one ALRT + entry in Profile (master spec §8, §16), on the
  /// personal plan's purple gradient. Copy summarises the PERSONAL plan
  /// and GROUP coverage from the backend's access summary: anyone with
  /// ALRT + (individual or its trial) or any group plan goes to Manage;
  /// everyone else is offered the trial. The word "Individual" never
  /// appears here (product owner 2026-09-28).
  Widget _buildAlrtPlusBanner({required final bool hasPlus}) {
    final access = ref.watch(providerOfAccess).value;
    final coveredGroups =
        access?.groups.where((g) => g.isSponsoredAndLive).length ?? 0;
    final hasAnyPlan = hasPlus ||
        coveredGroups > 0 ||
        (access?.unboundSponsorships.isNotEmpty ?? false) ||
        (access?.groups.any((g) => g.sponsorship?.youPay ?? false) ?? false);

    final String body;
    final String pill;
    if (hasAnyPlan) {
      body = 'You have ALRT +. Manage plans and group coverage.';
      pill = 'My plans';
    } else {
      body = 'Unlimited saved places. Try 2 weeks free.';
      pill = 'Explore';
    }

    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_plusStart, _plusEnd],
        ),
        borderRadius: BorderRadius.circular(18.spMin),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ALRT +',
                      style: TextStyle(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    if (isAlrtPlusTestUnlocked) ...[
                      SizedBox(width: 8.spMin),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.spMin,
                          vertical: 2.spMin,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20.spMin),
                        ),
                        child: Text(
                          'TEST',
                          style: TextStyle(
                            fontSize: 10.spMin,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.spMin),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    height: 1.3,
                    color: AppColors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.spMin),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.spMin,
              vertical: 8.spMin,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20.spMin),
            ),
            child: Text(
              pill,
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: FontWeight.w700,
                color: _plusPurple,
              ),
            ),
          ),
        ],
      ),
    ).onPressed(
      () => context.push(
        hasAnyPlan ? AlrtPlusManageScreen.route : AlrtPlusChooseScreen.route,
      ),
    );
  }

  // ---------------------------------------------------------------
  // 5. Grouped list cards
  // ---------------------------------------------------------------

  Widget _buildYourAlertsGroup({
    required final _Readiness readiness,
    required final bool hasPlus,
  }) {
    final savedCount = ref.watch(
      providerOfMyLocationSubscriptions.select(
        (s) => s.locationSubscriptions.where((l) => !l.isOwnLocation).length,
      ),
    );
    final savedSubtitle = hasPlus
        ? '$savedCount saved'
        : '$savedCount of $kFreeSavedLocationsLimit free used';

    return _buildGroup(
      label: 'Your alerts',
      rows: [
        _buildRow(
          icon: LucideIcons.bell,
          title: 'Notifications',
          subtitle: 'Official and community · sound and vibration inside',
          onTap: () => context.push(
            ManageNotificationsScreen.route,
            extra: const ManageNotificationsScreenArgs(initialTab: 0),
          ),
        ),
        _buildRow(
          icon: LucideIcons.mapPin,
          title: 'Saved places',
          subtitle: savedSubtitle,
          onTap: () => context.push(
            ManageNotificationsScreen.route,
            extra: const ManageNotificationsScreenArgs(initialTab: 1),
          ),
        ),
        _buildRow(
          icon: LucideIcons.shield,
          title: 'Safety profile',
          subtitle: readiness.safetyProfile
              ? 'Set up · stored on your phone'
              : 'Not set up · stored on your phone',
          onTap: () => context.push(SafetyProfileScreen.route),
        ),
        _buildRow(
          icon: LucideIcons.layoutGrid,
          title: 'Home screen widget',
          subtitle: 'Nearby alerts or family at a glance',
          onTap: () => context.push(AddWidgetScreen.route),
        ),
        _buildRow(
          icon: LucideIcons.vibrate,
          title: 'Accessible alerts',
          subtitle: 'Strong vibration, read aloud',
          onTap: () => context.push(AccessibleAlertsScreen.route),
        ),
      ],
    );
  }

  Widget _buildFamilyGroup() {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    final circles = ref.watch(providerOfFamily.select((s) => s.circles));

    final String familySubtitle;
    if (circle != null) {
      final n = circle.members.length;
      familySubtitle = '${circle.name} · $n ${n == 1 ? 'person' : 'people'}';
    } else if (circles.isNotEmpty) {
      final first = circles.first;
      final n = first.memberCount;
      familySubtitle = '${first.name} · $n ${n == 1 ? 'person' : 'people'}';
    } else {
      familySubtitle = 'No group yet';
    }

    return _buildGroup(
      label: 'Family',
      rows: [
        _buildRow(
          icon: LucideIcons.users,
          title: 'Family and check-ins',
          subtitle: familySubtitle,
          onTap: () =>
              ref.read(providerOfHomeTab.notifier).state = HomeTab.family,
        ),
        _buildRow(
          icon: LucideIcons.route,
          title: 'Journey sharing',
          subtitle: 'See shared journeys and live trips',
          onTap: _gotoJourneySharing,
        ),
      ],
    );
  }

  Widget _buildAccountGroup() {
    final int xpPoints = ref.watch(
          providerOfXpSummary.select((s) => s.value?.xpPoints),
        ) ??
        ref.watch(
          providerOfLoggedInUser.select((value) => value?.xpPoints),
        ) ??
        0;

    return _buildGroup(
      label: 'Account',
      rows: [
        _buildRow(
          icon: LucideIcons.star,
          title: 'Your points',
          subtitle: '$xpPoints XP · see where they came from',
          onTap: () => context.push(PointsBreakdownScreen.route),
        ),
        _buildRow(
          icon: LucideIcons.trophy,
          title: 'Leaderboard',
          subtitle: 'Ranks only. Names are never shown.',
          onTap: () => context.push(LeaderboardScreen.route),
        ),
        _buildRow(
          icon: LucideIcons.flag,
          title: 'My ALRTs',
          subtitle: 'Reports you have posted',
          onTap: _gotoMyAcceptedReportsScreen,
        ),
        _buildRow(
          icon: LucideIcons.share2,
          title: 'Share ALRT',
          subtitle: 'QR code or link · help a neighbour get alerts',
          onTap: () => showShareAlrtSheet(context),
        ),
        _buildRow(
          icon: LucideIcons.messageSquare,
          title: 'Help and feedback',
          subtitle: 'Get help or send feedback',
          onTap: _gotoSupportRequestScreen,
        ),
        // QA builds ship with the test unlock on, which hides every
        // paywall gate: this row lets the paywall itself be reviewed.
        // isAlrtPlusTestUnlocked requires appFlavor == 'dev' AND the
        // ALRT_PLUS_TEST_UNLOCK env flag, so it is structurally false in
        // a normal production (release-flavor) build.
        if (isAlrtPlusTestUnlocked)
          _buildRow(
            icon: LucideIcons.eye,
            title: 'Preview ALRT + plans',
            subtitle: 'QA build only. Gates are unlocked for testing.',
            onTap: () => context.push(AlrtPlusChooseScreen.route),
          ),
      ],
    );
  }

  Widget _buildPrivacyGroup() {
    return _buildGroup(
      label: 'Privacy',
      rows: [
        _buildRow(
          icon: LucideIcons.baby,
          title: 'Child mode',
          subtitle: 'Map, SOS and check-ins only',
          onTap: () => context.push(ChildModeScreen.route),
        ),
        _buildRow(
          icon: LucideIcons.ban,
          title: 'Blocked accounts',
          subtitle: 'People whose reports you have hidden',
          onTap: () => context.push(BlockedAccountsScreen.route),
        ),
        _buildRow(
          icon: LucideIcons.fileText,
          title: 'Terms and privacy',
          subtitle: 'Terms of use, privacy policy and disclaimer',
          onTap: _showLegalSheet,
        ),
      ],
    );
  }

  /// V3 section label (#B84500, uppercase, letter-spaced) above one white
  /// card holding [rows] separated by hairlines.
  Widget _buildGroup({
    required final String label,
    required final List<Widget> rows,
  }) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.spMin, bottom: 8.spMin),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: _sectionLabel,
            ),
          ),
        ),
        Container(
          decoration: _cardDecoration(),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: _hairline,
                    indent: 16.spMin,
                    endIndent: 16.spMin,
                  ),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// One list row: plain black 22 px Lucide icon, 16/700 title, 13 px
  /// muted subtitle, chevron. No tinted icon badges.
  Widget _buildRow({
    required final IconData icon,
    required final String title,
    required final String subtitle,
    required final VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
      child: Row(
        children: [
          Icon(icon, size: 22.spMin, color: AppColors.black),
          SizedBox(width: 14.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    height: 1.3,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.spMin),
          Icon(LucideIcons.chevronRight, size: 18.spMin, color: _muted),
        ],
      ),
    ).onPressed(onTap);
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 3.0,
            offset: Offset(0, 1),
          ),
        ],
      );

  // ---------------------------------------------------------------
  // 6. Bottom
  // ---------------------------------------------------------------

  Widget _buildLogoutButton() {
    return SizedBox(
      height: 52.spMin,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          side: const BorderSide(color: _hairline, width: 1.5),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.spMin),
          ),
        ),
        icon: Icon(LucideIcons.logOut, size: 18.spMin),
        label: Text(
          'Log out',
          style: TextStyle(
            fontSize: 15.spMin,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return TextButton(
      onPressed: _gotoDeleteAccountScreen,
      style: TextButton.styleFrom(foregroundColor: _danger),
      child: Text(
        'Delete account',
        style: TextStyle(
          fontSize: 14.spMin,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// "ALRT 1.0.5 (37) · TEST build": the build number Android's own app
  /// info hides, so a tester can tell which APK is actually installed.
  Widget _buildVersionFooter() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) return const SizedBox.shrink();
        return Center(
          child: Text(
            buildLabel(
              version: info.version,
              buildNumber: info.buildNumber,
              flavor: appFlavor,
              commit: kBuildCommit,
              billingMode: appFlavor == 'dev'
                  ? billingModeLabel(
                      testUnlocked: isAlrtPlusTestUnlocked,
                      hasStoreKey: Env.revenueCatApiKeyGoogle.isNotEmpty ||
                          Env.revenueCatApiKeyApple.isNotEmpty,
                    )
                  : '',
            ),
            style: TextStyle(
              fontSize: 12.spMin,
              color: _muted,
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // Sheets and navigation
  // ---------------------------------------------------------------

  /// Bottom sheet to change the profile photo. No name/email editing
  /// here: that is not implemented.
  void _showEditPhotoSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.spMin),
              child: Text(
                'Edit photo',
                style: TextStyle(
                  fontSize: 18.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: AppColors.black),
              title: Text(
                'Take photo',
                style:
                    TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref
                    .read(providerOfProfile.notifier)
                    .updateProfilePicture(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: AppColors.black),
              title: Text(
                'Choose from library',
                style:
                    TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref
                    .read(providerOfProfile.notifier)
                    .updateProfilePicture(source: ImageSource.gallery);
              },
            ),
            if (ref.read(providerOfLoggedInUser)?.processedProfilePicture !=
                null)
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: _danger),
                title: Text(
                  'Remove photo',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ref.read(providerOfProfile.notifier).deleteProfilePicture();
                },
              ),
            SizedBox(height: 8.spMin),
          ],
        ),
      ),
    );
  }

  /// Journey sharing only has a real destination once the user actually
  /// belongs to a circle (FamilyJourneyScreen falls back to a blank screen
  /// otherwise). With no circle yet, this lands on the Family tab, the same
  /// place the Family row above goes to.
  void _gotoJourneySharing() {
    final isInAGroup = ref.read(
      providerOfFamily.select(
        (s) => s.circle != null || s.circles.isNotEmpty,
      ),
    );
    if (isInAGroup) {
      context.push(FamilyJourneyScreen.route);
    } else {
      ref.read(providerOfHomeTab.notifier).state = HomeTab.family;
    }
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'U';
  }

  /// Listens to the profile picture update state changes and shows a toast
  /// on failure.
  void _listenToUpdateProfilePictureState() {
    ref.listen<ProfilePictureUpdateState>(
      providerOfProfile.select(
        (value) => value.profilePictureUpdateState,
      ),
      (previous, next) {
        next.maybeWhen(
          error: (_) => context.showErrorToast(
            message: 'Failed to update profile picture. Please try again.',
          ),
          orElse: () {},
        );
      },
    );
  }

  /// Listens to the logout state changes and navigates to the AppWrapper
  /// on success.
  void _listenToLogoutState() {
    ref.listen<LogoutState>(
      providerOfProfile.select((value) => value.logoutState),
      (previous, next) {
        next.maybeWhen(
          success: () => context.go(AppWrapper.route),
          error: (_) => context.showErrorToast(
            message: 'Failed to logout. Please try again.',
          ),
          orElse: () {},
        );
      },
    );
  }

  /// Shows a confirmation sheet for logging out.
  void _showLogoutDialog() {
    showConfirmationSheet(
      context: context,
      title: 'Are you sure you want to log out?',
      description: 'You will need to log in again to access your account.',
      onPressedConfirmAsync: (context, ref) =>
          ref.read(providerOfProfile.notifier).logout(),
    );
  }

  /// Navigates to My ALRTs (the accepted tab, as "View All ALRTs" did).
  void _gotoMyAcceptedReportsScreen() {
    context.push(
      MyHazardsScreen.route,
      extra: const MyHazardsScreenArgs(
        initialTab: MyHazardsTab.accepted,
      ),
    );
  }

  void _gotoSupportRequestScreen() {
    context.push(SupportRequestScreen.route);
  }

  /// Terms, privacy and disclaimer, reachable AFTER onboarding: Play
  /// requires a privacy-policy link inside the app, and reviewers look
  /// for it in settings.
  void _showLegalSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.fileText),
              title: const Text('Terms of Use'),
              onTap: () =>
                  openLink(context: sheetContext, link: AppLinks.termsOfUse),
            ),
            ListTile(
              leading: const Icon(LucideIcons.lock),
              title: const Text('Privacy Policy'),
              onTap: () =>
                  openLink(context: sheetContext, link: AppLinks.privacyPolicy),
            ),
            ListTile(
              leading: const Icon(LucideIcons.shieldAlert),
              title: const Text('Emergency services disclaimer'),
              onTap: () =>
                  openLink(context: sheetContext, link: AppLinks.disclaimer),
            ),
            SizedBox(height: 8.spMin),
          ],
        ),
      ),
    );
  }

  void _gotoDeleteAccountScreen() {
    context.push(DeleteAccountScreen.route);
  }
}
