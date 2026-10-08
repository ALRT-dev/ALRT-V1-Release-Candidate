import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/utils/maps_availability.dart';

void main() {
  test('the no-map area reaches about 50 km each way around the person', () {
    const brisbane = LatLng(-27.47, 153.03);
    final bounds = noMapHazardBounds(brisbane);
    expect(bounds.contains(brisbane), isTrue);
    // ~0.449 degrees of latitude is 50 km.
    expect(bounds.northeast.latitude - brisbane.latitude, closeTo(0.449, 0.01));
    expect(brisbane.latitude - bounds.southwest.latitude, closeTo(0.449, 0.01));
    // Longitude degrees are shorter away from the equator, so the box is
    // wider in degrees: 50 / (111.32 * cos 27.47) ~ 0.506.
    expect(
      bounds.northeast.longitude - brisbane.longitude,
      closeTo(0.506, 0.01),
    );
    // 40 km away is in, 70 km away is out.
    expect(bounds.contains(const LatLng(-27.11, 153.03)), isTrue);
    expect(bounds.contains(const LatLng(-26.84, 153.03)), isFalse);
  });

  test('the no-map area never leaves valid coordinates', () {
    final polar = noMapHazardBounds(const LatLng(89.9, 0));
    expect(polar.northeast.latitude, lessThanOrEqualTo(90));
    expect(polar.southwest.longitude, greaterThanOrEqualTo(-180));
    expect(polar.northeast.longitude, lessThanOrEqualTo(180));

    final dateLine = noMapHazardBounds(const LatLng(-17.7, 179.9));
    expect(dateLine.northeast.longitude, lessThanOrEqualTo(180));
    expect(dateLine.southwest.longitude, lessThan(179.9));
  });
}
