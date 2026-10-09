import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/progress_bar.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_theme.dart';

class OnboardingDisclaimerScreen extends ConsumerStatefulWidget {
  const OnboardingDisclaimerScreen({super.key});

  static const route = '/onboarding/disclaimer';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingDisclaimerScreenState();
}

class _OnboardingDisclaimerScreenState
    extends ConsumerState<OnboardingDisclaimerScreen>
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
          ).pad(20.0),
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
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.spMin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              24.hSizedBox,
              ProgressBar(
                currentStep: OnboardingStep.disclaimer.index + 1,
                totalSteps: OnboardingStep.values.length - 1,
                label:
                    'Step ${OnboardingStep.disclaimer.index + 1} of ${OnboardingStep.values.length - 1}',
              ),
              40.hSizedBox,
              _buildShieldIcon(),
              32.hSizedBox,
              _buildTitleSection(),
              32.hSizedBox,
              _buildDisclaimerPoints(),
              32.hSizedBox,
              _buildAgreeButton(),
              20.hSizedBox,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 40.spMin,
            height: 40.spMin,
            decoration: BoxDecoration(
              color: AppColors.extraLightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18.spMin,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShieldIcon() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Container(
            width: 100.spMin,
            height: 100.spMin,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 60.spMin,
                    color: AppColors.red,
                  ),
                  Positioned(
                    top: 11.spMin,
                    child: Text(
                      '!',
                      style: TextStyle(
                        fontSize: 28.spMin,
                        fontWeight: FontWeight.bold,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Column(
            children: [
              Text(
                'CRITICAL: NOT AN EMERGENCY SERVICE',
                style: TextStyle(
                  fontSize: 22.spMin,
                  fontWeight: FontWeight.bold,
                  color: AppColors.red,
                ),
                textAlign: TextAlign.center,
              ),
              16.hSizedBox,
              Text(
                'Safety ALRT is an independent information tool and not an official emergency authority.',
                style: TextStyle(
                  fontSize: 16.spMin,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
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

  Widget _buildDisclaimerPoints() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Column(
            children: [
              _buildDisclaimerItem(
                normalText: 'In a life-threatening situation, ',
                boldText:
                    'always call your local emergency number immediately',
                trailingText: '.',
              ),
              20.hSizedBox,
              _buildDisclaimerItem(
                normalText: 'Information in this app may be ',
                boldText: 'delayed, unvalidated, or incomplete',
                trailingText: '.',
              ),
              20.hSizedBox,
              _buildDisclaimerItem(
                normalText: 'You must ',
                boldText:
                    'follow the instructions of official emergency services and local authorities',
                trailingText: ' regardless of what is shown in this App.',
              ),
              20.hSizedBox,
              _buildDisclaimerItem(
                boldText: 'Do not wait',
                trailingText:
                    ' for an app notification to take action to protect your life.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisclaimerItem({
    String? normalText,
    required String boldText,
    String? trailingText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8.spMin,
          height: 8.spMin,
          margin: EdgeInsets.only(top: 8.spMin, right: 12.spMin),
          decoration: BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 15.spMin,
                color: AppColors.black,
                height: 1.5,
                fontFamily: AppTheme.defaultFontFamily,
              ),
              children: [
                if (normalText != null) TextSpan(text: normalText),
                TextSpan(
                  text: boldText,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (trailingText != null) TextSpan(text: trailingText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreeButton() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: GradientButton(
            title: 'I UNDERSTAND & AGREE',
            onPressed: _onAgree,
          ),
        );
      },
    );
  }

  void _onAgree() async {
    final result = await ref
        .read(providerOfOnboarding.notifier)
        .acceptOnboardingDisclaimer();
    if (!mounted) return;

    result.when(
      (onboardingResponse) {
        context.push(OnboardingStep.disclaimer.nextStep.route);
      },
      (error) {
        context.showErrorToast(
          message: error.message,
        );
      },
    );
  }
}
