import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/enums/user_badge_enum.dart';
import 'package:hazard_app/features/profile/providers/xp_summary_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The XP bar on the Profile ("Me") screen, approved board 9 Oct 2026:
/// an orange fill on a grey track, the tier markers (Watcher, Scout 750,
/// Guardian 1500 from [UserBadge]) underneath, and one line saying how
/// far the next tier is ("730 XP to Scout").
///
/// Reads the fresh ledger total first (which also catches the cached
/// login copy up); the login copy only bridges the first frames. The tier
/// is derived from the same number the bar draws, never a second stored
/// copy that can lag it.
class ProfileXpProgress extends ConsumerWidget {
  const ProfileXpProgress({super.key});

  static const _track = Color(0xFFE6E6EA);
  static const _muted = Color(0xFF5C5C66);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int xpPoints = ref.watch(
          providerOfXpSummary.select((s) => s.value?.xpPoints),
        ) ??
        ref.watch(
          providerOfLoggedInUser.select((value) => value?.xpPoints),
        ) ??
        0;
    final userBadge = UserBadge.forXp(xpPoints);
    final nextBadge = userBadge.nextBadge;
    final isLastBadge = userBadge == UserBadge.values.last;
    final maxXpPoints = UserBadge.values.last.requiredXpPoints;
    final fraction =
        maxXpPoints <= 0 ? 0.0 : (xpPoints / maxXpPoints).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100.spMin),
          child: SizedBox(
            height: 8.spMin,
            width: double.infinity,
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: _track,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
            ),
          ),
        ),
        SizedBox(height: 8.spMin),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final badge in UserBadge.values)
              Text(
                badge == UserBadge.values.first
                    ? badge.title
                    : '${badge.title} ${badge.requiredXpPoints}',
                style: TextStyle(
                  fontSize: 11.spMin,
                  fontWeight: FontWeight.w600,
                  color: userBadge.index >= badge.index
                      ? AppColors.orange
                      : _muted,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.spMin),
        Text(
          isLastBadge
              ? 'Top tier reached'
              : '${nextBadge.requiredXpPoints - xpPoints} XP to ${nextBadge.title}',
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w600,
            color: _muted,
          ),
        ),
      ],
    );
  }
}
