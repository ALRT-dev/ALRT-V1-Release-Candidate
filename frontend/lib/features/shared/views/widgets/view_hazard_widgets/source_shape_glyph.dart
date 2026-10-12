import 'package:flutter/material.dart';

/// The filled source-system shape drawn next to the row-1 label on the
/// feed card and the detail header (approved boards, 12 Oct 2026).
///
/// Shape says WHICH SYSTEM, colour says how urgent: the AWS triangle, the
/// official diamond, the global-humanitarian rounded square and the ALRT
/// shield all take the locked band hex, passed in as [color] (the same
/// hex the card's band strip wears, so the two can never disagree).
/// Community reports are not drawn here; they carry a CategoryGlyph in the
/// category colour instead.
class SourceShapeGlyph extends StatelessWidget {
  const SourceShapeGlyph({
    super.key,
    required this.isAws,
    required this.isOfficial,
    this.isGlobalHumanitarian = false,
    this.isAlrtIntel = false,
    required this.color,
    this.size = 14,
  });

  final bool isAws;
  final bool isOfficial;
  final bool isGlobalHumanitarian;
  final bool isAlrtIntel;

  /// The locked band hex for this alert.
  final Color color;

  /// The widest dimension of the glyph in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    if (isAlrtIntel) {
      return CustomPaint(
        size: Size(size, size),
        painter: _ShieldPainter(color),
      );
    }
    if (isGlobalHumanitarian) {
      return Container(
        width: size * 0.8,
        height: size * 0.8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.2),
        ),
      );
    }
    if (isAws) {
      // 14 x 12 at the default size.
      return CustomPaint(
        size: Size(size, size * 12 / 14),
        painter: _TrianglePainter(color),
      );
    }
    if (isOfficial) {
      // A 10 px filled square, rotated into a diamond.
      final side = size * 10 / 14;
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Transform.rotate(
            angle: 0.7853981633974483,
            child: Container(width: side, height: side, color: color),
          ),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      color != oldDelegate.color;
}

class _ShieldPainter extends CustomPainter {
  const _ShieldPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h * 0.18)
      ..lineTo(w, h * 0.55)
      ..quadraticBezierTo(w, h * 0.85, w / 2, h)
      ..quadraticBezierTo(0, h * 0.85, 0, h * 0.55)
      ..lineTo(0, h * 0.18)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter oldDelegate) =>
      color != oldDelegate.color;
}
