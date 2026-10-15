import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/models/hazard_source_model.dart';
import 'package:hazard_app/features/shared/utils/template_marker.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'published colours keep event pictograms instead of plain pins',
    () async {
      final hazard = Hazard(
        categoryId: 'crash',
        severityBand: HazardSeverityBand.action,
        contentDetails: {
          'presentation': {
            'band': 'action',
            'bandColor': '#123456',
            'iconCategoryId': 'crash',
          },
        },
      );
      final marker = BitmapDescriptor.defaultMarkerWithHue(22);
      final bitmaps = {'event_non_aws_crash_action': marker};
      expect(await templateMarker(hazard, bitmaps), isNull);
      expect(hazard.getMarkerBitmapDescriptor(bitmaps), marker);
    },
  );
  test('a selected template icon uses the new event asset keys', () {
    final hazard = Hazard(
      categoryId: 'other',
      severityBand: HazardSeverityBand.action,
      contentDetails: {
        'presentation': {
          'band': 'action',
          'bandColor': '#123456',
          'iconCategoryId': 'crash',
        },
      },
    );
    final marker = BitmapDescriptor.defaultMarkerWithHue(22);
    expect(
      hazard.getMarkerBitmapDescriptor({'event_non_aws_crash_action': marker}),
      marker,
    );
  });
  test(
    'GDACS keeps its native artwork and colour ahead of template overrides',
    () {
      final hazard = Hazard(
        title: 'Green earthquake alert in Japan',
        categoryId: 'earthquake',
        source: const HazardSource(id: 'gdacsGlobal'),
        severityBand: HazardSeverityBand.info,
        contentDetails: {
          'presentation': {
            'band': 'info',
            'bandColor': '#123456',
            'iconCategoryId': 'crash',
          },
        },
      );
      final gdacs = BitmapDescriptor.defaultMarkerWithHue(120);
      expect(hazard.templateBandColor, isNull);
      expect(hazard.templateIconCategoryId, isNull);
      expect(
        hazard.getMarkerBitmapDescriptor({
          'event_gdacs_earthquake_green': gdacs,
          'crash_info_non_aws': BitmapDescriptor.defaultMarker,
        }),
        gdacs,
      );
    },
  );
  final payload = <String, dynamic>{
    'schemaVersion': 1,
    'facts': ['An agency fact.'],
    'profileGuidance': [
      {
        'id': 'kids',
        'text': 'Consider checking local advice.',
        'profileTags': ['kids'],
      },
    ],
    'presentation': {
      'band': 'action',
      'bandColor': '#123456',
      'iconCategoryId': 'smoke',
    },
  };
  test('published content round trips and selects profile rows locally', () {
    final hazard = Hazard.fromJson({
      'id': 'example',
      'categoryId': 'other',
      'severityBand': 'action',
      'contentDetails': payload,
    });
    expect(hazard.publishedProfileGuidance, {
      'kids': 'Consider checking local advice.',
    });
    expect(hazard.templateBandColor?.toARGB32(), 0xff123456);
    expect(hazard.templateIconCategoryId, 'smoke');
    expect(hazard.toJson()['contentDetails'], payload);
  });
  test('AWS artwork ignores editable ALRT colour and icon overrides', () {
    final hazard = Hazard(
      isAwsCompliant: true,
      severityBand: HazardSeverityBand.action,
      contentDetails: payload,
    );
    expect(hazard.templateBandColor, isNull);
    expect(hazard.templateIconCategoryId, isNull);
  });
  test('empty published guidance does not fall back to stale library rows', () {
    expect(
      const Hazard(
        contentDetails: {'profileGuidance': []},
      ).publishedProfileGuidance,
      isEmpty,
    );
    expect(const Hazard().publishedProfileGuidance, isNull);
  });
  test('all matching guidance for a cohort is retained in source order', () {
    final hazard = Hazard(
      contentDetails: {
        'profileGuidance': [
          {
            'text': 'First suggestion.',
            'profileTags': ['kids'],
          },
          {
            'text': 'Second suggestion.',
            'profileTags': ['kids', 'medical'],
          },
        ],
      },
    );
    expect(
      hazard.publishedProfileGuidance?['kids'],
      'First suggestion.\n\nSecond suggestion.',
    );
    expect(hazard.publishedProfileGuidance?['medical'], 'Second suggestion.');
  });
  test('a colour from an old band cannot misrepresent a changed band', () {
    expect(
      Hazard(
        severityBand: HazardSeverityBand.critical,
        contentDetails: payload,
      ).templateBandColor,
      isNull,
    );
  });
}
