// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_leaderboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_XpLeaderboard _$XpLeaderboardFromJson(Map<String, dynamic> json) =>
    _XpLeaderboard(
      leaderboard:
          (json['leaderboard'] as List<dynamic>?)
              ?.map(
                (e) => XpLeaderboardEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <XpLeaderboardEntry>[],
      pagination: json['pagination'] == null
          ? null
          : XpLeaderboardPagination.fromJson(
              json['pagination'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$XpLeaderboardToJson(_XpLeaderboard instance) =>
    <String, dynamic>{
      'leaderboard': instance.leaderboard.map((e) => e.toJson()).toList(),
      'pagination': ?instance.pagination?.toJson(),
    };

_XpLeaderboardEntry _$XpLeaderboardEntryFromJson(Map<String, dynamic> json) =>
    _XpLeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Anonymous',
      email: json['email'] as String?,
      xpPoints: (json['xpPoints'] as num?)?.toInt() ?? 0,
      reliabilityScore: (json['reliabilityScore'] as num?)?.toDouble() ?? 0.0,
      hazardsReported: (json['hazardsReported'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$XpLeaderboardEntryToJson(_XpLeaderboardEntry instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'id': ?instance.id,
      'name': instance.name,
      'email': ?instance.email,
      'xpPoints': instance.xpPoints,
      'reliabilityScore': instance.reliabilityScore,
      'hazardsReported': instance.hazardsReported,
    };

_XpLeaderboardPagination _$XpLeaderboardPaginationFromJson(
  Map<String, dynamic> json,
) => _XpLeaderboardPagination(
  currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
  totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
  totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
  hasNext: json['hasNext'] as bool? ?? false,
  hasPrev: json['hasPrev'] as bool? ?? false,
);

Map<String, dynamic> _$XpLeaderboardPaginationToJson(
  _XpLeaderboardPagination instance,
) => <String, dynamic>{
  'currentPage': instance.currentPage,
  'totalPages': instance.totalPages,
  'totalUsers': instance.totalUsers,
  'hasNext': instance.hasNext,
  'hasPrev': instance.hasPrev,
};
