import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/models/xp_leaderboard_models.dart';
import 'package:hazard_app/features/profile/providers/xp_leaderboard_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Community XP leaderboard. Ranks and points only — the leaderboard never
/// shows other users' identities (CLAUDE.md). The user's own row is
/// highlighted so they can see where they sit.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  static const route = '/leaderboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(providerOfXpLeaderboard);
    final myId = ref.watch(
      providerOfLoggedInUser.select((u) => u?.id),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Leaderboard',
          style: TextStyle(fontSize: 17.spMin, fontWeight: FontWeight.w700),
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
                style: TextStyle(fontSize: 15.spMin, color: const Color(0xFF5f5c66)),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(providerOfXpLeaderboard.future),
            child: ListView.separated(
              padding: EdgeInsets.all(16.spMin),
              itemCount: entries.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.spMin),
              itemBuilder: (context, index) =>
                  _entryRowBuilder(entries[index], myId),
            ),
          );
        },
      ),
    );
  }

  Widget _entryRowBuilder(XpLeaderboardEntry entry, String? myId) {
    final isMe = myId != null && entry.id == myId;
    final medal = switch (entry.rank) {
      1 => const Color(0xFFE1A500), // gold
      2 => const Color(0xFF9AA0A6), // silver
      3 => const Color(0xFFB06A2C), // bronze
      _ => const Color(0xFF5f5c66),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFFFF7ED) : Colors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(
          color: isMe ? const Color(0xFFE8622A).withValues(alpha: 0.4) : const Color(0xFFECECEF),
          width: isMe ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34.spMin,
            child: Text(
              '${entry.rank}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w800,
                color: medal,
              ),
            ),
          ),
          SizedBox(width: 8.spMin),
          Expanded(
            child: Text(
              isMe ? 'Your position' : 'Rank ${entry.rank}',
              style: TextStyle(
                fontSize: 15.spMin,
                fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                color: isMe ? const Color(0xFFE8622A) : const Color(0xFF5f5c66),
              ),
            ),
          ),
          Row(
            children: [
              Icon(LucideIcons.star, size: 15.spMin, color: const Color(0xFFE1A500)),
              SizedBox(width: 4.spMin),
              Text(
                '${entry.xpPoints}',
                style: TextStyle(
                  fontSize: 15.spMin,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
            style: TextStyle(fontSize: 15.spMin, color: const Color(0xFF5f5c66)),
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
}
