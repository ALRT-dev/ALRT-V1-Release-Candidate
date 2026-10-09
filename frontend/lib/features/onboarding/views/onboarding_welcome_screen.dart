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
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  late AnimationController _mainController;

  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 20),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _mainController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
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
              AppColors.orange.withValues(alpha: 0.1),
              AppColors.purple.withValues(alpha: 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          // The card fills the screen when there is room and scrolls when
          // there isn't, so a short phone or a large system font pushes the
          // Get started button down rather than off the bottom edge.
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 40.0).clamp(
                      0.0,
                      double.infinity,
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _slideAnimation.value,
                          child: Opacity(
                            opacity: _fadeInAnimation.value,
                            child: _buildContent(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          20.hSizedBox,
          ProgressBar(
            currentStep: OnboardingStep.welcome.index + 1,
            totalSteps: OnboardingStep.values.length - 1,
            label:
                'Step ${OnboardingStep.welcome.index + 1} of ${OnboardingStep.values.length - 1}',
          ),
          40.hSizedBox,
          _buildLogo(),
          20.hSizedBox,
          _buildWelcomeSection(),
          40.hSizedBox,
          _buildFeaturesList(),
          50.hSizedBox,
          _buildGetStartedButton(),
        ],
      ).pad(20.0),
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
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Column(
            children: [
              Text(
                'Welcome to ALRT',
                style: TextStyle(
                  fontSize: 28.spMin,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              12.hSizedBox,
              Text(
                'Make safety awareness a daily habit. Every action you take helps protect you and your community.',
                style: TextStyle(
                  fontSize: 16.spMin,
                  color: AppColors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturesList() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Column(
            children: [
              _buildFeatureItem(
                icon: LucideIcons.mapPin,
                text: 'Real-time alerts near you',
              ),
              16.hSizedBox,
              _buildFeatureItem(
                icon: LucideIcons.users,
                text: 'Community-verified reports',
              ),
              16.hSizedBox,
              _buildFeatureItem(
                icon: LucideIcons.bell,
                text: 'Instant safety notifications',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 48.spMin,
          height: 48.spMin,
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 22.spMin,
            color: AppColors.orange,
          ),
        ),
        16.wSizedBox,
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16.spMin,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGetStartedButton() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: GradientButton(
            title: 'Get Started',
            onPressed: _onGetStarted,
          ),
        );
      },
    );
  }

  void _onGetStarted() async {
    context.push(OnboardingStep.welcome.nextStep.route);
  }
}
