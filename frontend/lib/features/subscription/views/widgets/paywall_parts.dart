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

/// The plan hero: a rounded card on the plan's gradient with white text,
/// the plan pill, heading, one line, and an optional "who it covers" chip.
class PlanHero extends StatelessWidget {
  const PlanHero({
    super.key,
    required this.identity,
    required this.heading,
    required this.intro,
    required this.onClose,
    this.badgeLabel,
    this.coverLine,
  });

  final PlanIdentity identity;
  final String heading;
  final String intro;
  final VoidCallback? onClose;
  final String? badgeLabel;

  /// Plain words for who and what the plan covers ("Covers you", "Covers
  /// everyone in Netball Mums · up to 20 people").
  final String? coverLine;

  @override
  Widget build(BuildContext context) {
    final rest = badgeLabel ?? identity.name;
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 4.spMin,
        left: 12.spMin,
        right: 12.spMin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: Icon(LucideIcons.x, color: kPaywallInk, size: 22.spMin),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20.spMin,
              18.spMin,
              20.spMin,
              20.spMin,
            ),
            decoration: BoxDecoration(
              gradient: identity.linearGradient,
              borderRadius: BorderRadius.circular(22.spMin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rest.isEmpty ? 'ALRT +' : 'ALRT + $rest',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                SizedBox(height: 10.spMin),
                Text(
                  heading,
                  style: TextStyle(
                    fontSize: 24.spMin,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.spMin),
                Text(
                  intro,
                  style: TextStyle(
                    fontSize: 13.5.spMin,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                if (coverLine != null) ...[
                  SizedBox(height: 14.spMin),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.spMin,
                      vertical: 8.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12.spMin),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.circleCheck,
                          size: 15.spMin,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.spMin),
                        Flexible(
                          child: Text(
                            coverLine!,
                            style: TextStyle(
                              fontSize: 12.5.spMin,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

/// One plan, said simply: who it covers and what they get. On the plan's
/// gradient when the plan is in force; plain white when it isn't.
class PlanCoverageCard extends StatelessWidget {
  const PlanCoverageCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.covers,
    this.identity,
    this.chip,
    this.note,
    this.actionLabel,
    this.onAction,
    this.actionIdentity,
  });

  /// Colours the action on a white card (for example "See ALRT +" in
  /// purple). Ignored on a gradient card.
  final PlanIdentity? actionIdentity;

  /// Null = not in force: a white card.
  final PlanIdentity? identity;

  /// "ALRT + FAMILY", "ALRT FREE", "NO GROUP PLAN".
  final String eyebrow;

  /// "Covers you", or the group's name.
  final String title;

  /// "4 of 6 people", "Renews 28 October 2026".
  final String? chip;

  /// What is covered, in one plain line.
  final String covers;

  /// Anything the person should know (pending change, lapsed plan).
  final String? note;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final on = identity != null;
    final ink = on ? Colors.white : kPaywallInk;
    final soft = on ? Colors.white.withValues(alpha: 0.9) : kPaywallInkSoft;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.spMin, 16.spMin, 18.spMin, 16.spMin),
      decoration: BoxDecoration(
        gradient: identity?.linearGradient,
        color: on ? null : Colors.white,
        borderRadius: BorderRadius.circular(20.spMin),
        border: on ? null : Border.all(color: kPaywallLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: on
                  ? Colors.white.withValues(alpha: 0.9)
                  : kPaywallInkFaint,
            ),
          ),
          SizedBox(height: 6.spMin),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.spMin,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          SizedBox(height: 6.spMin),
          Text(
            covers,
            style: TextStyle(fontSize: 13.spMin, height: 1.45, color: soft),
          ),
          if (chip != null) ...[
            SizedBox(height: 12.spMin),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.spMin,
                vertical: 6.spMin,
              ),
              decoration: BoxDecoration(
                color: on
                    ? Colors.white.withValues(alpha: 0.16)
                    : const Color(0xFFF1F0F4),
                borderRadius: BorderRadius.circular(10.spMin),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.circleCheck, size: 14.spMin, color: ink),
                  SizedBox(width: 6.spMin),
                  Flexible(
                    child: Text(
                      chip!,
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (note != null) ...[
            SizedBox(height: 10.spMin),
            Text(
              note!,
              style: TextStyle(
                fontSize: 12.5.spMin,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 12.spMin),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  backgroundColor: on
                      ? Colors.white.withValues(alpha: 0.18)
                      : actionIdentity?.accent ?? const Color(0xFFF1F0F4),
                  foregroundColor: on || actionIdentity != null
                      ? Colors.white
                      : ink,
                  padding: EdgeInsets.symmetric(vertical: 12.spMin),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Green (Family) into blue (Group), for anything that means "a group
/// plan" before the size is chosen.
const kGroupPlansGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF05603B), Color(0xFF1F5CAD)],
);

/// A choice between plans, on the plan's gradient: eyebrow, title, one
/// line of what it covers, and a chevron when it can be tapped.
class PlanChoiceCard extends StatelessWidget {
  const PlanChoiceCard({
    super.key,
    required this.gradient,
    required this.eyebrow,
    required this.title,
    required this.body,
    this.onTap,
    this.footnote,
  });

  final Gradient gradient;
  final String eyebrow;
  final String title;
  final String body;
  final VoidCallback? onTap;

  /// Shown under the body, for example why it can't be chosen yet.
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20.spMin),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.spMin),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.spMin, 16.spMin, 14.spMin, 16.spMin),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow,
                        style: TextStyle(
                          fontSize: 11.5.spMin,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      SizedBox(height: 6.spMin),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18.spMin,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.spMin),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 13.spMin,
                          height: 1.45,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                      if (footnote != null) ...[
                        SizedBox(height: 8.spMin),
                        Text(
                          footnote!,
                          style: TextStyle(
                            fontSize: 12.spMin,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(LucideIcons.chevronRight, color: Colors.white, size: 22.spMin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
