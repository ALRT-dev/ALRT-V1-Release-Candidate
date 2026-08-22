import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/notification/providers/accessible_alerts_provider.dart';
import 'package:hazard_app/features/notification/providers/repository_providers.dart';
import 'package:hazard_app/features/notification/repositories/notification_repository.dart';
import 'package:hazard_app/features/notification/services/local_notification_service.dart';
import 'package:hazard_app/features/search/models/hazard_search_params.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/followed_alerts_provider.dart';
import 'package:hazard_app/features/shared/providers/navigator_key_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/alert_speech_service.dart';
import 'package:hazard_app/features/shared/services/hazard_service.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

class NotificationService {
  NotificationService(final Ref ref) : _ref = ref;

  final Ref _ref;
  NotificationRepository get _notificationRepository =>
      _ref.read(providerOfNotificationRepository);
  HazardService get _hazardService => _ref.read(providerOfHazardService);

  StreamSubscription<RemoteMessage>? _remoteMessageStreamSub;
  StreamSubscription<RemoteMessage>? _foregroundMessageStreamSub;

  /// Fetches the hazards that the user has subscribed to for notifications.
  Future<Either<List<Hazard>, AppError>> getNotificationsFeed({
    final HazardSearchParams? searchParams,
  }) async {
    // If no category IDs are provided, return an empty list immediately.
    if (searchParams?.categoryIds.isEmpty ?? true) {
      return Success(<Hazard>[]);
    }

    // If all hazard source filters are false, return an empty list immediately.
    if (!(searchParams?.awsEmergency ?? false) &&
        !(searchParams?.awsWatchAndAct ?? false) &&
        !(searchParams?.awsAdvice ?? false) &&
        !(searchParams?.officialNonAws ?? false) &&
        !(searchParams?.userReported ?? false)) {
      return Success(<Hazard>[]);
    }

    final result = await _notificationRepository.getNotificationsFeed(
      searchParams: searchParams,
    );

    final success = await result.whenSuccess(
      _hazardService.populateHazardsWithRequiredData,
    );

    return result.copyWith(
      success: (_) => success,
    );
  }

  /// Gets the fcm token from Firebase Cloud Messaging.
  ///
  /// The [vapidKey] is the public key that is used for Web Push notifications.
  Future<Either<String, AppError>> getFCMToken({
    final String? vapidKey,
  }) {
    return _notificationRepository.getFCMToken(
      vapidKey: vapidKey,
    );
  }

  /// Current notification permission without triggering the OS prompt.
  Future<Either<AuthorizationStatus, AppError>>
  getNotificationPermissionStatus() {
    return _notificationRepository.getNotificationPermissionStatus();
  }

  /// Sends the push notification [token] in the server.
  Future<Either<void, AppError>> sendPushNotificationToken({
    required final String token,
  }) {
    return _notificationRepository.sendPushNotificationToken(
      token: token,
    );
  }

  /// Calls [onMessageReceived] callback when the remote message is received from the push notification.
  Future<void> handlePushNotificationMessage({
    required final Function(RemoteMessage) onMessageReceived,
  }) async {
    final initialMessageResult = await _notificationRepository
        .getInitialPushNotificationMessage();

    initialMessageResult.whenSuccess((remoteMessage) {
      if (remoteMessage != null) {
        onMessageReceived(remoteMessage);
      }
    });

    _remoteMessageStreamSub = _notificationRepository
        .onPushNotificationMessageOpenedApp()
        .listen(onMessageReceived);

    // Foreground messages: FCM does not display these automatically. Show
    // them via the local-notification layer (Android) / native presentation
    // (iOS); a tap routes into the same deep-link callback.
    await LocalNotificationService.instance.initialize(
      onNotificationTap: onMessageReceived,
      isFollowing: (alertId) =>
          _ref.read(providerOfFollowedAlerts).contains(alertId),
      onFollowAction: (alertId) =>
          _ref.read(providerOfFollowedAlerts.notifier).follow(alertId),
      onOpenMapAction: () => _goToHomeTab(HomeTab.map),
      onImSafeAction: _handleImSafeAction,
      useStrongVibration: () =>
          _ref.read(providerOfAccessibleAlerts).strongVibration,
    );
    _foregroundMessageStreamSub = _notificationRepository
        .onForegroundPushNotificationMessage()
        .listen((message) {
          LocalNotificationService.instance.showFromRemoteMessage(message);
          _maybeSpeak(message);
        });
  }

  /// Accessible delivery for vision impairment: with read-aloud on, an
  /// ACTION/CRITICAL alert arriving while the app is open is spoken once,
  /// on-device. Lower bands stay quiet; the Listen button on every alert
  /// detail covers them on demand.
  void _maybeSpeak(final RemoteMessage message) {
    if (!_ref.read(providerOfAccessibleAlerts).readAloud) return;

    final data = message.data;
    final band = _severityBandOf(data);
    if (band != 'action' && band != 'critical') return;

    final title = message.notification?.title ?? data['title'] as String?;
    final body = message.notification?.body ?? data['body'] as String?;
    final text = [
      band == 'critical' ? 'Critical alert.' : 'Take action alert.',
      if (title != null && title.isNotEmpty) title,
      if (body != null && body.isNotEmpty) body,
    ].join(' ');
    _ref.read(providerOfAlertSpeech).speak(text);
  }

  /// Same envelope as LocalNotificationService: the hazard rides in
  /// data['payload'] as a JSON string.
  String? _severityBandOf(final Map<String, dynamic> data) {
    final raw = data['payload'];
    if (raw is! String || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return (decoded['severityBand'] as String?)?.toLowerCase();
    } catch (_) {
      return null;
    }
  }

  /// "I'm safe" on an ACTION/CRITICAL notification fires the same family
  /// check-in as the in-app button when a circle exists; without one it just
  /// lands on the family tab so the user can set a circle up.
  void _handleImSafeAction() {
    if (_ref.read(providerOfFamily).circle != null) {
      _ref.read(providerOfFamily.notifier).checkIn();
    }
    _goToHomeTab(HomeTab.family);
  }

  /// Navigates to the home shell and selects [tab] once the route settles
  /// (same pattern as the widget deep-link handler).
  void _goToHomeTab(final HomeTab tab) {
    final context = _ref.read(providerOfGlobalNavigatorKey).currentContext;
    if (context != null && context.mounted) context.go(HomeScreen.route);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ref.read(providerOfHomeTab.notifier).state = tab;
    });
  }

  /// Disposes the stream.
  void disposePushNotificationMessageListener() {
    _remoteMessageStreamSub?.cancel();
    _remoteMessageStreamSub = null;
    _foregroundMessageStreamSub?.cancel();
    _foregroundMessageStreamSub = null;
  }
}
