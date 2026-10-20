import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/views/widgets/progress_bar.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The flat light page every onboarding step sits on (approved boards):
/// the boards' #F5F5F7 page, 20 px gutters, an optional back arrow, the segmented
/// step bar, then the step's own content, scrolling once it stops fitting.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.step,
    required this.children,
    this.showBack = true,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final OnboardingStep step;
  final List<Widget> children;
  final bool showBack;
  final CrossAxisAlignment crossAxisAlignment;

  /// The steps the bar counts: every step before "completed".
  static int get totalSteps => OnboardingStep.values.length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              // IntrinsicHeight lets a Spacer in the content push the CTA
              // to the bottom while the page still fits, and the scroll
              // view takes over once it does not.
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20.spMin,
                    12.spMin,
                    20.spMin,
                    20.spMin,
                  ),
                  child: Column(
                    crossAxisAlignment: crossAxisAlignment,
                    children: [
                      _buildTopRow(context),
                      SizedBox(height: 16.spMin),
                      ProgressBar(
                        currentStep: step.index + 1,
                        totalSteps: totalSteps,
                      ),
                      SizedBox(height: 18.spMin),
                      ...children,
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

  Widget _buildTopRow(final BuildContext context) {
    if (!showBack) return SizedBox(height: 40.spMin);
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 40.spMin,
            height: 40.spMin,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.arrowLeft,
              size: 20.spMin,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
