import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/profile/models/xp_leaderboard_models.dart';
import 'package:hazard_app/features/shared/providers/rest_client_provider.dart';

/// Community XP leaderboard from GET /api/xp/leaderboard. Loads the first
/// page (top 20); pull-to-refresh re-fetches.
final providerOfXpLeaderboard = FutureProvider.autoDispose<XpLeaderboard>((
  ref,
) async {
  final restClient = ref.watch(providerOfRestClient);
  return restClient.getXpLeaderboard(page: 1, limit: 20);
});
