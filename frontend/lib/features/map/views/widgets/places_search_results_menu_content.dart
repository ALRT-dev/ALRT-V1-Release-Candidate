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
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';

class PlacesSearchResultsMenuContent extends ConsumerStatefulWidget {
  const PlacesSearchResultsMenuContent({
    super.key,
    this.onPlaceSelected,
    required this.placesSearchKey,
    this.showMatchingAlerts = false,
  });

  /// Map search only (prototype 16 Oct 2026, "Search a place or alert"):
  /// alerts already loaded on the map whose title or place match the words
  /// are listed above the places.
  final bool showMatchingAlerts;

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
      final query = ref.watch(
        providerOfPlaces(widget.placesSearchKey).select(
          (value) => value.searchString,
        ),
      );
      final alerts = widget.showMatchingAlerts
          ? _matchingAlerts(query)
          : const <Hazard>[];
      if (places.isEmpty && alerts.isEmpty) {
        return _emptyBuilder();
      }

      final children = <Widget>[
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
      ];
      return ListView(children: children);
    });
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
        ? 'Community report, unverified'
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
