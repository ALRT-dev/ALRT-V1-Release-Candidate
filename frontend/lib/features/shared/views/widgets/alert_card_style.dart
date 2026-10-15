import 'package:flutter/material.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The locked alert-card treatments (product-rules §6/§31):
///
/// - SOLID red fill (gradient, white type, glow) = official CRITICAL only.
/// - DASHED red outline on white (no glow) = official needs-attention (ACTION).
/// - Community reports are never red-treated and always read UNVERIFIED.
/// - Severity is shown by shape as well as colour, never colour alone.
abstract final class AlertCardStyle {
  /// Solid red: official CRITICAL only.
  static const solidRedGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF5247), Color(0xFFB80000)],
  );

  /// Outer glow that accompanies the solid red treatment.
  static BoxShadow get criticalGlow => BoxShadow(
        color: const Color(0xFFE01B0F).withValues(alpha: 0.45),
        blurRadius: 18,
        offset: const Offset(0, 4),
      );

  /// Dashed needs-attention outline.
  static const dashedBorderColor = Color(0xFFE5928D);

  /// Dashed needs-attention type colour.
  static const dashedTextColor = Color(0xFFCC1010);

  /// The source-system shape (V3 alert rendering spec): shape says WHICH
  /// SYSTEM an alert came from, colour says how urgent it is.
  ///
  /// The five shapes, in the order they win:
  /// - ALRT Intel shield: ALRT's own assessment, the only shape carrying
  ///   ALRT's voice. It never restates or overrides an official warning.
  /// - Global humanitarian rounded square: GDACS-style events rated for
  ///   international response (may be retired later).
  /// - AWS triangle: the only system that writes a level word.
  /// - Official diamond: state agencies and services.
  /// - Community circle: an unverified report from someone nearby.
  static IconData systemShapeIcon({
    required final bool isAws,
    required final bool isOfficial,
    final bool isGlobalHumanitarian = false,
    final bool isAlrtIntel = false,
  }) {
    if (isAlrtIntel) return LucideIcons.shield;
    if (isGlobalHumanitarian) return LucideIcons.diamond;
    if (isAws) return LucideIcons.triangleAlert;
    if (isOfficial) return LucideIcons.diamond;
    return LucideIcons.circle;
  }

  // ── Pre-coloured severity sets (shape-severity/, locked hexes) ─────────
  // Diamond/shield render at the band hex; the shield carries colour only -
  // the band word is never written next to it. Community circles take the
  // category colour instead, never a band hex.

  // One definition: AppColors carries the locked hexes, and everything
  // severity-coloured (pins, clusters, cards, filters, both keys) reads
  // them from there. These names stay for the call sites that use them.
  static const bandInfo = AppColors.info;
  static const bandMonitor = AppColors.advice;
  static const bandAction = AppColors.watchAndAct;
  static const bandCritical = AppColors.emergency;

  /// The shield colour for a severity band.
  ///
  /// The shield used to carry its own brighter hexes from the icon sheet,
  /// which meant an ALRT Intel shield and an official diamond at the same
  /// urgency were two different oranges. There is one colour system: the
  /// shape says which system sent it, the band hex says how urgent it is,
  /// and the shield obeys the same hexes as every other shape. It still
  /// never writes the band word next to it.
  static Color shieldColor(final HazardSeverityBand? band) =>
      bandShapeColor(band);

  /// The locked hex for an official severity shape.
  static Color bandShapeColor(final HazardSeverityBand? band) {
    return switch (band) {
      HazardSeverityBand.monitor => bandMonitor,
      HazardSeverityBand.action => bandAction,
      HazardSeverityBand.critical => bandCritical,
      HazardSeverityBand.info || null => bandInfo,
    };
  }

  /// "8.4 km", "820 m", "3,274 km": tenths only under 100 km, so a far
  /// alert's distance fits beside the source name on the compact card
  /// ("3273.5 km a..." was cut off, phone review 15 Oct 2026).
  static String distanceLabel(final double metres) {
    if (metres < 1000) return '${metres.toStringAsFixed(0)} m';
    final km = metres / 1000;
    if (km < 100) return '${km.toStringAsFixed(1)} km';
    final whole = km.round().toString();
    final grouped = whole.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$grouped km';
  }

  /// The source's facts as clean lines for WHAT WE KNOW and the compact
  /// card. Feeds hand us raw fields ("ALERT LEVEL: Not Applicable",
  /// "LOCATION: BRICKWORKS PLANT, WALLGROVE RD", "Coordinates: -21.9,
  /// 148.0", "Main Category: CHANGED TRAFFIC CONDITIONS" after a line that
  /// already said it). This keeps the source's facts and words, and only:
  /// drops empty values ("Not Applicable", "Unknown"), machine fields
  /// (coordinates, timestamps the card already shows), lines that just
  /// repeat the title or an earlier line; and brings shouted capitals back
  /// to normal case. It never adds a fact (phone review, 15 Oct 2026).
  static List<String> factLines(final String? description, {final String? title}) {
    final raw = (description ?? '').split(RegExp(r'\r?\n'));
    final titleLower = (title ?? '').toLowerCase();
    final out = <String>[];
    final seen = <String>[];
    for (var line in raw) {
      line = line.replaceFirst(RegExp(r'^\s*[•\-\*·]+\s*'), '').trim();
      if (line.isEmpty) continue;

      String? key;
      String value = line;
      final m = RegExp(r'^([A-Za-z][A-Za-z /&()]{1,40}):\s*(.*)$').firstMatch(line);
      if (m != null) {
        key = m.group(1)!.trim();
        value = m.group(2)!.trim();
      }
      final keyLower = key?.toLowerCase() ?? '';
      final valueLower = value.toLowerCase();

      if (value.isEmpty || _emptyValues.contains(valueLower)) continue;
      if (_machineKeys.contains(keyLower)) continue;
      // Repeats the title ("Wandandian Expo", "Incident Type: Road Crash"
      // under "Road Crash - Warwick").
      if (titleLower.isNotEmpty &&
          valueLower.length >= 4 &&
          titleLower.contains(valueLower)) {
        continue;
      }
      // Repeats an earlier line. Short values ("2", "Yes") are left alone:
      // they turn up inside unrelated lines ("M2", "2 lanes").
      if (valueLower.length >= 4 && seen.any((e) => e.contains(valueLower))) {
        continue;
      }
      seen.add(line.toLowerCase());

      final calmValue = _calmShouted(value);
      out.add(key == null ? calmValue : '${_sentenceCaseKey(key)}: $calmValue');
    }
    return out;
  }

  static const _emptyValues = {
    'not applicable', 'n/a', 'na', 'unknown', 'none', 'null', '-', 'tbc',
    'not specified', 'not available',
  };

  static const _machineKeys = {
    'coordinates', 'coordinate', 'lat', 'lon', 'lng', 'latitude',
    'longitude', 'last updated', 'updated', 'published', 'id', 'uid',
    'station time', 'measured',
  };

  static const _keepUpper = {
    'NSW', 'WA', 'QLD', 'VIC', 'SA', 'NT', 'ACT', 'TAS', 'AQI', 'UV',
    'PM2.5', 'PM10', 'CBD', 'M1', 'M2', 'M4', 'M5', 'M7', 'M31', 'SES',
    'RFS', 'DFES', 'BOM', 'AWS', 'LGA', 'UK', 'US', 'NZ',
  };

  /// "ALERT LEVEL" -> "Alert level"; "Incident Kind" -> "Incident kind".
  static String _sentenceCaseKey(final String key) {
    final words = key.split(RegExp(r'\s+'));
    return [
      for (var i = 0; i < words.length; i++)
        _keepUpper.contains(words[i].toUpperCase()) && words[i].length <= 4
            ? words[i].toUpperCase()
            : i == 0
                ? words[i][0].toUpperCase() + words[i].substring(1).toLowerCase()
                : words[i].toLowerCase(),
    ].join(' ');
  }

  /// Brings runs of shouted words back to normal case: a fully shouted
  /// value becomes Title Case ("BRICKWORKS PLANT, WALLGROVE RD" ->
  /// "Brickworks Plant, Wallgrove Rd"); a shouted lead-in before ordinary
  /// words becomes a label ("CHANGED TRAFFIC CONDITIONS Oversize vehicle"
  /// -> "Changed traffic conditions: Oversize vehicle").
  static String _calmShouted(final String value) {
    String core(final String w) => w.replaceAll(RegExp(r'[^A-Za-z0-9.]'), '');
    bool acronym(final String w) => _keepUpper.contains(core(w).toUpperCase());
    // Known acronyms ("NSW RFS reports") are not shouting.
    bool shouted(final String w) =>
        RegExp(r'[A-Z]').hasMatch(w) &&
        w == w.toUpperCase() &&
        w.length > 1 &&
        !acronym(w);
    final words = value.split(' ');
    final shoutedCount = words.where(shouted).length;
    if (shoutedCount < 2) return value;

    String titleWord(final String w) {
      if (acronym(w)) return w;
      final lower = w.toLowerCase();
      final i = lower.indexOf(RegExp(r'[a-z]'));
      if (i < 0) return w;
      return lower.substring(0, i) + lower[i].toUpperCase() + lower.substring(i + 1);
    }

    if (words.every((w) => !RegExp(r'[a-z]').hasMatch(w))) {
      return words.map(titleWord).join(' ');
    }
    // Shouted lead-in followed by normal words.
    var n = 0;
    while (n < words.length && !RegExp(r'[a-z]').hasMatch(words[n])) {
      n++;
    }
    if (words.take(n).where(shouted).length >= 2 && n < words.length) {
      final lead = words
          .take(n)
          .map((w) => acronym(w) ? w : w.toLowerCase())
          .join(' ');
      final rest = words.skip(n).join(' ');
      // A label only when the rest starts a new phrase ("CHANGED TRAFFIC
      // CONDITIONS Oversize vehicle"); "ROAD CLOSED due to flooding" reads
      // on as one sentence.
      final joiner = RegExp(r'^[A-Z0-9]').hasMatch(rest) ? ': ' : ' ';
      return '${lead[0].toUpperCase()}${lead.substring(1)}$joiner$rest';
    }
    return value;
  }

  /// The agency's own instructions from an alert, without the generic
  /// filler older TEST records carry ("If you are near the area, be ready
  /// to follow ... instructions"). That line was written by the old
  /// pipeline, not the agency, so it is never shown under WHAT TO DO and
  /// never counts as published advice (phone review, 14 Oct 2026).
  static List<String> agencyActions(final List<String>? callsToAction) {
    if (callsToAction == null) return const [];
    final filler = RegExp(
      r'^\s*(if you are (near|in|around) (the|this) area,?\s*)?be ready to follow\b.*instructions\.?\s*$',
      caseSensitive: false,
    );
    return [
      for (final a in callsToAction)
        if (a.trim().isNotEmpty && !filler.hasMatch(a)) a,
    ];
  }

  /// Whether any of [callsToAction] is the AGENCY's advice. ALRT's own
  /// labelled suggestions ("ALRT suggests: ...") and the general health
  /// close are not, so "In plain terms" must not say "Their advice is in
  /// this alert" for them (WAQI publishes no advice at all).
  static bool hasAgencyAdvice(final List<String>? callsToAction) {
    final alrtOwn = RegExp(
      r'^\s*(alrt suggests|this is general information|this information is general)',
      caseSensitive: false,
    );
    return agencyActions(callsToAction).any((a) => !alrtOwn.hasMatch(a));
  }

  /// The "In plain terms" line.
  ///
  /// Locked rule (product owner, 2026-08-05): this states only WHAT HAS
  /// BEEN REPORTED and THAT the issuing agency is giving advice. ALRT does
  /// not write the advice, does not paraphrase it, and does not judge how
  /// dangerous something is. It used to say things like "Emergency services
  /// say act immediately" and "the air outside is bad enough to affect
  /// anyone" - words no agency actually said, attributed to them.
  ///
  /// Only AWS alerts carry a level word, and only because the source
  /// publishes that word itself; every other source is described without
  /// one. Community reports get no line at all.
  static String? plainTermsOf({
    required final bool isOfficial,
    required final bool isAws,
    final HazardSeverity? severity,
    final HazardSeverityBand? band,
    final String? categoryName,
    final String? sourceName,
    final String? locationName,
    final String? title,
    final bool? hasAdvice,
  }) {
    if (!isOfficial) return null;

    final trimmed = sourceName?.trim();
    final who = (trimmed != null && trimmed.isNotEmpty)
        ? trimmed
        : 'The issuing agency';

    // What the alert is ABOUT, in the alert's own facts: the hazard and
    // where it is. Never our words for what is happening or what to do.
    // "Other" is a bucket, not a thing an agency reports, so it reads as
    // "an alert". Everything else takes the article its first sound needs
    // ("an outage", "a bushfire"). A place name the source shouted in
    // capitals is brought back to title case; it is not our emphasis.
    final rawWhat = (categoryName ?? '').trim().toLowerCase();
    // A broad bucket name ("Other", "Security & Crime") is not a thing that
    // happened. The agency's own title usually names it ("Active Alarm in
    // Metro Central", "Police operation in Northbridge"), so those words
    // are used; only with no usable title does it read as "an alert" or
    // "a security and crime alert" (phone review, 14 Oct 2026).
    final isBucket = rawWhat.isEmpty || rawWhat == 'other' || rawWhat.contains('&');
    final titleHazard = isBucket ? _hazardFromTitle(title) : null;
    final what = titleHazard ??
        (rawWhat == 'other'
            ? 'alert'
            : rawWhat.contains('&')
                ? '${rawWhat.replaceAll('&', 'and').replaceAll(RegExp(r'\s+'), ' ')} alert'
                : rawWhat);
    // The place: the agency's own title names it ("Vehicle Fire at Salter
    // Point", "Road Crash – Warwick") far better than the feed's region
    // code ("METRO SOUTH EAST"), so the title's place wins when it has one.
    final fromTitle = _placeAndPreposition(title);
    final where = fromTitle?.$2 ?? _calmCase((locationName ?? '').trim());
    // Keep the agency's own word: "at Salter Point", "in Northbridge".
    final preposition = fromTitle?.$1 ?? 'near';
    final article = what.isEmpty
        ? ''
        : 'aeiou'.contains(what[0])
            ? 'an'
            : 'a';
    final subject = what.isEmpty
        ? 'this'
        : where.isEmpty
            ? '$article $what'
            : '$article $what $preposition $where';

    // Never promise advice that is not there: when the agency published
    // none, say so, matching the What to do section below it.
    final adviceLine = hasAdvice == false
        ? 'They have not published advice yet.'
        : 'Their advice is in this alert.';

    // The source's own level word, verbatim, never reworded. Only AWS
    // publishes one.
    final level = isAws
        ? switch (severity) {
            HazardSeverity.emergency => 'Emergency Warning',
            HazardSeverity.watchAndAct => 'Watch and Act',
            HazardSeverity.advice => 'Advice',
            _ => null,
          }
        : null;

    if (level != null) {
      return '$who has issued a $level for $subject. $adviceLine';
    }
    return '$who has reported $subject. $adviceLine';
  }

  /// The place named at the end of an agency title, as in "Vehicle Fire at
  /// Salter Point" or "Grass fire near Gingin", or null when the title has
  /// no such phrase. Shouted titles are brought back to title case.
  static String? placeFromTitle(final String? title) =>
      _placeAndPreposition(title)?.$2;

  /// Splits a "Hazard – Place" title (DFES writes "Road Crash – Warwick",
  /// "Bushfire – Dandaragan") into its two halves, or null.
  static (String, String)? _dashParts(final String? title) {
    final t = title?.trim();
    if (t == null || t.isEmpty) return null;
    final m = RegExp(r'^(.+?)\s+[\u2013\u2014-]\s+(.+)$').firstMatch(t);
    if (m == null) return null;
    return (m.group(1)!.trim(), m.group(2)!.trim());
  }

  /// The hazard words of an agency title, lower-cased ("active alarm",
  /// "road crash", "police operation"), or null when the title has no
  /// place phrase to split it at.
  static String? _hazardFromTitle(final String? title) {
    final t = title?.trim();
    if (t == null || t.isEmpty) return null;
    String? hazard;
    final dash = _dashParts(t);
    if (dash != null) {
      hazard = dash.$1;
    } else {
      final lower = t.toLowerCase();
      var cut = -1;
      for (final candidate in const [' at ', ' near ', ' in ']) {
        final i = lower.lastIndexOf(candidate);
        if (i > cut) cut = i;
      }
      if (cut > 0) hazard = t.substring(0, cut);
    }
    hazard = hazard?.trim();
    if (hazard == null ||
        hazard.isEmpty ||
        hazard.length > 40 ||
        !RegExp(r"^[A-Za-z][A-Za-z' /-]*$").hasMatch(hazard)) {
      return null;
    }
    return hazard.toLowerCase();
  }

  /// The title's place with the word the agency put before it.
  static (String, String)? _placeAndPreposition(final String? title) {
    final t = title?.trim();
    if (t == null || t.isEmpty) return null;
    // "Road Crash – Warwick": the place is everything after the dash.
    final dash = _dashParts(t);
    if (dash != null) {
      final place = dash.$2;
      if (place.length <= 40 &&
          RegExp(r"^[A-Za-z][A-Za-z' .,-]*$").hasMatch(place)) {
        return ('in', _calmCase(place));
      }
    }
    final lower = t.toLowerCase();
    // The LAST " at " / " near " / " in " wins, so "Burn-off in progress
    // at Gingin" gives Gingin, not "progress at Gingin".
    var cut = -1;
    var word = '';
    for (final candidate in const [' at ', ' near ', ' in ']) {
      final i = lower.lastIndexOf(candidate);
      if (i > cut) {
        cut = i;
        word = candidate;
      }
    }
    if (cut < 0) return null;
    final place = t.substring(cut + word.length).trim();
    // A place name, not the rest of a sentence.
    if (place.isEmpty ||
        place.length > 40 ||
        !RegExp(r"^[A-Za-z][A-Za-z' .,-]*$").hasMatch(place)) {
      return null;
    }
    return (word.trim(), _calmCase(place));
  }

  /// Title-cases a string only when it is entirely upper case (a shouted
  /// feed value such as "METRO SOUTH EAST"); mixed-case input is returned
  /// untouched so a deliberate spelling like "McLaren Vale" survives.
  static String _calmCase(final String value) {
    if (value.isEmpty || value != value.toUpperCase()) return value;
    if (value == value.toLowerCase()) return value;
    return value
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0] + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  // ── V3 expanded-card treatments (alert detail screen) ──────────────────

  /// Official (AWS and non-AWS) expanded-card header band.
  ///
  /// Anchored on the locked Action hex, like the pin and the key. The old
  /// start (#FF8C00) was the header-gradient orange, so an Action alert's
  /// expanded card was a different orange from its own pin.
  static const officialHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.watchAndAct, Color(0xFFB8560E)],
  );

  /// Official expanded-card header, coloured by severity - the top of the
  /// alert must designate the level: Advice/MONITOR yellow, Watch and
  /// Act/ACTION orange, Emergency/CRITICAL red, info grey.
  static LinearGradient officialHeaderGradientFor({
    required final bool isAws,
    final HazardSeverity? severity,
    final HazardSeverityBand? band,
  }) {
    final bool isCriticalTier = isAws
        ? severity == HazardSeverity.emergency
        : band == HazardSeverityBand.critical;
    final bool isActionTier = isAws
        ? severity == HazardSeverity.watchAndAct
        : band == HazardSeverityBand.action;
    final bool isMonitorTier = isAws
        ? severity == HazardSeverity.advice
        : band == HazardSeverityBand.monitor;

    // Every gradient starts on the band's own locked hex (AppColors, the
    // single definition) and falls to its dark stop. Re-typing the hexes
    // here is how a second palette grows back.
    if (isCriticalTier) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.emergency, Color(0xFF9E1520)],
      );
    }
    if (isActionTier) return officialHeaderGradient;
    if (isMonitorTier) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.advice, Color(0xFFDCA900)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.info, Color(0xFF6E7683)],
    );
  }

  /// The dark stop of each band's gradient.
  ///
  /// Shape glyphs and text drawn on a band TINT use this rather than the
  /// bright band hex, which has too little contrast against its own 12%
  /// wash to stay legible.
  static Color bandDarkStop(final HazardSeverityBand? band) {
    return switch (band) {
      HazardSeverityBand.critical => const Color(0xFF9E1520),
      HazardSeverityBand.action => const Color(0xFFB8560E),
      HazardSeverityBand.monitor => const Color(0xFF8A6D00),
      HazardSeverityBand.info || null => const Color(0xFF5A6270),
    };
  }

  /// The dark "In plain terms" surface (cards and the expanded alert).
  static const plainTermsBackground = Color(0xFF23252B);

  /// The bold "In plain terms" lead on the dark surface (approved Feed and
  /// Detail boards, 12 Oct 2026). No colon follows it.
  static const plainTermsLeadInk = Color(0xFFF2A67C);

  // ── Approved Feed/Detail card chrome (12 Oct 2026 boards) ──────────────

  /// Card corner radius, feed card and detail header alike.
  static const cardRadius = 18.0;

  /// The one quiet card shadow: 0 1 3 at 6% black.
  static const cardShadow = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 3,
    offset: Offset(0, 1),
  );

  /// Band-strip height on the feed card (official and AWS only).
  static const feedBandStripHeight = 5.0;

  /// Band-strip height on the detail header (official and AWS only).
  static const detailBandStripHeight = 6.0;

  /// Row-1 label inks, dark enough to read as text on white where the
  /// band hexes themselves are not.
  static const labelInkCritical = Color(0xFFB3141F);
  static const labelInkAction = Color(0xFF9A4A00);
  static const labelInkMonitor = Color(0xFF6B5400);

  /// OFFICIAL and ALRT ASSESSMENT label ink.
  static const labelInkNeutral = Color(0xFF3A3A42);

  /// COMMUNITY · UNVERIFIED label ink (the V3 label orange).
  static const labelInkCommunity = Color(0xFFB84500);

  /// Secondary meta text: "ago", source line, distance.
  static const metaInk = Color(0xFF5C5C66);

  /// The label ink for an AWS band word, by band.
  static Color bandLabelInk(final HazardSeverityBand? band) {
    return switch (band) {
      HazardSeverityBand.critical => labelInkCritical,
      HazardSeverityBand.action => labelInkAction,
      HazardSeverityBand.monitor => labelInkMonitor,
      HazardSeverityBand.info || null => labelInkNeutral,
    };
  }

  /// Community/user-report expanded-card header band.
  static const communityHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5AB0FF), Color(0xFF3A90E5)],
  );

  /// AWS severity-level pill (the ONLY system whose pill shows a level word).
  static const awsLevelPillBackground = Color(0xFFFFF6EF);
  static const awsLevelPillForeground = Color(0xFFB84500);
  static const awsLevelPillBorder = Color(0xFFFF6B01);

  /// Official non-AWS category pill (never a band/severity word).
  static const officialCategoryPillBackground = Color(0xFFE8FBF5);
  static const officialCategoryPillForeground = Color(0xFF146C43);
  static const officialCategoryPillBorder = Color(0xFF007A56);

  /// Community category pill (never a severity word).
  static const communityCategoryPillBackground = Color(0xFFE8F4FF);
  static const communityCategoryPillForeground = Color(0xFF1565B5);

  /// "Live · updated N ago" pill.
  static const livePillBackground = Color(0xFFE4F7EE);
  static const livePillForeground = Color(0xFF146C43);

  /// "In plain terms:" summary box tints.
  static const officialSummaryBackground = Color(0xFFFFF9F4);
  static const communitySummaryBackground = Color(0xFFF4F9FF);

  /// V3 section-header ink ("What we know" / "What to do").
  static const officialSectionHeaderColor = Color(0xFFB84500);
  static const communitySectionHeaderColor = Color(0xFF1565B5);

  /// V3 body copy colour.
  static const summaryTextColor = Color(0xFF44414C);
}

/// Paints a dashed rounded-rect outline (Flutter has no built-in dashed
/// border). Used for the official needs-attention card treatment.
class DashedRRectPainter extends CustomPainter {
  const DashedRRectPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.4,
    this.dashLength = 5,
    this.gapLength = 4,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRRectPainter oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      strokeWidth != oldDelegate.strokeWidth;
}
