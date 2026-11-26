import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/endpoints.dart';
import 'package:hazard_app/features/shared/providers/dio_instance_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Alert ids the user follows.
///
/// Kept on the phone for the Follow/Following UI, and mirrored to the server
/// (owner decision D7, 16 Nov 2026) so a followed alert pushes once when its
/// agency level changes and once when it ends. A failed server call never
/// blocks the tap; the next toggle or app start retries.
class FollowedAlertsNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'followed_alert_ids';

  @override
  Set<String> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_prefsKey) ?? const []).toSet();
    // Re-send follows made while offline or before the server supported them.
    for (final id in state) {
      unawaited(_sync(id, follow: true));
    }
  }

  Future<void> toggle(final String alertId) async {
    final next = {...state};
    final following = !next.remove(alertId);
    if (following) next.add(alertId);
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, next.toList());
    unawaited(_sync(alertId, follow: following));
  }

  Future<void> _sync(final String alertId, {required final bool follow}) async {
    try {
      final dio = ref.read(providerOfDioInstance(true));
      final url = '$kUrlHazards/$alertId/follow';
      if (follow) {
        await dio.post<dynamic>(url);
      } else {
        await dio.delete<dynamic>(url);
      }
    } catch (_) {
      // Signed out, offline, or an older server: the phone list still works.
    }
  }

  /// Follow only, never unfollow — used by the notification action so a
  /// repeat tap cannot silently unfollow an alert.
  Future<void> follow(final String alertId) async {
    if (state.contains(alertId)) return;
    await toggle(alertId);
  }
}

final providerOfFollowedAlerts =
    NotifierProvider<FollowedAlertsNotifier, Set<String>>(
  FollowedAlertsNotifier.new,
);
