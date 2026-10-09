import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
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
/// Active slot highlighted in brand orange. The map shows through around
/// it. Labels sit beneath each icon.
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
  static const familyIndigo = Color(0xFF3D3DDF);

  /// The ring the avatar wears while an SOS is running.
  static const _sosRing = Color(0xFFE4002B);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeTabbarState();
}

class _HomeTabbarState extends ConsumerState<HomeTabbar> {
  /// Frosted light background: translucent white so the map bleeds
  /// through, with a backdrop blur applied in the build method.
  static const _pillColor = Color(0xE6F5F5F7);
  static const _activeCircleColor = AppColors.orange;

  /// The capsule sits on a soft shadow so it lifts off the map.
  static const _glowColor = AppColors.footerGlow;

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

  Widget _tabItemBuilder(final HomeTab tab, {required final bool isActive}) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabChanged(tab),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36.spMin,
                height: 36.spMin,
                decoration: BoxDecoration(
                  color: isActive ? _activeCircleColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: _tabIconBuilder(tab, isActive: isActive)),
              ),
              SizedBox(height: 2.spMin),
              Text(
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
            ],
          ),
        ),
      ),
    );
  }

  /// Label colour: Family is always indigo, active tabs are orange, rest
  /// are medium grey.
  Color _labelColor(final HomeTab tab, {required final bool isActive}) {
    if (tab == HomeTab.family) {
      return HomeTabbar.familyIndigo;
    }
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
        return Icon(
          tab.iconData,
          size: 20.spMin,
          color: isActive
              ? HomeTabbar.familyIndigo
              : HomeTabbar.familyIndigo.withValues(alpha: 0.75),
        );
      case HomeTab.profile:
        return _profileAvatarBuilder(isActive: isActive);
      default:
        return Icon(
          tab.iconData,
          size: 20.spMin,
          color: isActive ? AppColors.white : AppColors.mediumGrey,
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
              size: 20.spMin,
              color: isActive ? AppColors.white : AppColors.mediumGrey,
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

        final ringColor = isSosRunning
            ? HomeTabbar._sosRing
            : isSharingLive
            ? HomeTabbar.familyIndigo
            : isActive
            ? AppColors.white
            : null;

        return Container(
          decoration: ringColor == null
              ? null
              : BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor,
                    width: isSosRunning || isSharingLive ? 2.5 : 2,
                  ),
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
