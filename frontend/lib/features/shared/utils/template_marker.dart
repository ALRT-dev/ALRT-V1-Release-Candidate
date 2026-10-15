import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/views/widgets/map_pin_shape_painter.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

final _templateMarkers = <String, BitmapDescriptor>{};

/// Reuses existing pin artwork and shape rendering. Agency and fire-status
/// assets keep their original colours; custom ALRT colours affect ALRT pins.
Future<BitmapDescriptor?> templateMarker(Hazard hazard) async {
  final color = hazard.templateBandColor;
  if (color == null ||
      hazard.templateIconCategoryId != null ||
      hazard.fireStatus != null) {
    return null;
  }
  final key = '${hazard.effectiveMapShape.name}_${color.toARGB32()}';
  if (_templateMarkers.containsKey(key)) return _templateMarkers[key];
  try {
    final pin = MapPinShape(shape: hazard.effectiveMapShape, color: color);
    final image = await pin.toBitmapDescriptor(
      logicalSize: Size(pin.size, pin.totalHeight),
      imageSize: Size(pin.size * 2.5, pin.totalHeight * 2.5),
    );
    if (_templateMarkers.length >= 128) {
      _templateMarkers.remove(_templateMarkers.keys.first);
    }
    _templateMarkers[key] = image;
    return image;
  } catch (_) {
    return null;
  }
}
