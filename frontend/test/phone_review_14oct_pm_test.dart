import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/profile/models/for_you_library.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';

/// Phone review, 14 Oct 2026 (afternoon): prompts on the alert detail.
void main() {
  group('For You never borrows another hazard', () {
    String? bucket(final String? category, final String? title) =>
        ForYouLibrary.bucketFor(categoryName: category, title: title);

    test('a gas smell under Utilities shows no outage lines', () {
      expect(bucket('Utilities & Infrastructure', 'Smell of gas'), isNull);
      expect(bucket('Utilities', 'Smell of gas - Scarborough, WA'), isNull);
    });

    test('a gas leak never gets the shelter-indoors chemical lines', () {
      expect(bucket('Chemical', 'Gas leak in Osborne Park'), isNull);
    });

    test('a burst water main shows nothing', () {
      expect(bucket('Utilities', 'Burst water main'), isNull);
    });

    test('a power outage still gets outage lines', () {
      expect(bucket('Utilities', 'Power outage'), 'utility_outage');
      expect(bucket('Power Outage', null), 'utility_outage');
    });

    test('bundled lines are hedged, never "advisable" or "a good idea"', () {
      for (final rows in ForYouLibrary.rows.values) {
        for (final line in rows.values) {
          expect(line.contains('advisable'), isFalse, reason: line);
          expect(line.contains('good idea'), isFalse, reason: line);
        }
      }
    });
  });

  group('What to do shows only the agency', () {
    test('old pipeline filler is not advice', () {
      expect(
        AlertCardStyle.agencyActions([
          'If you are near the area, be ready to follow Department of Fire '
              'and Emergency Services WA instructions.',
        ]),
        isEmpty,
      );
    });

    test('real agency instructions survive', () {
      const real = 'Avoid the area and follow directions from emergency services.';
      expect(AlertCardStyle.agencyActions([real]), [real]);
    });
  });

  group('plain terms reads the agency title', () {
    test('dash titles name the place, not the region code', () {
      final line = AlertCardStyle.plainTermsOf(
        isOfficial: true,
        isAws: false,
        categoryName: 'Crash',
        sourceName: 'Department of Fire and Emergency Services WA',
        locationName: 'METRO NORTH COASTAL',
        title: 'Road Crash – Warwick',
        hasAdvice: false,
      );
      expect(
        line,
        'Department of Fire and Emergency Services WA has reported a crash '
        'in Warwick. They have not published advice yet.',
      );
    });

    test('a bucket category takes the hazard words from the title', () {
      final line = AlertCardStyle.plainTermsOf(
        isOfficial: true,
        isAws: false,
        categoryName: 'Other',
        sourceName: 'DFES',
        locationName: 'METRO CENTRAL',
        title: 'Active Alarm in Metro Central, Perth',
        hasAdvice: false,
      );
      expect(
        line,
        'DFES has reported an active alarm in Metro Central, Perth. '
        'They have not published advice yet.',
      );
    });
  });

  group('facts are the source facts, cleaned', () {
    test('drops Not Applicable, calms shouted values', () {
      expect(
        AlertCardStyle.factLines(
          'ALERT LEVEL: Not Applicable\nLOCATION: BRICKWORKS PLANT, WALLGROVE RD, EASTERN CREEK',
          title: 'Fire alarm at Brickworks Plant, Wallgrove Rd',
        ),
        ['Location: Brickworks Plant, Wallgrove Rd, Eastern Creek'],
      );
    });

    test('drops coordinates and lines that repeat the title or each other', () {
      expect(
        AlertCardStyle.factLines(
          '• CHANGED TRAFFIC CONDITIONS Oversize vehicle\n'
          '• Incident Kind: Planned\n'
          '• Main Category: CHANGED TRAFFIC CONDITIONS\n'
          '• Coordinates: -21.9, 148.0',
          title: 'Oversize vehicle',
        ),
        [
          'Changed traffic conditions: Oversize vehicle',
          'Incident kind: Planned',
        ],
      );
      expect(
        AlertCardStyle.factLines(
          'Incident Type: Road Crash\nLocation: Wanneroo',
          title: 'Road Crash – Wanneroo',
        ),
        isEmpty,
      );
    });

    test('far distances fit on the card', () {
      expect(AlertCardStyle.distanceLabel(3273500), '3,274 km');
      expect(AlertCardStyle.distanceLabel(14200), '14.2 km');
      expect(AlertCardStyle.distanceLabel(459), '459 m');
    });

    test('ALRT suggestions are not the agency advice', () {
      expect(
        AlertCardStyle.hasAgencyAdvice([
          'ALRT suggests: Consider checking local health advice.',
          'This is general information. A health professional can help.',
        ]),
        isFalse,
      );
    });
  });

  group('air quality shows words, never the number', () {
    test('the AQI machine field is hidden and the meaning shows', () {
      final facts = AlertCardStyle.factLines(
        'Station: Moranbah\n'
        'Air quality: Unhealthy for sensitive groups (World Air Quality Index rating)\n'
        'Main pollutant: fine particles (PM2.5)\n'
        'What this means: People with heart or lung conditions may notice effects.\n'
        'Measured: 2026-10-15T02:00:00\n'
        'AQI: 111',
        title: 'Air Quality Alert - Moranbah',
      );
      expect(facts.any((f) => f.contains('111')), isFalse);
      expect(facts.any((f) => f.startsWith('Measured')), isFalse);
      expect(
        facts,
        containsAll([
          'Air quality: Unhealthy for sensitive groups (World Air Quality Index rating)',
          'Main pollutant: fine particles (PM2.5)',
          'What this means: People with heart or lung conditions may notice effects.',
        ]),
      );
    });
  });
}
