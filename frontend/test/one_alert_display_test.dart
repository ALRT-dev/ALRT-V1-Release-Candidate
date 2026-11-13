import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/utils/alert_text_util.dart';
import 'package:hazard_app/features/shared/views/widgets/agency_content_sections.dart';

// Owner review, 13 November 2026: every official alert shows the same
// sections in the same order, whatever path its content took.
void main() {
  group('older alerts adapted to the structured card', () {
    test('agency lines stay agency, ALRT lines stay ALRT', () {
      final content = AlertTextUtil.legacyDisplayContent(
        description: 'A bushfire is burning near Melaleuca.\nCrews are on scene.',
        callsToAction: [
          'DFES advises: Avoid the area.',
          'DFES advises: Drive with caution on Great Northern Highway.',
          'ALRT suggests: Keep your phone charged.',
          'If you are near the area, be ready to follow emergency instructions.',
        ],
        issuedLine: 'DFES has issued a bushfire incident at Melaleuca.',
        hazardBucket: 'bushfire',
      );
      expect(content['schemaVersion'], 1);
      expect(content['facts'], [
        'DFES has issued a bushfire incident at Melaleuca.',
        'A bushfire is burning near Melaleuca.',
        'Crews are on scene.',
      ]);
      expect(content['officialActions'], [
        'Avoid the area.',
        'Drive with caution on Great Northern Highway.',
      ]);
      expect(content['alrtSuggestions'], ['Keep your phone charged.']);
      expect(content['issuingAgency'], 'DFES');
    });

    test('no advice at all is topped up, never with a leave direction', () {
      final content = AlertTextUtil.legacyDisplayContent(
        description: 'Location: Melaleuca',
        callsToAction: const [],
        issuedLine: 'DFES has issued a bushfire incident at Melaleuca.',
        hazardBucket: 'grass_fire',
      );
      final advice = (content['alrtSuggestions'] as List).cast<String>();
      expect(advice.length, 2);
      for (final line in advice) {
        expect(line.toLowerCase(), isNot(contains('leave')));
      }
    });

    test('a thin description borrows the plain summary', () {
      final content = AlertTextUtil.legacyDisplayContent(
        description: '',
        aiSummary:
            'A storm is moving through Perth. Damaging winds are possible this afternoon.',
        callsToAction: const [],
        issuedLine: null,
      );
      expect(content['facts'], [
        'A storm is moving through Perth.',
        'Damaging winds are possible this afternoon.',
      ]);
    });
  });

  testWidgets('no level card and no area card: area folds into facts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AgencyContentSections(
            sourceName: 'NSW RFS',
            warningLevel: 'Watch and Act',
            content: {
              'schemaVersion': 1,
              'nativeLevel': 'Watch and Act',
              'facts': ['A bush fire is burning out of control.'],
              'affectedAreas': ['Wisemans Ferry', 'Spencer'],
              'officialActions': ['Monitor conditions.'],
              'alrtSuggestions': ['Check official updates often.'],
            },
          ),
        ),
      ),
    );
    expect(find.text('AGENCY WARNING'), findsNothing);
    expect(find.text('AFFECTED AREA'), findsNothing);
    expect(find.text('Areas: Wisemans Ferry, Spencer.'), findsOneWidget);
    expect(find.text('WHAT WE KNOW'), findsOneWidget);
    expect(find.text('WHAT TO DO'), findsOneWidget);
  });
}
