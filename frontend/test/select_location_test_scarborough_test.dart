import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/map/views/screens/select_location_screen.dart';

// Locks in the two invariants that keep the community report flow's
// TEST-only "Use Scarborough WA (TEST)" location fallback from ever
// appearing where it shouldn't:
//  - SelectLocationScreenArgs.showTestScarboroughOption defaults to
//    false, so every OTHER SelectLocationScreen caller (saved locations,
//    family places, etc.) is unaffected unless it explicitly opts in -
//    create_update_report_screen.dart is the only caller that does, and
//    only when testScarboroughLocationFallbackEnabled (hazard_repository
//    .dart's TEST/dev double-gate) is true.
//  - testScarboroughLocation itself matches the exact coordinates the
//    Admin Portal's own "TEST — DO NOT USE — Fire" preset uses
//    (SCARBOROUGH_WA_LAT/LNG, admin/src/data/testAlertPresets.ts), so a
//    tester's manually-submitted report and the admin-created alert land
//    on the same map pin.
void main() {
  group('SelectLocationScreenArgs.showTestScarboroughOption', () {
    test('defaults to false', () {
      final args = SelectLocationScreenArgs();

      expect(args.showTestScarboroughOption, isFalse);
    });

    test('can be explicitly enabled by an opted-in caller', () {
      final args = SelectLocationScreenArgs(showTestScarboroughOption: true);

      expect(args.showTestScarboroughOption, isTrue);
    });
  });

  group('testScarboroughLocation', () {
    test('matches the Admin Portal Fire preset\'s coordinates', () {
      expect(testScarboroughLocation.latitude, -31.89441);
      expect(testScarboroughLocation.longitude, 115.75999);
    });

    test('is clearly labelled as a TEST location', () {
      expect(testScarboroughLocation.name, contains('TEST'));
    });
  });
}
