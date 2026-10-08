import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/sos_record.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_resolved_screen.dart';

// The Past SOS record used to say "Live location ran for X" whatever the
// sender chose, "visible to N family members" (the whole group's size
// today, as a bare count), "[Name] stopped sharing at [time]", and that
// snapshots are "deleted within 1 hour" when the trail is wiped at once.
// It is built now from the stored location choice and audience, with the
// locked "SOS ended by [Name] at [time]." wording.

final _start = DateTime(2026, 10, 6, 14, 0);
// Ended by hand 25 minutes in: not an expiry.
final _ended = DateTime(2026, 10, 6, 14, 25);

FamilySosEvent _sos({
  final String? mode,
  final bool isLive = true,
  final String? precision,
  final bool? audienceRestricted = true,
  final List<String> recipientUserIds = const ['u-amy', 'u-tom'],
  final DateTime? resolvedAt,
  final String? endedBy = 'm-sam',
}) => FamilySosEvent(
  id: 's1',
  circleId: 'c1',
  memberId: 'm-sam',
  status: FamilySosStatus.resolved,
  isLive: isLive,
  locationMode: mode,
  locationPrecision: precision,
  createdAt: _start,
  resolvedAt: resolvedAt ?? _ended,
  endedByMemberId: endedBy,
  audienceRestricted: audienceRestricted,
  recipientUserIds: recipientUserIds,
  member: const FamilyMemberSnippet(
    id: 'm-sam',
    nickname: 'Sam',
    user: FamilyMemberUserSnippet(id: 'u-sam'),
  ),
);

void main() {
  group('what was shared, per location mode', () {
    test('no location', () {
      final text = sosRecordSharedText(
        _sos(mode: 'none', isLive: false),
        audienceNames: const ['Amy', 'Tom'],
      );
      expect(
        text,
        'No location was shared with this SOS. It was sent to Amy and Tom.',
      );
      expect(text, isNot(contains('Live location')));
      expect(text, isNot(contains('deleted')));
    });

    test('shared once', () {
      expect(
        sosRecordSharedText(
          _sos(mode: 'once', isLive: false),
          audienceNames: const ['Amy'],
        ),
        'Location was shared once, when the SOS was sent. It was sent to '
        'Amy. The location was deleted when the SOS ended.',
      );
    });

    test('live, suburb only, with how long the SOS ran', () {
      expect(
        sosRecordSharedText(
          _sos(mode: 'live', precision: 'approximate'),
          audienceNames: const ['Amy', 'Tom', 'you'],
        ),
        'Live location (suburb only) was shared during this SOS, which ran '
        'for 25 minutes. It was sent to Amy, Tom and you. The location '
        'trail was deleted when the SOS ended.',
      );
    });

    test('an old event without locationMode reads its isLive', () {
      expect(
        sosRecordLocationMode(_sos(isLive: false)),
        'none',
      );
      expect(sosRecordLocationMode(_sos()), 'live');
    });

    test('never "within 1 hour", never a bare "family members" count', () {
      for (final mode in ['none', 'once', 'live']) {
        final text = sosRecordSharedText(
          _sos(mode: mode),
          audienceNames: const ['Amy'],
        );
        expect(text, isNot(contains('within 1 hour')));
        expect(text, isNot(contains('family member')));
      }
    });
  });

  group('who it was sent to', () {
    test('names come from the stored audience, not the group today', () {
      final audience = sosAudienceNames(
        _sos(recipientUserIds: const ['u-amy', 'u-gone', 'u-me']),
        members: const [
          FamilyMember(id: 'm-amy', userId: 'u-amy', name: 'Amy'),
          FamilyMember(id: 'm-tom', userId: 'u-tom', name: 'Tom'),
          FamilyMember(id: 'm-me', userId: 'u-me', name: 'Me'),
        ],
        myUserId: 'u-me',
      );
      // Tom is in the group but was not in the audience: not named.
      expect(audience.names, ['Amy', 'you']);
      expect(audience.unnamed, 1);
      expect(
        sosRecordSharedText(
          _sos(mode: 'none'),
          audienceNames: audience.names,
          unnamedCount: audience.unnamed,
        ),
        'No location was shared with this SOS. It was sent to Amy, you and '
        '1 person no longer in the group.',
      );
    });

    test('an event from before the stored audience went to everyone', () {
      expect(
        sosRecordSharedText(_sos(mode: 'none', audienceRestricted: false)),
        'No location was shared with this SOS. It was sent to everyone in '
        'the group.',
      );
    });

    test('an unknown audience is left out, never guessed', () {
      expect(
        sosRecordSharedText(_sos(mode: 'none', audienceRestricted: null)),
        'No location was shared with this SOS.',
      );
    });
  });

  group('how it ended (locked wording)', () {
    test('ended by hand', () {
      expect(sosRecordEndedLine(_sos()), 'SOS ended by Sam at 2:25 pm.');
    });

    test('a sender who has left is named by the name it was sent under', () {
      const gone = FamilySosEvent(
        id: 's2',
        circleId: 'c1',
        memberId: 'm-gone',
        status: FamilySosStatus.resolved,
        senderName: 'Jo',
        member: FamilyMemberSnippet(id: 'm-gone'),
      );
      expect(sosSenderName(gone), 'Jo');
      expect(
        FamilySosEvent.fromJson(const {
          'id': 's3',
          'circleId': 'c1',
          'memberId': 'm-gone',
          'status': 'resolved',
          'senderName': 'Jo',
          'member': {'id': 'm-gone', 'nickname': 'Jo', 'user': null},
        }).member?.user,
        isNull,
      );
    });

    test('expired', () {
      final expired = _sos(
        endedBy: null,
        resolvedAt: _start.add(const Duration(hours: 1)),
      );
      expect(sosRecordEndedLine(expired), 'This SOS expired at 3:00 pm.');
    });
  });

  testWidgets('the record screen shows the facts and hides "Called"', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final sos = _sos(mode: 'once', isLive: false).copyWith(
      responses: [
        const FamilySosResponse(
          id: 'r1',
          sosEventId: 's1',
          memberId: 'm-amy',
          type: FamilySosResponseType.called,
          member: FamilyMemberSnippet(id: 'm-amy', nickname: 'Amy'),
        ),
        const FamilySosResponse(
          id: 'r2',
          sosEventId: 's1',
          memberId: 'm-tom',
          type: FamilySosResponseType.seen,
          member: FamilyMemberSnippet(id: 'm-tom', nickname: 'Tom'),
        ),
      ],
    );
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => ProviderScope(
          child: MaterialApp(
            home: FamilySosResolvedScreen(
              args: FamilySosResolvedScreenArgs(
                event: sos,
                audienceNames: const ['Amy', 'Tom'],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('SOS ended by Sam at 2:25 pm.'), findsOneWidget);
    expect(find.textContaining('stopped sharing'), findsNothing);
    expect(
      find.text(
        'Location was shared once, when the SOS was sent. It was sent to '
        'Amy and Tom. The location was deleted when the SOS ended.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Called'), findsNothing);
    expect(find.textContaining('Responded'), findsNothing);
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('Amy'), findsNothing);
  });
}
