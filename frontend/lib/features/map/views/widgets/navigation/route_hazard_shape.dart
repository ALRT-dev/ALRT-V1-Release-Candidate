import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Which source shape a hazard wears on the route screens (CLAUDE.md:
/// AWS triangle, official diamond, community disc, ALRT shield).
enum RouteHazardShapeKind { triangle, diamond, circle, shield }

/// The source shape for [hazard].
RouteHazardShapeKind routeHazardShapeKindOf(final Hazard hazard) {
  if (hazard.isAlrtIntel) return RouteHazardShapeKind.shield;
  if (hazard.isUserReported) return RouteHazardShapeKind.circle;
  if (hazard.isAwsCompliant == true) return RouteHazardShapeKind.triangle;
  return RouteHazardShapeKind.diamond;
}

/// The short level words shown at the right of a hazard row on the route
/// screens: the AWS level, "Unverified" for community reports, else none.
String routeHazardLevelOf(final Hazard hazard) {
  if (hazard.isUserReported) return 'Unverified';
  if (hazard.isAwsCompliant == true) return hazard.severityTitle;
  return '';
}

/// A filled source shape in the hazard's band colour, as the prototype
/// draws hazards on the route options, Travelling and en route sheet.
class RouteHazardShape extends StatelessWidget {
  const RouteHazardShape({
    super.key,
    required this.hazard,
    this.size = 22,
  });

  final Hazard hazard;
  final double size;

  @override
  Widget build(BuildContext context) {
    final kind = routeHazardShapeKindOf(hazard);
    final color = hazard.color == Colors.transparent
        ? const Color(0xFF8A93A0)
        : hazard.color;
    if (kind == RouteHazardShapeKind.shield) {
      return SizedBox(
        width: size,
        height: size,
        child: Icon(LucideIcons.shield, size: size, color: color),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RouteHazardShapePainter(kind: kind, color: color),
      ),
    );
  }
}

/// Paints one filled source shape filling its box.
class RouteHazardShapePainter extends CustomPainter {
  const RouteHazardShapePainter({required this.kind, required this.color});

  final RouteHazardShapeKind kind;
  final Color color;

  /// Draws [kind] centred on [center] at [size] on [canvas]. Shared with the
  /// route preview so the map and the rows use the same shapes.
  static void paintShape(
    final Canvas canvas,
    final Offset center,
    final double size,
    final RouteHazardShapeKind kind,
    final Color color,
  ) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final edge = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, size / 14);
    final half = size / 2;
    switch (kind) {
      case RouteHazardShapeKind.triangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - half)
          ..lineTo(center.dx + half, center.dy + half * 0.8)
          ..lineTo(center.dx - half, center.dy + half * 0.8)
          ..close();
        canvas
          ..drawPath(path, fill)
          ..drawPath(path, edge);
      case RouteHazardShapeKind.diamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - half)
          ..lineTo(center.dx + half, center.dy)
          ..lineTo(center.dx, center.dy + half)
          ..lineTo(center.dx - half, center.dy)
          ..close();
        canvas
          ..drawPath(path, fill)
          ..drawPath(path, edge);
      case RouteHazardShapeKind.circle:
      case RouteHazardShapeKind.shield:
        canvas
          ..drawCircle(center, half * 0.85, fill)
          ..drawCircle(center, half * 0.85, edge);
    }
  }

  @override
  void paint(final Canvas canvas, final Size size) {
    paintShape(
      canvas,
      Offset(size.width / 2, size.height / 2),
      math.min(size.width, size.height),
      kind,
      color,
    );
  }

  @override
  bool shouldRepaint(covariant RouteHazardShapePainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.color != color;
}
