import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';

/// The hazard badge that makes a feed row triageable in half a second.
///
/// Shape says which SYSTEM the alert came from (AWS triangle, official
/// diamond, community circle, ALRT shield), tint says which BAND it sits in.
/// A colour strip alone does not survive a fast scroll; a shape does.
///
/// Zero new assets: both the shapes and the band colours already exist in
/// the marker system, this just draws them together.
class HazardShapeBadge extends StatelessWidget {
  const HazardShapeBadge({
    super.key,
    required this.isAws,
    required this.isOfficial,
    required this.band,
    this.isGlobalHumanitarian = false,
    this.isAlrtIntel = false,
    this.size = 30,
  });

  /// Alerts carried by the Australian Warning System (triangle).
  final bool isAws;

  /// Alerts from a recognised agency (diamond). Community reports are
  /// neither, and take the circle.
  final bool isOfficial;

  /// Global humanitarian feeds (GDACS) take the rounded square.
  final bool isGlobalHumanitarian;

  /// ALRT's own assessment takes the shield, and outranks every other
  /// shape. It never writes the band word and never restates or overrides
  /// an official warning; it takes the same band hexes as everything else.
  final bool isAlrtIntel;

  /// The severity band, which supplies the tint and the glyph ink.
  final HazardSeverityBand? band;

  /// Outer square edge. 30 in the feed, 24 on the widget's alert state.
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = AlertCardStyle.bandShapeColor(band);
    // The glyph takes the band's dark stop, not the bright band hex, which
    // has too little contrast against its own wash.
    final ink = AlertCardStyle.bandDarkStop(band);

    return Container(
      width: size.spMin,
      height: size.spMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.spMin),
      ),
      child: Icon(
        AlertCardStyle.systemShapeIcon(
          isAws: isAws,
          isOfficial: isOfficial,
          isGlobalHumanitarian: isGlobalHumanitarian,
          isAlrtIntel: isAlrtIntel,
        ),
        size: (size * 17 / 30).spMin,
        color: ink,
      ),
    );
  }
}
