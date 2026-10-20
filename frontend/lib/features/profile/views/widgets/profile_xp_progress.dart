import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/enums/user_badge_enum.dart';
import 'package:hazard_app/features/profile/providers/xp_summary_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The XP bar on the Profile ("Me") screen, prototype Profile board:
/// the brand gradient fill on a grey track with a tick at Scout, the tier markers (Watcher, Scout 750,
/// Guardian 1500 from [UserBadge]) underneath, and one line saying how
/// far the next tier is ("730 XP to Scout").
///
/// Reads the fresh ledger total first (which also catches the cached
/// login copy up); the login copy only bridges the first frames. The tier
/// is derived from the same number the bar draws, never a second stored
/// copy that can lag it.
class ProfileXpProgress extends ConsumerWidget {
  const ProfileXpProgress({super.key});

  static const _track = Color(0xFFECEEF1);
  static const _tick = Color(0xFFD5D9DE);
  static const _fillStart = Color(0xFFFF6B00);
  static const _fillEnd = Color(0xFFFF0004);
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
        SizedBox(
          height: 14.spMin,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 8.spMin,
                    width: width,
                    decoration: BoxDecoration(
                      color: _track,
                      borderRadius: BorderRadius.circular(4.spMin),
                    ),
                  ),
                  Container(
                    height: 8.spMin,
                    width: width * fraction,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_fillStart, _fillEnd],
                      ),
                      borderRadius: BorderRadius.circular(4.spMin),
                    ),
                  ),
                  // Tier ticks inside the bar (Scout sits at the middle).
                  for (final badge in UserBadge.values)
                    if (badge != UserBadge.values.first &&
                        badge != UserBadge.values.last &&
                        maxXpPoints > 0)
                      Positioned(
                        left: width * badge.requiredXpPoints / maxXpPoints - 1,
                        top: 0,
                        child: Container(
                          width: 2,
                          height: 14.spMin,
                          color: _tick,
                        ),
                      ),
                ],
              );
            },
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
                  fontWeight:
                      badge == userBadge ? FontWeight.w700 : FontWeight.w400,
                  color: badge == userBadge ? AppColors.ink : _muted,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.spMin),
        Text(
          isLastBadge
              ? 'Top tier reached'
              : '${nextBadge.requiredXpPoints - xpPoints} XP to ${nextBadge.title}',
          style: TextStyle(fontSize: 12.spMin, color: _muted),
        ),
      ],
    );
  }
}
