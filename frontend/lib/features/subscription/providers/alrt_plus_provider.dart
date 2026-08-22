import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:flutter/services.dart';

final providerOfRevenueCat = Provider<RevenueCatService>(
  (ref) => RevenueCatService(),
);

/// The free tier saves at most this many locations, no matter what
/// (locked ALRT+ limits; moves to Remote Config in a later pass).
const kFreeSavedLocationsLimit = 1;

/// Whether the QA unlock is live: the env flag AND the dev flavour.
///
/// The env var alone used to decide, so a stray ALRT_PLUS_TEST_UNLOCK=true
/// in a store build would have bypassed every paywall gate, rendered fake
/// prices, and shown a "QA build only" row in Settings — an instant Apple
/// 3.1.2 rejection. appFlavor is the honest signal: the sideloaded dev
/// APK is built --release too, so kReleaseMode cannot tell them apart.
bool get isAlrtPlusTestUnlocked =>
    appFlavor == 'dev' && dotenv.env['ALRT_PLUS_TEST_UNLOCK'] == 'true';

/// True when the signed-in user has an active ALRT+ entitlement. Ensures
/// RevenueCat is configured for the current user before reading status.
/// `ref.refresh(providerOfAlrtPlus)` re-checks after a purchase.
final providerOfAlrtPlus = FutureProvider.autoDispose<bool>((ref) async {
  final userId = ref.watch(providerOfLoggedInUser)?.id;
  if (userId == null) return false;
  // Test-build escape hatch: sideloaded QA builds can't complete store
  // purchases, so CI sets ALRT_PLUS_TEST_UNLOCK=true in .env to open the
  // ALRT+ gates. Never set in store builds.
  if (isAlrtPlusTestUnlocked) return true;
  final rc = ref.watch(providerOfRevenueCat);
  await rc.ensureConfigured(userId);
  return rc.isPlus();
});

/// True when the active ALRT+ entitlement has a detected billing issue
/// (payment failed, store is retrying). Drives the calm amber banner on the
/// family screen.
final providerOfAlrtPlusBillingIssue = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final userId = ref.watch(providerOfLoggedInUser)?.id;
  if (userId == null) return false;
  final rc = ref.watch(providerOfRevenueCat);
  await rc.ensureConfigured(userId);
  final entitlement = await rc.plusEntitlement();
  return entitlement?.billingIssueDetectedAt != null;
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
