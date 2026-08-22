import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/providers/states/my_location_subscriptions_provider_state.dart';
import 'package:hazard_app/features/search/views/widgets/hazard_search_subscribed_locations_list_item.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';
import 'package:hazard_app/others/app_colors.dart';

class HazardSearchSubscribedLocationsList extends ConsumerStatefulWidget {
  const HazardSearchSubscribedLocationsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HazardSearchSubscribedLocationsListState();
}

class _HazardSearchSubscribedLocationsListState
    extends ConsumerState<HazardSearchSubscribedLocationsList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.spMin,
      children: [
        _titleBuilder(),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.spMin),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColorLight,
                blurRadius: 10.0,
                offset: Offset(0, 2.0),
              ),
            ],
          ),
          child: _listBuilder(),
        ),
        _buildSubscribeHint(),
        10.hSizedBox,
      ],
    ).pX(20.0);
  }

  Widget _titleBuilder() {
    return Text(
      'Subscribed Locations'.toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.orange,
      ),
    );
  }

  Widget _listBuilder() {
    final getLocationSubscriptionsState = ref.watch(
      providerOfMyLocationSubscriptions.select(
        (value) => value.getLocationSubscriptionsState,
      ),
    );

    return getLocationSubscriptionsState.maybeWhen(
      loading: _loadingBuilder,
      error: _errorBuilder,
      success: (_) => _dataBuilder(),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _loadingBuilder() {
    return SizedBox(
      height: 200.spMin,
      child: Center(child: Spinner()),
    );
  }

  Widget _emptyBuilder() {
    return SizedBox(
      height: 200.spMin,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Subscribe to a location',
            style: TextStyle(
              fontSize: 18.spMin,
              fontWeight: FontWeight.w500,
            ),
          ),
          5.hSizedBox,
          Text(
            'Please use the search bar to search for a location to see alerts around it and subscribe to it.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.spMin,
            ),
          ),
        ],
      ).pX(20.0),
    );
  }

  Widget _errorBuilder(final AppError error) {
    return SizedBox(
      height: 250.spMin,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Something went wrong!',
            style: TextStyle(
              fontSize: 16.spMin,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          5.hSizedBox,
          Text(
            'We are unable to load the data at the moment. Please try again later.',
            style: TextStyle(
              fontSize: 14.spMin,
            ),
            textAlign: TextAlign.center,
          ),
          20.hSizedBox,
          Button.filled(
            value: 'Try Again',
            width: 120.spMin,
            icon: Icon(Icons.refresh),
            iconAndTextSpacing: 5.0,
            padding: EdgeInsets.symmetric(
              vertical: 5.spMin,
            ),
            valueStyle: TextStyle(
              fontSize: 14.spMin,
            ),
            onPressed: () {
              ref
                  .read(providerOfMyLocationSubscriptions.notifier)
                  .getLocationSubscriptions();
            },
          ),
        ],
      ).pX(20.0),
    );
  }

  Widget _dataBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final locationSubscriptions = ref.watch(
          providerOfMyLocationSubscriptions.select(
            (value) => value.locationSubscriptions,
          ),
        );
        if (locationSubscriptions.isEmpty) return _emptyBuilder();

        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.spMin),
            itemCount: locationSubscriptions.length,
            separatorBuilder: (context, index) => Divider(
              height: 30.0,
              color: AppColors.grey.withValues(alpha: 0.05),
            ),
            itemBuilder: (context, index) {
              final subscription = locationSubscriptions[index];
              return HazardSearchSubscribedLocationsListItem(
                subscription: subscription,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSubscribeHint() {
    return Consumer(
      builder: (context, ref, child) {
        final locationSubscriptions = ref.watch(
          providerOfMyLocationSubscriptions.select(
            (value) => value.locationSubscriptions,
          ),
        );
        if (locationSubscriptions.length != 1) return const SizedBox.shrink();

        return Text(
          'Please use the search bar to search for a location to see alerts around it and subscribe to it. You are automatically subscribed to your current location.',
          style: TextStyle(
            fontSize: 12.spMin,
            color: AppColors.grey.withValues(alpha: 0.8),
            fontStyle: FontStyle.italic,
          ),
        );
      },
    );
  }
}
