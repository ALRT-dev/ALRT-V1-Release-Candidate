import 'package:flutter/material.dart';

class AppColors {
  static const primary = black;
  static const primaryLight = black54;

  static const transparent = Colors.transparent;

  static const white = Colors.white;

  static const black = Colors.black;
  static const black26 = Colors.black26;
  static const black38 = Colors.black38;
  static const black54 = Colors.black54;

  static const extraLightGrey = Color(0xFFf4f4f4);
  static const lightGrey = Color(0xFFD9D9D9);
  static const mediumGrey = Color(0xFF757575);
  static const grey = Color(0xff787676);

  static const shadowColor = Color(0x1A000000);
  static const shadowColorLight = Color(0x0D000000);
  static const shadowColorMedium = Color(0x1F000000);
  static const shadowColorDark = Color(0x33000000);

  static const extraLightblue = Color(0xFFEAF4FF);
  static const blue = Color(0xFF3478F5);
  static const darkBlue = Color(0xFF004ACE);
  static const yellow = Color(0xFFFCDD00);
  static const darkYellow = Color(0xFFD8B800);
  static const orange = Color(0xFFF26522);
  static const orange200 = Color(0xFFFF7E22);
  static const orange300 = Color(0xFFFF8C00); // locked header-gradient start (design-tokens.md)
  static const orange500 = Color(0xFFF97316);
  static const purple = Color(0xFF6A0DAD);
  static const pink = Color(0xFFE91E63);
  static const red = Color(0xFFEE2E24);
  static const red200 = Color(0xFFFF2020); // locked header-gradient end (design-tokens.md)
  static const red500 = Color(0xFFEF4444);
  static const darkRed = Color(0xFFFF0000);
  static const green = Color(0xFF34A853);
  static const darkGreen = Color(0xFF0B8043);
  static const brown = Color(0xFF8B4513);

  // Halos behind the floating capsules: the footer sits on purply blue,
  // the search bar on orange. Same shape, same treatment, different light.
  static const footerGlow = Color(0xFF6B6BE8);
  static const searchGlow = Color(0xFFFF6B01);

  // The locked band hexes (product rules, design system): Info #8A93A0,
  // Monitor #F5C518, Action #F07E1B, Critical #DA1F2D. These four aliases
  // are how severity is coloured everywhere: pins, clusters, cards, app
  // bars, filters and both keys. They used to point at the generic
  // yellow/orange/red above, which predate the locked palette, so the map
  // and the Map details legend disagreed about the same alert.
  static const info = Color(0xFF8A93A0);
  static const advice = Color(0xFFF5C518);
  static const watchAndAct = Color(0xFFF07E1B);
  static const emergency = Color(0xFFDA1F2D);
}
