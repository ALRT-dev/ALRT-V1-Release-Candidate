import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class RouteLabelMarker extends StatelessWidget {
  const RouteLabelMarker({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RouteArrowPainter(
        backgroundColor: backgroundColor ?? AppColors.primary,
        borderColor: AppColors.white,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          22.spMin, // Less left padding since arrow is on the left
          5.spMin,
          12.spMin,
          5.spMin, // Balanced vertical padding
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? AppColors.white,
            fontSize: 12.spMin,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ).pad(8.0);
  }
}

class RouteArrowPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;

  RouteArrowPainter({
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = AppColors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    // Calculate dimensions
    final double cornerRadius = 8.0;
    final double arrowWidth = 12.0;
    final double arrowHeight = 12.0;

    // Create the speech bubble path with arrow pointing right
    final path = Path();

    // Start from top-left corner (after arrow space)
    path.moveTo(arrowWidth + cornerRadius, 0);

    // Top edge
    path.lineTo(size.width - cornerRadius, 0);

    // Top-right corner
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
    );

    // Right edge
    path.lineTo(size.width, size.height - cornerRadius);

    // Bottom-right corner
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
    );

    // Bottom edge
    path.lineTo(arrowWidth + cornerRadius, size.height);

    // Bottom-left corner
    path.arcToPoint(
      Offset(arrowWidth, size.height - cornerRadius),
      radius: Radius.circular(cornerRadius),
    );

    // Left edge to arrow end
    final arrowStart = (size.height - arrowHeight) / 2;
    path.lineTo(arrowWidth, arrowStart + arrowHeight);

    // Arrow pointing left (toward route)
    path.lineTo(0, arrowStart + arrowHeight / 2);
    path.lineTo(arrowWidth, arrowStart);

    // Continue left edge
    path.lineTo(arrowWidth, cornerRadius);

    // Top-left corner
    path.arcToPoint(
      Offset(arrowWidth + cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
    );

    path.close();

    // Draw shadow (slightly offset)
    canvas.save();
    canvas.translate(2, 2);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Draw the filled shape
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! RouteArrowPainter ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor;
  }
}
