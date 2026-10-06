import 'package:geolocator/geolocator.dart';

/// Calculates the distance in km between two geographical points.
double calculateDistanceInKm(
  double startLatitude,
  double startLongitude,
  double endLatitude,
  double endLongitude,
) {
  final meter = calculateDistanceInMeters(
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
  );
  return meter / 1000; // Convert to kilometers
}

/// Calculates the distance in meters between two geographical points.
double calculateDistanceInMeters(
  double startLatitude,
  double startLongitude,
  double endLatitude,
  double endLongitude,
) {
  return Geolocator.distanceBetween(
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
  );
}
