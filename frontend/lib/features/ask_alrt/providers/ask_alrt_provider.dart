import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/ask_alrt/models/ask_alrt_message.dart';
import 'package:hazard_app/features/ask_alrt/providers/states/ask_alrt_provider_state.dart';
import 'package:hazard_app/api/endpoints.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/shared/providers/dio_instance_provider.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/ask_alrt/models/ask_alrt_local_answers.dart';
import 'package:hazard_app/features/shared/services/emergency_number.dart';

final providerOfAskAlrt =
    NotifierProvider.autoDispose<AskAlrtProvider, AskAlrtProviderState>(
      AskAlrtProvider.new,
    );

/// Drives the Ask ALRT chat: grounds each question in nearby active alerts,
/// calls the backend's Ask ALRT endpoint, and never surfaces a raw error.
class AskAlrtProvider extends Notifier<AskAlrtProviderState> {
  /// Calm fallback shown for ANY failure (server error, network,
  /// malformed response). Never show a raw error.
  /// Used only when nothing local matches and the backend is unreachable.
  /// The emergency number is resolved per user, never hard-coded.
  /// The offline fallback carries the app basics rather than a shrug, so
  /// even with the assistant unreachable the answer is useful.
  static String fallbackAnswerFor(final String emergencyNumber) =>
      "I can't reach the assistant right now, but here are the basics: "
      'ALRT shows official warnings and community reports near you on the '
      'map and feed. Shapes tell you the source (triangle = Australian '
      'Warning System, diamond = official agency, circle = community '
      'report) and colour tells you urgency. The Family tab does check-ins '
      'and SOS. ALRT never contacts emergency services for you. If you '
      'are in danger, call $emergencyNumber now.';

  /// Shown at the daily limit when the server gives no message of its own.
  static const limitAnswer =
      "You've reached today's Ask ALRT limit. It resets tomorrow.";

  /// Shown when the server answered but could not help right now (502,
  /// 503, any other refusal that is not the daily limit). The question is
  /// not counted, so the person can simply ask again.
  static const unavailableAnswer =
      'Ask ALRT is temporarily unavailable. Try again soon.';

  /// Shown for a 429 from the general API rate limiter (no `ask_limit`
  /// code): too many requests in a short time, not the daily allowance.
  static const tooManyRequestsAnswer =
      'Too many requests. Try again in a minute.';

  /// The `code` the server puts on the daily-allowance 429.
  static const askLimitCode = 'ask_limit';

  /// Field limits of the server's Ask ALRT body schema
  /// (backend ask_alrt_content.validator.ts). Anything longer is trimmed
  /// here so a long alert title never turns the whole question into a 400.
  static const maxQuestionLength = 2000;
  static const maxAlertIdLength = 100;
  static const maxAlertTitleLength = 300;
  static const maxAlertCategoryLength = 100;
  static const maxAlertSeverityLength = 100;
  static const maxAlertSourceLength = 200;
  static const maxEmergencyNumberLength = 8;

  /// Questions allowed per day on ALRT Free (the server is the authority;
  /// this only decides whether the sheet offers ALRT +).
  static const freeDailyLimit = 3;

  @override
  AskAlrtProviderState build() {
    Future.microtask(refreshAllowance);
    return const AskAlrtProviderState();
  }

  /// The person's local day, as the server counts it (master spec §14).
  Map<String, dynamic> get _dayZone => {
    'utcOffsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
  };

  /// Reads how many questions are left today. Never counts a question and
  /// never surfaces an error: the line simply stays hidden.
  Future<void> refreshAllowance() async {
    try {
      final dio = ref.read(providerOfDioInstance(true));
      final response = await dio.get<dynamic>(
        kUrlAskAlrtAllowance,
        queryParameters: _dayZone,
        options: Options(receiveTimeout: const Duration(seconds: 15)),
      );
      final data = response.data;
      if (!ref.mounted || data is! Map) return;
      final limit = data['limit'];
      final remaining = data['remaining'];
      if (limit is! num || remaining is! num) return;
      state = state.copyWith(
        dailyLimit: limit.toInt(),
        remainingToday: remaining.toInt(),
        limitReached: remaining <= 0,
      );
    } catch (_) {
      // Offline or an older server: no allowance line.
    }
  }

  /// Sends [question] to the backend, grounded in up to 5 nearby
  /// active alerts from the map state.
  Future<void> ask(final String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || state.isSending) return;
    final sentQuestion = clip(trimmed, maxQuestionLength);

    final groundingAlerts = _gatherNearbyAlerts();
    final nearbyAlertsPayload = _composeNearbyAlerts(groundingAlerts);

    state = state.copyWith(
      messages: [
        ...state.messages,
        AskAlrtMessage(role: AskAlrtRole.user, text: trimmed),
      ],
      isSending: true,
    );

    final emergencyNumber = ref.read(providerOfEmergencyNumber);

    // Every answer comes from the server while it can be reached, so each
    // one counts toward the daily allowance and Admin Portal edits to the
    // answer library reach people. The on-phone answers are only the
    // offline backup.
    String offlineAnswer() =>
        AskAlrtLocalAnswers.answerFor(
          trimmed,
          emergencyNumber: emergencyNumber,
        ) ??
        fallbackAnswerFor(emergencyNumber);

    var answer = fallbackAnswerFor(emergencyNumber);
    var citedAlerts = const <Hazard>[];
    int? remainingToday;
    var limitReached = false;
    var notCounted = false;

    try {
      final dio = ref.read(providerOfDioInstance(true));
      final response = await dio.post<dynamic>(
        kUrlAskAlrt,
        data: {
          'question': sentQuestion,
          if (emergencyNumber.length <= maxEmergencyNumberLength)
            'emergencyNumber': emergencyNumber,
          if (nearbyAlertsPayload.isNotEmpty)
            'nearbyAlerts': nearbyAlertsPayload,
          // The daily Ask ALRT allowance counts the person's LOCAL day
          // (master spec §14); the server validates and rate-limits changes.
          ..._dayZone,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );

      final parsedAnswer = _extractAnswer(response.data);
      if (parsedAnswer != null) {
        answer = parsedAnswer;
        citedAlerts = _resolveCitedAlerts(response.data, groundingAlerts);
      } else {
        answer = offlineAnswer();
      }
      final data = response.data;
      if (data is Map && data['remainingToday'] is num) {
        remainingToday = (data['remainingToday'] as num).toInt();
      }
    } on DioException catch (exception) {
      if (_isConnectionError(exception)) {
        // Truly unreachable (no network, timeout): answer from the phone.
        answer = offlineAnswer();
      } else if (_isLimitError(exception)) {
        // The server's own message names the plan and its daily number.
        answer = _serverMessage(exception) ?? limitAnswer;
        remainingToday = 0;
        limitReached = true;
      } else if (exception.response?.statusCode == 429) {
        answer = tooManyRequestsAnswer;
        notCounted = true;
      } else {
        // The server answered but could not help (502/503 and the like).
        // The canned offline text would claim it can't be reached, so say
        // what happened instead; the server does not count the question.
        answer = unavailableAnswer;
        notCounted = true;
      }
    } catch (_) {
      answer = unavailableAnswer;
      notCounted = true;
    }

    // The sheet may have been closed mid-flight (autoDispose).
    if (!ref.mounted) return;

    state = state.copyWith(
      messages: [
        ...state.messages,
        AskAlrtMessage(
          role: AskAlrtRole.assistant,
          text: answer,
          groundingAlerts: citedAlerts,
        ),
      ],
      isSending: false,
      remainingToday: remainingToday,
      limitReached:
          limitReached || (remainingToday != null && remainingToday <= 0),
    );

    // A refused question is not counted: re-read the allowance so the
    // line shows the server's number, not a guess.
    if (notCounted) unawaited(refreshAllowance());
  }

  /// [text] cut to at most [max] UTF-16 units, never splitting a
  /// character made of a surrogate pair.
  static String clip(final String text, final int max) {
    if (text.length <= max) return text;
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (buffer.length + char.length > max) break;
      buffer.write(char);
    }
    return buffer.toString().trimRight();
  }

  /// Up to 5 nearby active hazards, read (not watched) from the map state.
  ///
  /// The sheet is opened from the map rail, so [providerOfMap] is already
  /// alive underneath it and reading it is non-invasive.
  List<Hazard> _gatherNearbyAlerts() {
    // Never build the map just to ask a question.
    if (!ref.exists(providerOfMap)) return const <Hazard>[];
    try {
      return ref
          .read(providerOfMap)
          .hazards
          .where((hazard) => !hazard.isExpired)
          .take(5)
          .toList();
    } catch (_) {
      return const <Hazard>[];
    }
  }

  /// One structured entry per alert, keyed by the app's own stable id, so
  /// the backend can cite exactly which alerts it relied on instead of the
  /// app having to guess from a free-text reply. Alerts with no id can't be
  /// cited back, so they're left out rather than sent uncitably.
  List<Map<String, String>> _composeNearbyAlerts(final List<Hazard> alerts) {
    final payload = <Map<String, String>>[];
    for (final alert in alerts) {
      final id = alert.id?.trim();
      final title = alert.title?.trim() ?? '';
      // An id can't be shortened and still be cited back, so an over-long
      // one is left out like a missing one.
      if (id == null ||
          id.isEmpty ||
          id.length > maxAlertIdLength ||
          title.isEmpty) {
        continue;
      }

      final sourceName = alert.source?.name?.trim();
      final categoryName = alert.category?.name?.trim() ?? '';
      payload.add({
        'id': id,
        'title': clip(title, maxAlertTitleLength),
        if (categoryName.isNotEmpty)
          'category': clip(categoryName, maxAlertCategoryLength),
        if (alert.isAwsCompliant == true)
          'severity': clip(alert.severityTitle, maxAlertSeverityLength),
        'source': (sourceName != null && sourceName.isNotEmpty)
            ? clip(sourceName, maxAlertSourceLength)
            : 'community report, unverified',
      });
    }
    return payload;
  }

  /// Pulls the display text out of whatever shape the callable returned.
  /// Returns null when nothing usable is found (caller falls back).
  String? _extractAnswer(final dynamic data) {
    if (data is Map) {
      final answer = data['answer'];
      if (answer is String && answer.trim().isNotEmpty) {
        return answer.trim();
      }
      return null;
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return null;
  }

  /// Narrows [sentAlerts] down to only the ones the backend actually cited
  /// in `referencedAlertIds`, so the sheet shows citations, not just
  /// "everything that happened to be sent." Empty when the field is absent
  /// (e.g. an older backend) or the answer didn't rely on any of them.
  List<Hazard> _resolveCitedAlerts(
    final dynamic data,
    final List<Hazard> sentAlerts,
  ) {
    if (data is! Map) return const <Hazard>[];
    final ids = data['referencedAlertIds'];
    if (ids is! List || ids.isEmpty) return const <Hazard>[];

    final citedIds = ids.whereType<String>().toSet();
    if (citedIds.isEmpty) return const <Hazard>[];
    return sentAlerts.where((alert) => citedIds.contains(alert.id)).toList();
  }

  /// True only for the daily-allowance refusal: a 429 carrying the
  /// `ask_limit` code. The general rate limiter's 429 has no code.
  bool _isLimitError(final DioException exception) {
    final response = exception.response;
    if (response?.statusCode != 429) return false;
    final data = response?.data;
    return data is Map && data['code'] == askLimitCode;
  }

  /// True when the server was never reached (no network, timeouts), the
  /// only case where the on-phone offline answer is honest.
  bool _isConnectionError(final DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.unknown:
        // A socket failure surfaces as unknown with no response.
        return exception.response == null;
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
        return false;
    }
  }

  /// The server's error text (`{"error": "..."}`), when it sent one.
  String? _serverMessage(final DioException exception) {
    final data = exception.response?.data;
    if (data is Map) {
      final message = data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return null;
  }
}
