import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';

/// What a Restore really achieved. Each case has its own message: the app
/// never says "restored" unless ALRT has confirmed the access.
enum RestoreOutcomeKind {
  /// The store could not be reached; nothing was checked.
  storeUnavailable,

  /// The store answered: no active purchase on this store account.
  nothingFound,

  /// The store has a purchase but ALRT could not be reached to confirm.
  alrtUnreachable,

  /// The store has a purchase ALRT has not recorded yet.
  pending,

  /// ALRT confirms the access the store purchase gives.
  confirmed,
}

class RestoreOutcome {
  const RestoreOutcome(this.kind, this.message);

  final RestoreOutcomeKind kind;
  final String message;

  bool get isError =>
      kind == RestoreOutcomeKind.storeUnavailable ||
      kind == RestoreOutcomeKind.alrtUnreachable;
}

const kRestoreStoreUnavailable =
    'We couldn\'t reach your app store to restore purchases. Check your '
    'connection and try again.';
const kRestoreNothingFound =
    'This store account has no active ALRT + purchase to restore. If you '
    'bought with a different store account, sign in to that one and try '
    'again.';
const kRestoreAlrtUnreachable =
    'Your store found a purchase, but we couldn\'t reach ALRT to confirm '
    'it. Try again in a moment.';
const kRestorePending =
    'Your store found your purchase. We\'re still confirming it with ALRT, '
    'which can take a minute. Your access updates as soon as it\'s '
    'confirmed.';

/// Decides the outcome from what the store and ALRT actually said.
/// [reconcile] null means ALRT could not be reached.
RestoreOutcome restoreOutcome({
  required final bool storeFailed,
  required final List<String> activeStoreProducts,
  required final ReconcileResult? reconcile,
}) {
  if (storeFailed) {
    return const RestoreOutcome(
      RestoreOutcomeKind.storeUnavailable,
      kRestoreStoreUnavailable,
    );
  }
  if (activeStoreProducts.isEmpty) {
    return const RestoreOutcome(
      RestoreOutcomeKind.nothingFound,
      kRestoreNothingFound,
    );
  }
  if (reconcile == null) {
    return const RestoreOutcome(
      RestoreOutcomeKind.alrtUnreachable,
      kRestoreAlrtUnreachable,
    );
  }
  if (reconcile.unrecorded.isNotEmpty) {
    return const RestoreOutcome(RestoreOutcomeKind.pending, kRestorePending);
  }
  final summary = describeConfirmedAccess(reconcile.access);
  if (summary == null) {
    // The store has something, ALRT shows nothing paid, and the store's
    // record couldn't be compared: still arriving, never "restored".
    return const RestoreOutcome(RestoreOutcomeKind.pending, kRestorePending);
  }
  return RestoreOutcome(
    RestoreOutcomeKind.confirmed,
    'Purchases restored. $summary',
  );
}

/// "ALRT + is active for you. Your ALRT + Family plan covers Nixon
/// Family." Null when ALRT shows no paid access for this person.
String? describeConfirmedAccess(final AccessSummary access) {
  final parts = <String>[];
  if (access.personal.isIndividual && !access.personal.billingDisabled) {
    parts.add('ALRT + is active for you.');
  }
  for (final g in access.groups) {
    final s = g.sponsorship;
    if (s != null && s.youPay && s.live) {
      parts.add('Your ${planDisplayName(s.tier)} plan covers ${g.name}.');
    }
  }
  for (final u in access.unboundSponsorships) {
    parts.add(
      'Your ${planDisplayName(u.tier)} plan is waiting for a group. '
      'Choose it in My plans.',
    );
  }
  return parts.isEmpty ? null : parts.join(' ');
}

/// Restore, end to end: the store first, then ALRT, re-asking ALRT a few
/// times while a purchase is still arriving. Refreshes plan state after.
Future<RestoreOutcome> runRestore(
  final WidgetRef ref, {
  final int attempts = 3,
  final Duration wait = const Duration(seconds: 2),
}) async {
  List<String> products;
  try {
    products = await ref.read(providerOfRevenueCat).restoreActiveProducts();
  } catch (_) {
    return restoreOutcome(
      storeFailed: true,
      activeStoreProducts: const [],
      reconcile: null,
    );
  }
  RestoreOutcome outcome = restoreOutcome(
    storeFailed: false,
    activeStoreProducts: products,
    reconcile: null,
  );
  if (products.isNotEmpty) {
    final repo = ref.read(providerOfAccessRepository);
    for (var i = 0; i < attempts; i++) {
      final result = await repo.reconcile();
      outcome = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: products,
        reconcile: result.isSuccess ? result.success : null,
      );
      if (outcome.kind != RestoreOutcomeKind.pending) break;
      if (i < attempts - 1) await Future<void>.delayed(wait);
    }
  }
  ref.invalidate(providerOfAccess);
  ref.invalidate(providerOfAlrtPlus);
  return outcome;
}
