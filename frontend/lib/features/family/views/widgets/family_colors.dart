import 'package:flutter/material.dart';

/// Colors used by the Family Mode feature.
///
/// Kept separate from [AppColors] so the family feature stays self-contained.
class FamilyColors {
  /// The family brand colour: the approved prototype's purple accent
  /// (links, primary buttons, selected chips). The name is historical;
  /// every Family surface reads this one value, so the whole feature
  /// follows the prototype's purple instead of the earlier indigo/blue.
  static const indigo = v31Indigo;

  /// The deep end of the family gradient (the prototype's mid stop),
  /// also headings and selected segments.
  static const indigoDark = v31HeaderMid;

  /// A very light lavender used for chip and pill backgrounds.
  static const indigoLight = Color(0xFFF0E9F6);

  /// The green used for "Safe" chips and the "I'm Safe" button.
  static const safeGreen = Color(0xFF27AE60);

  /// The approved mockup's bright I'm Safe gradient, drawn with DARK ink:
  /// safeInk on safeBright is 7.6:1 and on safeBrightDeep 5.7:1 (AA 4.5:1).
  /// White ink on any of the app's greens fails AA, which is why these
  /// buttons use dark text instead of darkening the button.
  static const safeBright = Color(0xFF4DE49C);
  static const safeBrightDeep = Color(0xFF22C887);
  static const safeInk = Color(0xFF103C2C);

  /// A light green background for safe banners.
  static const safeGreenLight = Color(0xFFE7F6EE);

  /// Amber used for the "not everyone checked in" banner.
  static const amber = Color(0xFFB45309);

  /// A light amber background.
  static const amberLight = Color(0xFFFDF3E3);

  /// The dark red background of the SOS screen.
  static const sosDarkRed = Color(0xFF5C1010);

  /// The bright red used for SOS accents.
  static const sosRed = Color(0xFFDC2626);

  /// A light red background for SOS banners.
  static const sosRedLight = Color(0xFFFDECEC);

  // ── V3.1 prototype tokens ──────────────────────────────────────────────
  // Read straight off the standalone prototype. The older indigo above is
  // a different, lighter blue, which is why family screens built against it
  // never matched the mocks.

  /// The prototype's purple accent: buttons, selected chips, links.
  static const v31Indigo = Color(0xFF7B3FA0);

  /// The lavender page behind the cards (prototype body).
  static const v31Page = Color(0xFFECE8F2);

  /// Section labels on family screens: the prototype's quiet grey
  /// uppercase, so labels never compete with the purple and green.
  static const v31Label = Color(0xFF75757E);

  /// Body and secondary copy.
  static const v31Ink = Color(0xFF5F5C66);

  /// Hairline between rows inside a card (the prototype's card border).
  static const v31Divider = Color(0xFFEDE8F2);

  /// Unselected control borders (the prototype's outline button border).
  static const v31Border = Color(0xFFCDB8E0);

  /// Toggle track when on, and when off.
  static const v31ToggleOn = Color(0xFF16C784);
  static const v31ToggleOff = Color(0xFFD8D4DE);

  /// The amber promise note: background, border, ink.
  static const v31NoteBackground = Color(0xFFFFF9EC);
  static const v31NoteBorder = Color(0xFFF5D98A);
  static const v31NoteInk = Color(0xFF8A6D1E);

  /// The family header, in one place.
  ///
  /// Every family surface used to build its own gradient, so the hub, the
  /// journey screen and the empty state were three slightly different
  /// blues. This is the single blend they all take: violet at the top
  /// left falling through indigo into the deep navy, warmer and more
  /// purple than the old stops, which read as flat corporate blue.
  ///
  /// The approved prototype's band: 160° from #4A1C7A through #42186C at
  /// 45% to #2A0E45, a deep red-purple rather than the indigo it replaced.
  static const headerGradient = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.6, 1),
    stops: [0.0, 0.45, 1.0],
    colors: [
      Color(0xFF4A1C7A),
      Color(0xFF42186C),
      Color(0xFF2A0E45),
    ],
  );

  /// The soft highlight that sits over [headerGradient] top-right, so the
  /// band has a light source instead of looking like a flat fill.
  static const headerHighlight = RadialGradient(
    center: Alignment(0.75, -0.85),
    radius: 1.1,
    colors: [Color(0x40FFFFFF), Color(0x00FFFFFF)],
  );

  /// The three stops of the family header gradient (the prototype's band).
  static const v31HeaderTop = Color(0xFF4A1C7A);
  static const v31HeaderMid = Color(0xFF42186C);
  static const v31HeaderDeep = Color(0xFF2A0E45);

  /// The soft blob of light in the top-right of the header.
  static const v31HeaderGlow = Color(0xFF9C6BCF);

  /// Card shadow on the lavender page.
  static const v31CardShadow = Color(0x0D1E142D);

  /// The palette used to derive a stable per-member avatar color.
  ///
  /// Neutral/purple family only, on purpose: green is reserved for the
  /// "safe" status dot ([safeGreen]) and red for SOS ([sosRed]) elsewhere
  /// on this same avatar, so a member's identity colour can never be
  /// mistaken for either state.
  static const memberPalette = <Color>[
    Color(0xFF5238DE), // indigo-violet
    Color(0xFF8E44AD), // purple
    Color(0xFF6C7A94), // slate
    Color(0xFF7A4BF5), // violet
    Color(0xFF4A5568), // charcoal
    Color(0xFF9C6ADE), // lavender
  ];

  /// Derives a stable color for a member from their [memberId].
  ///
  /// Uses a deterministic hash over the id's code units so the same member
  /// always gets the same color, across sessions and devices.
  /// A group's chosen beacon colour from its stored hex, falling back to
  /// the family indigo so an unthemed group still looks deliberate.
  static Color beaconOf(final String? hex) {
    final trimmed = hex?.trim();
    if (trimmed == null || trimmed.isEmpty) return indigo;
    final cleaned = trimmed.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return indigo;
    return Color(cleaned.length <= 6 ? value | 0xFF000000 : value);
  }

  static Color memberColor(final String memberId) {
    var hash = 0;
    for (final unit in memberId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return memberPalette[hash % memberPalette.length];
  }
}
