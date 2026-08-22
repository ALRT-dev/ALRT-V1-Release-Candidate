import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/models/xp_breakdown_models.dart';
import 'package:hazard_app/features/profile/models/xp_summary_models.dart';
import 'package:hazard_app/features/profile/providers/xp_breakdown_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Where a user's points actually came from, read straight from the XP
/// ledger via GET /api/xp/breakdown.
///
/// Everything here is a real awarded point: the by-event totals and the
/// per-report rows both come from the same ledger rows that make up the
/// number at the top, so the parts add up to the whole. The previous
/// version estimated points from views and upvotes, which have not earned
/// anything for a long time, so the screen contradicted itself.
class PointsBreakdownScreen extends ConsumerWidget {
  const PointsBreakdownScreen({super.key});

  static const route = '/points-breakdown';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(providerOfXpBreakdown);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Your points',
          style: TextStyle(fontSize: 17.spMin, fontWeight: FontWeight.w700),
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
                  color: const Color(0xFF5f5c66),
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
            padding: EdgeInsets.all(20.spMin),
            children: [
              _headerCardBuilder(data),
              SizedBox(height: 16.spMin),
              if (data.stats != null) _statsRowBuilder(data.stats!),
              SizedBox(height: 16.spMin),
              _sectionTitleBuilder('WHERE YOUR POINTS CAME FROM'),
              if (data.byType.isEmpty)
                _emptyBuilder('Nothing yet. Points arrive when a report is '
                    'approved, when people nearby confirm it, and when you '
                    'finish a safety guide.')
              else
                ...data.byType.map(_typeRowBuilder),
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

  Widget _headerCardBuilder(XpBreakdown data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(color: const Color(0xFFECECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL POINTS',
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: const Color(0xFF5f5c66),
            ),
          ),
          SizedBox(height: 6.spMin),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(LucideIcons.star, size: 26.spMin, color: const Color(0xFFE1A500)),
              SizedBox(width: 8.spMin),
              Text(
                '${data.currentXpPoints}',
                style: TextStyle(
                  fontSize: 34.spMin,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.spMin),
          if (data.totalUsers > 0)
            Text(
              'Rank #${data.rank} of ${data.totalUsers}  ·  top ${100 - data.percentile}%',
              style: TextStyle(
                fontSize: 13.spMin,
                color: const Color(0xFF5f5c66),
              ),
            ),
        ],
      ),
    );
  }

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
        style: TextStyle(fontSize: 13.spMin, color: const Color(0xFF5f5c66)),
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
          border: Border.all(color: const Color(0xFFECECEF)),
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
                color: const Color(0xFF5f5c66),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitleBuilder(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.spMin, left: 2.spMin),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.spMin,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: const Color(0xFF5f5c66),
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
        border: Border.all(color: const Color(0xFFECECEF)),
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
                    color: const Color(0xFF5f5c66),
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

  /// One completed guide, named — the same treatment a report gets.
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
        border: Border.all(color: const Color(0xFFECECEF)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.spMin, color: const Color(0xFFE1A500)),
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
                    color: const Color(0xFF5f5c66),
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
      _ => (const Color(0xFF5f5c66), 'Pending'),
    };
    final isNegative = report.points < 0;

    return Container(
      margin: EdgeInsets.only(bottom: 10.spMin),
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: const Color(0xFFECECEF)),
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
                      color: const Color(0xFF5f5c66),
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
                        : const Color(0xFF5f5c66),
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
