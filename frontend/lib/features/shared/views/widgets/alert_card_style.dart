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
    if (isGlobalHumanitarian) return LucideIcons.square;
    if (isAws) return LucideIcons.triangleAlert;
    if (isOfficial) return LucideIcons.diamond;
    return LucideIcons.circle;
  }

  // ── Pre-coloured severity sets (shape-severity/, locked hexes) ─────────
  // Diamond/shield render at the band hex; the shield carries colour only —
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

  /// The "In plain terms" line.
  ///
  /// Locked rule (product owner, 2026-08-05): this states only WHAT HAS
  /// BEEN REPORTED and THAT the issuing agency is giving advice. ALRT does
  /// not write the advice, does not paraphrase it, and does not judge how
  /// dangerous something is. It used to say things like "Emergency services
  /// say act immediately" and "the air outside is bad enough to affect
  /// anyone" — words no agency actually said, attributed to them.
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
  }) {
    if (!isOfficial) return null;

    final trimmed = sourceName?.trim();
    final who = (trimmed != null && trimmed.isNotEmpty)
        ? trimmed
        : 'The issuing agency';

    // What the alert is ABOUT, in the alert's own facts: the hazard and
    // where it is. Never our words for what is happening or what to do.
    final what = (categoryName ?? '').trim().toLowerCase();
    final where = (locationName ?? '').trim();
    final subject = what.isEmpty
        ? 'this'
        : where.isEmpty
            ? 'a $what'
            : 'a $what near $where';

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
      return '$who has issued a $level for $subject. '
          'Their advice is in this alert.';
    }
    return '$who has reported $subject. Their advice is in this alert.';
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

  /// Official expanded-card header, coloured by severity — the top of the
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
