import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/models/xp_leaderboard_models.dart';
import 'package:hazard_app/features/profile/providers/xp_leaderboard_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Community XP leaderboard. Ranks and points only: the leaderboard never
/// shows other users' identities (CLAUDE.md). No medals, names,
/// reliability or report counts. The user's own position is a card at the
/// top that only they can see.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  static const route = '/leaderboard';

  static const _page = Color(0xFFF5F5F7);
  static const _muted = Color(0xFF5C5C66);
  static const _hairline = Color(0xFFE3E6EA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(providerOfXpLeaderboard);
    final myId = ref.watch(
      providerOfLoggedInUser.select((u) => u?.id),
    );

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 72.spMin,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.black),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 22.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 2.spMin),
            Text(
              'Completely de-identified. Ranks and points only.',
              style: TextStyle(fontSize: 13.spMin, color: _muted),
            ),
          ],
        ),
      ),
      body: leaderboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _errorBuilder(ref),
        data: (data) {
          final entries = data.leaderboard;
          if (entries.isEmpty) {
            return Center(
              child: Text(
                'No rankings yet.',
                style: TextStyle(fontSize: 15.spMin, color: _muted),
              ),
            );
          }
          final mine = myId == null
              ? null
              : entries.where((e) => e.id == myId).firstOrNull;
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(providerOfXpLeaderboard.future),
            child: ListView(
              padding: EdgeInsets.all(16.spMin),
              children: [
                _yourPositionCard(mine),
                SizedBox(height: 16.spMin),
                _rowsCard(entries, myId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _yourPositionCard(final XpLeaderboardEntry? mine) {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mine == null
                ? 'Your position: not in the top ranks yet'
                : 'Your position: #${mine.rank}',
            style: TextStyle(
              fontSize: 18.spMin,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            'Only you can see this line.',
            style: TextStyle(fontSize: 13.spMin, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _rowsCard(final List<XpLeaderboardEntry> entries, final String? myId) {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: _hairline,
                indent: 16.spMin,
                endIndent: 16.spMin,
              ),
            _entryRow(entries[i], isMe: myId != null && entries[i].id == myId),
          ],
        ],
      ),
    );
  }

  Widget _entryRow(final XpLeaderboardEntry entry, {required final bool isMe}) {
    return Container(
      color: isMe ? const Color(0xFFFFF3EC) : AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w700,
                color: isMe ? AppColors.orange : AppColors.black,
              ),
            ),
          ),
          Text(
            '${entry.xpPoints} pts',
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w700,
              color: isMe ? AppColors.orange : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBuilder(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Could not load the leaderboard.',
            style: TextStyle(fontSize: 15.spMin, color: _muted),
          ),
          SizedBox(height: 12.spMin),
          TextButton(
            onPressed: () => ref.refresh(providerOfXpLeaderboard),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 3.0,
            offset: Offset(0, 1),
          ),
        ],
      );
}
