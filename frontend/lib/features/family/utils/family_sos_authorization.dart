import 'package:hazard_app/features/family/models/family_models.dart';

/// Whether [sos] is the caller's own SOS: by member id in the SOS's own
/// circle, or — cross-circle, where member ids differ per circle — by the
/// underlying user id. This is the line between "your SOS, with a
/// stand-down control" and "someone else's, with an acknowledge button" on
/// every screen that shows a live SOS (the persistent strip, the Family hub
/// banner, the receiver screen), so it is worked out here once instead of
/// three separately-drifting copies.
bool isSosMine(
  final FamilySosEvent sos, {
  required final String? myMemberId,
  required final String? myUserId,
}) {
  return sos.memberId == myMemberId ||
      (sos.member?.user?.id != null && sos.member?.user?.id == myUserId);
}

/// Whether [response] (an SOS acknowledgment) was made by the caller, using
/// the same member-id-or-user-id rule as [isSosMine].
bool isSosResponseMine(
  final FamilySosResponse response, {
  required final String? myMemberId,
  required final String? myUserId,
}) {
  return response.memberId == myMemberId ||
      (response.member?.user?.id != null &&
          response.member?.user?.id == myUserId);
}
