import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/views/widgets/agency_content_sections.dart';
import 'package:hazard_app/features/profile/views/widgets/for_you_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'agency instructions first, supplemental guidance visibly separate',
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
                'facts': ['A sourced fact.', 'A second fact.', 'A third fact.'],
                'officialActions': ['Avoid Example Road.'],
                'alrtSuggestions': ['Consider reviewing your travel plans.'],
              },
            ),
          ),
        ),
      );
      expect(
        find.text('Consider reviewing your travel plans.'),
        findsOneWidget,
      );
      expect(find.text('Agency issued an incident.'), findsNothing);
      expect(find.text('A third fact.'), findsNothing);
      expect(
        find.text('Complete original source, including all conditions.'),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.text('Avoid Example Road.')).dy,
        lessThan(
          tester
              .getTopLeft(find.text('Consider reviewing your travel plans.'))
              .dy,
        ),
      );
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
