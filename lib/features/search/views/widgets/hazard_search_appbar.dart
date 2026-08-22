import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/map/views/widgets/places_search_results_menu_content.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/report/providers/create_update_report_provider.dart';
import 'package:hazard_app/features/report/views/screens/create_update_report_screen.dart';
import 'package:hazard_app/features/search/providers/main_search_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/dropdown.dart';
import 'package:hazard_app/features/shared/views/widgets/voice/voice_search_mic_button.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/features/shared/views/widgets/search_field_style.dart';

class HazardSearchAppBar extends ConsumerStatefulWidget {
  const HazardSearchAppBar({super.key});

  static const placesSearchKey = 'HazardSearchAppBar';
  static const filtersKey = 'HazardSearchAppBarFilters';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HazardSearchAppBarState();
}

class _HazardSearchAppBarState extends ConsumerState<HazardSearchAppBar> {
  final _searchFocusNode = FocusNode();
  final _searchController = TextEditingController();

  final _dropdownController = AlrtDropdownController();

  late final providerOfPlacesForSearch = providerOfPlaces(
    HazardSearchAppBar.placesSearchKey,
  );

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(providerOfPlacesForSearch).searchString;
    // Without this the glow could never brighten: hasFocus was read in
    // build, but nothing asked for a rebuild when focus changed.
    _searchFocusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.transparent,
      surfaceTintColor: AppColors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.orange300,
              AppColors.red200,
            ],
          ),
        ),
      ),
      floating: true,
      pinned: true,
      leading: const SizedBox(),
      leadingWidth: 0.0,
      toolbarHeight: 50.spMin,
      centerTitle: false,
      expandedHeight: 120.spMin,
      title: Text(
        'ALRT Search',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 24.spMin,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(63.spMin),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _searchbarBuilder(),
                ),
              ],
            ).pX(18.0),
            13.hSizedBox,
          ],
        ),
      ),
    );
  }

  Widget _searchbarBuilder() {
    return AlrtDropdown(
      controller: _dropdownController,
      button: (context, isOpen) => Consumer(
        builder: (context, ref, child) {
          final isSearchActive = ref.watch(
            providerOfPlacesForSearch.select(
              (value) => value.searchString.isNotEmpty,
            ),
          );
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: AppColors.white,
              // Same rounded rectangle as the map bar.
              borderRadius: SearchFieldStyle.borderRadius,
              boxShadow: SearchFieldStyle.glow(isLit: _searchFocusNode.hasFocus),
            ),
            padding: EdgeInsets.symmetric(vertical: 1.spMin),
            height: SearchFieldStyle.height,
            alignment: Alignment.center,
            child: TextFormField(
              focusNode: _searchFocusNode,
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _handleSearchChanged,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search alerts in any location...',
                hintStyle: TextStyle(
                  color: AppColors.grey.withValues(alpha: 0.7),
                ),
                contentPadding: EdgeInsets.only(
                  top: 5.spMin,
                  bottom: 5.spMin,
                  left: 20.spMin,
                  right: 10.spMin,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/search.svg',
                      width: 25.spMin,
                      height: 25.spMin,
                      color: AppColors.grey.withValues(alpha: 0.6),
                    ).pL(15.0),
                  ],
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 44.spMin,
                  minHeight: 44.spMin,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSearchActive)
                      VoiceSearchMicButton(
                        onTranscript: (text) {
                          _searchController.text = text;
                          _searchController.selection =
                              TextSelection.collapsed(offset: text.length);
                          _handleSearchChanged(text);
                        },
                        onReportTranscript: _handleReportDictation,
                      )
                    else
                      IconButton(
                        onPressed: _handleClearSearchPressed,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20.spMin,
                          color: AppColors.black,
                        ),
                      ).pR(5.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      menuContent: (context, close) {
        return PlacesSearchResultsMenuContent(
          placesSearchKey: HazardSearchAppBar.placesSearchKey,
          onPlaceSelected: _handleSearchResultSelected,
        );
      },
    );
  }


  /// Spoken hazard descriptions skip search: they land in Post an ALRT
  /// with the words already in the details field.
  void _handleReportDictation(final String transcript) {
    ref.read(providerOfCreateReport.notifier).updateDescription(transcript);
    context.push(CreateUpdateReportScreen.createRoute);
  }
  /// Updates the state with the given search string.
  void _handleSearchChanged(String value) {
    if (value.trim().isEmpty) {
      _dropdownController.close();
    } else {
      _dropdownController.open();
    }

    ref.read(providerOfPlacesForSearch.notifier)
      ..updateSearchString(value.trim())
      ..updateGetPlacesToLoading();
    EasyDebounce.debounce(
      'hazards-search',
      const Duration(milliseconds: 300),
      () {
        if (!mounted) return;
        ref
            .read(providerOfPlacesForSearch.notifier)
            .getPlaces(showOnlyCities: true);
      },
    );
  }

  /// Clears the search input field.
  void _handleClearSearchPressed() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    ref.read(providerOfPlacesForSearch.notifier).updateSearchString('');
    _dropdownController.close();

    // also clear the searched location and hazards from the main search provider
    ref.read(providerOfMainSearch.notifier)
      ..updateSearchedLocation(null)
      ..updateGetHazardsByLocationStateToInitial();
  }

  /// Handles the selection of a search result place.
  void _handleSearchResultSelected(final GooglePlace place) {
    _searchFocusNode.unfocus();
    _dropdownController.close();
    _searchController.text = place.name;

    ref.read(providerOfPlacesForSearch.notifier).updateSearchString(place.name);

    // update the main search provider with the selected location and fetch hazards.
    ref.read(providerOfMainSearch.notifier)
      ..updateSearchedLocation(place.toAlrtLocation)
      ..getHazards();
  }
}
