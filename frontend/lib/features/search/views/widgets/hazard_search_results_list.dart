import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/search/providers/main_search_provider.dart';
import 'package:hazard_app/features/search/providers/states/main_search_provider_state.dart';
import 'package:hazard_app/features/search/views/widgets/hazard_search_subscribed_locations_list.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/features/shared/views/widgets/common_hazards_list_item.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';

class HazardSearchResultsList extends ConsumerStatefulWidget {
  const HazardSearchResultsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HazardSearchResultsListState();
}

class _HazardSearchResultsListState
    extends ConsumerState<HazardSearchResultsList> {
  @override
  Widget build(BuildContext context) {
    final getHazardsByLocationState = ref.watch(
      providerOfMainSearch.select(
        (value) => value.getHazardsByLocationState,
      ),
    );

    return getHazardsByLocationState.maybeWhen(
      loading: () => _loadingBuilder(),
      error: (error) => _errorBuilder(),
      success: (hazards) => _dataBuilder(),
      orElse: () => _emptyBuilder(),
    );
  }

  Widget _loadingBuilder() {
    return SliverFillRemaining(
      child: Spinner(),
    );
  }

  Widget _emptyBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final isSearchActive = ref.watch(
          providerOfPlacesForSearch.select(
            (value) => value.searchString.isNotEmpty,
          ),
        );

        if (!isSearchActive) {
          return SliverToBoxAdapter(
            child: HazardSearchSubscribedLocationsList(),
          );
        }

        final selectedLocation = ref.watch(
          providerOfMainSearch.select(
            (value) => value.searchedLocation,
          ),
        );

        final isSubscribed = ref.watch(
          providerOfMainSearch.select(
            (value) => value.subscriptionId != null,
          ),
        );

        return SliverFillRemaining(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10.spMin,
            children: [
              SvgPicture.asset(
                'assets/icons/search.svg',
                width: 40.spMin,
              ),
              Column(
                spacing: 5.spMin,
                children: [
                  Text(
                    isSearchActive
                        ? selectedLocation != null
                              ? 'No alerts around "${selectedLocation.displayName}"'
                              : 'Nothing to show'
                        : 'Subscribe to a location',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.spMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    isSearchActive
                        ? selectedLocation != null
                              ? isSubscribed
                                    ? 'You have already subscribed to get instant alerts and updates around ${selectedLocation.displayName}.'
                                    : 'You can subscribe to get instant alerts and updates around ${selectedLocation.displayName}.'
                              : 'No results found for your search. Please try changing it.'
                        : 'Please use the search bar to search for a location to see alerts around it and subscribe to it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.spMin,
                    ),
                  ),
                ],
              ),
              if (selectedLocation != null) _subscribeButtonBuilder(),
            ],
          ).pad(20.0),
        );
      },
    );
  }

  Widget _subscribeButtonBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(
          providerOfMainSearch.select(
            (value) =>
                value.subscribeToLocationState.maybeWhen(
                  orElse: () => false,
                  loading: () => true,
                ) ||
                value.unsubscribeFromLocationState.maybeWhen(
                  orElse: () => false,
                  loading: () => true,
                ),
          ),
        );
        final isSubscribed = ref.watch(
          providerOfMainSearch.select(
            (value) => value.subscriptionId != null,
          ),
        );

        return SizedBox(
          height: 40.spMin,
          child: Button.gradient(
            width: 150.spMin,
            isLoading: isLoading,
            onPressed: _handleSubscribePressed,
            padding: EdgeInsets.zero,
            icon: isLoading
                ? null
                : Icon(
                    isSubscribed
                        ? Icons.notifications_off_rounded
                        : Icons.notifications_active_rounded,
                    size: 18.0,
                  ),
            value: isLoading
                ? null
                : isSubscribed
                ? 'Unsubscribe'
                : 'Subscribe',
            iconAndTextSpacing: 5.0,
            valueStyle: const TextStyle(
              fontSize: 14,
            ),
          ),
        );
      },
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
          providerOfMainSearch.select(
            (value) => value.hazards,
          ),
        );
        final getNextHazardsByLocationState = ref.watch(
          providerOfMainSearch.select(
            (value) => value.getNextHazardsByLocationState,
          ),
        );
        final isLoadingMore = getNextHazardsByLocationState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        if (hazards.isEmpty) {
          return _emptyBuilder();
        }

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
              showTrustMeter: false,
            );
          },
          separatorBuilder: (context, index) => 20.hSizedBox,
        );
      },
    );
  }

  /// Handles the subscribe button press.
  void _handleSubscribePressed() {
    ref.read(providerOfMainSearch.notifier).toggleSubscription();
  }
}
