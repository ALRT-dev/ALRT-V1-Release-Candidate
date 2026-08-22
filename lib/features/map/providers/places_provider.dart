import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/service_providers.dart';
import 'package:hazard_app/features/map/providers/states/places_provider_state.dart';
import 'package:hazard_app/features/map/services/location_service.dart';
import 'package:hazard_app/features/map/views/screens/select_location_screen.dart';
import 'package:hazard_app/features/map/views/widgets/map_searchbar.dart';
import 'package:hazard_app/features/onboarding/views/onboarding_location_screen.dart';
import 'package:hazard_app/features/search/views/widgets/hazard_search_appbar.dart';

final providerOfPlacesForOnboarding = providerOfPlaces(
  OnboardingLocationScreen.placesSearchKey,
);
final providerOfPlacesForMap = providerOfPlaces(
  MapSearchbar.placesSearchKey,
);
final providerOfPlacesForSearch = providerOfPlaces(
  HazardSearchAppBar.placesSearchKey,
);
final providerOfPlacesForSelectLocation = providerOfPlaces(
  SelectLocationScreen.placesSearchKey,
);

final providerOfPlaces = StateNotifierProvider.autoDispose
    .family<PlacesProvider, PlacesProviderState, String>(
      (ref, key) => PlacesProvider(
        ref: ref,
        state: PlacesProviderState(),
      ),
    );

class PlacesProvider extends StateNotifier<PlacesProviderState> {
  PlacesProvider({
    required final Ref ref,
    required PlacesProviderState state,
  }) : _ref = ref,
       super(state);

  final Ref _ref;
  LocationService get _locationService => _ref.read(providerOfLocationService);

  /// Fetches places based on the current search string in the state.
  Future<void> getPlaces({
    final bool showOnlyCities = false,
  }) async {
    final searchString = state.searchString;
    if (searchString.isEmpty) {
      state = state.copyWith(
        places: [],
        getPlacesState: const GetPlacesState.success([]),
      );
      return;
    }

    state = state.copyWith(
      getPlacesState: const GetPlacesState.loading(),
    );

    final result = await _locationService.getPlaces(
      currentUserLocation: _ref.read(providerOfLocation).location,
      searchString: searchString,
      showOnlyCities: showOnlyCities,
    );
    if (!mounted) return;

    result.when(
      (places) {
        state = state.copyWith(
          places: places,
          getPlacesState: GetPlacesState.success(places),
        );
      },
      (error) {
        state = state.copyWith(
          getPlacesState: GetPlacesState.error(error),
        );
      },
    );
  }

  /// Updates [PlacesProviderState.searchString] in with the given [searchString].
  void updateSearchString(final String searchString) {
    state = state.copyWith(
      searchString: searchString,
    );
  }

  /// Updates [PlacesProviderState.getPlacesState] to loading state.
  void updateGetPlacesToLoading() {
    state = state.copyWith(
      getPlacesState: const GetPlacesState.loading(),
    );
  }
}
