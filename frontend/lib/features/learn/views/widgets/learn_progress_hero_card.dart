import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/models/xp_summary_models.dart';
import 'package:hazard_app/features/profile/providers/xp_summary_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Dark hero card on top of the Learn tab: overall progress AND this
/// week's challenge, in one card.
///
/// These used to be two stacked cards, and testers read them as two
/// competing challenges (QA 2026-08-07): "0 of 20 guides" with an XP pill
/// looked like one target, "learn 2 guides" like another. There is one
/// story: the guides are the library, the weekly challenge is the ask.
class LearnProgressHeroCard extends ConsumerWidget {
  const LearnProgressHeroCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.totalXpEarned,
  });

  final int completedCount;
  final int totalCount;
  final int totalXpEarned;

  double get _progress =>
      totalCount == 0 ? 0 : (completedCount / totalCount).clamp(0, 1);

  String get _subtitle {
    if (totalCount == 0) {
      return 'Guides are on their way — check back soon.';
    }
    if (completedCount == 0) {
      return 'Start a guide below — each one earns XP.';
    }
    if (completedCount >= totalCount) {
      return 'All guides done — great work staying prepared.';
    }
    final remaining = totalCount - completedCount;
    return '$remaining more to go — each guide earns XP.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quest = ref.watch(providerOfXpSummary).asData?.value.weeklyQuest;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  totalCount == 0
                      ? 'Be ready before it happens'
                      : '$completedCount of $totalCount guides done',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
              8.wSizedBox,
              _xpPillBuilder(),
            ],
          ),
          6.hSizedBox,
          Text(
            _subtitle,
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
          14.hSizedBox,
          _progressBarBuilder(),
          if (quest != null) ...[
            14.hSizedBox,
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.white.withValues(alpha: 0.12),
            ),
            12.hSizedBox,
            _weeklyChallengeBuilder(quest),
          ],
        ],
      ),
    );
  }

  /// The weekly challenge strip, inside the same card so the Learn tab
  /// asks for exactly one thing.
  Widget _weeklyChallengeBuilder(final WeeklyQuest quest) {
    final done = quest.completed;
    final progress = quest.target > 0
        ? (quest.progress / quest.target).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              done ? LucideIcons.trophy : LucideIcons.target,
              size: 15.spMin,
              color: done ? const Color(0xFF1EE28C) : AppColors.orange,
            ),
            6.wSizedBox,
            Expanded(
              child: Text(
                done
                    ? 'This week\'s challenge complete'
                    : 'This week: ${quest.title.toLowerCase()}',
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
            6.wSizedBox,
            Text(
              done ? '+${quest.xpReward} XP earned' : '+${quest.xpReward} XP',
              style: TextStyle(
                fontSize: 11.5.spMin,
                fontWeight: FontWeight.w800,
                color: done ? const Color(0xFF1EE28C) : AppColors.orange,
              ),
            ),
          ],
        ),
        if (!done) ...[
          8.hSizedBox,
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.spMin,
              backgroundColor: AppColors.white.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(AppColors.orange),
            ),
          ),
          5.hSizedBox,
          Text(
            '${quest.progress} of ${quest.target} done',
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _xpPillBuilder() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.spMin,
        vertical: 6.spMin,
      ),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(100.spMin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.bookOpen,
            color: AppColors.white,
            size: 14.spMin,
          ),
          5.wSizedBox,
          Text(
            '+$totalXpEarned XP',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBarBuilder() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: 7.spMin,
          decoration: BoxDecoration(
            color: AppColors.grey.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(100.spMin),
          ),
          child: Row(
            children: [
              Container(
                width: _progress * constraints.maxWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.spMin),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.orange300,
                      AppColors.red200,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
