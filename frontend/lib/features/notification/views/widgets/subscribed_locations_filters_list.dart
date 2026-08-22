import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/notification/views/widgets/subscribed_locations_filters_list_item.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SubscribedLocationsFiltersList extends ConsumerStatefulWidget {
  const SubscribedLocationsFiltersList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SubscribedLocationsFiltersListState();
}

class _SubscribedLocationsFiltersListState
    extends ConsumerState<SubscribedLocationsFiltersList> {
  @override
  Widget build(BuildContext context) {
    final locationSubscriptions = ref.watch(
      providerOfMyLocationSubscriptions.select(
        (value) => value.locationSubscriptions,
      ),
    );
    return SizedBox(
      height: 48.spMin,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: 20.spMin,
          vertical: 8.spMin,
        ),
        itemCount: locationSubscriptions.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAllLocationSubscription();
          }

          final subscription = locationSubscriptions[index - 1];
          return SubscribedLocationsFiltersListItem(
            subscription: subscription,
          );
        },
        separatorBuilder: (context, index) => 10.wSizedBox,
      ),
    );
  }

  Widget _buildAllLocationSubscription() {
    return Consumer(
      builder: (context, ref, child) {
        final isSelected = ref.watch(
          providerOfHazardFiltersForNotifications.select(
            (value) => value.selectedLocationIds.isEmpty,
          ),
        );
        return Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.orange : AppColors.white,
            borderRadius: BorderRadius.circular(12.spMin),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 2.0,
                offset: Offset(0.0, 0.0),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 14.spMin,
            vertical: 6.spMin,
          ),
          child: Row(
            spacing: 5.spMin,
            children: [
              Icon(
                LucideIcons.mapPin,
                size: 12.spMin,
                color: isSelected ? AppColors.white : AppColors.orange,
              ),
              Text(
                'All',
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.black,
                ),
              ),
            ],
          ),
        ).onPressed(_onAllLocationSubscriptionTap);
      },
    );
  }

  void _onAllLocationSubscriptionTap() {
    ref
        .read(providerOfHazardFiltersForNotifications.notifier)
        .updateSelectedLocationIds({});

    // get notifications feed hazards
    ref
        .read(providerOfNotificationsFeed.notifier)
        .getNotificationsFeedHazards();
  }
}
