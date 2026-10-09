import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/group_state.dart';

// The hub's group tiles and the groups page say the same one-line state
// for every group, open or not. These pin the words and the priority.
FamilyCircleSummary summary({
  final int members = 3,
  final int checkedIn = 0,
  final List<String> waiting = const [],
  final FamilyCircleSosSummary? sos,
}) => FamilyCircleSummary(
  circleId: 'c1',
  name: 'Nixon Family',
  myMemberId: 'me',
  memberCount: members,
  checkedInCount: checkedIn,
  waitingOn: waiting,
  activeSos: sos,
);

void main() {
  test('an SOS beats everything, and names who', () {
    final state = groupStateOf(
      summary(
        checkedIn: 3,
        sos: const FamilyCircleSosSummary(id: 's1', memberId: 'tom', memberName: 'Tom'),
      ),
    );
    expect(state.kind, GroupStateKind.sos);
    expect(state.label, 'SOS live · Tom');
  });

  test('a live socket SOS counts even before the list is refreshed', () {
    final state = groupStateOf(
      summary(checkedIn: 3),
      activeSosEvents: const [
        FamilySosEvent(
          id: 's2',
          circleId: 'c1',
          memberId: 'amy',
          member: FamilyMemberSnippet(id: 'amy', nickname: 'Amy'),
        ),
      ],
    );
    expect(state.kind, GroupStateKind.sos);
    expect(state.label, 'SOS live · Amy');
  });

  test('waiting names the people, up to two, then a count', () {
    expect(
      groupStateOf(summary(checkedIn: 2, waiting: const ['Amy'])).label,
      '2 of 3 · waiting on Amy',
    );
    expect(
      groupStateOf(summary(members: 4, checkedIn: 2, waiting: const ['Amy', 'Tom'])).label,
      '2 of 4 · waiting on Amy and Tom',
    );
    expect(
      groupStateOf(
        summary(members: 5, checkedIn: 1, waiting: const ['Amy', 'Tom', 'Ben', 'Kim']),
      ).label,
      '1 of 5 · waiting on Amy, Tom +2',
    );
  });

  test('everyone in, and a group of one', () {
    final allIn = groupStateOf(summary(checkedIn: 3));
    expect(allIn.kind, GroupStateKind.allIn);
    expect(allIn.label, '3 of 3 checked in');
    final alone = groupStateOf(summary(members: 1, waiting: const ['Sarah']));
    expect(alone.kind, GroupStateKind.alone);
    expect(alone.label, 'Just you so far');
  });

  test('the open circle uses its live roll instead of the list counts', () {
    final now = DateTime(2026, 9, 4, 9);
    final open = FamilyCircle(
      id: 'c1',
      name: 'Nixon Family',
      myMemberId: 'me',
      members: [
        FamilyMember(id: 'me', userId: 'u1', name: 'Sarah', lastCheckInAt: now),
        FamilyMember(id: 'tom', userId: 'u2', name: 'Tom', lastCheckInAt: now),
        const FamilyMember(id: 'amy', userId: 'u3', name: 'Amy'),
      ],
    );
    // The stale list says nobody is in; the live circle says two are.
    final state = groupStateOf(
      summary(waiting: const ['Sarah', 'Tom', 'Amy']),
      openCircle: open,
      now: now,
    );
    expect(state.label, '2 of 3 · waiting on Amy');
  });

  test('a tile for a group that is not open reads its CheckInRoll, so a '
      'targeted ask waits on its targets only', () {
    final now = DateTime(2026, 9, 4, 9, 0);
    final loaded = FamilyCircle(
      id: 'c1',
      name: 'Nixon Family',
      myMemberId: 'me',
      members: const [
        FamilyMember(id: 'me', userId: 'u-me', name: 'Me'),
        FamilyMember(id: 'tom', userId: 'u-tom', name: 'Tom'),
        FamilyMember(id: 'amy', userId: 'u-amy', name: 'Amy'),
      ],
      latestCheckInRequest: FamilyCheckInRequest(
        id: 'r1',
        circleId: 'c1',
        requestedById: 'me',
        targetMemberIds: const ['amy'],
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
    );
    // The list's own waitingOn ignores who was asked: it would say Tom.
    final state = groupStateOf(
      summary(checkedIn: 0, waiting: const ['Tom', 'Amy']),
      loadedCircles: {'c1': loaded},
      now: now,
    );
    expect(state.kind, GroupStateKind.waiting);
    expect(state.label, '1 of 3 · waiting on Amy');
  });
}
