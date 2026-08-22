import 'package:app_settings/app_settings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:hazard_app/features/shared/utils/error_codes.dart';
import 'package:hazard_app/others/env.dart';

abstract class LocationRepository {
  /// Returns the current location of the user.
  Future<Either<AlrtLocation, AppError>> getCurrentLocation();

  /// Returns the address from the latitude and longitude.
  Future<Either<String, AppError>> getAddressFromCoordinates({
    required final LatLng coordinates,
    final bool getSubUrbOnly = false,
  });

  Future<Either<String, AppError>> getAddressFromCoordinatesPlugin({
    required LatLng coordinates,
    bool getSubUrbOnly = false,
  });

  /// Returns true if the location permission is granted.
  Future<Either<bool, AppError>> isLocationPermissionGranted();

  /// Returns true if the location permission can be requested.
  Future<Either<bool, AppError>> canRequestLocationPermission();

  /// Opens the location settings.
  Future<Either<void, AppError>> openLocationSettings();

  Stream<Position> getPositionStream({
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  });

  Stream<double> getHeadingStream();

  Future<Either<List<GooglePlace>, AppError>> getPlaces({
    required final String searchString,
    required final AlrtLocation currentUserLocation,
    final bool showOnlyCities = false,
  });

  Future<Either<Map<String, dynamic>, AppError>> getPlaceDetails({
    required final String placeId,
  });
}

class LocationRepositoryImpl extends LocationRepository {
  LocationRepositoryImpl({
    required final Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<Either<AlrtLocation, AppError>> getCurrentLocation() {
    return runAsyncCall(
      name: 'getCurrentLocation',
      future: () async {
        // check if location services are enabled
        final isLocationServiceEnabled =
            await Geolocator.isLocationServiceEnabled();
        if (!isLocationServiceEnabled) {
          throw AppError(
            code: ksLocationErrorServiceDisabled,
            message: 'Location services are disabled.',
          );
        }

        // check if location permission is granted
        var locationPermission = await Geolocator.checkPermission();

        if (locationPermission == LocationPermission.denied) {
          locationPermission = await Geolocator.requestPermission();
          if (locationPermission == LocationPermission.denied) {
            throw AppError(
              code: ksLocationErrorPermissionDenied,
              message: 'Location permissions are denied.',
            );
          }
        }
        if (locationPermission == LocationPermission.deniedForever) {
          throw AppError(
            code: ksLocationErrorPermissionDeniedForever,
            message:
                'Location permissions are permanently denied, we cannot request permissions.',
          );
        }

        // get current location
        final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            timeLimit: const Duration(milliseconds: 5000),
          ),
        );

        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        String? address;
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final addresses = [
            if (place.street?.isNotEmpty ?? false) place.street,
            if (place.locality?.isNotEmpty ?? false) place.locality,
            if (place.administrativeArea?.isNotEmpty ?? false)
              place.administrativeArea,
            if (place.country?.isNotEmpty ?? false) place.country,
          ];
          address = addresses.join(', ');
        }

        final alpLocation = AlrtLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
        );

        return Success(alpLocation);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<bool, AppError>> isLocationPermissionGranted() {
    return runAsyncCall(
      name: 'isLocationPermissionGranted',
      future: () async {
        final locationPermission = await Geolocator.checkPermission();
        final isGranted =
            locationPermission == LocationPermission.always ||
            locationPermission == LocationPermission.whileInUse;

        return Success(isGranted);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<bool, AppError>> canRequestLocationPermission() {
    return runAsyncCall(
      name: 'canRequestPermission',
      future: () async {
        final locationPermission = await Geolocator.checkPermission();
        final canRequest =
            locationPermission == LocationPermission.unableToDetermine ||
            locationPermission == LocationPermission.denied;

        return Success(canRequest);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> openLocationSettings() {
    return runAsyncCall(
      name: 'openLocationSettings',
      future: () async {
        await AppSettings.openAppSettings(
          type: AppSettingsType.location,
        );
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<String, AppError>> getAddressFromCoordinates({
    required LatLng coordinates,
    bool getSubUrbOnly = false,
  }) {
    return runAsyncCall(
      name: 'getAddressFromCoordinates',
      future: () async {
        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/geocode/json',
          queryParameters: {
            'latlng': '${coordinates.latitude},${coordinates.longitude}',
            'key': Env.googleMapsApiKey,
          },
        );

        if (response.data['status'] != 'OK' ||
            response.data['results'] == null ||
            response.data['results'] is! List ||
            (response.data['results'] as List).isEmpty) {
          throw AppError(
            message:
                response.data['error_message'] ??
                'Failed to fetch address from coordinates',
          );
        }

        if (response.data['results'][0]['formatted_address'] == null) {
          throw AppError(
            message: 'Failed to fetch address from coordinates',
          );
        }

        if (getSubUrbOnly) {
          // Extract general area (suburb/locality) from address components
          final results = response.data['results'] as List?;

          if (results?.isNotEmpty ?? false) {
            final addressComponents =
                results![results.length == 1 ? 0 : 1]['address_components']
                    as List?;
            if (addressComponents != null) {
              String? suburb;
              String? locality;
              String? administrativeArea;

              for (final component in addressComponents) {
                final types = component['types'] as List?;
                if (types != null) {
                  if (types.contains('sublocality') ||
                      types.contains('sublocality_level_1')) {
                    suburb = component['long_name'];
                  } else if (types.contains('locality')) {
                    locality = component['long_name'];
                  } else if (types.contains('administrative_area_level_1')) {
                    administrativeArea = component['long_name'];
                  }
                }
              }

              // Return the most specific area available
              final generalArea = suburb ?? locality ?? administrativeArea;
              if (generalArea != null) {
                return Success(generalArea);
              }
            }
          }
        }

        final address = response.data['results'][0]['formatted_address'];
        return Success(address);
      },
      onError: Failure.new,
    );
  }

  @override
  Stream<Position> getPositionStream({
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
    ),
  }) {
    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  @override
  Stream<double> getHeadingStream() {
    return FlutterCompass.events!.map(
      (event) => event.heading ?? 0.0,
    );
  }

  @override
  Future<Either<List<GooglePlace>, AppError>> getPlaces({
    required String searchString,
    required AlrtLocation currentUserLocation,
    bool showOnlyCities = false,
  }) {
    return runAsyncCall(
      name: 'getPlaces',
      future: () async {
        final result = await _dio
            .get(
              'https://maps.googleapis.com/maps/api/place/autocomplete/json',
              queryParameters: {
                'input': searchString,
                'key': Env.googleMapsApiKey,
                'locationbias':
                    'circle:50000@${currentUserLocation.latitude},${currentUserLocation.longitude}',
                if (showOnlyCities) "types": ["locality"],
              },
            )
            .then((response) async {
              final predictions = response.data['predictions'];
              if (predictions == null || predictions is! List) {
                return <Map<String, dynamic>>[];
              }

              final futures = <Future<Map<String, dynamic>>>[];

              for (final prediction in predictions) {
                if (prediction is Map<String, dynamic> &&
                    prediction.containsKey('place_id')) {
                  final data = {
                    'place_id': prediction['place_id'],
                    'description': prediction['description'],
                  };
                  final future =
                      getPlaceDetails(
                        placeId: prediction['place_id'],
                      ).then(
                        (value) => value.when(
                          (details) => {
                            ...data,
                            'latitude': details['geometry']['location']['lat'],
                            'longitude': details['geometry']['location']['lng'],
                            'bounds': {
                              'northeastLat':
                                  details['geometry']['viewport']['northeast']['lat'],
                              'northeastLng':
                                  details['geometry']['viewport']['northeast']['lng'],
                              'southwestLat':
                                  details['geometry']['viewport']['southwest']['lat'],
                              'southwestLng':
                                  details['geometry']['viewport']['southwest']['lng'],
                            },
                            'name': details['name'],
                            'address': details['formatted_address'],
                          },
                          (error) => data,
                        ),
                      );
                  futures.add(future);
                }
              }

              return Future.wait(futures);
            });
        final places = result.map((e) => GooglePlace.fromJson(e)).toList();
        return Success(places);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<Map<String, dynamic>, AppError>> getPlaceDetails({
    required String placeId,
  }) {
    return runAsyncCall(
      name: 'getPlaceDetails',
      future: () async {
        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/place/details/json',
          queryParameters: {
            'place_id': placeId,
            'key': Env.googleMapsApiKey,
            'fields': 'geometry,formatted_address,name',
          },
        );

        if (response.data['status'] != 'OK' ||
            response.data['result'] == null ||
            response.data['result'] is! Map<String, dynamic>) {
          throw AppError(
            message:
                response.data['error_message'] ??
                'Failed to fetch place details',
          );
        }

        return Success(
          response.data['result'] as Map<String, dynamic>,
        );
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<String, AppError>> getAddressFromCoordinatesPlugin({
    required LatLng coordinates,
    bool getSubUrbOnly = false,
  }) {
    return runAsyncCall(
      name: 'getAddressFromCoordinatesPlugin',
      future: () async {
        final placemarks = await placemarkFromCoordinates(
          coordinates.latitude,
          coordinates.longitude,
        );

        if (placemarks.isEmpty) {
          throw AppError(
            message: 'Failed to fetch address from coordinates',
          );
        }

        if (getSubUrbOnly) {
          final place = placemarks.first;
          final generalArea =
              place.subLocality ?? place.locality ?? place.administrativeArea;
          if (generalArea != null && generalArea.isNotEmpty) {
            return Success(generalArea);
          } else {
            throw AppError(
              message: 'Failed to fetch general area from coordinates',
            );
          }
        }

        final place = placemarks.first;
        final addresses = [
          if (place.street?.isNotEmpty ?? false) place.street,
          if (place.locality?.isNotEmpty ?? false) place.locality,
          if (place.administrativeArea?.isNotEmpty ?? false)
            place.administrativeArea,
          if (place.country?.isNotEmpty ?? false) place.country,
        ];
        final address = addresses.join(', ');

        return Success(address);
      },
      onError: Failure.new,
    );
  }
}
