import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_group_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/paywall_parts.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The one ALRT + entry (master spec §8, §10): two clearly separate
/// choices, "For myself" (Individual) and "Cover a group" (Family, Group
/// 20, Group 50), with ALRT Free always one tap away. Pops the result of
/// whichever purchase screen was opened.
class AlrtPlusChooseScreen extends StatelessWidget {
  const AlrtPlusChooseScreen({super.key});

  static const route = '/alrt-plus/choose';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaywallBody,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(18.spMin, 8.spMin, 18.spMin, 24.spMin),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            SizedBox(height: 4.spMin),
            Text(
              kChooseHeading,
              style: TextStyle(
                fontSize: 24.spMin,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: kPaywallInk,
              ),
            ),
            SizedBox(height: 18.spMin),
            _choice(
              context,
              identity: PlanIdentity.individual,
              icon: LucideIcons.user,
              title: kChooseForMyselfTitle,
              body: kChooseForMyselfBody,
              onTap: () async {
                final ok = await context.push<bool>(
                  AlrtPlusPaywallScreen.route,
                  extra: const AlrtPlusPaywallArgs(),
                );
                if (ok == true && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
            SizedBox(height: 12.spMin),
            _choice(
              context,
              identity: PlanIdentity.family,
              icon: LucideIcons.users,
              title: kChooseCoverGroupTitle,
              body: kChooseCoverGroupBody,
              onTap: () async {
                final ok = await context.push<bool>(
                  AlrtPlusGroupPaywallScreen.route,
                );
                if (ok == true && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
            SizedBox(height: 22.spMin),
            SizedBox(
              height: 48.spMin,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: kPaywallLine, width: 1.5),
                  foregroundColor: kPaywallInk,
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(kContinueFree),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choice(
    final BuildContext context, {
    required final PlanIdentity identity,
    required final IconData icon,
    required final String title,
    required final String body,
    required final VoidCallback onTap,
  }) {
    final accent = identity.accentFor(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.spMin),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.spMin),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.spMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.spMin),
            border: Border.all(color: kPaywallLine),
          ),
          child: Row(
            children: [
              Container(
                width: 44.spMin,
                height: 44.spMin,
                decoration: BoxDecoration(
                  color: identity.tint,
                  borderRadius: BorderRadius.circular(14.spMin),
                ),
                child: Icon(icon, color: accent, size: 22.spMin),
              ),
              SizedBox(width: 12.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w800,
                        color: kPaywallInk,
                      ),
                    ),
                    SizedBox(height: 3.spMin),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 13.spMin,
                        height: 1.45,
                        color: kPaywallInkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
