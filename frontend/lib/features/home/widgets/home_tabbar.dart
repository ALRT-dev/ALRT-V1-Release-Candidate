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

/// The dark floating pill navigation bar.
///
/// Icons-only so six destinations fit comfortably: Map, Search, ALRT,
/// Alerts (with unread dot), Family (indigo) and the user's avatar as
/// Profile. The map shows through around it.
class HomeTabbar extends ConsumerStatefulWidget {
  const HomeTabbar({
    super.key,
    required this.tabController,
  });

  /// The tab controller.
  final TabController tabController;

  /// Total vertical space the floating pill occupies (pill + bottom gap).
  static const double height = 76.0;

  /// Indigo accent for the Family destination.
  static const familyIndigo = Color(0xFF7C7CE0);

  /// The ring the avatar wears while an SOS is running.
  static const _sosRing = Color(0xFFE4002B);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeTabbarState();
}

class _HomeTabbarState extends ConsumerState<HomeTabbar> {
  static const _pillColor = Color(0xFF23252B);
  static const _activeCircleColor = Color(0xFF3A3D45);

  /// The capsule sits on a soft purply-blue halo, matched by the search
  /// bar's orange one, so the floating controls read as one set.
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
        padding: EdgeInsets.only(left: 20.spMin, right: 20.spMin, bottom: 10.spMin),
        child: Container(
          height: 62.spMin,
          decoration: BoxDecoration(
            color: _pillColor,
            borderRadius: BorderRadius.circular(40.spMin),
            boxShadow: [
              // Wide, low-opacity halo first, then the grounding shadow.
              BoxShadow(
                color: _glowColor.withValues(alpha: 0.38),
                blurRadius: 26.0,
                spreadRadius: 1.0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.25),
                blurRadius: 16.0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.spMin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: tabs
                .map((tab) => _tabItemBuilder(tab, isActive: tab == currentTab))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _tabItemBuilder(final HomeTab tab, {required final bool isActive}) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabChanged(tab),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46.spMin,
            height: 46.spMin,
            decoration: BoxDecoration(
              color: isActive ? _activeCircleColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(child: _tabIconBuilder(tab, isActive: isActive)),
          ),
        ),
      ),
    );
  }

  Widget _tabIconBuilder(final HomeTab tab, {required final bool isActive}) {
    switch (tab) {
      case HomeTab.list:
        // The mark sits in its locked 32x26 box, never redrawn and never
        // substituted for a glyph. Contain rather than a bare height, so
        // the box is the spec and the artwork fits itself to it.
        return SizedBox(
          width: 32.spMin,
          height: 26.spMin,
          child: SvgPicture.asset(
            // The six-path mark, never redrawn and never substituted for
            // a glyph. Vector so it stays crisp in its locked 32x26 box.
            'assets/logos/alrt_logo.svg',
            fit: BoxFit.contain,
          ),
        );
      case HomeTab.notifications:
        return _alertsIconBuilder(isActive: isActive);
      case HomeTab.family:
        return Icon(
          tab.iconData,
          size: 23.spMin,
          color: isActive ? HomeTabbar.familyIndigo : HomeTabbar.familyIndigo.withValues(alpha: 0.75),
        );
      case HomeTab.profile:
        return _profileAvatarBuilder(isActive: isActive);
      default:
        return Icon(
          tab.iconData,
          size: 23.spMin,
          color: isActive ? AppColors.white : AppColors.grey,
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
              size: 23.spMin,
              color: isActive ? AppColors.white : AppColors.grey,
            ),
            if (hasFreshAlerts)
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: 8.spMin,
                  height: 8.spMin,
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

  /// The user's avatar as the Profile destination.
  Widget _profileAvatarBuilder({required final bool isActive}) {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.watch(providerOfLoggedInUser);
        final profilePictureUrl = user?.profilePictureUrl;

        final avatar = profilePictureUrl != null && profilePictureUrl.isNotEmpty
            ? CircleAvatar(
                radius: 14.spMin,
                backgroundImage: CachedNetworkImageProvider(profilePictureUrl),
              )
            : CircleAvatar(
                radius: 14.spMin,
                backgroundColor: AppColors.orange,
                child: Text(
                  user?.initials ?? '?',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11.spMin,
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
