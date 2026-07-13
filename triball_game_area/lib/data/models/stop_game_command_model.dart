// triball_game_area/lib/data/models/stop_game_command_model.dart

/// Commande d'arrêt de partie reçue depuis Config Area
class StopGameCommand {
  final int fromClientNum;
  final int timestamp;
  final DateTime receivedAt;

  StopGameCommand({
    this.fromClientNum = 0,
    this.timestamp = 0,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory StopGameCommand.fromJson(Map<String, dynamic> json) {
    return StopGameCommand(
      fromClientNum: (json['from'] as num?)?.toInt() ?? 0,
      timestamp: (json['ts'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() => 'StopGameCommand(from=$fromClientNum)';
}