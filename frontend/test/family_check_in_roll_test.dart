import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/check_in_roll.dart';

// The hub header, the name chips and the split member list all read from
// CheckInRoll, so "who has checked in and who hasn't" is one answer.
FamilyMember member(final String id, {final DateTime? last}) =>
    FamilyMember(id: id, userId: 'u-$id', name: id, lastCheckInAt: last);

FamilyCircle circle(
  final List<FamilyMember> members, {
  final FamilyCheckInRequest? ask,
}) => FamilyCircle(
  id: 'c1',
  name: 'Nixon Family',
  myMemberId: 'me',
  members: members,
  latestCheckInRequest: ask,
);

void main() {
  final now = DateTime(2026, 9, 4, 9, 0);

  test('without an ask, checked in means within the last day', () {
    final roll = CheckInRoll.of(
      circle([
        member('me', last: now.subtract(const Duration(hours: 1))),
        member('Tom', last: now.subtract(const Duration(hours: 23))),
        member('Amy', last: now.subtract(const Duration(hours: 25))),
        member('Ben'),
      ]),
      now: now,
    );
    expect(roll.askedAt, isNull);
    expect(roll.checkedIn.map((m) => m.id), ['me', 'Tom']);
    expect(roll.notYet.map((m) => m.id), ['Amy', 'Ben']);
    expect(roll.everyoneAccountedFor, isFalse);
  });

  test('with a fresh ask, only a check-in AFTER the ask counts', () {
    final askedAt = now.subtract(const Duration(minutes: 10));
    final roll = CheckInRoll.of(
      circle(
        [
          member('me', last: now.subtract(const Duration(hours: 1))),
          member('Tom', last: now.subtract(const Duration(minutes: 5))),
          member('Amy', last: now.subtract(const Duration(minutes: 30))),
        ],
        ask: FamilyCheckInRequest(
          id: 'r1',
          circleId: 'c1',
          requestedById: 'Amy',
          createdAt: askedAt,
        ),
      ),
      now: now,
    );
    expect(roll.askedAt, askedAt);
    expect(roll.requesterId, 'Amy');
    // Amy asked, so she is never "waiting on herself"; I checked in an
    // hour ago, BEFORE the ask, so I still owe an answer.
    expect(roll.checkedIn.map((m) => m.id), ['Tom', 'Amy']);
    expect(roll.notYet.map((m) => m.id), ['me']);
  });

  test('an ask older than a day falls back to the plain reading', () {
    final roll = CheckInRoll.of(
      circle(
        [member('me', last: now.subtract(const Duration(hours: 2)))],
        ask: FamilyCheckInRequest(
          id: 'r1',
          circleId: 'c1',
          requestedById: 'Tom',
          createdAt: now.subtract(const Duration(hours: 30)),
        ),
      ),
      now: now,
    );
    expect(roll.askedAt, isNull);
    expect(roll.checkedIn.map((m) => m.id), ['me']);
    expect(roll.everyoneAccountedFor, isTrue);
  });

  test('waitingOnLabel names people, never a bare count', () {
    expect(waitingOnLabel([]), 'Everyone is accounted for');
    expect(waitingOnLabel(['Amy']), 'Waiting on Amy');
    expect(waitingOnLabel(['Amy', 'Tom']), 'Waiting on Amy and Tom');
    expect(
      waitingOnLabel(['Amy', 'Tom', 'Ben', 'Kim']),
      'Waiting on Amy, Tom and 2 more',
    );
  });

  test('checkedInLabel puts "you" last', () {
    expect(checkedInLabel([], meIncluded: false), 'Nobody has checked in yet');
    expect(checkedInLabel([], meIncluded: true), 'You checked in');
    expect(checkedInLabel(['Tom'], meIncluded: false), 'Tom checked in');
    expect(checkedInLabel(['Tom'], meIncluded: true), 'Tom and you checked in');
    expect(
      checkedInLabel(['Tom', 'Amy'], meIncluded: true),
      'Tom, Amy and you checked in',
    );
  });
}
