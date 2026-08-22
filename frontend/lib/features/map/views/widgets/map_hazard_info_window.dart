import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/service_providers.dart';
import 'package:hazard_app/features/map/views/widgets/info_window_container.dart';
import 'package:hazard_app/features/map/views/widgets/map_hazard_preview.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';

class MapHazardInfoWindow extends ConsumerStatefulWidget {
  /// A custom InfoWindow that displays the MapHazardPreview widget above the selected marker.
  /// This widget calculates the screen position of the selected hazard marker and positions
  /// the preview widget accordingly, making it behave like a custom InfoWindow.
  const MapHazardInfoWindow({super.key});

  @override
  ConsumerState<MapHazardInfoWindow> createState() =>
      _MapHazardInfoWindowState();
}

class _MapHazardInfoWindowState extends ConsumerState<MapHazardInfoWindow> {
  final GlobalKey _previewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final selectedHazard = ref.watch(
      providerOfMap.select((value) => value.selectedHazard),
    );

    // Also watch camera position to trigger rebuilds when map moves
    ref.watch(
      providerOfMap.select((value) => value.cameraPosition),
    );

    // If no hazard is selected, don't show anything
    if (selectedHazard == null) {
      return const SizedBox.shrink();
    }

    // Check if hazard has valid coordinates
    final latitude = selectedHazard.latitude;
    final longitude = selectedHazard.longitude;
    if (latitude == null || longitude == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<ScreenCoordinate?>(
      future: _getMarkerScreenPosition(LatLng(latitude, longitude)),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final screenCoordinate = snapshot.data!;
        final screenSize = MediaQuery.of(context).size;

        // Calculate InfoWindow position - place it ABOVE the marker
        final markerX = screenCoordinate.x.toDouble();
        final markerY = screenCoordinate.y.toDouble();

        // Check if marker is visible on screen (with some margin for the InfoWindow)
        const double margin = 50.0; // Margin to account for InfoWindow size
        if (markerX < -margin ||
            markerX > screenSize.width + margin ||
            markerY < -margin ||
            markerY > screenSize.height + margin) {
          // Marker is off-screen, don't show InfoWindow
          return const SizedBox.shrink();
        }

        // Calculate dynamic height offset
        final previewHalfHeight = _getPreviewHalfHeight();

        // Position InfoWindow above the marker
        // Position above marker (adjust this value as needed)
        final infoWindowTop = markerY - 130 - previewHalfHeight;
        final infoWindowLeft =
            markerX -
            ((context.screenSize.width - 40) /
                2); // Center horizontally on marker

        return Positioned(
          left:
              infoWindowLeft, // Follow marker horizontally without constraints
          top: infoWindowTop, // Remove constraints - follow marker exactly
          child: Material(
            type: MaterialType.transparency,
            child: InfoWindowContainer(
              child: Container(
                key: _previewKey,
                constraints: BoxConstraints(
                  maxWidth: context.screenSize.width - 40,
                  minWidth: 200,
                ),
                child: const MapHazardPreview(),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Gets the screen coordinate for a marker position
  Future<ScreenCoordinate?> _getMarkerScreenPosition(LatLng position) async {
    try {
      final mapService = ref.read(providerOfMapService);
      return await mapService.getScreenCoordinate(position);
    } catch (e) {
      return null;
    }
  }

  /// Gets half the height of the MapHazardPreview widget
  double _getPreviewHalfHeight() {
    try {
      final RenderBox? renderBox =
          _previewKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        return renderBox.size.height / 2;
      }
    } catch (e) {
      // Ignore errors and return fallback value
    }
    // Return fallback value (half of 110.0) if measurement is not available
    return 55.0;
  }
}
