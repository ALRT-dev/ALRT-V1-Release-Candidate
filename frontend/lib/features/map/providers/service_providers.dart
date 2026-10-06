import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/map/services/location_service.dart';
import 'package:hazard_app/features/map/services/map_service.dart';

/// Provider of [MapService].
final providerOfMapService = Provider<MapService>(
  MapService.new,
);

/// Provider of [LocationService].
final providerOfLocationService = Provider<LocationService>(
  LocationService.new,
);
