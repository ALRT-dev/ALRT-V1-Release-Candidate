import 'package:hazard_app/features/family/models/family_models.dart';

/// The manage screen's seat count before the circles list has loaded, so
/// the owner is never briefly shown occupying one of their own paid seats.
/// Mirrors SEAT_FREE_ROLES = ["owner", "guest"] in family.service.ts —
/// only `adult`/`child` members consume a seat.
int fallbackSeatsUsed(final FamilyCircle? circle) {
  if (circle == null) return 0;
  return circle.members
      .where((m) => m.role != FamilyRole.guest && m.role != FamilyRole.owner)
      .length;
}
