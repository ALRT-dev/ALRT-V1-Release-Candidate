import 'package:flutter/material.dart';

extension ColorExt on Color {
  /// Determines if the color is light based on its luminance.
  bool get isLight {
    if (this == Colors.transparent) {
      return true;
    }
    // A color is considered light if its luminance is greater than 0.4
    return computeLuminance() > 0.4;
  }

  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return hslDark.toColor();
  }
}
