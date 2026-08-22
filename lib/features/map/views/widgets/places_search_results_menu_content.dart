import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/map/providers/states/places_provider_state.dart';
import 'package:hazard_app/features/map/views/widgets/places_search_results_menu_content_item.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';

class PlacesSearchResultsMenuContent extends ConsumerStatefulWidget {
  const PlacesSearchResultsMenuContent({
    super.key,
    this.onPlaceSelected,
    required this.placesSearchKey,
  });

  final void Function(GooglePlace)? onPlaceSelected;

  final String placesSearchKey;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MapSearchResultsListState();
}

class _MapSearchResultsListState
    extends ConsumerState<PlacesSearchResultsMenuContent> {
  @override
  Widget build(BuildContext context) {
    final getPlacesState = ref.watch(
      providerOfPlaces(widget.placesSearchKey).select(
        (value) => value.getPlacesState,
      ),
    );

    return getPlacesState.maybeWhen(
      loading: _loadingBuilder,
      error: (error) => _errorBuilder(),
      success: (_) => _dataBuilder(),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _loadingBuilder() {
    return Spinner();
  }

  Widget _errorBuilder() {
    return const Center(
      child: Text(
        'Error occurred while fetching places',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _emptyBuilder() {
    return const Center(
      child: Text(
        'No places found...',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _dataBuilder() {
    return Consumer(builder: (context, ref, child) {
      final places = ref.watch(
        providerOfPlaces(widget.placesSearchKey).select(
          (value) => value.places,
        ),
      );
      if (places.isEmpty) {
        return _emptyBuilder();
      }

      return ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          return PlacesSearchResultsMenuContentItem(
            place: places[index],
            onSelected: widget.onPlaceSelected,
          );
        },
      );
    });
  }
}
