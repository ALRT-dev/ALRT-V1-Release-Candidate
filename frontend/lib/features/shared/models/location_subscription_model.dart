import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'location_subscription_model.freezed.dart';
part 'location_subscription_model.g.dart';

@freezed
abstract class LocationSubscription with _$LocationSubscription {
  const LocationSubscription._();

  const factory LocationSubscription({
    /// The subscription's unique identifier.
    final String? id,

    /// The northeast latitude of the subscription area.
    required final double northeastLat,

    /// The northeast longitude of the subscription area.
    required final double northeastLng,

    /// The southwest latitude of the subscription area.
    required final double southwestLat,

    /// The southwest longitude of the subscription area.
    required final double southwestLng,

    /// Indicates if this subscription is for the user's own location.
    @Default(false) final bool isOwnLocation,

    /// The name of the location.
    final String? name,

    /// The human-readable address of the location.
    final String? address,

    /// The timestamp when the subscription was created.
    final DateTime? createdAt,

    /// The timestamp when the subscription was last updated.
    final DateTime? updatedAt,
  }) = _LocationSubscription;

  /// Computes the geographical bounds of the subscription area.
  LatLngBounds get bounds => LatLngBounds(
    northeast: LatLng(northeastLat, northeastLng),
    southwest: LatLng(southwestLat, southwestLng),
  );

  /// Computes the center point of the subscription area.
  LatLng get center => LatLng(
    (northeastLat + southwestLat) / 2,
    (northeastLng + southwestLng) / 2,
  );

  /// Calculates the approximate radius in kilometers from the bounds.
  /// This uses the Haversine formula to calculate distance from center to northeast corner.
  double get radiusInKm {
    const earthRadiusKm = 6371.0;

    final centerLat = center.latitude;
    final centerLng = center.longitude;

    // Calculate distance from center to northeast corner
    final lat1Rad = centerLat * math.pi / 180;
    final lat2Rad = northeastLat * math.pi / 180;
    final deltaLatRad = (northeastLat - centerLat) * math.pi / 180;
    final deltaLngRad = (northeastLng - centerLng) * math.pi / 180;

    final a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  factory LocationSubscription.fromJson(Map<String, dynamic> json) =>
      _$LocationSubscriptionFromJson(json);
}
