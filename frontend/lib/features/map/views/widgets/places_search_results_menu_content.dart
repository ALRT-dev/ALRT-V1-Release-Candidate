import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/map/providers/states/places_provider_state.dart';
import 'package:hazard_app/features/map/views/widgets/places_search_results_menu_content_item.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';

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
    this.showMatchingAlerts = false,
  });

  final void Function(GooglePlace)? onPlaceSelected;

  /// Map search only ("Search a place or alert", 16 Oct 2026): alerts
  /// already on the map whose title, place or category match the words are
  /// listed above the places.
  final bool showMatchingAlerts;

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
    final query = ref.watch(
      providerOfPlaces(widget.placesSearchKey).select(
        (value) => value.searchString,
      ),
    );
    final alerts = widget.showMatchingAlerts
        ? _matchingAlerts(query)
        : const <Hazard>[];

    final Widget body;
    if (places.isNotEmpty || alerts.isNotEmpty) {
      body = _listBuilder(places, alerts);
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

  Widget _listBuilder(
    final List<GooglePlace> places,
    final List<Hazard> alerts,
  ) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 4.spMin),
      // Drag the list to put the keyboard away, as in Maps.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (alerts.isNotEmpty) ...[
          _header('ALERTS'),
          for (final alert in alerts) _AlertResultRow(alert: alert),
          if (places.isNotEmpty) _header('PLACES'),
        ],
        for (final place in places)
          PlacesSearchResultsMenuContentItem(
            place: place,
            onSelected: widget.onPlaceSelected,
          ),
      ],
    );
  }

  /// Every word of 3+ letters must appear in the alert's title, place or
  /// category. Expired alerts are left out. At most 4, most serious first.
  List<Hazard> _matchingAlerts(final String query) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 3)
        .toList();
    if (words.isEmpty || !ref.exists(providerOfMap)) return const <Hazard>[];
    final List<Hazard> hazards;
    try {
      hazards = ref.read(providerOfMap).hazards;
    } catch (_) {
      return const <Hazard>[];
    }
    final matches = hazards.where((h) {
      if (h.isExpired) return false;
      final text = '${h.title ?? ''} ${h.locationName ?? ''} '
              '${h.category?.name ?? ''}'
          .toLowerCase();
      return words.every(text.contains);
    }).toList()
      ..sort(
        (a, b) => (b.severityBand?.index ?? 0).compareTo(
          a.severityBand?.index ?? 0,
        ),
      );
    return matches.take(4).toList();
  }

  Widget _header(final String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.spMin, 12.spMin, 16.spMin, 4.spMin),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.spMin,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: const Color(0xFFB84500),
        ),
      ),
    );
  }
}

class _AlertResultRow extends StatelessWidget {
  const _AlertResultRow({required this.alert});

  final Hazard alert;

  @override
  Widget build(BuildContext context) {
    final where = alert.locationName?.trim();
    final kind = alert.isUserReported
        ? 'Community report'
        : alert.isAwsCompliant == true
            ? alert.severityTitle
            : 'Official';
    return InkWell(
      onTap: () => context.push(
        ViewHazardScreen.route,
        extra: ViewHazardScreenArgs(hazard: alert),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 10.spMin),
        child: Row(
          children: [
            Container(
              width: 10.spMin,
              height: 10.spMin,
              decoration: BoxDecoration(
                color: alert.color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title ?? 'Alert',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E),
                    ),
                  ),
                  Text(
                    (where == null || where.isEmpty) ? kind : '$kind · $where',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: const Color(0xFF5C5C66),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
