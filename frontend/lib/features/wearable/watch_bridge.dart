import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/api/endpoints.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/home_screen_widget/family_widget_model.dart';
import 'package:hazard_app/features/home_screen_widget/models/family_widget_payload.dart';
import 'package:hazard_app/features/shared/providers/dio_instance_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/wearable/watch_payload.dart';

/// The iPhone side of the ALRT Apple Watch companion.
///
/// The phone holds the session: the watch never signs in and never calls
/// the backend. It is told circle status (the Family widget payload, so
/// never names of members or locations) and asks the phone to act; the
/// phone posts with its own login and answers with the server's result.
///
/// Native half: WatchSessionBridge in ios/Runner/AppDelegate.swift, over
/// the method channel [channelName]. iOS only; a no-op elsewhere.
abstract final class WatchBridge {
  static const channelName = 'com.safetyalrt.alrt/watch';
  static const _channel = MethodChannel(channelName);

  static bool get _supported => !kIsWeb && Platform.isIOS;

  /// The last status sent, so a watch that opens its app can be answered
  /// even when nothing has changed since (the widget sync skips repeats).
  static Map<String, Object>? _last;

  /// Called from FamilyWidgetSync on every family state change.
  static void push(final FamilyWidgetPayload payload) {
    final context = WatchPayload.fromWidget(payload);
    _last = context;
    _send(context);
  }

  /// Sign-out and account deletion: the wrist forgets everything at once.
  static void clear() {
    final context = WatchPayload.fromWidget(
      FamilyWidgetModel.signedOut(DateTime.now()),
    );
    _last = context;
    _send(context);
  }

  static void _send(final Map<String, Object> context) {
    if (!_supported) return;
    unawaited(
      _channel
          .invokeMethod<void>('updateContext', context)
          .catchError((Object e) => debugPrint('[WatchBridge] updateContext: $e')),
    );
  }

  /// Starts answering the watch. Call once, from the root widget, so it is
  /// in place even when the watch wakes the app in the background.
  static void attach(final WidgetRef ref) {
    if (!_supported) return;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'action':
          final args = call.arguments;
          if (args is! Map) {
            return WatchActionResult.failed().toMessage();
          }
          return _perform(ref, args);
        case 'requestState':
          _answerStateRequest(ref);
          return null;
        default:
          throw MissingPluginException(call.method);
      }
    });
    // Tells the native side it may deliver messages that arrived while the
    // Flutter side was still starting.
    unawaited(
      _channel.invokeMethod<void>('ready').catchError((Object _) {}),
    );
  }

  static void _answerStateRequest(final WidgetRef ref) {
    if (ref.read(providerOfLoggedInUser) == null) {
      clear();
      return;
    }
    final last = _last;
    if (last != null) _send(last);
    // Reading the family provider loads it if this launch had not yet;
    // its listener then pushes fresh status through FamilyWidgetSync.
    unawaited(ref.read(providerOfFamily.notifier).load(silent: true));
  }

  static Future<Map<String, Object>> _perform(
    final WidgetRef ref,
    final Map<Object?, Object?> message,
  ) async {
    if (ref.read(providerOfLoggedInUser) == null) {
      return WatchActionResult.failed(status: 401).toMessage();
    }
    final action = WatchAction.parse(message);
    if (action == null) return WatchActionResult.failed().toMessage();
    final circleName = message['circleName'] is String
        ? message['circleName'] as String
        : 'your circle';
    final dio = ref.read(providerOfDioInstance(true));
    final query = {'circleId': action.circleId};

    try {
      switch (action) {
        case WatchSosPreview():
          final response = await dio.get<Map<String, dynamic>>(
            kUrlFamilySosPreview,
            queryParameters: query,
          );
          return WatchSosPreview.toMessage(response.data ?? const {});
        case WatchCheckIn():
          await dio.post<dynamic>(kUrlFamilyCheckIn, queryParameters: query, data: action.body);
          _refresh(ref);
          return WatchActionResult.checkedIn(circleName, DateTime.now()).toMessage();
        case WatchSos():
          await dio.post<dynamic>(kUrlFamilySos, queryParameters: query, data: action.body);
          _refresh(ref);
          return WatchActionResult.sosSent(circleName).toMessage();
      }
    } on DioException catch (e) {
      final offline =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout;
      return WatchActionResult.failed(
        status: e.response?.statusCode,
        body: e.response?.data,
        offline: offline && e.response == null,
      ).toMessage();
    } catch (_) {
      return WatchActionResult.failed().toMessage();
    }
  }

  static void _refresh(final WidgetRef ref) {
    unawaited(ref.read(providerOfFamily.notifier).load(silent: true));
  }
}
