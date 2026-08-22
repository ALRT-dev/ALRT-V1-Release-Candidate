import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HazardSearchSubscribedLocationsListItem extends ConsumerStatefulWidget {
  const HazardSearchSubscribedLocationsListItem({
    super.key,
    required this.subscription,
  });

  final LocationSubscription subscription;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HazardSearchSubscribedLocationsListItemState();
}

class _HazardSearchSubscribedLocationsListItemState
    extends ConsumerState<HazardSearchSubscribedLocationsListItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12.spMin,
      children: [
        _buildIcon(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationName(),
              _buildLocationAddressOrRadius(),
            ],
          ),
        ),
        widget.subscription.isOwnLocation
            ? _buildEditButton()
            : _buildUnsubscribeButton(),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40.spMin,
      height: 40.spMin,
      decoration: BoxDecoration(
        color: widget.subscription.isOwnLocation
            ? AppColors.green.withValues(alpha: 0.1)
            : AppColors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.spMin),
      ),
      child: Icon(
        LucideIcons.mapPin,
        color: widget.subscription.isOwnLocation
            ? AppColors.green
            : AppColors.orange,
        size: 20.spMin,
      ),
    );
  }

  Widget _buildLocationName() {
    return Text(
      widget.subscription.isOwnLocation
          ? 'My Location'
          : widget.subscription.name ?? 'Unknown Location',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: widget.subscription.isOwnLocation
            ? AppColors.green
            : AppColors.black,
      ),
    );
  }

  Widget _buildLocationAddressOrRadius() {
    return Consumer(
      builder: (context, ref, child) {
        final ownLocationRadiusKm =
            ref.read(providerOfLoggedInUser)?.ownLocationSubscriptionRadiusKm ??
            5;

        return Text(
          widget.subscription.isOwnLocation
              ? '${ownLocationRadiusKm}km radius'
              : widget.subscription.address ?? 'No address available',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.spMin,
            color: AppColors.grey,
          ),
        );
      },
    );
  }

  Widget _buildUnsubscribeButton() {
    return Container(
      width: 32.spMin,
      height: 32.spMin,
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.spMin),
      ),
      child: Icon(
        LucideIcons.trash2,
        color: AppColors.red,
        size: 16.spMin,
      ),
    ).onPressed(_handleUnsubscribe);
  }

  Widget _buildEditButton() {
    return Container(
      width: 32.spMin,
      height: 32.spMin,
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.spMin),
      ),
      child: Icon(
        LucideIcons.pencil,
        color: AppColors.green,
        size: 16.spMin,
      ),
    ).onPressed(_handleEditMyLocationTap);
  }

  /// Handles the tap action when the edit action is pressed.
  void _handleEditMyLocationTap() {
    final ownLocationRadiusKm =
        ref.read(providerOfLoggedInUser)?.ownLocationSubscriptionRadiusKm ?? 5;
    showChangeRadiusBottomsheet(
      context: context,
      initialRadius: ownLocationRadiusKm,
    );
  }

  /// Handles the unsubscribe action when the "Unsubscribe" button is pressed.
  void _handleUnsubscribe() {
    if (widget.subscription.id == null) return;

    showConfirmationSheet(
      context: context,
      title: 'Unsubscribe from Location',
      description:
          'Are you sure you want to unsubscribe from notifications for "${widget.subscription.name ?? 'this location'}"?',
      onPressedConfirmAsync: (context, ref) => ref
          .read(providerOfMyLocationSubscriptions.notifier)
          .unsubscribeFromLocation(subscriptionId: widget.subscription.id!),
    );
  }
}
