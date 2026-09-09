import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/notification/providers/accessible_alerts_provider.dart';
import 'package:hazard_app/features/profile/models/safety_cohort.dart';
import 'package:hazard_app/features/profile/providers/safety_profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Strong vibration (phone QA 2026-09-09): the user's choice lives in the
/// device preferences, not in the Android channel. The urgent channel is
/// created while the switch is on and deleted while it is off, so deleting
/// or re-creating that channel can never lose the preference. These pin the
/// preference side; the channel calls themselves need an Android device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

  test('follows the safety profile until the user touches the switch', () async {
    SharedPreferences.setMockInitialValues({
      'safety_profile_cohorts': [SafetyCohort.deaf.id],
    });
    final c = ProviderContainer();
    final sub = c.listen(providerOfAccessibleAlerts, (_, __) {});
    await settle();
    expect(c.read(providerOfAccessibleAlerts).strongVibration, isTrue);
    expect(c.read(providerOfAccessibleAlerts).readAloud, isFalse);
    sub.close();
    c.dispose();
  });

  test('an explicit off beats the profile and is written to the device', () async {
    SharedPreferences.setMockInitialValues({
      'safety_profile_cohorts': [SafetyCohort.deaf.id],
    });
    final c = ProviderContainer();
    final sub = c.listen(providerOfAccessibleAlerts, (_, __) {});
    await settle();
    await c.read(providerOfAccessibleAlerts.notifier).setStrongVibration(false);
    expect(c.read(providerOfAccessibleAlerts).strongVibration, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('accessible_alerts_strong_vibration'), isFalse);
    sub.close();
    c.dispose();
  });

  test('the saved choice survives a fresh start (channel state is irrelevant)', () async {
    SharedPreferences.setMockInitialValues({
      'accessible_alerts_strong_vibration': true,
    });
    final c = ProviderContainer();
    final sub = c.listen(providerOfAccessibleAlerts, (_, __) {});
    await settle();
    expect(c.read(providerOfAccessibleAlerts).strongVibration, isTrue);
    sub.close();
    c.dispose();
  });

  test('off then on again ends on, and the device holds the last value', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    final sub = c.listen(providerOfAccessibleAlerts, (_, __) {});
    await settle();
    final n = c.read(providerOfAccessibleAlerts.notifier);
    await n.setStrongVibration(true);
    await n.setStrongVibration(false);
    await n.setStrongVibration(true);
    expect(c.read(providerOfAccessibleAlerts).strongVibration, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('accessible_alerts_strong_vibration'), isTrue);
    sub.close();
    c.dispose();
  });

  test('ticking a cohort later never overrides an explicit choice', () async {
    SharedPreferences.setMockInitialValues({
      'accessible_alerts_strong_vibration': false,
    });
    final c = ProviderContainer();
    final sub = c.listen(providerOfAccessibleAlerts, (_, __) {});
    await settle();
    await c.read(providerOfSafetyProfile.notifier).toggle(SafetyCohort.deaf);
    await settle();
    expect(c.read(providerOfSafetyProfile), contains(SafetyCohort.deaf));
    expect(c.read(providerOfAccessibleAlerts).strongVibration, isFalse);
    sub.close();
    c.dispose();
  });
}
