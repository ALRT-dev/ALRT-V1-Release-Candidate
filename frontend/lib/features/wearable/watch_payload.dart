import 'package:hazard_app/features/home_screen_widget/models/family_widget_payload.dart';

/// What the Apple Watch is told, built from the Family widget payload so
/// the wrist can never show more than the home-screen widget: circle
/// names and one status line each. Never a member's name, a location or a
/// safety-profile detail.
///
/// WatchConnectivity carries property-list values only, so every value is
/// a String, num, bool, List or Map and nothing is null.
abstract final class WatchPayload {
  /// Bumped when the watch app must read the shape differently.
  static const version = 1;

  static Map<String, Object> fromWidget(final FamilyWidgetPayload payload) => {
    'version': version,
    'signedIn': payload.state != 'signed_out',
    'state': payload.state,
    'headline': payload.headline,
    'sub': payload.sub,
    'generatedAt': payload.generatedAt.toUtc().toIso8601String(),
    'moreCircles': payload.moreCircles,
    'rows': [
      for (final row in payload.rows)
        <String, Object>{
          'circleId': row.circleId,
          'name': row.name,
          'kind': row.kind.wire,
          'headline': row.headline,
          'sub': row.sub,
        },
    ],
  };
}

/// One action the watch asked the phone to perform.
sealed class WatchAction {
  const WatchAction({required this.circleId, required this.clientRequestId});

  final String circleId;

  /// Generated on the watch, sent to the backend: the same tap arriving
  /// twice (a retry after a lost answer) is one action server-side.
  final String clientRequestId;

  /// Parses a WatchConnectivity message; null when it is not a valid
  /// action (unknown kind, missing circle, missing or malformed key).
  static WatchAction? parse(final Map<Object?, Object?> message) {
    final circleId = message['circleId'];
    final key = message['clientRequestId'];
    if (circleId is! String || circleId.isEmpty) return null;
    if (message['action'] == 'sosPreview') {
      return WatchSosPreview(circleId: circleId);
    }
    if (key is! String || !_uuid.hasMatch(key)) return null;
    return switch (message['action']) {
      'checkIn' => WatchCheckIn(circleId: circleId, clientRequestId: key),
      'sos' => WatchSos(circleId: circleId, clientRequestId: key),
      _ => null,
    };
  }

  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// The JSON body posted to the backend for this action.
  Map<String, Object> get body;
}

/// "Check in to [circle]": no location, ever, from the wrist.
class WatchCheckIn extends WatchAction {
  const WatchCheckIn({required super.circleId, required super.clientRequestId});

  @override
  Map<String, Object> get body => {'clientRequestId': clientRequestId};
}

/// SOS from the wrist after a deliberate hold: to everyone else in that
/// circle, with no location (the sender must choose location sharing
/// explicitly, which only the phone's SOS screen offers).
class WatchSos extends WatchAction {
  const WatchSos({required super.circleId, required super.clientRequestId});

  @override
  Map<String, Object> get body => {
    'isLive': false,
    'locationMode': 'none',
    'clientRequestId': clientRequestId,
  };
}

/// Before the hold: who this circle's SOS would reach right now, from the
/// backend's own preview (the send repeats the same check). Sends nothing.
class WatchSosPreview extends WatchAction {
  const WatchSosPreview({required super.circleId}) : super(clientRequestId: '');

  @override
  Map<String, Object> get body => const {};

  /// The preview as the watch shows it: names only, never a location.
  static Map<String, Object> toMessage(final Map<String, dynamic> preview) {
    final names = [
      for (final r in (preview['recipients'] as List? ?? const []))
        if (r is Map && r['name'] is String) r['name'] as String,
    ];
    final state = preview['state'] is String ? preview['state'] as String : 'ok';
    final canSend = state == 'ok' && names.isNotEmpty;
    return {
      'ok': true,
      'canSend': canSend,
      'names': names,
      'detail': canSend
          ? 'Goes to ${_list(names)}. No location is sent from your watch.'
          : 'No one in this circle can get an SOS right now. Open ALRT on your iPhone.',
    };
  }

  static String _list(final List<String> names) {
    if (names.length <= 1) return names.join();
    if (names.length == 2) return '${names[0]} and ${names[1]}';
    if (names.length == 3) return '${names[0]}, ${names[1]} and ${names[2]}';
    return '${names[0]}, ${names[1]} and ${names.length - 2} others';
  }
}

/// The answer sent back to the watch. The watch says "done" only when
/// [ok] is true, which only happens after the server confirmed.
class WatchActionResult {
  const WatchActionResult._(this.ok, this.title, this.detail);

  factory WatchActionResult.checkedIn(final String circleName, final DateTime at) =>
      WatchActionResult._(true, 'Checked in to $circleName', _time(at));

  factory WatchActionResult.sosSent(final String circleName) =>
      WatchActionResult._(true, 'SOS sent to $circleName', 'Your circle has been told');

  /// A refusal or failure, worded from the server's own message when it
  /// gave one (for example "Add someone first..."), otherwise plain.
  factory WatchActionResult.failed({
    final int? status,
    final Object? body,
    final bool offline = false,
  }) {
    if (offline) {
      return const WatchActionResult._(
        false,
        'Not sent',
        'Your iPhone is offline. Try again when it is connected.',
      );
    }
    if (status == 401) {
      return const WatchActionResult._(false, 'Not sent', 'Open ALRT on your iPhone and sign in.');
    }
    if (status == 402) {
      return const WatchActionResult._(false, 'Not sent', 'Open ALRT on your iPhone to see why.');
    }
    final message = _serverMessage(body);
    return WatchActionResult._(
      false,
      'Not sent',
      message ?? 'Something went wrong. Try again or use your iPhone.',
    );
  }

  final bool ok;
  final String title;
  final String detail;

  Map<String, Object> toMessage() => {'ok': ok, 'title': title, 'detail': detail};

  static String? _serverMessage(final Object? body) {
    if (body is Map) {
      for (final key in const ['error', 'message']) {
        final value = body[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }
    return null;
  }

  static String _time(final DateTime at) {
    final local = at.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m ${local.hour < 12 ? 'am' : 'pm'}';
  }
}
