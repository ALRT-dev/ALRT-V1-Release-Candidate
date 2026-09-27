import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'package:hazard_app/others/app_wrapper.dart';

class OnboardingCompleteScreen extends ConsumerStatefulWidget {
  const OnboardingCompleteScreen({super.key});

  static const route = '/onboarding/complete';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState
    extends ConsumerState<OnboardingCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _checkController;
  late AnimationController _pulseController;
  late AnimationController _badgeController;
  late List<AnimationController> _cardControllers;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _checkRotateAnimation;
  late Animation<double> _pulseOpacityAnimation;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _badgeRotateAnimation;
  late Animation<double> _badgeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _checkController.dispose();
    _pulseController.dispose();
    _badgeController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.spMin),
              ),
              child: SafeArea(
                // Two stacked cards plus 110px of fixed spacers overflow a
                // short screen, so the page scrolls once it stops fitting
                // and keeps its spaced-out layout when it still does.
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(child: _buildContent()),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            60.hSizedBox,
            _buildSuccessIcon(),
            50.hSizedBox,
            _buildHeader(),
          ],
        ),
        Column(
          children: [
            _buildBadgeEarnedCard(),
            16.hSizedBox,
            _buildNextMilestoneCard(),
          ],
        ),
        _buildActionButtons().pB(20.0),
      ],
    ).pX(20.0);
  }

  Widget _buildSuccessIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse rings
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseScaleAnimation.value,
              child: Opacity(
                opacity: _pulseOpacityAnimation.value,
                child: Container(
                  width: 96.spMin,
                  height: 96.spMin,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.green,
                      width: 4,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Main check circle
        AnimatedBuilder(
          animation: _checkController,
          builder: (context, child) {
            return Transform.scale(
              scale: _checkScaleAnimation.value,
              child: Transform.rotate(
                angle: _checkRotateAnimation.value,
                child: Container(
                  width: 96.spMin,
                  height: 96.spMin,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.white.withValues(alpha: 0.4),
                        blurRadius: 20.spMin,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _checkController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _checkScaleAnimation.value,
                        child: Icon(
                          Icons.check_rounded,
                          size: 56.spMin,
                          color: AppColors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, opacity, child) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween<double>(begin: 10, end: 0),
          builder: (context, offset, child) {
            return Transform.translate(
              offset: Offset(0, offset),
              child: Opacity(
                opacity: opacity,
                child: Column(
                  children: [
                    Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontSize: 32.spMin,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    8.hSizedBox,
                    Text(
                      'Set up complete.',
                      style: TextStyle(
                        fontSize: 18.spMin,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBadgeEarnedCard() {
    return AnimatedBuilder(
      animation: _cardControllers[0],
      builder: (context, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0, 20),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _cardControllers[0],
                curve: Curves.easeOut,
              ),
            );

        final opacityAnimation =
            Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: _cardControllers[0],
                curve: Curves.easeOut,
              ),
            );

        return Transform.translate(
          offset: slideAnimation.value,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.spMin),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 235, 226),
                borderRadius: BorderRadius.circular(20.spMin),
                border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _badgeController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _badgeRotateAnimation.value,
                            child: Transform.scale(
                              scale: _badgeScaleAnimation.value,
                              child: Center(
                                child: Stack(
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      size: 60.spMin,
                                      color: AppColors.orange,
                                    ),
                                    Positioned.fill(
                                      child: Center(
                                        child: Icon(
                                          Icons.star,
                                          size: 24.spMin,
                                          color: AppColors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      16.wSizedBox,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '+20 points',
                              style: TextStyle(
                                fontSize: 22.spMin,
                                fontWeight: FontWeight.w700,
                                color: AppColors.orange,
                              ),
                            ),
                            4.hSizedBox,
                            Text(
                              'Your first 20 points are on the board.',
                              style: TextStyle(
                                fontSize: 16.spMin,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  16.hSizedBox,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.spMin),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2EC),
                      borderRadius: BorderRadius.circular(12.spMin),
                      border: Border.all(
                        color: AppColors.orange.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'Start exploring alerts in your area and contribute to your community\'s safety. Every report you share helps keep others informed and protected.',
                      style: TextStyle(
                        fontSize: 14.spMin,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildNextMilestoneCard() {
    return AnimatedBuilder(
      animation: _cardControllers[1],
      builder: (context, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0, 20),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _cardControllers[1],
                curve: Curves.easeOut,
              ),
            );

        final opacityAnimation =
            Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: _cardControllers[1],
                curve: Curves.easeOut,
              ),
            );

        return Transform.translate(
          offset: slideAnimation.value,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.spMin),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.spMin),
                border: Border.all(
                  color: AppColors.blue.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.spMin,
                    height: 44.spMin,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
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
                          'Next Milestone:',
                          style: TextStyle(
                            fontSize: 14.spMin,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blue,
                          ),
                        ),
                        4.hSizedBox,
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.spMin,
                              color: AppColors.blue,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppTheme.defaultFontFamily,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Post your first alert to earn ',
                              ),
                              TextSpan(
                                text: '+10 points!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildActionButtons() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, opacity, child) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween<double>(begin: 10, end: 0),
          builder: (context, offset, child) {
            return Transform.translate(
              offset: Offset(0, offset),
              child: Opacity(
                opacity: opacity,
                child: Column(
                  children: [
                    GradientButton(
                      title: 'Start Using ALRT',
                      onPressed: _gotoMapScreen,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize card controllers for staggered animations
    _cardControllers = List.generate(
      2,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _scaleAnimation =
        Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: Curves.easeOut,
          ),
        );

    _checkScaleAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _checkController,
            curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
          ),
        );

    _checkRotateAnimation =
        Tween<double>(
          begin: -math.pi,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _checkController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          ),
        );

    _pulseScaleAnimation =
        Tween<double>(
          begin: 1.0,
          end: 1.8,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: Curves.easeOut,
          ),
        );

    _pulseOpacityAnimation =
        Tween<double>(
          begin: 0.5,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: Curves.easeOut,
          ),
        );

    _badgeRotateAnimation =
        Tween<double>(
          begin: 0.0,
          end: 0.1,
        ).animate(
          CurvedAnimation(
            parent: _badgeController,
            curve: Curves.easeInOut,
          ),
        );

    _badgeScaleAnimation =
        Tween<double>(
          begin: 1.0,
          end: 1.1,
        ).animate(
          CurvedAnimation(
            parent: _badgeController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _startAnimations() {
    _mainController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _checkController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _pulseController.repeat();
    });

    // Start card animations with stagger
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 1000 + (i * 150)), () {
        _cardControllers[i].forward();
      });
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      _badgeController.repeat(reverse: true);
    });
  }

  void _gotoMapScreen() {
    context.go(
      AppWrapper.route,
      extra: AppWrapperArgs(
        homeScreenArgs: HomeScreenArgs(
          initialTab: HomeTab.map,
        ),
      ),
    );
  }
}
