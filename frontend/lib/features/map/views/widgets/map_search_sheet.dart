import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/map/providers/states/places_provider_state.dart';
import 'package:hazard_app/features/map/views/widgets/alert_feed_row.dart';
import 'package:hazard_app/features/map/views/widgets/places_sheet.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Typed map search as a bottom sheet (prototype boards Search and
/// SearchResults, 16 Oct 2026).
///
/// Before anything is typed: YOUR PLACES (My location and each saved
/// place, which open Places) and NEAR YOU NOW (the most serious alerts
/// loaded on the map). Once something is typed: ALERTS MATCHING the words
/// as feed cards, then PLACES from the backend's place search, each with a
/// Save button. Tapping a place shows it on the map.
///
/// The words typed live in the map search's own places provider, so the
/// bar under the sheet shows the same text when it closes.
Future<void> showMapSearchSheet({
  required final BuildContext context,
  required final void Function(GooglePlace place) onPlaceSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.35),
    builder: (context) => MapSearchSheet(onPlaceSelected: onPlaceSelected),
  );
}

class MapSearchSheet extends ConsumerStatefulWidget {
  const MapSearchSheet({super.key, required this.onPlaceSelected});

  final void Function(GooglePlace place) onPlaceSelected;

  @override
  ConsumerState<MapSearchSheet> createState() => _MapSearchSheetState();
}

class _MapSearchSheetState extends ConsumerState<MapSearchSheet> {
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _line = Color(0xFFE3E6EA);
  static const _handle = Color(0xFFD9D6D0);

  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(providerOfPlacesForMap).searchString,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(final String value) {
    ref.read(providerOfPlacesForMap.notifier)
      ..updateSearchString(value.trim())
      ..updateGetPlacesToLoading();
    EasyDebounce.debounce(
      'map-search',
      const Duration(milliseconds: 280),
      () {
        if (!mounted) return;
        ref.read(providerOfPlacesForMap.notifier).getPlaces();
      },
    );
  }

  void _pickPlace(final GooglePlace place) {
    Navigator.of(context).maybePop();
    widget.onPlaceSelected(place);
  }

  Future<void> _savePlace(final GooglePlace place) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await savePlaceForAlerts(context: context, ref: ref, place: place);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openPlaces() {
    final navigator = Navigator.of(context);
    final parent = navigator.context;
    navigator.maybePop();
    showPlacesSheet(context: parent);
  }

  /// Every word of 3+ letters must appear in the alert's title, place or
  /// category. Expired alerts are left out. At most 4, most serious first.
  static List<Hazard> matchingAlerts(
    final String query,
    final List<Hazard> hazards,
  ) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 3)
        .toList();
    if (words.isEmpty) return const <Hazard>[];
    final matches = hazards.where((h) {
      if (h.isExpired) return false;
      final text = '${h.title ?? ''} ${h.locationName ?? ''} '
              '${h.category?.name ?? ''}'
          .toLowerCase();
      return words.every(text.contains);
    }).toList()
      ..sort(_mostSeriousFirst);
    return matches.take(4).toList();
  }

  static String _alertsNow(final int n) =>
      '$n alert${n == 1 ? '' : 's'} now';

  static int _mostSeriousFirst(final Hazard a, final Hazard b) =>
      (b.severityBand?.index ?? 0).compareTo(a.severityBand?.index ?? 0);

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final query = ref.watch(
      providerOfPlacesForMap.select((s) => s.searchString),
    );
    final places = ref.watch(providerOfPlacesForMap.select((s) => s.places));
    final placesState = ref.watch(
      providerOfPlacesForMap.select((s) => s.getPlacesState),
    );
    final isLoading = placesState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final hazards = ref.watch(providerOfMap.select((s) => s.hazards));

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
        ),
        padding: EdgeInsets.fromLTRB(16.spMin, 10.spMin, 16.spMin, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.spMin,
                height: 5.spMin,
                decoration: BoxDecoration(
                  color: _handle,
                  borderRadius: BorderRadius.circular(3.spMin),
                ),
              ),
            ),
            SizedBox(height: 14.spMin),
            _searchRowBuilder(),
            if (isLoading)
              Padding(
                padding: EdgeInsets.only(top: 6.spMin),
                child: const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: AppColors.transparent,
                  color: AppColors.orange,
                ),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  top: 14.spMin,
                  bottom: 28.spMin + keyboard,
                ),
                children: query.isEmpty
                    ? _beforeTypingBuilder(hazards)
                    : _resultsBuilder(
                        query,
                        places,
                        matchingAlerts(query, hazards),
                        isLoading,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchRowBuilder() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48.spMin,
            padding: EdgeInsets.symmetric(horizontal: 14.spMin),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.spMin),
              border: Border.all(color: _line, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.search, size: 18.spMin, color: _muted),
                SizedBox(width: 10.spMin),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: _onChanged,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontSize: 16.spMin,
                      fontWeight: FontWeight.w500,
                      color: _ink,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search a place or alert',
                      hintStyle: TextStyle(fontSize: 16.spMin, color: _muted),
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 4.spMin),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(
            foregroundColor: _muted,
            padding: EdgeInsets.symmetric(horizontal: 6.spMin),
            minimumSize: Size(48.spMin, 48.spMin),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  List<Widget> _beforeTypingBuilder(final List<Hazard> hazards) {
    final subs = ref.watch(
      providerOfMyLocationSubscriptions.select((s) => s.locationSubscriptions),
    );
    final feedHazards = ref.watch(
      providerOfNotificationsFeed.select((s) => s.hazards),
    );
    final ownRadiusKm =
        ref.watch(
          providerOfLoggedInUser.select(
            (u) => u?.ownLocationSubscriptionRadiusKm,
          ),
        ) ??
        5;
    final all = [...feedHazards, ...hazards];
    final saved = subs.where((s) => !s.isOwnLocation).toList();
    final near = hazards.where((h) => !h.isExpired).toList()
      ..sort(_mostSeriousFirst);

    final rows = <Widget>[
      _row(
        title: 'My location',
        subtitle: '$ownRadiusKm km radius · follows you',
        onTap: _openPlaces,
      ),
      for (final s in saved)
        _row(
          title: (s.name?.trim().isNotEmpty ?? false) ? s.name! : 'Saved place',
          subtitle: [
            if (s.address?.trim().isNotEmpty ?? false) s.address!,
            _alertsNow(alertsInsideSubscription(s, all)),
          ].join(' · '),
          onTap: _openPlaces,
        ),
    ];

    return [
      _label('YOUR PLACES'),
      SizedBox(height: 8.spMin),
      _group(rows),
      SizedBox(height: 14.spMin),
      _label('NEAR YOU NOW'),
      SizedBox(height: 8.spMin),
      if (near.isEmpty)
        _note('Nothing on the map near you right now.')
      else
        for (final h in near.take(3)) ...[
          AlertFeedRow(hazard: h),
          SizedBox(height: 8.spMin),
        ],
      SizedBox(height: 6.spMin),
      _footnote(),
    ];
  }

  List<Widget> _resultsBuilder(
    final String query,
    final List<GooglePlace> places,
    final List<Hazard> alerts,
    final bool isLoading,
  ) {
    final nothing = alerts.isEmpty && places.isEmpty;
    return [
      if (alerts.isNotEmpty) ...[
        _label('ALERTS MATCHING “${query.toUpperCase()}”'),
        SizedBox(height: 8.spMin),
        for (final h in alerts) ...[
          AlertFeedRow(hazard: h),
          SizedBox(height: 8.spMin),
        ],
        SizedBox(height: 6.spMin),
      ],
      if (places.isNotEmpty) ...[
        _label('PLACES'),
        SizedBox(height: 8.spMin),
        _group([
          for (final p in places.take(4))
            _row(
              title: p.name,
              subtitle: p.address,
              onTap: () => _pickPlace(p),
              trailing: _saveButton(p),
            ),
        ]),
        SizedBox(height: 14.spMin),
      ],
      if (nothing && !isLoading) ...[
        _note(
          'Nothing matches “$query” yet. Try a suburb, a road or a word '
          'from the alert.',
        ),
        SizedBox(height: 14.spMin),
      ],
      _footnote(),
    ];
  }

  Widget _label(final String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.spMin),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.sectionLabel,
        ),
      ),
    );
  }

  Widget _group(final List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        border: Border.all(color: AppColors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 16.spMin),
                color: AppColors.black.withValues(alpha: 0.06),
              ),
            rows[i],
          ],
        ],
      ),
    );
  }

  Widget _row({
    required final String title,
    required final String subtitle,
    required final VoidCallback onTap,
    final Widget? trailing,
  }) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 58.spMin),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.spMin),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.spMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.spMin,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.spMin,
                              fontWeight: FontWeight.w500,
                              color: _muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.spMin),
                trailing ??
                    Icon(
                      LucideIcons.chevronRight,
                      size: 18.spMin,
                      color: _muted,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _saveButton(final GooglePlace place) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10.spMin),
      child: InkWell(
        onTap: _saving ? null : () => _savePlace(place),
        borderRadius: BorderRadius.circular(10.spMin),
        child: Container(
          height: 36.spMin,
          padding: EdgeInsets.symmetric(horizontal: 14.spMin),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.spMin),
            border: Border.all(color: _line),
          ),
          child: Text(
            'Save',
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _note(final String text) {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14.spMin, color: _muted, height: 1.45),
      ),
    );
  }

  Widget _footnote() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.spMin),
      child: Text(
        'Place search goes through the ALRT backend, so no map key ships '
        'in the app.',
        style: TextStyle(fontSize: 12.spMin, color: _muted, height: 1.45),
      ),
    );
  }
}

/// The alerts the map search would list for [query] (most serious first, at
/// most 4). Speak to ALRT uses it to say what a spoken search found.
List<Hazard> mapSearchMatchingAlerts(
  final String query,
  final List<Hazard> hazards,
) =>
    _MapSearchSheetState.matchingAlerts(query, hazards);
