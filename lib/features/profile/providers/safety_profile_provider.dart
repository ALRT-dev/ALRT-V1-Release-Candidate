import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/profile/models/safety_cohort.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's ticked For You cohorts.
///
/// Privacy rule (For You Cohort Layer): this set is stored ON DEVICE ONLY via
/// SharedPreferences and is never sent to the backend, analytics, or anywhere
/// else. Matching and pinning of For You lines happen locally.
class SafetyProfileNotifier extends Notifier<Set<SafetyCohort>> {
  static const _prefsKey = 'safety_profile_cohorts';

  @override
  Set<SafetyCohort> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_prefsKey) ?? const [];
    state = {
      for (final cohort in SafetyCohort.values)
        if (ids.contains(cohort.id)) cohort,
    };
  }

  Future<void> toggle(final SafetyCohort cohort) async {
    final next = {...state};
    if (!next.remove(cohort)) next.add(cohort);
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      next.map((cohort) => cohort.id).toList(),
    );
  }
}

final providerOfSafetyProfile =
    NotifierProvider<SafetyProfileNotifier, Set<SafetyCohort>>(
  SafetyProfileNotifier.new,
);
