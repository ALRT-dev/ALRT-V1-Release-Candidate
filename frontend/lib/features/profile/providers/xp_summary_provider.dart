import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/profile/models/xp_summary_models.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/rest_client_provider.dart';

/// Scoring v2 summary for the profile (XP, streak, trust tier, quest).
/// Auto-refreshes whenever it is re-watched after disposal; call
/// `ref.refresh(providerOfXpSummary)` to force-reload after XP changes.
final providerOfXpSummary = FutureProvider.autoDispose<XpSummary>((ref) async {
  final restClient = ref.watch(providerOfRestClient);
  final summary = await restClient.getXpSummary();

  // One number everywhere: the cached login copy of the total is caught up
  // whenever fresh ledger figures arrive, so the profile bar can never
  // disagree with the "Your points" screen (QA 2026-08-07).
  ref.read(providerOfLoggedInUser.notifier).update(
        (user) => user?.copyWith(xpPoints: summary.xpPoints),
      );

  return summary;
});
