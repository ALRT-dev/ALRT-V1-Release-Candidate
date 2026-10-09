import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.label,
  });

  final int currentStep;
  final int totalSteps;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        8.hSizedBox,
        Container(
          height: 10.spMin,
          decoration: BoxDecoration(
            color: AppColors.extraLightGrey,
            borderRadius: BorderRadius.circular(100.spMin),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.spMin),
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(100.spMin),
              value: currentStep / totalSteps,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.orange500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
