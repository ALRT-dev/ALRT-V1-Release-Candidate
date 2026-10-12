import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/utils/check_in_roll.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hazard_app/features/profile/providers/child_mode_provider.dart';

/// The frosted light floating navigation bar with icon + label for each
/// destination.
///
/// Six slots: Map, Alerts, Report (ALRT logo), Ready, Family, Me.
/// Each slot is a 50 px radius-14 tile that takes a tinted background
/// while active: brand orange for ordinary tabs, indigo for Family at
/// rest, teal while a check-in is asked of the user, SOS red while any SOS
/// runs. The map shows through around the pill. Labels sit beneath icons.
class HomeTabbar extends ConsumerStatefulWidget {
  const HomeTabbar({
    super.key,
    required this.tabController,
  });

  /// The tab controller.
  final TabController tabController;

  /// Total vertical space the floating pill occupies (pill + bottom gap).
  static const double height = 86.0;

  /// Indigo accent for the Family destination.
  static const familyIndigo = FamilyColors.indigo;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeTabbarState();
}

class _HomeTabbarState extends ConsumerState<HomeTabbar> {
  /// Frosted light background: translucent white so the map bleeds
  /// through, with a backdrop blur applied in the build method.
  static const _pillColor = Color(0xCCF5F5F7);
  static const _activeCircleColor = AppColors.orange;

  /// The active tile tint for ordinary tabs; Family picks its own.
  static const _activeTileAlpha = 0.10;

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(providerOfHomeTab);
    // Child mode drops the ALRT slot, which is the way in to Report an
    // ALRT: a child can see hazards and raise an SOS, but does not publish
    // to strangers.
    final isChildMode = ref.watch(providerOfIsChildMode);
    final tabs = HomeTab.values
        .where((tab) => !(isChildMode && tab == HomeTab.list))
        .toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.spMin,
          right: 20.spMin,
          bottom: 10.spMin,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.spMin),
          child: BackdropFilter(
            filter: _frostedFilter,
            child: Container(
              height: 68.spMin,
              decoration: BoxDecoration(
                color: _pillColor,
                borderRadius: BorderRadius.circular(18.spMin),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.5),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.08),
                    blurRadius: 20.0,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.spMin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: tabs
                    .map((tab) =>
                        _tabItemBuilder(tab, isActive: tab == currentTab))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static final _frostedFilter = ImageFilter.blur(sigmaX: 20, sigmaY: 20);

  /// The 58 px radius-14 tile (room around the icon and label) every slot sits in. [tint] is the active
  /// background, or null for a slot at rest.
  Widget _tileBuilder({
    required final Color? tint,
    required final Widget icon,
    required final Widget label,
  }) {
    return Container(
      width: 58.spMin,
      height: 58.spMin,
      margin: EdgeInsets.symmetric(horizontal: 1.spMin),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18.spMin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36.spMin,
            height: 28.spMin,
            child: Center(child: icon),
          ),
          SizedBox(height: 2.spMin),
          label,
        ],
      ),
    );
  }

  Widget _tabItemBuilder(final HomeTab tab, {required final bool isActive}) {
    // The family slot has its own builder: its colour and dot change with
    // the family state (idle / asked / SOS).
    if (tab == HomeTab.family) {
      return _familyTabItemBuilder(isActive: isActive);
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabChanged(tab),
        child: Center(
          child: _tileBuilder(
            tint: isActive
                ? _activeCircleColor.withValues(alpha: _activeTileAlpha)
                : null,
            icon: _tabIconBuilder(tab, isActive: isActive),
            label: Text(
              tab.title,
              style: TextStyle(
                fontSize: 10.spMin,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: _labelColor(tab, isActive: isActive),
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  /// The full family tab slot, state-aware: indigo when idle, teal with a
  /// dot when a check-in is asked of the user, red with a dot during SOS.
  Widget _familyTabItemBuilder({required final bool isActive}) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabChanged(HomeTab.family),
        child: Center(
          child: Consumer(
            builder: (context, ref, child) {
              final isSosActive = ref.watch(
                providerOfFamily.select(
                  (s) => s.activeSosEvents.isNotEmpty,
                ),
              );
              // Teal only for a real ask: fresh, aimed at me, unanswered.
              // Without an ask the roll's notYet is just "not checked in
              // today", which is silence, never a reason to light up.
              final isAskedOfMe = ref.watch(
                providerOfFamily.select((s) {
                  final circle = s.circle;
                  if (circle == null) return false;
                  return CheckInRoll.of(circle).isAskedOf(circle.myMemberId);
                }),
              );

              // SOS trumps asked; both trump idle.
              final Color accent;
              final bool showDot;
              final double tintAlpha;
              if (isSosActive) {
                accent = FamilyColors.sosRed;
                showDot = true;
                tintAlpha = 0.10;
              } else if (isAskedOfMe) {
                accent = FamilyColors.teal;
                showDot = true;
                tintAlpha = 0.12;
              } else {
                accent = FamilyColors.indigo;
                showDot = false;
                tintAlpha = 0.10;
              }

              return _tileBuilder(
                tint: isActive ? accent.withValues(alpha: tintAlpha) : null,
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      HomeTab.family.iconData,
                      size: 22.spMin,
                      color: isActive
                          ? accent
                          : accent.withValues(alpha: 0.75),
                    ),
                    if (showDot)
                      Positioned(
                        top: -1,
                        right: -1,
                        child: Container(
                          width: 7.spMin,
                          height: 7.spMin,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                label: Text(
                  HomeTab.family.title,
                  style: TextStyle(
                    fontSize: 10.spMin,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: accent,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Label colour: active tabs are orange, rest are medium grey. The
  /// family tab has its own builder and never reaches here.
  Color _labelColor(final HomeTab tab, {required final bool isActive}) {
    return isActive ? _activeCircleColor : AppColors.mediumGrey;
  }

  Widget _tabIconBuilder(final HomeTab tab, {required final bool isActive}) {
    switch (tab) {
      case HomeTab.list:
        // The mark sits in its locked 32x26 box, never redrawn and never
        // substituted for a glyph. Contain rather than a bare height, so
        // the box is the spec and the artwork fits itself to it.
        return SizedBox(
          width: 26.spMin,
          height: 22.spMin,
          child: SvgPicture.asset(
            // The six-path mark, never redrawn and never substituted for
            // a glyph. Vector so it stays crisp in its locked box.
            'assets/logos/alrt_logo.svg',
            fit: BoxFit.contain,
          ),
        );
      case HomeTab.notifications:
        return _alertsIconBuilder(isActive: isActive);
      case HomeTab.family:
        // Handled by _familyTabItemBuilder; this case is unreachable.
        return const SizedBox.shrink();
      case HomeTab.profile:
        return _profileAvatarBuilder(isActive: isActive);
      default:
        return Icon(
          tab.iconData,
          size: 22.spMin,
          color: isActive ? _activeCircleColor : AppColors.mediumGrey,
        );
    }
  }

  /// Alerts bell with an unread dot when fresh alerts exist in the feed.
  Widget _alertsIconBuilder({required final bool isActive}) {
    return Consumer(
      builder: (context, ref, child) {
        final hasFreshAlerts = ref.watch(
          providerOfNotificationsFeed.select(
            (value) => value.hazards.any(
              (hazard) =>
                  hazard.createdAt != null &&
                  DateTime.now().difference(hazard.createdAt!).inHours < 24,
            ),
          ),
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              HomeTab.notifications.iconData,
              size: 22.spMin,
              color: isActive ? _activeCircleColor : AppColors.mediumGrey,
            ),
            if (hasFreshAlerts)
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: 7.spMin,
                  height: 7.spMin,
                  decoration: const BoxDecoration(
                    color: AppColors.emergency,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// The user's avatar as the Me destination.
  Widget _profileAvatarBuilder({required final bool isActive}) {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.watch(providerOfLoggedInUser);
        final profilePictureUrl = user?.profilePictureUrl;

        final avatar = profilePictureUrl != null && profilePictureUrl.isNotEmpty
            ? CircleAvatar(
                radius: 12.spMin,
                backgroundImage: CachedNetworkImageProvider(profilePictureUrl),
              )
            : CircleAvatar(
                radius: 12.spMin,
                backgroundColor: AppColors.orange,
                child: Text(
                  user?.initials ?? '?',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 9.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );

        // Locked rule: the avatar wears a ring while any live share or SOS
        // is running, so something of yours being shared is never silent.
        final isSosRunning = ref.watch(
          providerOfFamily.select((s) => s.activeSosEvents.isNotEmpty),
        );
        final isSharingLive = ref.watch(
          providerOfFamily.select((s) {
            final expiresAt = s.circle?.me?.locationExpiresAt;
            return expiresAt != null && expiresAt.isAfter(DateTime.now());
          }),
        );

        if (isSosRunning || isSharingLive) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSosRunning
                    ? FamilyColors.sosRed
                    : FamilyColors.indigo,
                width: 2.5,
              ),
            ),
            child: avatar,
          );
        }

        if (!isActive) return avatar;

        // Active: a 2 px white ring inside a 2 px orange ring. The orange
        // spread is painted first so the white sits on top of it.
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: _activeCircleColor, spreadRadius: 4),
              BoxShadow(color: AppColors.white, spreadRadius: 2),
            ],
          ),
          child: avatar,
        );
      },
    );
  }

  /// Updates the current selected tab.
  void _onTabChanged(final HomeTab tab) {
    context.unfocusInputs();
    ref.read(providerOfHomeTab.notifier).state = tab;
  }
}
