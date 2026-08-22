import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/map/providers/states/places_provider_state.dart';
import 'package:hazard_app/features/map/views/widgets/place_search_results_item.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';

class PlaceSearchResultsList extends ConsumerStatefulWidget {
  const PlaceSearchResultsList({
    super.key,
    required this.placesSearchKey,
    this.onPlaceSelected,
    this.radiusFilter,
  });

  final void Function(GooglePlace)? onPlaceSelected;

  final String placesSearchKey;

  /// Optional filter function to check if a place is within radius.
  /// Returns true if the place should be included in results.
  final bool Function(double? latitude, double? longitude)? radiusFilter;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlaceSearchResultsListState();
}

class _PlaceSearchResultsListState
    extends ConsumerState<PlaceSearchResultsList> {
  @override
  Widget build(BuildContext context) {
    final getPlacesState = ref.watch(
      providerOfPlaces(widget.placesSearchKey).select(
        (value) => value.getPlacesState,
      ),
    );

    return getPlacesState.maybeWhen(
      loading: () => _loadingBuilder(),
      error: (error) => _errorBuilder(),
      success: (places) => _dataBuilder(),
      orElse: () => _emptyBuilder(),
    );
  }

  Widget _loadingBuilder() {
    return SliverFillRemaining(
      child: Spinner(),
    );
  }

  Widget _errorBuilder() {
    return SliverFillRemaining(
      child: const Center(
        child: Text(
          'Error occurred while fetching places',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _emptyBuilder() {
    return SliverFillRemaining(
      child: Center(
        child: Consumer(
          builder: (context, ref, child) {
            final isSearchActive = ref.watch(
              providerOfPlaces(widget.placesSearchKey).select(
                (value) => value.searchString.isNotEmpty,
              ),
            );
            return Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10.spMin,
              children: [
                Icon(
                  Icons.place_rounded,
                  size: 30.spMin,
                ),
                Column(
                  children: [
                    Text(
                      isSearchActive
                          ? 'No places found'
                          : 'Start searching for places',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isSearchActive)
                      Text(
                        'Please try a different search term.',
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ],
            ).pX(20.0).pB(80.0);
          },
        ),
      ),
    );
  }

  Widget _dataBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final places = ref.watch(
          providerOfPlaces(widget.placesSearchKey).select(
            (value) => value.places,
          ),
        );

        // Apply radius filter if provided
        final filteredPlaces = widget.radiusFilter != null
            ? places.where((place) {
                return widget.radiusFilter!(place.latitude, place.longitude);
              }).toList()
            : places;

        if (filteredPlaces.isEmpty) {
          return _emptyBuilder();
        }

        return SliverList.builder(
          itemCount: filteredPlaces.length,
          itemBuilder: (context, index) {
            return PlaceSearchResultsListItem(
              place: filteredPlaces[index],
              onSelected: widget.onPlaceSelected,
            );
          },
        );
      },
    );
  }
}
