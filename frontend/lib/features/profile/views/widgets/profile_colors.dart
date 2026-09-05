import 'package:flutter/material.dart';

/// A row's icon-stroke gradient, per the approved Profile mockup: colour
/// lives on the icon only (via [ShaderMask]), never as a filled row
/// background - so the screen stays quiet next to the alert feed, where a
/// saturated fill already carries meaning.
///
/// Two stops ([start], [end]) by default. [mid] is optional and only used
/// by accents that want a three-stop gradient (currently ALRT+ membership's
/// gold -> orange -> coral) - every other accent is unaffected.
class ProfileRowAccent {
  const ProfileRowAccent(this.start, this.end, {this.mid});

  final Color start;
  final Color end;
  final Color? mid;

  List<Color> get colors => mid != null ? [start, mid!, end] : [start, end];
}

/// Per-row accent colours from the approved mockup. Each row keeps the
/// same two-stop identity in light and dark mode - Flutter's Material
/// surfaces already give the icon enough contrast against a dark card
/// without needing a second, brighter set of stops.
class ProfileColors {
  const ProfileColors._();

  static const savedLocations = ProfileRowAccent(
    Color(0xFF46B6F7),
    Color(0xFF1B54CC),
  );

  /// Family & check-ins - the same bright green -> teal identity as the
  /// in-app I'm Safe action, so the two read as one colour. Deliberately
  /// stays a two-stop gradient (not the three-stop premium treatment
  /// below): Family reads as safety, not membership.
  static const familyAndCheckIns = ProfileRowAccent(
    Color(0xFF059669),
    Color(0xFF2DD4A7),
  );

  static const journeySharing = ProfileRowAccent(
    Color(0xFF8B84FF),
    Color(0xFF4B2FC4),
  );

  static const appearance = ProfileRowAccent(
    Color(0xFFC77DFF),
    Color(0xFFA61E86),
  );

  static const notifications = ProfileRowAccent(
    Color(0xFFFFB33D),
    Color(0xFFE86A00),
  );

  /// The premium ALRT+ card (approved redesign 2026-09-03): a dark,
  /// blended purple surface - deep indigo-violet rising to a brighter
  /// purple - with white text. Dark on purpose so it reads as membership,
  /// distinct from every light safety card around it, and never as a
  /// warning (red stays reserved for [dangerAction]).
  static const alrtPlusCardGradient = <Color>[
    Color(0xFF241A66),
    Color(0xFF3D2A9E),
    Color(0xFF6A3FD1),
  ];

  /// The crown on the ALRT+ card: cream -> gold, the only warm accent on
  /// that dark surface.
  static const alrtPlusCrown = ProfileRowAccent(
    Color(0xFFFFF3C4),
    Color(0xFFE9B949),
  );

  /// The tinted-icon accent for ALRT+ rows outside the card (the QA-only
  /// paywall preview row, the TEST chip).
  static const alrtPlusMembership = ProfileRowAccent(
    Color(0xFFF3E9FF),
    Color(0xFF6A3FD1),
  );

  static const helpAndFeedback = ProfileRowAccent(
    Color(0xFF9AA8B8),
    Color(0xFF5A6B7D),
  );

  /// Warm red reserved for genuinely important/destructive actions only
  /// (Delete Account) - never reused for a routine navigation row.
  static const dangerAction = Color(0xFFB3435A);
}
