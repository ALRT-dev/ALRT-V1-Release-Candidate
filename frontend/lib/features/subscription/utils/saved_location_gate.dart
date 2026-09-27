import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';

/// What a "Save this location" tap should do, decided from facts only, so
/// the rule can be tested without a provider (phone QA 2026-09-09: "the
/// saved-location paywall does not work").
enum SavedLocationGate {
  /// Under the free allowance, or on ALRT+: save it.
  save,

  /// At the free allowance without ALRT+: explain, then offer the paywall.
  needsPlus,
}

/// [savedCount] counts saved locations only; the automatic own-location
/// follow never counts. [isPlus] is the live entitlement (or the QA
/// unlock). The free allowance is [kFreeSavedLocationsLimit].
SavedLocationGate savedLocationGate({
  required final int savedCount,
  required final bool isPlus,
  final int freeLimit = kFreeSavedLocationsLimit,
}) {
  if (isPlus) return SavedLocationGate.save;
  return savedCount >= freeLimit
      ? SavedLocationGate.needsPlus
      : SavedLocationGate.save;
}

/// What the tap ended in, for the screen to report. Nothing here is silent:
/// every branch has a visible result on the phone.
sealed class SaveLocationOutcome {
  const SaveLocationOutcome();
}

/// The location is now saved (alerts for it will reach the account).
class SaveLocationSaved extends SaveLocationOutcome {
  const SaveLocationSaved(this.name);
  final String? name;
}

/// The saved location was removed.
class SaveLocationRemoved extends SaveLocationOutcome {
  const SaveLocationRemoved();
}

/// The free allowance is used up and the account has no ALRT+. The screen
/// shows the explanation sheet and the paywall, then tries again.
class SaveLocationNeedsPlus extends SaveLocationOutcome {
  const SaveLocationNeedsPlus({required this.fromServer});

  /// True when the SERVER refused (billing enforcement on), false when the
  /// app's own count decided.
  final bool fromServer;
}

/// Something needed for the decision could not be read (the saved list,
/// the entitlement). Nothing was saved.
class SaveLocationCouldNotCheck extends SaveLocationOutcome {
  const SaveLocationCouldNotCheck(this.message);
  final String message;
}

/// The server refused or the request failed. Nothing was saved.
class SaveLocationFailed extends SaveLocationOutcome {
  const SaveLocationFailed(this.message);
  final String message;
}
