import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/sos_timing.dart';

// The facts of a past SOS, as its after-event record says them. Built from
// what was stored (the sender's location choice and the audience fixed at
// the start), never from the group as it is today.

/// The location choice the sender made for [sos]: none, once or live.
/// Events from before locationMode existed say it with isLive.
String sosRecordLocationMode(final FamilySosEvent sos) =>
    sos.locationMode ?? (sos.isLive ? 'live' : 'none');

/// Who sent [sos]: their name in the group, or, once they have left it,
/// the name the SOS was sent under.
String sosSenderName(final FamilySosEvent sos) {
  final member = sos.member;
  return member?.nickname ??
      member?.user?.name ??
      sos.senderName ??
      'A family member';
}

/// "SOS ended by Sam at 3:45 pm." or "This SOS expired at 3:45 pm."
/// (locked wording). Only the sender can end an SOS, so the name is the
/// sender's.
String sosRecordEndedLine(final FamilySosEvent sos) {
  final expired = sosExpiredLine(sos);
  if (expired != null) return expired;
  final who = sosSenderName(sos);
  final at = sos.resolvedAt;
  return at == null
      ? 'SOS ended by $who.'
      : 'SOS ended by $who at ${sosClock(at)}.';
}

/// "Amy", "Amy and Tom", "Amy, Tom and Ben": every name, since this is the
/// record of who it reached.
String sosRecordNames(final List<String> names) {
  if (names.isEmpty) return '';
  if (names.length == 1) return names.single;
  return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
}

/// What was shared, with whom, and what became of it.
///
/// [audienceNames] are the stored audience's names, resolved by the
/// caller; [unnamedCount] counts stored recipients who can no longer be
/// named (they left the group). Null [audienceNames] = not known, and the
/// sentence about who it reached is left out rather than guessed.
String sosRecordSharedText(
  final FamilySosEvent sos, {
  final List<String>? audienceNames,
  final int unnamedCount = 0,
}) {
  final mode = sosRecordLocationMode(sos);
  final suburbOnly = sos.locationPrecision == 'approximate';
  final started = sos.createdAt;
  final ended = sos.resolvedAt;
  final ranFor = started == null || ended == null
      ? null
      : ended.difference(started);

  final parts = <String>[
    switch (mode) {
      'once' =>
        suburbOnly
            ? 'Location was shared once (suburb only), when the SOS was sent.'
            : 'Location was shared once, when the SOS was sent.',
      'live' =>
        'Live location${suburbOnly ? ' (suburb only)' : ''} was shared '
            'during this SOS'
            '${ranFor == null ? '' : ', which ran for ${sosDurationLabel(ranFor)}'}.',
      _ => 'No location was shared with this SOS.',
    },
  ];

  if (sos.audienceRestricted == false) {
    // From before the stored audience: it went to the whole group.
    parts.add('It was sent to everyone in the group.');
  } else if (sos.audienceRestricted == true && audienceNames != null) {
    final names = [
      ...audienceNames,
      if (unnamedCount == 1) '1 person no longer in the group',
      if (unnamedCount > 1) '$unnamedCount people no longer in the group',
    ];
    if (names.isNotEmpty) {
      parts.add('It was sent to ${sosRecordNames(names)}.');
    }
  }

  switch (mode) {
    case 'live':
      parts.add('The location trail was deleted when the SOS ended.');
    case 'once':
      parts.add('The location was deleted when the SOS ended.');
  }
  return parts.join(' ');
}

/// "under a minute", "12 minutes", "1 hour", "1 hour 5 min".
String sosDurationLabel(final Duration d) {
  if (d.inMinutes < 1) return 'under a minute';
  if (d.inMinutes < 60) {
    return '${d.inMinutes} ${d.inMinutes == 1 ? 'minute' : 'minutes'}';
  }
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  if (minutes == 0) return '$hours ${hours == 1 ? 'hour' : 'hours'}';
  return '$hours ${hours == 1 ? 'hour' : 'hours'} $minutes min';
}

/// The stored audience of [sos] by name, from [members] (the group as
/// loaded): "you" for [myUserId], the sender left out. Also how many
/// stored recipients are no longer in the group.
({List<String> names, int unnamed}) sosAudienceNames(
  final FamilySosEvent sos, {
  required final List<FamilyMember> members,
  required final String? myUserId,
}) {
  final byUser = {for (final m in members) m.userId: m};
  final names = <String>[];
  var unnamed = 0;
  for (final userId in sos.recipientUserIds) {
    if (userId == sos.member?.user?.id) continue;
    final member = byUser[userId];
    if (member == null) {
      unnamed += 1;
    } else {
      names.add(userId == myUserId ? 'you' : member.name);
    }
  }
  return (names: names, unnamed: unnamed);
}
