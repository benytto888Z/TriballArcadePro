// lib/data/models/platform_leaderboard_model.dart

import 'game_state_model.dart';
import 'leaderboard_entry_model.dart';
import 'match_type_model.dart';

/// Payload complet reçu de l'ESP32 pour un leaderboard
class PlatformLeaderboardData {
  final GameMode mode;
  final List<LeaderboardEntryModel> entries;
  final int count;
  final DateTime receivedAt;

  PlatformLeaderboardData({
    required this.mode,
    required this.entries,
    required this.count,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory PlatformLeaderboardData.fromJson(Map<String, dynamic> json) {
    final modeKey = json['mode'] as String? ?? 'classic';
    final mode = GameModeExtension.fromKey(modeKey) ?? GameMode.classic;

    final entriesJson = (json['entries'] as List?) ?? [];
    final entries = entriesJson.map((e) {
      final entryJson = e as Map<String, dynamic>;

      // L'ESP32 renvoie un format compact : {rank, player, time_ms, balls, date}
      return LeaderboardEntryModel(
        playerName: entryJson['player'] as String? ?? '',
        completionTime: Duration(
          milliseconds: (entryJson['time_ms'] as num?)?.toInt() ?? 0,
        ),
        totalBalls: (entryJson['balls'] as num?)?.toInt() ?? 0,
        date: DateTime.tryParse(
          entryJson['date'] as String? ?? '',
        ) ??
            DateTime.now(),
        matchType: MatchType.soloChrono, // Toujours soloChrono côté ESP32
        gameMode: mode,
      );
    }).toList();

    return PlatformLeaderboardData(
      mode: mode,
      entries: entries,
      count: (json['count'] as num?)?.toInt() ?? entries.length,
    );
  }

  @override
  String toString() =>
      'PlatformLeaderboard(${mode.key}: $count entries)';
}