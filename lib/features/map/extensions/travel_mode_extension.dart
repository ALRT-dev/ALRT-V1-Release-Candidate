import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

extension TravelModeExtension on TravelMode {
  /// Gets the display text for the travel mode.
  String get displayText {
    return switch (this) {
      TravelMode.driving => 'Drive',
      TravelMode.transit => 'Transit',
      TravelMode.walking => 'Walk',
      TravelMode.bicycling => 'Cycle',
      TravelMode.twoWheeler => 'Two Wheeler',
    };
  }

  /// Gets the icon for the travel mode.
  IconData get iconData {
    return switch (this) {
      TravelMode.driving => Icons.directions_car_rounded,
      TravelMode.transit => Icons.directions_train_rounded,
      TravelMode.walking => Icons.directions_walk_rounded,
      TravelMode.bicycling => Icons.directions_bike_rounded,
      TravelMode.twoWheeler => Icons.motorcycle_rounded,
    };
  }
}
