import 'package:freezed_annotation/freezed_annotation.dart';

part 'alrt_location_bounds_model.freezed.dart';
part 'alrt_location_bounds_model.g.dart';

@freezed
abstract class AlrtLocationBounds with _$AlrtLocationBounds {
  const factory AlrtLocationBounds({
    required final double northeastLat,
    required final double northeastLng,
    required final double southwestLat,
    required final double southwestLng,
  }) = _AlrtLocationBounds;

  factory AlrtLocationBounds.fromJson(Map<String, dynamic> json) =>
      _$AlrtLocationBoundsFromJson(json);
}
