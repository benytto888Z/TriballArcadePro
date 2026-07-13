// lib/data/models/leaderboard_entry_model.dart

import 'game_state_model.dart';
import 'match_type_model.dart';

/// Entrée du classement (top 10)
/// Toujours associée à un MatchType (obligatoirement soloChrono actuellement)
/// et à un GameMode (classic/hardcore/champion/combo)
class LeaderboardEntryModel {
  final String playerName;
  final Duration completionTime;
  final int totalBalls;
  final DateTime date;
  final MatchType matchType;      // ✅ NEW
  final GameMode gameMode;         // ✅ Type modifié (GameMode enum au lieu de String)

  LeaderboardEntryModel({
    required this.playerName,
    required this.completionTime,
    required this.totalBalls,
    required this.date,
    required this.matchType,
    required this.gameMode,
  });

  // ============================================
  // FROM/TO JSON
  // ============================================
  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      playerName: json['playerName'] ?? json['player'] ?? '',
      completionTime: Duration(
        milliseconds: json['completionTimeMs'] ?? json['time_ms'] ?? 0,
      ),
      totalBalls: json['totalBalls'] ?? json['balls'] ?? 0,
      date: DateTime.parse(
        json['date'] ?? DateTime.now().toIso8601String(),
      ),
      matchType: MatchTypeX.fromKey(
          json['matchType'] ?? json['match_type'] ?? 'solo_chrono') ??
          MatchType.soloChrono,
      gameMode: GameModeExtension.fromKey(
          json['gameMode'] ?? json['mode'] ?? 'classic') ??
          GameMode.classic,
    );
  }

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'completionTimeMs': completionTime.inMilliseconds,
    'totalBalls': totalBalls,
    'date': date.toIso8601String(),
    'matchType': matchType.key,
    'gameMode': gameMode.key,
  };

  /// Format compact pour envoi WebSocket vers ESP32
  Map<String, dynamic> toEsp32Json() => {
    'player': playerName,
    'time_ms': completionTime.inMilliseconds,
    'balls': totalBalls,
    'date': date.toIso8601String(),
    'match_type': matchType.key,
    'mode': gameMode.key,
  };

  // ============================================
  // FORMATTERS
  // ============================================
  String get timeFormatted {
    final minutes =
    completionTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
    completionTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = (completionTime.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$millis';
  }

  String get dateFormatted {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  String toString() =>
      'Leaderboard($playerName: $timeFormatted | ${matchType.key}/${gameMode.key})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardEntryModel &&
        other.playerName == playerName &&
        other.completionTime == completionTime &&
        other.date == date &&
        other.matchType == matchType &&
        other.gameMode == gameMode;
  }

  @override
  int get hashCode =>
      playerName.hashCode ^
      completionTime.hashCode ^
      date.hashCode ^
      matchType.hashCode ^
      gameMode.hashCode;
}