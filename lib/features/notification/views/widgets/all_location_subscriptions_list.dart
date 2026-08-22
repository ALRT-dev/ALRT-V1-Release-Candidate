import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/views/widgets/all_location_subscriptions_list_item.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/providers/states/my_location_subscriptions_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';

class AllLocationSubscriptionsList extends ConsumerStatefulWidget {
  const AllLocationSubscriptionsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AllLocationSubscriptionsListState();
}

class _AllLocationSubscriptionsListState
    extends ConsumerState<AllLocationSubscriptionsList> {
  @override
  Widget build(BuildContext context) {
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
    return Spinner();
  }

  Widget _errorBuilder(final AppError error) {
    return Center(
      child: Text(
        'An error occurred. Please try again later.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _emptyBuilder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Nothing to show here yet.',
            style: TextStyle(
              fontSize: 18.spMin,
              fontWeight: FontWeight.w500,
            ),
          ),
          5.hSizedBox,
          Text(
            'You have not subscribed to any locations yet. Subscribe to locations to receive alerts in those areas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.spMin,
            ),
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

        return ListView.builder(
          itemCount: locationSubscriptions.length,
          itemBuilder: (context, index) {
            final subscription = locationSubscriptions[index];
            return AllLocationSubscriptionsListItem(
              subscription: subscription,
            );
          },
        );
      },
    );
  }
}
