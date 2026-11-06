// Real detail-screen composition. Coordinates are deliberately omitted here:
// native Google Maps rendering still requires the TEST phone build.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/learn/providers/guide_for_category_provider.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/models/hazard_source_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/view_hazard_provider.dart';
import 'package:hazard_app/features/shared/providers/states/view_hazard_provider_state.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'screenshot_fonts.dart';

final enabled = Platform.environment['ALRT_SCREENSHOTS'] == '1';

class FixtureAlertProvider extends ViewHazardProvider {
  FixtureAlertProvider(Ref ref, Hazard hazard)
    : super(
        ref: ref,
        hazardId: hazard.id!,
        state: ViewHazardProviderState(hazard: hazard),
      );
  @override
  Future<void> viewHazard() async {}
}

void main() {
  setUpAll(() async {
    if (!enabled) return;
    SharedPreferences.setMockInitialValues({
      'safety_profile_cohorts': ['older', 'kids', 'mobility'],
    });
    await loadScreenshotFonts();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (call) async => call.method == 'getVoices' ? [] : 1,
        );
  });
  for (final generic in [false, true]) {
    testWidgets('real alert detail ${generic ? 'generic fire' : 'bushfire'}', (
      tester,
    ) async {
      await tester.runAsync(loadScreenshotFonts);
      final category = generic ? 'otherFire' : 'bushfire';
      final place = generic ? 'Bassendean' : 'Scarborough';
      final hazard = Hazard(
        id: 'fixture-$category',
        title:
            '${generic ? 'Other Fire' : 'Bushfire'} - ${place.toUpperCase()}',
        categoryId: category,
        category: HazardCategory(
          id: category,
          name: generic ? 'Other Fire' : 'Bushfire',
        ),
        source: const HazardSource(
          id: 'waDfes',
          name: 'Department of Fire and Emergency Services WA',
        ),
        locationName: place,
        createdAt: DateTime(2026, 11, 7, 8),
        contentDetails: {
          'schemaVersion': 1,
          'extractionMethod': 'dfes-incident-fields',
          'facts': [
            'A ${generic ? 'fire' : 'bushfire'} was reported in $place.',
            'Reported on 7 November at 8:00 am AWST.',
          ],
          'officialActions': [],
          'alrtSuggestions': [
            'Consider checking Emergency WA for official incident updates.',
            'Consider reviewing your ${generic ? 'emergency' : 'bushfire emergency'} plan.',
          ],
          'profileGuidance': [],
          if (!generic) 'profileGuidancePolicy': 'bundledFallback',
          'sourceUpdate': {
            'summary':
                'Location details changed from the broader region to $place.',
            'detectedAt': '2026-11-07T00:05:00Z',
          },
          'originalSourceText':
              'Incident Type: ${generic ? 'Fire' : 'Bushfire'}\nLocation: $place',
        },
      );
      await tester.binding.setSurfaceSize(const Size(390, 2400));
      tester.view.physicalSize = const Size(780, 4800);
      tester.view.devicePixelRatio = 2;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        await tester.binding.setSurfaceSize(null);
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            providerOfLoggedInUser.overrideWith(
              (ref) => const AppUser(id: 'viewer'),
            ),
            providerOfViewHazard(
              hazard.id!,
            ).overrideWith((ref) => FixtureAlertProvider(ref, hazard)),
            providerOfGuideForCategory(
              category,
            ).overrideWith((ref) async => null),
            providerOfFamily.overrideWith(
              (ref) => FamilyProvider(
                ref: ref,
                bootstrap: false,
                state: const FamilyProviderState(
                  circles: [
                    FamilyCircleSummary(
                      circleId: 'family',
                      name: 'Bella',
                      myMemberId: 'me',
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (_, __) => MaterialApp(
              theme: AppTheme.lightPalette,
              home: ViewHazardScreen(
                args: ViewHazardScreenArgs(hazard: hazard),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('WHAT TO DO'), findsOneWidget);
      expect(find.text('Send alert & check in'), findsOneWidget);
      expect(find.text('Change detected'), findsOneWidget);
      expect(find.text('Get them on ALRT'), findsNothing);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/alert-${generic ? 'fire' : 'bushfire'}-detail.png',
        ),
      );
      await tester.binding.setSurfaceSize(const Size(390,844));
      tester.view.physicalSize=const Size(780,1688);
      await tester.pumpAndSettle();
      expect(tester.takeException(),isNull);
      await expectLater(find.byType(MaterialApp),matchesGoldenFile('goldens/alert-${generic ? 'fire' : 'bushfire'}-phone-top.png'));
      await tester.ensureVisible(find.text('Send alert & check in'));
      await tester.pumpAndSettle();
      expect(tester.takeException(),isNull);
      await expectLater(find.byType(MaterialApp),matchesGoldenFile('goldens/alert-${generic ? 'fire' : 'bushfire'}-phone-share.png'));
    }, skip: !enabled);
  }
}
