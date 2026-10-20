import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/notification/views/widgets/hazard_notifications_list.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_filters_provider_state.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Pinned header for the Alerts feed: title, 'My saved location alerts'
/// pill button, and the filters button.
/// The pill opens a bottom sheet with the subscription-based feed so the
/// user can always reach their saved-location alerts without leaving the tab.
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(height: 6.spMin),
          GestureDetector(
            onTap: () => _showSavedLocationAlertsSheet(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.spMin,
                vertical: 5.spMin,
              ),
              decoration: BoxDecoration(
                color: AppColors.extraLightGrey,
                borderRadius: BorderRadius.circular(20.spMin),
                border: Border.all(color: AppColors.lightGrey, width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.mapPin,
                      size: 13.spMin,
                      color: AppColors.ink.withValues(alpha: 0.6)),
                  SizedBox(width: 5.spMin),
                  Text(
                    'My saved location alerts',
                    style: TextStyle(
                      fontSize: 12.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(width: 4.spMin),
                  Icon(LucideIcons.chevronRight,
                      size: 12.spMin,
                      color: AppColors.ink.withValues(alpha: 0.45)),
                ],
              ),
            ),
          ),
        ],
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
      onFiltersUpdated: _refreshSubscriptionFeed,
    );
  }

  /// Opens a bottom sheet showing only the subscription-based (saved
  /// location) alerts — alerts for places the user has explicitly saved.
  void _showSavedLocationAlertsSheet(BuildContext context) {
    _refreshSubscriptionFeed();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx2, sc) => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.spMin),
              topRight: Radius.circular(24.spMin),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.spMin),
              Center(
                child: Container(
                  width: 40.spMin,
                  height: 4.spMin,
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              SizedBox(height: 16.spMin),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.spMin),
                child: Row(
                  children: [
                    Icon(LucideIcons.mapPin,
                        size: 18.spMin, color: AppColors.ink),
                    SizedBox(width: 8.spMin),
                    Text(
                      'My saved location alerts',
                      style: TextStyle(
                        fontSize: 20.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20.spMin, 6.spMin, 20.spMin, 0),
                child: Text(
                  'Alerts for the locations you have saved.',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    color: AppColors.ink.withValues(alpha: 0.55),
                  ),
                ),
              ),
              SizedBox(height: 12.spMin),
              Expanded(
                child: CustomScrollView(
                  controller: sc,
                  slivers: [
                    SizedBox(height: 4.spMin).sliverBox,
                    SavedLocationHazardsList(),
                    SizedBox(height: 30.spMin).sliverBox,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshSubscriptionFeed() {
    ref
        .read(providerOfNotificationsFeed.notifier)
        .getNotificationsFeedHazards();
  }
}
