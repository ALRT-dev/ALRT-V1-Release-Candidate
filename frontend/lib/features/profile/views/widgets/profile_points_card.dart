import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/providers/xp_summary_provider.dart';
import 'package:hazard_app/features/shared/enums/user_badge_enum.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Compact "ALRT points" summary shown just below the profile header,
/// before Safety. Deliberately plain rather than celebratory: a real
/// number, the real tier name, a slim bar and one line of plain-language
/// progress text - no emoji, no confetti, no invented reward copy. Reads
/// the same xpPoints/tier data as the app-bar's own progress bar
/// (ProfileXpProgress), never a second source of truth.
class ProfilePointsCard extends ConsumerWidget {
  const ProfilePointsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int xpPoints =
        ref.watch(providerOfXpSummary.select((s) => s.value?.xpPoints)) ??
        ref.watch(providerOfLoggedInUser.select((value) => value?.xpPoints)) ??
        0;

    final currentBadge = UserBadge.forXp(xpPoints);
    final nextBadge = currentBadge.nextBadge;
    final isMaxTier = currentBadge == UserBadge.values.last;
    final maxXpPoints = UserBadge.values.last.requiredXpPoints;
    final progress = (xpPoints.clamp(0, maxXpPoints)) / maxXpPoints;

    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColorLight,
            blurRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$xpPoints',
                    style: TextStyle(
                      fontSize: 24.spMin,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                      height: 1.0,
                    ),
                  ),
                  4.wSizedBox,
                  Padding(
                    padding: EdgeInsets.only(bottom: 3.spMin),
                    child: Text(
                      'points',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.spMin,
                  vertical: 5.spMin,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.spMin),
                ),
                child: Text(
                  currentBadge.title,
                  style: TextStyle(
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
            ],
          ),
          10.hSizedBox,
          ClipRRect(
            borderRadius: BorderRadius.circular(100.spMin),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 5.spMin,
              backgroundColor: AppColors.extraLightGrey,
              valueColor: AlwaysStoppedAnimation(AppColors.blue),
            ),
          ),
          6.hSizedBox,
          Text(
            isMaxTier
                ? 'Highest level reached — ${currentBadge.title}'
                : '${nextBadge.requiredXpPoints - xpPoints} points to ${nextBadge.title}',
            style: TextStyle(
              fontSize: 11.5.spMin,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
