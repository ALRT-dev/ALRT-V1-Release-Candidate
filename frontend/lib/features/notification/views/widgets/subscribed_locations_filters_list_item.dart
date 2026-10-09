import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SubscribedLocationsFiltersListItem extends ConsumerStatefulWidget {
  const SubscribedLocationsFiltersListItem({
    super.key,
    required this.subscription,
  });

  /// The subscription to display.
  final LocationSubscription subscription;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SubscribedLocationsFiltersListItemState();
}

class _SubscribedLocationsFiltersListItemState
    extends ConsumerState<SubscribedLocationsFiltersListItem> {
  @override
  Widget build(BuildContext context) {
    final isSelected = ref.watch(
      providerOfHazardFiltersForNotifications.select(
        (value) => value.selectedLocationIds.contains(widget.subscription.id),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.orange : AppColors.white,
        borderRadius: BorderRadius.circular(12.spMin),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.orange.withValues(alpha: 0.5)
                : AppColors.shadowColor,
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
            widget.subscription.isOwnLocation
                ? 'My Location'
                : widget.subscription.name ?? 'Unknown Location',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.black,
            ),
          ),
        ],
      ),
    ).onPressed(_onTap);
  }

  void _onTap() {
    if (widget.subscription.id == null) {
      return;
    }
    ref
        .read(providerOfHazardFiltersForNotifications.notifier)
        .toggleLocationId(widget.subscription.id!);

    // get notifications feed hazards
    ref
        .read(providerOfNotificationsFeed.notifier)
        .getNotificationsFeedHazards();
  }
}
