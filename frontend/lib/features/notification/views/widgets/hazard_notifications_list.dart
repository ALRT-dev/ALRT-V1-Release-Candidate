import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/notification/providers/states/notifications_feed_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/common_hazards_list_item.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';

class HazardNotificationsList extends ConsumerStatefulWidget {
  const HazardNotificationsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HazardNotificationsListState();
}

class _HazardNotificationsListState
    extends ConsumerState<HazardNotificationsList> {
  @override
  Widget build(BuildContext context) {
    final getNotificationsFeedHazardsState = ref.watch(
      providerOfNotificationsFeed.select(
        (value) => value.getNotificationsFeedHazardsState,
      ),
    );

    return getNotificationsFeedHazardsState.maybeWhen(
      loading: _loadingBuilder,
      success: (_) => _dataBuilder(),
      error: (error) => _errorBuilder(),
      orElse: () => const SizedBox(),
    );
  }

  Widget _loadingBuilder() {
    return SliverFillRemaining(
      child: Spinner(),
    );
  }

  Widget _emptyBuilder() {
    return SliverFillRemaining(
      child: Consumer(
        builder: (context, ref, child) {
          final isSearchActive = ref.watch(
            providerOfNotificationsFeed.select(
              (value) => value.searchString.isNotEmpty,
            ),
          );
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10.spMin,
            children: [
              SvgPicture.asset(
                'assets/icons/notifications_tab_unselected.svg',
                width: 40.spMin,
              ),
              Column(
                spacing: 5.spMin,
                children: [
                  Text(
                    'Nothing to show!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    isSearchActive
                        ? 'No results found for your search. Please try changing it.'
                        : 'There are no alerts at the moment. Please check back later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ],
          ).pad(20.0);
        },
      ),
    );
  }

  Widget _errorBuilder() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Something went wrong!',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'We are unable to load the data at the moment. Please try again later.',
            textAlign: TextAlign.center,
          ),
        ],
      ).pad(20.0),
    );
  }

  Widget _dataBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hazards = ref.watch(
          providerOfNotificationsFeed.select(
            (value) => value.hazards,
          ),
        );
        if (hazards.isEmpty) {
          return _emptyBuilder();
        }

        final getNextNotificationsFeedHazardsState = ref.watch(
          providerOfNotificationsFeed.select(
            (value) => value.getNextNotificationsFeedHazardsState,
          ),
        );
        final isLoadingMore = getNextNotificationsFeedHazardsState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return SliverList.separated(
          itemCount: hazards.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == hazards.length) {
              // Show loading indicator at the bottom
              return Spinner().pad(20.0);
            }
            final hazard = hazards[index];
            return CommonHazardsListItem(
              key: ValueKey(hazard.id),
              hazard: hazard,
            );
          },
          separatorBuilder: (context, index) => 20.hSizedBox,
        );
      },
    );
  }
}
