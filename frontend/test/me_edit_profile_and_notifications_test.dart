import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/notification/views/screens/manage_notifications_screen.dart';
import 'package:hazard_app/features/profile/models/safety_cohort.dart';
import 'package:hazard_app/features/profile/views/screens/safety_profile_screen.dart';
import 'package:hazard_app/features/profile/views/widgets/edit_profile_sheet.dart';

/// Me tab rebuild (12 Oct 2026): the Edit profile sheet's save rule, the
/// Safety profile display labels, and the saved-place bounds the
/// Notifications screen builds for a picked place without a viewport.
void main() {
  group('Edit profile: display name', () {
    test('a changed, non-blank name is what gets sent', () {
      expect(
        displayNameToSave(input: '  Sarah Nixon ', current: 'Sarah'),
        'Sarah Nixon',
      );
    });

    test('blank input sends nothing', () {
      expect(displayNameToSave(input: '   ', current: 'Sarah'), isNull);
      expect(displayNameToSave(input: '', current: null), isNull);
    });

    test('the same name as the account already has sends nothing', () {
      expect(displayNameToSave(input: 'Sarah', current: 'Sarah'), isNull);
      expect(displayNameToSave(input: ' Sarah ', current: 'Sarah '), isNull);
    });
  });

  group('Safety profile labels', () {
    test('Visiting Australia reads Visitor; the stored id is unchanged', () {
      expect(safetyCohortDisplayLabel(SafetyCohort.visitor), 'Visitor');
      expect(SafetyCohort.visitor.id, 'visitor');
      expect(SafetyCohort.visitor.label, 'Visiting Australia');
    });

    test('Older adult reads Older person; every other chip keeps its label',
        () {
      expect(safetyCohortDisplayLabel(SafetyCohort.older), 'Older person');
      for (final cohort in SafetyCohort.values) {
        if (cohort == SafetyCohort.older || cohort == SafetyCohort.visitor) {
          continue;
        }
        expect(safetyCohortDisplayLabel(cohort), cohort.label);
      }
    });
  });

  group('Saved places: bounds for a picked point', () {
    test('a square around the point whose corner is the radius away', () {
      final b = boundsAround(
        latitude: -31.89,
        longitude: 115.76,
        radiusKm: 5,
      );
      expect(b.northeastLat, greaterThan(-31.89));
      expect(b.southwestLat, lessThan(-31.89));
      expect(b.northeastLng, greaterThan(115.76));
      expect(b.southwestLng, lessThan(115.76));
      // Symmetric about the centre.
      expect(
        (b.northeastLat + b.southwestLat) / 2,
        closeTo(-31.89, 1e-9),
      );
      expect(
        (b.northeastLng + b.southwestLng) / 2,
        closeTo(115.76, 1e-9),
      );
      // 5 km to the corner is about 3.54 km per edge: roughly 0.032 deg
      // of latitude.
      expect(b.northeastLat - b.southwestLat, closeTo(0.0636, 0.001));
    });
  });
}
