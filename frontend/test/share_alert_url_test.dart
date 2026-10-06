import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/utils/share_alert.dart';

/// A DEV/TEST build must never share a link into production — the alert it
/// points at only exists in whichever backend the build actually talks to.
/// This pins buildAlertShareUrl to the base URL it's given, so a second
/// hardcoded environment URL can't grow back into share_alert.dart.
void main() {
  group('buildAlertShareUrl', () {
    test('builds against the production base URL', () {
      expect(
        buildAlertShareUrl(
          baseUrl: 'https://api.safetyalrt.com',
          hazardId: 'abc123',
        ),
        'https://api.safetyalrt.com/a/abc123',
      );
    });

    test('builds against the isolated TEST backend URL', () {
      expect(
        buildAlertShareUrl(
          baseUrl: 'https://api-test.safetyalrt.com',
          hazardId: 'abc123',
        ),
        'https://api-test.safetyalrt.com/a/abc123',
      );
    });

    test('builds against a local dev server URL', () {
      expect(
        buildAlertShareUrl(
          baseUrl: 'http://192.168.1.67:9000',
          hazardId: 'xyz789',
        ),
        'http://192.168.1.67:9000/a/xyz789',
      );
    });
  });
}
