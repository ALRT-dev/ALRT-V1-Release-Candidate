import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/views/widgets/agency_content_sections.dart';

void main() {
  testWidgets(
    'recognised sparse source explains limits without implying extraction failed',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgencyContentSections(
              content: {
                'facts': ['Smoke was reported in Innaloo.'],
                'sourceLimitations':
                    'The cause and extent are not supplied in this feed.',
                'sourceAdviceStatus': 'not-in-incident-feed',
                'officialActions': [],
                'alrtSuggestions': [],
              },
            ),
          ),
        ),
      );
      expect(
        find.text('The cause and extent are not supplied in this feed.'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'This incident feed contains no agency instructions.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('not available in this view'), findsNothing);
    },
  );
  testWidgets('render actual Scarborough content for visual review', (
    tester,
  ) async {
    final loader = FontLoader('Poppins')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('assets/fonts/Poppins/Poppins-Regular.ttf').readAsBytesSync(),
          ),
        ),
      );
    await tester.runAsync(loader.load);
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await tester.runAsync(icons.load);
    tester.view.physicalSize = const Size(430, 1050);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Poppins'),
        home: Scaffold(
          backgroundColor: const Color(0xFFF5F5F7),
          body: RepaintBoundary(
            key: key,
            child: Container(
              color: const Color(0xFFF5F5F7),
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bushfire in Scarborough',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 16),
                  AgencyContentSections(
                    sourceName: 'DFES',
                    content: {
                      'extractionMethod': 'dfes-incident-fields',
                      'facts': [
                        'A bushfire was reported in Scarborough (City of Stirling).',
                        'Reported on 6 November at 7:27 pm AWST.',
                      ],
                      'affectedAreas': ['Scarborough'],
                      'officialActions': [],
                      'alrtSuggestions': [
                        'Consider checking Emergency WA for official incident updates.',
                        'Consider reviewing your bushfire emergency plan.',
                      ],
                      'originalSourceText':
                          'Incident Type: Bushfire\nLocation: Scarborough\nSource: Department of Fire and Emergency Services WA incident feed',
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final picture = (await tester.runAsync(
      () => boundary.toImage(pixelRatio: 2),
    ))!;
    final data = await tester.runAsync(
      () => picture.toByteData(format: ui.ImageByteFormat.png),
    );
    final file = File(
      Platform.environment['ALRT_VISUAL_OUTPUT'] ??
          'build/alert-content-development.png',
    );
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(data!.buffer.asUint8List());
    picture.dispose();
  });
  testWidgets('sparse incident keeps advice and collapses metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AgencyContentSections(
              content: {
                'extractionMethod': 'dfes-incident-fields',
                'facts': ['A fire was reported in Bassendean.'],
                'affectedAreas': ['Bassendean'],
                'officialActions': [],
                'alrtSuggestions': [
                  'Consider checking Emergency WA.',
                  'Consider reviewing your emergency plan.',
                ],
                'originalSourceText':
                    'Incident Type: Fire\nLocation: Bassendean',
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('WHAT TO DO'), findsOneWidget);
    expect(find.text('ALRT safety advice'), findsOneWidget);
    expect(find.text('AFFECTED AREA'), findsNothing);
    expect(
      find.text('Incident Type: Fire\nLocation: Bassendean').hitTestable(),
      findsNothing,
    );
  });
}
