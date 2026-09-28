import 'package:flutter/material.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';

/// The colour identity of each ALRT + product (master spec §8).
///
/// Applied to the plus sign / plan badge, the paywall hero, benefit icons,
/// the purchase button, the selected plan row and the membership card.
/// Never used for official warnings, red SOS actions, the green Check in
/// button or the Family navigation. The ALRT wordmark stays orange.
@immutable
class PlanIdentity {
  const PlanIdentity({
    required this.name,
    required this.accent,
    required this.tint,
    required this.darkAccent,
  });

  final String name;

  /// Light-mode accent: buttons, selected row border, badge.
  final Color accent;

  /// Light-mode tint: hero wash, selected row fill, card background.
  final Color tint;

  /// Dark-mode accent (on dark surfaces).
  final Color darkAccent;

  static const individual = PlanIdentity(
    name: 'Individual',
    accent: Color(0xFF096D69),
    tint: Color(0xFFEFF9F7),
    darkAccent: Color(0xFF76D9CD),
  );

  static const family = PlanIdentity(
    name: 'Family',
    accent: Color(0xFF7B359A),
    tint: Color(0xFFF8F1FC),
    darkAccent: Color(0xFFD9A2EF),
  );

  /// Group 20 and Group 50 share blue; capacity and price tell them apart.
  static const group = PlanIdentity(
    name: 'Group',
    accent: Color(0xFF1F5CAD),
    tint: Color(0xFFF0F5FE),
    darkAccent: Color(0xFF99C1FF),
  );

  static PlanIdentity of(final PlanTier tier) => switch (tier) {
    PlanTier.individual => individual,
    PlanTier.family => family,
    PlanTier.group20 || PlanTier.group50 => group,
  };

  /// The accent to use on the current theme's surface.
  Color accentFor(final BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkAccent : accent;
}

/// The "ALRT +" badge in a plan's colour. The plus carries the plan
/// colour; the text stays readable on light and dark surfaces.
class PlanBadge extends StatelessWidget {
  const PlanBadge({super.key, required this.identity, this.label});

  final PlanIdentity identity;

  /// Defaults to "ALRT + " followed by the plan name.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final accent = identity.accentFor(context);
    return Semantics(
      label: label ?? 'ALRT + ${identity.name}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'ALRT '),
              TextSpan(
                text: '+',
                style: TextStyle(color: accent),
              ),
              if (label == null) TextSpan(text: ' ${identity.name}'),
              if (label != null) TextSpan(text: ' $label'),
            ],
          ),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF232326),
          ),
        ),
      ),
    );
  }
}
