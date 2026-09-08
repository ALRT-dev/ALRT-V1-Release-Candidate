import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/profile/utils/build_label.dart';

// Android app info shows only "1.0.5" for every TEST build, so the app
// itself must say which build it is.
void main() {
  test('TEST builds show version, build number and the TEST marker', () {
    expect(
      buildLabel(version: '1.0.5', buildNumber: '37', flavor: 'dev'),
      'ALRT 1.0.5 (37) · TEST build',
    );
  });
  test('production shows the version and build only', () {
    expect(
      buildLabel(version: '1.0.5', buildNumber: '37', flavor: 'prod'),
      'ALRT 1.0.5 (37)',
    );
    expect(
      buildLabel(version: '1.0.5', buildNumber: '', flavor: null),
      'ALRT 1.0.5',
    );
  });
}
