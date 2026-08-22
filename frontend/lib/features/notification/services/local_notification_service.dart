import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Displays push notifications received while the app is in the FOREGROUND.
///
/// FCM only renders notifications automatically when the app is backgrounded
/// or terminated; foreground messages are delivered silently to
/// `FirebaseMessaging.onMessage` and were previously dropped entirely.
///
/// - iOS: foreground presentation is delegated to the OS via
///   [FirebaseMessaging.setForegroundNotificationPresentationOptions].
/// - Android: this service renders a local notification on a high-importance
///   channel, carrying the FCM data payload so a tap deep-links exactly like
///   a tray notification would.
///
/// Action buttons are deterministic from the alert's severity band and never
/// include Mute (that lives in the OS long-press menu and in-app settings):
/// - INFO/MONITOR (incl. AWS Advice): View details + Follow for updates —
///   or Open map instead of Follow when the alert is already followed.
/// - ACTION/CRITICAL: I'm safe + View details. "I'm safe" fires the same
///   family check-in as the in-app button — one mechanic, two surfaces.
class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const _channelId = 'alrt_alerts';
  static const _channelName = 'Safety alerts';
  static const _channelDescription =
      'Hazard alerts and family safety notifications';

  // Accessible delivery: ACTION/CRITICAL alerts land here when the user has
  // strong vibration on (deaf or hard of hearing). The pattern is long and
  // unmistakable; channel settings are fixed at creation, which is why this
  // is a second channel rather than a per-notification tweak.
  static const _urgentChannelId = 'alrt_alerts_urgent';
  static const _urgentChannelName = 'Urgent alerts (strong vibration)';
  static const _urgentChannelDescription =
      'Take-action and critical alerts with long strong vibration';

  // Action button ids, shared by Android actions and iOS category actions.
  static const actionViewDetails = 'alrt_view_details';
  static const actionFollow = 'alrt_follow_updates';
  static const actionOpenMap = 'alrt_open_map';
  static const actionImSafe = 'alrt_im_safe';

  // iOS notification category identifiers, registered at initialize so the
  // native side can attach the matching action set.
  static const categoryLowBand = 'ALRT_LOW_BAND';
  static const categoryLowBandFollowing = 'ALRT_LOW_BAND_FOLLOWING';
  static const categoryHighBand = 'ALRT_HIGH_BAND';
  static const categoryCheckInPrompt = 'ALRT_CHECKIN_PROMPT';

  /// Backend push type for a scheduled daily check-in prompt (the only
  /// family push that carries an action button).
  static const _typeScheduledCheckInPrompt = 'familyScheduledCheckInPrompt';

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  void Function(RemoteMessage message)? _onNotificationTap;
  void Function(String alertId)? _onFollowAction;
  void Function()? _onOpenMapAction;
  void Function()? _onImSafeAction;
  bool Function(String alertId)? _isFollowing;
  bool Function()? _useStrongVibration;

  /// Initializes the plugin and wires the callbacks. Safe to call once at
  /// startup; subsequent calls only replace the callbacks.
  ///
  /// [isFollowing] decides at display time whether the low-band second action
  /// is "Follow for updates" or "Open map" (already following).
  Future<void> initialize({
    required void Function(RemoteMessage message) onNotificationTap,
    void Function(String alertId)? onFollowAction,
    void Function()? onOpenMapAction,
    void Function()? onImSafeAction,
    bool Function(String alertId)? isFollowing,
    bool Function()? useStrongVibration,
  }) async {
    _onNotificationTap = onNotificationTap;
    _onFollowAction = onFollowAction;
    _onOpenMapAction = onOpenMapAction;
    _onImSafeAction = onImSafeAction;
    _isFollowing = isFollowing;
    _useStrongVibration = useStrongVibration;
    if (_initialized || kIsWeb) return;

    // Let iOS present foreground notifications natively.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    final initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // Permissions are requested through firebase_messaging already.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: _darwinCategories(),
      ),
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _urgentChannelId,
        _urgentChannelName,
        description: _urgentChannelDescription,
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList(
          [0, 700, 300, 700, 300, 1200, 400, 700, 300, 700, 300, 1200],
        ),
      ),
    );

    _initialized = true;
  }

  /// Shows a foreground FCM message as a local notification (Android only —
  /// iOS presents it natively through the foreground presentation options).
  Future<void> showFromRemoteMessage(RemoteMessage message) async {
    if (kIsWeb || !Platform.isAndroid) return;
    if (!_initialized) return;

    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String?;
    final body = notification?.body ?? message.data['body'] as String?;
    if (title == null && body == null) return;

    final actions = _actionsFor(message.data);
    final urgent = _isUrgent(message.data) &&
        (_useStrongVibration?.call() ?? false);

    await _plugin.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          urgent ? _urgentChannelId : _channelId,
          urgent ? _urgentChannelName : _channelName,
          channelDescription:
              urgent ? _urgentChannelDescription : _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          actions: actions,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// ACTION and CRITICAL hazard pushes qualify for accessible delivery.
  bool _isUrgent(Map<String, dynamic> data) {
    final band =
        (_hazardPayloadOf(data)?['severityBand'] as String?)?.toLowerCase();
    return band == 'action' || band == 'critical';
  }

  /// Band-matched action buttons. Only hazard pushes (payloads carrying a
  /// severityBand) get actions; family/system pushes render button-free —
  /// except the scheduled check-in prompt, which gets one-tap "I'm safe".
  List<AndroidNotificationAction>? _actionsFor(Map<String, dynamic> data) {
    if (data['notificationType'] == _typeScheduledCheckInPrompt) {
      return const [
        AndroidNotificationAction(
          actionImSafe,
          "I'm safe",
          showsUserInterface: true,
        ),
      ];
    }

    final hazard = _hazardPayloadOf(data);
    final alertId = hazard?['id']?.toString();
    final band = (hazard?['severityBand'] as String?)?.toLowerCase();
    if (band == null || alertId == null || alertId.isEmpty) return null;

    const viewDetails = AndroidNotificationAction(
      actionViewDetails,
      'View details',
      showsUserInterface: true,
    );
    if (band == 'action' || band == 'critical') {
      return const [
        AndroidNotificationAction(
          actionImSafe,
          "I'm safe",
          showsUserInterface: true,
        ),
        viewDetails,
      ];
    }

    final following = _isFollowing?.call(alertId) ?? false;
    return [
      viewDetails,
      if (following)
        const AndroidNotificationAction(
          actionOpenMap,
          'Open map',
          showsUserInterface: true,
        )
      else
        const AndroidNotificationAction(
          actionFollow,
          'Follow for updates',
          showsUserInterface: true,
        ),
    ];
  }

  /// The iOS action sets mirroring [_actionsFor], keyed by category id. The
  /// display side (FCM apns `category`) is app-side only, so these register
  /// the identifiers for whenever a category is attached.
  List<DarwinNotificationCategory> _darwinCategories() {
    final viewDetails = DarwinNotificationAction.plain(
      actionViewDetails,
      'View details',
      options: {DarwinNotificationActionOption.foreground},
    );
    return [
      DarwinNotificationCategory(
        categoryLowBand,
        actions: [
          viewDetails,
          DarwinNotificationAction.plain(
            actionFollow,
            'Follow for updates',
            options: {DarwinNotificationActionOption.foreground},
          ),
        ],
      ),
      DarwinNotificationCategory(
        categoryLowBandFollowing,
        actions: [
          viewDetails,
          DarwinNotificationAction.plain(
            actionOpenMap,
            'Open map',
            options: {DarwinNotificationActionOption.foreground},
          ),
        ],
      ),
      DarwinNotificationCategory(
        categoryHighBand,
        actions: [
          DarwinNotificationAction.plain(
            actionImSafe,
            "I'm safe",
            options: {DarwinNotificationActionOption.foreground},
          ),
          viewDetails,
        ],
      ),
      DarwinNotificationCategory(
        categoryCheckInPrompt,
        actions: [
          DarwinNotificationAction.plain(
            actionImSafe,
            "I'm safe",
            options: {DarwinNotificationActionOption.foreground},
          ),
        ],
      ),
    ];
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final data = Map<String, dynamic>.from(
        jsonDecode(payload) as Map<dynamic, dynamic>,
      );

      switch (response.actionId) {
        case actionImSafe:
          _onImSafeAction?.call();
          return;
        case actionOpenMap:
          _onOpenMapAction?.call();
          return;
        case actionFollow:
          final alertId = _hazardPayloadOf(data)?['id']?.toString();
          if (alertId != null && alertId.isNotEmpty) {
            _onFollowAction?.call(alertId);
          }
          // Fall through: land on the alert so the Following state is
          // visible right away.
          break;
        default:
          break;
      }

      // Body tap and "View details" rebuild a RemoteMessage so they flow
      // through the exact same deep-link handling as tray notification taps.
      _onNotificationTap?.call(RemoteMessage(data: data.cast()));
    } catch (_) {
      // Malformed payload — nothing to deep-link into.
    }
  }

  /// Decodes the nested hazard payload (`data['payload']` is the JSON hazard
  /// sent by the backend push sender), or null when absent/malformed.
  static Map<String, dynamic>? _hazardPayloadOf(Map<String, dynamic> data) {
    final raw = data['payload'];
    if (raw is! String || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
