import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';
import 'package:collection/collection.dart';
import 'package:hazard_app/features/family/utils/sos_preview.dart' show joinNames;
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';

/// What a Restore really achieved, for the SPECIFIC purchases the store
/// found (review follow-up, 29 Sep 2026). Existing, unrelated paid access
/// never turns into "Purchases restored": only purchases ALRT has matched
/// to its own verified records count as confirmed.
enum RestoreOutcomeKind {
  /// The store could not be reached; nothing was checked.
  storeUnavailable,

  /// The store answered: no active ALRT purchase on this store account.
  nothingFound,

  /// The store has purchases but ALRT could not be reached to check them.
  alrtUnreachable,

  /// Every purchase found is confirmed by ALRT.
  confirmed,

  /// Some are confirmed, some are not (yet).
  partial,

  /// None confirmed yet; the store's server record has them (arriving).
  pending,

  /// None confirmed, and ALRT could not read the store's server record,
  /// so nothing was compared (missing server key or store API down).
  unchecked,

  /// The store's server record for this ALRT account doesn't have them:
  /// probably bought while signed in to another ALRT account.
  notLinked,
}

class RestoreOutcome {
  const RestoreOutcome(this.kind, this.message);

  final RestoreOutcomeKind kind;
  final String message;

  bool get isError =>
      kind == RestoreOutcomeKind.storeUnavailable ||
      kind == RestoreOutcomeKind.alrtUnreachable;

  /// Worth asking ALRT again in a moment.
  bool get mayChange =>
      kind == RestoreOutcomeKind.pending || kind == RestoreOutcomeKind.partial;
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
const kRestoreUnchecked =
    'Your store found a purchase, but ALRT couldn\'t check it with the '
    'store yet, so it isn\'t confirmed. Try again in a few minutes.';
const kRestoreNotLinked =
    'Your store has a purchase that isn\'t linked to this ALRT account. If '
    'you bought it while signed in to a different ALRT account, sign in to '
    'that one.';

/// "ALRT +", "ALRT + Family for Nixon Family", "ALRT + Group 20 (choose
/// its group in My plans)".
String _describe(final ReconcileProduct p, final AccessSummary access) {
  final tier = p.tier!;
  if (tier == PlanTier.individual) return 'ALRT +';
  if (p.bound == false) {
    return '${planDisplayName(tier)} (choose its group in My plans)';
  }
  final group = access.groups
      .where((g) => g.sponsorship?.youPay == true && g.sponsorship?.tier == tier)
      .firstOrNull;
  return group == null
      ? planDisplayName(tier)
      : '${planDisplayName(tier)} for ${group.name}';
}

String _list(final Iterable<String> items) => joinNames(items.toList());

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
  final ours = reconcile.products
      .where((p) => p.status != ReconcileProductStatus.unknown && p.tier != null)
      .toList();
  if (reconcile.products.isNotEmpty && ours.isEmpty) {
    return const RestoreOutcome(
      RestoreOutcomeKind.nothingFound,
      kRestoreNothingFound,
    );
  }
  if (ours.isEmpty) {
    // An older backend that can't compare products: never "restored".
    return const RestoreOutcome(RestoreOutcomeKind.unchecked, kRestoreUnchecked);
  }
  List<ReconcileProduct> by(final ReconcileProductStatus s) =>
      ours.where((p) => p.status == s).toList();
  final confirmed = by(ReconcileProductStatus.confirmed);
  final pending = by(ReconcileProductStatus.pending);
  final unchecked = by(ReconcileProductStatus.unchecked);
  final notFound = by(ReconcileProductStatus.notFound);
  String names(final List<ReconcileProduct> ps) =>
      _list(ps.map((p) => planDisplayName(p.tier!)));

  if (confirmed.length == ours.length) {
    return RestoreOutcome(
      RestoreOutcomeKind.confirmed,
      'Purchases restored: '
      '${_list(confirmed.map((p) => _describe(p, reconcile.access)))}.',
    );
  }
  if (confirmed.isNotEmpty) {
    final parts = <String>[
      'Restored: ${_list(confirmed.map((p) => _describe(p, reconcile.access)))}.',
      if (pending.isNotEmpty) 'Still confirming: ${names(pending)}.',
      if (unchecked.isNotEmpty) 'Not confirmed yet: ${names(unchecked)}.',
      if (notFound.isNotEmpty)
        'Not linked to this ALRT account: ${names(notFound)}.',
    ];
    return RestoreOutcome(RestoreOutcomeKind.partial, parts.join(' '));
  }
  if (pending.isNotEmpty) {
    return const RestoreOutcome(RestoreOutcomeKind.pending, kRestorePending);
  }
  if (unchecked.isNotEmpty) {
    return const RestoreOutcome(RestoreOutcomeKind.unchecked, kRestoreUnchecked);
  }
  return const RestoreOutcome(RestoreOutcomeKind.notLinked, kRestoreNotLinked);
}

/// Restore, end to end: the store first, then ALRT, re-asking ALRT a few
/// times while a purchase is still arriving. Refreshes plan state after.
Future<RestoreOutcome> runRestore(
  final WidgetRef ref, {
  final int attempts = 3,
  final Duration wait = const Duration(seconds: 2),
}) async {
  List<String> products;
  // Restore needs the SDK signed in as this ALRT user first; without it
  // the store read below refuses and the person is told it failed.
  await ref
      .read(providerOfRevenueCat)
      .ensureConfiguredFor(ref.read(providerOfLoggedInUser)?.id);
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
      final result = await repo.reconcile(productIds: products);
      outcome = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: products,
        reconcile: result.isSuccess ? result.success : null,
      );
      if (!outcome.mayChange) break;
      if (i < attempts - 1) await Future<void>.delayed(wait);
    }
  }
  ref.invalidate(providerOfAccess);
  ref.invalidate(providerOfAlrtPlus);
  return outcome;
}
