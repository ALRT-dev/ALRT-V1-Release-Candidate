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

/// Onboarding step 4: explains that ALRT is free and what the free tier
/// includes. No prices, no purchase flow, no paywall navigation.
///
/// Handoff: "No prices, no purchase; free tier stated plainly."
class OnboardingAlrtPlusScreen extends ConsumerWidget {
  const OnboardingAlrtPlusScreen({super.key, this.onDone});

  static const route = '/onboarding/alrt-plus';

  /// Test seam; defaults to the next onboarding step.
  final VoidCallback? onDone;

  void _next(final BuildContext context) {
    if (onDone != null) {
      onDone!();
      return;
    }
    context.go(OnboardingStep.alrtPlus.nextStep.route);
  }

  static const _step = OnboardingStep.alrtPlus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.orange.withValues(alpha: 0.08),
              AppColors.purple.withValues(alpha: 0.06),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
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
                  child: Padding(
                    padding: EdgeInsets.all(20.spMin),
                    child: Column(
                      children: [
                        _buildBackButton(context),
                        24.hSizedBox,
                        ProgressBar(
                          currentStep: _step.index,
                          totalSteps: OnboardingStep.values.length - 1,
                          label:
                              'Step ${_step.index} of ${OnboardingStep.values.length - 1}',
                        ),
                        32.hSizedBox,
                        _buildHeader(),
                        28.hSizedBox,
                        _buildFreeFeatures(),
                        12.hSizedBox,
                        _buildAlrtPlusNote(),
                        32.hSizedBox,
                        GradientButton(
                          title: 'Continue with ALRT Free',
                          onPressed: () => _next(context),
                        ),
                        20.hSizedBox,
                      ],
                    ),
                  ),
                ).pad(20.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14.spMin),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 40.spMin,
            color: AppColors.green,
          ),
        ),
        20.hSizedBox,
        Text(
          'ALRT is free to use',
          style: TextStyle(
            fontSize: 26.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),
        10.hSizedBox,
        Text(
          'Everything you need to stay aware is included at no cost.',
          style: TextStyle(
            fontSize: 15.spMin,
            color: AppColors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFreeFeatures() {
    const features = [
      _FreeFeature(
        icon: Icons.map_rounded,
        text: 'Live safety map with alerts near you',
      ),
      _FreeFeature(
        icon: Icons.navigation_rounded,
        text: 'Navigation that avoids hazards',
      ),
      _FreeFeature(
        icon: Icons.place_rounded,
        text: 'One saved place besides where you are',
      ),
      _FreeFeature(
        icon: Icons.smart_toy_rounded,
        text: '3 Ask ALRT questions a day',
      ),
      _FreeFeature(
        icon: Icons.notifications_rounded,
        text: 'Push notifications for alerts that matter',
      ),
    ];

    return Column(
      children: features
          .map((f) => Padding(
                padding: EdgeInsets.only(bottom: 12.spMin),
                child: _buildFeatureRow(f),
              ))
          .toList(),
    );
  }

  Widget _buildFeatureRow(_FreeFeature feature) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.spMin),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.spMin),
          ),
          child: Icon(
            feature.icon,
            size: 20.spMin,
            color: AppColors.orange,
          ),
        ),
        12.wSizedBox,
        Expanded(
          child: Text(
            feature.text,
            style: TextStyle(
              fontSize: 15.spMin,
              color: AppColors.black,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlrtPlusNote() {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: AppColors.extraLightGrey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.star_rounded,
            size: 20.spMin,
            color: AppColors.grey,
          ),
          10.wSizedBox,
          Expanded(
            child: Text(
              'ALRT + is optional and adds more saved places, more Ask ALRT '
              'questions, and family features. You can add it any time from '
              'your profile.',
              style: TextStyle(
                fontSize: 13.spMin,
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeFeature {
  final IconData icon;
  final String text;
  const _FreeFeature({required this.icon, required this.text});
}
