import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/learn/providers/learn_provider.dart';
import 'package:hazard_app/features/learn/views/screens/learn_topics_screen.dart';
import 'package:hazard_app/features/notification/providers/manage_notifications_provider.dart';
import 'package:hazard_app/features/notification/views/screens/manage_notifications_screen.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/views/screens/safety_profile_screen.dart';
import 'package:hazard_app/features/ready/providers/ready_provider.dart';
import 'package:hazard_app/features/ready/views/screens/drill_list_screen.dart';
import 'package:hazard_app/features/ready/views/screens/plan_list_screen.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// One of the five readiness steps: what it is, whether it is done, and
/// where to go to do it.
class _ReadyStep {
  const _ReadyStep({
    required this.title,
    required this.body,
    required this.done,
    required this.onTap,
  });

  final String title;
  final String body;
  final bool done;
  final VoidCallback onTap;
}

/// The Ready tab, rebuilt to the approved "Ready" board (9 Oct 2026):
/// a readiness ring, the first undone step as a dark "next step" card,
/// the five steps as a list, and a 2x2 grid of everything else.
///
/// Every step is derived from real state. "Turn on alerts" reads the
/// saved push settings (any type enabled); it is never hardcoded done.
class ReadyScreen extends ConsumerStatefulWidget {
  const ReadyScreen({super.key});

  @override
  ConsumerState<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends ConsumerState<ReadyScreen> {
  static const _page = Color(0xFFF5F5F7);
  static const _muted = Color(0xFF5C5C66);
  static const _hairline = Color(0xFFE3E6EA);
  static const _ringTrack = Color(0xFFE6E6EA);
  static const _ready = Color(0xFF16A34A);
  static const _ink = Color(0xFF1C1C1E);
  static const _sectionLabel = Color(0xFFB84500);
  static const _nextStepLabel = Color(0xFFF2A67C);
  static const _brandStart = Color(0xFFFF6B00);
  static const _brandEnd = Color(0xFFFF0004);

  @override
  void initState() {
    super.initState();
    // Kick off learn data and ready summary/plan loads so the steps can
    // read guide progress, plan meeting points and drill counts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(providerOfLearn).hasData) {
        ref.read(providerOfLearn.notifier).load();
      }
      final ready = ref.read(providerOfReady.notifier);
      ready.loadSummary();
      if (!ref.read(providerOfReady).hasLoadedPlans) {
        ready.loadPlans();
      }
    });
  }

  // ---------------------------------------------------------------
  // Steps
  // ---------------------------------------------------------------

  List<_ReadyStep> _watchSteps() {
    final alertsOn = ref.watch(
      providerOfManageNotifications.select((s) {
        final p = s.pushNotificationSettings;
        return p.awsEmergency ||
            p.awsWatchAndAct ||
            p.awsAdvice ||
            p.officialNonAws ||
            p.userReported;
      }),
    );
    final homeSaved = ref.watch(
      providerOfMyLocationSubscriptions.select(
        (s) => s.locationSubscriptions.any((l) => !l.isOwnLocation),
      ),
    );
    final familyAdded = ref.watch(
      providerOfFamily.select((s) {
        final circle = s.circle;
        if (circle != null) return circle.members.length > 1;
        return s.circles.any((c) => c.memberCount > 1);
      }),
    );
    final readyState = ref.watch(providerOfReady);
    final meetingPoint = readyState.plans.any(
      (plan) => (plan.meetingPoint ?? '').trim().isNotEmpty,
    );
    final drillDone = (readyState.summary?.drillCount ?? 0) > 0 ||
        readyState.drills.isNotEmpty;

    return [
      _ReadyStep(
        title: 'Turn on alerts',
        body: 'Official warnings and community reports for where you are, '
            'the moment they are issued.',
        done: alertsOn,
        onTap: () => context.push(
          ManageNotificationsScreen.route,
          extra: const ManageNotificationsScreenArgs(initialTab: 0),
        ),
      ),
      _ReadyStep(
        title: 'Save home',
        body: 'Get alerts for home even when you are somewhere else.',
        done: homeSaved,
        onTap: () => context.push(
          ManageNotificationsScreen.route,
          extra: const ManageNotificationsScreenArgs(initialTab: 1),
        ),
      ),
      _ReadyStep(
        title: 'Add one family member',
        body: 'Check in and see each other during an emergency.',
        done: familyAdded,
        onTap: () =>
            ref.read(providerOfHomeTab.notifier).state = HomeTab.family,
      ),
      _ReadyStep(
        title: 'Pick a meeting point',
        body: 'Agree where to go if you are separated. Write it into your '
            'plan so everyone has it.',
        done: meetingPoint,
        onTap: () => context.push(PlanListScreen.route),
      ),
      _ReadyStep(
        title: 'Run a family drill',
        body: 'Practise the plan once so it is familiar when it counts.',
        done: drillDone,
        onTap: () => context.push(DrillListScreen.route),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _watchSteps();
    final done = steps.where((s) => s.done).length;
    final total = steps.length;
    final pct = (done / total * 100).round();
    final next = steps.where((s) => !s.done).firstOrNull;

    return Scaffold(
      backgroundColor: _page,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(),
          Padding(
            padding: EdgeInsets.fromLTRB(16.spMin, 16.spMin, 16.spMin, 32.spMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRingCard(done: done, total: total, pct: pct),
                if (next != null) ...[
                  SizedBox(height: 12.spMin),
                  _buildNextStepCard(next),
                ],
                SizedBox(height: 20.spMin),
                _buildSectionLabel('Your 5 steps'),
                _buildStepsCard(steps),
                SizedBox(height: 20.spMin),
                _buildSectionLabel('Everything to be ready'),
                _buildEverythingGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 16.spMin),
          child: Row(
            children: [
              Icon(LucideIcons.shield, size: 28.spMin, color: AppColors.orange),
              SizedBox(width: 10.spMin),
              Text(
                'Ready',
                style: TextStyle(
                  fontSize: 28.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Ring card
  // ---------------------------------------------------------------

  Widget _buildRingCard({
    required final int done,
    required final int total,
    required final int pct,
  }) {
    final title = pct < 40 ? 'Getting started' : 'Well on your way';
    final ringSize = 96.spMin;
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: CircularProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    strokeWidth: 8,
                    backgroundColor: _ringTrack,
                    valueColor: const AlwaysStoppedAnimation<Color>(_ready),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 26.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.spMin),
                Text(
                  '$done of $total steps done. Households with a plan act '
                  'about twice as fast in an emergency.',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    height: 1.4,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Next step card
  // ---------------------------------------------------------------

  Widget _buildNextStepCard(final _ReadyStep step) {
    return Container(
      padding: EdgeInsets.all(18.spMin),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(18.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXT STEP · 2 MIN',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: _nextStepLabel,
            ),
          ),
          SizedBox(height: 8.spMin),
          Text(
            step.title,
            style: TextStyle(
              fontSize: 20.spMin,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 6.spMin),
          Text(
            step.body,
            style: TextStyle(
              fontSize: 14.spMin,
              height: 1.4,
              color: AppColors.white.withValues(alpha: 0.72),
            ),
          ),
          SizedBox(height: 16.spMin),
          Container(
            height: 54.spMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_brandStart, _brandEnd],
              ),
              borderRadius: BorderRadius.circular(16.spMin),
            ),
            child: Text(
              'Set it now',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ).onPressed(step.onTap),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Steps list
  // ---------------------------------------------------------------

  Widget _buildStepsCard(final List<_ReadyStep> steps) {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: _hairline,
                indent: 16.spMin,
                endIndent: 16.spMin,
              ),
            _buildStepRow(steps[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildStepRow(final _ReadyStep step) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
      child: Row(
        children: [
          if (step.done)
            Icon(LucideIcons.circleCheck, size: 26.spMin, color: _ready)
          else
            Container(
              width: 26.spMin,
              height: 26.spMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _ringTrack, width: 2),
              ),
            ),
          SizedBox(width: 14.spMin),
          Expanded(
            child: Text(
              step.title,
              style: TextStyle(
                fontSize: 15.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18.spMin, color: _muted),
        ],
      ),
    ).onPressed(step.onTap);
  }

  // ---------------------------------------------------------------
  // Everything grid
  // ---------------------------------------------------------------

  Widget _buildEverythingGrid() {
    return Column(
      children: [
        Row(
          children: [
            _buildGridTile(
              icon: LucideIcons.bookOpen,
              title: 'All guides',
              subtitle: 'Short, by hazard',
              onTap: () => context.push(LearnTopicsScreen.route),
            ),
            SizedBox(width: 12.spMin),
            _buildGridTile(
              icon: LucideIcons.fileText,
              title: 'My plan',
              subtitle: 'If a warning, then we',
              onTap: () => context.push(PlanListScreen.route),
            ),
          ],
        ),
        SizedBox(height: 12.spMin),
        Row(
          children: [
            _buildGridTile(
              icon: LucideIcons.footprints,
              title: 'Family drill',
              subtitle: 'Practise together',
              onTap: () => context.push(DrillListScreen.route),
            ),
            SizedBox(width: 12.spMin),
            _buildGridTile(
              icon: LucideIcons.shield,
              title: 'Safety profile',
              subtitle: 'Stays on your phone',
              onTap: () => context.push(SafetyProfileScreen.route),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridTile({
    required final IconData icon,
    required final String title,
    required final String subtitle,
    required final VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.spMin),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22.spMin, color: AppColors.orange),
            SizedBox(height: 10.spMin),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 2.spMin),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.spMin,
                color: _muted,
              ),
            ),
          ],
        ),
      ).onPressed(onTap),
    );
  }

  // ---------------------------------------------------------------
  // Shared bits
  // ---------------------------------------------------------------

  Widget _buildSectionLabel(final String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.spMin, bottom: 8.spMin),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.spMin,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: _sectionLabel,
        ),
      ),
    );
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
}
