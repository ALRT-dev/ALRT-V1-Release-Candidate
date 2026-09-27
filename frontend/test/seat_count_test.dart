import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/subscription/utils/seat_count.dart';

// Regression test for the ALRT+ manage screen's seat count briefly
// counting the host as an occupied paid seat while the circles list is
// still loading. SEAT_FREE_ROLES = ["owner", "guest"] in
// family.service.ts — only adult/child members ever consume a seat.
FamilyCircle circleWithRoles(final List<FamilyRole> roles) => FamilyCircle(
  id: 'c1',
  name: 'The Nixons',
  myMemberId: 'owner',
  members: [
    for (var i = 0; i < roles.length; i++)
      FamilyMember(id: 'm$i', userId: 'u$i', role: roles[i]),
  ],
);

void main() {
  group('fallbackSeatsUsed', () {
    test('is 0 when the circle has not loaded yet', () {
      expect(fallbackSeatsUsed(null), 0);
    });

    test('is 0 for just the owner - never counts the host', () {
      expect(fallbackSeatsUsed(circleWithRoles([FamilyRole.owner])), 0);
    });

    test('excludes guests as well as the owner', () {
      expect(
        fallbackSeatsUsed(
          circleWithRoles([FamilyRole.owner, FamilyRole.guest]),
        ),
        0,
      );
    });

    test('counts adult and child members as occupied seats', () {
      expect(
        fallbackSeatsUsed(
          circleWithRoles([
            FamilyRole.owner,
            FamilyRole.adult,
            FamilyRole.child,
            FamilyRole.guest,
          ]),
        ),
        2,
      );
    });
  });
}
