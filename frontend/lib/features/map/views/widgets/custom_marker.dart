import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class CustomMarker extends ConsumerStatefulWidget {
  const CustomMarker({
    super.key,
    required this.markerImagePath,
    required this.emoji,
  });

  final String markerImagePath;
  final String emoji;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CustomMarkerState();
}

class _CustomMarkerState extends ConsumerState<CustomMarker> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          widget.markerImagePath,
          width: 38.spMin,
        ),
        Positioned.fill(
          bottom: 17.spMin,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(3.spMin),
              decoration: BoxDecoration(
                color: AppColors.black26,
                shape: BoxShape.circle,
              ),
              child: Text(
                widget.emoji,
                style: TextStyle(
                  shadows: [
                    Shadow(
                      offset: Offset(0.0, 0.0),
                      blurRadius: 10.0,
                      color: AppColors.black.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ).pL(3.0).pB(3.0),
            ),
          ),
        ),
      ],
    );
  }
}
