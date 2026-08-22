import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/models/xp_summary_models.dart';
import 'package:hazard_app/features/profile/providers/xp_summary_provider.dart';
import 'package:hazard_app/features/profile/views/screens/how_points_work_screen.dart';
import 'package:hazard_app/features/profile/views/screens/points_breakdown_screen.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _green = Color(0xFF27AE60);
const _amber = Color(0xFFF2994A);
const _indigo = Color(0xFF5B5BD6);

/// Profile card for Scoring v2: trust tier, streak and the weekly quest,
/// linking to the full "How points work" transparency screen.
class ProfileTrustCard extends ConsumerWidget {
  const ProfileTrustCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(providerOfXpSummary);
    final summary = summaryAsync.value;
    if (summary == null) return const SizedBox.shrink();

    final tier = summary.trustTier;
    final quest = summary.weeklyQuest;

    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: [
          BoxShadow(color: AppColors.shadowColorLight, blurRadius: 2.0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.spMin,
                height: 42.spMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13.spMin),
                ),
                child: Icon(
                  LucideIcons.shieldCheck,
                  size: 22.spMin,
                  color: _green,
                ),
              ),
              SizedBox(width: 12.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier?.name ?? 'Newcomer',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      _tierSubtitle(tier),
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (summary.streakDays > 0) _streakChipBuilder(summary),
            ],
          ),
          if (tier?.next != null) ...[
            SizedBox(height: 12.spMin),
            _nextTierProgressBuilder(tier!),
          ],
          if (quest != null) ...[
            SizedBox(height: 14.spMin),
            _questBuilder(quest),
          ],
          SizedBox(height: 12.spMin),
          GestureDetector(
            onTap: () => context.push(HowPointsWorkScreen.route),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How points work',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w700,
                    color: _indigo,
                  ),
                ),
                SizedBox(width: 4.spMin),
                Icon(LucideIcons.chevronRight, size: 15.spMin, color: _indigo),
              ],
            ),
          ),
          SizedBox(height: 10.spMin),
          Row(
            children: [
              // Leaderboard entry removed: points are private to each
              // account — other users' names and scores are never shown.
              // The screen stays routed for a possible opt-in return.
              GestureDetector(
                onTap: () => context.push(PointsBreakdownScreen.route),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.chartColumnBig, size: 15.spMin, color: _indigo),
                    SizedBox(width: 4.spMin),
                    Text(
                      'Your points',
                      style: TextStyle(
                        fontSize: 13.spMin,
                        fontWeight: FontWeight.w700,
                        color: _indigo,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _tierSubtitle(final TrustTier? tier) {
    if (tier == null) return 'Report hazards to build trust';
    final rate = (tier.verificationRate * 100).round();
    if (tier.approvedCount == 0) {
      return 'Your first approved report starts your record';
    }
    return '${tier.approvedCount} approved · $rate% verified';
  }

  Widget _streakChipBuilder(final XpSummary summary) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.spMin, vertical: 6.spMin),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.spMin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.flame, size: 14.spMin, color: _amber),
          SizedBox(width: 4.spMin),
          Text(
            summary.streakMultiplierActive
                ? '${summary.streakDays}d · 1.2×'
                : '${summary.streakDays}d',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w800,
              color: _amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextTierProgressBuilder(final TrustTier tier) {
    final next = tier.next!;
    final progress = next.approvedNeeded > 0
        ? (tier.approvedCount / next.approvedNeeded).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${tier.approvedCount}/${next.approvedNeeded} approved reports '
          'towards ${next.name}',
          style: TextStyle(fontSize: 11.spMin, color: AppColors.grey),
        ),
        SizedBox(height: 6.spMin),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.spMin),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6.spMin,
            backgroundColor: const Color(0xFFF0F0F2),
            valueColor: const AlwaysStoppedAnimation<Color>(_green),
          ),
        ),
      ],
    );
  }

  Widget _questBuilder(final WeeklyQuest quest) {
    final progress = quest.target > 0
        ? (quest.progress / quest.target).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(12.spMin),
      decoration: BoxDecoration(
        color: _indigo.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Row(
        children: [
          Icon(
            quest.completed ? LucideIcons.trophy : LucideIcons.target,
            size: 20.spMin,
            color: _indigo,
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.completed
                      ? 'Weekly quest complete! +${quest.xpReward} XP'
                      : '${quest.title} · +${quest.xpReward} XP',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                if (!quest.completed) ...[
                  SizedBox(height: 6.spMin),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.spMin),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5.spMin,
                      backgroundColor: Colors.white,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_indigo),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.spMin),
          Text(
            '${quest.progress}/${quest.target}',
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w800,
              color: _indigo,
            ),
          ),
        ],
      ),
    );
  }
}
