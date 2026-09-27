import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/models/xp_summary_models.dart';
import 'package:hazard_app/features/profile/providers/xp_summary_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Full transparency on Scoring v2: what earns points, what never does,
/// how streaks and trust tiers work, and the user's recent ledger.
class HowPointsWorkScreen extends ConsumerWidget {
  const HowPointsWorkScreen({super.key});

  static const route = '/how-points-work';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(providerOfXpSummary).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'How points work',
          style: TextStyle(fontSize: 17.spMin, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.spMin),
        children: [
          _principleCardBuilder(),
          SizedBox(height: 16.spMin),
          _sectionTitleBuilder('EARNING POINTS'),
          _pointRowBuilder(
            icon: LucideIcons.circleCheck,
            color: const Color(0xFF27AE60),
            title: 'Report approved',
            subtitle: 'Passes review and goes live to the community.',
            points: '+10',
          ),
          _pointRowBuilder(
            icon: LucideIcons.users,
            color: const Color(0xFF5B5BD6),
            title: 'Corroborated by others',
            subtitle:
                'Someone else reports the same hazard within 1 km of yours.',
            points: '+5',
          ),
          _pointRowBuilder(
            icon: LucideIcons.badgeCheck,
            color: const Color(0xFF2D9CDB),
            title: 'Official match',
            subtitle:
                'An official source later confirms what you reported nearby.',
            points: '+15',
          ),
          _pointRowBuilder(
            icon: LucideIcons.bookOpen,
            color: const Color(0xFFF2994A),
            title: 'Safety guide completed',
            subtitle: 'Finish any guide in the Learn hub.',
            points: '+10',
          ),
          _pointRowBuilder(
            icon: LucideIcons.trophy,
            color: const Color(0xFFF2C94C),
            title: 'Weekly quest',
            subtitle: 'Complete 2 guides in a week.',
            points: '+20',
          ),
          _pointRowBuilder(
            icon: LucideIcons.sparkles,
            color: const Color(0xFF27AE60),
            title: 'Getting set up',
            subtitle:
                'One-off welcomes: finish onboarding +20, complete your '
                'profile +10, post your first ALRT +10, join a family '
                'group +10.',
            points: '+50',
          ),
          _pointRowBuilder(
            icon: LucideIcons.mapPin,
            color: const Color(0xFF2D9CDB),
            title: 'Saved place added',
            subtitle: 'Each place your family watches over.',
            points: '+5',
          ),
          _pointRowBuilder(
            icon: LucideIcons.circleX,
            color: const Color(0xFFD7263D),
            title: 'Report rejected',
            subtitle: 'Fails review. Your total never drops below zero.',
            points: '−15',
          ),
          SizedBox(height: 16.spMin),
          _sectionTitleBuilder('STREAKS'),
          _plainCardBuilder(
            icon: LucideIcons.flame,
            color: const Color(0xFFF2994A),
            text:
                'An approved report, a family check-in or a finished guide '
                'keeps your daily streak alive. From day 3, approved reports '
                'earn a 1.2× bonus.',
          ),
          SizedBox(height: 16.spMin),
          _sectionTitleBuilder('TRUST TIERS'),
          _plainCardBuilder(
            icon: LucideIcons.shieldCheck,
            color: const Color(0xFF27AE60),
            text:
                'Newcomer → Verified Reporter (5 approved, 60% verified) → '
                'Trusted Reporter (20 approved, 80% verified). Higher tiers '
                'signal your reports can be trusted at a glance.',
          ),
          SizedBox(height: 16.spMin),
          _sectionTitleBuilder('NEVER FOR POINTS'),
          _plainCardBuilder(
            icon: LucideIcons.heartHandshake,
            color: const Color(0xFF5B5BD6),
            text:
                'SOS, family check-ins and hazard-proximity alerts never earn '
                'points. Nobody should feel a nudge to game a safety feature.',
          ),
          if (summary != null && summary.recentEvents.isNotEmpty) ...[
            SizedBox(height: 16.spMin),
            _sectionTitleBuilder('YOUR RECENT ACTIVITY'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.spMin),
              ),
              child: Column(
                children: [
                  for (final (index, event)
                      in summary.recentEvents.indexed) ...[
                    if (index > 0)
                      const Divider(height: 1, color: Color(0xFFF0F0F2)),
                    _ledgerRowBuilder(event),
                  ],
                ],
              ),
            ),
          ],
          SizedBox(height: 40.spMin),
        ],
      ),
    );
  }

  Widget _principleCardBuilder() {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(18.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Points reward verified safety value',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.spMin,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.spMin),
          Text(
            'Every point you earn (or lose) is recorded and visible here. '
            'Points come from reports the community can rely on — not from '
            'volume, and never from emergencies.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13.spMin,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitleBuilder(final String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.spMin),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.grey,
        ),
      ),
    );
  }

  Widget _pointRowBuilder({
    required final IconData icon,
    required final Color color,
    required final String title,
    required final String subtitle,
    required final String points,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.spMin),
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Row(
        children: [
          Container(
            width: 38.spMin,
            height: 38.spMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.spMin),
            ),
            child: Icon(icon, size: 19.spMin, color: color),
          ),
          SizedBox(width: 12.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.spMin,
                    color: AppColors.grey,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.spMin),
          Text(
            points,
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w800,
              color: points.startsWith('−')
                  ? const Color(0xFFD7263D)
                  : const Color(0xFF27AE60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainCardBuilder({
    required final IconData icon,
    required final Color color,
    required final String text,
  }) {
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.spMin, color: color),
          SizedBox(width: 12.spMin),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.spMin,
                color: AppColors.black,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ledgerRowBuilder(final XpLedgerEvent event) {
    final isPositive = event.points >= 0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.type?.label ?? 'XP change',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                if (event.createdAt != null)
                  Text(
                    timeago.format(event.createdAt!),
                    style: TextStyle(fontSize: 11.spMin, color: AppColors.grey),
                  ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${event.points} XP',
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w800,
              color: isPositive
                  ? const Color(0xFF27AE60)
                  : const Color(0xFFD7263D),
            ),
          ),
        ],
      ),
    );
  }
}
