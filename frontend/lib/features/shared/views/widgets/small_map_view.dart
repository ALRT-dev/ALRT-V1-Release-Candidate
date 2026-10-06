import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/providers/hazard_markers_bitmaps_provider.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/others/app_colors.dart';

class SmallMapView extends ConsumerStatefulWidget {
  const SmallMapView({
    super.key,
    required this.hazard,
    this.height = 200,
    this.onTap,
  });

  /// The hazard to display on the map
  final Hazard hazard;

  /// The height of the map view
  final double height;

  /// Optional callback when the map is tapped
  final VoidCallback? onTap;

  @override
  ConsumerState<SmallMapView> createState() => _SmallMapViewState();
}

class _SmallMapViewState extends ConsumerState<SmallMapView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarker();
  }

  @override
  void didUpdateWidget(SmallMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hazard.id != widget.hazard.id ||
        oldWidget.hazard.latitude != widget.hazard.latitude ||
        oldWidget.hazard.longitude != widget.hazard.longitude ||
        oldWidget.hazard.severity != widget.hazard.severity ||
        oldWidget.hazard.categoryId != widget.hazard.categoryId) {
      _createMarker();
    }
  }

  void _createMarker() {
    if (widget.hazard.latitude == null || widget.hazard.longitude == null) {
      setState(() {
        _markers = {};
      });
      return;
    }

    final markerBitmaps = ref.read(
      providerOfHazardMarkerBitmaps.select((value) => value.markerBitmaps),
    );

    final bitmapDescriptor = widget.hazard.getMarkerBitmapDescriptor(
      markerBitmaps,
    );

    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId(widget.hazard.id ?? 'hazard_marker'),
          position: LatLng(widget.hazard.latitude!, widget.hazard.longitude!),
          icon: bitmapDescriptor ?? BitmapDescriptor.defaultMarker,
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container if no location data
    if (widget.hazard.latitude == null || widget.hazard.longitude == null) {
      return const SizedBox.shrink();
    }

    // Listen to marker bitmap changes and update marker
    ref.listen(
      providerOfHazardMarkerBitmaps.select((value) => value.markerBitmaps),
      (previous, next) {
        if (previous != next) {
          _createMarker();
        }
      },
    );

    return SizedBox(
      height: widget.height.spMin,
      child: Stack(
        children: [
          // Wrap in a Listener to handle gesture conflicts better
          Listener(
            onPointerDown: (_) {
              // This helps prevent parent scroll views from intercepting gestures
            },
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.hazard.latitude!,
                  widget.hazard.longitude!,
                ),
                zoom: 7.0,
              ),
              markers: _markers,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              buildingsEnabled: true,
              trafficEnabled: false,
              mapType: MapType.normal,
              onTap: (_) {
                // Call the optional tap callback
                widget.onTap?.call();
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                Factory<ScaleGestureRecognizer>(
                  () => ScaleGestureRecognizer(),
                ),
                Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer(),
                ),
                Factory<HorizontalDragGestureRecognizer>(
                  () => HorizontalDragGestureRecognizer(),
                ),
              },
            ),
          ),
          // Add subtle overlay if onTap is provided
          if (widget.onTap != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(6.spMin),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6.spMin),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.open_in_new,
                  size: 16.spMin,
                  color: AppColors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
