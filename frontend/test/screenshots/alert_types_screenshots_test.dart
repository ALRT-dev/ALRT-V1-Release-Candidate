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
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
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

  final kinds = <String, Hazard>{
    'air-quality': Hazard(
      id: 'fixture-air-quality',
      title: 'Air quality alert - Duncraig',
      description:
          'Station: Duncraig, Perth, Australia\nAir quality: poor (World Air Quality Index rating)\nAQI: 162',
      categoryId: 'airQualityAlert',
      category: const HazardCategory(
        id: 'airQualityAlert',
        parentId: 'healthAndAir',
        name: 'Air Quality Alert',
      ),
      source: const HazardSource(id: 'waqi', name: 'World Air Quality Index'),
      severityBand: HazardSeverityBand.action,
      locationName: 'Duncraig',
      createdAt: DateTime(2026, 11, 13, 15),
      contentDetails: const {
        'schemaVersion': 1,
        'templateVersion': 4,
        'facts': [
          'World Air Quality Index reports that air quality near Duncraig, Perth, Australia is poor.',
          'Air pollution at this level can affect people with heart or lung conditions, older adults and children.',
        ],
        'affectedAreas': ['Duncraig'],
        'nativeLevel': null,
        'officialActions': [],
        'alrtSuggestions': [
          'Consider limiting long or strenuous outdoor activity, particularly if you have a breathing condition.',
          'If you have a breathing condition, consider keeping your usual medication within reach and following your care plan.',
          'For current health advice, your state EPA or Department of Health can help.',
        ],
        'profileGuidance': [],
      },
    ),
    'gdacs': Hazard(
      id: 'fixture-gdacs',
      title: 'Orange earthquake alert in Vanuatu',
      description:
          'On 13 November 2026 an earthquake of magnitude 6.8 occurred near Port Vila, Vanuatu. Alert level: Orange.',
      categoryId: 'earthquake',
      category: const HazardCategory(
        id: 'earthquake',
        parentId: 'weatherAndEnvironment',
        name: 'Earthquake',
      ),
      source: const HazardSource(id: 'gdacsGlobal', name: 'GDACS'),
      severityBand: HazardSeverityBand.action,
      nativeWarningLevel: 'Orange',
      locationName: 'Port Vila, Vanuatu',
      createdAt: DateTime(2026, 11, 13, 14),
      contentDetails: const {
        'schemaVersion': 1,
        'templateVersion': 4,
        'facts': [
          'GDACS rates this earthquake near Port Vila, Vanuatu as orange, medium humanitarian impact. People in the area are affected; others generally are not.',
          'On 13 November 2026 an earthquake of magnitude 6.8 occurred near Port Vila, Vanuatu.',
        ],
        'affectedAreas': ['Port Vila, Vanuatu'],
        'nativeLevel': 'GDACS Orange',
        'officialActions': [],
        'alrtSuggestions': [
          'If the ground shakes, Drop, Cover and Hold On until the shaking stops.',
          'Be ready for aftershocks, which can follow minutes or days later.',
          'Local authority guidance is the reliable reference for anyone in the affected area.',
          'If you have family or contacts in the region, establishing contact is a good idea.',
        ],
        'profileGuidance': [],
      },
    ),
  };
  for (final entry in kinds.entries) {
    testWidgets('alert type ${entry.key}', (tester) async {
      await tester.runAsync(loadScreenshotFonts);
      final hazard = entry.value;
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
              guideForCategoryKey(hazard.categoryId!, hazard.displayWarningLevel),
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
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/alert-${entry.key}-detail.png'),
      );
    }, skip: !enabled);
  }
}
