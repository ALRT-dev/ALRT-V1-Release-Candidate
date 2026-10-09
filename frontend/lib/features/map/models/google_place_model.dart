import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/map/models/alrt_location_bounds_model.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';

part 'google_place_model.freezed.dart';
part 'google_place_model.g.dart';

@freezed
abstract class GooglePlace with _$GooglePlace {
  const GooglePlace._();

  const factory GooglePlace({
    @JsonKey(name: 'place_id') required final String placeId,
    required final String description,
    required final double latitude,
    required final double longitude,
    required final String name,
    required final String address,
    required final AlrtLocationBounds bounds,
  }) = _GooglePlace;

  /// Converts [GooglePlace] to [AlrtLocation].
  AlrtLocation get toAlrtLocation {
    return AlrtLocation(
      latitude: latitude,
      longitude: longitude,
      address: address,
      name: name,
      bounds: bounds,
    );
  }

  factory GooglePlace.fromJson(Map<String, dynamic> json) =>
      _$GooglePlaceFromJson(json);
}
