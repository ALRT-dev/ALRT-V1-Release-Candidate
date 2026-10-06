import 'package:flutter/material.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_theme.dart';

/// Theme-aware surface/text colours for widgets that must look right in
/// both Light and Dark Appearance - currently the complete Profile screen
/// and the rest of the shared app chrome that isn't already dark by design
/// (the floating bottom nav pill is dark unconditionally, per the locked
/// design system, so it needs none of this).
///
/// Reuses the exact dark tones [AppTheme.darkPalette] itself is built
/// from (AppTheme.darkSurface etc.) rather than a second set of hex
/// values, so a card and the app bar it sits under can never drift out of
/// sync. Older screens keep using AppColors literals directly and are
/// unaffected by this - it is additive, not a replacement for AppColors.
extension AppSurfaceColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Card / sheet / bottom-sheet background.
  Color get surfaceCard =>
      isDarkMode ? AppTheme.darkSurface : AppColors.white;

  /// The page background beneath cards.
  Color get surfaceScaffold =>
      isDarkMode ? AppTheme.darkScaffold : AppColors.extraLightGrey;

  /// A subtly-raised neutral fill: count/text chips, icon-badge squares.
  Color get surfaceMuted =>
      isDarkMode ? AppTheme.darkSurfaceRaised : AppColors.extraLightGrey;

  /// Primary text and icon colour.
  Color get onSurface => isDarkMode ? AppTheme.darkTextPrimary : AppColors.black;

  /// Secondary text: subtitles, section labels, timestamps.
  Color get onSurfaceMuted =>
      isDarkMode ? AppTheme.darkTextSecondary : AppColors.grey;

  /// Chevrons, dividers, unselected borders.
  Color get outline => isDarkMode ? AppTheme.darkBorder : AppColors.lightGrey;

  /// Card drop shadow - a black shadow reads as a smudge on an already-
  /// dark card, so Dark mode uses a softer, more contained one.
  Color get cardShadow =>
      isDarkMode ? Colors.black.withValues(alpha: 0.35) : AppColors.shadowColorLight;
}
