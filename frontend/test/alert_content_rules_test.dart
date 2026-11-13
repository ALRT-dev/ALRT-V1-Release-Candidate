import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/views/widgets/agency_content_sections.dart';
import 'package:hazard_app/features/profile/views/widgets/for_you_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('sparse source explains missing advice instead of hiding section', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: AgencyContentSections(content: {
        'facts': ['An active alarm was reported in Claremont.'],
        'officialActions': [], 'alrtSuggestions': [],
      }),
    )));
    expect(find.text('WHAT TO DO'), findsOneWidget);
    expect(find.textContaining('Agency instructions are not available in this view.'), findsOneWidget);
    expect(find.textContaining('has not published'), findsNothing);
  });
  testWidgets(
    'one agency instruction hides ALRT fallback, including persisted mixed records',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgencyContentSections(
              sourceName: 'Agency',
              officialIntro: 'Agency issued an incident.',
              content: {
                'sourceDescription':
                    'Complete original source, including all conditions.',
                'facts': [
                  'A sourced fact.',
                  'A second fact.',
                  'A third fact.',
                  'A fourth fact.',
                  'A fifth fact.',
                ],
                'officialActions': ['Avoid Example Road.'],
                'alrtSuggestions': ['Consider reviewing your travel plans.'],
              },
            ),
          ),
        ),
      );
      expect(
        find.text('Consider reviewing your travel plans.'),
        findsNothing,
      );
      expect(find.text('ALRT safety advice'), findsNothing);
      expect(find.textContaining('ALRT safety advice is general guidance'), findsNothing);
      expect(find.text('Agency issued an incident.'), findsNothing);
      expect(find.text('A fourth fact.'), findsOneWidget);
      expect(find.text('A fifth fact.'), findsNothing);
      expect(
        find.text('Complete original source, including all conditions.').hitTestable(),
        findsNothing,
      );
      expect(find.text('Avoid Example Road.'), findsOneWidget);
    },
  );
  testWidgets('no selected Safety Profile needs means no For You promotion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ForYouCard(categoryName: 'Flood')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Container), findsNothing);
  });
}
