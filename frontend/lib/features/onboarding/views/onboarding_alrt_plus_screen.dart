import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/paywall_parts.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';

/// Optional onboarding step (master spec §10): says what ALRT + adds and
/// what stays free, then gets out of the way. "Continue with ALRT Free" is
/// the main button; nothing here opens a store sheet by itself. Group
/// plans are explained but bought later, once the person has a group.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personal = ref.watch(providerOfAccess).asData?.value?.personal;
    final alreadyPlus =
        personal != null && personal.isIndividual && !personal.billingDisabled;
    return Scaffold(
      backgroundColor: kPaywallBody,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(18.spMin, 24.spMin, 18.spMin, 24.spMin),
          children: [
            Text(
              'ALRT is free to use',
              style: TextStyle(
                fontSize: 24.spMin,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: kPaywallInk,
              ),
            ),
            SizedBox(height: 8.spMin),
            Text(
              'Alerts, the live map, navigation, one saved place and 3 Ask '
              'ALRT questions a day are always free. ALRT + is optional, and '
              'you can add it any time from Profile.',
              style: TextStyle(
                fontSize: 14.spMin,
                height: 1.5,
                color: kPaywallInkSoft,
              ),
            ),
            SizedBox(height: 20.spMin),
            PlanChoiceCard(
              gradient: PlanIdentity.individual.linearGradient,
              eyebrow: 'ALRT +',
              title: alreadyPlus ? 'You have ALRT +' : kChooseForMyselfTitle,
              body: kChooseForMyselfBody,
              onTap: alreadyPlus
                  ? null
                  : () async {
                      final ok = await context.push<bool>(
                        AlrtPlusPaywallScreen.route,
                        extra: const AlrtPlusPaywallArgs(),
                      );
                      if (ok == true && context.mounted) _next(context);
                    },
            ),
            SizedBox(height: 12.spMin),
            const PlanChoiceCard(
              gradient: kGroupPlansGradient,
              eyebrow: 'ALRT + Family · ALRT + Group',
              title: kChooseCoverGroupTitle,
              body: kChooseCoverGroupBody,
              footnote:
                  'Create or join a group in Family first. You can cover it '
                  'from Profile at any time.',
            ),
            SizedBox(height: 24.spMin),
            PlanCta(
              label: alreadyPlus ? 'Continue' : kContinueFree,
              identity: const PlanIdentity(
                name: '',
                accent: Color(0xFF232326),
                tint: Color(0xFFF1F0F4),
                darkAccent: Colors.white,
                gradient: [Color(0xFF232326), Color(0xFF232326)],
              ),
              onPressed: () => _next(context),
            ),
          ],
        ),
      ),
    );
  }
}
