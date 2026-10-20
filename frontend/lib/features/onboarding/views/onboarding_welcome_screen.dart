import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/onboarding_page.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Onboarding step 1 (board Onb1): the promise in three plain rows, then
/// "Get started".
class OnboardingWelcomeScreen extends ConsumerStatefulWidget {
  const OnboardingWelcomeScreen({super.key});

  static const route = '/onboarding/welcome';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState
    extends ConsumerState<OnboardingWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  static const _step = OnboardingStep.welcome;

  /// "Who is ALRT for?": shapes nothing on the server yet, it only
  /// answers the board's question on this screen.
  String _who = 'Just me';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Short screens (small phones, large text sizes) shrink the logo and
    // gaps so the Get started button stays on screen.
    final compact = MediaQuery.of(context).size.height < 760;
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: OnboardingPage(
          step: _step,
          showBack: false,
          children: [
            8.hSizedBox,
            Center(
              child: Image.asset(
                'assets/logos/alrt_logo.png',
                width: (compact ? 64 : 86).spMin,
                filterQuality: FilterQuality.high,
              ),
            ),
            (compact ? 10 : 14).hSizedBox,
            Text(
              'Welcome to ALRT',
              style: TextStyle(
                fontSize: 32.spMin,
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            10.hSizedBox,
            Text(
              'Official warnings and what they mean for you, in plain words. '
              'Free, always.',
              style: TextStyle(
                fontSize: 16.spMin,
                height: 1.5,
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ).pX(16.0),
            (compact ? 16 : 26).hSizedBox,
            const _FeatureRow(
              icon: LucideIcons.bell,
              title: 'Warnings near the places you choose',
              body: 'Bushfire, flood, storm, outages, road closures',
            ),
            18.hSizedBox,
            const _FeatureRow(
              icon: LucideIcons.shieldCheck,
              title: 'What to do, from the people in charge',
              body: 'Official advice word for word, never invented',
            ),
            16.hSizedBox,
            const _FeatureRow(
              icon: LucideIcons.users,
              title: 'Know your people are okay',
              body: 'Check in with one tap. Nobody is tracked.',
            ),
            24.hSizedBox,
            Text(
              'WHO IS ALRT FOR?',
              style: TextStyle(
                fontSize: 12.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppColors.sectionLabel,
              ),
            ),
            10.hSizedBox,
            Row(
              children: [
                for (final who in const ['Just me', 'My family', 'My team']) ...[
                  if (who != 'Just me') 8.wSizedBox,
                  Expanded(child: _whoChip(who)),
                ],
              ],
            ),
            const Spacer(),
            (compact ? 16 : 32).hSizedBox,
            GradientButton(
              title: 'Get started',
              onPressed: _onGetStarted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _whoChip(final String who) {
    final on = _who == who;
    return Semantics(
      selected: on,
      button: true,
      child: GestureDetector(
        onTap: () => setState(() => _who = who),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 46.spMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.ink : AppColors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(
              color: on ? AppColors.ink : AppColors.lightGrey,
              width: on ? 2 : 1.5,
            ),
          ),
          child: Text(
            who,
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: on ? FontWeight.w700 : FontWeight.w600,
              color: on ? AppColors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  void _onGetStarted() {
    context.push(_step.nextStep.route);
  }
}

/// A 44 px white rounded square holding an orange icon, with a bold line
/// and a plain line beside it.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44.spMin,
          height: 44.spMin,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(color: AppColors.lightGrey, width: 1),
          ),
          child: Icon(icon, size: 22.spMin, color: AppColors.orange),
        ),
        14.wSizedBox,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.ink,
                ),
              ),
              3.hSizedBox,
              Text(
                body,
                style: TextStyle(
                  fontSize: 13.spMin,
                  height: 1.35,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
