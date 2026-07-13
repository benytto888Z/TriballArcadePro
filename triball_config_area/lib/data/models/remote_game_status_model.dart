// triball_config_area/lib/data/models/remote_game_status_model.dart

/// Statut du jeu envoyé par Game Area et reçu par Config Area
/// via l'ESP32 comme relais
class RemoteGameStatus {
  final String state;                       // waiting | countdown | playing | victory | game_over
  final String? currentPlayerName;
  final Map<String, int> scores;            // {"Léo": 45, "Mia": 30}
  final int elapsedSeconds;
  final String? winnerName;
  final int? currentTurn;                    // 1, 2, 3...
  final DateTime receivedAt;

  RemoteGameStatus({
    required this.state,
    this.currentPlayerName,
    this.scores = const {},
    this.elapsedSeconds = 0,
    this.winnerName,
    this.currentTurn,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory RemoteGameStatus.fromJson(Map<String, dynamic> json) {
    final scoresRaw = json['scores'] as Map<String, dynamic>? ?? {};
    final scores = <String, int>{};
    scoresRaw.forEach((key, value) {
      scores[key] = (value is num) ? value.toInt() : 0;
    });

    return RemoteGameStatus(
      state: json['state'] as String? ?? 'unknown',
      currentPlayerName: json['currentPlayer'] as String?,
      scores: scores,
      elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt() ?? 0,
      winnerName: json['winner'] as String?,
      currentTurn: (json['currentTurn'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'state': state,
    if (currentPlayerName != null) 'currentPlayer': currentPlayerName,
    'scores': scores,
    'elapsedSeconds': elapsedSeconds,
    if (winnerName != null) 'winner': winnerName,
    if (currentTurn != null) 'currentTurn': currentTurn,
  };

  bool get isPlaying => state == 'playing';
  bool get isVictory => state == 'victory';
  bool get isWaiting => state == 'waiting';
  bool get isCountdown => state == 'countdown';
  bool get isGameOver => state == 'game_over';

  String get elapsedFormatted {
    final m = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  String toString() =>
      'RemoteGameStatus(state=$state, player=$currentPlayerName, '
          'scores=$scores, elapsed=$elapsedFormatted)';
}