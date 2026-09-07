import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/family_sos_authorization.dart';

// isSosMine/isSosResponseMine decide who gets the stand-down control (the
// sender) versus the acknowledge-only button (everyone else) on the SOS
// receiver screen, and which route the persistent SOS strip opens. These
// pin that boundary directly: a regression here means either the sender
// loses the ability to end their own SOS, or someone else's device shows
// them a stand-down button for an SOS that is not theirs.
FamilySosEvent sosEvent({
  final String memberId = 'member-1',
  final String? memberUserId,
}) => FamilySosEvent(
  id: 'sos-1',
  circleId: 'circle-1',
  memberId: memberId,
  member: memberUserId == null
      ? null
      : FamilyMemberSnippet(
          id: memberId,
          user: FamilyMemberUserSnippet(id: memberUserId),
        ),
);

FamilySosResponse sosResponse({
  final String memberId = 'member-1',
  final String? memberUserId,
}) => FamilySosResponse(
  id: 'response-1',
  sosEventId: 'sos-1',
  memberId: memberId,
  member: memberUserId == null
      ? null
      : FamilyMemberSnippet(
          id: memberId,
          user: FamilyMemberUserSnippet(id: memberUserId),
        ),
);

void main() {
  group('isSosMine', () {
    test('true when the SOS memberId matches the caller\'s memberId', () {
      final sos = sosEvent(memberId: 'me-in-this-circle');
      expect(
        isSosMine(sos, myMemberId: 'me-in-this-circle', myUserId: null),
        isTrue,
      );
    });

    test(
      'true when the SOS was sent from another circle where the sender '
      'has a different memberId, but the same userId as the caller',
      () {
        final sos = sosEvent(
          memberId: 'their-member-id-in-that-circle',
          memberUserId: 'shared-user-id',
        );
        expect(
          isSosMine(
            sos,
            myMemberId: 'my-member-id-in-my-selected-circle',
            myUserId: 'shared-user-id',
          ),
          isTrue,
        );
      },
    );

    test('false for a different member with no matching userId either', () {
      final sos = sosEvent(
        memberId: 'someone-else',
        memberUserId: 'someone-elses-user-id',
      );
      expect(
        isSosMine(sos, myMemberId: 'me', myUserId: 'my-user-id'),
        isFalse,
      );
    });

    test('false, not a crash, when the caller has no memberId or userId yet', () {
      final sos = sosEvent(memberId: 'someone-else');
      expect(isSosMine(sos, myMemberId: null, myUserId: null), isFalse);
    });
  });

  group('isSosResponseMine', () {
    test('true when the response memberId matches the caller', () {
      final response = sosResponse(memberId: 'me');
      expect(
        isSosResponseMine(response, myMemberId: 'me', myUserId: null),
        isTrue,
      );
    });

    test('stays true across circles by userId, same rule as isSosMine', () {
      final response = sosResponse(
        memberId: 'their-member-id-in-that-circle',
        memberUserId: 'shared-user-id',
      );
      expect(
        isSosResponseMine(
          response,
          myMemberId: 'my-member-id-elsewhere',
          myUserId: 'shared-user-id',
        ),
        isTrue,
      );
    });

    test('false for someone else\'s acknowledgment', () {
      final response = sosResponse(memberId: 'someone-else');
      expect(
        isSosResponseMine(response, myMemberId: 'me', myUserId: null),
        isFalse,
      );
    });
  });
}
