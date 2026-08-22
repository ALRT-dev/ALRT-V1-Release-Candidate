import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/profile/models/safety_cohort.dart';
import 'package:hazard_app/features/profile/providers/safety_profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How urgent alerts reach people who won't hear a ping or read a banner.
///
/// Two switches, both delivery-side and on-device only:
/// - [strongVibration]: ACTION/CRITICAL alerts arrive on a channel with a
///   long, hard vibration pattern (and lights where the OS supports it).
/// - [readAloud]: ACTION/CRITICAL alerts are spoken aloud when the app is
///   open, and every alert detail carries a Listen button.
///
/// Until the user touches a switch it follows their safety profile: ticking
/// "Deaf or hard of hearing" turns strong vibration on, "Vision impairment"
/// turns read-aloud on. An explicit toggle always wins from then on.
class AccessibleAlertsSettings {
  const AccessibleAlertsSettings({
    required this.strongVibration,
    required this.readAloud,
  });

  final bool strongVibration;
  final bool readAloud;
}

class AccessibleAlertsNotifier extends Notifier<AccessibleAlertsSettings> {
  static const _vibrationKey = 'accessible_alerts_strong_vibration';
  static const _readAloudKey = 'accessible_alerts_read_aloud';

  bool? _explicitVibration;
  bool? _explicitReadAloud;
  bool _loaded = false;

  @override
  AccessibleAlertsSettings build() {
    final cohorts = ref.watch(providerOfSafetyProfile);
    if (!_loaded) _load();
    return AccessibleAlertsSettings(
      strongVibration:
          _explicitVibration ?? cohorts.contains(SafetyCohort.deaf),
      readAloud: _explicitReadAloud ?? cohorts.contains(SafetyCohort.vision),
    );
  }

  Future<void> _load() async {
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    _explicitVibration = prefs.getBool(_vibrationKey);
    _explicitReadAloud = prefs.getBool(_readAloudKey);
    _recompute();
  }

  Future<void> setStrongVibration(final bool value) async {
    _explicitVibration = value;
    _recompute();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
  }

  Future<void> setReadAloud(final bool value) async {
    _explicitReadAloud = value;
    _recompute();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_readAloudKey, value);
  }

  void _recompute() {
    final cohorts = ref.read(providerOfSafetyProfile);
    state = AccessibleAlertsSettings(
      strongVibration:
          _explicitVibration ?? cohorts.contains(SafetyCohort.deaf),
      readAloud: _explicitReadAloud ?? cohorts.contains(SafetyCohort.vision),
    );
  }
}

final providerOfAccessibleAlerts =
    NotifierProvider<AccessibleAlertsNotifier, AccessibleAlertsSettings>(
      AccessibleAlertsNotifier.new,
    );
