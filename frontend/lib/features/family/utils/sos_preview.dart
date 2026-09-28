import 'package:hazard_app/features/family/models/family_models.dart';

/// The phone's own guess at who an SOS reaches, from the group it has
/// loaded. Shown only until the backend's preview (sos_api.dart) answers,
/// or when it can't be reached; the send always re-checks on the server.
class LocalSosPreview {
  const LocalSosPreview({required this.names, required this.live});

  /// Names of the people the SOS is addressed to, in the group it is sent
  /// from. The server may still leave out anyone who can't receive it.
  final List<String> names;
  final bool live;

  bool get isEmpty => names.isEmpty;

  /// "Alex, Morgan and Taylor" / "Alex, Morgan, Taylor and 5 others".
  String get recipientsLine {
    if (names.isEmpty) return 'No one yet';
    if (names.length == 1) return names.single;
    if (names.length <= 4) {
      return '${names.sublist(0, names.length - 1).join(', ')} and '
          '${names.last}';
    }
    final rest = names.length - 3;
    return '${names.take(3).join(', ')} and $rest others';
  }

  /// True to what the app sends: with live sharing on, a location that
  /// keeps updating; with it off, the one point taken when it is sent
  /// (when the phone has one), never updated.
  String get locationLine => live
      ? 'Your live location, updating until you end the SOS (up to 4 hours).'
      : 'Where you are when you send it, once. It won\'t update.';
}

LocalSosPreview sosPreview({
  required final List<FamilyMember> others,
  required final FamilySosList? list,
  required final bool live,
}) {
  final chosen = list == null
      ? others
      : others.where((m) => list.memberIds.contains(m.id)).toList();
  return LocalSosPreview(
    names: [for (final m in chosen) m.name],
    live: live,
  );
}

/// "Alex", "Alex and Morgan", "Alex, Morgan and Taylor",
/// "Alex, Morgan, Taylor and 3 others".
String joinNames(final List<String> names) =>
    LocalSosPreview(names: names, live: false).isEmpty
        ? ''
        : LocalSosPreview(names: names, live: false).recipientsLine;

/// Why someone is left out of an SOS, in plain words.
String excludedReason(final String? reason) => switch (reason) {
  'sponsorship_paused' => 'this group\'s plan has ended',
  'needs_individual' => 'needs ALRT + here',
  _ => 'can\'t receive it now',
};

/// What a recipient is told about an SOS's location, from the SOS itself
/// (never the sender's ordinary group location): none, once or live, and
/// how old the point was when the SOS was sent when it was a last-known
/// point.
String sosLocationLine(final FamilySosEvent sos, {required final bool ended}) {
  if (ended) return 'This SOS has ended. Its location is no longer shared.';
  final mode = sos.locationMode ?? (sos.isLive ? 'live' : null);
  if (mode == 'none') return 'No location was shared with this SOS.';
  final captured = sos.locationCapturedAt;
  final created = sos.createdAt;
  final lagMinutes = captured != null && created != null
      ? created.difference(captured).inMinutes
      : 0;
  final lastKnown = lagMinutes >= 2
      ? ' · last known location, $lagMinutes min before the SOS'
      : '';
  final where = sos.locationLabel != null ? 'Near ${sos.locationLabel}' : null;
  if (mode == 'once') {
    return where != null
        ? '$where$lastKnown · shared once'
        : 'Location shared once$lastKnown';
  }
  if (where != null) return '$where$lastKnown · live';
  return sos.latitude != null
      ? 'Live location shared with you'
      : 'Live location will appear when their phone finds them';
}
