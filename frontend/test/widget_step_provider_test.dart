import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/profile/models/safety_cohort.dart';
import 'package:hazard_app/features/profile/providers/safety_profile_provider.dart';
import 'package:hazard_app/features/profile/providers/widget_step_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Finish setting up strip waits for the device preferences and clears
/// its "Add a widget" step once the user has opened it (Android only).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

  test('the widget step is not loaded until the preference is read', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    final sub = c.listen(providerOfWidgetStep, (_, __) {});
    expect(c.read(providerOfWidgetStep).loaded, isFalse);
    await settle();
    expect(c.read(providerOfWidgetStep).loaded, isTrue);
    expect(c.read(providerOfWidgetStep).done, isFalse);
    sub.close();
    c.dispose();
  });

  test('opening the step marks it done and it stays done after a restart', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    final sub = c.listen(providerOfWidgetStep, (_, __) {});
    await settle();
    await c.read(providerOfWidgetStep.notifier).markDone();
    expect(c.read(providerOfWidgetStep).done, isTrue);
    sub.close();
    c.dispose();

    final fresh = ProviderContainer();
    final freshSub = fresh.listen(providerOfWidgetStep, (_, __) {});
    await settle();
    expect(fresh.read(providerOfWidgetStep).done, isTrue);
    freshSub.close();
    fresh.dispose();
  });

  test('the safety profile reports loaded only after the read', () async {
    SharedPreferences.setMockInitialValues({
      'safety_profile_cohorts': [SafetyCohort.deaf.id],
    });
    final c = ProviderContainer();
    final sub = c.listen(providerOfSafetyProfile, (_, __) {});
    final loadedSub = c.listen(providerOfSafetyProfileLoaded, (_, __) {});
    expect(c.read(providerOfSafetyProfileLoaded), isFalse);
    await settle();
    expect(c.read(providerOfSafetyProfileLoaded), isTrue);
    expect(c.read(providerOfSafetyProfile), contains(SafetyCohort.deaf));
    sub.close();
    loadedSub.close();
    c.dispose();
  });

  test('the widget step is offered on Android only', () {
    expect(widgetStepAvailableOn(TargetPlatform.android), isTrue);
    expect(widgetStepAvailableOn(TargetPlatform.iOS), isFalse);
  });
}
