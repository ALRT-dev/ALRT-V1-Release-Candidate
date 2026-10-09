import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';

/// Several people can ask for a check-in within the same day. The circle
/// must name all of them, drop the ones already answered, ignore asks
/// aimed at someone else, and still work with a server that sends only
/// the latest ask.
void main() {
  final now = DateTime(2026, 9, 8, 9, 0);

  FamilyMember member(String id, {DateTime? last}) => FamilyMember(
        id: id,
        userId: 'u-$id',
        name: id,
        lastCheckInAt: last,
      );

  FamilyCheckInRequest ask(
    String id,
    String by, {
    required int minutesAgo,
    List<String> targets = const [],
  }) =>
      FamilyCheckInRequest(
        id: id,
        circleId: 'c1',
        requestedById: by,
        requestedBy: FamilyMemberSnippet(id: by, nickname: by),
        createdAt: now.subtract(Duration(minutes: minutesAgo)),
        targetMemberIds: targets,
      );

  FamilyCircle circle({
    required List<FamilyCheckInRequest> asks,
    FamilyCheckInRequest? latest,
    DateTime? myLast,
  }) =>
      FamilyCircle(
        id: 'c1',
        name: 'The Nixons',
        myMemberId: 'me',
        members: [member('me', last: myLast), member('amy'), member('tom')],
        latestCheckInRequest: latest ?? asks.firstOrNull,
        checkInRequests: asks,
      );

  test('names every asker, newest first, without repeats', () {
    final c = circle(asks: [
      ask('r3', 'tom', minutesAgo: 3),
      ask('r2', 'amy', minutesAgo: 5, targets: ['me']),
      ask('r1', 'amy', minutesAgo: 40),
    ]);
    expect(c.checkInRequestsOwedByMe.map((r) => r.id), ['r3', 'r2', 'r1']);
    expect(c.namesOwedMyCheckIn, ['tom', 'amy']);
    expect(c.checkInRequestOwedByMe?.id, 'r3');
  });

  test('a check-in after the newest ask answers all of them', () {
    final c = circle(
      asks: [ask('r2', 'tom', minutesAgo: 30), ask('r1', 'amy', minutesAgo: 60)],
      myLast: now.subtract(const Duration(minutes: 10)),
    );
    expect(c.checkInRequestsOwedByMe, isEmpty);
    expect(c.checkInRequestOwedByMe, isNull);
  });

  test('a check-in between two asks leaves only the newer one owed', () {
    final c = circle(
      asks: [ask('r2', 'tom', minutesAgo: 5), ask('r1', 'amy', minutesAgo: 60)],
      myLast: now.subtract(const Duration(minutes: 30)),
    );
    expect(c.checkInRequestsOwedByMe.map((r) => r.id), ['r2']);
  });

  test('my own asks and asks aimed at others are not owed by me', () {
    final c = circle(asks: [
      ask('mine', 'me', minutesAgo: 2),
      ask('theirs', 'amy', minutesAgo: 4, targets: ['tom']),
      ask('forMe', 'tom', minutesAgo: 6, targets: ['me']),
    ]);
    expect(c.checkInRequestsOwedByMe.map((r) => r.id), ['forMe']);
  });

  test('falls back to the single latest ask from an older server', () {
    final c = circle(asks: const [], latest: ask('r1', 'amy', minutesAgo: 5));
    expect(c.openCheckInRequests.map((r) => r.id), ['r1']);
    expect(c.namesOwedMyCheckIn, ['amy']);
  });
}
