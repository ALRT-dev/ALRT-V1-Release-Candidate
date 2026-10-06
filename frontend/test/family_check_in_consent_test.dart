import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_consent_sheet.dart';

// Locks in the model half of the check-in consent rule: the only thing a
// UI may use to decide it is answering someone's request (and therefore
// must name the requester on the consent sheet) is
// FamilyCircle.checkInRequestOwedByMe. Whatever that returns, the sheet is
// shown for every interactive check-in and the choice it hands back is the
// ONLY thing that may turn location sharing on.
void main() {
  final askedAt = DateTime(2026, 9, 3, 9, 0);

  FamilyCircle circle({
    required String myMemberId,
    DateTime? myLastCheckInAt,
    FamilyCheckInRequest? request,
  }) {
    return FamilyCircle(
      id: 'circle-1',
      name: 'Nixon Family',
      myMemberId: myMemberId,
      members: [
        FamilyMember(
          id: 'me',
          userId: 'user-me',
          name: 'Me',
          lastCheckInAt: myLastCheckInAt,
        ),
        const FamilyMember(id: 'sarah', userId: 'user-sarah', name: 'Sarah'),
      ],
      latestCheckInRequest: request,
    );
  }

  final sarahAsked = FamilyCheckInRequest(
    id: 'req-1',
    circleId: 'circle-1',
    requestedById: 'sarah',
    createdAt: askedAt,
  );

  group('FamilyCircle.checkInRequestOwedByMe', () {
    test('is null when nobody has asked', () {
      expect(circle(myMemberId: 'me').checkInRequestOwedByMe, isNull);
    });

    test('is the request when someone else asked and I have not answered',
        () {
      final c = circle(myMemberId: 'me', request: sarahAsked);
      expect(c.checkInRequestOwedByMe, sarahAsked);
    });

    test('is null when I am the one who asked', () {
      final c = circle(myMemberId: 'sarah', request: sarahAsked);
      expect(c.checkInRequestOwedByMe, isNull);
    });

    test('is null once I have checked in after the ask', () {
      final c = circle(
        myMemberId: 'me',
        request: sarahAsked,
        myLastCheckInAt: askedAt.add(const Duration(minutes: 5)),
      );
      expect(c.checkInRequestOwedByMe, isNull);
    });

    test('is still owed when my last check-in predates the ask', () {
      final c = circle(
        myMemberId: 'me',
        request: sarahAsked,
        myLastCheckInAt: askedAt.subtract(const Duration(hours: 3)),
      );
      expect(c.checkInRequestOwedByMe, sarahAsked);
    });
  });

  group('CheckInConsentChoice', () {
    test('only the explicit share choice maps to shareLocation: true', () {
      bool shareFor(CheckInConsentChoice choice) =>
          choice == CheckInConsentChoice.checkInAndShareLocation;
      expect(shareFor(CheckInConsentChoice.checkInOnly), isFalse);
      expect(shareFor(CheckInConsentChoice.checkInAndShareLocation), isTrue);
    });
  });
}
