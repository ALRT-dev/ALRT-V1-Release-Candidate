import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_journey_screen.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/notification/views/screens/manage_notifications_screen.dart';
import 'package:hazard_app/features/profile/enums/my_hazards_tab_types.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/views/screens/safety_profile_screen.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_manage_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/profile/views/screens/support_request_screen.dart';
import 'package:hazard_app/features/profile/providers/my_hazards_provider.dart';
import 'package:hazard_app/features/profile/providers/profile_provider.dart';
import 'package:hazard_app/features/profile/providers/states/profile_provider_state.dart';
import 'package:hazard_app/features/profile/views/screens/delete_account_screen.dart';
import 'package:hazard_app/features/profile/views/screens/my_hazards_screen.dart';
import 'package:hazard_app/features/profile/views/widgets/accepted_hazards_widgets/my_accepted_hazards_list.dart';
import 'package:hazard_app/features/profile/views/widgets/add_widget_sheet.dart';
import 'package:hazard_app/features/profile/views/screens/points_breakdown_screen.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_colors.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_gradient_icon.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_xp_progress.dart';
import 'package:hazard_app/features/profile/views/widgets/rejected_hazards_widgets/my_rejected_hazards_list.dart';
import 'package:hazard_app/features/shared/enums/user_badge_enum.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/features/profile/views/widgets/share_alrt_sheet.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_surface_colors.dart';
import 'package:hazard_app/others/app_wrapper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:hazard_app/features/profile/views/screens/blocked_accounts_screen.dart';
import 'package:hazard_app/features/profile/views/screens/child_mode_screen.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    _listenToUpdateProfilePictureState();
    _listenToLogoutState();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.spMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFamilyHighlightCard(),
                  10.spMin.hSizedBox,
                  _buildAlrtPlusHighlightCard(),
                  24.spMin.hSizedBox,
                  _buildStatsSection(),
                  24.spMin.hSizedBox,
                  _buildSubmittedHazardsSection(),
                  _buildFailedReviewsSection(),
                  _buildSafetySection(),
                  20.spMin.hSizedBox,
                  _buildPreferencesSection(),
                  20.spMin.hSizedBox,
                  _buildAccountSection(),
                  20.spMin.hSizedBox,
                  _buildPrivacySafetySection(),
                  20.spMin.hSizedBox,
                  _buildSupportSharingSection(),
                  20.spMin.hSizedBox,
                  _buildDangerZoneSection(),
                  30.spMin.hSizedBox,
                  _buildLogoutSection(),
                  30.spMin.hSizedBox,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 220.spMin,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the collapse ratio
          final collapsedHeight =
              kToolbarHeight + MediaQuery.of(context).padding.top;
          final currentHeight = constraints.maxHeight;

          // When currentHeight equals collapsedHeight, it's fully collapsed
          final isCollapsed =
              currentHeight <= collapsedHeight + 10; // Small buffer

          return FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: EdgeInsets.only(
              left: 20.spMin,
              bottom: 16.spMin,
            ),
            title: isCollapsed
                ? GestureDetector(
                    onTap: _showEditPhotoSheet,
                    child: Row(
                      spacing: 10.spMin,
                      children: [
                        _buildUserAvatar(
                          size: 40.0,
                          fontSize: 20.0,
                          borderRadius: 10.0,
                          showEditBadge: false,
                        ),
                        _buildUserName(
                          color: AppColors.black,
                          fontSize: 20.0,
                        ),
                      ],
                    ),
                  )
                : null,
            // Deliberately always dark, in both Light and Dark Appearance -
            // this header already reads as its own high-contrast surface
            // (per the mockup) and predates the Appearance toggle, so it is
            // out of scope for the Light/Dark distinction rather than a
            // remaining gap in it.
            background: Container(
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.9),
              ),
              padding: EdgeInsets.all(20.spMin),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 10.spMin,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _showEditPhotoSheet,
                            child: Row(
                              spacing: 15.spMin,
                              children: [
                                _buildUserAvatar(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildUserName(
                                        color: AppColors.white
                                            .withValues(alpha: 0.9),
                                      ),
                                      3.spMin.hSizedBox,
                                      Text(
                                        'Edit photo',
                                        style: TextStyle(
                                          fontSize: 12.spMin,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildUserBadge(),
                      ],
                    ),
                    20.hSizedBox,
                    ProfileXpProgress().pB(10.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserName({
    final double fontSize = 20.0,
    final Color color = AppColors.white,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final userName = ref.watch(
          providerOfLoggedInUser.select(
            (value) => value?.name ?? 'User',
          ),
        );
        return Text(
          userName,
          style: TextStyle(
            fontSize: fontSize.spMin,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar({
    final double size = 65.0,
    final double fontSize = 30.0,
    final double borderRadius = 20.0,
    final bool showEditBadge = true,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final userName = ref.watch(
          providerOfLoggedInUser.select(
            (value) => value?.name ?? 'User',
          ),
        );
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size.spMin,
              height: size.spMin,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.orange300,
                    AppColors.red200,
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius.spMin),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange300.withValues(alpha: 0.6),
                    blurRadius: 10.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getInitials(userName),
                  style: TextStyle(
                    fontSize: fontSize.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            if (showEditBadge)
              Positioned(
                right: -2.spMin,
                bottom: -2.spMin,
                child: Container(
                  padding: EdgeInsets.all(4.spMin),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.black.withValues(alpha: 0.9),
                      width: 2.0,
                    ),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 10.spMin,
                    color: AppColors.black,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserBadge() {
    return Consumer(
      builder: (context, ref, child) {
        final userBadge = ref.watch(
          providerOfLoggedInUser.select(
            (value) => value?.userBadge ?? UserBadge.watcher,
          ),
        );

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.spMin,
            vertical: 5.spMin,
          ),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.spMin),
            border: Border.all(
              color: AppColors.orange.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Text(
            '⚡️ ${userBadge.title}',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.orange300,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Row(
      spacing: 8.spMin,
      children: [
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final alertsMade = ref.watch(
                providerOfLoggedInUser.select(
                  (value) => value?.hazardsReportedCount ?? 0,
                ),
              );
              return _buildStatItem(
                value: alertsMade,
                label: 'ALRTs Made',
                valueColor: const Color(0xFFFF7F44),
              );
            },
          ),
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final alertsViewed = ref.watch(
                providerOfLoggedInUser.select(
                  (value) => value?.hazardsViewedCount ?? 0,
                ),
              );
              return _buildStatItem(
                value: alertsViewed,
                label: 'Viewed',
                valueColor: const Color(0xFF6199FF),
              );
            },
          ),
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final upvotesReceived = ref.watch(
                providerOfLoggedInUser.select(
                  (value) => value?.upvotesReceivedCount ?? 0,
                ),
              );
              return _buildStatItem(
                value: upvotesReceived,
                label: 'Upvotes',
                valueColor: const Color(0xFF39C05D),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittedHazardsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final isEmpty = ref.watch(
          providerOfMyHazards.select(
            (value) => value.myAcceptedHazards.isEmpty,
          ),
        );
        if (isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10.spMin,
          children: [
            Text('Recent ALRTs'.toUpperCase(), style: _sectionLabelStyle()),
            MyAcceptedHazardsList(
              limit: 3,
              shinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            _buildViewAllButton(
              text: 'View All ALRTs',
              onPressed: _gotoMyAcceptedReportsScreen,
            ),
          ],
        ).pB(24.0);
      },
    );
  }

  Widget _buildFailedReviewsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final isEmpty = ref.watch(
          providerOfMyHazards.select(
            (value) => value.myRejectedHazards.isEmpty,
          ),
        );
        if (isEmpty) return const SizedBox();

        return Column(
          spacing: 10.spMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Needs Update'.toUpperCase(), style: _sectionLabelStyle()),
            MyRejectedHazardsList(
              limit: 3,
              shinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            _buildViewAllButton(
              text: 'View All Pending',
              onPressed: _gotoMyRejectedReportsScreen,
            ),
          ],
        ).pB(24.0);
      },
    );
  }

  /// Family & check-ins — the first card under the header: a soft,
  /// restrained green -> teal gradient wash (calm, never a loud fill), so
  /// it reads as a safety focal point without competing with the header's
  /// own XP bar or ALRT+'s bolder premium treatment below. Subtitle is
  /// real circle/SOS status only - never invented copy.
  Widget _buildFamilyHighlightCard() {
    return Consumer(
      builder: (context, ref, child) {
        final circle = ref.watch(providerOfFamily.select((s) => s.circle));
        final circles = ref.watch(providerOfFamily.select((s) => s.circles));
        final activeSosCount = ref.watch(
          providerOfFamily.select((s) => s.activeSosEvents.length),
        );

        final String subtitle;
        if (activeSosCount > 0) {
          subtitle = activeSosCount == 1
              ? '1 active SOS in your circle'
              : '$activeSosCount active SOS in your circle';
        } else if (circle != null) {
          final memberCount = circle.members.length;
          subtitle = memberCount > 0
              ? '${circle.name} · $memberCount member${memberCount == 1 ? '' : 's'}'
              : circle.name;
        } else if (circles.isNotEmpty) {
          subtitle = circles.length == 1
              ? 'You belong to 1 circle'
              : 'You belong to ${circles.length} circles';
        } else {
          subtitle = 'Check in and see who is near an alert';
        }

        return _buildHighlightCard(
          icon: LucideIcons.users,
          accent: ProfileColors.familyAndCheckIns,
          backgroundTint: 0.10,
          borderTint: 0.28,
          title: 'Family & check-ins',
          subtitle: subtitle,
          onTap: () =>
              ref.read(providerOfHomeTab.notifier).state = HomeTab.family,
        );
      },
    );
  }

  /// ALRT+ membership — the premium card (approved redesign 2026-09-03):
  /// a dark, blended purple surface (ProfileColors.alrtPlusCardGradient)
  /// with white text and a cream-to-gold crown, so it reads unmistakably
  /// as membership next to the light safety cards around it. Subtitle and
  /// TEST chip reuse the exact same real entitlement state as before - no
  /// invented offers, no gating changes.
  Widget _buildAlrtPlusHighlightCard() {
    return Consumer(
      builder: (context, ref, child) {
        final isSubscribed = ref.watch(providerOfAlrtPlus).value == true;
        return Container(
          padding: EdgeInsets.all(16.spMin),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.55, 1.0],
              colors: ProfileColors.alrtPlusCardGradient,
            ),
            borderRadius: BorderRadius.circular(18.spMin),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: ProfileColors.alrtPlusCardGradient.first
                    .withValues(alpha: 0.35),
                blurRadius: 16.0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46.spMin,
                height: 46.spMin,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13.spMin),
                  border: Border.all(
                    color: ProfileColors.alrtPlusCrown.end
                        .withValues(alpha: 0.45),
                  ),
                ),
                child: Center(
                  child: ProfileGradientIcon(
                    icon: LucideIcons.crown,
                    accent: ProfileColors.alrtPlusCrown,
                    size: 24.0,
                    gradient: true,
                  ),
                ),
              ),
              12.wSizedBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ALRT+ membership',
                      style: TextStyle(
                        fontSize: 16.5.spMin,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    2.spMin.hSizedBox,
                    Text(
                      isSubscribed
                          ? 'Plan, seats and billing'
                          : 'You pay once, everyone else joins free',
                      style: TextStyle(
                        fontSize: 12.5.spMin,
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAlrtPlusTestUnlocked) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.spMin,
                    vertical: 3.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: ProfileColors.alrtPlusCrown.start
                        .withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20.spMin),
                  ),
                  child: Text(
                    'TEST',
                    style: TextStyle(
                      fontSize: 10.5.spMin,
                      fontWeight: FontWeight.w800,
                      color: ProfileColors.alrtPlusCrown.start,
                    ),
                  ),
                ),
                6.wSizedBox,
              ],
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.75),
                size: 19.spMin,
              ),
            ],
          ),
        ).onPressed(
          () => context.push(
            isSubscribed
                ? AlrtPlusManageScreen.route
                : AlrtPlusPaywallScreen.route,
          ),
        );
      },
    );
  }

  /// The light highlight-card shape (Family & check-ins): a soft gradient
  /// wash of [accent]'s own stops behind a gradient icon badge. ALRT+ has
  /// its own dark premium card above and no longer shares this shape.
  Widget _buildHighlightCard({
    required final IconData icon,
    required final ProfileRowAccent accent,
    required final double backgroundTint,
    required final double borderTint,
    required final String title,
    required final String subtitle,
    required final VoidCallback onTap,
    final Widget? trailing,
    final bool premium = false,
  }) {
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            for (final (index, stopColor) in accent.colors.indexed)
              stopColor.withValues(
                alpha: index == accent.colors.length - 1
                    ? backgroundTint * (premium ? 1.8 : 1.3)
                    : backgroundTint,
              ),
          ],
        ),
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(
          color: accent.end.withValues(alpha: borderTint),
          width: premium ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: (premium ? 46 : 42).spMin,
            height: (premium ? 46 : 42).spMin,
            decoration: BoxDecoration(
              color: context.surfaceCard,
              borderRadius: BorderRadius.circular(13.spMin),
              boxShadow: [
                BoxShadow(
                  color: accent.end.withValues(alpha: premium ? 0.35 : 0.18),
                  blurRadius: premium ? 10.0 : 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: ProfileGradientIcon(
                icon: icon,
                accent: accent,
                size: premium ? 23.0 : 21.0,
                gradient: true,
              ),
            ),
          ),
          12.wSizedBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: (premium ? 16.5 : 15.5).spMin,
                    fontWeight: premium ? FontWeight.w800 : FontWeight.w700,
                    color: context.onSurface,
                  ),
                ),
                2.spMin.hSizedBox,
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    color: context.onSurfaceMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[trailing, 6.wSizedBox],
          Icon(
            Icons.chevron_right,
            color: accent.end.withValues(alpha: 0.6),
            size: 19.spMin,
          ),
        ],
      ),
    ).onPressed(onTap);
  }

  /// SAFETY: safety profile first, then saved locations and journey
  /// sharing. Family & check-ins is its own highlight card above, not a
  /// row in this list. Safety profile moved here from Privacy (approved
  /// redesign 2026-09-03): it is the thing that tailors every alert, so
  /// it belongs at the top of Safety, not among the privacy controls.
  Widget _buildSafetySection() {
    return _buildSectionCard(
      label: 'Safety',
      rows: [
        _buildProfileRow(
          title: 'Safety profile',
          subtitle: 'Tailored For You guidance · stays on your phone',
          icon: LucideIcons.shieldCheck,
          accent: const ProfileRowAccent(Color(0xFF6199FF), AppColors.blue),
          onTap: () => context.push(SafetyProfileScreen.route),
        ),
        Consumer(
          builder: (context, ref, child) {
            final savedCount = ref.watch(
              providerOfMyLocationSubscriptions.select(
                (s) => s.locationSubscriptions
                    .where((location) => !location.isOwnLocation)
                    .length,
              ),
            );
            return _buildProfileRow(
              title: 'Saved locations',
              subtitle: 'Places you get hazard alerts for',
              icon: LucideIcons.mapPin,
              accent: ProfileColors.savedLocations,
              trailing: _buildCountChip(savedCount),
              onTap: () => context.push(
                ManageNotificationsScreen.route,
                extra: const ManageNotificationsScreenArgs(initialTab: 1),
              ),
            );
          },
        ),
        _buildProfileRow(
          title: 'Journey sharing',
          subtitle: 'See shared journeys and live trips',
          icon: LucideIcons.route,
          accent: ProfileColors.journeySharing,
          onTap: _gotoJourneySharing,
        ),
      ],
    );
  }

  /// PREFERENCES: notifications, language. Appearance is deliberately
  /// hidden for now - Dark mode is unfinished (see app.dart, pinned to
  /// ThemeMode.light) and the row would offer a choice the app cannot
  /// yet honour. The picker itself, appearance_provider.dart and the
  /// dark palette all stay in place, dormant, for a later accessibility
  /// pass.
  Widget _buildPreferencesSection() {
    return _buildSectionCard(
      label: 'Preferences',
      rows: [
        _buildProfileRow(
          title: 'Notifications',
          subtitle: 'Alert types and push preferences',
          icon: LucideIcons.bell,
          accent: ProfileColors.notifications,
          onTap: () => context.push(
            ManageNotificationsScreen.route,
            extra: const ManageNotificationsScreenArgs(initialTab: 0),
          ),
        ),
        _buildProfileRow(
          title: 'Language',
          subtitle: _currentLanguageLabel(),
          icon: LucideIcons.globe,
          accent: const ProfileRowAccent(Color(0xFF6199FF), Color(0xFF2FA6FF)),
          onTap: _showLanguagePicker,
        ),
      ],
    );
  }

  /// ACCOUNT: points, help & feedback (+ the QA-only paywall preview row).
  /// ALRT+ membership itself is now its own highlight card above.
  Widget _buildAccountSection() {
    return _buildSectionCard(
      label: 'Account',
      rows: [
        // The only remaining path to the points breakdown after removing
        // the old ProfileTrustCard block (duplicate tier/streak/quest
        // card, replaced by the single compact XP bar in the header) - a
        // quiet row here rather than a second progress display. "How
        // points work" stays reachable from the report-submission screen
        // (create_update_report_screen.dart), so it does not need a
        // second entry point here too.
        _buildProfileRow(
          title: 'Your points',
          subtitle: 'See where your points came from',
          icon: LucideIcons.star,
          accent: const ProfileRowAccent(Color(0xFFFFD166), Color(0xFFE1A500)),
          onTap: () => context.push(PointsBreakdownScreen.route),
        ),
        // QA builds ship with the test unlock on, which hides every
        // paywall gate — this row lets the paywall itself be reviewed.
        // isAlrtPlusTestUnlocked requires appFlavor == 'dev' AND the
        // ALRT_PLUS_TEST_UNLOCK env flag, so it is structurally false in
        // a normal production (release-flavor) build - this row cannot
        // render there regardless of any env value.
        if (isAlrtPlusTestUnlocked)
          _buildProfileRow(
            title: 'Preview ALRT+ paywall',
            subtitle: 'QA build only — gates are unlocked for testing',
            icon: LucideIcons.eye,
            accent: const ProfileRowAccent(Color(0xFF8B84FF), Color(0xFF5B5BD6)),
            onTap: () => context.push(AlrtPlusPaywallScreen.route),
          ),
        _buildProfileRow(
          title: 'Help & feedback',
          subtitle: 'Get help or submit feedback',
          icon: LucideIcons.messageSquare,
          accent: ProfileColors.helpAndFeedback,
          onTap: _gotoSupportRequestScreen,
        ),
      ],
    );
  }

  /// PRIVACY: who can see what, and the legal texts. Safety profile now
  /// lives at the top of the Safety section above.
  Widget _buildPrivacySafetySection() {
    return _buildSectionCard(
      label: 'Privacy',
      rows: [
        _buildProfileRow(
          title: 'Child mode',
          subtitle: 'Map, SOS and check-ins only on this phone',
          icon: LucideIcons.baby,
          accent: const ProfileRowAccent(Color(0xFF3DD9C4), Color(0xFF00A896)),
          onTap: () => context.push(ChildModeScreen.route),
        ),
        _buildProfileRow(
          title: 'Blocked accounts',
          subtitle: 'People whose reports you have hidden',
          icon: LucideIcons.userX,
          accent: const ProfileRowAccent(Color(0xFFE07A3D), Color(0xFFB84500)),
          onTap: () => context.push(BlockedAccountsScreen.route),
        ),
        _buildProfileRow(
          title: 'Terms & Privacy',
          subtitle: 'Terms of use, privacy policy and disclaimer',
          icon: LucideIcons.scale,
          accent: ProfileColors.helpAndFeedback,
          onTap: _showLegalSheet,
        ),
      ],
    );
  }

  /// SUPPORT & SHARING: spreading/using the app more.
  Widget _buildSupportSharingSection() {
    return _buildSectionCard(
      label: 'Support & Sharing',
      rows: [
        _buildProfileRow(
          title: 'Add widget to your home screen',
          subtitle: 'Nearby alerts or family at a glance',
          icon: LucideIcons.layoutGrid,
          accent: const ProfileRowAccent(Color(0xFFFFB33D), AppColors.orange),
          onTap: () => showAddWidgetSheet(context),
        ),
        _buildProfileRow(
          title: 'Share ALRT',
          subtitle: 'QR code or link · help a neighbour get alerts',
          icon: LucideIcons.share2,
          accent: const ProfileRowAccent(Color(0xFFD86AE8), Color(0xFFC233DB)),
          onTap: () => showShareAlrtSheet(context),
        ),
      ],
    );
  }

  /// Danger zone: destructive actions only — the warm red the rest of the
  /// screen deliberately avoids, reserved for something that matters.
  Widget _buildDangerZoneSection() {
    return Container(
      decoration: BoxDecoration(
        color: ProfileColors.dangerAction.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20.spMin),
        border: Border.all(
          color: ProfileColors.dangerAction.withValues(alpha: 0.25),
        ),
      ),
      child: _buildProfileRow(
        title: 'Delete Account',
        subtitle: 'Permanently delete your account and data',
        icon: LucideIcons.trash2,
        accent: const ProfileRowAccent(
          ProfileColors.dangerAction,
          ProfileColors.dangerAction,
        ),
        titleColor: ProfileColors.dangerAction,
        onTap: _gotoDeleteAccountScreen,
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Button.gradient(
      value: 'Logout',
      icon: Icon(Icons.logout),
      onPressed: () {
        _showLogoutDialog();
      },
    );
  }

  /// Bottom sheet to switch between the supported languages.
  void _showLanguagePicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      builder: (sheetContext) {
        final currentCode = context.locale.languageCode;
        Widget languageTile({
          required String code,
          required String title,
          required String subtitle,
        }) {
          final isSelected = currentCode == code;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? AppColors.orange
                  : sheetContext.surfaceMuted,
              child: Text(
                code.toUpperCase(),
                style: TextStyle(
                  color: isSelected
                      ? AppColors.white
                      : sheetContext.onSurfaceMuted,
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 15.spMin,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(subtitle, style: TextStyle(fontSize: 12.spMin)),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: AppColors.orange)
                : null,
            onTap: () {
              context.setLocale(Locale(code));
              Navigator.of(sheetContext).pop();
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.spMin),
                child: Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 18.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              languageTile(
                code: 'en',
                title: 'English',
                subtitle: 'English',
              ),
              // Spanish hidden until the app is actually localised — only ~5
              // strings are translated today, so switching locale changes
              // nothing visible. Restore this tile when full l10n lands.
              // languageTile(
              //   code: 'es',
              //   title: 'Español',
              //   subtitle: 'Spanish',
              // ),
              Padding(
                padding: EdgeInsets.all(16.spMin),
                child: Text(
                  'Official warnings are shown in their original English wording where a verified translation is not yet available.',
                  style: TextStyle(
                    fontSize: 11.spMin,
                    color: sheetContext.onSurfaceMuted,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // The Light/Dark/Device Appearance picker (and its ProfileColors.appearance
  // accent) is deliberately not wired into any row right now - see the
  // comment on _buildPreferencesSection. Removed here rather than left as
  // dead code so `flutter analyze` stays clean; appearance_provider.dart
  // and AppTheme.darkPalette are untouched and ready to be reconnected
  // when full accessibility support is designed.

  /// Bottom sheet to change the profile photo — the upload logic already
  /// existed (profile_provider.dart) but had no UI trigger before this
  /// redesign. No name/email editing here: that is not implemented.
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
              leading: Icon(Icons.camera_alt_rounded, color: AppColors.blue),
              title: Text(
                'Take Photo',
                style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref
                    .read(providerOfProfile.notifier)
                    .updateProfilePicture(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: AppColors.purple),
              title: Text(
                'Choose from Library',
                style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref
                    .read(providerOfProfile.notifier)
                    .updateProfilePicture(source: ImageSource.gallery);
              },
            ),
            8.spMin.hSizedBox,
          ],
        ),
      ),
    );
  }

  /// Journey sharing only has a real destination once the user actually
  /// belongs to a circle (FamilyJourneyScreen falls back to a blank screen
  /// otherwise) — reuses the exact same membership check FamilyTabView
  /// already applies, rather than inventing a new gate. With no circle
  /// yet, this lands on the same Family tab / onboarding screen the
  /// Family highlight card above also goes to.
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

  Widget _buildStatItem({
    required final int value,
    required final String label,
    required final Color valueColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(20.spMin),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 2.0,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        vertical: 14.spMin,
        horizontal: 10.spMin,
      ),
      child: Column(
        spacing: 2.spMin,
        children: [
          Text(
            NumberFormat.compact().format(value),
            style: GoogleFonts.poppins(
              fontSize: 30.spMin,
              fontWeight: FontWeight.bold,
              color: valueColor,
              height: 1.0,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12.spMin,
              color: context.onSurfaceMuted.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Section headings (approved redesign 2026-09-03): dark, bold and
  /// letter-spaced so each group reads as a real heading, not a faint
  /// caption. Primary text colour, never a washed-out grey - the old 60%
  /// grey fell below the contrast a heading needs.
  TextStyle _sectionLabelStyle() => TextStyle(
        fontSize: 13.spMin,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: context.onSurface,
      );

  /// A grouped-card section: an uppercase heading above a single white
  /// rounded card holding [rows] — the shared shape every Profile section
  /// below the header uses.
  Widget _buildSectionCard({
    required final String label,
    required final List<Widget> rows,
  }) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.spMin,
      children: [
        Text(label.toUpperCase(), style: _sectionLabelStyle()),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceCard,
            borderRadius: BorderRadius.circular(20.spMin),
            boxShadow: [
              BoxShadow(
                color: context.cardShadow,
                blurRadius: 2.0,
                offset: Offset(0.0, 0.0),
              ),
            ],
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  /// A single Profile row: a calm, single-colour icon (never a gradient -
  /// gradients stay reserved for the two highlight cards above), title/
  /// subtitle, an optional trailing chip, then the chevron.
  Widget _buildProfileRow({
    required final String title,
    required final String subtitle,
    required final IconData icon,
    required final ProfileRowAccent accent,
    required final VoidCallback onTap,
    final Widget? trailing,
    final Color? titleColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          ProfileGradientIcon(icon: icon, accent: accent),
          16.wSizedBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? context.onSurface,
                  ),
                ),
                2.spMin.hSizedBox,
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    color: context.onSurfaceMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[trailing, 8.wSizedBox],
          Icon(
            Icons.chevron_right,
            color: context.outline,
            size: 20.spMin,
          ),
        ],
      ),
    ).onPressed(onTap);
  }

  /// Neutral count pill for Saved locations — a real count, never an
  /// invented "X of Y" against a free-tier cap that does not exist yet.
  Widget _buildCountChip(final int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.spMin, vertical: 3.spMin),
      decoration: BoxDecoration(
        color: context.surfaceMuted,
        borderRadius: BorderRadius.circular(20.spMin),
      ),
      child: Text(
        count == 1 ? '1 saved' : '$count saved',
        style: TextStyle(
          fontSize: 10.5.spMin,
          fontWeight: FontWeight.w700,
          color: context.onSurfaceMuted,
        ),
      ),
    );
  }

  Widget _buildViewAllButton({
    required final String text,
    final Function()? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16.spMin),
      child: Container(
        padding: EdgeInsets.all(16.spMin),
        decoration: BoxDecoration(
          color: context.surfaceCard,
          border: Border.all(
            color: context.outline.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16.spMin),
          boxShadow: [
            BoxShadow(
              color: context.cardShadow,
              blurRadius: 2.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14.spMin,
                color: context.onSurfaceMuted.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            8.spMin.wSizedBox,
            Icon(
              LucideIcons.arrowRight500,
              size: 16.spMin,
              color: context.onSurfaceMuted.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'U';
  }

  // ignore: unused_element
  String _reliabilityDescription(double score) {
    if (score >= 0.8) {
      return 'Excellent';
    } else if (score >= 0.6) {
      return 'Good';
    } else if (score >= 0.4) {
      return 'Average';
    } else if (score >= 0.2) {
      return 'Below Average';
    } else {
      return 'Poor';
    }
  }

  /// Listens to the profile picture update state changes and shows appropriate toasts.
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

  /// Listens to the logout state changes and navigates to the AppWrapper on success.
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

  /// Shows a confirmation dialog for logging out.
  void _showLogoutDialog() {
    showConfirmationSheet(
      context: context,
      title: 'Are you sure you want to logout?',
      description: 'You will need to log in again to access your account.',
      onPressedConfirmAsync: (context, ref) =>
          ref.read(providerOfProfile.notifier).logout(),
    );
  }

  /// Navigates to the My Accepted Reports screen.
  void _gotoMyAcceptedReportsScreen() {
    context.push(
      MyHazardsScreen.route,
      extra: const MyHazardsScreenArgs(
        initialTab: MyHazardsTab.accepted,
      ),
    );
  }

  /// Navigates to the My Rejected Reports screen.
  void _gotoMyRejectedReportsScreen() {
    context.push(
      MyHazardsScreen.route,
      extra: const MyHazardsScreenArgs(
        initialTab: MyHazardsTab.rejected,
      ),
    );
  }

  /// Navigates to the Support Request screen.
  void _gotoSupportRequestScreen() {
    context.push(SupportRequestScreen.route);
  }

  /// Navigates to the Delete Account screen.
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

  String _currentLanguageLabel() {
    return switch (context.locale.languageCode) {
      'es' => 'Español',
      _ => 'English',
    };
  }

}
