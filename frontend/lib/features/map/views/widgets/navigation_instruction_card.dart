import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/providers/navigation_provider.dart';
import 'package:hazard_app/others/app_colors.dart';

class NavigationInstructionCard extends ConsumerWidget {
  const NavigationInstructionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(providerOfNavigation);

    if (!navigationState.isNavigating ||
        navigationState.currentInstruction == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.spMin),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _getInstructionIcon(navigationState.currentInstruction!),
              size: 24.spMin,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  navigationState.currentInstruction!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                if (navigationState.remainingDistance != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'in ${_formatDistance(navigationState.remainingDistance!)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (navigationState.estimatedArrival != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.spMin,
                vertical: 4.spMin,
              ),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                _formatTime(navigationState.estimatedArrival!),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.info,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getInstructionIcon(String instruction) {
    final lowerInstruction = instruction.toLowerCase();

    if (lowerInstruction.contains('right')) {
      if (lowerInstruction.contains('sharp')) {
        return Icons.turn_sharp_right;
      } else if (lowerInstruction.contains('slight')) {
        return Icons.turn_slight_right;
      } else {
        return Icons.turn_right;
      }
    } else if (lowerInstruction.contains('left')) {
      if (lowerInstruction.contains('sharp')) {
        return Icons.turn_sharp_left;
      } else if (lowerInstruction.contains('slight')) {
        return Icons.turn_slight_left;
      } else {
        return Icons.turn_left;
      }
    } else if (lowerInstruction.contains('straight') ||
        lowerInstruction.contains('continue')) {
      return Icons.straight;
    } else if (lowerInstruction.contains('u-turn')) {
      return Icons.u_turn_right;
    } else if (lowerInstruction.contains('destination') ||
        lowerInstruction.contains('arrived')) {
      return Icons.location_on;
    } else {
      return Icons.navigation;
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }
  }
}
