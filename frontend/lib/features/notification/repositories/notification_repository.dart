import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hazard_app/api/rest_client.dart';
import 'package:hazard_app/features/search/models/hazard_search_params.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:hazard_app/features/shared/utils/error_codes.dart';

abstract class NotificationRepository {
  Future<Either<List<Hazard>, AppError>> getNotificationsFeed({
    final HazardSearchParams? searchParams,
  });

  Future<Either<String, AppError>> getFCMToken({
    final String? vapidKey,
  });

  /// Reads the current notification permission WITHOUT triggering the OS
  /// prompt — used to decide whether to show the priming screen first.
  Future<Either<AuthorizationStatus, AppError>>
  getNotificationPermissionStatus();

  Future<Either<void, AppError>> sendPushNotificationToken({
    required final String token,
  });

  /// Removes this phone's token for the signed-in account and drops the
  /// local FCM token, so the next account starts with a fresh one.
  Future<Either<void, AppError>> unregisterPushNotificationToken();

  /// Emits whenever Firebase rotates this phone's token.
  Stream<String> onTokenRefresh();

  /// A test push to the caller's own phones only.
  Future<Either<Map<String, dynamic>, AppError>> sendTestNotification({
    required bool urgent,
  });

  Future<Either<RemoteMessage?, AppError>> getInitialPushNotificationMessage();

  Stream<RemoteMessage> onPushNotificationMessageOpenedApp();

  Stream<RemoteMessage> onForegroundPushNotificationMessage();
}

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required final RestClient restClient,
    required final FirebaseMessaging firebaseMessaging,
  }) : _restClient = restClient,
       _firebaseMessaging = firebaseMessaging;

  final RestClient _restClient;
  final FirebaseMessaging _firebaseMessaging;

  @override
  Future<Either<List<Hazard>, AppError>> getNotificationsFeed({
    final HazardSearchParams? searchParams,
  }) async {
    return runAsyncCall(
      name: 'getNotificationsFeed',
      future: () async {
        final result = await _restClient.getNotificationsFeed(
          searchParams: searchParams,
        );
        return Success(result);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<String, AppError>> getFCMToken({
    String? vapidKey,
  }) {
    return runAsyncCall(
      name: 'getNotificationToken',
      future: () async {
        final notificationSettings = await _firebaseMessaging.requestPermission(
          carPlay: false,
        );
        // Provisional (iOS quiet delivery) is a granted permission too:
        // the token must be registered or those users never get a push.
        if (notificationSettings.authorizationStatus ==
                AuthorizationStatus.authorized ||
            notificationSettings.authorizationStatus ==
                AuthorizationStatus.provisional) {
          final token = await _firebaseMessaging.getToken(
            vapidKey: vapidKey,
          );

          if (token == null) {
            throw AppError(
              message: 'Failed to get notification token.',
            );
          }

          return Success(token);
        } else if (notificationSettings.authorizationStatus ==
                AuthorizationStatus.denied ||
            notificationSettings.authorizationStatus ==
                AuthorizationStatus.notDetermined) {
          throw AppError(
            code: ksNotificationPermissionDenied,
            message:
                'User declined or has not accepted the notification permission.',
          );
        }

        throw AppError(
          code: ksUnknownErrorCode,
          message: ksUnknownErrorMessage,
        );
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<AuthorizationStatus, AppError>>
  getNotificationPermissionStatus() {
    return runAsyncCall(
      name: 'getNotificationPermissionStatus',
      future: () async {
        final settings = await _firebaseMessaging.getNotificationSettings();
        return Success(settings.authorizationStatus);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> sendPushNotificationToken({
    required String token,
  }) {
    return runAsyncCall(
      name: 'sendPushNotificationToken',
      future: () async {
        await _restClient.sendPushNotificationToken(
          token: token,
          platform: kIsWeb
              ? 'web'
              : Platform.isIOS
              ? 'ios'
              : 'android',
        );
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<void, AppError>> unregisterPushNotificationToken() {
    return runAsyncCall(
      name: 'unregisterPushNotificationToken',
      future: () async {
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _restClient.deletePushNotificationToken(token: token);
        }
        // A new token is minted on the next registration, so a phone that
        // changes hands cannot be reached with the old one.
        await _firebaseMessaging.deleteToken();
        return Success(null);
      },
      onError: Failure.new,
    );
  }

  @override
  Stream<String> onTokenRefresh() => _firebaseMessaging.onTokenRefresh;

  @override
  Future<Either<Map<String, dynamic>, AppError>> sendTestNotification({
    required bool urgent,
  }) {
    return runAsyncCall(
      name: 'sendTestNotification',
      future: () async {
        final res = await _restClient.sendTestNotification(urgent: urgent);
        final data = res.data;
        return Success(
          data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
        );
      },
      onError: Failure.new,
    );
  }

  @override
  Future<Either<RemoteMessage?, AppError>> getInitialPushNotificationMessage() {
    return runAsyncCall(
      name: 'getInitialNotificationMessage',
      future: () async {
        final remoteMessage = await _firebaseMessaging.getInitialMessage();
        return Success(remoteMessage);
      },
      onError: Failure.new,
    );
  }

  @override
  Stream<RemoteMessage> onPushNotificationMessageOpenedApp() {
    return FirebaseMessaging.onMessageOpenedApp;
  }

  @override
  Stream<RemoteMessage> onForegroundPushNotificationMessage() {
    return FirebaseMessaging.onMessage;
  }
}
