import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/notification/services/wearable_push.dart';

// Locks in the rules of the wearable notification pilot
// (WEARABLES_AUDIT_AND_PLAN.md §4.5, §9 and §11): only the two pilot push
// types are recognised, the check-in button always names the circle, an SOS
// never gets an acknowledging button, success wording exists only for a
// server-confirmed outcome, and the same ask always maps to the same client
// key so two surfaces produce one row.
void main() {
  Map<String, dynamic> checkInRequestData({String? circleName = 'Home'}) => {
    'wearable': '1',
    'notificationType': 'familyCheckInRequest',
    'title': 'Check-in requested · Home',
    'body': 'Amy asked you to check in to Home.',
    'channelId': 'alrt_alerts',
    'urgent': '0',
    'category': 'ALRT_CHECKIN_REQUEST',
    'payload':
        '{"circleId":"c1","requestId":"r1",'
        '${circleName == null ? '' : '"circleName":"$circleName",'}'
        '"requesterName":"Amy"}',
  };

  group('parse', () {
    test('recognises a pilot check-in request', () {
      final m = WearablePushMessage.parse(checkInRequestData());
      expect(m, isNotNull);
      expect(m!.isCheckInRequest, isTrue);
      expect(m.isSos, isFalse);
      expect(m.circleId, 'c1');
      expect(m.circleName, 'Home');
      expect(m.requestId, 'r1');
      expect(m.category, WearablePush.categoryCheckInRequest);
      expect(m.channelId, WearablePush.channelDefault);
      expect(m.urgent, isFalse);
    });

    test('recognises a pilot SOS as urgent on the urgent channel', () {
      final m = WearablePushMessage.parse({
        'wearable': '1',
        'notificationType': 'familySos',
        'title': 'Sam triggered SOS',
        'body': 'Home · Open ALRT to see their SOS and respond.',
        'channelId': 'alrt_alerts_urgent',
        'urgent': '1',
        'payload': '{"circleId":"c1","circleName":"Home","sosEventId":"s1"}',
      });
      expect(m, isNotNull);
      expect(m!.isSos, isTrue);
      expect(m.urgent, isTrue);
      expect(m.channelId, WearablePush.channelUrgent);
      expect(m.sosEventId, 's1');
    });

    test('ignores every push that is not marked for the pilot', () {
      final data = checkInRequestData()..remove('wearable');
      expect(WearablePushMessage.parse(data), isNull);
    });

    test('ignores pilot-marked pushes of any other type', () {
      final data = checkInRequestData()
        ..['notificationType'] = 'familyCheckIn';
      expect(WearablePushMessage.parse(data), isNull);
    });

    test('ignores a pilot push with no title or body to draw', () {
      final data = checkInRequestData()..remove('body');
      expect(WearablePushMessage.parse(data), isNull);
    });

    test('tolerates a malformed payload', () {
      final data = checkInRequestData()..['payload'] = '{not json';
      final m = WearablePushMessage.parse(data);
      expect(m, isNotNull);
      expect(m!.requestId, isNull);
    });

    test('round-trips through toData', () {
      final m = WearablePushMessage.parse(checkInRequestData())!;
      final again = WearablePushMessage.parse(m.toData())!;
      expect(again.requestId, m.requestId);
      expect(again.circleName, m.circleName);
      expect(again.notificationId, m.notificationId);
    });
  });

  group('buttons and ids', () {
    test('the check-in button names the circle, never a bare "Check in"', () {
      final m = WearablePushMessage.parse(checkInRequestData())!;
      expect(m.checkInActionLabel, 'Check in to Home');
    });

    test('with no circle name the button still names a destination', () {
      final m = WearablePushMessage.parse(checkInRequestData(circleName: null))!;
      expect(m.checkInActionLabel, 'Check in to your circle');
    });

    test('one id per event so a redelivery replaces, not stacks', () {
      final a = WearablePushMessage.parse(checkInRequestData())!;
      final b = WearablePushMessage.parse(
        checkInRequestData()..['title'] = 'Check-in requested (again)',
      )!;
      expect(a.notificationId, b.notificationId);
      expect(a.followUpNotificationId, isNot(a.notificationId));
    });
  });

  group('client key', () {
    test('is the same for the same ask, from any surface', () {
      expect(checkInClientKeyFor('r1'), checkInClientKeyFor('r1'));
      expect(checkInClientKeyFor('r1'), isNot(checkInClientKeyFor('r2')));
      expect(checkInClientKeyFor('r1'), 'req:r1');
    });
  });

  group('follow-up wording', () {
    final at = DateTime(2026, 10, 11, 9, 41);

    test('success is worded only for a server-confirmed outcome', () {
      final confirmed = WearableFollowUp.forOutcome(
        WearableCheckInOutcome.confirmed,
        circleName: 'Home',
        at: at,
      );
      expect(confirmed.title, 'Checked in to Home');
      expect(confirmed.body, contains('9:41 am'));
      expect(confirmed.body, contains('no location'));

      for (final outcome in [
        WearableCheckInOutcome.failed,
        WearableCheckInOutcome.uncertain,
        WearableCheckInOutcome.signedOut,
      ]) {
        final f = WearableFollowUp.forOutcome(
          outcome,
          circleName: 'Home',
          at: at,
        );
        expect(f.title, isNot(startsWith('Checked in')));
        expect(f.title, contains('Home'));
      }
    });

    test('uncertain says it was sent but not confirmed', () {
      final f = WearableFollowUp.forOutcome(
        WearableCheckInOutcome.uncertain,
        circleName: 'Home',
        at: at,
      );
      expect(f.title, contains('Could not confirm'));
      expect(f.body, contains('did not answer'));
    });

    test('a failure carries the reason when one is known', () {
      final f = WearableFollowUp.forOutcome(
        WearableCheckInOutcome.failed,
        circleName: 'Home',
        at: at,
        reason: 'Your phone is offline.',
      );
      expect(f.body, startsWith('Your phone is offline.'));
    });
  });

  group('outcome for status', () {
    test('only 2xx confirms', () {
      expect(outcomeForStatus(201).outcome, WearableCheckInOutcome.confirmed);
      expect(outcomeForStatus(200).outcome, WearableCheckInOutcome.confirmed);
      expect(outcomeForStatus(400).outcome, WearableCheckInOutcome.failed);
      expect(outcomeForStatus(402).outcome, WearableCheckInOutcome.failed);
      expect(outcomeForStatus(402).reason, contains('ALRT +'));
      expect(outcomeForStatus(401).outcome, WearableCheckInOutcome.signedOut);
    });

    test('no answer, a 409 in flight and a 5xx are uncertain, never retried as success', () {
      expect(outcomeForStatus(null).outcome, WearableCheckInOutcome.uncertain);
      expect(outcomeForStatus(409).outcome, WearableCheckInOutcome.uncertain);
      expect(outcomeForStatus(503).outcome, WearableCheckInOutcome.uncertain);
    });
  });

  group('answered requests', () {
    test('remembers newest last and caps the list', () {
      var ids = <String>[];
      for (var i = 0; i < 60; i++) {
        ids = rememberAnsweredRequest(ids, 'r$i', keep: 50);
      }
      expect(ids.length, 50);
      expect(ids.first, 'r10');
      expect(ids.last, 'r59');
    });

    test('a repeat moves to the end without duplicating', () {
      final ids = rememberAnsweredRequest(['a', 'b'], 'a');
      expect(ids, ['b', 'a']);
    });
  });
}
