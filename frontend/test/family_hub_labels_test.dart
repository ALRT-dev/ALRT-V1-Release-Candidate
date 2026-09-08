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
      expect(checkInCardTitle([]), "Let your circle know you're okay");
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

  group('seats across hosted circles', () {
    const owned1 = FamilyCircleSummary(
      circleId: 'a', name: 'A', myMemberId: 'me', isOwned: true, seatCount: 3,
    );
    const owned2 = FamilyCircleSummary(
      circleId: 'b', name: 'B', myMemberId: 'me', isOwned: true, seatCount: 2,
    );
    const joined = FamilyCircleSummary(
      circleId: 'c', name: 'C', myMemberId: 'me', isOwned: false, seatCount: 7,
    );

    test('only owned circles count', () {
      expect(seatsUsedAcrossHostedCircles([owned1, owned2, joined]), 5);
      expect(seatsUsedAcrossHostedCircles([joined]), 0);
    });

    test('line says across circles you host, out of 8', () {
      expect(
        hostedSeatLine(seatsUsed: 5),
        '5 of 8 seats used across circles you host',
      );
      expect(hostedSeatLine(seatsUsed: 11), startsWith('8 of 8'));
    });

    test('non-hosts see who hosts, and that joining is free', () {
      expect(hostedByLine('Sarah'), 'Hosted by Sarah · joining is free');
      expect(hostedByLine(null), contains('none of your own seats'));
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
    test('Safe when answered, Near when near an alert', () {
      expect(
        memberStatusChip(member: member(), hasAnswered: true, isNearAlert: false),
        'Safe',
      );
      expect(
        memberStatusChip(member: member(), hasAnswered: true, isNearAlert: true),
        'Near',
      );
    });
  });
}
