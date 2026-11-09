import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

// Owner, 9 November 2026: an AWS warning always states its level.
void main() {
  test('uses the extracted label first', () {
    const hazard = Hazard(
      isAwsCompliant: true,
      nativeWarningLevel: 'Advice',
      contentDetails: {'nativeLevel': 'Watch and Act'},
    );
    expect(hazard.displayWarningLevel, 'Watch and Act');
  });

  test('falls back to the record label when extraction left it empty', () {
    const hazard = Hazard(
      isAwsCompliant: true,
      nativeWarningLevel: 'Emergency Warning',
      contentDetails: {'nativeLevel': null},
    );
    expect(hazard.displayWarningLevel, 'Emergency Warning');
  });

  test('an AWS alert with no label still states the level of its band', () {
    expect(
      const Hazard(
        isAwsCompliant: true,
        severityBand: HazardSeverityBand.critical,
      ).displayWarningLevel,
      'Emergency Warning',
    );
    expect(
      const Hazard(
        isAwsCompliant: true,
        severityBand: HazardSeverityBand.action,
      ).displayWarningLevel,
      'Watch and Act',
    );
    expect(
      const Hazard(
        isAwsCompliant: true,
        severityBand: HazardSeverityBand.info,
      ).displayWarningLevel,
      'Advice',
    );
  });

  test('a non-AWS alert never gets an invented level', () {
    expect(
      const Hazard(severityBand: HazardSeverityBand.critical)
          .displayWarningLevel,
      isNull,
    );
  });
}
