import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/learn/providers/learn_provider.dart';
import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/learn/views/screens/guide_detail_screen.dart';
import 'package:hazard_app/features/learn/views/screens/learn_topics_screen.dart';
import 'package:hazard_app/features/notification/providers/manage_notifications_provider.dart';
import 'package:hazard_app/features/notification/views/screens/manage_notifications_screen.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/views/screens/safety_profile_screen.dart';
import 'package:hazard_app/features/ready/providers/ready_provider.dart';
import 'package:hazard_app/features/ready/views/screens/drill_list_screen.dart';
import 'package:hazard_app/features/ready/views/screens/plan_edit_screen.dart';
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
    this.time,
  });

  final String title;
  final String body;
  final bool done;
  final VoidCallback onTap;

  /// How long it takes ("2 min"), shown on the row while it is not done.
  final String? time;
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
  static const _rowHairline = Color(0xFFECEEF1);
  static const _ringTrack = Color(0xFFE6E6EA);
  static const _ringTodo = Color(0xFFD5D9DE);
  static const _tileTint = Color(0xFFFFF4EE);
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
        onTap: _openPlan,
        time: '2 min',
      ),
      _ReadyStep(
        title: 'Run a family drill',
        body: 'Practise the plan once so it is familiar when it counts.',
        done: drillDone,
        onTap: () => context.push(DrillListScreen.route),
        time: '5 min',
      ),
    ];
  }

  /// "Set it now", "Pick a meeting point" and "My plan" all open the
  /// plan itself (board Plan): the first saved plan, or a new one.
  void _openPlan() {
    final plans = ref.read(providerOfReady).plans;
    context.push(
      plans.isEmpty
          ? PlanEditScreen.route
          : PlanEditScreen.routeWithId(plans.first.id),
    );
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
            padding: EdgeInsets.fromLTRB(16.spMin, 12.spMin, 16.spMin, 32.spMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRingCard(done: done, total: total, pct: pct),
                if (next != null) ...[
                  SizedBox(height: 14.spMin),
                  _buildNextStepCard(next),
                ],
                SizedBox(height: 14.spMin),
                _buildSectionLabel('Your 5 steps'),
                _buildStepsCard(steps, next),
                SizedBox(height: 14.spMin),
                _buildSectionLabel('Everything to be ready'),
                _buildEverythingGrid(),
                _buildGuideStrip(),
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

  /// The board's header sits on the page itself: no white bar.
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.spMin, 16.spMin, 16.spMin, 8.spMin),
        child: Row(
          children: [
            Icon(LucideIcons.shieldCheck, size: 28.spMin, color: AppColors.orange),
            SizedBox(width: 10.spMin),
            Text(
              'Ready',
              style: TextStyle(
                fontSize: 28.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: _ink,
              ),
            ),
          ],
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
      padding: EdgeInsets.all(20.spMin),
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
          SizedBox(width: 18.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.spMin,
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
      padding: EdgeInsets.fromLTRB(20.spMin, 18.spMin, 20.spMin, 18.spMin),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A30), Color(0xFF141416)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.spMin),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.time == null
                ? 'NEXT STEP'
                : 'NEXT STEP · ${step.time!.toUpperCase()}',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: _nextStepLabel,
            ),
          ),
          SizedBox(height: 12.spMin),
          Text(
            step.title,
            style: TextStyle(
              fontSize: 20.spMin,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 12.spMin),
          Text(
            step.body,
            style: TextStyle(
              fontSize: 14.spMin,
              height: 1.4,
              color: const Color(0xFFD0D0D6),
            ),
          ),
          SizedBox(height: 12.spMin),
          Container(
            height: 48.spMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_brandStart, _brandEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.spMin),
              boxShadow: [
                BoxShadow(
                  color: _brandEnd.withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              'Set it now',
              style: TextStyle(
                fontSize: 15.spMin,
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

  Widget _buildStepsCard(
    final List<_ReadyStep> steps,
    final _ReadyStep? next,
  ) {
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
                color: _rowHairline,
                indent: 16.spMin,
                endIndent: 16.spMin,
              ),
            _buildStepRow(steps[i], isNext: identical(steps[i], next)),
          ],
        ],
      ),
    );
  }

  /// Done: a filled green disc with a white tick. The next step: an
  /// orange ring and a bold title. Later steps: a grey ring, grey title.
  Widget _buildStepRow(final _ReadyStep step, {required final bool isNext}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 12.spMin),
      child: Row(
        children: [
          Container(
            width: 24.spMin,
            height: 24.spMin,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: step.done ? _ready : null,
              border: step.done
                  ? null
                  : Border.all(
                      color: isNext ? AppColors.orange : _ringTodo,
                      width: 2,
                    ),
            ),
            child: step.done
                ? Icon(LucideIcons.check, size: 14.spMin, color: AppColors.white)
                : null,
          ),
          SizedBox(width: 12.spMin),
          Expanded(
            child: Text(
              step.title,
              style: TextStyle(
                fontSize: 15.spMin,
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                color: step.done || isNext ? _ink : _muted,
              ),
            ),
          ),
          if (!step.done && step.time != null)
            Text(
              step.time!,
              style: TextStyle(fontSize: 12.spMin, color: _muted),
            ),
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
              onTap: _openPlan,
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
        padding: EdgeInsets.all(14.spMin),
        decoration: _cardDecoration(radius: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.spMin,
              height: 40.spMin,
              decoration: BoxDecoration(
                color: _tileTint,
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Icon(icon, size: 20.spMin, color: AppColors.orange),
            ),
            SizedBox(height: 6.spMin),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.spMin,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            SizedBox(height: 6.spMin),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.spMin, color: _muted),
            ),
          ],
        ),
      ).onPressed(onTap),
    );
  }

  /// The guide strip at the foot of the board: the first guide not yet
  /// read, from the Learn topics. Hidden until they load, and once every
  /// guide is done.
  Widget _buildGuideStrip() {
    final learn = ref.watch(providerOfLearn);
    GuideListItem? guide;
    String? topicName;
    for (final topic in learn.topics) {
      for (final g in topic.guides) {
        if (!g.completed) {
          guide = g;
          topicName = topic.name;
          break;
        }
      }
      if (guide != null) break;
    }
    if (guide == null) return const SizedBox.shrink();
    final picked = guide;
    return Padding(
      padding: EdgeInsets.only(top: 14.spMin),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
        decoration: _cardDecoration(radius: 16),
        child: Row(
          children: [
            Container(
              width: 44.spMin,
              height: 44.spMin,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF7E29),
              ),
              child: Icon(
                LucideIcons.bookOpen,
                size: 20.spMin,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    picked.title,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  SizedBox(height: 2.spMin),
                  Text(
                    'Start here · +${picked.xpReward} XP',
                    style: TextStyle(fontSize: 12.spMin, color: _muted),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 18.spMin, color: _muted),
          ],
        ),
      ).onPressed(
        () => context.push(
          GuideDetailScreen.route,
          extra: GuideDetailScreenArgs(
            slugOrId: picked.slug,
            topicName: topicName,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Shared bits
  // ---------------------------------------------------------------

  Widget _buildSectionLabel(final String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.spMin),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: _sectionLabel,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration({final double radius = 18}) => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius.spMin),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 3.0,
            offset: Offset(0, 1),
          ),
        ],
      );
}
