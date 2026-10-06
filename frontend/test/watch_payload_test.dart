import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/home_screen_widget/family_widget_model.dart';
import 'package:hazard_app/features/home_screen_widget/models/family_widget_payload.dart';
import 'package:hazard_app/features/wearable/watch_payload.dart';

void main() {
  final at = DateTime.utc(2026, 10, 7, 9, 41);

  FamilyWidgetPayload payload() => FamilyWidgetPayload(
    state: 'check_in_requested',
    headline: 'Check-in requested',
    sub: 'Home · tap to check in',
    deeplink: 'alrt://open?screen=family',
    generatedAt: at,
    rows: const [
      FamilyWidgetRow(
        circleId: 'c-home',
        name: 'Home',
        kind: FamilyWidgetRowKind.checkInRequested,
        headline: 'Check-in requested',
        sub: 'Tap to check in',
        deeplink: 'alrt://open?screen=family_checkin&circleId=c-home',
        isCurrent: true,
        iconPath: '/private/icon.png',
      ),
    ],
  );

  group('WatchPayload', () {
    test('carries circle names and status only, never deep links or files', () {
      final map = WatchPayload.fromWidget(payload());
      expect(map['signedIn'], true);
      expect(map['state'], 'check_in_requested');
      final rows = map['rows']! as List;
      expect(rows, hasLength(1));
      final row = rows.single as Map;
      expect(row.keys, unorderedEquals(['circleId', 'name', 'kind', 'headline', 'sub']));
      expect(row['kind'], 'check_in_requested');
    });

    test('holds no null values (WatchConnectivity property lists only)', () {
      void walk(final Object? v) {
        expect(v, isNotNull);
        if (v is Map) v.values.forEach(walk);
        if (v is List) v.forEach(walk);
      }

      walk(WatchPayload.fromWidget(payload()));
      walk(WatchPayload.fromWidget(FamilyWidgetModel.signedOut(at)));
    });

    test('signed out tells the watch to forget everything', () {
      final map = WatchPayload.fromWidget(FamilyWidgetModel.signedOut(at));
      expect(map['signedIn'], false);
      expect(map['rows'], isEmpty);
    });
  });

  group('WatchAction.parse', () {
    const key = '3f2b8c1e-9d4a-4b6f-8e2a-1c5d7e9f0a12';

    test('check-in sends the client key and never a location', () {
      final a = WatchAction.parse({'action': 'checkIn', 'circleId': 'c1', 'clientRequestId': key});
      expect(a, isA<WatchCheckIn>());
      expect(a!.body, {'clientRequestId': key});
    });

    test('SOS goes without location and says so explicitly', () {
      final a = WatchAction.parse({'action': 'sos', 'circleId': 'c1', 'clientRequestId': key});
      expect(a, isA<WatchSos>());
      expect(a!.body, {'isLive': false, 'locationMode': 'none', 'clientRequestId': key});
    });

    test('SOS preview needs no key', () {
      expect(WatchAction.parse({'action': 'sosPreview', 'circleId': 'c1'}), isA<WatchSosPreview>());
    });

    test('refuses unknown actions, missing circles and malformed keys', () {
      expect(WatchAction.parse({'action': 'endSos', 'circleId': 'c1', 'clientRequestId': key}), isNull);
      expect(WatchAction.parse({'action': 'checkIn', 'clientRequestId': key}), isNull);
      expect(WatchAction.parse({'action': 'checkIn', 'circleId': 'c1', 'clientRequestId': 'x'}), isNull);
      expect(WatchAction.parse({'action': 'sos', 'circleId': 'c1'}), isNull);
    });
  });

  group('WatchActionResult', () {
    test('success names the circle and is factual (never "safe")', () {
      final r = WatchActionResult.checkedIn('Home', DateTime(2026, 10, 7, 21, 5));
      expect(r.ok, true);
      expect(r.title, 'Checked in to Home');
      expect(r.detail, '9:05 pm');
      expect(r.title.toLowerCase(), isNot(contains('safe')));
    });

    test('offline is "Not sent", never a pretend success', () {
      final r = WatchActionResult.failed(offline: true);
      expect(r.ok, false);
      expect(r.title, 'Not sent');
    });

    test('uses the server message when there is one', () {
      final r = WatchActionResult.failed(
        status: 422,
        body: {'error': 'Add someone first. You need at least one other person to send an SOS.'},
      );
      expect(r.detail, startsWith('Add someone first'));
    });
  });

  group('WatchSosPreview', () {
    test('names who it reaches and that no location is sent', () {
      final m = WatchSosPreview.toMessage({
        'state': 'ok',
        'recipients': [
          {'memberId': 'a', 'name': 'Amy'},
          {'memberId': 't', 'name': 'Tom'},
        ],
      });
      expect(m['canSend'], true);
      expect(m['names'], ['Amy', 'Tom']);
      expect(m['detail'], 'Goes to Amy and Tom. No location is sent from your watch.');
    });

    test('nobody to reach means no hold button', () {
      final m = WatchSosPreview.toMessage({'state': 'noPeople', 'recipients': []});
      expect(m['canSend'], false);
    });
  });
}
