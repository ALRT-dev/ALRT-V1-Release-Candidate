import 'package:flutter/gestures.dart';
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
import 'package:hazard_app/features/shared/utils/app_links.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_theme.dart';

class OnboardingLegalScreen extends ConsumerStatefulWidget {
  const OnboardingLegalScreen({super.key});

  static const route = '/onboarding/legal';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingLegalScreenState();
}

class _OnboardingLegalScreenState extends ConsumerState<OnboardingLegalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _mainController;

  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isAcknowledged = false;

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
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.spMin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    24.hSizedBox,
                    ProgressBar(
                      currentStep: OnboardingStep.legal.index + 1,
                      totalSteps: OnboardingStep.values.length - 1,
                      label:
                          'Step ${OnboardingStep.legal.index + 1} of ${OnboardingStep.values.length - 1}',
                    ),
                    32.hSizedBox,
                    _buildLockIcon(),
                    32.hSizedBox,
                    _buildTitleSection(),
                    32.hSizedBox,
                    _buildLegalPoints(),
                    32.hSizedBox,
                    _buildAcknowledgementCheckbox(),
                    32.hSizedBox,
                    _buildConfirmButton(),
                    20.hSizedBox,
                  ],
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildLockIcon() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Icon(
            Icons.lock_outline,
            size: 80.spMin,
            color: AppColors.grey,
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
                'LEGAL & PRIVACY',
                style: TextStyle(
                  fontSize: 24.spMin,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              16.hSizedBox,
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.spMin,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTheme.defaultFontFamily,
                  ),
                  children: [
                    const TextSpan(
                      text: 'By continuing, you acknowledge and agree to our ',
                    ),
                    TextSpan(
                      text: 'Terms of Use',
                      style: TextStyle(
                        color: AppColors.orange,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _openLink(AppLinks.termsOfUse),
                    ),
                    const TextSpan(text: ', '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.orange,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _openLink(AppLinks.privacyPolicy),
                    ),
                    const TextSpan(text: ', and '),
                    TextSpan(
                      text: 'Disclaimer',
                      style: TextStyle(
                        color: AppColors.orange,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _openLink(AppLinks.disclaimer),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegalPoints() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Column(
            children: [
              _buildLegalItem(
                boldText: 'Age:',
                normalText: ' 13 or older, or the minimum age required by '
                    'law where you live if that is higher. Any age with '
                    'Child mode set up by a parent or guardian',
              ),
              16.hSizedBox,
              _buildLegalItem(
                boldText: 'Independent:',
                normalText: ' Not affiliated with government agencies',
              ),
              16.hSizedBox,
              _buildLegalItem(
                boldText: 'Location:',
                normalText: ' Used only to show alerts near you. Your exact '
                    'location is never shared unless you choose to share it',
              ),
              16.hSizedBox,
              _buildLegalItem(
                boldText: 'Alerts:',
                normalText: ' Not guaranteed (network dependent)',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegalItem({
    required String boldText,
    required String normalText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8.spMin,
          height: 8.spMin,
          margin: EdgeInsets.only(top: 8.spMin, right: 12.spMin),
          decoration: BoxDecoration(
            color: AppColors.orange,
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
                TextSpan(
                  text: boldText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: normalText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcknowledgementCheckbox() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isAcknowledged = !_isAcknowledged;
              });
            },
            child: Container(
              padding: EdgeInsets.all(16.spMin),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.spMin),
                border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.spMin,
                    height: 20.spMin,
                    decoration: BoxDecoration(
                      color: _isAcknowledged
                          ? AppColors.orange
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(4.spMin),
                      border: Border.all(
                        color: _isAcknowledged
                            ? AppColors.orange
                            : AppColors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: _isAcknowledged
                        ? Icon(
                            Icons.check,
                            size: 14.spMin,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                  12.wSizedBox,
                  Expanded(
                    child: Text(
                      'I acknowledge and accept all the above terms and conditions',
                      style: TextStyle(
                        fontSize: 14.spMin,
                        color: AppColors.black,
                        height: 1.4,
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

  Widget _buildConfirmButton() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: _isAcknowledged
              ? GradientButton(
                  title: 'CONFIRM & CONTINUE',
                  onPressed: _onConfirm,
                )
              : Container(
                  width: double.infinity,
                  height: 54.spMin,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(100.spMin),
                  ),
                  child: Center(
                    child: Text(
                      'CONFIRM & CONTINUE',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _openLink(String url) {
    openLink(context: context, link: url);
  }

  void _onConfirm() async {
    final result = await ref
        .read(providerOfOnboarding.notifier)
        .acceptOnboardingTermsOfService();
    if (!mounted) return;

    result.when(
      (onboardingResponse) {
        context.push(OnboardingStep.legal.nextStep.route);
      },
      (error) {
        context.showErrorToast(
          message: error.message,
        );
      },
    );
  }
}
