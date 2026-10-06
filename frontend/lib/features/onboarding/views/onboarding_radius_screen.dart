import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/progress_bar.dart';
import 'package:hazard_app/features/onboarding/views/widgets/confirmation_popup.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class RadiusOption {
  final int value;
  final String label;
  final String description;

  const RadiusOption({
    required this.value,
    required this.label,
    required this.description,
  });
}

class OnboardingRadiusScreen extends ConsumerStatefulWidget {
  const OnboardingRadiusScreen({super.key});

  static const route = '/onboarding/radius';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingRadiusScreenState();
}

class _OnboardingRadiusScreenState extends ConsumerState<OnboardingRadiusScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pinController;
  late AnimationController _pulseController;
  late AnimationController _radiusController;
  late List<AnimationController> _alertControllers;

  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pinFloatAnimation;
  late Animation<double> _pulseAnimation;
  late List<Animation<double>> _radiusScaleAnimations;
  late List<Animation<double>> _radiusOpacityAnimations;
  late List<Animation<double>> _alertScaleAnimations;
  late List<Animation<double>> _alertOpacityAnimations;

  bool _showConfirmation = false;

  final List<RadiusOption> _radiusOptions = const [
    RadiusOption(value: 1, label: '1 km', description: 'Immediate vicinity'),
    RadiusOption(value: 2, label: '2 km', description: 'Close neighborhood'),
    RadiusOption(value: 3, label: '3 km', description: 'Local area'),
    RadiusOption(value: 4, label: '4 km', description: 'Extended area'),
    RadiusOption(value: 5, label: '5 km', description: 'Wider community'),
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

    _pinController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _radiusController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize alert controllers
    _alertControllers = List.generate(
      6,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 1500),
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

    _pinFloatAnimation =
        Tween<double>(
          begin: 0.0,
          end: -5.0,
        ).animate(
          CurvedAnimation(
            parent: _pinController,
            curve: Curves.easeInOut,
          ),
        );

    // Setup pulse animations
    _pulseAnimation =
        Tween<double>(
          begin: 1.0,
          end: 2.5,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    // Setup radius circle animations
    _radiusScaleAnimations = List.generate(
      5,
      (index) =>
          Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: _radiusController,
              curve: Interval(
                index * 0.1,
                (index * 0.1) + 0.5,
                curve: Curves.easeOut,
              ),
            ),
          ),
    );

    _radiusOpacityAnimations = List.generate(
      5,
      (index) =>
          Tween<double>(
            begin: 0.0,
            end: 0.3 - (index * 0.05),
          ).animate(
            CurvedAnimation(
              parent: _radiusController,
              curve: Interval(
                index * 0.1,
                (index * 0.1) + 0.5,
                curve: Curves.easeOut,
              ),
            ),
          ),
    );

    // Setup alert indicator animations
    _alertScaleAnimations = List.generate(
      6,
      (index) =>
          Tween<double>(
            begin: 1.0,
            end: 1.3,
          ).animate(
            CurvedAnimation(
              parent: _alertControllers[index],
              curve: Curves.easeInOut,
            ),
          ),
    );

    _alertOpacityAnimations = List.generate(
      6,
      (index) =>
          Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: _alertControllers[index],
              curve: Curves.easeInOut,
            ),
          ),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _mainController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _pinController.repeat(reverse: true);
      _pulseController.repeat();
    });
  }

  void _startRadiusAnimations() {
    _radiusController.forward();

    for (int i = 0; i < _alertControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 500 + (i * 200)), () {
        _alertControllers[i].repeat(reverse: true);
      });
    }
  }

  void _resetRadiusAnimations() {
    _radiusController.reset();
    for (var controller in _alertControllers) {
      controller.reset();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pinController.dispose();
    _pulseController.dispose();
    _radiusController.dispose();
    for (var controller in _alertControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSelectRadius(int radius) {
    ref.read(providerOfOnboarding.notifier).updateSelectedRadius(radius);

    _resetRadiusAnimations();
    Future.delayed(const Duration(milliseconds: 100), () {
      _startRadiusAnimations();
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
                currentStep: 4,
                totalSteps: OnboardingStep.values.length - 1,
                label: 'Step 4 of ${OnboardingStep.values.length - 1}',
              ),
              40.hSizedBox,
              _buildHeaderSection(),
              40.hSizedBox,
              _buildRadiusVisualizer(),
              40.hSizedBox,
              _buildRadiusOptions(),
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
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Column(
            children: [
              Text(
                'Set your radius',
                style: TextStyle(
                  fontSize: 28.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              12.hSizedBox,
              Text(
                'Choose how far from your location you want to make, confirm, or deny alerts. This helps keep information local and relevant.',
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

  Widget _buildRadiusVisualizer() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Container(
            height: 280.spMin,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.orange.withValues(alpha: 0.05),
                  Colors.red.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30.spMin),
              border: Border.all(
                color: AppColors.orange.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.spMin),
              child: Stack(
                children: [
                  Center(child: _buildRadiusCircles()),
                  Center(child: _buildCenterPin()),
                  Center(child: _buildAlertIndicators()),
                  Consumer(
                    builder: (context, ref, child) {
                      final selectedRadius = ref.watch(
                        providerOfOnboarding.select(
                          (value) => value.selectedRadius,
                        ),
                      );
                      if (selectedRadius != null && selectedRadius > 0) {
                        return _buildRadiusLabel();
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadiusCircles() {
    return AnimatedBuilder(
      animation: _radiusController,
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, child) {
            final selectedRadius = ref.watch(
              providerOfOnboarding.select(
                (value) => value.selectedRadius ?? 0,
              ),
            );
            return Stack(
              alignment: Alignment.center,
              children: List.generate(selectedRadius, (index) {
                final size = (index + 1) * 80.spMin;
                return Transform.scale(
                  scale: _radiusScaleAnimations[index].value,
                  child: Opacity(
                    opacity: _radiusOpacityAnimations[index].value,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.orange,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }

  Widget _buildCenterPin() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse rings
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = _pulseAnimation.value;
            final opacity = (2.5 - scale) / 1.5 * 0.6;

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity.clamp(0.0, 0.6),
                child: Container(
                  width: 48.spMin,
                  height: 48.spMin,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade400,
                  ),
                ),
              ),
            );
          },
        ),

        // Main pin
        AnimatedBuilder(
          animation: _pinController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _pinFloatAnimation.value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pin body
                  SizedBox(
                    width: 40.spMin,
                    height: 48.spMin,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Pin circle
                        Container(
                          width: 40.spMin,
                          height: 40.spMin,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF22d3ee), // cyan-400
                                Color(0xFF10b981), // green-500
                                Color(0xFF3b82f6), // blue-500
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 8.spMin,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 12.spMin,
                              height: 12.spMin,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        // Pin point
                        Positioned(
                          top: 32.spMin,
                          child: CustomPaint(
                            size: Size(10.spMin, 8.spMin),
                            painter: PinPointPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlertIndicators() {
    return Consumer(
      builder: (context, ref, child) {
        final selectedRadius = ref.watch(
          providerOfOnboarding.select(
            (value) => value.selectedRadius ?? 0,
          ),
        );
        if (selectedRadius == 0) return const SizedBox.shrink();

        return Stack(
          alignment: Alignment.center,
          children: List.generate(6, (index) {
            final angle = (index * 60) * (math.pi / 180);
            final distance = math.min(selectedRadius * 40.spMin, 160.spMin);
            final x = math.cos(angle) * distance;
            final y = math.sin(angle) * distance;

            return AnimatedBuilder(
              animation: _alertControllers[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(x, y),
                  child: Transform.scale(
                    scale: _alertScaleAnimations[index].value,
                    child: Opacity(
                      opacity: _alertOpacityAnimations[index].value,
                      child: Container(
                        width: 16.spMin,
                        height: 16.spMin,
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue.withValues(alpha: 0.4),
                              blurRadius: 4.spMin,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  Widget _buildRadiusLabel() {
    return Positioned(
      bottom: 10.spMin,
      left: 0.0,
      right: 0.0,
      child: Center(
        child: AnimatedBuilder(
          animation: _radiusController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 10 * (1 - _radiusController.value)),
              child: Opacity(
                opacity: _radiusController.value,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.spMin,
                    vertical: 8.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(100.spMin),
                    border: Border.all(
                      color: AppColors.orange.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 8.spMin,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final selectedRadius = ref.watch(
                        providerOfOnboarding.select(
                          (value) => value.selectedRadius ?? 0,
                        ),
                      );

                      return Text(
                        '$selectedRadius km radius',
                        style: TextStyle(
                          fontSize: 14.spMin,
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildRadiusOptions() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Column(
            children: _radiusOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;

              return Padding(
                padding: EdgeInsets.only(bottom: 12.spMin),
                child: _buildRadiusOptionCard(option, index),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildRadiusOptionCard(RadiusOption option, int index) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedRadius = ref.watch(
          providerOfOnboarding.select(
            (value) => value.selectedRadius,
          ),
        );
        final isSelected = selectedRadius == option.value;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween<double>(begin: -20, end: 0),
          curve: Curves.easeOut,
          builder: (context, offset, child) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 600 + (index * 100)),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeOut,
              builder: (context, opacity, child) {
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: Opacity(
                    opacity: opacity,
                    child: GestureDetector(
                      onTap: () => _handleSelectRadius(option.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: EdgeInsets.all(16.spMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.spMin),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.orange
                                : AppColors.lightGrey,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColors.orange.withValues(alpha: 0.05)
                              : AppColors.white,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.orange.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 8.spMin,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
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
                            AnimatedScale(
                              scale: isSelected ? 1.2 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.elasticOut,
                              child: Text(
                                isSelected ? '✓' : '○',
                                style: TextStyle(
                                  fontSize: 24.spMin,
                                  color: isSelected
                                      ? AppColors.orange
                                      : AppColors.grey,
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
    return Consumer(
      builder: (context, ref, child) {
        final selectedRadius = ref.watch(
          providerOfOnboarding.select(
            (value) => value.selectedRadius,
          ),
        );

        return ConfirmationPopup(
          show: true,
          message:
              "Radius set to ${selectedRadius}km! You'll interact with alerts within this range.",
          onComplete: _handleConfirmationComplete,
        );
      },
    );
  }

  void _handleConfirmationComplete() {
    setState(() {
      _showConfirmation = false;
    });

    // context.push(OnboardingStep.radius.nextStep.route);
  }

  void _onNext() async {
    final result = await ref
        .read(providerOfOnboarding.notifier)
        .setOnboardingRadius();
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

class PinPointPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22d3ee)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
