import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';

// Two rules for "Share ALRT" (product owner, 2026-09-03):
//  - the TEST (dev) flavour has NO share link at all - a TEST APK is sent
//    to a tester directly, never via the production site or a store;
//  - the production destination is a single constant that is only changed
//    once a replacement has been independently confirmed to work (the
//    current /get path is a known 404, deliberately not swapped silently).
void main() {
  group('AppLinks.shareAppLinkForFlavor', () {
    test('the TEST (dev) flavour has no share link', () {
      expect(AppLinks.shareAppLinkForFlavor('dev'), isNull);
    });

    test('a store build shares the single production destination', () {
      expect(
        AppLinks.shareAppLinkForFlavor('prod'),
        AppLinks.shareAppProduction,
      );
    });

    test('an unknown or missing flavour is treated as production', () {
      expect(AppLinks.shareAppLinkForFlavor(null), AppLinks.shareAppProduction);
      expect(
        AppLinks.shareAppLinkForFlavor('staging'),
        AppLinks.shareAppProduction,
      );
    });
  });

  group('AppLinks.shareAppProduction', () {
    test('is an https safetyalrt.com URL and matches its display form', () {
      expect(AppLinks.shareAppProduction, startsWith('https://'));
      expect(
        AppLinks.shareAppProduction,
        contains(AppLinks.shareAppProductionDisplay),
      );
    });
  });
}
