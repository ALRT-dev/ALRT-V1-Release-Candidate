import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/family_hub_labels.dart';

// The hub's wording for the one "I'm Safe" control, seats across hosted
// circles, the tile layout at large text, and a member's state line.
void main() {
  final now = DateTime(2026, 9, 7, 12, 0);

  FamilyMember member({
    FamilySharingLevel level = FamilySharingLevel.precise,
    DateTime? last,
    String? label,
    DateTime? sharedAt,
    DateTime? expiresAt,
  }) => FamilyMember(
    id: 'm1',
    userId: 'u1',
    name: 'Tom',
    sharingLevel: level,
    lastCheckInAt: last,
    locationLabel: label,
    locationUpdatedAt: sharedAt,
    locationExpiresAt: expiresAt,
  );

  group('imSafeLabel', () {
    test('plain when nobody is owed an answer', () {
      expect(imSafeLabel(), 'Check in');
      expect(imSafeLabel(requesterName: ''), 'Check in');
    });
    test('names the requester while their ask is open', () {
      expect(imSafeLabel(requesterName: 'Amy'), 'Check in · lets Amy know');
    });
    test('names every asker when several asked, kept short', () {
      expect(
        imSafeLabel(requesterNames: ['Amy', 'Tom']),
        'Check in · lets Amy and Tom know',
      );
      expect(
        imSafeLabel(requesterNames: ['Amy', 'Tom', 'Emma', 'James']),
        'Check in · lets Amy, Tom +2 know',
      );
      expect(
        imSafeLabel(requesterName: 'Amy', requesterNames: ['Amy', 'Tom']),
        'Check in · lets Amy and Tom know',
      );
    });
  });

  group('check-in card wording', () {
    test('askersLabel', () {
      expect(askersLabel([]), 'Your circle');
      expect(askersLabel(['Amy']), 'Amy');
      expect(askersLabel(['Amy', 'Tom']), 'Amy and Tom');
      expect(askersLabel(['Amy', 'Tom', 'Emma']), 'Amy, Tom +1');
    });
    test('title reads as the mockup', () {
      expect(checkInCardTitle([]), 'Your check-in');
      expect(checkInCardTitle(['Amy']), 'Amy requested a check-in');
      expect(
        checkInCardTitle(['Amy', 'Tom', 'Emma', 'James']),
        'Amy, Tom +2 requested a check-in',
      );
    });
    test('View N requests only when there is more than one', () {
      expect(viewRequestsLabel(0), isNull);
      expect(viewRequestsLabel(1), isNull);
      expect(viewRequestsLabel(4), 'View 4 requests');
    });
  });

  group('people and host lines (V1: no seats)', () {
    test('people line counts people, singular and plural', () {
      expect(peopleLine(1), '1 person');
      expect(peopleLine(4), '4 people');
    });

    test('non-hosts see who hosts, and that joining is free', () {
      expect(hostedByLine('Sarah'), 'Hosted by Sarah · joining is free');
      expect(hostedByLine(null), 'Joining is free');
      expect(hostedByLine(null), isNot(contains('seat')));
    });
  });

  test('quick tiles stack past a modest text scale', () {
    expect(useStackedQuickTiles(1.0), isFalse);
    expect(useStackedQuickTiles(1.15), isFalse);
    expect(useStackedQuickTiles(1.3), isTrue);
  });

  group('memberStatusLine', () {
    test('an unanswered ask leads, with the last check-in', () {
      final line = memberStatusLine(
        member: member(last: now.subtract(const Duration(days: 1))),
        hasAnswered: false,
        askedAt: now.subtract(const Duration(minutes: 3)),
        now: now,
      );
      expect(line, 'Asked 3 minutes ago');
    });

    test('an unanswered ask with no check-in ever', () {
      final line = memberStatusLine(
        member: member(),
        hasAnswered: false,
        askedAt: now.subtract(const Duration(minutes: 3)),
        now: now,
      );
      expect(line, 'Asked 3 minutes ago');
    });

    test('a snapshot says where, when, and when it expires', () {
      final line = memberStatusLine(
        member: member(
          label: 'Scarborough',
          sharedAt: now.subtract(const Duration(minutes: 10)),
          expiresAt: now.add(const Duration(minutes: 30)),
        ),
        hasAnswered: true,
        now: now,
      );
      expect(line, 'Scarborough · shared 10 minutes ago · expires 30 minutes from now');
    });

    test('hidden location still reports the last check-in', () {
      expect(
        memberStatusLine(
          member: member(
            level: FamilySharingLevel.off,
            last: now.subtract(const Duration(hours: 2)),
          ),
          hasAnswered: true,
          now: now,
        ),
        'Location hidden · checked in 2 hours ago',
      );
      expect(
        memberStatusLine(
          member: member(level: FamilySharingLevel.alertsOnly),
          hasAnswered: null,
          now: now,
        ),
        'Location hidden · no check-in yet',
      );
    });

    test('never says "snapshot" for someone who simply has not checked in', () {
      expect(
        memberStatusLine(member: member(), hasAnswered: null, now: now),
        'No check-in yet',
      );
      expect(
        memberStatusLine(
          member: member(last: now.subtract(const Duration(minutes: 5))),
          hasAnswered: true,
          now: now,
        ),
        'Checked in 5 minutes ago',
      );
    });
  });

  group('memberStatusChip', () {
    test('"Waiting" for silence, never "unsafe"', () {
      final chip = memberStatusChip(
        member: member(),
        hasAnswered: false,
        isNearAlert: false,
      );
      expect(chip, 'Waiting');
      expect(chip.toLowerCase(), isNot(contains('unsafe')));
    });
    test('Checked in when answered (never "Safe"), Near when near an alert', () {
      expect(
        memberStatusChip(member: member(), hasAnswered: true, isNearAlert: false),
        'Checked in',
      );
      expect(
        memberStatusChip(member: member(), hasAnswered: true, isNearAlert: true),
        'Near',
      );
    });
  });

  test('no outstanding request is "No recent check-in", not "Waiting"', () {
    expect(
      memberStatusChip(member: member(), hasAnswered: null, isNearAlert: false),
      'No recent check-in',
    );
  });

  group('checkInTargetCircleIds', () {
    const home = FamilyCircleSummary(circleId: 'home', name: 'Home', myMemberId: 'm1');
    const work = FamilyCircleSummary(circleId: 'work', name: 'Work', myMemberId: 'm2');
    const crew = FamilyCircleSummary(
      circleId: 'crew', name: 'Crew', myMemberId: 'm3', pendingCheckInRequests: 1,
    );

    test('answering an ask stays in the current circle', () {
      expect(
        checkInTargetCircleIds(owedRequestId: 'r1', selectedCircleId: 'home', circles: [home, work, crew]),
        isEmpty,
      );
    });
    test('a spontaneous check-in tells every circle with nothing waiting', () {
      expect(
        checkInTargetCircleIds(owedRequestId: null, selectedCircleId: 'home', circles: [home, work]),
        ['home', 'work'],
      );
    });
    test('never silently answers an ask waiting in another circle', () {
      expect(
        checkInTargetCircleIds(owedRequestId: null, selectedCircleId: 'home', circles: [home, work, crew]),
        ['home', 'work'],
      );
    });
    test('the open circle is always included, even with its own ask count', () {
      expect(
        checkInTargetCircleIds(owedRequestId: null, selectedCircleId: 'crew', circles: [home, crew]),
        ['home', 'crew'],
      );
    });
  });
}
