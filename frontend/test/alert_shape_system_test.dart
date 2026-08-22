import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/map/providers/map_display_settings_provider.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/hazard_source_model.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The five source-system shapes are the app's whole visual grammar, so they
/// are pinned here: a wrong glyph is a wrong claim about who issued an alert.
void main() {
  group('systemShapeIcon', () {
    test('AWS is the triangle', () {
      expect(
        AlertCardStyle.systemShapeIcon(isAws: true, isOfficial: true),
        LucideIcons.triangleAlert,
      );
    });

    test('other official sources are the diamond', () {
      expect(
        AlertCardStyle.systemShapeIcon(isAws: false, isOfficial: true),
        LucideIcons.diamond,
      );
    });

    test('community reports are the circle', () {
      expect(
        AlertCardStyle.systemShapeIcon(isAws: false, isOfficial: false),
        LucideIcons.circle,
      );
    });

    test('global humanitarian is the rounded square, beating AWS/official',
        () {
      expect(
        AlertCardStyle.systemShapeIcon(
          isAws: true,
          isOfficial: true,
          isGlobalHumanitarian: true,
        ),
        LucideIcons.square,
      );
    });

    test('ALRT Intel is the shield and outranks every other system', () {
      expect(
        AlertCardStyle.systemShapeIcon(
          isAws: true,
          isOfficial: true,
          isGlobalHumanitarian: true,
          isAlrtIntel: true,
        ),
        LucideIcons.shield,
      );
    });
  });

  group('source-system classification', () {
    Hazard hazardWith({final HazardSource? source, final bool aws = false}) =>
        Hazard(id: 'h1', source: source, isAwsCompliant: aws);

    test('a GDACS alert is global humanitarian, not official', () {
      final hazard = hazardWith(
        source: const HazardSource(id: 'gdacsGlobal', name: 'GDACS'),
      );
      expect(hazard.isGlobalHumanitarian, isTrue);
      expect(
        AlertSourceSystem.of(hazard),
        AlertSourceSystem.globalHumanitarian,
      );
    });

    test('an agency alert stays official', () {
      final hazard = hazardWith(
        source: const HazardSource(id: 'nswSes', name: 'NSW SES'),
      );
      expect(hazard.isGlobalHumanitarian, isFalse);
      expect(AlertSourceSystem.of(hazard), AlertSourceSystem.official);
    });

    test('an AWS alert stays AWS', () {
      final hazard = hazardWith(
        source: const HazardSource(id: 'nswRfs', name: 'NSW RFS'),
        aws: true,
      );
      expect(AlertSourceSystem.of(hazard), AlertSourceSystem.aws);
    });

    test('a user report is community even with no source', () {
      final hazard = Hazard(
        id: 'h2',
        reportedBy: const AppUser(id: 'u1'),
      );
      expect(AlertSourceSystem.of(hazard), AlertSourceSystem.community);
    });

    test('a source marked shield is ALRT Intel', () {
      final hazard = hazardWith(
        source: const HazardSource(
          id: 'alrtIntel',
          name: 'ALRT Intel',
          shape: HazardSourceShape.shield,
        ),
      );
      expect(hazard.isAlrtIntel, isTrue);
      expect(AlertSourceSystem.of(hazard), AlertSourceSystem.alrtIntel);
    });

    test('ALRT Intel outranks AWS and global humanitarian', () {
      final hazard = Hazard(
        id: 'h3',
        isAwsCompliant: true,
        source: const HazardSource(
          id: 'gdacsGlobal',
          name: 'Intel over GDACS',
          shape: HazardSourceShape.shield,
        ),
      );
      expect(AlertSourceSystem.of(hazard), AlertSourceSystem.alrtIntel);
    });

    test('a source with no shape is unaffected', () {
      final hazard = hazardWith(
        source: const HazardSource(id: 'nswSes', name: 'NSW SES'),
      );
      expect(hazard.isAlrtIntel, isFalse);
    });
  });
}
