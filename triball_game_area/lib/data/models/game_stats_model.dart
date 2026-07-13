// lib/data/models/game_stats_model.dart

import 'package:get/get.dart';
import 'score_event_model.dart';

/// Statistiques live calculées en temps réel pendant la partie
class GameStats {
  final RxInt totalShots = 0.obs;
  final RxInt positiveShots = 0.obs;
  final RxInt negativeShots = 0.obs;
  final RxInt bonusShots = 0.obs;           // +30
  final RxInt penaltyShots = 0.obs;         // x0
  final RxInt multiplierShots = 0.obs;      // x2
  final RxInt missedShots = 0.obs;          // refused (overshoot)
  final RxInt totalCombosTriggered = 0.obs;
  final RxInt maxComboCount = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt maxStreak = 0.obs;
  final RxInt totalPointsGained = 0.obs;
  final RxInt totalPointsLost = 0.obs;

  // Heatmap : compteur de hits par trou
  final RxMap<String, int> hitsPerHole = <String, int>{}.obs;

  // ============================================
  // COMPUTED
  // ============================================
  double get accuracy {
    if (totalShots.value == 0) return 0;
    return (positiveShots.value / totalShots.value) * 100;
  }

  double get netScore => (totalPointsGained.value - totalPointsLost.value).toDouble();

  String? get mostHitHole {
    if (hitsPerHole.isEmpty) return null;
    return hitsPerHole.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // ============================================
  // EVENT REGISTRATION
  // ============================================
  void registerShot(ScoreEventModel event, bool applied) {
    totalShots.value++;

    // Heatmap
    hitsPerHole[event.hole] = (hitsPerHole[event.hole] ?? 0) + 1;

    if (!applied) {
      missedShots.value++;
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
      totalPointsGained.value += event.value;
      _incrementStreak();
    } else if (event.value > 0) {
      positiveShots.value++;
      totalPointsGained.value += event.value;
      _incrementStreak();
    } else if (event.value < 0) {
      negativeShots.value++;
      totalPointsLost.value += event.value.abs();
      _resetStreak();
    }
  }

  void registerCombo(int comboCount) {
    totalCombosTriggered.value++;
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

  void reset() {
    totalShots.value = 0;
    positiveShots.value = 0;
    negativeShots.value = 0;
    bonusShots.value = 0;
    penaltyShots.value = 0;
    multiplierShots.value = 0;
    missedShots.value = 0;
    totalCombosTriggered.value = 0;
    maxComboCount.value = 0;
    currentStreak.value = 0;
    maxStreak.value = 0;
    totalPointsGained.value = 0;
    totalPointsLost.value = 0;
    hitsPerHole.clear();
  }

  Map<String, dynamic> toJson() => {
    'totalShots': totalShots.value,
    'positiveShots': positiveShots.value,
    'negativeShots': negativeShots.value,
    'bonusShots': bonusShots.value,
    'penaltyShots': penaltyShots.value,
    'multiplierShots': multiplierShots.value,
    'missedShots': missedShots.value,
    'totalCombos': totalCombosTriggered.value,
    'maxCombo': maxComboCount.value,
    'maxStreak': maxStreak.value,
    'accuracy': accuracy,
    'hitsPerHole': hitsPerHole,
  };
}