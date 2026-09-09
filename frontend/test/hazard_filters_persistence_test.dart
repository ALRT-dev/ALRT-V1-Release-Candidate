import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_filters_provider_state.dart';
import 'package:hazard_app/features/map/views/screens/map_screen.dart';
import 'package:hazard_app/features/notification/views/widgets/notifications_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The map and the ALRT feed share one set of alert filters, saved on the
/// device (phone QA 2026-09-09: "selected alerts do not show up
/// consistently"). These pin the sharing and the round trip.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('map and feed resolve to the same filter state', () {
    expect(MapScreen.filtersKey, kSharedAlertFiltersKey);
    expect(NotificationsAppBar.filtersKey, kSharedAlertFiltersKey);
    expect(providerOfHazardFiltersForMap, equals(providerOfHazardFiltersForNotifications));
  });

  test('storage round trip keeps every switch and the chosen ids', () {
    const s = HazardFiltersProviderState(
      awsAdvice: false,
      globalHumanitarian: false,
      selectedCategoryIds: {'c1', 'c2'},
      selectedLocationIds: {'l1'},
    );
    final back = HazardFiltersProviderState.fromStorageJson(
      jsonDecode(jsonEncode(s.toStorageJson())) as Map<String, dynamic>,
    );
    expect(back.awsAdvice, isFalse);
    expect(back.globalHumanitarian, isFalse);
    expect(back.awsEmergency, isTrue);
    expect(back.selectedCategoryIds, {'c1', 'c2'});
    expect(back.selectedLocationIds, {'l1'});
  });

  test('a change is written to the device and restored by a fresh instance', () async {
    SharedPreferences.setMockInitialValues({});
    final a = ProviderContainer();
    a.read(providerOfHazardFilters('k').notifier).updateUserReported(false);
    a.read(providerOfHazardFilters('k').notifier).updateAlrtIntel(false);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(HazardFiltersProvider.prefsKeyFor('k')), isNotNull);
    a.dispose();

    final b = ProviderContainer();
    final sub = b.listen(providerOfHazardFilters('k'), (_, __) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final restored = b.read(providerOfHazardFilters('k'));
    expect(restored.userReported, isFalse);
    expect(restored.alrtIntel, isFalse);
    expect(restored.awsEmergency, isTrue);
    sub.close();
    b.dispose();
  });

  test('a corrupt saved value is ignored, never fatal', () async {
    SharedPreferences.setMockInitialValues({
      HazardFiltersProvider.prefsKeyFor('bad'): 'not json',
    });
    final c = ProviderContainer();
    final sub = c.listen(providerOfHazardFilters('bad'), (_, __) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(c.read(providerOfHazardFilters('bad')).userReported, isTrue);
    sub.close();
    c.dispose();
  });
}
