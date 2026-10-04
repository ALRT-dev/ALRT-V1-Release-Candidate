import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Pure label helpers for the Family hub, kept widget-free so the wording
/// the hub shows for people, tiles, the one "Check in" button and a
/// member's state can be unit-tested without pumping the screen.
///
/// V1 (master spec 28 Sep 2026): no seats, and check-in wording is factual.
/// A check-in says someone checked in, never that they are safe.

/// The single check-in control's label (product decision 8 Sep 2026: it
/// says "Check in", because that is what it does; whether a location goes
/// with it is decided on the consent sheet). When someone's ask is still
/// owed an answer, the button says who the tap answers; there is no
/// second button inside the ask banner.
String imSafeLabel({
  final String? requesterName,
  final List<String> requesterNames = const [],
}) {
  final names = [
    if (requesterName != null && requesterName.isNotEmpty) requesterName,
    ...requesterNames.where((n) => n.isNotEmpty && n != requesterName),
  ];
  if (names.isEmpty) return 'Check in';
  return 'Check in · lets ${askersLabel(names)} know';
}

/// "Amy", "Amy and Tom", "Amy, Tom +2": who is waiting, kept short enough
/// for a button and a card title.
String askersLabel(final List<String> names) {
  if (names.isEmpty) return 'Your circle';
  if (names.length == 1) return names[0];
  if (names.length == 2) return '${names[0]} and ${names[1]}';
  return '${names[0]}, ${names[1]} +${names.length - 2}';
}

/// The card title over the Check in button: "Amy requested a check-in",
/// "Amy, Tom +2 requested a check-in", or the card's own name.
String checkInCardTitle(final List<String> askers) => askers.isEmpty
    ? 'Your check-in'
    : '${askersLabel(askers)} requested a check-in';

/// "View 4 requests" — only when there is more than one to view.
String? viewRequestsLabel(final int count) =>
    count > 1 ? 'View $count requests' : null;

/// "4 people" / "1 person": the group's size, with no billing mechanics
/// (those live on My plans, master spec §11).
String peopleLine(final int count) => count == 1 ? '1 person' : '$count people';

/// The line a non-host sees under the group name.
String hostedByLine(final String? hostName) =>
    hostName == null || hostName.isEmpty
        ? 'Joining is free'
        : 'Hosted by $hostName · joining is free';

/// Four quick tiles fit in one row up to a modest text scale; past that
/// the 11sp labels clip, so the row becomes two rows of two.
bool useStackedQuickTiles(final double textScale) => textScale > 1.15;

/// What the row and the details sheet say under a member's name.
///
/// Truthful ordering: an unanswered ask leads, then an explicit snapshot,
/// then a hidden location (still with the last check-in, because "hidden"
/// is about location, not about whether they are all right), then the last
/// check-in, then "No check-in yet". Never "unsafe": not checking in is
/// silence, not danger.
String memberStatusLine({
  required final FamilyMember member,
  required final bool? hasAnswered,
  final DateTime? askedAt,
  required final DateTime now,
}) {
  String ago(final DateTime at) => timeago.format(at, clock: now);

  final last = member.lastCheckInAt;
  final lastLabel = last == null ? 'no check-in yet' : 'checked in ${ago(last)}';

  if (askedAt != null && hasAnswered == false) {
    // The row keeps to one short fact; the details sheet adds the rest.
    return 'Asked ${ago(askedAt)}';
  }

  final label = member.locationLabel;
  if (label != null && label.isNotEmpty) {
    final sharedAt = member.locationUpdatedAt;
    final expiresAt = member.locationExpiresAt;
    final expiry = expiresAt != null && expiresAt.isAfter(now)
        ? ' · expires ${timeago.format(expiresAt, clock: now, allowFromNow: true)}'
        : '';
    return sharedAt != null
        ? '$label · shared ${ago(sharedAt)}$expiry'
        : '$label$expiry';
  }

  if (member.sharingLevel == FamilySharingLevel.off ||
      member.sharingLevel == FamilySharingLevel.alertsOnly) {
    return 'Location hidden · $lastLabel';
  }

  if (last != null) return 'Checked in ${ago(last)}';
  return 'No check-in yet';
}

/// The short chip on a member row, factual only (master spec §11):
/// "Checked in", "Waiting" only while a real request is outstanding,
/// otherwise "No recent check-in". Never "Safe".
String memberStatusChip({
  required final FamilyMember member,
  required final bool? hasAnswered,
  required final bool isNearAlert,
}) {
  if (isNearAlert) return 'Near';
  if (hasAnswered ?? member.isCheckedInRecently) return 'Checked in';
  if (hasAnswered == false) return 'Waiting';
  return 'No recent check-in';
}

/// The longer, honest reading of the chip, for the details sheet.
String memberStatusExplanation({
  required final FamilyMember member,
  required final bool? hasAnswered,
  required final bool isNearAlert,
}) {
  if (isNearAlert) {
    return 'Their last known area is near an active alert. Ask them to '
        'check in, or request a one-time snapshot.';
  }
  if (hasAnswered ?? member.isCheckedInRecently) {
    return 'They checked in. A check-in says they checked in, not how they '
        'are.';
  }
  if (hasAnswered == false) {
    return "They haven't answered the check-in request yet. That is "
        'silence, not danger. You can ask again, or request a one-time '
        'snapshot.';
  }
  return "They haven't checked in recently. That is silence, not danger. "
      'You can ask them to check in.';
}

/// Which circles a check-in goes to.
///
/// Answering an ask is a deliberate act in one circle: with an ask owed
/// in the open circle, the check-in goes there only ([owedRequestId] set,
/// empty list = "the current circle"). With nothing owed here, a
/// spontaneous check-in goes to every circle, EXCEPT a
/// circle where someone is waiting on your check-in: answering that ask
/// must be your own tap there (Switch circle, then Check in), never a
/// side effect of checking in somewhere else.
List<String> checkInTargetCircleIds({
  required final String? owedRequestId,
  required final String? selectedCircleId,
  required final List<FamilyCircleSummary> circles,
}) {
  if (owedRequestId != null) return const [];
  final ids = <String>[];
  for (final c in circles) {
    if (c.pendingCheckInRequests > 0 && c.circleId != selectedCircleId) continue;
    if (!ids.contains(c.circleId)) ids.add(c.circleId);
  }
  if (selectedCircleId != null && !ids.contains(selectedCircleId)) {
    ids.insert(0, selectedCircleId);
  }
  return ids;
}
