import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:hazard_app/others/env.dart';

abstract class MapRepository {
  Future<Either<void, AppError>> animateCamera({
    required final CameraUpdate cameraUpdate,
    final Duration? duration,
  });

  Future<Either<LatLngBounds, AppError>> getVisibleRegion();

  Future<Either<List<GooglePlace>, AppError>> getPlaces({
    required final String searchString,
    required final AlrtLocation currentUserLocation,
    final bool showOnlyCities = false,
  });

  Future<Either<Map<String, dynamic>, AppError>> getPlaceDetails({
    required final String placeId,
  });

  Future<Either<RoutesApiResponse, AppError>> getRoute({
    required final LatLng origin,
    required final LatLng destination,
    final TravelMode travelMode = TravelMode.driving,
    final List<PolylineWayPoint>? intermediates,
  });

  Future<Either<String, AppError>> getAddressFromCoordinates({
    required final LatLng coordinates,
    final bool getSubUrbOnly = false,
  });
}

class MapRepositoryImpl implements MapRepository {
  const MapRepositoryImpl({
    required GoogleMapController googleMapController,
    required Dio dio,
    required PolylinePoints polylinePoints,
  }) : _googleMapController = googleMapController,
       _dio = dio,
       _polylinePoints = polylinePoints;

  final GoogleMapController _googleMapController;
  final Dio _dio;
  final PolylinePoints _polylinePoints;

  @override
  Future<Either<void, AppError>> animateCamera({
    required CameraUpdate cameraUpdate,
    Duration? duration,
  }) {
    return runAsyncCall(
      name: 'animateCamera',
      future: () async {
        await _googleMapController.animateCamera(
          cameraUpdate,
          duration: duration,
        );
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<LatLngBounds, AppError>> getVisibleRegion() {
    return runAsyncCall(
      name: 'getVisibleRegion',
      future: () async {
        final bounds = await _googleMapController.getVisibleRegion();
        return Success(bounds);
      },
      onError: Failure.new,
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
  Future<Either<RoutesApiResponse, AppError>> getRoute({
    required LatLng origin,
    required LatLng destination,
    TravelMode travelMode = TravelMode.driving,
    List<PolylineWayPoint>? intermediates,
  }) {
    return runAsyncCall(
      name: 'getRoute',
      future: () async {
        final request = RoutesApiRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          travelMode: travelMode,
          intermediates: intermediates,
          routingPreference: travelMode == TravelMode.driving
              ? RoutingPreference.trafficAware
              : RoutingPreference.unspecified,
          polylineQuality: PolylineQuality.overview,
          computeAlternativeRoutes: true,
          languageCode: 'en',
          regionCode: 'AU',
          // Override the package's default field mask so the Routes API also
          // returns turn-by-turn step data (instructions, maneuvers, per-step
          // polylines) for every route — including alternative routes.
          responseFieldMask: const [
            'routes.duration',
            'routes.staticDuration',
            'routes.distanceMeters',
            'routes.polyline.encodedPolyline',
            'routes.legs.distanceMeters',
            'routes.legs.duration',
            'routes.legs.steps.distanceMeters',
            'routes.legs.steps.staticDuration',
            'routes.legs.steps.polyline.encodedPolyline',
            'routes.legs.steps.startLocation',
            'routes.legs.steps.endLocation',
            'routes.legs.steps.navigationInstruction',
            'routes.legs.steps.travelMode',
            'routes.legs.steps.transitDetails',
          ].join(','),
        );

        final result = await _polylinePoints.getRouteBetweenCoordinatesV2(
          request: request,
        );

        if (!result.isSuccessful) {
          throw AppError(
            message: result.errorMessage ?? 'Failed to fetch route',
          );
        }

        return Success(result);
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
}
