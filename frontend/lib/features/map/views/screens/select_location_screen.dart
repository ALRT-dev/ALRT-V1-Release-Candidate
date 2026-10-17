import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/map/providers/service_providers.dart';
import 'package:hazard_app/features/map/views/screens/select_location_on_map_screen.dart';
import 'package:hazard_app/features/map/views/widgets/place_search_results_list.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Fixed TEST-only report location, matching the coordinates the Admin
/// Portal's own "TEST — DO NOT USE — Fire" preset uses (see
/// SCARBOROUGH_WA_LAT/LNG, admin/src/data/testAlertPresets.ts) so a
/// tester's manually-submitted community report and the admin-created
/// TEST alert land on the exact same map pin.
const testScarboroughLocation = AlrtLocation(
  latitude: -31.89441,
  longitude: 115.75999,
  name: 'Scarborough, WA (TEST)',
);

class SelectLocationScreenArgs {
  SelectLocationScreenArgs({
    this.initialLocation,
    this.getSubUrbOnly = false,
    this.showYourLocationOption = true,
    this.showTestScarboroughOption = false,
    this.centerLocation,
    this.radiusInMeters,
  });

  /// The initial location to be displayed on the map when the screen loads.
  final AlrtLocation? initialLocation;

  /// Whether to get only the suburb part of the address.
  final bool getSubUrbOnly;

  /// Whether to show the "Your Location" option.
  final bool showYourLocationOption;

  /// Whether to show the TEST-only "Use Scarborough WA (TEST)" option -
  /// callers opt in explicitly (see create_update_report_screen.dart's
  /// _gotoSelectLocationScreen), so this never appears for other
  /// SelectLocationScreen callers (saved locations, family places, etc.)
  /// even when the TEST flag is on. testScarboroughLocationFallbackEnabled
  /// (hazard_repository.dart) already double-gates the flag itself to a
  /// TEST/dev build, so this stays false in production regardless.
  final bool showTestScarboroughOption;

  /// The center location for radius constraint.
  /// If provided with [radiusInMeters], only locations within the radius can be selected.
  final AlrtLocation? centerLocation;

  /// The radius in meters for location selection constraint.
  /// If provided with [centerLocation], only locations within this radius can be selected.
  final double? radiusInMeters;

  /// Whether radius constraint is enabled.
  bool get hasRadiusConstraint =>
      centerLocation != null && radiusInMeters != null;
}

class SelectLocationScreen extends ConsumerStatefulWidget {
  const SelectLocationScreen({
    super.key,
    this.args,
  });

  final SelectLocationScreenArgs? args;

  static const String route = '/select-location';

  static const placesSearchKey = 'SelectLocationScreen';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectLocationScreenState();
}

class _SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _page = Color(0xFFF5F5F7);
  static const _field = Color(0xFFE3E6EA);

  final _searchFocusNode = FocusNode();
  final _searchController = TextEditingController();

  /// The suburb the person is in now, for the "<suburb> / Suburb · where
  /// you are now" row (prototype board "SelectLocation"). Null until the
  /// backend geocoder has answered, and the row waits for it.
  String? _suburb;

  @override
  void initState() {
    super.initState();
    _searchController.text =
        widget.args?.initialLocation?.name ??
        widget.args?.initialLocation?.address ??
        '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_searchController.text.isNotEmpty) {
        _handleSearchChanged(_searchController.text);
      } else {
        // A fresh search: no query left over from the last visit.
        ref
            .read(providerOfPlacesForSelectLocation.notifier)
            .updateSearchString('');
      }
      if (widget.args?.showYourLocationOption ?? true) _loadSuburb();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSuburb() async {
    final here = ref.read(providerOfLocation).location;
    final result = await ref
        .read(providerOfLocationService)
        .getAddressFromCoordinates(
          coordinates: here.latLng,
          getSubUrbOnly: true,
        );
    if (!mounted) return;
    result.when(
      (suburb) {
        if (suburb.trim().isNotEmpty) setState(() => _suburb = suburb.trim());
      },
      (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearchActive = ref.watch(
      providerOfPlacesForSelectLocation.select(
        (value) => value.searchString.isNotEmpty,
      ),
    );

    return Scaffold(
      backgroundColor: _page,
      body: Column(
        children: [
          _headerBuilder(context),
          Expanded(
            child: CustomScrollView(
              slivers: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 0),
                  child: _searchbarBuilder(),
                ).sliverBox,
                14.hSizedBox.sliverBox,
                if (widget.args?.hasRadiusConstraint ?? false)
                  _radiusConstraintBannerBuilder().sliverBox,
                if (isSearchActive)
                  PlaceSearchResultsList(
                    placesSearchKey: SelectLocationScreen.placesSearchKey,
                    onPlaceSelected: _handlePlaceSelected,
                    radiusFilter: widget.args?.hasRadiusConstraint ?? false
                        ? _isLocationWithinRadius
                        : null,
                  )
                else ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.spMin),
                    child: _optionsGroupBuilder(),
                  ).sliverBox,
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20.spMin,
                      14.spMin,
                      20.spMin,
                      24.spMin,
                    ),
                    child: Text(
                      'You can look at alerts anywhere. Reports are always '
                      'posted from where you actually are.',
                      style: TextStyle(
                        fontSize: 13.spMin,
                        color: _muted,
                        height: 1.45,
                      ),
                    ),
                  ).sliverBox,
                ],
              ],
            ),
          ),
        ],
      ),
    ).keyboardDismisser(context);
  }

  Widget _headerBuilder(final BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        8.spMin,
        MediaQuery.paddingOf(context).top + 8.spMin,
        16.spMin,
        12.spMin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                tooltip: 'Back',
                icon: Icon(
                  LucideIcons.chevronLeft,
                  size: 26.spMin,
                  color: _ink,
                ),
              ),
              Expanded(
                child: Text(
                  'Choose a location',
                  style: TextStyle(
                    fontSize: 24.spMin,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.spMin),
            child: Text(
              'Place search goes through the ALRT backend',
              style: TextStyle(fontSize: 14.spMin, color: _muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchbarBuilder() {
    return TextFormField(
      focusNode: _searchFocusNode,
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onChanged: _handleSearchChanged,
      style: TextStyle(
        fontSize: 15.spMin,
        fontWeight: FontWeight.w500,
        color: _ink,
      ),
      decoration: InputDecoration(
        hintText: 'Search a suburb, town or address',
        hintStyle: TextStyle(
          fontSize: 15.spMin,
          color: _muted.withValues(alpha: 0.7),
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 14.spMin,
        ),
        filled: true,
        fillColor: AppColors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.spMin),
          borderSide: const BorderSide(color: _field, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.spMin),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
        suffixIcon: Consumer(
          builder: (context, ref, child) {
            final isSearchActive = ref.watch(
              providerOfPlacesForSelectLocation.select(
                (value) => value.searchString.isNotEmpty,
              ),
            );
            if (!isSearchActive) return const SizedBox.shrink();
            return IconButton(
              onPressed: _handleClearSearchPressed,
              tooltip: 'Clear',
              icon: Icon(
                Icons.close_rounded,
                size: 20.spMin,
                color: _ink,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Your location, the suburb you are in, Choose on the map: one white
  /// group with hairline dividers, as on the board.
  Widget _optionsGroupBuilder() {
    final showYourLocation = widget.args?.showYourLocationOption ?? true;
    final rows = <Widget>[
      if (showYourLocation)
        _rowBuilder(
          title: 'Your location',
          subtitle: 'Asked only now, when you choose it',
          onTap: _handleYourLocationPressed,
        ),
      if (showYourLocation && _suburb != null)
        _rowBuilder(
          title: _suburb!,
          subtitle: 'Suburb · where you are now',
          onTap: _handleSuburbPressed,
        ),
      if (widget.args?.showTestScarboroughOption ?? false)
        _rowBuilder(
          title: 'Use Scarborough WA (TEST)',
          subtitle: 'For testing only, when your real location is unavailable',
          titleColor: AppColors.orange,
          onTap: () => context.pop(testScarboroughLocation),
        ),
      _rowBuilder(
        title: 'Choose on the map',
        subtitle: 'Drop a pin',
        onTap: _gotoSelectLocationOnMapScreen,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        border: Border.all(color: AppColors.black.withValues(alpha: 0.04)),
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

  Widget _rowBuilder({
    required final String title,
    required final String subtitle,
    required final VoidCallback onTap,
    final Color titleColor = _ink,
  }) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 58.spMin),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.spMin,
            vertical: 10.spMin,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 1.spMin),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w500,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18.spMin,
                color: _muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radiusConstraintBannerBuilder() {
    final radiusInKm = (widget.args!.radiusInMeters! / 1000).toStringAsFixed(1);

    return Consumer(
      builder: (context, ref, child) {
        final hasSearchResults = ref.watch(
          providerOfPlacesForSelectLocation.select(
            (value) => value.places.isNotEmpty,
          ),
        );
        if (!hasSearchResults) {
          return SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          padding: EdgeInsets.all(12.spMin),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.blue.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.blue,
                size: 20.spMin,
              ),
              12.wSizedBox,
              Expanded(
                child: Text(
                  'Showing locations within $radiusInKm km from your location.',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    color: AppColors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// The suburb row: where the person is now, named by suburb only.
  void _handleSuburbPressed() {
    final suburb = _suburb;
    if (suburb == null) return;
    final here = ref.read(providerOfLocation).location;
    if ((widget.args?.hasRadiusConstraint ?? false) &&
        !_isLocationWithinRadius(here.latitude, here.longitude)) {
      context.showErrorToast(
        message: 'Your location is outside the allowed area.',
      );
      return;
    }
    context.pop(here.copyWith(name: suburb, address: suburb));
  }

  /// Updates the search string in the [PlacesProvider] and triggers a debounced to fetch places.
  void _handleSearchChanged(final String value) {
    ref.read(providerOfPlacesForSelectLocation.notifier)
      ..updateSearchString(value.trim())
      ..updateGetPlacesToLoading();

    EasyDebounce.debounce(
      'location-search-debounce',
      const Duration(milliseconds: 500),
      () {
        ref
            .read(providerOfPlacesForSelectLocation.notifier)
            .getPlaces(showOnlyCities: widget.args?.getSubUrbOnly ?? false);
      },
    );
  }

  /// Clears the search input field and refocuses it.
  void _handleClearSearchPressed() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
    _handleSearchChanged('');
  }

  /// Checks if a location is within the radius constraint.
  bool _isLocationWithinRadius(double? latitude, double? longitude) {
    if (!widget.args!.hasRadiusConstraint) return true;
    if (latitude == null || longitude == null) return false;

    final centerLat = widget.args!.centerLocation!.latitude;
    final centerLng = widget.args!.centerLocation!.longitude;
    final maxRadius = widget.args!.radiusInMeters!;

    final distance = calculateDistanceInMeters(
      centerLat,
      centerLng,
      latitude,
      longitude,
    );

    return distance <= maxRadius;
  }

  /// Formats distance in a user-friendly way.
  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    }
    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
  }

  /// Fetches the user's current location from the [LocationProvider] and pops the screen with that location.
  void _handleYourLocationPressed() async {
    final currentUserLocation = ref.read(providerOfLocation).location;

    // Check radius constraint
    if (widget.args?.hasRadiusConstraint ?? false) {
      if (!_isLocationWithinRadius(
        currentUserLocation.latitude,
        currentUserLocation.longitude,
      )) {
        final distance = calculateDistanceInMeters(
          widget.args!.centerLocation!.latitude,
          widget.args!.centerLocation!.longitude,
          currentUserLocation.latitude,
          currentUserLocation.longitude,
        );
        final radiusInKm = (widget.args!.radiusInMeters! / 1000)
            .toStringAsFixed(1);
        if (!mounted) return;
        context.showErrorToast(
          message:
              'Your location is ${_formatDistance(distance)} away. Please select a location within $radiusInKm km.',
        );
        return;
      }
    }

    final result = await ref
        .read(providerOfLocationService)
        .getAddressFromCoordinates(
          coordinates: currentUserLocation.latLng,
          getSubUrbOnly: widget.args?.getSubUrbOnly ?? false,
        );
    if (!mounted) return;

    result.when(
      (address) {
        context.pop(
          currentUserLocation.copyWith(
            address: address,
          ),
        );
      },
      (error) {
        context.showErrorToast(
          message: 'Could not get your location. Please try again.',
        );
      },
    );
  }

  /// Navigates to the [SelectLocationOnMapScreen] to allow the user to select a location on the map.
  void _gotoSelectLocationOnMapScreen() async {
    final location = await context.push(
      SelectLocationOnMapScreen.route,
      extra: SelectLocationOnMapScreenArgs(
        initialLocation: widget.args?.initialLocation,
        getSubUrbOnly: widget.args?.getSubUrbOnly ?? false,
        centerLocation: widget.args?.centerLocation,
        radiusInMeters: widget.args?.radiusInMeters,
      ),
    );
    if (!mounted) return;

    if (location != null && location is AlrtLocation) {
      // Validate radius constraint
      if (widget.args?.hasRadiusConstraint ?? false) {
        if (!_isLocationWithinRadius(location.latitude, location.longitude)) {
          final distance = calculateDistanceInMeters(
            widget.args!.centerLocation!.latitude,
            widget.args!.centerLocation!.longitude,
            location.latitude,
            location.longitude,
          );
          final radiusInKm = (widget.args!.radiusInMeters! / 1000)
              .toStringAsFixed(1);
          context.showErrorToast(
            message:
                'Selected location is ${_formatDistance(distance)} away. Please select within $radiusInKm km.',
          );
          return;
        }
      }
      context.pop(location);
    }
  }

  /// Handles the selection of a place from the search results and pops the screen with the selected location.
  void _handlePlaceSelected(final GooglePlace place) {
    // Validation is already done by the radiusFilter in PlaceSearchResultsList
    // This is just an extra safety check
    if (widget.args?.hasRadiusConstraint ?? false) {
      if (!_isLocationWithinRadius(place.latitude, place.longitude)) {
        final distance = calculateDistanceInMeters(
          widget.args!.centerLocation!.latitude,
          widget.args!.centerLocation!.longitude,
          place.latitude,
          place.longitude,
        );
        final radiusInKm = (widget.args!.radiusInMeters! / 1000)
            .toStringAsFixed(1);
        context.showErrorToast(
          message:
              'Selected location is ${_formatDistance(distance)} away. Please select within $radiusInKm km.',
        );
        return;
      }
    }
    context.pop(place.toAlrtLocation);
  }
}
