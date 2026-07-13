// triball_game_area/lib/data/models/remote_config_command_model.dart

import 'game_config_model.dart';
import 'game_state_model.dart';
import 'match_type_model.dart';

/// Commande de démarrage de partie reçue depuis Config Area
/// Contient la GameConfig complète + métadonnées
class RemoteConfigCommand {
  final GameConfig gameConfig;
  final String? language;
  final String? theme;
  final String? requestedBy;
  final int timestamp;
  final DateTime receivedAt;

  RemoteConfigCommand({
    required this.gameConfig,
    this.language,
    this.theme,
    this.requestedBy,
    this.timestamp = 0,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory RemoteConfigCommand.fromJson(Map<String, dynamic> json) {
    // Parse MatchType
    final matchTypeKey = json['matchType'] as String? ?? 'competition';
    final matchType = MatchTypeX.fromKey(matchTypeKey) ?? MatchType.competition;

    // Parse GameMode
    final modeKey = json['gameMode'] as String? ?? 'classic';
    final gameMode = GameModeExtension.fromKey(modeKey) ?? GameMode.classic;

    // Parse players
    final playersJson = json['players'] as List? ?? [];
    final players = playersJson.map((e) => e.toString()).toList();

    // Parse options
    final options = json['options'] as Map<String, dynamic>? ?? {};
    final ttsEnabled = options['ttsEnabled'] as bool? ?? true;
    final soundEnabled = options['soundEnabled'] as bool? ?? true;

    // Parse overshoot rule
    OvershootRule overshootRule = OvershootRule.refuse;
    final overshootKey = json['overshootRule'] as String? ?? 'refuse';
    switch (overshootKey) {
      case 'bounce':
        overshootRule = OvershootRule.bounce;
        break;
      case 'hardcoreOvershoot':
        overshootRule = OvershootRule.hardcoreOvershoot;
        break;
      default:
        overshootRule = OvershootRule.refuse;
    }

    // Construction de la GameConfig selon MatchType
    late GameConfig gameConfig;
    switch (matchType) {
      case MatchType.competition:
        gameConfig = GameConfig.competition(
          mode: gameMode,
          players: players,
          ballsPerTurn: (json['ballsPerTurn'] as num?)?.toInt() ?? 3,
          turnDurationSeconds:
          (json['turnDurationSeconds'] as num?)?.toInt(),
          turnWarningSeconds:
          (json['turnWarningSeconds'] as num?)?.toInt(),
          overshootRule: overshootRule,
          ttsEnabled: ttsEnabled,
          soundEnabled: soundEnabled,
        );
        break;
      case MatchType.soloChrono:
        gameConfig = GameConfig.soloChrono(
          mode: gameMode,
          playerName: players.isNotEmpty ? players.first : 'Player',
          ballsPerTurn: (json['ballsPerTurn'] as num?)?.toInt() ?? 3,
          turnDurationSeconds:
          (json['turnDurationSeconds'] as num?)?.toInt(),
          turnWarningSeconds:
          (json['turnWarningSeconds'] as num?)?.toInt(),
          overshootRule: overshootRule,
          ttsEnabled: ttsEnabled,
          soundEnabled: soundEnabled,
        );
        break;
      case MatchType.tournament:
        gameConfig = GameConfig.tournament(
          mode: gameMode,
          players: players,
          ballsPerTurn: (json['ballsPerTurn'] as num?)?.toInt() ?? 3,
          turnDurationSeconds:
          (json['turnDurationSeconds'] as num?)?.toInt(),
          turnWarningSeconds:
          (json['turnWarningSeconds'] as num?)?.toInt(),
          overshootRule: overshootRule,
          ttsEnabled: ttsEnabled,
          soundEnabled: soundEnabled,
        );
        break;
    }

    return RemoteConfigCommand(
      gameConfig: gameConfig,
      language: json['language'] as String?,
      theme: json['theme'] as String?,
      requestedBy: json['requestedBy'] as String?,
      timestamp: (json['ts'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() =>
      'RemoteConfigCommand(${gameConfig.matchType.key}/${gameConfig.mode.key}, '
          'players=${gameConfig.playerCount})';
}