import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_filters_provider_state.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Plain white pinned header for the Alerts feed: the title and one
/// filters button. Search lives in the Map search bar, and the push inbox
/// is reached from elsewhere, so neither sits up here any more.
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
      toolbarHeight: 60.spMin,
      centerTitle: false,
      title: Text(
        'Alerts',
        style: TextStyle(
          color: AppColors.ink,
          fontSize: 28.spMin,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        _filtersButtonBuilder(),
        SizedBox(width: 20.spMin),
      ],
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

  /// Fetches the hazards for the notifications feed.
  void _getHazards() {
    ref
        .read(providerOfNotificationsFeed.notifier)
        .getNotificationsFeedHazards();
  }
}
