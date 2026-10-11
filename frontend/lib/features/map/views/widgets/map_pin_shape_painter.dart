import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hazard_app/features/shared/models/hazard_source_model.dart';

/// Renders a map pin as a coloured shape with an optional pointer tail.
///
/// The five shapes mirror AlertCardStyle.systemShapeIcon:
/// - Triangle (AWS): equilateral triangle, point up
/// - Diamond (Official): rotated 45° square
/// - Circle (Community): plain circle
/// - Square (Global humanitarian): rounded square
/// - Shield (ALRT Intel): shield outline
///
/// Each is filled with the band colour and drawn at [size]×[size] logical
/// pixels, with a 6 px pointer tail below so the pin's tip sits on the
/// geographic coordinate.
class MapPinShape extends StatelessWidget {
  const MapPinShape({
    super.key,
    required this.shape,
    required this.color,
    this.size = 28,
  });

  final HazardSourceShape shape;
  final Color color;
  final double size;

  /// Total logical height including the pointer tail.
  double get totalHeight => size + 8;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: totalHeight,
      child: CustomPaint(
        size: Size(size, totalHeight),
        painter: _PinPainter(
          shape: shape,
          fillColor: color,
          shapeSize: size,
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  _PinPainter({
    required this.shape,
    required this.fillColor,
    required this.shapeSize,
  });

  final HazardSourceShape shape;
  final Color fillColor;
  final double shapeSize;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final cx = canvasSize.width / 2;
    // The shape is centred vertically within the top shapeSize px.
    final cy = shapeSize / 2;
    final r = shapeSize / 2 - 2; // leave room for stroke

    // Draw the pointer tail first (shadow, then fill).
    final tailPath = Path()
      ..moveTo(cx - 5, shapeSize - 3)
      ..lineTo(cx, canvasSize.height)
      ..lineTo(cx + 5, shapeSize - 3)
      ..close();
    canvas.drawPath(tailPath, shadowPaint);
    canvas.drawPath(tailPath, paint);

    // Draw shape shadow, fill, then white stroke.
    final shapePath = _shapePath(cx, cy, r);
    canvas.drawPath(shapePath, shadowPaint);
    canvas.drawPath(shapePath, paint);
    canvas.drawPath(shapePath, strokePaint);
  }

  Path _shapePath(double cx, double cy, double r) {
    switch (shape) {
      case HazardSourceShape.triangle:
        return _trianglePath(cx, cy, r);
      case HazardSourceShape.diamond:
        return _diamondPath(cx, cy, r);
      case HazardSourceShape.circle:
        return _circlePath(cx, cy, r);
      case HazardSourceShape.square:
        return _roundedSquarePath(cx, cy, r);
      case HazardSourceShape.shield:
        return _shieldPath(cx, cy, r);
    }
  }

  Path _trianglePath(double cx, double cy, double r) {
    // Equilateral triangle, point up.
    final h = r * math.sqrt(3);
    return Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + h / 2, cy + r * 0.6)
      ..lineTo(cx - h / 2, cy + r * 0.6)
      ..close();
  }

  Path _diamondPath(double cx, double cy, double r) {
    return Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r, cy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - r, cy)
      ..close();
  }

  Path _circlePath(double cx, double cy, double r) {
    return Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
  }

  Path _roundedSquarePath(double cx, double cy, double r) {
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: r * 1.7,
      height: r * 1.7,
    );
    return Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r * 0.3)));
  }

  Path _shieldPath(double cx, double cy, double r) {
    // A simplified shield: wider at the top, pointed at the bottom.
    final w = r * 0.9;
    final top = cy - r;
    final bottom = cy + r;
    final mid = top + (bottom - top) * 0.5;
    return Path()
      ..moveTo(cx - w, top + r * 0.15)
      ..quadraticBezierTo(cx - w, top, cx, top)
      ..quadraticBezierTo(cx + w, top, cx + w, top + r * 0.15)
      ..lineTo(cx + w, mid)
      ..quadraticBezierTo(cx + w, bottom - r * 0.2, cx, bottom)
      ..quadraticBezierTo(cx - w, bottom - r * 0.2, cx - w, mid)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _PinPainter old) =>
      shape != old.shape || fillColor != old.fillColor || shapeSize != old.shapeSize;
}
