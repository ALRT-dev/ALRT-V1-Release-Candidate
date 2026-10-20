import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/onboarding_page.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
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
    // Hidden only when ALRT + is already held. It is NOT hidden when the
    // backend reports billing off (TEST): the plan screens handle every
    // refusal themselves, and hiding the way in made paid sign-up
    // impossible to test.
    final hasAlrtPlus = ref.watch(providerOfAlrtPlus).asData?.value ?? false;
    final showPlansLink = !hasAlrtPlus;

    return OnboardingPage(
      step: _step,
      children: [
        Text(
          'ALRT is free to use',
          style: TextStyle(
            fontSize: 30.spMin,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
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
        18.hSizedBox,
        _PlanCard(
          identity: PlanIdentity.individual,
          title: 'For myself',
          body: 'Unlimited places, 10 questions a day, any groups',
          onTap: showPlansLink
              ? () => context.push(AlrtPlusPaywallScreen.route)
              : null,
        ),
        10.hSizedBox,
        _PlanCard(
          identity: PlanIdentity.family,
          title: 'Cover a group of up to 6',
          body: 'Check in, Check on, SOS and Journey for everyone in it',
          onTap: () => context.push(AlrtPlusChooseScreen.route),
        ),
        10.hSizedBox,
        _PlanCard(
          identity: PlanIdentity.group,
          title: 'Cover 20 or 50 people',
          body: 'Same, for a team, a street or a club',
          onTap: () => context.push(AlrtPlusChooseScreen.route),
        ),
        14.hSizedBox,
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
        GradientButton(
          title: 'Continue with ALRT Free',
          dark: true,
          onPressed: () => _next(context),
        ),
        if (showPlansLink) ...[
          6.hSizedBox,
          SizedBox(
            height: 44.spMin,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mediumGrey,
              ),
              onPressed: () => context.push(AlrtPlusChooseScreen.route),
              child: Text(
                'See ALRT + plans',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The board's plan row: a white card on a soft shadow with the plan's
/// gradient pill on the left, then a bold line and one plain line.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.identity,
    required this.title,
    required this.body,
    this.onTap,
  });

  final PlanIdentity identity;
  final String title;
  final String body;

  /// Opens the plan's sign-up. Null leaves the card as information only.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.spMin);
    return Semantics(
      button: onTap != null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: AppColors.white,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 14.spMin,
                vertical: 12.spMin,
              ),
              child: Row(
                children: [
                  Container(
                    height: 24.spMin,
                    padding: EdgeInsets.symmetric(horizontal: 10.spMin),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: identity.linearGradient,
                      borderRadius: BorderRadius.circular(12.spMin),
                    ),
                    child: Text(
                      identity.label,
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  12.wSizedBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.spMin,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        1.hSizedBox,
                        Text(
                          body,
                          style: TextStyle(
                            fontSize: 12.spMin,
                            height: 1.35,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
