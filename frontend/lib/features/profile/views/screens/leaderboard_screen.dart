import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/models/xp_leaderboard_models.dart';
import 'package:hazard_app/features/profile/providers/xp_leaderboard_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Community XP leaderboard. Reads GET /api/xp/leaderboard (top 20) and lets
/// the user pull to refresh. Trust tier is a verification rate, never a raw
/// count — so we surface reports + reliability, not just points.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  static const route = '/leaderboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(providerOfXpLeaderboard);

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
              itemBuilder: (context, index) => _entryRowBuilder(entries[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _entryRowBuilder(XpLeaderboardEntry entry) {
    final medal = switch (entry.rank) {
      1 => const Color(0xFFE1A500), // gold
      2 => const Color(0xFF9AA0A6), // silver
      3 => const Color(0xFFB06A2C), // bronze
      _ => const Color(0xFF5f5c66),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: const Color(0xFFECECEF)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  '${entry.hazardsReported} reports',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    color: const Color(0xFF5f5c66),
                  ),
                ),
              ],
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
