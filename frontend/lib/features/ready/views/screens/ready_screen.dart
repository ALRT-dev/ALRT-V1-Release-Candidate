import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/learn/providers/learn_provider.dart';
import 'package:hazard_app/features/notification/views/screens/manage_notifications_screen.dart';
import 'package:hazard_app/features/learn/views/screens/learn_topics_screen.dart';
import 'package:hazard_app/features/profile/providers/safety_profile_provider.dart';
import 'package:hazard_app/features/profile/views/screens/safety_profile_screen.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The Ready tab: readiness score and five preparation steps.
///
/// The score is client-side only, computed from how many of the five steps
/// the user has completed or started. Plan and Drill are Layer 3 features
/// with no backend yet, so they show as available but navigate to an
/// in-screen placeholder.
class ReadyScreen extends ConsumerStatefulWidget {
  const ReadyScreen({super.key});

  @override
  ConsumerState<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends ConsumerState<ReadyScreen> {
  static const _ink = Color(0xFF232326);
  static const _inkSoft = Color(0xFF75757E);
  static const _sectionLabel = Color(0xFFB84500);

  @override
  void initState() {
    super.initState();
    // Kick off learn data load if it hasn't been loaded yet, so we can
    // show guide completion progress.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(providerOfLearn).hasData) {
        ref.read(providerOfLearn.notifier).load();
      }
    });
  }

  // ---------------------------------------------------------------
  // Readiness scoring
  // ---------------------------------------------------------------

  /// Returns 0..5 completed steps count based on available state.
  int _completedSteps(WidgetRef ref) {
    var count = 0;

    // 1. Safety Profile -- completed if at least one cohort is ticked.
    final cohorts = ref.watch(providerOfSafetyProfile);
    if (cohorts.isNotEmpty) count++;

    // 2. Learn -- completed if user has finished at least one guide.
    final learnState = ref.watch(providerOfLearn);
    if (learnState.hasData && learnState.completedCount > 0) count++;

    // 3. Alerts -- always count as started since the user chose an
    //    alert level during onboarding. A more refined check would read
    //    the notification settings, but that requires an async load;
    //    for now completing onboarding counts.
    count++;

    // 4. Plan -- Layer 3, not completable yet.
    // 5. Drill -- Layer 3, not completable yet.

    return count;
  }

  @override
  Widget build(BuildContext context) {
    final completed = _completedSteps(ref);
    const total = 5;
    final pct = (completed / total * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(18.spMin, 14.spMin, 18.spMin, 28.spMin),
          children: [
            _buildScoreHero(completed, total, pct),
            16.hSizedBox,
            Row(
              children: [
                Text(
                  'YOUR PREPARATION STEPS',
                  style: TextStyle(
                    fontSize: 10.5.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: _sectionLabel,
                  ),
                ),
                const Spacer(),
                Text(
                  '$completed of $total',
                  style: TextStyle(
                    fontSize: 10.5.spMin,
                    fontWeight: FontWeight.w800,
                    color: _sectionLabel,
                  ),
                ),
              ],
            ),
            12.hSizedBox,
            _buildStepCard(
              icon: Icons.shield_rounded,
              title: 'Safety Profile',
              subtitle: 'Tell us who you are preparing for',
              completed: ref.watch(providerOfSafetyProfile).isNotEmpty,
              onTap: () => context.push(SafetyProfileScreen.route),
            ),
            10.hSizedBox,
            _buildLearnCard(),
            10.hSizedBox,
            _buildStepCard(
              icon: Icons.description_rounded,
              title: 'Plan',
              subtitle: 'Create a household emergency plan',
              completed: false,
              isLayer3: true,
              onTap: () => _showComingSoon(context, 'Plan'),
            ),
            10.hSizedBox,
            _buildStepCard(
              icon: Icons.directions_run_rounded,
              title: 'Drill',
              subtitle: 'Practice with your household',
              completed: false,
              isLayer3: true,
              onTap: () => _showComingSoon(context, 'Drill'),
            ),
            10.hSizedBox,
            _buildStepCard(
              icon: Icons.notifications_rounded,
              title: 'Alerts',
              subtitle: 'Configure how alerts reach you',
              completed: true, // set during onboarding
              onTap: () => context.push(ManageNotificationsScreen.route),
            ),
            20.hSizedBox,
            Text(
              'Completing each step helps you and the people you care for '
              'be better prepared when it counts.',
              style: TextStyle(
                fontSize: 12.spMin,
                height: 1.55,
                color: _inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Hero card with score
  // ---------------------------------------------------------------

  Widget _buildScoreHero(int completed, int total, int pct) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.spMin),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF23252B), Color(0xFF121216)],
        ),
        borderRadius: BorderRadius.circular(18.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circular progress indicator
              SizedBox(
                width: 56.spMin,
                height: 56.spMin,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56.spMin,
                      height: 56.spMin,
                      child: CircularProgressIndicator(
                        value: completed / total,
                        strokeWidth: 5.spMin,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.orange,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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
                      'Your readiness',
                      style: TextStyle(
                        fontSize: 22.spMin,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 4.spMin),
                    Text(
                      completed == total
                          ? 'All steps completed'
                          : '$completed of $total steps completed',
                      style: TextStyle(
                        fontSize: 13.spMin,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.4,
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

  // ---------------------------------------------------------------
  // Step cards
  // ---------------------------------------------------------------

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool completed,
    required VoidCallback onTap,
    bool isLayer3 = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(
            color: completed
                ? AppColors.green.withValues(alpha: 0.3)
                : const Color(0xFFE3E1E8),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.spMin,
              height: 42.spMin,
              decoration: BoxDecoration(
                color: completed
                    ? AppColors.green.withValues(alpha: 0.1)
                    : AppColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Icon(
                icon,
                size: 22.spMin,
                color: completed ? AppColors.green : AppColors.orange,
              ),
            ),
            SizedBox(width: 14.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.spMin,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                      ),
                      if (isLayer3) ...[
                        SizedBox(width: 8.spMin),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.spMin,
                            vertical: 2.spMin,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.spMin),
                          ),
                          child: Text(
                            'Soon',
                            style: TextStyle(
                              fontSize: 10.spMin,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3.spMin),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.spMin,
                      color: _inkSoft,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.spMin),
            if (completed)
              Icon(
                Icons.check_circle,
                size: 22.spMin,
                color: AppColors.green,
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 22.spMin,
                color: _inkSoft,
              ),
          ],
        ),
      ),
    );
  }

  /// Learn card reads live guide-completion data from the provider.
  Widget _buildLearnCard() {
    return Consumer(
      builder: (context, ref, child) {
        final learnState = ref.watch(providerOfLearn);
        final hasCompleted =
            learnState.hasData && learnState.completedCount > 0;
        final String subtitle;

        if (learnState.hasData && learnState.completedCount > 0) {
          subtitle =
              '${learnState.completedCount} of ${learnState.totalCount} guides completed';
        } else {
          subtitle = 'Learn what to do in an emergency';
        }

        return _buildStepCard(
          icon: Icons.menu_book_rounded,
          title: 'Learn',
          subtitle: subtitle,
          completed: hasCompleted,
          onTap: () => context.push(LearnTopicsScreen.route),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // Layer 3 placeholder
  // ---------------------------------------------------------------

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming in a future update'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
