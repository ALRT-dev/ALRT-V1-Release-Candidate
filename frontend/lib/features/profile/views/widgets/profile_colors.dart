import 'package:flutter/material.dart';

/// A row's icon-stroke gradient, per the approved Profile mockup: colour
/// lives on the icon only (via [ShaderMask]), never as a filled row
/// background - so the screen stays quiet next to the alert feed, where a
/// saturated fill already carries meaning.
class ProfileRowAccent {
  const ProfileRowAccent(this.start, this.end);

  final Color start;
  final Color end;

  List<Color> get colors => [start, end];
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

  static const familyAndCheckIns = ProfileRowAccent(
    Color(0xFF29C48D),
    Color(0xFF068257),
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

  static const alrtPlusMembership = ProfileRowAccent(
    Color(0xFFFF8A00),
    Color(0xFFF5000A),
  );

  static const helpAndFeedback = ProfileRowAccent(
    Color(0xFF9AA8B8),
    Color(0xFF5A6B7D),
  );

  /// Warm red reserved for genuinely important/destructive actions only
  /// (Delete Account) - never reused for a routine navigation row.
  static const dangerAction = Color(0xFFB3435A);
}
