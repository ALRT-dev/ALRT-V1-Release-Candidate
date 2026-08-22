import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The locked band hexes, pinned.
///
/// The map, the cards and the two keys used to disagree because severity
/// colours were defined in more than one place. There is now one set, in
/// AppColors, and this test is what stops a second set growing back.
void main() {
  const info = Color(0xFF8A93A0);
  const monitor = Color(0xFFF5C518);
  const action = Color(0xFFF07E1B);
  const critical = Color(0xFFDA1F2D);

  group('locked band hexes', () {
    test('the AppColors aliases are the locked palette', () {
      expect(AppColors.info, info);
      expect(AppColors.advice, monitor);
      expect(AppColors.watchAndAct, action);
      expect(AppColors.emergency, critical);
    });

    test('the card style reads the same palette, not a copy', () {
      expect(AlertCardStyle.bandInfo, AppColors.info);
      expect(AlertCardStyle.bandMonitor, AppColors.advice);
      expect(AlertCardStyle.bandAction, AppColors.watchAndAct);
      expect(AlertCardStyle.bandCritical, AppColors.emergency);
    });

    test('non-AWS bands wear the locked hexes, info included', () {
      expect(HazardSeverityBand.info.colorNonAws, info);
      expect(HazardSeverityBand.monitor.colorNonAws, monitor);
      expect(HazardSeverityBand.action.colorNonAws, action);
      expect(HazardSeverityBand.critical.colorNonAws, critical);
    });

    test('AWS bands wear the locked hexes, lowest is Advice yellow', () {
      // AWS has no grey level: its quietest word is Advice.
      expect(HazardSeverityBand.info.colorAws, monitor);
      expect(HazardSeverityBand.monitor.colorAws, monitor);
      expect(HazardSeverityBand.action.colorAws, action);
      expect(HazardSeverityBand.critical.colorAws, critical);
    });

    test('severity words match their bands', () {
      expect(HazardSeverity.advice.colorAws, monitor);
      expect(HazardSeverity.watchAndAct.colorAws, action);
      expect(HazardSeverity.emergency.colorAws, critical);
      expect(HazardSeverity.info.colorNonAws, info);
      // AWS has no grey: info under AWS is Advice yellow, matching the
      // band enum, so one alert is never coloured two ways.
      expect(HazardSeverity.info.colorAws, monitor);
    });

    test('expanded-card headers start on the locked hexes', () {
      LinearGradient headerFor(final HazardSeverityBand band) =>
          AlertCardStyle.officialHeaderGradientFor(isAws: false, band: band);

      expect(headerFor(HazardSeverityBand.critical).colors.first, critical);
      expect(headerFor(HazardSeverityBand.action).colors.first, action);
      expect(headerFor(HazardSeverityBand.monitor).colors.first, monitor);
      expect(headerFor(HazardSeverityBand.info).colors.first, info);
    });
  });
}
