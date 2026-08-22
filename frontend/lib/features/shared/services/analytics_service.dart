import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';

/// Thin wrapper over Firebase Analytics. Every call is fire-and-forget and
/// swallow-on-error: analytics must never affect app behaviour.
class AnalyticsService {
  AnalyticsService._();

  static void _logEvent(String name, [Map<String, Object>? parameters]) {
    FirebaseAnalytics.instance
        .logEvent(name: name, parameters: parameters)
        .catchError((Object e) => log('analytics: $name failed: $e'));
  }

  /// An alert was shared externally (share sheet opened).
  static void alertShared({required String hazardId, required String from}) {
    _logEvent('alert_shared', {'hazard_id': hazardId, 'from': from});
  }

  /// The app itself was shared (QR sheet: copy or the OS share sheet).
  static void appShared({required String from}) {
    _logEvent('app_shared', {'from': from});
  }

  /// The user enabled notifications from the priming screen.
  static void notificationsEnabled({required String from}) {
    _logEvent('notifications_enabled', {'from': from});
  }

  /// The user snoozed the notification priming screen.
  static void notificationPrimingSnoozed() {
    _logEvent('notification_priming_snoozed');
  }

  /// A hazard report was submitted by the user.
  static void reportSubmitted({String? categoryId}) {
    _logEvent('report_submitted', {
      if (categoryId != null) 'category_id': categoryId,
    });
  }

  /// A family check-in was sent.
  static void familyCheckIn() => _logEvent('family_check_in');

  /// A family SOS was triggered.
  static void familySosTriggered() => _logEvent('family_sos_triggered');

  /// A one-time location snapshot was shared.
  static void familySnapshotShared({required String via}) {
    _logEvent('family_snapshot_shared', {'via': via});
  }

  /// A safety guide was completed.
  static void guideCompleted({required String guideSlug}) {
    _logEvent('guide_completed', {'guide_slug': guideSlug});
  }

  /// The in-app review dialog was requested.
  static void reviewRequested() => _logEvent('review_requested');
}
