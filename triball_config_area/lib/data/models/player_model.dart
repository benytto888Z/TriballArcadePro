// lib/data/models/player_model.dart

import 'package:get/get.dart';
import 'score_event_model.dart';

class PlayerModel {
  final int id;
  final String name;
  final RxInt score;
  final RxInt turnScore;
  final RxInt ballsThrown;
  final RxBool isActive;
  final RxList<ScoreHistoryEntry> history;
  final Rx<DateTime?> startTime;
  final Rx<DateTime?> endTime;

  // ✅ NEW : Compteur de balles LOCAL au tour actuel
  final RxInt ballsThrownThisTurn = 0.obs;

  // ============================================
  // ✅ NEW : Events récents par joueur (max 5)
  // ============================================
  final RxList<ScoreEventModel> recentEvents = <ScoreEventModel>[].obs;

  // ============================================
  // ✅ NEW : Stats live par joueur
  // ============================================
  final RxInt totalShots = 0.obs;
  final RxInt positiveShots = 0.obs;
  final RxInt negativeShots = 0.obs;
  final RxInt bonusShots = 0.obs;       // ≥ +30
  final RxInt penaltyShots = 0.obs;     // x0
  final RxInt multiplierShots = 0.obs;  // x2
  final RxInt currentStreak = 0.obs;
  final RxInt maxStreak = 0.obs;
  final RxInt maxComboCount = 0.obs;
  final RxInt comboTriggered = 0.obs;

  // ============================================
  // ✅ NEW : Compteur de tours
  // ============================================
  final RxInt turnsPlayed = 0.obs;

  PlayerModel({
    required this.id,
    required this.name,
    int initialScore = 0,
  })  : score = initialScore.obs,
        turnScore = 0.obs,
        ballsThrown = 0.obs,
        isActive = false.obs,
        history = <ScoreHistoryEntry>[].obs,
        startTime = Rx<DateTime?>(null),
        endTime = Rx<DateTime?>(null);

  int get totalBalls => ballsThrown.value;

  // ============================================
  // COMPUTED
  // ============================================
  double get accuracy {
    if (totalShots.value == 0) return 0;
    return (positiveShots.value / totalShots.value) * 100;
  }

  Duration? get elapsedTime {
    if (startTime.value == null) return null;
    final end = endTime.value ?? DateTime.now();
    return end.difference(startTime.value!);
  }

  String get elapsedTimeFormatted {
    final d = elapsedTime;
    if (d == null) return '--:--';
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = (d.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$millis';
  }

  int get positiveShotsCount => positiveShots.value;
  int get negativeShotsCount => negativeShots.value;
  int get bigShotsCount => bonusShots.value;

  int? get bestShot {
    if (history.isEmpty) return null;
    return history.map((e) => e.points).reduce((a, b) => a > b ? a : b);
  }

  // ============================================
  // ✅ NEW : Register a shot (combine score + event + stats)
  // ============================================
  void registerShot({
    required ScoreEventModel event,
    required bool applied,
  }) {
    // Add to recent events (max 5)
    recentEvents.insert(0, event);
    if (recentEvents.length > 5) recentEvents.removeLast();

    // Update stats
    totalShots.value++;

    if (!applied) {
      _resetStreak();
      return;
    }

    if (event.isX0) {
      penaltyShots.value++;
      _resetStreak();
    } else if (event.isX2) {
      multiplierShots.value++;
    } else if (event.value >= 30) {
      bonusShots.value++;
      positiveShots.value++;
      _incrementStreak();
    } else if (event.value > 0) {
      positiveShots.value++;
      _incrementStreak();
    } else if (event.value < 0) {
      negativeShots.value++;
      _resetStreak();
    }
  }

  void registerCombo(int comboCount) {
    comboTriggered.value++;
    if (comboCount > maxComboCount.value) {
      maxComboCount.value = comboCount;
    }
  }

  void _incrementStreak() {
    currentStreak.value++;
    if (currentStreak.value > maxStreak.value) {
      maxStreak.value = currentStreak.value;
    }
  }

  void _resetStreak() {
    currentStreak.value = 0;
  }

  // ============================================
  // ✅ NEW : Incrémenter le tour
  // ============================================
  void incrementTurn() {
    turnsPlayed.value++;
  }

  // ============================================
  // RESET (called on game restart)
  // ============================================
  void reset() {
    score.value = 0;
    turnScore.value = 0;
    ballsThrown.value = 0;
    isActive.value = false;
    history.clear();
    recentEvents.clear();
    startTime.value = null;
    endTime.value = null;

    // Reset stats
    totalShots.value = 0;
    positiveShots.value = 0;
    negativeShots.value = 0;
    bonusShots.value = 0;
    penaltyShots.value = 0;
    multiplierShots.value = 0;
    currentStreak.value = 0;
    maxStreak.value = 0;
    maxComboCount.value = 0;
    comboTriggered.value = 0;
    turnsPlayed.value = 0;    // ✅ NEW
    ballsThrownThisTurn.value = 0;   // ✅ NEW
  }

  void addScoreEntry(String hole, int points, String effect) {
    history.add(ScoreHistoryEntry(
      hole: hole,
      points: points,
      effect: effect,
      timestamp: DateTime.now(),
      scoreAfter: score.value,
    ));
  }

  void incrementBallsThisTurn() {
    ballsThrownThisTurn.value++;
    ballsThrown.value++;  // Garde aussi le compteur global pour stats
  }

  void resetBallsThisTurn() {
    ballsThrownThisTurn.value = 0;
  }


  // ============================================
// ✅ NEW : Reset combo state pour nouveau tour bonus
// (efface uniquement les recent events + streak,
// sans toucher aux stats globales)
// ============================================
  void resetForBonusTurn() {
    recentEvents.clear();
    currentStreak.value = 0;
    ballsThrownThisTurn.value = 0;    // ✅ Reset compteur du tour

  }


  // ============================================
  // ✅ NEW : Reset combo state pour nouveau tour
  // (appelé lors du switch de joueur)
  // ============================================
  void resetForNewTurn() {
    // Reset combo tracking (mais garde les stats globales)
    recentEvents.clear();
    currentStreak.value = 0;
    ballsThrownThisTurn.value = 0;    // ✅ Reset compteur du tour
  }

  @override
  String toString() => 'Player($name: ${score.value})';
}

// ============================================================
// SCORE HISTORY ENTRY (inchangé)
// ============================================================
class ScoreHistoryEntry {
  final String hole;
  final int points;
  final String effect;
  final DateTime timestamp;
  final int scoreAfter;

  ScoreHistoryEntry({
    required this.hole,
    required this.points,
    required this.effect,
    required this.timestamp,
    required this.scoreAfter,
  });

  Map<String, dynamic> toJson() => {
    'hole': hole,
    'points': points,
    'effect': effect,
    'timestamp': timestamp.toIso8601String(),
    'scoreAfter': scoreAfter,
  };

  factory ScoreHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ScoreHistoryEntry(
      hole: json['hole'] ?? '',
      points: json['points'] ?? 0,
      effect: json['effect'] ?? 'neutral',
      timestamp: DateTime.parse(
          json['timestamp'] ?? DateTime.now().toIso8601String()),
      scoreAfter: json['scoreAfter'] ?? 0,
    );
  }

  bool get isPositive => points > 0;
  bool get isNegative => points < 0;
  bool get isZero => points == 0;
}