import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/ask_alrt/views/ask_alrt_sheet.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/notification/providers/alerts_display_provider.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/notification/views/screens/push_inbox_screen.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_filters_provider_state.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Plain white pinned header for the Alerts feed (Feed board, 16 Oct
/// 2026): the title, then Ask ALRT, the notifications inbox and Filters.
/// Search lives in the Map search bar.
class NotificationsAppBar extends ConsumerStatefulWidget {
  const NotificationsAppBar({super.key});

  static const filtersKey = kSharedAlertFiltersKey;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationsAppBarState();
}

class _NotificationsAppBarState extends ConsumerState<NotificationsAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      shadowColor: AppColors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      floating: false,
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      titleSpacing: 20.spMin,
      toolbarHeight: 80.spMin,
      centerTitle: false,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alerts',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 28.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 4.spMin),
          _savedLocationsPill(),
        ],
      ),
      // Feed board: Ask ALRT, the notifications inbox, then Filters.
      actions: [
        _squareButtonBuilder(
          semanticLabel: 'Ask ALRT',
          icon: LucideIcons.sparkles,
          iconColor: AppColors.orange,
          background: _askWash,
          bordered: false,
          onTap: () => showAskAlrtSheet(context),
        ),
        SizedBox(width: 8.spMin),
        _squareButtonBuilder(
          semanticLabel: 'Notifications',
          icon: LucideIcons.bell,
          iconColor: AppColors.ink,
          background: AppColors.white,
          bordered: true,
          onTap: () => context.push(PushInboxScreen.route),
        ),
        SizedBox(width: 8.spMin),
        _filtersButtonBuilder(),
        SizedBox(width: 20.spMin),
      ],
    );
  }

  static const _askWash = Color(0xFFFFF1E8);

  /// Pill toggle that switches the Alerts list between all map-visible alerts
  /// and only those inside the user's saved-location subscription boxes.
  Widget _savedLocationsPill() {
    return Consumer(
      builder: (context, ref, _) {
        final active = ref.watch(providerOfShowSavedLocationsOnly);
        return GestureDetector(
          onTap: () {
            final next = !active;
            ref.read(providerOfShowSavedLocationsOnly.notifier).state = next;
            if (next) {
              ref
                  .read(providerOfNotificationsFeed.notifier)
                  .getNotificationsFeedHazards(silent: true);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.spMin,
              vertical: 5.spMin,
            ),
            decoration: BoxDecoration(
              color: active ? AppColors.ink : AppColors.white,
              borderRadius: BorderRadius.circular(20.spMin),
              border: Border.all(
                color: active ? AppColors.ink : AppColors.lightGrey,
              ),
            ),
            child: Text(
              'My saved locations',
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.white : AppColors.ink,
              ),
            ),
          ),
        );
      },
    );
  }

  /// A 40x40 square header button.
  Widget _squareButtonBuilder({
    required final String semanticLabel,
    required final IconData icon,
    required final Color iconColor,
    required final Color background,
    required final bool bordered,
    required final VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40.spMin,
          height: 40.spMin,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12.spMin),
            border: bordered
                ? Border.all(color: AppColors.lightGrey, width: 1.0)
                : null,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20.spMin, color: iconColor),
        ),
      ),
    );
  }

  /// 40x40 white square with a hairline border, a red count badge when any
  /// filter is switched off, and the same filters sheet as the map.
  Widget _filtersButtonBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final count = ref.watch(
          providerOfHazardFilters(NotificationsAppBar.filtersKey).select(
            (value) => value.unselectedFiltersCount,
          ),
        );
        return GestureDetector(
          onTap: _showFiltersBottomSheet,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40.spMin,
                height: 40.spMin,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.spMin),
                  border: Border.all(color: AppColors.lightGrey, width: 1.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.slidersHorizontal,
                  size: 20.spMin,
                  color: AppColors.ink,
                ),
              ),
              if (count > 0)
                Positioned(
                  top: -4.spMin,
                  right: -4.spMin,
                  child: Container(
                    width: 18.spMin,
                    height: 18.spMin,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 11.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showFiltersBottomSheet() {
    showHazardFiltersBottomSheet(
      context: context,
      filtersKey: NotificationsAppBar.filtersKey,
      onFiltersUpdated: _getHazards,
    );
  }

  /// Fetches whichever Alerts list is currently shown.
  void _getHazards() {
    final showSaved = ref.read(providerOfShowSavedLocationsOnly);
    if (showSaved) {
      ref
          .read(providerOfNotificationsFeed.notifier)
          .getNotificationsFeedHazards();
    } else {
      ref.read(providerOfMap.notifier).getMapHazards();
    }
  }
}
