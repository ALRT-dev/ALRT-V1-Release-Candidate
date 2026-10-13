import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';

void main() {
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
