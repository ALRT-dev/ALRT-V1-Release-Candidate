import 'package:hazard_app/features/family/models/family_models.dart';

/// Who has answered and who is still owed, worked out ONE way for the
/// whole hub (header, chips, member list), so the three never disagree.
///
/// "Answered" means: checked in since the latest ask, when there is an
/// ask younger than a day; otherwise simply checked in within the last
/// day. The person who ASKED is never in the waiting list - they are not
/// waiting on themself (two-phone QA 2026-08-06).
class CheckInRoll {
  const CheckInRoll({
    required this.checkedIn,
    required this.notYet,
    required this.askedAt,
    required this.requesterId,
    this.targetMemberIds = const [],
  });

  /// Members who have answered (or asked), in circle order.
  final List<FamilyMember> checkedIn;

  /// Members still owed, in circle order.
  final List<FamilyMember> notYet;

  /// The ask this roll is measured against, or null when it is the plain
  /// "checked in today" reading.
  final DateTime? askedAt;

  /// Who asked, when [askedAt] is set.
  final String? requesterId;

  /// Members [askedAt] is aimed at (see FamilyCheckInRequest.targetMemberIds);
  /// empty = everyone. Only meaningful when [askedAt] is set.
  final List<String> targetMemberIds;

  bool get everyoneAccountedFor => notYet.isEmpty;

  /// Whether [member] counts as having answered on this roll.
  bool hasAnswered(final FamilyMember member) =>
      checkedIn.any((m) => m.id == member.id);

  static const _askFreshFor = Duration(hours: 24);

  static CheckInRoll of(final FamilyCircle circle, {final DateTime? now}) {
    final at = now ?? DateTime.now();
    final request = circle.latestCheckInRequest;
    final requestedAt = request?.createdAt;
    final askIsFresh =
        requestedAt != null && at.difference(requestedAt) < _askFreshFor;
    final askedAt = askIsFresh ? requestedAt : null;
    final requesterId = askIsFresh ? request?.requestedById : null;

    final checkedIn = <FamilyMember>[];
    final notYet = <FamilyMember>[];
    for (final member in circle.members) {
      final last = member.lastCheckInAt;
      final bool answered;
      if (member.id == requesterId) {
        answered = true;
      } else if (askedAt != null && request!.isAimedAt(member.id)) {
        // Asked (everyone, or this person by name): only a check-in
        // AFTER the ask counts.
        answered = last != null && last.isAfter(askedAt);
      } else {
        // Not asked by this request: the plain "checked in today" reading.
        answered = last != null && at.difference(last) < _askFreshFor;
      }
      (answered ? checkedIn : notYet).add(member);
    }
    return CheckInRoll(
      checkedIn: checkedIn,
      notYet: notYet,
      askedAt: askedAt,
      requesterId: requesterId,
      targetMemberIds: askedAt == null ? const [] : request!.targetMemberIds,
    );
  }
}

/// "Waiting on Amy", "Waiting on Amy and Tom", "Waiting on Amy, Tom and
/// 2 more" - names, never a bare count, because a name is what makes
/// someone pick up the phone. Empty list: "Everyone is accounted for".
String waitingOnLabel(final List<String> names) {
  if (names.isEmpty) return 'Everyone is accounted for';
  if (names.length == 1) return 'Waiting on ${names[0]}';
  if (names.length == 2) return 'Waiting on ${names[0]} and ${names[1]}';
  final rest = names.length - 2;
  return 'Waiting on ${names[0]}, ${names[1]} and $rest more';
}

/// "Tom and you checked in", "Tom, Amy and you checked in", "Nobody has
/// checked in yet". [meIncluded] puts "you" last, the way people say it.
String checkedInLabel(
  final List<String> otherNames, {
  required final bool meIncluded,
}) {
  final names = [...otherNames, if (meIncluded) 'you'];
  if (names.isEmpty) return 'Nobody has checked in yet';
  if (names.length == 1) {
    return names[0] == 'you' ? 'You checked in' : '${names[0]} checked in';
  }
  final head = names.sublist(0, names.length - 1).join(', ');
  return '$head and ${names.last} checked in';
}
