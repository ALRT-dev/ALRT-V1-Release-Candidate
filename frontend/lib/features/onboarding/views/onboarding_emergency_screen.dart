import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hazard_app/features/onboarding/views/widgets/progress_bar.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_theme.dart';

class OnboardingEmergencyScreen extends ConsumerStatefulWidget {
  const OnboardingEmergencyScreen({super.key});

  static const route = '/onboarding/emergency';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingEmergencyScreenState();
}

class _OnboardingEmergencyScreenState
    extends ConsumerState<OnboardingEmergencyScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _sirenController;
  late AnimationController _noticeController;
  late AnimationController _declineController;

  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sirenPulseAnimation;
  late Animation<double> _noticeScaleAnimation;
  late Animation<double> _noticeOpacityAnimation;
  late Animation<double> _declineSlideAnimation;
  late Animation<double> _declineOpacityAnimation;

  bool _showDeclineMessage = false;

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

    _sirenController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _noticeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _declineController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
          begin: const Offset(100, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

    _scaleAnimation =
        Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
          ),
        );

    _sirenPulseAnimation =
        Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).animate(
          CurvedAnimation(
            parent: _sirenController,
            curve: Curves.easeInOut,
          ),
        );

    _noticeScaleAnimation =
        Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _noticeController,
            curve: Curves.easeOut,
          ),
        );

    _noticeOpacityAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _noticeController,
            curve: Curves.easeOut,
          ),
        );

    _declineSlideAnimation =
        Tween<double>(
          begin: -10.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _declineController,
            curve: Curves.easeOut,
          ),
        );

    _declineOpacityAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _declineController,
            curve: Curves.easeOut,
          ),
        );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _mainController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _sirenController.repeat(reverse: true);
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _noticeController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _sirenController.dispose();
    _noticeController.dispose();
    _declineController.dispose();
    super.dispose();
  }

  void _handleDecline() {
    setState(() {
      _showDeclineMessage = true;
    });
    _declineController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.spMin),
          child: Column(
            children: [
              Row(
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
              ),
              24.hSizedBox,
              ProgressBar(
                currentStep: 6,
                totalSteps: OnboardingStep.values.length - 1,
                label: 'Step 6 of ${OnboardingStep.values.length - 1}',
              ),
              40.hSizedBox,
              _buildHeaderSection(),
              40.hSizedBox,
              _buildSafetyNotice(),
              if (_showDeclineMessage) ...[
                20.hSizedBox,
                _buildDeclineMessage(),
              ],
              40.hSizedBox,
              _buildActionButtons(),
              20.hSizedBox,
              _buildFooterLinks(),
              20.hSizedBox,
            ],
          ),
        ),
      ),
    ).pad(20.0);
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildSirenIcon(),
            );
          },
        ),
        24.hSizedBox,
        AnimatedBuilder(
          animation: _fadeInAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeInAnimation.value,
              child: Text(
                'Safety Notice',
                style: TextStyle(
                  fontSize: 28.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSirenIcon() {
    return AnimatedBuilder(
      animation: _sirenController,
      builder: (context, child) {
        return Transform.scale(
          scale: _sirenPulseAnimation.value,
          child: Container(
            padding: EdgeInsets.all(16.spMin),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withValues(alpha: 0.1),
                  AppColors.orange.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.2),
                  blurRadius: 20.spMin,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              '🚨',
              style: TextStyle(fontSize: 72.spMin),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSafetyNotice() {
    return AnimatedBuilder(
      animation: _noticeController,
      builder: (context, child) {
        return Transform.scale(
          scale: _noticeScaleAnimation.value,
          child: Opacity(
            opacity: _noticeOpacityAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withValues(alpha: 0.05),
                    AppColors.orange.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.spMin),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              padding: EdgeInsets.all(24.spMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.spMin),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8.spMin),
                        ),
                        child: Icon(
                          Icons.warning,
                          size: 20.spMin,
                          color: AppColors.white,
                        ),
                      ),
                      16.wSizedBox,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNoticeText(
                              'ALRT shares general hazard and safety information from official and community sources.',
                              false,
                            ),
                            12.hSizedBox,
                            _buildNoticeText(
                              'We are not an emergency service. In an emergency, call your local emergency number.',
                              true,
                            ),
                            12.hSizedBox,
                            _buildNoticeText(
                              'Information shown may not be verified or current—always follow official directions from emergency services and local authorities.',
                              false,
                            ),
                            12.hSizedBox,
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14.spMin,
                                  color: AppColors.black,
                                  height: 1.4,
                                  fontFamily: AppTheme.defaultFontFamily,
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'By continuing, you acknowledge that use of this app is at your own discretion and agree to our ',
                                  ),
                                  TextSpan(
                                    text: 'Terms of Use',
                                    style: TextStyle(
                                      color: AppColors.orange500,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: AppColors.orange500,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoticeText(String text, bool isEmergency) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15.spMin,
        color: isEmergency ? Colors.red.shade700 : AppColors.black,
        fontWeight: isEmergency ? FontWeight.w600 : FontWeight.normal,
        height: 1.5,
      ),
    );
  }

  Widget _buildDeclineMessage() {
    return AnimatedBuilder(
      animation: _declineController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _declineSlideAnimation.value),
          child: Opacity(
            opacity: _declineOpacityAnimation.value,
            child: Container(
              padding: EdgeInsets.all(16.spMin),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.spMin),
                border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.spMin,
                    color: AppColors.black,
                    height: 1.4,
                    fontFamily: AppTheme.defaultFontFamily,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'You must agree to the terms to use ALRT. Have questions? ',
                    ),
                    TextSpan(
                      text: 'Contact us',
                      style: TextStyle(
                        color: AppColors.orange500,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' for more information.'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Column(
            children: [
              _buildAgreeButton(),
              12.hSizedBox,
              _buildDeclineButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgreeButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF10b981), // green-500
            Color(0xFF059669), // emerald-600
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(100.spMin),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 15.spMin,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100.spMin),
          onTap: _handleAgree,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.spMin),
            child: Text(
              'I Understand & Agree',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeclineButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.lightGrey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(100.spMin),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100.spMin),
          onTap: _handleDecline,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.spMin),
            child: Text(
              'I Don\'t Agree',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Handle terms and privacy
                },
                child: Text(
                  'Read Terms & Privacy',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.spMin),
                width: 4.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  shape: BoxShape.circle,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle contact us
                },
                child: Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAgree() async {
    final result = await ref
        .read(providerOfOnboarding.notifier)
        .acceptOnboardingTermsOfService();
    if (!mounted) return;

    result.when(
      (onboardingResponse) {},
      (error) {
        context.showErrorToast(
          message: error.message,
        );
      },
    );
  }
}
