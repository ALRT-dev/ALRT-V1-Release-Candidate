import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/providers/service_providers.dart';
import 'package:hazard_app/features/map/providers/states/location_permission_provider_state.dart';
import 'package:hazard_app/features/map/services/location_service.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/user_service.dart';

final providerOfLocation =
    StateNotifierProvider<LocationProvider, LocationProviderState>(
      (ref) => LocationProvider(
        ref: ref,
        state: LocationProviderState(
          updateLocationCancelToken: CancelToken(),
        ),
      ),
    );

class LocationProvider extends StateNotifier<LocationProviderState> {
  LocationProvider({
    required final Ref ref,
    required final LocationProviderState state,
  }) : _ref = ref,
       super(state) {
    _ref.onDispose(() {
      _positionStreamSubscription?.cancel();
    });
  }

  final Ref _ref;
  LocationService get _locationService => _ref.read(providerOfLocationService);
  AppUser? get _loggedInUser => _ref.read(providerOfLoggedInUser);
  UserService get _userService => _ref.read(providerOfUserService);

  StreamSubscription<Position>? _positionStreamSubscription;

  /// Gets the current location of the user.
  Future<void> getLocation() async {
    if (state.getLocationState == GetLocationState.loading()) {
      return;
    }

    state = state.copyWith(
      getLocationState: GetLocationState.loading(),
    );

    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;

    result.when(
      (success) {
        state = state.copyWith(
          getLocationState: GetLocationState.success(success),
          isUsingDeviceLocation: true,
        );
        updateLocation(success);

        _listenToPositionStream();
      },
      (failure) {
        state = state.copyWith(
          getLocationState: GetLocationState.error(failure),
        );
      },
    );
  }

  /// Listens to the position stream and updates the location accordingly.
  void _listenToPositionStream() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = _locationService.getPositionStream().listen(
      (position) {
        final location = AlrtLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        updateLocation(location);
      },
    );
  }

  /// Gets the device location and compares it with the user's location,
  /// if the locations are different then update the user's location with the device location.
  Future<void> _updateUserLocation() async {
    if (_loggedInUser == null) return;

    state = state.copyWith(
      updateUserLocationState: UpdateUserLocationState.loading(),
    );

    // if device location is already equals to the user's location then there's nothing to do
    if (state.location.latitude.toStringAsFixed(3) ==
            _loggedInUser?.latitude?.toStringAsFixed(3) &&
        state.location.longitude.toStringAsFixed(3) ==
            _loggedInUser?.longitude?.toStringAsFixed(3)) {
      log(
        "Skipping location update because the device's location and the user's location are same!",
      );
      return;
    }

    final addressResult = await _locationService
        .getAddressFromCoordinatesPlugin(
          coordinates: state.location.latLng,
          getSubUrbOnly: true,
        );
    if (!mounted) return;
    final address = addressResult.when(
      (success) => success,
      (failure) => null,
    );

    // cancel the old requests before making new requests
    if (state.updateLocationCancelToken.requestOptions != null) {
      state.updateLocationCancelToken.cancel();
      state = state.copyWith(updateLocationCancelToken: CancelToken());
    }

    // if device location is different than the user's location then update the user's location
    final updateUserResult = await _userService.updateCurrentUser(
      user: AppUser(
        latitude: state.location.latitude,
        longitude: state.location.longitude,
        locationName: state.location.displayName == 'Unknown Location'
            ? address
            : state.location.displayName,
      ),
      cancelToken: state.updateLocationCancelToken,
    );
    if (!mounted) return;

    updateUserResult.when(
      (success) {
        state = state.copyWith(
          updateUserLocationState: UpdateUserLocationState.success(success),
        );

        // Update the logged in user state
        _ref.read(providerOfLoggedInUser.notifier).state = success;

        // Update the own location subscription
        _ref
            .read(providerOfMyLocationSubscriptions.notifier)
            .updateOwnLocationSubscription();
      },
      (failure) {
        state = state.copyWith(
          updateUserLocationState: UpdateUserLocationState.error(failure),
        );
      },
    );
  }

  /// Opens the location settings of the app.
  Future<void> openLocationSettings() {
    return _locationService.openLocationSettings();
  }

  /// Returns `true` if the location permission can be requested.
  Future<bool> canRequestLocationPermission() async {
    final result = await _locationService.canRequestLocationPermission();
    return result.when((success) => success, (_) => false);
  }

  /// Returns `true` if the location permission is granted.
  Future<bool> isLocationPermissionGranted() async {
    final result = await _locationService.isLocationPermissionGranted();
    return result.when((success) => success, (_) => false);
  }

  /// Updates [LocationProviderState.location] with the given [location].
  void updateLocation(final AlrtLocation location) {
    state = state.copyWith(
      location: location,
    );
    _updateUserLocation();
  }
}
