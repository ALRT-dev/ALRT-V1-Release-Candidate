import 'package:flutter/material.dart';
import 'package:hazard_app/others/app_colors.dart';

/// A custom painter that draws a pointer/arrow pointing downward.
/// This is used to make the InfoWindow look more like a traditional map InfoWindow.
class InfoWindowPointer extends CustomPainter {
  final Color color;
  final double size;

  const InfoWindowPointer({
    this.color = Colors.white,
    this.size = 12.0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();

    // Create a triangle pointing downward
    final double centerX = canvasSize.width / 2;
    final double centerY = canvasSize.height / 2;

    path.moveTo(centerX - size / 2, centerY - size / 2);
    path.lineTo(centerX + size / 2, centerY - size / 2);
    path.lineTo(centerX, centerY + size / 2);
    path.close();

    // Draw shadow first
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final Path shadowPath = Path.from(path);
    shadowPath.shift(const Offset(1, 2));
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw the main pointer
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is InfoWindowPointer &&
        (oldDelegate.color != color || oldDelegate.size != size);
  }
}

/// A widget that creates an InfoWindow-style container with a pointer arrow.
class InfoWindowContainer extends StatelessWidget {
  final Widget child;

  const InfoWindowContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main content container
        child,
        // Pointer/arrow
        SizedBox(
          width: 24,
          height: 12,
          child: CustomPaint(
            painter: InfoWindowPointer(
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}
