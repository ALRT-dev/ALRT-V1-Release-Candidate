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
import 'package:hazard_app/features/shared/views/widgets/round_button.dart';
import 'package:hazard_app/others/app_colors.dart';

class SelectLocationScreenArgs {
  SelectLocationScreenArgs({
    this.initialLocation,
    this.getSubUrbOnly = false,
    this.showYourLocationOption = true,
    this.centerLocation,
    this.radiusInMeters,
  });

  /// The initial location to be displayed on the map when the screen loads.
  final AlrtLocation? initialLocation;

  /// Whether to get only the suburb part of the address.
  final bool getSubUrbOnly;

  /// Whether to show the "Your Location" option.
  final bool showYourLocationOption;

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
  final _searchFocusNode = FocusNode();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text =
        widget.args?.initialLocation?.name ??
        widget.args?.initialLocation?.address ??
        '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_searchController.text.isNotEmpty) {
        _handleSearchChanged(_searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          10.hSizedBox.sliverBox,
          SafeArea(
            bottom: false,
            child: _searchbarBuilder().pX(20.0),
          ).sliverBox,
          20.hSizedBox.sliverBox,

          if (widget.args?.showYourLocationOption ?? true)
            _yourLocationBuilder().sliverBox,
          _chooseOnTheMapBuilder().sliverBox,
          Divider().pX(20.0).sliverBox,
          if (widget.args?.hasRadiusConstraint ?? false)
            _radiusConstraintBannerBuilder().sliverBox,
          PlaceSearchResultsList(
            placesSearchKey: SelectLocationScreen.placesSearchKey,
            onPlaceSelected: _handlePlaceSelected,
            radiusFilter: widget.args?.hasRadiusConstraint ?? false
                ? _isLocationWithinRadius
                : null,
          ),
        ],
      ),
    ).keyboardDismisser(context);
  }

  Widget _searchbarBuilder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10.0,
            offset: Offset(0, 0.0),
          ),
        ],
      ),
      child: TextFormField(
        focusNode: _searchFocusNode,
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: _handleSearchChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search the location...',
          contentPadding: EdgeInsets.only(
            top: 5.spMin,
            bottom: 5.spMin,
            right: 10.spMin,
          ),
          filled: true,
          fillColor: AppColors.white,
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: BackButtonIcon(),
                onPressed: () {
                  context.pop();
                },
              ),
            ],
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final isSearchActive = ref.watch(
                    providerOfPlacesForSelectLocation.select(
                      (value) => value.searchString.isNotEmpty,
                    ),
                  );
                  if (!isSearchActive) return const SizedBox();

                  return IconButton(
                    onPressed: _handleClearSearchPressed,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.spMin,
                      color: AppColors.black,
                    ),
                  ).pR(5.0);
                },
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
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          padding: EdgeInsets.all(12.spMin),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
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

  Widget _yourLocationBuilder() {
    return ListTile(
      leading: RoundButton(
        icon: Icon(
          Icons.my_location_rounded,
          color: AppColors.blue,
          size: 22.spMin,
        ),
      ),
      title: Text(
        'Your location',
        style: TextStyle(
          fontSize: 16.spMin,
          color: AppColors.blue,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: _handleYourLocationPressed,
    );
  }

  Widget _chooseOnTheMapBuilder() {
    return ListTile(
      leading: RoundButton(
        icon: Icon(
          Icons.map_rounded,
          size: 22.spMin,
          color: AppColors.blue,
        ),
      ),
      title: Text(
        'Choose on the map',
        style: TextStyle(
          fontSize: 16.spMin,
          color: AppColors.blue,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: _gotoSelectLocationOnMapScreen,
    );
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
