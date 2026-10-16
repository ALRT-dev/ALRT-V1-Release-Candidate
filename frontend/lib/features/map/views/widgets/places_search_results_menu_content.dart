import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/map/providers/states/places_provider_state.dart';
import 'package:hazard_app/features/map/views/widgets/places_search_results_menu_content_item.dart';

/// Results under a places search box.
///
/// Typing never blanks the list: while a new query is in flight the last
/// results stay on screen with a thin progress line on top, and the full
/// spinner state only appears before the first results arrive (phone
/// review, 14 Oct 2026: the panel kept flashing to an empty spinner on
/// every letter).
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
  static const _hint = Color(0xFF5C5C66);

  @override
  Widget build(BuildContext context) {
    final getPlacesState = ref.watch(
      providerOfPlaces(widget.placesSearchKey).select(
        (value) => value.getPlacesState,
      ),
    );
    final places = ref.watch(
      providerOfPlaces(widget.placesSearchKey).select(
        (value) => value.places,
      ),
    );
    final isLoading = getPlacesState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final isError = getPlacesState.maybeWhen(
      error: (_) => true,
      orElse: () => false,
    );

    final Widget body;
    if (places.isNotEmpty) {
      body = _listBuilder(places);
    } else if (isLoading) {
      body = _messageBuilder('Searching...');
    } else if (isError) {
      body = _messageBuilder(
        "We couldn't search right now. Check your connection and try again.",
      );
    } else {
      body = getPlacesState.maybeWhen(
        success: (_) => _messageBuilder('No matching places. Try a suburb or street.'),
        orElse: () => const SizedBox.shrink(),
      );
    }

    return Stack(
      children: [
        Positioned.fill(child: body),
        // Thin progress line instead of replacing the list.
        if (isLoading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(14.spMin),
              ),
              child: const LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: Colors.transparent,
                color: Color(0xFFE8622A), // footer active orange
              ),
            ),
          ),
      ],
    );
  }

  Widget _messageBuilder(final String text) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.spMin, vertical: 16.spMin),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.spMin, color: _hint, height: 1.35),
        ),
      ),
    );
  }

  Widget _listBuilder(final List<GooglePlace> places) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 4.spMin),
      // Drag the list to put the keyboard away, as in Maps.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: places.length,
      itemBuilder: (context, index) {
        return PlacesSearchResultsMenuContentItem(
          place: places[index],
          onSelected: widget.onPlaceSelected,
        );
      },
    );
  }
}
