import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class ConfirmationPopup extends StatefulWidget {
  const ConfirmationPopup({
    super.key,
    required this.show,
    required this.message,
    required this.onComplete,
  });

  final bool show;
  final String message;
  final VoidCallback onComplete;

  @override
  State<ConfirmationPopup> createState() => _ConfirmationPopupState();
}

class _ConfirmationPopupState extends State<ConfirmationPopup>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late AnimationController _popupController;
  late AnimationController _checkController;
  late AnimationController _glowController;
  late AnimationController _textController;
  late List<AnimationController> _sparkleControllers;

  late Animation<double> _overlayOpacityAnimation;
  late Animation<double> _popupScaleAnimation;
  late Animation<Offset> _popupSlideAnimation;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _checkRotateAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late List<Animation<Offset>> _sparklePositionAnimations;
  late List<Animation<double>> _sparkleScaleAnimations;
  late List<Animation<double>> _sparkleOpacityAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.show) {
      _startAnimation();
    }
  }

  void _setupAnimations() {
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _popupController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize sparkle controllers
    _sparkleControllers = List.generate(
      8,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      ),
    );

    _overlayOpacityAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _overlayController,
            curve: Curves.easeOut,
          ),
        );

    _popupScaleAnimation =
        Tween<double>(
          begin: 0.5,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _popupController,
            curve: Curves.elasticOut,
          ),
        );

    _popupSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 50),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _popupController,
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
            curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
          ),
        );

    _checkRotateAnimation =
        Tween<double>(
          begin: -math.pi,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _checkController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );

    _glowAnimation =
        Tween<double>(
          begin: 0.5,
          end: 0.8,
        ).animate(
          CurvedAnimation(
            parent: _glowController,
            curve: Curves.easeInOut,
          ),
        );

    _textOpacityAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Curves.easeOut,
          ),
        );

    _textSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 10),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Curves.easeOut,
          ),
        );

    // Setup sparkle animations
    _sparklePositionAnimations = List.generate(8, (index) {
      final angle = index * 45 * (math.pi / 180);
      return Tween<Offset>(
        begin: Offset.zero,
        end: Offset(
          math.cos(angle) * 150,
          math.sin(angle) * 150,
        ),
      ).animate(
        CurvedAnimation(
          parent: _sparkleControllers[index],
          curve: Curves.easeOut,
        ),
      );
    });

    _sparkleScaleAnimations = List.generate(8, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _sparkleControllers[index],
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ),
      );
    });

    _sparkleOpacityAnimations = List.generate(8, (index) {
      return Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _sparkleControllers[index],
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
        ),
      );
    });
  }

  void _startAnimation() {
    _overlayController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      _popupController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _checkController.forward();
      _glowController.repeat(reverse: true);

      // Start sparkle effects
      for (int i = 0; i < _sparkleControllers.length; i++) {
        Future.delayed(Duration(milliseconds: 200 + (i * 50)), () {
          _sparkleControllers[i].forward();
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _popupController.dispose();
    _checkController.dispose();
    _glowController.dispose();
    _textController.dispose();
    for (var controller in _sparkleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _overlayController,
        builder: (context, child) {
          return Opacity(
            opacity: _overlayOpacityAnimation.value,
            child: Container(
              color: AppColors.black.withValues(alpha: 0.3),
              child: Center(
                child: AnimatedBuilder(
                  animation: _popupController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _popupScaleAnimation.value,
                      child: Transform.translate(
                        offset: _popupSlideAnimation.value,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.spMin),
                          constraints: BoxConstraints(maxWidth: 400.spMin),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(30.spMin),
                            border: Border.all(
                              color: Colors.green.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 40.spMin,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32.spMin,
                                  vertical: 80.spMin,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildCheckIcon(),
                                    16.hSizedBox,
                                    _buildMessage(),
                                  ],
                                ),
                              ),
                              ..._buildSparkles(),
                            ],
                          ),
                        ),
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

  Widget _buildCheckIcon() {
    return AnimatedBuilder(
      animation: _checkController,
      builder: (context, child) {
        return Transform.scale(
          scale: _checkScaleAnimation.value,
          child: Transform.rotate(
            angle: _checkRotateAnimation.value,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  width: 80.spMin,
                  height: 80.spMin,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF10b981), // green-400
                        Color(0xFF059669), // emerald-600
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(
                          alpha: _glowAnimation.value,
                        ),
                        blurRadius: 40.spMin,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 40.spMin,
                    color: AppColors.white,
                    weight: 3,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessage() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: _textSlideAnimation.value,
          child: Opacity(
            opacity: _textOpacityAnimation.value,
            child: Text(
              widget.message,
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSparkles() {
    return List.generate(8, (index) {
      return AnimatedBuilder(
        animation: _sparkleControllers[index],
        builder: (context, child) {
          final position = _sparklePositionAnimations[index].value;
          final scale = _sparkleScaleAnimations[index].value;
          final opacity = _sparkleOpacityAnimations[index].value;

          return Positioned(
            left: (200.spMin / 2) + position.dx,
            top: (200.spMin / 2) + position.dy,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 8.spMin,
                  height: 8.spMin,
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.6),
                        blurRadius: 4.spMin,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
