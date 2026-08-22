import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/models/blocked_user_model.dart';
import 'package:hazard_app/features/shared/providers/rest_client_provider.dart';

/// Flagging a report, and blocking an account.
///
/// The blocked set is kept here so every surface filters the same way: the
/// backend already drops blocked accounts out of the list feed, and this
/// covers the map and anything else rendered from cached state, so a
/// blocked person does not linger on one screen after vanishing from
/// another.
class BlockedUsersNotifier extends AsyncNotifier<List<BlockedUser>> {
  @override
  Future<List<BlockedUser>> build() async {
    final client = ref.read(providerOfRestClient);
    try {
      final response = await client.getBlockedUsers();
      return response.blocked;
    } catch (_) {
      // A failed fetch must not stop the app rendering. Nothing blocked is
      // the safe default: content stays visible rather than disappearing
      // for reasons the user cannot see.
      return const <BlockedUser>[];
    }
  }

  Future<void> block(final String userId) async {
    final client = ref.read(providerOfRestClient);
    await client.blockUser(body: {'userId': userId});
    ref.invalidateSelf();
    await future;
  }

  Future<void> unblock(final String userId) async {
    final client = ref.read(providerOfRestClient);
    await client.unblockUser(userId: userId);
    ref.invalidateSelf();
    await future;
  }
}

final providerOfBlockedUsers =
    AsyncNotifierProvider<BlockedUsersNotifier, List<BlockedUser>>(
      BlockedUsersNotifier.new,
    );

/// The blocked ids, for filtering. Empty while loading, so nothing is
/// hidden on the strength of an unfinished request.
final providerOfBlockedUserIds = Provider<Set<String>>((ref) {
  final blocked = ref.watch(providerOfBlockedUsers).asData?.value;
  return {for (final user in blocked ?? const <BlockedUser>[]) user.userId};
});

/// Raises a flag on a community report.
final providerOfFlagHazard = Provider<
    Future<void> Function(String hazardId, HazardFlagReason reason)>((ref) {
  return (hazardId, reason) async {
    final client = ref.read(providerOfRestClient);
    await client.flagHazard(
      hazardId: hazardId,
      body: {'reason': reason.id},
    );
  };
});
