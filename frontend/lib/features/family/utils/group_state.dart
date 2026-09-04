import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/check_in_roll.dart';

/// The one-line state of a group as the hub tiles and the groups page say
/// it: an SOS running there beats everything; otherwise who is still owed
/// a check-in, by name; otherwise everyone is in. The same words in both
/// places, worked out here once.
enum GroupStateKind { sos, waiting, allIn, alone }

class GroupState {
  const GroupState({required this.kind, required this.label});

  final GroupStateKind kind;
  final String label;
}

/// [openCircle] is the fully loaded circle, if this summary is the one on
/// screen: its live roll beats the list's counts, which are only as fresh
/// as the last list fetch. [activeSosEvents] are the app-wide live SOS
/// events, which arrive over the socket for every group you are in.
GroupState groupStateOf(
  final FamilyCircleSummary summary, {
  final FamilyCircle? openCircle,
  final List<FamilySosEvent> activeSosEvents = const [],
  final DateTime? now,
}) {
  final liveSos = activeSosEvents
      .where((e) => e.circleId == summary.circleId)
      .firstOrNull;
  final sosName = liveSos?.member?.displayName ?? summary.activeSos?.memberName;
  if (liveSos != null || summary.activeSos != null) {
    return GroupState(kind: GroupStateKind.sos, label: 'SOS live · $sosName');
  }

  final int total;
  final int checkedIn;
  final List<String> waiting;
  if (openCircle != null && openCircle.id == summary.circleId) {
    final roll = CheckInRoll.of(openCircle, now: now);
    total = openCircle.members.length;
    checkedIn = roll.checkedIn.length;
    waiting = roll.notYet.map((m) => m.name).toList();
  } else {
    total = summary.memberCount;
    checkedIn = summary.checkedInCount;
    waiting = summary.waitingOn;
  }

  if (total <= 1) {
    return const GroupState(kind: GroupStateKind.alone, label: 'Just you so far');
  }
  if (waiting.isEmpty) {
    return GroupState(
      kind: GroupStateKind.allIn,
      label: '$checkedIn of $total checked in',
    );
  }
  final names = waiting.length <= 2
      ? waiting.join(' and ')
      : '${waiting[0]}, ${waiting[1]} +${waiting.length - 2}';
  return GroupState(
    kind: GroupStateKind.waiting,
    label: '$checkedIn of $total · waiting on $names',
  );
}
