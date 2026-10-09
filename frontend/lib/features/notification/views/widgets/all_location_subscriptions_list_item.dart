import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/providers/states/my_location_subscriptions_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/context_navigation_extension.dart';
import 'package:hazard_app/features/shared/extensions/date_time_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/others/app_colors.dart';

class AllLocationSubscriptionsListItem extends ConsumerStatefulWidget {
  const AllLocationSubscriptionsListItem({
    super.key,
    required this.subscription,
  });

  final LocationSubscription subscription;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AllLocationSubscriptionsListItemState();
}

class _AllLocationSubscriptionsListItemState
    extends ConsumerState<AllLocationSubscriptionsListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.spMin),
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.spMin),
        side: BorderSide(
          color: AppColors.lightGrey.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.spMin),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.spMin,
              height: 40.spMin,
              decoration: BoxDecoration(
                color: widget.subscription.isOwnLocation
                    ? AppColors.green.withValues(alpha: 0.1)
                    : AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.spMin),
              ),
              child: Icon(
                Icons.place,
                color: widget.subscription.isOwnLocation
                    ? AppColors.green
                    : AppColors.blue,
                size: 20.spMin,
              ),
            ),
            12.wSizedBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subscription.isOwnLocation
                        ? 'My Location'
                        : widget.subscription.name ?? 'Unknown Location',
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w600,
                      color: widget.subscription.isOwnLocation
                          ? AppColors.green
                          : AppColors.black,
                    ),
                  ),
                  2.hSizedBox,
                  Text(
                    widget.subscription.address ?? 'No address available',
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: AppColors.grey,
                      height: 1.3,
                    ),
                  ),
                  2.hSizedBox,
                  Text(
                    'Subscribed ${widget.subscription.createdAt?.formattedDateOnly}',
                    style: TextStyle(
                      fontSize: 11.spMin,
                      color: AppColors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  8.hSizedBox,

                  Row(
                    spacing: 10.spMin,
                    children: [
                      !widget.subscription.isOwnLocation
                          ? Consumer(
                              builder: (context, ref, child) {
                                final isLoading = ref.watch(
                                  providerOfMyLocationSubscriptions.select(
                                    (value) => value
                                        .unsubscribeFromLocationStateWrappers
                                        .any(
                                          (wrapper) =>
                                              wrapper.subscriptionId ==
                                                  widget.subscription.id &&
                                              wrapper
                                                  .unsubscribeFromLocationState
                                                  .maybeWhen(
                                                    orElse: () => false,
                                                    loading: () => true,
                                                  ),
                                        ),
                                  ),
                                );

                                return SizedBox(
                                  height: 30.spMin,
                                  child: Button.filled(
                                    width: 120.spMin,
                                    onPressed: _handleUnsubscribe,
                                    isLoading: isLoading,
                                    padding: EdgeInsets.zero,
                                    color: AppColors.red,
                                    iconAndTextSpacing: 5.0,
                                    icon: isLoading
                                        ? null
                                        : Icon(
                                            Icons.notifications_off_rounded,
                                            color: AppColors.white,
                                            size: 16.spMin,
                                          ),
                                    borderRadius: 8.0,
                                    value: isLoading ? null : 'Unsubscribe',
                                    valueStyle: TextStyle(
                                      fontSize: 12.spMin,
                                      color: AppColors.white,
                                    ),
                                  ),
                                );
                              },
                            )
                          : SizedBox(
                              height: 30.spMin,
                              child: Button.filled(
                                width: 120.spMin,
                                onPressed: _handleEditMyLocationTap,
                                iconAndTextSpacing: 5.0,
                                padding: EdgeInsets.zero,
                                color: AppColors.grey,
                                icon: Icon(
                                  Icons.edit_rounded,
                                  color: AppColors.white,
                                  size: 16.spMin,
                                ),
                                borderRadius: 8.0,
                                value: 'Edit Radius',
                                valueStyle: TextStyle(
                                  fontSize: 12.spMin,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 30.spMin,
                        child: Button.filled(
                          width: 120.spMin,
                          onPressed: _handleViewOnMap,
                          iconAndTextSpacing: 5.0,
                          padding: EdgeInsets.zero,
                          color: AppColors.orange,
                          icon: Icon(
                            Icons.map_rounded,
                            color: AppColors.white,
                            size: 16.spMin,
                          ),
                          borderRadius: 8.0,
                          value: 'View on Map',
                          valueStyle: TextStyle(
                            fontSize: 12.spMin,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  /// Handles the view on map action when the "View on Map" button is pressed.
  void _handleViewOnMap() {
    context.popUntilRoute(HomeScreen.route);
    ref.read(providerOfHomeTab.notifier).state = HomeTab.map;
    ref
        .read(providerOfMap.notifier)
        .animateToBounds(bounds: widget.subscription.bounds, padding: 0.0);
  }
}
