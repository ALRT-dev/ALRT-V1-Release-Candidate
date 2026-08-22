import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/providers/states/hazard_markers_bitmaps_provider_state.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/hazard_service.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

final providerOfHazardMarkerBitmaps =
    StateNotifierProvider<
      HazardMarkerBitmapsProvider,
      HazardMarkersBitmapsProviderState
    >(
      (ref) => HazardMarkerBitmapsProvider(
        ref: ref,
        state: const HazardMarkersBitmapsProviderState(),
      ),
    );

class HazardMarkerBitmapsProvider
    extends StateNotifier<HazardMarkersBitmapsProviderState> {
  HazardMarkerBitmapsProvider({
    required final Ref ref,
    required final HazardMarkersBitmapsProviderState state,
  }) : _ref = ref,
       super(state) {
    _createRedDotBitmap();
  }

  final Ref _ref;
  HazardService get _hazardService => _ref.read(providerOfHazardService);

  /// Creates a small red dot icon for low zoom levels
  Future<void> _createRedDotBitmap() async {
    return runAsyncCall(
      name: 'createRedDotBitmap',
      future: () async {
        const size = 10.0;

        final widget = Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.darkRed,
            shape: BoxShape.circle,
          ),
        );

        final redDotBitmap = await widget.toBitmapDescriptor(
          logicalSize: const Size(size, size),
          imageSize: const Size(size * 2, size * 2),
        );
        updateRedDotBitmap(redDotBitmap);
      },
      onError: (_) {},
    );
  }

  /// Generates marker bitmaps for all hazard categories and severities.
  Future<void> generateMarkerBitmaps() async {
    state = state.copyWith(
      generateMarkerBitmaps: const GenerateMarkerBitmaps.loading(),
    );

    final result = await _hazardService.generateHazardMarkerBitmaps();
    if (!mounted) return;

    result.when(
      (markerBitmaps) {
        state = state.copyWith(
          markerBitmaps: markerBitmaps,
          generateMarkerBitmaps: GenerateMarkerBitmaps.success(markerBitmaps),
        );
      },
      (error) {
        state = state.copyWith(
          generateMarkerBitmaps: GenerateMarkerBitmaps.failure(error),
        );
      },
    );
  }

  /// Updates [HazardMarkersBitmapsProviderState.redDotBitmap] with the given [redDotBitmap].
  void updateRedDotBitmap(final BitmapDescriptor redDotBitmap) {
    state = state.copyWith(
      redDotBitmap: redDotBitmap,
    );
  }
}
