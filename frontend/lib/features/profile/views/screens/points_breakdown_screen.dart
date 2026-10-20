import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/models/xp_breakdown_models.dart';
import 'package:hazard_app/features/profile/models/xp_summary_models.dart';
import 'package:hazard_app/features/profile/providers/xp_breakdown_provider.dart';
import 'package:hazard_app/features/profile/views/screens/how_points_work_screen.dart';
import 'package:hazard_app/features/profile/views/screens/leaderboard_screen.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_badges_card.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_page_kit.dart';
import 'package:hazard_app/features/shared/enums/user_badge_enum.dart';
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
      body: Column(
        children: [
          const ProfilePageHeader(title: 'Your points'),
          Expanded(
            child: breakdown.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => ListView(
                padding: EdgeInsets.all(16.spMin),
                children: [
                  ProfileCard(
                    children: [
                      const ProfileMutedText('Could not load your points.'),
                      ProfileButton(
                        label: 'Try again',
                        kind: ProfileButtonKind.secondary,
                        onPressed: () => ref.invalidate(providerOfXpBreakdown),
                      ),
                    ],
                  ),
                ],
              ),
              data: (data) => RefreshIndicator(
                onRefresh: () async => ref.refresh(providerOfXpBreakdown.future),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16.spMin,
                    14.spMin,
                    16.spMin,
                    32.spMin,
                  ),
                  children: [
                    _headerCardBuilder(data),
                    SizedBox(height: 14.spMin),
                    _sectionTitleBuilder('Where your points came from'),
                    if (data.byType.isEmpty)
                      const ProfileCard(
                        children: [ProfileMutedText('Nothing yet.')],
                      )
                    else
                      ProfileCard(
                        children: data.byType.map(_typeRowBuilder).toList(),
                      ),
                    SizedBox(height: 14.spMin),
                    _sectionTitleBuilder('How points work'),
                    _howPointsWorkCardBuilder(),
                    SizedBox(height: 14.spMin),
                    _linksCardBuilder(context),
                    SizedBox(height: 14.spMin),
                    _sectionTitleBuilder('Your learning'),
                    if ((data.learning?.guides.isEmpty ?? true) &&
                        (data.learning?.challenges.isEmpty ?? true))
                      _emptyBuilder('Finish a guide in the Learn tab and it '
                          'appears here by name, like your reports do.')
                    else ...[
                      ...?data.learning?.guides.map(_guideRowBuilder),
                      ...?data.learning?.challenges.map(_challengeRowBuilder),
                    ],
                    SizedBox(height: 14.spMin),
                    _sectionTitleBuilder('Your reports'),
                    if (data.reports.isEmpty)
                      _emptyBuilder(
                        'No reports have earned or cost points yet.',
                      )
                    else
                      ...data.reports.map(_reportRowBuilder),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        ? '${tier.title} · top level'
        : '${tier.title} · ${next.requiredXpPoints - xp} to ${next.title}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.spMin),
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
              letterSpacing: 0.6,
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: 2.spMin),
          Text(
            '$xp',
            style: TextStyle(
              fontSize: 40.spMin,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: AppColors.white,
            ),
          ),
          Text(
            tierLine,
            style: TextStyle(
              fontSize: 13.spMin,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// The scoring rules in one plain card (rules.json points).
  Widget _howPointsWorkCardBuilder() {
    return const ProfileCard(
      children: [
        ProfileMutedText(
          'Report approved +10 · Confirmed by a neighbour +5 · Matches an '
          'official warning +15 · Guide read +10 · Report rejected -15. '
          "Confirming someone else's report earns nothing. Points reward "
          'careful, accurate reports. No streaks.',
          size: 14,
        ),
      ],
    );
  }

  /// Leaderboard and Badges (prototype), then the full explainer.
  Widget _linksCardBuilder(BuildContext context) {
    return ProfileRowGroup(
      rows: [
        ProfileListRow(
          key: const Key('points-leaderboard'),
          title: 'Leaderboard',
          subtitle: 'Ranks only. Names are never shown.',
          onTap: () => context.push(LeaderboardScreen.route),
        ),
        ProfileListRow(
          title: 'Badges',
          subtitle: 'What you have earned and what is next',
          onTap: () => showProfileSheet<void>(
            context: context,
            builder: (sheetContext) => [
              const ProfileSheetTitle(title: 'Badges'),
              const ProfileBadgesCard(),
              ProfileButton(
                label: 'Close',
                kind: ProfileButtonKind.ghost,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
        ProfileListRow(
          title: 'How points work',
          subtitle: 'The full explainer',
          onTap: () => context.push(HowPointsWorkScreen.route),
        ),
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

  Widget _sectionTitleBuilder(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.spMin, left: 4.spMin),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: _sectionLabel,
        ),
      ),
    );
  }

  /// One kind of earning: what it is, how many times, and the total.
  Widget _typeRowBuilder(final XpTypeTotal row) {
    final isNegative = row.points < 0;
    final times = row.count == 1 ? 'once' : '${row.count} times';
    return Row(
      children: [
        Expanded(
          child: Text(
            '${row.type?.label ?? 'Other'} ($times)',
            style: TextStyle(fontSize: 15.spMin, color: AppColors.ink),
          ),
        ),
        Text(
          '${isNegative ? '' : '+'}${row.points}',
          style: TextStyle(
            fontSize: 15.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ],
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
