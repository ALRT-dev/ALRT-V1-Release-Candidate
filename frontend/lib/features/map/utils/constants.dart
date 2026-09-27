import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';

/// The default latitude for the map, centered on Sydney, Australia.
const kDefaultLatitude = -33.873265;

/// The default longitude for the map, centered on Sydney, Australia.
const kDefaultLongitude = 151.209845;

/// The default user location, centered on Sydney, Australia.
const kDefaultUserLocation = AlrtLocation(
  latitude: kDefaultLatitude,
  longitude: kDefaultLongitude,
);

/// The default camera position for the map, centered at [kDefaultLatitude] and [kDefaultLongitude].
const kDefaultCameraPosition = CameraPosition(
  target: LatLng(kDefaultLatitude, kDefaultLongitude),
  zoom: 12.0,
);
