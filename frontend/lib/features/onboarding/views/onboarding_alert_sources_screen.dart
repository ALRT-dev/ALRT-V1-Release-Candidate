import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/enums/push_notification_preference_types.dart';
import 'package:hazard_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/progress_bar.dart';
import 'package:hazard_app/features/onboarding/views/widgets/confirmation_popup.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class AlertSourceOption {
  final PushNotificationPreference preference;
  final IconData icon;
  final String label;
  final String description;
  final Color backgroundColor;
  final Color iconColor;

  const AlertSourceOption({
    required this.preference,
    required this.icon,
    required this.label,
    required this.description,
    required this.backgroundColor,
    required this.iconColor,
  });
}

class OnboardingAlertSourcesScreen extends ConsumerStatefulWidget {
  const OnboardingAlertSourcesScreen({super.key});

  static const route = '/onboarding/alert-sources';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingAlertSourcesScreenState();
}

class _OnboardingAlertSourcesScreenState
    extends ConsumerState<OnboardingAlertSourcesScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _bellController;
  late AnimationController _selectionController;
  late List<AnimationController> _cardControllers;

  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bellPulseAnimation;
  late Animation<double> _bellRotateAnimation;

  bool _showConfirmation = false;

  final List<AlertSourceOption> _sourceOptions = const [
    AlertSourceOption(
      preference: PushNotificationPreference.official,
      icon: Icons.security,
      label: 'Official alerts',
      description: 'Verified alerts from authorities',
      backgroundColor: AppColors.blue,
      iconColor: AppColors.white,
    ),
    AlertSourceOption(
      preference: PushNotificationPreference.userReported,
      icon: Icons.group,
      label: 'User reported alerts',
      description: 'Alerts reported by the community',
      backgroundColor: AppColors.purple,
      iconColor: AppColors.white,
    ),
    AlertSourceOption(
      preference: PushNotificationPreference.all,
      icon: Icons.layers,
      label: 'Both',
      description: 'Official + user alerts',
      backgroundColor: AppColors.orange,
      iconColor: AppColors.white,
    ),
  ];

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

    _bellController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize card controllers for staggered animations
    _cardControllers = List.generate(
      _sourceOptions.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
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

    _bellPulseAnimation =
        Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).animate(
          CurvedAnimation(
            parent: _bellController,
            curve: Curves.easeInOut,
          ),
        );

    _bellRotateAnimation =
        Tween<double>(
          begin: -0.1,
          end: 0.1,
        ).animate(
          CurvedAnimation(
            parent: _bellController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _mainController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _bellController.repeat(reverse: true);
    });

    // Start card animations with stagger
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 800 + (i * 100)), () {
        _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bellController.dispose();
    _selectionController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSelectSource(final PushNotificationPreference preference) {
    ref
        .read(providerOfOnboarding.notifier)
        .updateSelectedNotificationPreference(preference);

    _selectionController.forward().then((_) {
      _selectionController.reverse();
    });
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
          child: Stack(
            children: [
              AnimatedBuilder(
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
              if (_showConfirmation) _buildConfirmationPopup(),
            ],
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
                currentStep: 5,
                totalSteps: OnboardingStep.values.length - 1,
                label: 'Step 5 of ${OnboardingStep.values.length - 1}',
              ),
              40.hSizedBox,
              _buildHeaderSection(),
              40.hSizedBox,
              _buildSourceOptions(),
              40.hSizedBox,
              _buildNextButton(),
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
              child: _buildBellIcon(),
            );
          },
        ),
        24.hSizedBox,
        AnimatedBuilder(
          animation: _fadeInAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeInAnimation.value,
              child: Column(
                children: [
                  Text(
                    'Choose your alert sources',
                    style: TextStyle(
                      fontSize: 28.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  12.hSizedBox,
                  Text(
                    'Select which types of alerts you\'d like to receive. You can change this anytime.',
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
        ),
      ],
    );
  }

  Widget _buildBellIcon() {
    return AnimatedBuilder(
      animation: _bellController,
      builder: (context, child) {
        return Transform.scale(
          scale: _bellPulseAnimation.value,
          child: Transform.rotate(
            angle: _bellRotateAnimation.value,
            child: Container(
              padding: EdgeInsets.all(16.spMin),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.orange.withValues(alpha: 0.2),
                    AppColors.purple.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.3),
                    blurRadius: 20.spMin,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                '🔔',
                style: TextStyle(fontSize: 72.spMin),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOptions() {
    return Column(
      children: _sourceOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;

        return Padding(
          padding: EdgeInsets.only(bottom: 12.spMin),
          child: _buildSourceOptionCard(option, index),
        );
      }).toList(),
    );
  }

  Widget _buildSourceOptionCard(AlertSourceOption option, int index) {
    return Consumer(
      builder: (context, ref, child) {
        final isSelected = ref.watch(
          providerOfOnboarding.select(
            (state) =>
                state.selectedNotificationPreference == option.preference,
          ),
        );

        return AnimatedBuilder(
          animation: _cardControllers[index],
          builder: (context, child) {
            final slideAnimation =
                Tween<Offset>(
                  begin: const Offset(-20, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _cardControllers[index],
                    curve: Curves.easeOut,
                  ),
                );

            final opacityAnimation =
                Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: _cardControllers[index],
                    curve: Curves.easeOut,
                  ),
                );

            return Transform.translate(
              offset: slideAnimation.value,
              child: Opacity(
                opacity: opacityAnimation.value,
                child: GestureDetector(
                  onTap: () => _handleSelectSource(option.preference),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.all(20.spMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.spMin),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.orange
                            : AppColors.lightGrey.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      color: isSelected
                          ? AppColors.orange.withValues(alpha: 0.05)
                          : AppColors.white,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.orange.withValues(alpha: 0.2),
                                blurRadius: 10.spMin,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(12.spMin),
                          decoration: BoxDecoration(
                            color: option.backgroundColor,
                            borderRadius: BorderRadius.circular(12.spMin),
                          ),
                          child: Icon(
                            option.icon,
                            size: 24.spMin,
                            color: AppColors.white,
                          ),
                        ),
                        16.wSizedBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label,
                                style: TextStyle(
                                  fontSize: 16.spMin,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                              4.hSizedBox,
                              Text(
                                option.description,
                                style: TextStyle(
                                  fontSize: 14.spMin,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '✓',
                              style: TextStyle(
                                fontSize: 24.spMin,
                                color: AppColors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNextButton() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 100),
            child: GradientButton(
              title: "Next",
              icon: Icon(
                Icons.arrow_forward,
                size: 20.spMin,
                color: AppColors.white,
              ),
              onPressed: _onNext,
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmationPopup() {
    return ConfirmationPopup(
      show: true,
      message:
          "Alert preferences saved! You're all set to receive relevant safety updates.",
      onComplete: _handleConfirmationComplete,
    );
  }

  void _handleConfirmationComplete() {
    setState(() {
      _showConfirmation = false;
    });

    // context.push(OnboardingStep.pushNotification.nextStep.route);
  }

  void _onNext() async {
    final result = await ref
        .read(providerOfOnboarding.notifier)
        .setOnboardingNotificationPreferences();
    if (!mounted) return;

    result.when(
      (onboardingResponse) {
        setState(() {
          _showConfirmation = true;
        });
      },
      (error) {
        context.showErrorToast(
          message: error.message,
        );
      },
    );
  }
}
