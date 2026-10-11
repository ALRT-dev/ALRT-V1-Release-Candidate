import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The onboarding step indicator from the approved boards: one 4 px
/// segment per step, radius 2, the completed and current ones filled
/// brand orange and the rest a light grey.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.label,
  });

  /// 1-based: how many segments are filled.
  final int currentStep;
  final int totalSteps;

  /// Kept for callers that still pass one; the boards show no label, so
  /// it is announced to screen readers only.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final filled = currentStep.clamp(0, totalSteps);
    return Semantics(
      label: label ?? 'Step $filled of $totalSteps',
      child: Row(
        children: [
          for (var i = 0; i < totalSteps; i++) ...[
            Expanded(
              child: Container(
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: i < filled ? AppColors.orange : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2.spMin),
                ),
              ),
            ),
            if (i < totalSteps - 1) SizedBox(width: 6.spMin),
          ],
        ],
      ),
    );
  }
}
