import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/home_screen_widget/family_widget_model.dart';
import 'package:hazard_app/features/home_screen_widget/models/family_widget_payload.dart';

/// The Family circles widget (issue 3): one row per circle, most urgent
/// first, honest words, no member names or locations, one deep link per
/// row that only ever opens the app.
void main() {
  final now = DateTime(2026, 9, 9, 9, 0);

  FamilyMember member(
    String id, {
    DateTime? lastCheckInAt,
    String name = 'Someone',
  }) => FamilyMember(
    id: id,
    userId: 'u-$id',
    name: name,
    lastCheckInAt: lastCheckInAt,
  );

  FamilyCircle circle({
    String id = 'c1',
    String name = 'Nixons',
    List<FamilyMember>? members,
    List<FamilyCheckInRequest> requests = const [],
  }) => FamilyCircle(
    id: id,
    name: name,
    myMemberId: 'me',
    members:
        members ??
        [
          member('me', name: 'Me'),
          member('amy', name: 'Amy Nixon'),
          member('tom', name: 'Tom'),
        ],
    checkInRequests: requests,
  );

  FamilyCircleSummary summary(
    String id,
    String name, {
    int pending = 0,
    FamilyCircleSosSummary? sos,
    int members = 3,
    int checkedIn = 1,
  }) => FamilyCircleSummary(
    circleId: id,
    name: name,
    myMemberId: 'me-$id',
    memberCount: members,
    checkedInCount: checkedIn,
    pendingCheckInRequests: pending,
    activeSos: sos,
  );

  test('no circle: says so and points at the app', () {
    final p = FamilyWidgetModel.build(
      const FamilyProviderState(hasLoadedOnce: true),
      now: now,
    );
    expect(p.state, 'no_circle');
    expect(p.headline, 'No family circle yet');
    expect(p.rows, isEmpty);
    expect(p.deeplink, contains('screen=family'));
  });

  test('no pending requests: honest wording, never "everyone is safe"', () {
    final state = FamilyProviderState(
      hasLoadedOnce: true,
      circle: circle(
        members: [
          member('me'),
          member('amy', lastCheckInAt: DateTime(2026, 9, 1)),
          member(
            'tom',
            lastCheckInAt: now.subtract(const Duration(minutes: 30)),
          ),
        ],
      ),
      circles: [summary('c1', 'Nixons')],
    );
    final p = FamilyWidgetModel.build(state, now: now);
    expect(p.state, 'ok');
    expect(p.headline, 'No pending requests');
    expect(p.rows.single.headline, 'No pending requests');
    expect(p.rows.single.sub, contains('checked in today'));
    final json = jsonEncode(p.toJson()).toLowerCase();
    expect(json, isNot(contains("everyone's safe")));
    expect(json, isNot(contains('everyone is safe')));
  });

  test(
    'a check-in request owed by me outranks ordinary status and links to the check-in flow',
    () {
      final ask = FamilyCheckInRequest(
        id: 'r1',
        circleId: 'c1',
        requestedById: 'amy',
        createdAt: now.subtract(const Duration(minutes: 5)),
      );
      final state = FamilyProviderState(
        hasLoadedOnce: true,
        circle: circle(requests: [ask]),
        circles: [summary('c1', 'Nixons', pending: 1)],
      );
      final p = FamilyWidgetModel.build(state, now: now);
      expect(p.state, 'check_in_requested');
      expect(p.rows.single.kind, FamilyWidgetRowKind.checkInRequested);
      expect(p.rows.single.headline, 'Check-in requested');
      expect(p.rows.single.deeplink, contains('screen=family_checkin'));
      expect(p.rows.single.deeplink, contains('circleId=c1'));
    },
  );

  test('an ask I made shows "Waiting for responses", not a request to me', () {
    final ask = FamilyCheckInRequest(
      id: 'r1',
      circleId: 'c1',
      requestedById: 'me',
      createdAt: now.subtract(const Duration(minutes: 5)),
    );
    final state = FamilyProviderState(
      hasLoadedOnce: true,
      circle: circle(
        members: [
          member('me'),
          member('amy', lastCheckInAt: now),
          member('tom', lastCheckInAt: DateTime(2026, 9, 1)),
        ],
        requests: [ask],
      ),
      circles: [summary('c1', 'Nixons')],
    );
    final p = FamilyWidgetModel.build(state, now: now);
    expect(p.state, 'waiting');
    expect(p.rows.single.headline, 'Waiting for responses');
    expect(p.rows.single.sub, '1 of 2 answered');
  });

  test('my SOS beats everything, is worded as mine, and links to that SOS', () {
    final state = FamilyProviderState(
      hasLoadedOnce: true,
      circle: circle(),
      circles: [
        summary('c1', 'Nixons', pending: 2),
        summary('c2', 'Weekend crew'),
      ],
      activeSosEvents: const [
        FamilySosEvent(id: 'sos-1', circleId: 'c1', memberId: 'me'),
      ],
    );
    final p = FamilyWidgetModel.build(state, now: now);
    expect(p.state, 'sos');
    expect(p.isCritical, isTrue);
    expect(p.headline, 'Your SOS is active');
    expect(p.rows.first.kind, FamilyWidgetRowKind.sosMine);
    expect(
      p.rows.first.deeplink,
      'alrtwidget://open?screen=family_sos&circleId=c1&sosId=sos-1',
    );
  });

  test(
    "another member's SOS in a circle that is not open is first, without their name",
    () {
      final state = FamilyProviderState(
        hasLoadedOnce: true,
        circle: circle(),
        circles: [
          summary('c1', 'Nixons'),
          summary(
            'c2',
            'Weekend crew',
            sos: FamilyCircleSosSummary(
              id: 'sos-9',
              memberId: 'other',
              memberName: 'Amy Nixon',
              createdAt: now,
            ),
          ),
        ],
      );
      final p = FamilyWidgetModel.build(state, now: now);
      expect(p.state, 'sos');
      expect(p.rows.first.name, 'Weekend crew');
      expect(p.rows.first.kind, FamilyWidgetRowKind.sosOther);
      expect(p.rows.first.headline, 'SOS active');
      expect(jsonEncode(p.toJson()), isNot(contains('Amy Nixon')));
      expect(p.sub, contains('Weekend crew'));
    },
  );

  test(
    'requests across circles are all listed, one row each, no duplicates',
    () {
      final state = FamilyProviderState(
        hasLoadedOnce: true,
        circle: circle(),
        circles: [
          summary('c1', 'Nixons'),
          summary('c2', 'Weekend crew', pending: 1),
          summary('c3', 'School run', pending: 3),
        ],
      );
      final p = FamilyWidgetModel.build(state, now: now);
      expect(p.headline, '2 circles asked you to check in');
      expect(p.rows.map((r) => r.circleId).toSet().length, p.rows.length);
      expect(
        p.rows
            .where((r) => r.kind == FamilyWidgetRowKind.checkInRequested)
            .length,
        2,
      );
      expect(p.rows.first.name, 'School run');
      expect(p.rows.first.sub, '3 requests · tap to check in');
      expect(p.rows.last.name, 'Nixons');
    },
  );

  test('more than four circles: four rows and an honest "+N more"', () {
    final state = FamilyProviderState(
      hasLoadedOnce: true,
      circle: circle(),
      circles: [for (var i = 1; i <= 6; i++) summary('c$i', 'Circle $i')],
    );
    final p = FamilyWidgetModel.build(state, now: now);
    expect(p.rows.length, FamilyWidgetPayload.maxRows);
    expect(p.moreCircles, 2);
    expect(p.sub, 'Across 6 circles');
  });

  test(
    'the payload never carries coordinates, member names or a safety profile',
    () {
      final state = FamilyProviderState(
        hasLoadedOnce: true,
        circle: circle(),
        circles: [summary('c1', 'Nixons')],
        activeSosEvents: const [
          FamilySosEvent(
            id: 'sos-1',
            circleId: 'c1',
            memberId: 'amy',
            latitude: -27.4,
            longitude: 153.0,
            locationLabel: 'Scarborough',
          ),
        ],
      );
      final json = jsonEncode(
        FamilyWidgetModel.build(state, now: now).toJson(),
      );
      expect(json, isNot(contains('153.0')));
      expect(json, isNot(contains('Scarborough')));
      expect(json, isNot(contains('Amy')));
      expect(json, isNot(contains('latitude')));
      expect(json, contains('"generatedAt"'));
    },
  );

  test('signed out clears to a signed-out card', () {
    final p = FamilyWidgetModel.signedOut(now);
    expect(p.state, 'signed_out');
    expect(p.rows, isEmpty);
  });

  group('taps only navigate', () {
    test('a family tap carries the circle', () {
      final tap = FamilyWidgetTap.parse(
        Uri.parse('alrtwidget://open?screen=family&circleId=c2'),
      );
      expect(tap, isA<OpenFamilyTap>());
      expect((tap as OpenFamilyTap).circleId, 'c2');
    });
    test('a check-in tap opens the flow, never checks in', () {
      final tap = FamilyWidgetTap.parse(
        Uri.parse('alrtwidget://open?screen=family_checkin&circleId=c1'),
      );
      expect(tap, isA<OpenCheckInTap>());
    });
    test('an SOS tap names the SOS', () {
      final tap = FamilyWidgetTap.parse(
        Uri.parse('alrtwidget://open?screen=family_sos&circleId=c1&sosId=s9'),
      );
      expect(tap, isA<OpenSosTap>());
      expect((tap as OpenSosTap).sosId, 's9');
    });
    test('a foreign scheme or unknown screen is ignored', () {
      expect(
        FamilyWidgetTap.parse(
          Uri.parse('https://example.com/open?screen=family'),
        ),
        isNull,
      );
      expect(
        FamilyWidgetTap.parse(Uri.parse('alrtwidget://open?screen=nope')),
        isNull,
      );
      expect(FamilyWidgetTap.parse(null), isNull);
    });
  });
}
