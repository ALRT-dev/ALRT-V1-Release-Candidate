import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/profile/models/xp_breakdown_models.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/rest_client_provider.dart';

/// Per-report XP breakdown and ranking from GET /api/xp/breakdown.
final providerOfXpBreakdown = FutureProvider.autoDispose<XpBreakdown>((
  ref,
) async {
  final restClient = ref.watch(providerOfRestClient);
  final breakdown = await restClient.getXpBreakdown();

  // Same rule as the summary: fresh figures catch the cached total up, so
  // the bar on the profile matches the number at the top of this screen.
  ref.read(providerOfLoggedInUser.notifier).update(
        (user) => user?.copyWith(xpPoints: breakdown.currentXpPoints),
      );

  return breakdown;
});
