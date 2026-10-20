import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:hazard_app/features/profile/utils/build_label.dart';
import 'package:hazard_app/others/env.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/screens/family_journey_screen.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/notification/models/push_notification_settings_model.dart';
import 'package:hazard_app/features/notification/providers/accessible_alerts_provider.dart';
import 'package:hazard_app/features/notification/providers/manage_notifications_provider.dart';
import 'package:hazard_app/features/notification/providers/states/manage_notifications_provider_state.dart';
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
import 'package:hazard_app/features/profile/views/screens/points_breakdown_screen.dart';
import 'package:hazard_app/features/profile/views/widgets/edit_profile_sheet.dart';
import 'package:hazard_app/features/profile/providers/child_mode_provider.dart';
import 'package:hazard_app/features/profile/providers/widget_step_provider.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_page_kit.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_xp_progress.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/profile/views/widgets/share_alrt_sheet.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_wrapper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:hazard_app/features/profile/views/screens/blocked_accounts_screen.dart';
import 'package:hazard_app/features/profile/views/screens/child_mode_screen.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';
import 'package:hazard_app/features/map/views/widgets/places_sheet.dart';

/// The Profile ("Me") tab, matched to the prototype "Profile" board
/// (ALRT screen map, 16 Oct 2026): the avatar inside a thick readiness
/// ring on the page grey, a "Finish setting up" card, the XP card, the one
/// ALRT + entry on the plan's purple gradient, then grouped list cards
/// (YOUR ALERTS with orange subtitles, FAMILY on lilac with indigo
/// subtitles, ACCOUNT, PRIVACY on light grey) with plain 22 px line icons,
/// and Log out / Delete account side by side at the bottom. The avatar and
/// the Edit link open the Edit profile sheet (photo and display name).
///
/// Every navigation target is wired exactly as before: same screens, same
/// args, same route constants.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

/// The four "Finish setting up" steps, each true when done. The OS never
/// says whether a widget was placed, so "Widget added" is the on-device
/// providerOfWidgetStep flag, set once the widget screen has been opened.
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
  // Prototype palette (ALRT screen map, Profile board).
  static const _page = Color(0xFFF5F5F7);
  static const _muted = Color(0xFF5C5C66);
  static const _hairline = Color(0xFFE3E6EA);
  static const _ringTrack = Color(0x14000000);
  static const _ready = Color(0xFF16A34A);
  static const _doneTile = Color(0xFFE6F6EC);
  static const _tileBorder = Color(0x0D000000);
  static const _sectionLabel = Color(0xFFB84500);
  static const _plusStart = Color(0xFF4A1766);
  static const _plusEnd = Color(0xFF8E3FB3);
  static const _danger = Color(0xFFB3141F);
  static const _chevron = Color(0xFF9A9AA2);
  static const _groupBorder = Color(0x0A000000);
  static const _rowDivider = Color(0x0F000000);

  // Group surfaces and subtitle colours from the board.
  static const _familyGroupBg = Color(0xFFF0EEF5);
  static const _privacyGroupBg = Color(0xFFF4F4F6);
  static const _alertsSubtitle = AppColors.orange;
  static const _familySubtitle = FamilyColors.indigo;

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
                _buildFinishSettingUpCard(readiness),
                SizedBox(height: 14.spMin),
                _buildXpCard(),
                SizedBox(height: 14.spMin),
                _buildAlrtPlusBanner(hasPlus: hasPlus),
                SizedBox(height: 14.spMin),
                _buildYourAlertsGroup(readiness: readiness, hasPlus: hasPlus),
                SizedBox(height: 14.spMin),
                _buildFamilyGroup(),
                SizedBox(height: 14.spMin),
                _buildAccountGroup(hasPlus: hasPlus),
                SizedBox(height: 14.spMin),
                _buildPrivacyGroup(),
                SizedBox(height: 14.spMin),
                _buildBottomButtons(),
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
    final widgetAdded = ref.watch(
      providerOfWidgetStep.select((s) => s.done),
    );
    return _Readiness(
      savedPlace: savedPlace,
      safetyProfile: safetyProfile,
      accessibleAlerts: accessibleAlerts,
      widgetAdded: widgetAdded,
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
    final isTrial = ref.watch(
      providerOfAccess.select((a) => a.value?.personal.isTrial ?? false),
    );
    final planLabel = hasPlus ? (isTrial ? 'ALRT + trial' : 'ALRT +') : 'ALRT Free';

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.spMin, 16.spMin, 20.spMin, 0),
        child: Row(
          children: [
            _buildAvatarWithRing(
              userName: userName,
              fraction: readiness.fraction,
            ).onPressed(_openEditProfile),
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
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 2.spMin),
                  Text(
                    '$planLabel · ${readiness.percent}% ready',
                    style: TextStyle(fontSize: 13.spMin, color: _muted),
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
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              ),
            ).onPressed(_openEditProfile),
          ],
        ),
      ),
    );
  }

  /// 54 px avatar (photo, or initials on the brand gradient) inside a
  /// thick readiness ring: green arc for the done share, faint remainder.
  Widget _buildAvatarWithRing({
    required final String userName,
    required final double fraction,
  }) {
    final ringSize = 72.spMin;
    final photo = ref.watch(
          providerOfProfile.select((s) => s.profilePicture),
        ) ??
        ref.watch(
          providerOfLoggedInUser.select((u) => u?.processedProfilePicture),
        );
    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: ringSize - 7.spMin,
            height: ringSize - 7.spMin,
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 7.spMin,
              backgroundColor: _ringTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(_ready),
              strokeCap: StrokeCap.round,
            ),
          ),
          Container(
            width: 54.spMin,
            height: 54.spMin,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.orange300, AppColors.red200],
              ),
            ),
            child: _buildAvatarContent(photo: photo, userName: userName),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent({
    required final AlrtMedia? photo,
    required final String userName,
  }) {
    final initials = Center(
      child: Text(
        _getInitials(userName),
        style: TextStyle(
          fontSize: 22.spMin,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
    if (photo == null) return initials;
    return switch (photo.source) {
      AlrtMediaSource.file => Image.file(File(photo.value), fit: BoxFit.cover),
      AlrtMediaSource.networkUrl => Image.network(
          photo.value,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => initials,
        ),
      AlrtMediaSource.asset => Image.asset(photo.value, fit: BoxFit.cover),
    };
  }

  // ---------------------------------------------------------------
  // 2. Finish setting up
  // ---------------------------------------------------------------

  Widget _buildFinishSettingUpCard(final _Readiness readiness) {
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Finish setting up',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                '${readiness.left} left',
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.spMin),
          Row(
            children: [
              _buildSetupTile(
                icon: LucideIcons.mapPin,
                label: 'Save a place',
                done: readiness.savedPlace,
                onTap: () => showPlacesSheet(context: context),
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

  /// One step tile: the step's own icon (green once done, orange until
  /// then) over a two-line label, on a pale green fill once done.
  Widget _buildSetupTile({
    required final IconData icon,
    required final String label,
    required final bool done,
    required final VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        height: 74.spMin,
        padding: EdgeInsets.symmetric(horizontal: 6.spMin, vertical: 10.spMin),
        decoration: BoxDecoration(
          color: done ? _doneTile : AppColors.white,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(color: _tileBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
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
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: AppColors.ink,
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

  int _watchXp() =>
      ref.watch(providerOfXpSummary.select((s) => s.value?.xpPoints)) ??
      ref.watch(providerOfLoggedInUser.select((value) => value?.xpPoints)) ??
      0;

  Widget _buildXpCard() {
    final xpPoints = _watchXp();

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
                  fontSize: 26.spMin,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(width: 4.spMin),
              Padding(
                padding: EdgeInsets.only(bottom: 2.spMin),
                child: Text(
                  'XP',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w600,
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
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ).onPressed(() => context.push(HowPointsWorkScreen.route)),
            ],
          ),
          SizedBox(height: 10.spMin),
          const ProfileXpProgress(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // 4. ALRT + banner
  // ---------------------------------------------------------------

  /// Whether the person has any plan to manage: ALRT + (or its trial) or
  /// any group plan they are covered by or pay for.
  bool _watchHasAnyPlan({required final bool hasPlus}) {
    final access = ref.watch(providerOfAccess).value;
    final coveredGroups =
        access?.groups.where((g) => g.isSponsoredAndLive).length ?? 0;
    return hasPlus ||
        coveredGroups > 0 ||
        (access?.unboundSponsorships.isNotEmpty ?? false) ||
        (access?.groups.any((g) => g.sponsorship?.youPay ?? false) ?? false);
  }

  /// The one ALRT + entry in Profile (master spec §8, §16), on the
  /// personal plan's purple gradient. Anyone with ALRT + (or its trial) or
  /// any group plan goes to My plans; everyone else is offered the trial.
  /// The word "Individual" never appears here (product owner 2026-09-28).
  Widget _buildAlrtPlusBanner({required final bool hasPlus}) {
    final hasAnyPlan = _watchHasAnyPlan(hasPlus: hasPlus);

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
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_plusStart, _plusEnd],
        ),
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: const [
          BoxShadow(
            color: Color(0x407B359A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
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
                SizedBox(height: 2.spMin),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12.spMin,
                    height: 1.3,
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.spMin),
          Container(
            height: 32.spMin,
            padding: EdgeInsets.symmetric(horizontal: 14.spMin),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10.spMin),
            ),
            child: Text(
              pill,
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: FontWeight.w700,
                color: _plusStart,
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

  /// The board's level names (rules.json notifications.levels), read
  /// from the saved switches. Null until the settings have loaded.
  String? _notificationLevelLabel(final PushNotificationSettings s) {
    final official = s.awsWatchAndAct || s.awsAdvice || s.officialNonAws;
    if (s.userReported && official) return 'Official and community';
    if (s.userReported) return 'Community only';
    if (official) return 'Official warnings only';
    return 'Keep it quiet';
  }

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
        ? '$savedCount saved · no limit'
        : '$savedCount of $kFreeSavedLocationsLimit free used';
    final cohortCount = ref.watch(
      providerOfSafetyProfile.select((cohorts) => cohorts.length),
    );
    final levelLabel = ref.watch(
      providerOfManageNotifications.select(
        (s) => s.getPushNotificationSettingsState.maybeWhen(
          success: (_) => _notificationLevelLabel(s.pushNotificationSettings),
          orElse: () => null,
        ),
      ),
    );

    return _buildGroup(
      label: 'Your alerts',
      subtitleColor: _alertsSubtitle,
      rows: [
        _RowSpec(
          icon: LucideIcons.bell,
          title: 'Notifications',
          subtitle: levelLabel == null
              ? 'Sound and vibration inside'
              : '$levelLabel · sound and vibration inside',
          onTap: () => context.push(
            ManageNotificationsScreen.route,
            extra: const ManageNotificationsScreenArgs(initialTab: 0),
          ),
        ),
        _RowSpec(
          icon: LucideIcons.mapPin,
          title: 'Saved places',
          subtitle: savedSubtitle,
          onTap: () => showPlacesSheet(context: context),
        ),
        _RowSpec(
          icon: LucideIcons.shield,
          title: 'Safety profile',
          subtitle: cohortCount > 0
              ? '$cohortCount selected · stored on your phone'
              : 'Not set up · stored on your phone',
          onTap: () => context.push(SafetyProfileScreen.route),
        ),
        _RowSpec(
          icon: LucideIcons.layoutGrid,
          title: 'Home screen widget',
          subtitle: 'Nearby alerts or family at a glance',
          onTap: () => context.push(AddWidgetScreen.route),
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
      familySubtitle = 'No group yet. Creating one is free.';
    }

    return _buildGroup(
      label: 'Family',
      background: _familyGroupBg,
      subtitleColor: _familySubtitle,
      rows: [
        _RowSpec(
          icon: LucideIcons.users,
          title: 'Family and check-ins',
          subtitle: familySubtitle,
          onTap: () =>
              ref.read(providerOfHomeTab.notifier).state = HomeTab.family,
        ),
        _RowSpec(
          icon: LucideIcons.navigation,
          title: 'Journey sharing',
          subtitle: 'Shared journeys and live trips',
          onTap: _gotoJourneySharing,
        ),
      ],
    );
  }

  Widget _buildAccountGroup({required final bool hasPlus}) {
    final xpPoints = _watchXp();
    final hasAnyPlan = _watchHasAnyPlan(hasPlus: hasPlus);

    return _buildGroup(
      label: 'Account',
      rows: [
        _RowSpec(
          icon: LucideIcons.star,
          title: 'Your points',
          subtitle: '$xpPoints XP · see where they came from',
          onTap: () => context.push(PointsBreakdownScreen.route),
        ),
        _RowSpec(
          icon: LucideIcons.share,
          title: 'Share ALRT',
          subtitle: 'QR code or link',
          onTap: () => showShareAlrtSheet(context),
        ),
        _RowSpec(
          icon: LucideIcons.lifeBuoy,
          title: 'Help and feedback',
          subtitle: 'Get help or send feedback',
          onTap: _gotoSupportRequestScreen,
        ),
        _RowSpec(
          icon: LucideIcons.creditCard,
          title: 'My plans',
          subtitle: hasPlus
              ? 'Personal plan and group coverage'
              : 'ALRT Free · group coverage',
          onTap: () => context.push(
            hasAnyPlan ? AlrtPlusManageScreen.route : AlrtPlusChooseScreen.route,
          ),
        ),
        _RowSpec(
          icon: LucideIcons.flag,
          title: 'My ALRTs',
          subtitle: 'Reports you posted',
          onTap: _gotoMyAcceptedReportsScreen,
        ),
        _RowSpec(
          icon: LucideIcons.vibrate,
          title: 'Accessible alerts',
          subtitle: 'Strong vibration, read aloud',
          onTap: () => context.push(AccessibleAlertsScreen.route),
        ),
        _RowSpec(
          icon: LucideIcons.messageSquare,
          title: 'Language',
          subtitle: 'English',
          onTap: _showLanguageSheet,
        ),
        // QA builds ship with the test unlock on, which hides every
        // paywall gate: this row lets the paywall itself be reviewed.
        // isAlrtPlusTestUnlocked requires appFlavor == 'dev' AND the
        // ALRT_PLUS_TEST_UNLOCK env flag, so it is structurally false in
        // a normal production (release-flavor) build.
        if (appFlavor == 'dev') ...[
          _RowSpec(
            icon: LucideIcons.lock,
            title: isAlrtPlusTestUnlocked
                ? 'Test mode: ALRT + unlocked'
                : 'Test mode: real paywalls',
            subtitle: isAlrtPlusTestUnlocked
                ? 'QA build only. Tap to turn the real paywalls on.'
                : 'QA build only. Tap to unlock ALRT + for testing.',
            onTap: _toggleTestMode,
          ),
          _RowSpec(
            icon: LucideIcons.eye,
            title: 'Preview ALRT + plans',
            subtitle: 'QA build only. See the plans and prices.',
            onTap: () => context.push(AlrtPlusChooseScreen.route),
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacyGroup() {
    final childModeOn = ref.watch(providerOfIsChildMode);
    return _buildGroup(
      label: 'Privacy',
      background: _privacyGroupBg,
      rows: [
        _RowSpec(
          icon: LucideIcons.userRound,
          title: 'Child mode',
          subtitle: childModeOn
              ? 'On · Report hidden'
              : 'Map, SOS and check-ins only',
          onTap: () => context.push(ChildModeScreen.route),
        ),
        _RowSpec(
          icon: LucideIcons.ban,
          title: 'Blocked accounts',
          subtitle: 'People whose reports you have hidden',
          onTap: () => context.push(BlockedAccountsScreen.route),
        ),
        _RowSpec(
          icon: LucideIcons.fileText,
          title: 'Terms and privacy',
          subtitle: 'Terms of use, privacy policy, disclaimer',
          onTap: _showLegalSheet,
        ),
      ],
    );
  }

  /// V3 section label (#B84500, uppercase, letter-spaced) above one card
  /// holding [rows] separated by inset hairlines.
  Widget _buildGroup({
    required final String label,
    required final List<_RowSpec> rows,
    final Color background = AppColors.white,
    final Color subtitleColor = _muted,
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
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: _sectionLabel,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18.spMin),
            border: Border.all(color: _groupBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: _rowDivider,
                    indent: 16.spMin,
                    endIndent: 16.spMin,
                  ),
                _buildRow(rows[i], subtitleColor: subtitleColor),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// One list row as on the board: a plain 22 px ink line icon, 15/700
  /// title, 12/500 subtitle in the group's colour, grey chevron, 58 px.
  Widget _buildRow(final _RowSpec row, {required final Color subtitleColor}) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 58.spMin),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 9.spMin),
        child: Row(
          children: [
            Icon(row.icon, size: 22.spMin, color: AppColors.ink),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    row.title,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 1.spMin),
                  Text(
                    row.subtitle,
                    style: TextStyle(
                      fontSize: 12.spMin,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.spMin),
            Icon(LucideIcons.chevronRight, size: 16.spMin, color: _chevron),
          ],
        ),
      ),
    ).onPressed(row.onTap);
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

  /// Log out (white, outlined) and Delete account (red text) side by side.
  Widget _buildBottomButtons() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.spMin),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.spMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.spMin),
                border: Border.all(color: _hairline),
              ),
              child: Text(
                'Log out',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ).onPressed(_showLogoutSheet),
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Container(
              height: 48.spMin,
              alignment: Alignment.center,
              child: Text(
                'Delete account',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w600,
                  color: _danger,
                ),
              ),
            ).onPressed(_gotoDeleteAccountScreen),
          ),
        ],
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

  /// The Edit profile sheet: photo (the old picker lives inside it),
  /// display name, sign-in email and the home region for alerts.
  void _openEditProfile() {
    showEditProfileSheet(context);
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

  /// The prototype "Log out?" sheet: Log out, or Stay. Signing out also
  /// clears the Family widget (ProfileProvider.logout).
  void _showLogoutSheet() {
    showProfileSheet<void>(
      context: context,
      builder: (sheetContext) => [
        const ProfileSheetTitle(
          title: 'Log out?',
          subtitle:
              'You will need to sign in again. The Family widget is cleared.',
        ),
        ProfileButton(
          key: const Key('logout-go'),
          label: 'Log out',
          onPressed: () {
            Navigator.of(sheetContext).pop();
            ref.read(providerOfProfile.notifier).logout();
          },
        ),
        ProfileButton(
          label: 'Stay',
          kind: ProfileButtonKind.ghost,
          onPressed: () => Navigator.of(sheetContext).pop(),
        ),
      ],
    );
  }

  /// The prototype Language sheet. Only English ships today (Spanish is
  /// switched off in app_bootstrap.dart until full localisation lands), so
  /// it shows the one choice rather than a switch that does nothing.
  void _showLanguageSheet() {
    showProfileSheet<void>(
      context: context,
      builder: (sheetContext) => [
        const ProfileSheetTitle(title: 'Language'),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.spMin),
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 20.spMin,
                height: 20.spMin,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 6.spMin),
                ),
              ),
              SizedBox(width: 12.spMin),
              Text(
                'English',
                style: TextStyle(
                  fontSize: 15.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        const ProfileMutedText(
          'More languages are coming. Official warnings are shown in their '
          'original wording.',
          size: 12,
        ),
        ProfileButton(
          label: 'Close',
          kind: ProfileButtonKind.ghost,
          onPressed: () => Navigator.of(sheetContext).pop(),
        ),
      ],
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

  /// Flips between "ALRT + unlocked" and the real paywalls (dev builds
  /// only), then re-reads everything that depends on it.
  Future<void> _toggleTestMode() async {
    await AlrtPlusTestSwitch.set(unlocked: !isAlrtPlusTestUnlocked);
    if (!mounted) return;
    ref
      ..invalidate(providerOfAlrtPlus)
      ..invalidate(providerOfAccess)
      ..invalidate(providerOfAlrtPlusBillingIssue)
      ..invalidate(providerOfExpiredAlrtPlus);
    setState(() {});
    context.showSuccessToast(
      message: isAlrtPlusTestUnlocked
          ? 'ALRT + is unlocked for testing.'
          : 'Real paywalls are on.',
    );
  }

  void _gotoSupportRequestScreen() {
    context.push(SupportRequestScreen.route);
  }

  /// Terms, privacy and disclaimer, reachable AFTER onboarding: Play
  /// requires a privacy-policy link inside the app, and reviewers look
  /// for it in settings. Prototype "Terms and privacy" sheet. The board
  /// also lists Community guidelines and Data sources and licences; those
  /// pages have no published URL yet (AppLinks), so they are not shown.
  void _showLegalSheet() {
    showProfileSheet<void>(
      context: context,
      builder: (sheetContext) => [
        const ProfileSheetTitle(title: 'Terms and privacy'),
        ProfileRowGroup(
          rows: [
            ProfileListRow(
              title: 'Terms of Use',
              onTap: () =>
                  openLink(context: sheetContext, link: AppLinks.termsOfUse),
            ),
            ProfileListRow(
              title: 'Privacy Policy',
              onTap: () =>
                  openLink(context: sheetContext, link: AppLinks.privacyPolicy),
            ),
            ProfileListRow(
              title: 'Emergency services disclaimer',
              onTap: () =>
                  openLink(context: sheetContext, link: AppLinks.disclaimer),
            ),
          ],
        ),
        ProfileButton(
          label: 'Close',
          kind: ProfileButtonKind.ghost,
          onPressed: () => Navigator.of(sheetContext).pop(),
        ),
      ],
    );
  }

  void _gotoDeleteAccountScreen() {
    context.push(DeleteAccountScreen.route);
  }
}

/// One Profile list row: icon, title, subtitle and where it goes.
class _RowSpec {
  const _RowSpec({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
