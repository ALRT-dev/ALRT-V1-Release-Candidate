import 'package:flutter/material.dart';

/// Colors used by the Family Mode feature.
///
/// Kept separate from [AppColors] so the family feature stays self-contained.
class FamilyColors {
  /// The family brand colour: the approved prototype's indigo accent
  /// (links, primary buttons, selected chips). Reinstated from the 28
  /// approved prototype boards, superseding the 8 Sep purple decision.
  static const indigo = v31Indigo;

  /// The deep end of the family gradient (the prototype's mid stop),
  /// also headings and selected segments.
  static const indigoDark = v31HeaderMid;

  /// A very light indigo used for chip and pill backgrounds.
  static const indigoLight = Color(0xFFECECFA);

  /// The green used for "Safe" chips and the "I'm Safe" button.
  static const safeGreen = Color(0xFF27AE60);

  /// The check-in button: the approved prototype's green gradient
  /// (#149A4A → #0B7A3B) with WHITE text and icons — the owner's decision
  /// of 8 September 2026 replaces the earlier dark-ink treatment. The top
  /// stop is nudged from #149A4A to #10843F so white measures 4.6:1 there
  /// and 5.4:1 at the deep end (WCAG AA is 4.5:1).
  static const safeBright = Color(0xFF10843F);
  static const safeBrightDeep = Color(0xFF0B7A3B);
  static const safeInk = Colors.white;

  /// A light green background for safe banners.
  static const safeGreenLight = Color(0xFFE7F6EE);

  /// Amber used for the "not everyone checked in" banner.
  static const amber = Color(0xFFB45309);

  /// A light amber background.
  static const amberLight = Color(0xFFFDF3E3);

  /// The dark red background of the SOS screen.
  static const sosDarkRed = Color(0xFF5C1010);

  /// The bright red used for SOS accents.
  static const sosRed = Color(0xFFDA1F2D);

  /// A light red background for SOS banners.
  static const sosRedLight = Color(0xFFFDECEC);

  // ── State colours (hub header, footer slot, member rings) ─────────────

  /// Teal for the "check-in asked of you" state — footer, header, member
  /// rings. Chosen over green so it reads as "awaiting" rather than "safe".
  static const teal = Color(0xFF0D9488);

  /// The deeper end of the teal gradient for the header band.
  static const tealDeep = Color(0xFF0F766E);

  /// The teal header gradient: bright teal at the top left falling through
  /// the deeper stop into a near-dark teal.
  static const tealHeaderGradient = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.6, 1),
    stops: [0.0, 0.55, 1.0],
    colors: [
      Color(0xFF0D9488),
      Color(0xFF0F766E),
      Color(0xFF0A5C53),
    ],
  );

  /// The SOS header gradient: the approved red band.
  static const sosHeaderGradient = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.6, 1),
    stops: [0.0, 0.55, 1.0],
    colors: [
      Color(0xFFC8102E),
      Color(0xFFA00D24),
      Color(0xFF7A0012),
    ],
  );

  // ── V3.1 prototype tokens ──────────────────────────────────────────────
  // Read straight off the approved prototype boards. The accent is the
  // reinstated indigo #3D3DDF from the 28 approved boards.

  /// The prototype's indigo accent: buttons, selected chips, links.
  static const v31Indigo = Color(0xFF3D3DDF);

  /// The light indigo page behind the cards (prototype body).
  static const v31Page = Color(0xFFEBEBF7);

  /// Section labels on family screens: a quiet grey uppercase, so labels
  /// never compete with the indigo and green. Darker than the prototype's
  /// #75757E, which measured 3.8:1 on the indigo page; this is 5.2:1
  /// there and 6.2:1 on white.
  static const v31Label = Color(0xFF625F6A);

  /// Body and secondary copy.
  static const v31Ink = Color(0xFF5F5C66);

  /// Hairline between rows inside a card (the prototype's card border).
  static const v31Divider = Color(0xFFE8E8F5);

  /// Unselected control borders (the prototype's outline button border).
  static const v31Border = Color(0xFFB0B0E0);

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
  /// blues. This is the single blend they all take: bright indigo at the
  /// top left falling through deep indigo into near-black.
  ///
  /// The approved prototype's band: #2E2A9E through #1E1780 at 45% to
  /// #120D4F.
  static const headerGradient = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.6, 1),
    stops: [0.0, 0.45, 1.0],
    colors: [
      Color(0xFF2E2A9E),
      Color(0xFF1E1780),
      Color(0xFF120D4F),
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
  static const v31HeaderTop = Color(0xFF2E2A9E);
  static const v31HeaderMid = Color(0xFF1E1780);
  static const v31HeaderDeep = Color(0xFF120D4F);

  /// The soft blob of light in the top-right of the header.
  static const v31HeaderGlow = Color(0xFF6B6BE8);

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
