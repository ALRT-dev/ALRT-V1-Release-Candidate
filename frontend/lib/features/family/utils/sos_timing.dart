import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:intl/intl.dart';

/// Locked spec (3 Oct 2026): an SOS lasts 1 hour. The sender can extend it
/// by another hour from now, or end it. Mirrors SOS_MAX_DURATION_MS and
/// sosExpiresAt in the backend's family.service.ts.
const kSosDuration = Duration(hours: 1);

/// The one sentence that explains SOS timing everywhere it is explained.
const kSosDurationLine = 'SOS lasts 1 hour. You can extend it or end it.';

/// When [sos] stands itself down: its `liveUntil` (set by each "Extend 1
/// hour"), else 1 hour from the start. Null when neither is known.
DateTime? sosLiveUntil(final FamilySosEvent sos) {
  final until = sos.liveUntil;
  if (until != null) return until.toLocal();
  final created = sos.createdAt;
  return created?.add(kSosDuration).toLocal();
}

/// "3:45 pm", in the phone's local time.
String sosClock(final DateTime at) =>
    DateFormat('h:mm a').format(at.toLocal()).toLowerCase();

/// "Live until 3:45 pm", for the sender's running SOS. Null when unknown.
String? sosLiveUntilLine(final FamilySosEvent sos) {
  final until = sosLiveUntil(sos);
  return until == null ? null : 'Live until ${sosClock(until)}';
}

/// True when [sos] ended on its own at the end of its hour, rather than
/// by the sender's "End SOS". The backend stores who ended it by hand
/// (endedByMemberId); an expiry leaves it empty and resolves at or after
/// the event's end time. A small tolerance absorbs clock skew between the
/// scheduler and the stored end time.
bool sosExpired(final FamilySosEvent sos) {
  if (sos.status == FamilySosStatus.active) return false;
  if (sos.endedByMemberId != null) return false;
  final resolved = sos.resolvedAt;
  final until = sosLiveUntil(sos);
  if (resolved == null || until == null) return false;
  return !resolved.isBefore(until.subtract(const Duration(minutes: 1)));
}

/// When an expired SOS stopped: the stored end time when it was extended,
/// else when the server stood it down.
DateTime? sosExpiredAt(final FamilySosEvent sos) =>
    sos.liveUntil?.toLocal() ?? sos.resolvedAt?.toLocal();

/// "This SOS expired at 3:45 pm." (locked wording), or null when [sos] did
/// not expire.
String? sosExpiredLine(final FamilySosEvent sos) {
  if (!sosExpired(sos)) return null;
  final at = sosExpiredAt(sos);
  return at == null ? null : 'This SOS expired at ${sosClock(at)}.';
}

/// What to say when "Extend 1 hour" is refused. The backend answers 409
/// when the SOS has already ended (or its hour ran out) and 404 when it
/// isn't the caller's own; anything else is treated as not reaching ALRT.
String extendSosErrorMessage(final AppError error) => switch (error.code) {
  '409' || '404' => 'This SOS has already ended, so it can\'t be extended.',
  _ => 'We couldn\'t extend your SOS. Check your connection and try again.',
};
