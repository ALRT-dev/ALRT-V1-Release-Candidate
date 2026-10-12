import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/onboarding_page.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_choose_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Onboarding step 4 (board Onb4): ALRT is free; ALRT + is optional but
/// offered first, as the lead button, with Free one clear tap below.
///
/// No prices here (they come from the store, on the plan screens) and no
/// purchase flow: "Get ALRT +" opens the ALRT + chooser, and it is hidden
/// when the backend says billing is off or the person already has ALRT +.
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
    // Hidden when billing is disabled server-side or ALRT + is already
    // held; an unreachable backend (null) still shows it, since the plan
    // screens handle every refusal themselves.
    final billingEnabled =
        ref.watch(providerOfAccess).asData?.value?.billingEnabled ?? true;
    final hasAlrtPlus = ref.watch(providerOfAlrtPlus).asData?.value ?? false;
    final showPlansLink = billingEnabled && !hasAlrtPlus;

    return OnboardingPage(
      step: _step,
      children: [
        Text(
          'ALRT is free to use',
          style: TextStyle(
            fontSize: 26.spMin,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: AppColors.ink,
          ),
        ),
        8.hSizedBox,
        Text(
          'Alerts, the live map, navigation, one saved place and 3 Ask ALRT '
          'questions a day are always free. ALRT + is optional, and you can '
          'add it any time.',
          style: TextStyle(
            fontSize: 15.spMin,
            height: 1.45,
            color: AppColors.mediumGrey,
          ),
        ),
        24.hSizedBox,
        const _PlanCard(
          identity: PlanIdentity.individual,
          title: 'For myself',
          body: 'Unlimited places, 10 questions a day, any groups',
        ),
        12.hSizedBox,
        const _PlanCard(
          identity: PlanIdentity.family,
          title: 'Cover a group of up to 6',
          body: 'Check in, Check on, SOS and Journey for everyone in it',
        ),
        12.hSizedBox,
        const _PlanCard(
          identity: PlanIdentity.group,
          title: 'Cover 20 or 50 people',
          body: 'Same, for a team, a street or a club',
        ),
        16.hSizedBox,
        Text(
          'Prices are shown in the app store. Create or join a group in '
          'Family first if you want to cover one.',
          style: TextStyle(
            fontSize: 12.spMin,
            height: 1.45,
            color: AppColors.mediumGrey,
          ),
        ),
        const Spacer(),
        24.hSizedBox,
        if (showPlansLink) ...[
          GradientButton(
            title: 'Get ALRT +',
            onPressed: () => context.push(AlrtPlusChooseScreen.route),
          ),
          10.hSizedBox,
        ],
        GradientButton(
          title: 'Continue with ALRT Free',
          dark: true,
          onPressed: () => _next(context),
        ),
      ],
    );
  }
}

/// A white card with the plan's coloured pill, a bold title and one line.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.identity,
    required this.title,
    required this.body,
  });

  final PlanIdentity identity;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.spMin,
              vertical: 4.spMin,
            ),
            decoration: BoxDecoration(
              color: identity.accent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              identity.label,
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: AppColors.white,
              ),
            ),
          ),
          10.hSizedBox,
          Text(
            title,
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColors.ink,
            ),
          ),
          4.hSizedBox,
          Text(
            body,
            style: TextStyle(
              fontSize: 13.spMin,
              height: 1.4,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}
