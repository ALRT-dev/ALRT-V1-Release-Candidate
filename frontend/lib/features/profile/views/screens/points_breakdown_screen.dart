import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/models/xp_breakdown_models.dart';
import 'package:hazard_app/features/profile/models/xp_summary_models.dart';
import 'package:hazard_app/features/profile/providers/xp_breakdown_provider.dart';
import 'package:hazard_app/features/profile/views/screens/how_points_work_screen.dart';
import 'package:hazard_app/features/profile/views/screens/leaderboard_screen.dart';
import 'package:hazard_app/features/shared/enums/user_badge_enum.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Where a user's points actually came from, read straight from the XP
/// ledger via GET /api/xp/breakdown.
///
/// Everything here is a real awarded point: the by-event totals and the
/// per-report rows both come from the same ledger rows that make up the
/// number at the top, so the parts add up to the whole. The previous
/// version estimated points from views and upvotes, which have not earned
/// anything for a long time, so the screen contradicted itself.
///
/// Approved board 9 Oct 2026: total on the brand gradient with the tier
/// line, the ledger sources, a plain "How points work" card, and rows to
/// the leaderboard and the full explainer.
class PointsBreakdownScreen extends ConsumerWidget {
  const PointsBreakdownScreen({super.key});

  static const route = '/points-breakdown';

  static const _page = Color(0xFFF5F5F7);
  static const _muted = Color(0xFF5C5C66);
  static const _hairline = Color(0xFFE3E6EA);
  static const _sectionLabel = Color(0xFFB84500);
  static const _brandStart = Color(0xFFFF6B00);
  static const _brandEnd = Color(0xFFFF0004);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(providerOfXpBreakdown);

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.black),
        ),
        title: Text(
          'Your points',
          style: TextStyle(
            fontSize: 22.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ),
      body: breakdown.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load your points.',
                style: TextStyle(
                  fontSize: 15.spMin,
                  color: _muted,
                ),
              ),
              SizedBox(height: 12.spMin),
              TextButton(
                onPressed: () => ref.refresh(providerOfXpBreakdown),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.refresh(providerOfXpBreakdown.future),
          child: ListView(
            padding: EdgeInsets.all(16.spMin),
            children: [
              _headerCardBuilder(data),
              SizedBox(height: 16.spMin),
              if (data.stats != null) ...[
                _statsRowBuilder(data.stats!),
                SizedBox(height: 16.spMin),
              ],
              _sectionTitleBuilder('WHERE YOUR POINTS CAME FROM'),
              if (data.byType.isEmpty)
                _emptyBuilder('Nothing yet. Points arrive when a report is '
                    'approved, when people nearby confirm it, and when you '
                    'finish a safety guide.')
              else
                ...data.byType.map(_typeRowBuilder),
              SizedBox(height: 16.spMin),
              _sectionTitleBuilder('HOW POINTS WORK'),
              _howPointsWorkCardBuilder(),
              SizedBox(height: 16.spMin),
              _linksCardBuilder(context),
              SizedBox(height: 16.spMin),
              _sectionTitleBuilder('YOUR LEARNING'),
              if ((data.learning?.guides.isEmpty ?? true) &&
                  (data.learning?.challenges.isEmpty ?? true))
                _emptyBuilder('Finish a guide in the Learn tab and it '
                    'appears here by name, like your reports do.')
              else ...[
                ...?data.learning?.guides.map(_guideRowBuilder),
                ...?data.learning?.challenges.map(_challengeRowBuilder),
              ],
              SizedBox(height: 16.spMin),
              _sectionTitleBuilder('YOUR REPORTS'),
              if (data.reports.isEmpty)
                _emptyBuilder('No reports have earned or cost points yet.')
              else
                ...data.reports.map(_reportRowBuilder),
            ],
          ),
        ),
      ),
    );
  }

  /// Total on the brand gradient, with the tier line derived from the same
  /// number ("Watcher · 730 to Scout"). Tiers come from [UserBadge].
  Widget _headerCardBuilder(XpBreakdown data) {
    final xp = data.currentXpPoints;
    final tier = UserBadge.forXp(xp);
    final next = tier.nextBadge;
    final isTop = tier == UserBadge.values.last;
    final tierLine = isTop
        ? '${tier.title} · top tier'
        : '${tier.title} · ${next.requiredXpPoints - xp} to ${next.title}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.spMin),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_brandStart, _brandEnd],
        ),
        borderRadius: BorderRadius.circular(18.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL POINTS',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 6.spMin),
          Text(
            '$xp',
            style: TextStyle(
              fontSize: 36.spMin,
              fontWeight: FontWeight.w700,
              height: 1.0,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 8.spMin),
          Text(
            tierLine,
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }

  /// The scoring rules in one plain card (Points and Badge Logic v1.1).
  Widget _howPointsWorkCardBuilder() {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report approved +10 · Confirmed by a neighbour +5 · Matches an '
            'official warning +15 · Guide read +10 · Report rejected -15.',
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w600,
              height: 1.45,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.spMin),
          Text(
            'Confirming someone else\'s report earns nothing. Points reward '
            'careful, accurate reports. No streaks.',
            style: TextStyle(
              fontSize: 13.spMin,
              height: 1.4,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _linksCardBuilder(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _linkRowBuilder(
            icon: LucideIcons.trophy,
            title: 'Leaderboard',
            subtitle: 'Ranks only. Names are never shown.',
            onTap: () => context.push(LeaderboardScreen.route),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: _hairline,
            indent: 16.spMin,
            endIndent: 16.spMin,
          ),
          _linkRowBuilder(
            icon: LucideIcons.info,
            title: 'How points work',
            subtitle: 'The full explainer',
            onTap: () => context.push(HowPointsWorkScreen.route),
          ),
        ],
      ),
    );
  }

  Widget _linkRowBuilder({
    required final IconData icon,
    required final String title,
    required final String subtitle,
    required final VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
      child: Row(
        children: [
          Icon(icon, size: 22.spMin, color: AppColors.black),
          SizedBox(width: 14.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.spMin, color: _muted),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.spMin),
          Icon(LucideIcons.chevronRight, size: 18.spMin, color: _muted),
        ],
      ),
    ).onPressed(onTap);
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 3.0,
            offset: Offset(0, 1),
          ),
        ],
      );

  Widget _statsRowBuilder(XpBreakdownStats stats) {
    // Views and votes used to sit here as if they earned something. They
    // never did; what counts is approval and other people confirming.
    return Row(
      children: [
        _statTileBuilder('${stats.totalHazardsReported}', 'Reports'),
        SizedBox(width: 10.spMin),
        _statTileBuilder('${stats.approvedReports}', 'Approved'),
        SizedBox(width: 10.spMin),
        _statTileBuilder('${stats.corroborationsReceived}', 'Confirmed by'),
      ],
    );
  }

  Widget _emptyBuilder(final String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.spMin),
      child: Text(
        message,
        style: TextStyle(fontSize: 13.spMin, color: _muted),
      ),
    );
  }

  Widget _statTileBuilder(String value, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(color: _hairline),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18.spMin,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2.spMin),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.spMin,
                color: _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitleBuilder(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.spMin, left: 4.spMin),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.spMin,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: _sectionLabel,
        ),
      ),
    );
  }

  /// One kind of earning: what it is, how many times, and the total.
  Widget _typeRowBuilder(final XpTypeTotal row) {
    final isNegative = row.points < 0;
    return Container(
      margin: EdgeInsets.only(bottom: 8.spMin),
      padding: EdgeInsets.symmetric(
        horizontal: 14.spMin,
        vertical: 12.spMin,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: _hairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.type?.label ?? 'Other',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  row.count == 1 ? 'once' : '${row.count} times',
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isNegative ? '' : '+'}${row.points}',
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w800,
              color: isNegative
                  ? const Color(0xFFCC1010)
                  : const Color(0xFF27AE60),
            ),
          ),
        ],
      ),
    );
  }

  /// One completed guide, named: the same treatment a report gets.
  Widget _guideRowBuilder(final XpGuideCompletion guide) {
    return _learningRowBuilder(
      icon: LucideIcons.bookOpen,
      title: guide.title,
      subtitle: 'Safety guide completed',
      points: guide.points,
    );
  }

  Widget _challengeRowBuilder(final XpChallengeCompletion challenge) {
    return _learningRowBuilder(
      icon: LucideIcons.trophy,
      title: 'Weekly challenge',
      subtitle: 'Completed the guides for the week',
      points: challenge.points,
    );
  }

  Widget _learningRowBuilder({
    required final IconData icon,
    required final String title,
    required final String subtitle,
    required final int points,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.spMin),
      padding: EdgeInsets.symmetric(
        horizontal: 14.spMin,
        vertical: 12.spMin,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: _hairline),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.spMin, color: AppColors.black),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+$points',
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF27AE60),
            ),
          ),
        ],
      ),
    );
  }

  /// One report, with the ledger events that make up its total, so a
  /// number can always be traced to the thing that caused it.
  Widget _reportRowBuilder(final XpReportBreakdown report) {
    final (statusColor, statusLabel) = switch (report.reviewStatus) {
      'accepted' => (const Color(0xFF27AE60), 'Approved'),
      'rejected' => (const Color(0xFFCC1010), 'Rejected'),
      _ => (_muted, 'Pending'),
    };
    final isNegative = report.points < 0;

    return Container(
      margin: EdgeInsets.only(bottom: 10.spMin),
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: _hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.title.isEmpty ? 'Untitled report' : report.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8.spMin),
              Text(
                '${isNegative ? '' : '+'}${report.points}',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w800,
                  color: isNegative
                      ? const Color(0xFFCC1010)
                      : const Color(0xFF27AE60),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.spMin),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.spMin,
                  vertical: 3.spMin,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.spMin),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11.spMin,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          for (final event in report.events) ...[
            SizedBox(height: 6.spMin),
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.type?.label ?? 'Adjustment',
                    style: TextStyle(
                      fontSize: 11.5.spMin,
                      color: _muted,
                    ),
                  ),
                ),
                Text(
                  '${event.points < 0 ? '' : '+'}${event.points}',
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    fontWeight: FontWeight.w700,
                    color: event.points < 0
                        ? const Color(0xFFCC1010)
                        : _muted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
