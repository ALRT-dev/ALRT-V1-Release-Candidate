import 'dart:convert';

/// Wearable notification pilot (WEARABLES_AUDIT_AND_PLAN.md §4.5 and §9).
///
/// Pure helpers shared by the foreground app and the background isolates:
/// how a pilot push is recognised, which buttons it carries, what the
/// follow-up notification says in each of the four states, and the key
/// that makes a check-in answered twice (phone and watch) one row on the
/// server. Nothing here touches a plugin, so every rule is unit-tested.
///
/// A pilot push is a data message from the backend with `wearable: "1"`.
/// Exactly two types qualify: a check-in request and an SOS received.
/// Every other push keeps its shape and never reaches this code.
class WearablePush {
  WearablePush._();

  /// Action ids, shared by Android actions and iOS category actions.
  static const actionCheckInCircle = 'alrt_check_in_circle';
  static const actionOpenOnPhone = 'alrt_open_on_phone';

  /// iOS category identifiers the backend names on the two pilot pushes.
  static const categoryCheckInRequest = 'ALRT_CHECKIN_REQUEST';
  static const categorySosReceived = 'ALRT_SOS_RECEIVED';

  static const typeCheckInRequest = 'familyCheckInRequest';
  static const typeSos = 'familySos';

  static const channelDefault = 'alrt_alerts';
  static const channelUrgent = 'alrt_alerts_urgent';
}

/// The one key both surfaces use when answering the same ask, so the
/// server records one check-in however many times it is sent.
String checkInClientKeyFor(final String requestId) => 'req:$requestId';

/// A pilot push, parsed from the FCM data map.
class WearablePushMessage {
  const WearablePushMessage({
    required this.type,
    required this.title,
    required this.body,
    required this.channelId,
    required this.urgent,
    required this.payload,
    this.category,
    this.collapseKey,
  });

  final String type;
  final String title;
  final String body;
  final String channelId;
  final bool urgent;
  final Map<String, dynamic> payload;
  final String? category;
  final String? collapseKey;

  bool get isCheckInRequest => type == WearablePush.typeCheckInRequest;
  bool get isSos => type == WearablePush.typeSos;

  String? get circleId => payload['circleId']?.toString();
  String? get circleName => payload['circleName']?.toString();
  String? get requestId => payload['requestId']?.toString();
  String? get sosEventId => payload['sosEventId']?.toString();

  /// Never a bare "Check in": the button always names where it goes.
  String get checkInActionLabel =>
      'Check in to ${circleName?.trim().isNotEmpty == true ? circleName!.trim() : 'your circle'}';

  /// The stable id for this event's notification: a second delivery
  /// replaces the first in the tray instead of stacking. Same formula as
  /// LocalNotificationService so the two never disagree about an event.
  int get notificationId {
    final key = sosEventId ?? requestId ?? collapseKey ?? '$title|$body';
    return '$type:$key'.hashCode & 0x7fffffff;
  }

  /// The follow-up ("Checked in to Home") sits beside the request, not on
  /// top of it, so the user sees what they answered and what happened.
  int get followUpNotificationId => (notificationId ^ 0x2A2A2A2A) & 0x7fffffff;

  /// Parses an FCM data map. Returns null for anything that is not a pilot
  /// push, so callers can ignore every other notification cheaply.
  static WearablePushMessage? parse(final Map<String, dynamic> data) {
    if (data['wearable'] != '1' && data['wearable'] != true) return null;
    final type = data['notificationType']?.toString();
    if (type != WearablePush.typeCheckInRequest &&
        type != WearablePush.typeSos) {
      return null;
    }
    final title = data['title']?.toString();
    final body = data['body']?.toString();
    if (title == null || title.isEmpty || body == null || body.isEmpty) {
      return null;
    }
    Map<String, dynamic> payload = const {};
    final raw = data['payload'];
    if (raw is Map) {
      payload = Map<String, dynamic>.from(raw);
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) payload = Map<String, dynamic>.from(decoded);
      } catch (_) {
        payload = const {};
      }
    }
    final urgent = data['urgent'] == '1' || data['urgent'] == true;
    final channel = data['channelId']?.toString();
    return WearablePushMessage(
      type: type!,
      title: title,
      body: body,
      channelId: channel != null && channel.isNotEmpty
          ? channel
          : (urgent ? WearablePush.channelUrgent : WearablePush.channelDefault),
      urgent: urgent,
      payload: payload,
      category: data['category']?.toString(),
      collapseKey: data['collapseKey']?.toString(),
    );
  }

  /// Round-trips through a notification payload string.
  Map<String, dynamic> toData() => {
    'wearable': '1',
    'notificationType': type,
    'title': title,
    'body': body,
    'channelId': channelId,
    'urgent': urgent ? '1' : '0',
    'payload': jsonEncode(payload),
    if (category != null) 'category': category,
    if (collapseKey != null) 'collapseKey': collapseKey,
  };
}

/// What happened to a check-in sent from a notification action.
enum WearableCheckInOutcome {
  /// The server answered: one row exists for this ask.
  confirmed,

  /// This ask was already answered from a notification on this phone.
  alreadyDone,

  /// The server refused or the phone is offline. Nothing was recorded.
  failed,

  /// Sent, no answer (twice). It may or may not be recorded; the app
  /// reconciles on next open. Nothing is retried on its own.
  uncertain,

  /// No session on this phone. Open ALRT and sign in.
  signedOut,
}

/// The follow-up notification's words for each outcome. Success is only
/// ever worded after the server confirmed (confirmed, alreadyDone).
class WearableFollowUp {
  const WearableFollowUp({required this.title, required this.body});

  final String title;
  final String body;

  static String _time(final DateTime at) {
    final h = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final m = at.minute.toString().padLeft(2, '0');
    return '$h:$m ${at.hour < 12 ? 'am' : 'pm'}';
  }

  static WearableFollowUp forOutcome(
    final WearableCheckInOutcome outcome, {
    required final String circleName,
    required final DateTime at,
    final String? reason,
  }) {
    final circle = circleName.trim().isEmpty ? 'your circle' : circleName.trim();
    switch (outcome) {
      case WearableCheckInOutcome.confirmed:
        return WearableFollowUp(
          title: 'Checked in to $circle',
          body: '${_time(at)} · no location sent',
        );
      case WearableCheckInOutcome.alreadyDone:
        return WearableFollowUp(
          title: 'Already checked in to $circle',
          body: 'Nothing was sent again.',
        );
      case WearableCheckInOutcome.failed:
        return WearableFollowUp(
          title: 'Check-in to $circle not sent',
          body: reason == null || reason.isEmpty
              ? 'Open ALRT to try again.'
              : '$reason Open ALRT to try again.',
        );
      case WearableCheckInOutcome.uncertain:
        return WearableFollowUp(
          title: 'Could not confirm your check-in to $circle',
          body: 'It was sent but ALRT did not answer. Open ALRT to check.',
        );
      case WearableCheckInOutcome.signedOut:
        return WearableFollowUp(
          title: 'Check-in to $circle not sent',
          body: 'Open ALRT and sign in first.',
        );
    }
  }
}

/// Keeps the last [keep] answered request ids, newest last.
List<String> rememberAnsweredRequest(
  final List<String> existing,
  final String requestId, {
  final int keep = 50,
}) {
  final next = [...existing.where((id) => id != requestId), requestId];
  return next.length <= keep ? next : next.sublist(next.length - keep);
}

/// Maps an HTTP status from POST /api/family/check-in to an outcome and a
/// plain reason. Only 2xx is success; 401 is handled by the caller (token
/// refresh) before this is consulted.
({WearableCheckInOutcome outcome, String? reason}) outcomeForStatus(
  final int? status,
) {
  if (status == null) {
    return (outcome: WearableCheckInOutcome.uncertain, reason: null);
  }
  if (status >= 200 && status < 300) {
    return (outcome: WearableCheckInOutcome.confirmed, reason: null);
  }
  if (status == 401) {
    return (outcome: WearableCheckInOutcome.signedOut, reason: null);
  }
  if (status == 402) {
    return (
      outcome: WearableCheckInOutcome.failed,
      reason: 'This group needs an ALRT + plan for check-ins.',
    );
  }
  if (status == 404) {
    return (
      outcome: WearableCheckInOutcome.failed,
      reason: 'You are no longer in that group.',
    );
  }
  if (status == 409) {
    // The server is still handling the first attempt: not a failure, and
    // not something to retry from here.
    return (outcome: WearableCheckInOutcome.uncertain, reason: null);
  }
  if (status >= 500) {
    return (outcome: WearableCheckInOutcome.uncertain, reason: null);
  }
  return (outcome: WearableCheckInOutcome.failed, reason: null);
}
