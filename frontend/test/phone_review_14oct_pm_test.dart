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
}
