import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/progress_bar.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

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
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.orange.withValues(alpha: 0.08),
              AppColors.purple.withValues(alpha: 0.06),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: _buildCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30.spMin),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 15.spMin,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20.spMin),
              child: Column(
                children: [
                  24.hSizedBox,
                  ProgressBar(
                    currentStep: _step.index + 1,
                    totalSteps: OnboardingStep.values.length - 1,
                    label:
                        'Step ${_step.index + 1} of ${OnboardingStep.values.length - 1}',
                  ),
                  32.hSizedBox,
                  _buildLogo(),
                  20.hSizedBox,
                  _buildWelcomeSection(),
                  32.hSizedBox,
                  _buildFeaturesList(),
                  40.hSizedBox,
                  GradientButton(
                    title: 'Get Started',
                    onPressed: _onGetStarted,
                  ),
                  20.hSizedBox,
                ],
              ),
            ),
          ).pad(20.0),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/logos/alrt_logo.png',
      width: 110.spMin,
      filterQuality: FilterQuality.high,
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Text(
          'Welcome to ALRT',
          style: TextStyle(
            fontSize: 26.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),
        10.hSizedBox,
        Text(
          'Make safety awareness a daily habit. Every action you take helps protect you and your community.',
          style: TextStyle(
            fontSize: 15.spMin,
            color: AppColors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.map_rounded,
          text: 'Real-time alerts near you',
        ),
        12.hSizedBox,
        _buildFeatureItem(
          icon: Icons.people_rounded,
          text: 'Community-verified reports',
        ),
        12.hSizedBox,
        _buildFeatureItem(
          icon: Icons.notifications_rounded,
          text: 'Instant safety notifications',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.spMin),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.spMin),
          ),
          child: Icon(
            icon,
            size: 22.spMin,
            color: AppColors.orange,
          ),
        ),
        14.wSizedBox,
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.spMin,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _onGetStarted() {
    context.push(_step.nextStep.route);
  }
}
