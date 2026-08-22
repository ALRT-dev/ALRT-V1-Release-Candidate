import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/ask_alrt/models/ask_alrt_message.dart';
import 'package:hazard_app/features/ask_alrt/providers/states/ask_alrt_provider_state.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/ask_alrt/models/ask_alrt_local_answers.dart';
import 'package:hazard_app/features/shared/services/emergency_number.dart';

final providerOfAskAlrt =
    NotifierProvider.autoDispose<AskAlrtProvider, AskAlrtProviderState>(
      AskAlrtProvider.new,
    );

/// Drives the Ask ALRT chat: grounds each question in nearby active alerts,
/// calls the `askAlrt` Firebase callable, and never surfaces a raw error.
class AskAlrtProvider extends Notifier<AskAlrtProviderState> {
  /// Calm fallback shown for ANY failure (App Check rejection, function not
  /// deployed, network, malformed response). Never show a raw error.
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
      'and SOS. ALRT never contacts emergency services for you — if you '
      'are in danger, call $emergencyNumber now.';

  /// Shown when the backend reports a quota-style error mentioning 'limit'.
  static const limitAnswer =
      "You've reached today's Ask ALRT limit. It resets tomorrow.";

  @override
  AskAlrtProviderState build() => const AskAlrtProviderState();

  /// Sends [question] to the `askAlrt` callable, grounded in up to 5 nearby
  /// active alerts from the map state.
  Future<void> ask(final String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || state.isSending) return;

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

    // The basics are answered on this phone: no network, no model, no wait.
    // It also means the app can still explain itself when the assistant
    // backend is unreachable.
    final local = AskAlrtLocalAnswers.answerFor(
      trimmed,
      emergencyNumber: emergencyNumber,
    );
    if (local != null) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          AskAlrtMessage(role: AskAlrtRole.assistant, text: local),
        ],
        isSending: false,
      );
      return;
    }

    var answer = fallbackAnswerFor(emergencyNumber);
    var citedAlerts = const <Hazard>[];

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'askAlrt',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );
      final result = await callable.call<dynamic>({
        'question': trimmed,
        if (nearbyAlertsPayload.isNotEmpty) 'nearbyAlerts': nearbyAlertsPayload,
      });

      final parsedAnswer = _extractAnswer(result.data);
      if (parsedAnswer != null) {
        answer = parsedAnswer;
        citedAlerts = _resolveCitedAlerts(result.data, groundingAlerts);
      }
    } on FirebaseFunctionsException catch (exception) {
      answer = _isLimitError(exception)
          ? limitAnswer
          : fallbackAnswerFor(emergencyNumber);
    } catch (_) {
      // App Check rejection, not deployed, network loss, anything else:
      // stay calm, keep the fallback copy.
      answer = fallbackAnswerFor(emergencyNumber);
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
    );
  }

  /// Up to 5 nearby active hazards, read (not watched) from the map state.
  ///
  /// The sheet is opened from the map rail, so [providerOfMap] is already
  /// alive underneath it and reading it is non-invasive.
  List<Hazard> _gatherNearbyAlerts() {
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
      if (id == null || id.isEmpty || title.isEmpty) continue;

      final sourceName = alert.source?.name?.trim();
      payload.add({
        'id': id,
        'title': title,
        if (alert.category?.name?.trim().isNotEmpty ?? false)
          'category': alert.category!.name!.trim(),
        if (alert.isAwsCompliant == true) 'severity': alert.severityTitle,
        'source': (sourceName != null && sourceName.isNotEmpty)
            ? sourceName
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

  /// True when the backend rejected the call with a quota-style message.
  bool _isLimitError(final FirebaseFunctionsException exception) {
    final message = exception.message?.toLowerCase() ?? '';
    final details = exception.details?.toString().toLowerCase() ?? '';
    return message.contains('limit') || details.contains('limit');
  }
}
