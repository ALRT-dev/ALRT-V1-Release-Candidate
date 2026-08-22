import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

part 'hazard_markers_bitmaps_provider_state.freezed.dart';

@freezed
abstract class HazardMarkersBitmapsProviderState
    with _$HazardMarkersBitmapsProviderState {
  const factory HazardMarkersBitmapsProviderState({
    /// The map of hazard (severity and category emoji) to their corresponding marker bitmaps.
    @Default({}) final Map<String, BitmapDescriptor> markerBitmaps,

    /// Bitmap for small red dot icon used at low zoom levels.
    final BitmapDescriptor? redDotBitmap,

    /// The state of generating marker bitmaps.
    @Default(GenerateMarkerBitmaps.initial())
    final GenerateMarkerBitmaps generateMarkerBitmaps,
  }) = _HazardMarkersBitmapsProviderState;
}

@freezed
class GenerateMarkerBitmaps with _$GenerateMarkerBitmaps {
  const factory GenerateMarkerBitmaps.initial() = _GenerateMarkerBitmapsInitial;
  const factory GenerateMarkerBitmaps.loading() = _GenerateMarkerBitmapsLoading;
  const factory GenerateMarkerBitmaps.success(
    final Map<String, BitmapDescriptor> markerBitmaps,
  ) = _GenerateMarkerBitmapsSuccess;
  const factory GenerateMarkerBitmaps.failure(
    final AppError error,
  ) = _GenerateMarkerBitmapsFailure;
}
