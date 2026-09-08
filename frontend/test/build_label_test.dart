import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/profile/utils/build_label.dart';

// Android app info shows only "1.0.5" for every TEST build, so the app
// itself must say which build, commit and billing mode it is.
void main() {
  test('TEST builds show version, build, TEST marker, commit and billing', () {
    expect(
      buildLabel(
        version: '1.0.5',
        buildNumber: '38',
        flavor: 'dev',
        commit: 'ab12cd3',
        billingMode: 'RevenueCat Test Store',
      ),
      'ALRT 1.0.5 (38) · TEST build · ab12cd3 · RevenueCat Test Store',
    );
  });
  test('production shows the version and build only', () {
    expect(
      buildLabel(version: '1.0.5', buildNumber: '38', flavor: 'prod'),
      'ALRT 1.0.5 (38)',
    );
    expect(
      buildLabel(version: '1.0.5', buildNumber: '', flavor: null),
      'ALRT 1.0.5',
    );
  });
  test('billing mode wording', () {
    expect(billingModeLabel(testUnlocked: true, hasStoreKey: false), 'billing bypass');
    expect(billingModeLabel(testUnlocked: false, hasStoreKey: true), 'store billing');
    expect(billingModeLabel(testUnlocked: false, hasStoreKey: false), 'no billing key');
  });
}
