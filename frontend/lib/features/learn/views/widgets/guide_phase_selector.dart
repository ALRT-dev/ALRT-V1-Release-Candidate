import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/learn/enums/guide_phase_types.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Before / During / After segmented pills. The selected phase is filled
/// orange; the rest sit on a light grey track.
class GuidePhaseSelector extends StatelessWidget {
  const GuidePhaseSelector({
    super.key,
    required this.selectedPhase,
    required this.onPhaseSelected,
  });

  final GuidePhase selectedPhase;
  final void Function(GuidePhase phase) onPhaseSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.spMin),
      decoration: BoxDecoration(
        color: AppColors.extraLightGrey,
        borderRadius: BorderRadius.circular(100.spMin),
      ),
      child: Row(
        children: GuidePhase.values.map(
          (phase) {
            final isSelected = phase == selectedPhase;

            return Expanded(
              child: InkWell(
                onTap: () => onPhaseSelected(phase),
                borderRadius: BorderRadius.circular(100.spMin),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(vertical: 8.spMin),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.orange : AppColors.transparent,
                    borderRadius: BorderRadius.circular(100.spMin),
                  ),
                  child: Center(
                    child: Text(
                      phase.label,
                      style: TextStyle(
                        fontSize: 13.spMin,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
