import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shared building blocks for the V1 purchase screens (Individual, Cover a
/// group, the chooser). Restrained heroes on purchase screens only, Poppins
/// from the app theme, rounded surfaces, plan colours from [PlanIdentity].

const kPaywallInk = Color(0xFF232326);
const kPaywallInkSoft = Color(0xFF5F5F68);
const kPaywallInkFaint = Color(0xFF8A8A93);
const kPaywallLine = Color(0xFFE6E4EA);
const kPaywallBody = Color(0xFFF6F6F8);

/// A calm hero: plan tint wash, the plan badge, heading and one line.
class PlanHero extends StatelessWidget {
  const PlanHero({
    super.key,
    required this.identity,
    required this.heading,
    required this.intro,
    required this.onClose,
    this.badgeLabel,
  });

  final PlanIdentity identity;
  final String heading;
  final String intro;
  final VoidCallback? onClose;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: identity.tint,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 4.spMin,
        left: 8.spMin,
        right: 20.spMin,
        bottom: 20.spMin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: Icon(LucideIcons.x, color: kPaywallInk, size: 22.spMin),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12.spMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlanBadge(identity: identity, label: badgeLabel),
                SizedBox(height: 12.spMin),
                Text(
                  heading,
                  style: TextStyle(
                    fontSize: 23.spMin,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: kPaywallInk,
                  ),
                ),
                SizedBox(height: 6.spMin),
                Text(
                  intro,
                  style: TextStyle(
                    fontSize: 13.5.spMin,
                    height: 1.5,
                    color: kPaywallInkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One benefit line with a plan-coloured check.
class PlanBenefit extends StatelessWidget {
  const PlanBenefit({super.key, required this.text, required this.identity});

  final String text;
  final PlanIdentity identity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.spMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22.spMin,
            height: 22.spMin,
            decoration: BoxDecoration(
              color: identity.tint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.check,
              size: 14.spMin,
              color: identity.accentFor(context),
            ),
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.spMin,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: kPaywallInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A white rounded card.
class PaywallCard extends StatelessWidget {
  const PaywallCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        border: Border.all(color: kPaywallLine),
      ),
      child: child,
    );
  }
}

/// Small print paragraph.
class PaywallFinePrint extends StatelessWidget {
  const PaywallFinePrint(this.text, {super.key, this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontSize: 11.5.spMin,
        height: 1.55,
        color: kPaywallInkSoft,
      ),
    );
  }
}

/// The purchase button, solid in the plan colour.
class PlanCta extends StatelessWidget {
  const PlanCta({
    super.key,
    required this.label,
    required this.identity,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final PlanIdentity identity;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    return SizedBox(
      width: double.infinity,
      height: 52.spMin,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: identity.accentFor(context),
          disabledBackgroundColor: identity.accent.withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
        onPressed: enabled ? onPressed : null,
        child: busy
            ? SizedBox(
                width: 22.spMin,
                height: 22.spMin,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

/// "Continue with ALRT Free", Restore purchases, Terms and Privacy: always
/// reachable on every purchase screen (master spec §6, Apple 3.1.2).
class PaywallFooter extends StatelessWidget {
  const PaywallFooter({
    super.key,
    required this.onContinueFree,
    required this.onRestore,
    this.busy = false,
  });

  final VoidCallback onContinueFree;
  final VoidCallback onRestore;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final link = TextStyle(
      fontSize: 12.spMin,
      color: kPaywallInkSoft,
      decoration: TextDecoration.underline,
    );
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48.spMin,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              side: const BorderSide(color: kPaywallLine, width: 1.5),
              foregroundColor: kPaywallInk,
            ),
            onPressed: busy ? null : onContinueFree,
            child: Text(
              kContinueFree,
              style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 6.spMin),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              onPressed: busy ? null : onRestore,
              child: Text('Restore purchases', style: link),
            ),
            TextButton(
              onPressed: () =>
                  openLink(context: context, link: AppLinks.termsOfUse),
              child: Text('Terms', style: link),
            ),
            TextButton(
              onPressed: () =>
                  openLink(context: context, link: AppLinks.privacyPolicy),
              child: Text('Privacy', style: link),
            ),
          ],
        ),
      ],
    );
  }
}

/// A status message box (pending, confirmed-updating, error).
class PaywallNotice extends StatelessWidget {
  const PaywallNotice({
    super.key,
    required this.text,
    this.isError = false,
  });

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFB42318) : const Color(0xFF3B4A5A);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.spMin),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEF3F2) : const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13.spMin, height: 1.45, color: color),
      ),
    );
  }
}
