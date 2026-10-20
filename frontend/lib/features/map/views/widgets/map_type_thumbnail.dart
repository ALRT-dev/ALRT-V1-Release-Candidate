import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A small painted picture of each map style for the Map details picker
/// (product owner, 16 Oct 2026: the line icons looked cheap). Default is a
/// cream street map with roads and a park, Satellite a dark aerial with a
/// lit road, Terrain a green relief with contour lines. Drawn with Canvas,
/// so it is crisp at any size and needs no image assets.
class MapTypeThumbnail extends StatelessWidget {
  const MapTypeThumbnail({
    super.key,
    required this.mapType,
    this.width = 64,
    this.height = 44,
    this.radius = 10,
  });

  final MapType mapType;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        size: Size(width, height),
        painter: _MapTypePainter(mapType),
      ),
    );
  }
}

class _MapTypePainter extends CustomPainter {
  const _MapTypePainter(this.mapType);

  final MapType mapType;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    switch (mapType) {
      case MapType.satellite:
      case MapType.hybrid:
        _satellite(canvas, rect, w, h);
      case MapType.terrain:
        _terrain(canvas, rect, w, h);
      case MapType.normal:
      case MapType.none:
        _streets(canvas, rect, w, h);
    }
  }

  void _streets(Canvas c, Rect r, double w, double h) {
    c.drawRect(r, Paint()..color = const Color(0xFFF2EFE8));
    // Water in the corner and a park block.
    c.drawPath(
      Path()
        ..moveTo(0, h * 0.62)
        ..quadraticBezierTo(w * 0.18, h * 0.5, w * 0.1, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = const Color(0xFFA9D8EF),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.56, h * 0.14, w * 0.3, h * 0.34),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFCFE8CF),
    );
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = h * 0.11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final edge = Paint()
      ..color = const Color(0xFFD9D4C7)
      ..strokeWidth = h * 0.15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final roads = [
      Path()
        ..moveTo(w * 0.22, 0)
        ..lineTo(w * 0.34, h),
      Path()
        ..moveTo(0, h * 0.42)
        ..lineTo(w, h * 0.3),
      Path()
        ..moveTo(w * 0.5, h * 0.3)
        ..lineTo(w * 0.62, h),
    ];
    for (final p in roads) {
      c.drawPath(p, edge);
    }
    for (final p in roads) {
      c.drawPath(p, road);
    }
    // The main road in the brand orange, as Google draws a highway.
    c.drawPath(
      Path()
        ..moveTo(0, h * 0.42)
        ..lineTo(w, h * 0.3),
      Paint()
        ..color = const Color(0xFFF6C66B)
        ..strokeWidth = h * 0.09
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void _satellite(Canvas c, Rect r, double w, double h) {
    c.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E4A2F), Color(0xFF1E3A2A), Color(0xFF3B4A3A)],
        ).createShader(r),
    );
    // Field patches.
    final patch = Paint()..color = const Color(0xFF4E6B3C);
    c.drawRect(Rect.fromLTWH(w * 0.05, h * 0.1, w * 0.3, h * 0.3), patch);
    c.drawRect(
      Rect.fromLTWH(w * 0.6, h * 0.55, w * 0.35, h * 0.4),
      Paint()..color = const Color(0xFF6B5A3A),
    );
    // Water.
    c.drawPath(
      Path()
        ..moveTo(w, 0)
        ..lineTo(w, h * 0.4)
        ..quadraticBezierTo(w * 0.8, h * 0.3, w * 0.7, 0)
        ..close(),
      Paint()..color = const Color(0xFF1D3F5E),
    );
    // A lit road.
    c.drawPath(
      Path()
        ..moveTo(0, h * 0.75)
        ..quadraticBezierTo(w * 0.5, h * 0.55, w, h * 0.7),
      Paint()
        ..color = const Color(0xFFE8E2C8)
        ..strokeWidth = h * 0.06
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void _terrain(Canvas c, Rect r, double w, double h) {
    c.drawRect(r, Paint()..color = const Color(0xFFDDEBD2));
    // Relief: darker green hill, lighter lowland.
    c.drawPath(
      Path()
        ..moveTo(0, h)
        ..lineTo(0, h * 0.55)
        ..quadraticBezierTo(w * 0.3, h * 0.05, w * 0.6, h * 0.45)
        ..quadraticBezierTo(w * 0.8, h * 0.7, w, h * 0.5)
        ..lineTo(w, h)
        ..close(),
      Paint()..color = const Color(0xFFBFD9A8),
    );
    final contour = Paint()
      ..color = const Color(0xFF8FAE7A)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 4; i++) {
      final t = i / 4;
      c.drawPath(
        Path()
          ..moveTo(w * (0.05 + t * 0.12), h)
          ..quadraticBezierTo(
            w * 0.3,
            h * (0.2 + t * 0.14),
            w * (0.6 - t * 0.04),
            h * (0.5 + t * 0.09),
          )
          ..quadraticBezierTo(w * 0.8, h * (0.75 + t * 0.05), w, h * (0.55 + t * 0.1)),
        contour,
      );
    }
    // A river.
    c.drawPath(
      Path()
        ..moveTo(w * 0.7, 0)
        ..quadraticBezierTo(w * 0.9, h * 0.3, w * 0.75, h * 0.6)
        ..quadraticBezierTo(w * 0.65, h * 0.8, w * 0.85, h),
      Paint()
        ..color = const Color(0xFF8CC6E0)
        ..strokeWidth = h * 0.07
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _MapTypePainter old) => old.mapType != mapType;
}
