import 'package:freezed_annotation/freezed_annotation.dart';

part 'xp_leaderboard_models.freezed.dart';
part 'xp_leaderboard_models.g.dart';

/// Payload from GET /api/xp/leaderboard.
@freezed
abstract class XpLeaderboard with _$XpLeaderboard {
  const factory XpLeaderboard({
    @Default(<XpLeaderboardEntry>[]) final List<XpLeaderboardEntry> leaderboard,
    final XpLeaderboardPagination? pagination,
  }) = _XpLeaderboard;

  factory XpLeaderboard.fromJson(Map<String, dynamic> json) =>
      _$XpLeaderboardFromJson(json);
}

/// A single ranked row in the leaderboard.
@freezed
abstract class XpLeaderboardEntry with _$XpLeaderboardEntry {
  const factory XpLeaderboardEntry({
    @Default(0) final int rank,
    final String? id,
    @Default('Anonymous') final String name,
    final String? email,
    @Default(0) final int xpPoints,
    @Default(0.0) final double reliabilityScore,
    @Default(0) final int hazardsReported,
  }) = _XpLeaderboardEntry;

  factory XpLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$XpLeaderboardEntryFromJson(json);
}

@freezed
abstract class XpLeaderboardPagination with _$XpLeaderboardPagination {
  const factory XpLeaderboardPagination({
    @Default(1) final int currentPage,
    @Default(1) final int totalPages,
    @Default(0) final int totalUsers,
    @Default(false) final bool hasNext,
    @Default(false) final bool hasPrev,
  }) = _XpLeaderboardPagination;

  factory XpLeaderboardPagination.fromJson(Map<String, dynamic> json) =>
      _$XpLeaderboardPaginationFromJson(json);
}
