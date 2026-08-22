import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AlrtApprovedToast extends StatefulWidget {
  const AlrtApprovedToast({
    super.key,
    required this.onDismiss,
    this.autoCloseDuration = const Duration(seconds: 3),
  });

  final VoidCallback onDismiss;
  final Duration autoCloseDuration;

  @override
  State<AlrtApprovedToast> createState() => _AlrtApprovedToastState();
}

class _AlrtApprovedToastState extends State<AlrtApprovedToast>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Slide and fade animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutBack,
          ),
        );

    _fadeAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOut,
          ),
        );

    // Progress animation for auto-close
    _progressController = AnimationController(
      duration: widget.autoCloseDuration,
      vsync: this,
    );

    _slideController.forward();
    _progressController.forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dismissToast();
      }
    });
  }

  void _dismissToast() async {
    await _slideController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.spMin),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismissToast,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity!.abs() > 100) {
                  _dismissToast();
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(20.spMin),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.spMin),
                  child: Stack(
                    children: [
                      // Subtle gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.1),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: EdgeInsets.all(16.spMin),
                        child: Row(
                          children: [
                            // Icon container
                            Container(
                              width: 40.spMin,
                              height: 40.spMin,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  LucideIcons.check,
                                  color: Colors.white,
                                  size: 22.spMin,
                                ),
                              ),
                            ),
                            12.wSizedBox,
                            // Message
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ALRT Approved! 🎉',
                                    style: TextStyle(
                                      fontSize: 14.spMin,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.4,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  2.hSizedBox,
                                  Text(
                                    'Your alert is now live - community notified',
                                    style: TextStyle(
                                      fontSize: 11.spMin,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            4.wSizedBox,
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.spMin),
                                color: AppColors.white.withValues(alpha: 0.15),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.spMin,
                                vertical: 5.spMin,
                              ),
                              child: Row(
                                spacing: 5.spMin,
                                children: [
                                  Icon(
                                    LucideIcons.star,
                                    size: 12.spMin,
                                    color: AppColors.white,
                                  ),
                                  Text(
                                    '+10',
                                    style: TextStyle(
                                      fontSize: 14.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            8.wSizedBox,
                            // Close button
                            GestureDetector(
                              onTap: _dismissToast,
                              child: Container(
                                width: 28.spMin,
                                height: 28.spMin,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8.spMin),
                                ),
                                child: Center(
                                  child: Icon(
                                    LucideIcons.x,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    size: 16.spMin,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress indicator at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Container(
                              height: 3.spMin,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16.spMin),
                                  bottomRight: Radius.circular(16.spMin),
                                ),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 1 - _progressController.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16.spMin),
                                      bottomRight:
                                          _progressController.value > 0.95
                                          ? Radius.zero
                                          : Radius.circular(2.spMin),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
