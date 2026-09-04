import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';

// Share ALRT opened a 404 (safetyalrt.com/get) on a real phone, and a TEST
// build was sending recipients to the production site. These pin the two
// rules that fix that: no build ever links to /get again, and the dev
// (TEST) flavour has no share link at all.
void main() {
  group('AppLinks.shareAppLinkForFlavor', () {
    test('the TEST (dev) flavour has no share link', () {
      expect(AppLinks.shareAppLinkForFlavor('dev'), isNull);
    });

    test('a store build shares the public website', () {
      expect(AppLinks.shareAppLinkForFlavor('prod'), AppLinks.website);
    });

    test('an unknown or missing flavour still shares the website', () {
      expect(AppLinks.shareAppLinkForFlavor(null), AppLinks.website);
      expect(AppLinks.shareAppLinkForFlavor('staging'), AppLinks.website);
    });
  });

  group('AppLinks.website', () {
    test('never points at the known-404 /get path', () {
      expect(AppLinks.website, isNot(contains('/get')));
      expect(AppLinks.website, 'https://www.safetyalrt.com');
    });

    test('the display form is the same host', () {
      expect(AppLinks.website, contains(AppLinks.websiteDisplay));
    });
  });
}
