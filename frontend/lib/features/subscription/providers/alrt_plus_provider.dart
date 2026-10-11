import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final providerOfRevenueCat = Provider<RevenueCatService>(
  (ref) => RevenueCatService(),
);

/// ALRT Free saves this many places besides where you are (V1 access
/// model). The backend's GET /api/access carries the live number.
const kFreeSavedLocationsLimit = 1;

/// Whether the QA unlock is live: the env flag AND the dev flavour.
///
/// The env var alone used to decide, so a stray ALRT_PLUS_TEST_UNLOCK=true
/// in a store build would have bypassed every paywall gate, rendered fake
/// prices, and shown a "QA build only" row in Settings — an instant Apple
/// 3.1.2 rejection. appFlavor is the honest signal: the sideloaded dev
/// APK is built --release too, so kReleaseMode cannot tell them apart.
bool get isAlrtPlusTestUnlocked =>
    appFlavor == 'dev' &&
    const String.fromEnvironment('ALRT_PLUS_TEST_UNLOCK') == 'true';

/// The access the backend computed for the signed-in person: personal
/// plan and each group's coverage, separately (GET /api/access). Null
/// when signed out or when the backend can't be reached, so callers can
/// say "couldn't check" instead of guessing.
/// `ref.invalidate(providerOfAccess)` re-reads after a purchase.
final providerOfAccess = FutureProvider.autoDispose<AccessSummary?>((
  ref,
) async {
  final userId = ref.watch(providerOfLoggedInUser)?.id;
  if (userId == null) return null;
  final result = await ref.read(providerOfAccessRepository).getAccess();
  return result.isSuccess ? result.success : null;
});

/// True when the signed-in person has ALRT + Individual (or its trial):
/// the PERSONAL plan only. A Family/Group plan never makes this true,
/// for members or the payer (V1 access model). Read from the backend;
/// when it can't be reached, the store's own `individual` entitlement is
/// used as a display hint (the server still enforces every limit).
final providerOfAlrtPlus = FutureProvider.autoDispose<bool>((ref) async {
  final userId = ref.watch(providerOfLoggedInUser)?.id;
  if (userId == null) return false;
  // Test-build escape hatch: sideloaded QA builds can't complete store
  // purchases, so CI sets ALRT_PLUS_TEST_UNLOCK=true in .env to open the
  // ALRT + gates. Never set in store builds.
  if (isAlrtPlusTestUnlocked) return true;
  final access = await ref.watch(providerOfAccess.future);
  if (access != null) return access.personal.isIndividual;
  final rc = ref.watch(providerOfRevenueCat);
  await rc.ensureConfigured(userId);
  return rc.isPlus(forUserId: userId);
});

/// True when the active ALRT+ entitlement has a detected billing issue
/// (payment failed, store is retrying). Drives the calm amber banner on the
/// family screen.
final providerOfAlrtPlusBillingIssue = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final userId = ref.watch(providerOfLoggedInUser)?.id;
  if (userId == null) return false;
  // Test-build escape hatch, matching providerOfAlrtPlus above: never
  // contact RevenueCat under test-unlock. A QA build has no real
  // entitlement to check for a billing issue.
  if (isAlrtPlusTestUnlocked) return false;
  final rc = ref.watch(providerOfRevenueCat);
  await rc.ensureConfigured(userId);
  final entitlement = await rc.plusEntitlement();
  return entitlement?.billingIssueDetectedAt != null;
});

/// The lapsed ALRT+ entitlement, if this customer was subscribed before but
/// it has since expired or been cancelled-and-ended — null both when never
/// subscribed and while ALRT+ is currently active. Lets the profile screen
/// route a "was on ALRT+, now on the free plan" user to an explanation
/// screen instead of the plain paywall, with no backend change.
final providerOfExpiredAlrtPlus = FutureProvider.autoDispose<EntitlementInfo?>((
  ref,
) async {
  final userId = ref.watch(providerOfLoggedInUser)?.id;
  if (userId == null) return null;
  // Test-build escape hatch, matching providerOfAlrtPlus above: a QA build
  // has no real store subscription to have ever lapsed.
  if (isAlrtPlusTestUnlocked) return null;
  final rc = ref.watch(providerOfRevenueCat);
  await rc.ensureConfigured(userId);
  return rc.expiredEntitlement();
});

/// One-shot intent: set by the welcome screen's "Invite your family" CTA,
/// consumed by the family onboarding after the circle is created.
/// (Notifier-based: StateProvider was removed in Riverpod 3.)
class PendingFamilyInviteNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  // ignore: use_setters_to_change_properties
  void set(final bool value) => state = value;
}

final providerOfPendingFamilyInvite =
    NotifierProvider<PendingFamilyInviteNotifier, bool>(
      PendingFamilyInviteNotifier.new,
    );
