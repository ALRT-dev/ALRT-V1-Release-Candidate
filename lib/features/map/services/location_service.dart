import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/map/providers/repository_providers.dart';
import 'package:hazard_app/features/map/repositories/location_repository.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

class LocationService {
  LocationService(final Ref ref) : _ref = ref;

  final Ref _ref;
  LocationRepository get _locationRepository =>
      _ref.read(providerOfLocationRepository);

  /// Returns the current location of the user.
  Future<Either<AlrtLocation, AppError>> getCurrentLocation() {
    return _locationRepository.getCurrentLocation();
  }

  /// Returns the address from the latitude and longitude.
  Future<Either<String, AppError>> getAddressFromCoordinates({
    required final LatLng coordinates,
    final bool getSubUrbOnly = false,
  }) {
    return _locationRepository.getAddressFromCoordinates(
      coordinates: coordinates,
      getSubUrbOnly: getSubUrbOnly,
    );
  }

  /// Returns true if the location permission is granted.
  Future<Either<bool, AppError>> isLocationPermissionGranted() {
    return _locationRepository.isLocationPermissionGranted();
  }

  /// Returns true if the location permission can be requested.
  Future<Either<bool, AppError>> canRequestLocationPermission() {
    return _locationRepository.canRequestLocationPermission();
  }

  /// Opens the location settings.
  Future<Either<void, AppError>> openLocationSettings() {
    return _locationRepository.openLocationSettings();
  }

  /// Returns a stream of position updates.
  Stream<Position> getPositionStream({
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  }) {
    return _locationRepository.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  /// Returns a stream of heading (compass) updates in degrees.
  Stream<double> getHeadingStream() {
    return _locationRepository.getHeadingStream();
  }

  /// Fetches places based on the given [searchString].
  Future<Either<List<GooglePlace>, AppError>> getPlaces({
    required final String searchString,
    required final AlrtLocation currentUserLocation,
    final bool showOnlyCities = false,
  }) {
    return _locationRepository.getPlaces(
      searchString: searchString,
      currentUserLocation: currentUserLocation,
      showOnlyCities: showOnlyCities,
    );
  }

  /// Fetches detailed information about a place using its [placeId].
  Future<Either<void, AppError>> getPlaceDetails({
    required final String placeId,
  }) {
    return _locationRepository.getPlaceDetails(
      placeId: placeId,
    );
  }

  /// Fetches the address from coordinates using a plugin.
  Future<Either<String, AppError>> getAddressFromCoordinatesPlugin({
    required LatLng coordinates,
    bool getSubUrbOnly = false,
  }) {
    return _locationRepository.getAddressFromCoordinatesPlugin(
      coordinates: coordinates,
      getSubUrbOnly: getSubUrbOnly,
    );
  }
}
