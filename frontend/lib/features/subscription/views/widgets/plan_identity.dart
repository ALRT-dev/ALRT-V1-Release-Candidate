import 'package:flutter/material.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';

/// The colour identity of each ALRT + product (product owner, 28 Sep
/// 2026, replacing the master spec §8 teal/purple/blue set):
/// - ALRT + (personal, formerly "Individual"): purple
/// - ALRT + Family: bright green
/// - ALRT + Group 20 / Group 50: blue
/// Each has a gradient for heroes and badges, a solid accent for buttons
/// and borders, and a light tint for selected rows.
///
/// Never used for official warnings, red SOS actions, the green Check in
/// button or the Family navigation. The ALRT wordmark stays orange.
@immutable
class PlanIdentity {
  const PlanIdentity({
    required this.name,
    required this.accent,
    required this.tint,
    required this.darkAccent,
    required this.gradient,
  });

  /// What follows "ALRT +": empty for the personal plan, else "Family",
  /// "Group 20"... (see [label]).
  final String name;

  /// Light-mode accent: buttons, selected row border. White text on it
  /// passes WCAG AA.
  final Color accent;

  /// Light-mode tint: selected row fill, benefit ticks.
  final Color tint;

  /// Dark-mode accent (on dark surfaces).
  final Color darkAccent;

  /// Dark to light, top-left to bottom-right. White text sits on the
  /// darker end.
  final List<Color> gradient;

  /// "ALRT +", "ALRT + Family", "ALRT + Group".
  String get label => name.isEmpty ? 'ALRT +' : 'ALRT + $name';

  LinearGradient get linearGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: gradient,
  );

  static const individual = PlanIdentity(
    name: '',
    accent: Color(0xFF7B359A),
    tint: Color(0xFFF6EEFB),
    darkAccent: Color(0xFFD9A2EF),
    gradient: [Color(0xFF4A1766), Color(0xFF8E3FB3)],
  );

  static const family = PlanIdentity(
    name: 'Family',
    accent: Color(0xFF0A7F4F),
    tint: Color(0xFFE9F8F0),
    darkAccent: Color(0xFF5EDC9C),
    gradient: [Color(0xFF05603B), Color(0xFF17A96A)],
  );

  /// Group 20 and Group 50 share blue; capacity and price tell them apart.
  static const group = PlanIdentity(
    name: 'Group',
    accent: Color(0xFF1F5CAD),
    tint: Color(0xFFEEF4FE),
    darkAccent: Color(0xFF99C1FF),
    gradient: [Color(0xFF123A73), Color(0xFF2468C4)],
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

/// The full product name: "ALRT +", "ALRT + Family", "ALRT + Group 20".
String planDisplayName(final PlanTier tier) =>
    tier == PlanTier.individual ? 'ALRT +' : 'ALRT + ${planTierName(tier)}';

/// The plan pill: white "ALRT + Family" on the plan's gradient. [label]
/// replaces the words after "ALRT +" (for example "Group 20").
class PlanBadge extends StatelessWidget {
  const PlanBadge({super.key, required this.identity, this.label});

  final PlanIdentity identity;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final rest = label ?? identity.name;
    final text = rest.isEmpty ? 'ALRT +' : 'ALRT + $rest';
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          gradient: identity.linearGradient,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
