import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/home/providers/states/home_provider_state.dart';
import 'package:hazard_app/features/notification/providers/service_providers.dart';
import 'package:hazard_app/features/notification/services/notification_service.dart';
import 'package:hazard_app/features/shared/enums/shared_prefs_key_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/repositories/shared_prefs_repository.dart';
import 'package:hazard_app/features/shared/services/analytics_service.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

/// How long a "Maybe later" on the priming screen silences the re-ask.
const _kPrimingSnooze = Duration(days: 5);

final providerOfHome =
    StateNotifierProvider.autoDispose<HomeProvider, HomeProviderState>(
      (ref) => HomeProvider(
        ref: ref,
        state: HomeProviderState(),
      ),
    );

class HomeProvider extends StateNotifier<HomeProviderState> {
  HomeProvider({
    required final Ref ref,
    required final HomeProviderState state,
  }) : _ref = ref,
       super(state) {
    _connectSocket();
    _sendPushNotificationToken();
  }

  final Ref _ref;
  NotificationService get _notificationService =>
      _ref.read(providerOfNotificationService);
  SharedPreferencesRepository get _sharedPrefs =>
      _ref.read(providerOfSharedPreferencesRepository);

  /// Connects to the socket.
  Future<void> _connectSocket() async {
    final socketService = _ref.read(providerOfSocketService);
    socketService.connect();
    _ref.onDispose(
      () => socketService.dispose(),
    );
  }

  /// Registers for push when already authorized; otherwise raises the
  /// priming screen instead of firing the OS prompt cold.
  Future<void> _sendPushNotificationToken() async {
    final statusResult = await _notificationService
        .getNotificationPermissionStatus();
    if (!mounted) return;

    final status = statusResult.whenSuccess((s) => s);
    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional) {
      await _fetchAndSendToken();
      return;
    }

    // Not authorized: prime, unless the user recently said "Maybe later".
    final snoozedAtResult = await _sharedPrefs.getInt(
      key: SharedPrefsKey.notificationPrimingSnoozedAt,
    );
    if (!mounted) return;
    final snoozedAt = snoozedAtResult.whenSuccess((v) => v);
    if (snoozedAt != null &&
        DateTime.now().millisecondsSinceEpoch - snoozedAt <
            _kPrimingSnooze.inMilliseconds) {
      return;
    }

    state = state.copyWith(
      notificationPrimingRequest: status == AuthorizationStatus.denied
          ? NotificationPrimingKind.previouslyDenied
          : NotificationPrimingKind.firstAsk,
    );
  }

  /// Called from the priming screen's primary button. Triggers the OS prompt
  /// (first ask) and registers the token when granted.
  Future<bool> enableNotificationsFromPriming() async {
    state = state.copyWith(notificationPrimingRequest: null);
    await _fetchAndSendToken();
    final enabled = state.sendPushNotificationTokenState.maybeWhen(
      success: (_) => true,
      orElse: () => false,
    );
    if (enabled) AnalyticsService.notificationsEnabled(from: 'priming');
    return enabled;
  }

  /// Called when the user picks "Maybe later" — snoozes the re-ask.
  Future<void> snoozeNotificationPriming() async {
    AnalyticsService.notificationPrimingSnoozed();
    state = state.copyWith(notificationPrimingRequest: null);
    await _sharedPrefs.saveInt(
      key: SharedPrefsKey.notificationPrimingSnoozedAt,
      value: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Fetches the FCM token (prompting if needed) and sends it to the server.
  Future<void> _fetchAndSendToken() async {
    state = state.copyWith(
      sendPushNotificationTokenState: SendPushNotificationTokenState.loading(),
    );

    final result = await _notificationService.getFCMToken().then(
      (data) => data.when<Future<Either<String, AppError>>>(
        (fcmToken) async {
          final result = await _notificationService.sendPushNotificationToken(
            token: fcmToken,
          );
          return result.when(
            (success) => Success(fcmToken),
            (failure) => Failure(failure),
          );
        },
        (failure) async => Failure(failure),
      ),
    );
    if (!mounted) return;

    result.when(
      (success) {
        state = state.copyWith(
          sendPushNotificationTokenState:
              SendPushNotificationTokenState.success(success),
        );
      },
      (failure) {
        state = state.copyWith(
          sendPushNotificationTokenState: SendPushNotificationTokenState.error(
            failure,
          ),
        );
      },
    );
  }
}
