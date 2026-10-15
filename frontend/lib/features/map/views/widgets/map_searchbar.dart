import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/ask_alrt/views/ask_alrt_sheet.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/map_search_text_editing_controller_provider.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/map/views/widgets/places_search_results_menu_content.dart';
import 'package:hazard_app/features/report/providers/create_update_report_provider.dart';
import 'package:hazard_app/features/report/views/screens/create_update_report_screen.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/services/voice_input_controller.dart';
import 'package:hazard_app/features/shared/views/widgets/dropdown.dart';
import 'package:hazard_app/features/shared/views/widgets/voice/voice_listening_sheet.dart';
import 'package:hazard_app/features/shared/views/widgets/voice/voice_priming_sheet.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The map search bar (prototype board "Main", 9 Oct 2026).
///
/// White 48 px bar, radius 14. Leading search glyph, the place/alert search
/// field, then two square buttons inside the bar on the right: voice search
/// and Ask ALRT. Both moved here from the old setup chips and the rail.
class MapSearchbar extends ConsumerStatefulWidget {
  const MapSearchbar({super.key});

  static const placesSearchKey = 'MapSearchbar';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapSearchbarState();
}

class _MapSearchbarState extends ConsumerState<MapSearchbar> {
  static const _inkColor = Color(0xFF1C1C1E);
  static const _hintColor = Color(0xFF5C5C66);
  static const _micBackground = Color(0xFFF5F5F7);
  static const _micIconColor = Color(0xFF3A3A42);
  static const _askBackground = Color(0xFFFFF1E8);
  static const _askIconColor = Color(0xFFE8622A);

  /// Same key the shared VoiceSearchMicButton writes, so the one-time
  /// microphone priming sheet is shown once across the app, not once per
  /// entry point.
  static const _kVoicePrimedKey = 'voice_priming_shown';

  final _searchFocusNode = FocusNode();
  TextEditingController get _searchController =>
      ref.read(providerOfMapSearchTextEditingController);

  final _dropdownController = AlrtDropdownController();

  /// The mic hides itself when there is no recogniser or the microphone was
  /// refused; typing still works.
  bool _micHidden = false;
  bool _micBusy = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(providerOfPlacesForMap).searchString;
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlrtDropdown(
      controller: _dropdownController,
      fitAboveKeyboard: true,
      dropdownHeight: 360,
      button: (context, isOpen) => Consumer(
        builder: (context, ref, child) {
          final isSearchActive = ref.watch(
            providerOfPlacesForMap.select(
              (value) => value.searchString.isNotEmpty,
            ),
          );

          return Container(
            height: 48.spMin,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.spMin),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.10),
                  blurRadius: 16.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.spMin),
            child: Row(
              children: [
                Icon(
                  LucideIcons.search,
                  size: 20.spMin,
                  color: _hintColor,
                ),
                SizedBox(width: 10.spMin),
                Expanded(child: _searchFieldBuilder()),
                SizedBox(width: 10.spMin),
                if (isSearchActive)
                  _squareButtonBuilder(
                    background: _micBackground,
                    icon: LucideIcons.x,
                    iconColor: _micIconColor,
                    semanticLabel: 'Clear search',
                    onPressed: _handleClearSearchPressed,
                  )
                else if (!_micHidden)
                  _squareButtonBuilder(
                    background: _micBackground,
                    icon: LucideIcons.mic,
                    iconColor: _micIconColor,
                    semanticLabel: 'Search by voice',
                    onPressed: _handleMicTap,
                  ),
                if (isSearchActive || !_micHidden) SizedBox(width: 10.spMin),
                _squareButtonBuilder(
                  background: _askBackground,
                  icon: LucideIcons.sparkles,
                  iconColor: _askIconColor,
                  semanticLabel: 'Ask ALRT',
                  onPressed: () => showAskAlrtSheet(context),
                ),
              ],
            ),
          );
        },
      ),
      menuContent: (context, close) {
        return PlacesSearchResultsMenuContent(
          placesSearchKey: MapSearchbar.placesSearchKey,
          onPlaceSelected: _handleSearchResultSelected,
        );
      },
    );
  }

  Widget _searchFieldBuilder() {
    return TextFormField(
      focusNode: _searchFocusNode,
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onChanged: _handleSearchChanged,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(
        fontSize: 15.spMin,
        color: _inkColor,
      ),
      decoration: InputDecoration(
        hintText: 'Search a place or alert',
        hintStyle: TextStyle(
          fontSize: 15.spMin,
          color: _hintColor,
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12.spMin),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  /// One of the 34 x 34 radius-10 buttons that sit inside the bar.
  Widget _squareButtonBuilder({
    required final Color background,
    required final IconData icon,
    required final Color iconColor,
    required final String semanticLabel,
    required final VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Container(
        width: 34.spMin,
        height: 34.spMin,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10.spMin),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18.spMin,
          color: iconColor,
        ),
      ).onPressed(onPressed),
    );
  }

  /// Tap-to-talk. Primes for permission the first time, then listens and
  /// routes the words: a place name lands in the search field, a hazard
  /// description lands in Post an ALRT. Mirrors VoiceSearchMicButton, which
  /// draws its own orange disc and so could not take the bar's styling.
  Future<void> _handleMicTap() async {
    if (_micBusy) return;
    _micBusy = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final primed = prefs.getBool(_kVoicePrimedKey) ?? false;

      if (!primed) {
        if (!mounted) return;
        final proceed = await VoicePrimingSheet.show(context);
        if (proceed != true) return;
        await prefs.setBool(_kVoicePrimedKey, true);
      }

      final controller = ref.read(providerOfVoiceInput);
      final ok = await controller.ensureInitialized();
      if (!ok) {
        if (mounted) setState(() => _micHidden = true);
        return;
      }

      if (!mounted) return;
      final dictation = await VoiceListeningSheet.showForIntent(
        context,
        controller,
      );
      if (dictation == null) return;
      if (dictation.intent == VoiceIntent.report) {
        _handleReportDictation(dictation.text);
      } else {
        _handleVoiceSearchTranscript(dictation.text);
      }
    } finally {
      _micBusy = false;
    }
  }

  void _handleVoiceSearchTranscript(final String transcript) {
    final text = transcript.trim();
    if (text.isEmpty) return;
    _searchController.text = text;
    _searchController.selection = TextSelection.collapsed(offset: text.length);
    _handleSearchChanged(text);
  }

  /// Spoken hazard descriptions skip search: they land in Post an ALRT
  /// with the words already in the details field.
  void _handleReportDictation(final String transcript) {
    if (!mounted) return;
    ref.read(providerOfCreateReport.notifier).updateDescription(transcript);
    context.push(CreateUpdateReportScreen.createRoute);
  }

  /// Handles changes in the search input field with a debounce.
  void _handleSearchChanged(final String value) {
    if (value.trim().isEmpty) {
      _dropdownController.close();
    } else {
      _dropdownController.open();
    }

    // Keep the previous results on screen while the next query runs; the
    // menu shows a thin progress line rather than blanking to a spinner.
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

  /// Clears the search input field and unfocuses it.
  void _handleClearSearchPressed() {
    final isRoutePresent = ref.read(
      providerOfMap.select(
        (value) => value.currentRoutePlan != null,
      ),
    );

    // if a route is present, only clear the route but keep the selected place
    // else clear both selected place and route
    if (isRoutePresent) {
      ref.read(providerOfMap.notifier)
        ..updateCurrentRoutePlan(null)
        ..stopNavigation();
    } else {
      _searchFocusNode.unfocus();
      _searchController.clear();
      _dropdownController.close();
      ref.read(providerOfPlacesForMap.notifier).updateSearchString('');
      ref.read(providerOfMap.notifier)
        ..updateSelectedLocation(null)
        ..removeSelectedLocationMarker();
    }
  }

  /// Updates the selected place in the map provider when a search result is selected.
  void _handleSearchResultSelected(final GooglePlace place) {
    _dropdownController.close();
    _searchFocusNode.unfocus();
    _searchController.text = place.name;

    ref.read(providerOfPlacesForMap.notifier).updateSearchString(place.name);
    ref.read(providerOfMap.notifier)
      // update selected location
      ..updateSelectedLocation(place.toAlrtLocation)
      // clear any selected hazard when a new place is selected
      ..updateSelectedHazard(null);

    // move camera to the selected place
    ref
        .read(providerOfMap.notifier)
        .animateTo(
          position: LatLng(place.latitude, place.longitude),
          zoom: 20.0,
        );

    // add a marker to the selected place
    ref
        .read(providerOfMap.notifier)
        .addSelectedLocationMarker(LatLng(place.latitude, place.longitude));
  }
}
