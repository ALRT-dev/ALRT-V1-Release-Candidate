import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hazard_app/api/endpoints.dart';
import 'package:hazard_app/features/notification/services/wearable_push.dart';
import 'package:hazard_app/features/shared/enums/shared_prefs_key_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wearable notification pilot: the two entry points Android runs while the
/// app is in the background or closed, and the check-in action they share
/// with the foreground app.
///
/// 1. [alrtWearableBackgroundMessageHandler] receives the backend's
///    data-only pilot push and draws it with action buttons. Any other
///    message is ignored here (the system or the foreground app draws it
///    as today).
/// 2. [alrtWearableBackgroundActionHandler] runs when `Check in to
///    <circle>` is tapped in the tray or on a mirrored watch notification:
///    it posts the check-in with NO location, using the phone's own
///    session, and then shows a follow-up notification with the server's
///    answer. Opening the notification itself sends nothing.
///
/// Both run in their own isolate with no Riverpod and no loaded .env, so
/// they read the API base URL and the session from SharedPreferences,
/// written by the foreground app.

/// Registered with FirebaseMessaging.onBackgroundMessage at start-up.
@pragma('vm:entry-point')
Future<void> alrtWearableBackgroundMessageHandler(
  final RemoteMessage message,
) async {
  if (kIsWeb || !Platform.isAndroid) return;
  final parsed = WearablePushMessage.parse(message.data);
  if (parsed == null) return;
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await WearableNotifications.instance.show(parsed);
}

/// Registered as onDidReceiveBackgroundNotificationResponse.
@pragma('vm:entry-point')
Future<void> alrtWearableBackgroundActionHandler(
  final NotificationResponse response,
) async {
  if (response.actionId != WearablePush.actionCheckInCircle) return;
  // The plugin does not await this handler: anything thrown here would be
  // an uncaught zone error with nobody to see it.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    final parsed = WearableNotifications.parsePayload(response.payload);
    if (parsed == null || !parsed.isCheckInRequest) return;
    await WearableCheckInAction().perform(parsed);
  } catch (e) {
    debugPrint('wearable check-in action failed: $e');
  }
}

/// Draws pilot pushes with their buttons. Owns its own plugin instance so
/// it works in a background isolate; the foreground app's
/// LocalNotificationService registers the same channels, ids and
/// categories, so the two never disagree.
class WearableNotifications {
  WearableNotifications._();

  static final WearableNotifications instance = WearableNotifications._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// The plugin is a singleton. When the foreground app has already
  /// initialised it (with its tap handler and iOS categories), this must
  /// not initialise it again, or the tap handler would be replaced.
  void markInitialized() => _initialized = true;

  static WearablePushMessage? parsePayload(final String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return null;
      return WearablePushMessage.parse(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      // A tap on the body or on "Open on phone" from a background isolate
      // has no app to route into; Android launches the app and the
      // foreground LocalNotificationService handles the response.
      onDidReceiveBackgroundNotificationResponse:
          alrtWearableBackgroundActionHandler,
    );
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    // The default channel always exists. The urgent channel is created by
    // the foreground app only while strong vibration is on; a push naming
    // a missing channel falls back to the default one, which keeps the
    // user's choice (see LocalNotificationService.applyStrongVibrationChannel).
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        WearablePush.channelDefault,
        'Safety alerts',
        description: 'Hazard alerts and family safety notifications',
        importance: Importance.max,
      ),
    );
    _initialized = true;
  }

  /// Which buttons a pilot push carries. A check-in request gets the
  /// named check-in (handled in the background, no screen) and "Open on
  /// phone"; an SOS gets "Open on phone" only: nothing about an SOS is
  /// ever acknowledged from a notification.
  static List<AndroidNotificationAction> actionsFor(
    final WearablePushMessage m,
  ) {
    return [
      if (m.isCheckInRequest)
        AndroidNotificationAction(
          WearablePush.actionCheckInCircle,
          m.checkInActionLabel,
          showsUserInterface: false,
          cancelNotification: false,
        ),
      const AndroidNotificationAction(
        WearablePush.actionOpenOnPhone,
        'Open on phone',
        showsUserInterface: true,
      ),
    ];
  }

  /// The urgent channel exists only while the user's strong-vibration
  /// switch is on (LocalNotificationService.applyStrongVibrationChannel).
  /// Drawing on it when it does not exist would create it with a default
  /// pattern and defeat the switch, so an urgent push goes to the urgent
  /// channel only if that channel already exists, and a server-named
  /// channel is never created from here.
  Future<String> _channelFor(final WearablePushMessage m) async {
    if (!m.urgent) return WearablePush.channelDefault;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final channels = await android?.getNotificationChannels();
      final exists =
          channels?.any((c) => c.id == WearablePush.channelUrgent) ?? false;
      return exists ? WearablePush.channelUrgent : WearablePush.channelDefault;
    } catch (_) {
      return WearablePush.channelDefault;
    }
  }

  Future<void> show(final WearablePushMessage m) async {
    if (kIsWeb || !Platform.isAndroid) return;
    await _ensureInitialized();
    final channelId = await _channelFor(m);
    final urgent = channelId == WearablePush.channelUrgent;
    await _plugin.show(
      m.notificationId,
      m.title,
      m.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          urgent ? 'Urgent alerts (strong vibration)' : 'Safety alerts',
          channelDescription: urgent
              ? 'Take-action and critical alerts with long strong vibration'
              : 'Hazard alerts and family safety notifications',
          importance: Importance.max,
          priority: Priority.high,
          // Same lock-screen rule as the server-drawn copy: the phone's own
          // setting decides whether the body shows while locked.
          visibility: NotificationVisibility.private,
          category: urgent
              ? AndroidNotificationCategory.alarm
              : AndroidNotificationCategory.message,
          tag: m.collapseKey,
          actions: actionsFor(m),
        ),
      ),
      payload: jsonEncode(m.toData()),
    );
  }

  /// The follow-up beside the request: what happened to the check-in.
  Future<void> showFollowUp(
    final WearablePushMessage m,
    final WearableFollowUp followUp,
  ) async {
    if (kIsWeb || !Platform.isAndroid) return;
    await _ensureInitialized();
    await _plugin.show(
      m.followUpNotificationId,
      followUp.title,
      followUp.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          WearablePush.channelDefault,
          'Safety alerts',
          channelDescription: 'Hazard alerts and family safety notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          visibility: NotificationVisibility.private,
          category: AndroidNotificationCategory.status,
        ),
      ),
      payload: jsonEncode(m.toData()),
    );
  }

  /// Removes the request notification once it has been answered, so the
  /// tray (and a mirrored watch) no longer offers a button that would do
  /// nothing.
  Future<void> dismiss(final WearablePushMessage m) async {
    if (kIsWeb || !Platform.isAndroid) return;
    await _ensureInitialized();
    await _plugin.cancel(m.notificationId, tag: m.collapseKey);
  }
}

/// Posts a check-in with no location for a pilot request, using the
/// phone's stored session, and reports the outcome as a follow-up
/// notification. Safe to call from the background isolate and from the
/// foreground app (which then reloads its circle state).
class WearableCheckInAction {
  /// Forgets which asks were answered from a notification on this phone.
  /// Called on sign-out and account deletion, with the rest of the
  /// phone's cached state, so the next account starts clean.
  static Future<void> clearLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPrefsKey.wearableAnsweredRequestIds.name);
  }

  WearableCheckInAction({
    final Dio? dio,
    final Future<SharedPreferences> Function()? prefs,
    final WearableNotifications? notifications,
    final DateTime Function()? now,
  }) : _dio = dio,
       _prefs = prefs ?? SharedPreferences.getInstance,
       _notifications = notifications ?? WearableNotifications.instance,
       _now = now ?? DateTime.now;

  final Dio? _dio;
  final Future<SharedPreferences> Function() _prefs;
  final WearableNotifications _notifications;
  final DateTime Function() _now;

  static const _timeout = Duration(seconds: 15);

  Future<WearableCheckInOutcome> perform(final WearablePushMessage m) async {
    final requestId = m.requestId;
    final circleName = m.circleName ?? 'your circle';
    if (requestId == null || requestId.isEmpty) {
      await _report(m, WearableCheckInOutcome.failed, circleName);
      return WearableCheckInOutcome.failed;
    }
    final prefs = await _prefs();
    // The background engine is reused across taps: without a reload the
    // cache could hold the previous account's session or answered list.
    await prefs.reload();

    // Answered already from a notification on this phone: say so, send
    // nothing. The server would dedupe anyway (same clientKey), but the
    // user should not see a second "sending".
    final answered =
        prefs.getStringList(SharedPrefsKey.wearableAnsweredRequestIds.name) ??
        const <String>[];
    if (answered.contains(requestId)) {
      await _report(m, WearableCheckInOutcome.alreadyDone, circleName);
      return WearableCheckInOutcome.alreadyDone;
    }

    final baseUrl = prefs.getString(SharedPrefsKey.apiBaseUrl.name);
    var accessToken = prefs.getString(SharedPrefsKey.accessToken.name);
    if (baseUrl == null || baseUrl.isEmpty || accessToken == null) {
      await _report(m, WearableCheckInOutcome.signedOut, circleName);
      return WearableCheckInOutcome.signedOut;
    }

    final dio = _dio ?? Dio(BaseOptions(baseUrl: baseUrl));
    final body = {
      'requestId': requestId,
      'clientKey': checkInClientKeyFor(requestId),
    };
    final query = {if (m.circleId != null) 'circleId': m.circleId};

    Future<int?> post(final String token) async {
      try {
        final res = await dio
            .post<dynamic>(
              kUrlFamilyCheckIn,
              data: body,
              queryParameters: query,
              options: Options(
                headers: {'Authorization': 'Bearer $token'},
                validateStatus: (_) => true,
                sendTimeout: _timeout,
                receiveTimeout: _timeout,
              ),
            )
            .timeout(_timeout);
        return res.statusCode;
      } on TimeoutException {
        return null;
      } on DioException catch (e) {
        // A transport failure (offline, DNS, reset) is a plain failure:
        // nothing reached the server. A timeout after sending is not.
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          return -1;
        }
        return null;
      } catch (_) {
        return null;
      }
    }

    var status = await post(accessToken);
    if (status == 401) {
      final refreshed = await _refreshAccessToken(dio, prefs);
      if (refreshed != null) {
        accessToken = refreshed;
        status = await post(accessToken);
      }
    }
    final firstUnanswered = status == null;
    if (status == null) {
      // Sent, no answer: one more attempt with the SAME key. The server
      // treats a repeat as the same check-in, so this can never create a
      // second row or a second push to the circle.
      status = await post(accessToken);
      // If the first attempt may have reached the server but the retry
      // could not connect, the truth is "uncertain", not "offline".
      if (status == -1 && firstUnanswered) status = null;
    }

    WearableCheckInOutcome outcome;
    String? reason;
    if (status == -1) {
      outcome = WearableCheckInOutcome.failed;
      reason = 'Your phone is offline.';
    } else {
      final mapped = outcomeForStatus(status);
      outcome = mapped.outcome;
      reason = mapped.reason;
    }

    if (outcome == WearableCheckInOutcome.confirmed) {
      // Bookkeeping must never cost the user the follow-up that says the
      // server confirmed.
      try {
        await prefs.setStringList(
          SharedPrefsKey.wearableAnsweredRequestIds.name,
          rememberAnsweredRequest(answered, requestId),
        );
        await _notifications.dismiss(m);
      } catch (_) {
        // The follow-up below still goes out.
      }
    }
    await _report(m, outcome, circleName, reason: reason);
    return outcome;
  }

  Future<void> _report(
    final WearablePushMessage m,
    final WearableCheckInOutcome outcome,
    final String circleName, {
    final String? reason,
  }) {
    return _notifications.showFollowUp(
      m,
      WearableFollowUp.forOutcome(
        outcome,
        circleName: circleName,
        at: _now(),
        reason: reason,
      ),
    );
  }

  /// The same refresh the app's AuthInterceptor performs, kept minimal.
  Future<String?> _refreshAccessToken(
    final Dio dio,
    final SharedPreferences prefs,
  ) async {
    final refreshToken = prefs.getString(SharedPrefsKey.refreshToken.name);
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final res = await dio
          .post<Map<String, dynamic>>(
            kUrlRefreshToken,
            data: {'refreshToken': refreshToken},
            options: Options(validateStatus: (_) => true),
          )
          .timeout(_timeout);
      final token = res.data?['accessToken'];
      if (res.statusCode != 200 || token is! String || token.isEmpty) {
        return null;
      }
      await prefs.setString(SharedPrefsKey.accessToken.name, token);
      return token;
    } catch (_) {
      return null;
    }
  }
}
