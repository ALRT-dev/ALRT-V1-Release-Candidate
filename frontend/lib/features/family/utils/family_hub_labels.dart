import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Pure label helpers for the Family hub, kept widget-free so the wording
/// the hub shows for seats, tiles, the one "Check in" button and a member's
/// state can be unit-tested without pumping the screen.

/// ALRT+ carries this many seats across the circles one person hosts
/// (locked billing rule; MAX_SEATS_TOTAL in family.service.ts). Not a
/// per-circle cap, and never changed here.
const kFamilyMaxSeats = 8;

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
/// "Amy, Tom +2 requested a check-in", or the plain invitation.
String checkInCardTitle(final List<String> askers) => askers.isEmpty
    ? "Let your circle know you're okay"
    : '${askersLabel(askers)} requested a check-in';

/// "View 4 requests" — only when there is more than one to view.
String? viewRequestsLabel(final int count) =>
    count > 1 ? 'View $count requests' : null;

/// Seats in use across every circle the caller hosts. Only owned circles
/// spend the caller's seats; joined circles never do, and the host and
/// guests never hold a seat (seatCount already excludes them).
int seatsUsedAcrossHostedCircles(final List<FamilyCircleSummary> circles) =>
    circles.where((c) => c.isOwned).fold<int>(0, (sum, c) => sum + c.seatCount);

/// "3 of 8 seats used across circles you host" — worded so a host with two
/// circles never reads the number as this circle's alone.
String hostedSeatLine({
  required final int seatsUsed,
  final int maxSeats = kFamilyMaxSeats,
}) {
  final used = seatsUsed.clamp(0, maxSeats);
  return '$used of $maxSeats seats used across circles you host';
}

/// The line a non-host sees where the host sees the seat line.
String hostedByLine(final String? hostName) =>
    hostName == null || hostName.isEmpty
        ? 'Joining is free · you use none of your own seats here'
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

/// The short chip on a member row. "Waiting" is deliberate: it says the
/// circle is waiting on their check-in, not that anything is wrong.
String memberStatusChip({
  required final FamilyMember member,
  required final bool? hasAnswered,
  required final bool isNearAlert,
}) {
  if (isNearAlert) return 'Near';
  if (hasAnswered ?? member.isCheckedInRecently) return 'Safe';
  return 'Waiting';
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
    return 'They have checked in as safe on the current roll.';
  }
  return "They haven't checked in yet. That is silence, not danger — ask "
      'them to check in, or request a one-time snapshot.';
}
