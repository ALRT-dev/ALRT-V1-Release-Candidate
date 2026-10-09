import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/others/app_colors.dart';

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw north pointer (red) - left half
    final northPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final northPath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.9) // Top point
      ..lineTo(center.dx - radius * 0.3, center.dy) // Left center
      ..lineTo(center.dx + radius * 0.3, center.dy) // Right center
      ..close();

    canvas.drawPath(northPath, northPaint);

    // Draw south pointer (grey) - right half
    final southPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    final southPath = Path()
      ..moveTo(center.dx, center.dy + radius * 0.9) // Bottom point
      ..lineTo(center.dx + radius * 0.3, center.dy) // Right center
      ..lineTo(center.dx - radius * 0.3, center.dy) // Left center
      ..close();

    canvas.drawPath(southPath, southPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CustomCompassButton extends ConsumerStatefulWidget {
  const CustomCompassButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomCompassButtonState();
}

class _CustomCompassButtonState extends ConsumerState<CustomCompassButton> {
  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(providerOfMap);
    final bearing = mapState.cameraPosition.bearing;

    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: bearing == 0 ? 0.0 : 1.0,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: 48.spMin,
          height: 48.spMin,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(
              color: AppColors.lightGrey,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10.0,
                offset: Offset(0, 0.0),
              ),
            ],
          ),
          child: Transform.rotate(
            angle: -bearing * pi / 180,
            child: Padding(
              padding: EdgeInsets.all(12.spMin),
              child: CustomPaint(
                painter: CompassPainter(),
                size: Size(24.spMin, 24.spMin),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles tap on the custom compass button to reset map bearing to north.
  void _handleTap() {
    final currentPosition = ref.read(providerOfMap).cameraPosition;
    ref
        .read(providerOfMap.notifier)
        .animateToCameraUpdate(
          cameraUpdate: CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentPosition.target,
              zoom: currentPosition.zoom,
              tilt: currentPosition.tilt,
              bearing: 0,
            ),
          ),
        );
  }
}
