import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/profile/models/safety_cohort.dart';
import 'package:hazard_app/features/profile/providers/safety_profile_provider.dart';
import 'package:hazard_app/features/notification/services/local_notification_service.dart';
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
  bool _prefsLoaded = false;
  Future<void>? _loading;

  /// The last value the Android urgent channel was set to, or null when the
  /// channel state is unknown (nothing applied yet, or the test button has
  /// created it as a side effect).
  bool? _appliedChannel;

  @override
  AccessibleAlertsSettings build() {
    final cohorts = ref.watch(providerOfSafetyProfile);
    final profileLoaded = ref.watch(providerOfSafetyProfileLoaded);
    _loading ??= _load();
    final settings = AccessibleAlertsSettings(
      strongVibration:
          _explicitVibration ?? cohorts.contains(SafetyCohort.deaf),
      // Nothing is read aloud automatically. Anyone who wants an alert
      // spoken taps Listen at the bottom of it.
      readAloud: false,
    );
    // The urgent channel follows the effective value, but only once both
    // the saved switch and the safety profile are read: before that the
    // value is a placeholder and would delete a channel the user wants.
    if (_prefsLoaded && profileLoaded) {
      unawaited(_applyChannel(settings.strongVibration));
    }
    return settings;
  }

  /// Completes once the saved switch has been read and the urgent channel
  /// matches the effective setting (the safety profile is waited for too).
  Future<void> ensureLoaded() async {
    await (_loading ??= _load());
    var waited = 0;
    while (!ref.read(providerOfSafetyProfileLoaded) && waited < 50) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      waited++;
    }
    await _applyChannel(state.strongVibration);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _explicitVibration = prefs.getBool(_vibrationKey);
    _prefsLoaded = true;
    _recompute();
  }

  Future<void> setStrongVibration(final bool value) async {
    _explicitVibration = value;
    _prefsLoaded = true;
    _recompute();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
  }

  /// Posts a test notification on the urgent channel; false when the
  /// system blocks ALRT notifications.
  Future<bool> testStrongVibration() async {
    final shown = await LocalNotificationService.instance
        .showStrongVibrationTest();
    // The test creates the urgent channel as a side effect, so the channel
    // state is unknown again: the next recompute re-applies the setting.
    _appliedChannel = null;
    return shown;
  }

  Future<void> setReadAloud(final bool value) async {
    // Stored for a future read-aloud setting; nothing reads it back yet.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_readAloudKey, value);
  }

  void _recompute() {
    final cohorts = ref.read(providerOfSafetyProfile);
    final settings = AccessibleAlertsSettings(
      strongVibration:
          _explicitVibration ?? cohorts.contains(SafetyCohort.deaf),
      // No switch in Notifications. Read-aloud is on only when the safety
      // profile says Vision impairment; everyone else uses Listen.
      readAloud: false,
    );
    state = settings;
    if (_prefsLoaded && ref.read(providerOfSafetyProfileLoaded)) {
      unawaited(_applyChannel(settings.strongVibration));
    }
  }

  /// Creates or removes the Android urgent channel (long vibration pattern)
  /// so it matches [enabled], once per change. ON always has the channel,
  /// OFF never does (see LocalNotificationService.applyStrongVibrationChannel).
  Future<void> _applyChannel(final bool enabled) async {
    if (_appliedChannel == enabled) return;
    _appliedChannel = enabled;
    await LocalNotificationService.instance.applyStrongVibrationChannel(
      enabled,
    );
  }
}

final providerOfAccessibleAlerts =
    NotifierProvider<AccessibleAlertsNotifier, AccessibleAlertsSettings>(
      AccessibleAlertsNotifier.new,
    );
