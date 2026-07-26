// lib/data/repositories/game_repository.dart

import '../../core/constants/game_constants.dart';
import '../models/player_model.dart';
import '../models/game_state_model.dart';
import '../models/score_event_model.dart';
import '../models/game_config_model.dart';
import '../models/combo_model.dart';
import '../models/score_modifier_model.dart';

class GameRepository {
  // ============================================
  // SCORE APPLICATION
  // ============================================
  ScoreApplyResult applyScore({
    required int currentScore,
    required ScoreEventModel event,
    required GameConfig config,
    List<ScoreEventModel> recentEvents = const [],
    int currentStreak = 0,
  }) {
    final target = config.targetScore;
    int newScore = currentScore;
    String message = '';
    int baseValue = event.value;
    double appliedMultiplier = 1.0;
    final modifiers = <ScoreModifier>[];

    // ===== DETECT COMBO =====
    final combo = detectCombo(
      recentEvents: [event, ...recentEvents],
      currentStreak: currentStreak,
    );

    // ============================================
    // ✅ HARDCORE MODE — Logique enrichie
    // ============================================
    if (config.mode == GameMode.hardcore) {

      // 1. x0 → -20 points (existant)
      if (event.isX0) {
        newScore = (currentScore - 20).clamp(0, GameConstants.hardcoreMaxScore);
        modifiers.add(ScoreModifier.hardcorePenalty);
        return ScoreApplyResult(
          previousScore: currentScore,
          newScore: newScore,
          applied: true,
          isVictory: false,
          isOvershoot: false,
          message: 'hardcore_penalty',
          baseValue: baseValue,
          appliedMultiplier: 1.0,
          modifiers: modifiers,
          combo: null,
        );
      }

      // 2. x2 → double le score (avec plafond max)
      if (event.isX2) {
        // Conserver le signe du score : -10 × 2 = -20.
        // Seul le plafond positif Hardcore reste appliqué.
        newScore = currentScore * 2;
        if (newScore > GameConstants.hardcoreMaxScore) {
          newScore = GameConstants.hardcoreMaxScore;
        }
        appliedMultiplier = 2.0;
        modifiers.add(ScoreModifier.x2Multiplier);
        message = 'score_doubled';

        final isVictory = newScore == target;
        return ScoreApplyResult(
          previousScore: currentScore,
          newScore: newScore,
          applied: true,
          isVictory: isVictory,
          isOvershoot: false,
          message: isVictory ? 'victory' : message,
          baseValue: baseValue,
          appliedMultiplier: appliedMultiplier,
          modifiers: modifiers,
          combo: combo,
        );
      }

      // 3. Score normal : +5, +10, +30, -5, -10
      newScore = currentScore + event.value;

      // Les scores négatifs sont autorisés : 0 - 5 = -5, puis -5 + 10 = 5.

      // 5. Plafond à hardcoreMaxScore (200)
      if (newScore > GameConstants.hardcoreMaxScore) {
        newScore = GameConstants.hardcoreMaxScore;
      }

      // 6. Victoire = score EXACTEMENT égal au target (100)
      final isVictory = newScore == target;
      final isOvershoot = newScore > target;   // Info seulement, pas de refus

      // ✅ Message spécial pour dépassement HARDCORE
      if (isOvershoot) {
        message = 'hardcore_overshoot';    // "Tu as dépassé 100, redescends !"
      } else if (isVictory) {
        message = 'victory';
      }

      return ScoreApplyResult(
        previousScore: currentScore,
        newScore: newScore,
        applied: true,                       // ✅ Toujours appliqué en HARDCORE
        isVictory: isVictory,
        isOvershoot: isOvershoot,
        message: message,
        baseValue: baseValue,
        appliedMultiplier: 1.0,
        modifiers: modifiers,
        combo: combo,
      );
    }

    // ============================================
    // AUTRES MODES (Classic, Champion, Combo) — Logique existante
    // ============================================

    // ===== SPECIAL HOLES =====
    if (event.isX0) {
      return ScoreApplyResult(
        previousScore: currentScore,
        newScore: 0,
        applied: true,
        isVictory: false,
        isOvershoot: false,
        message: 'score_reset_to_zero',
        baseValue: 0,
        appliedMultiplier: 0,
        modifiers: [ScoreModifier.x0Reset],
        combo: null,
      );
    }

    if (event.isX2) {
      newScore = currentScore * 2;
      appliedMultiplier = 2.0;
      modifiers.add(ScoreModifier.x2Multiplier);
      message = 'score_doubled';
    } else {
      int valueToAdd = event.value;

      // COMBO mode : multiplicateurs
      if (config.mode == GameMode.combo && combo != null) {
        if (combo.type != ComboType.none && event.value > 0) {
          double mult = combo.type.multiplier;

          // PERFECT STREAK accorde le tour bonus sans remultiplier le score.
          // Toutefois, si le hit courant complète aussi un DOUBLE/TRIPLE du
          // même trou, ce bonus de score reste appliqué indépendamment.
          if (combo.type == ComboType.perfectStreak) {
            final streakEvents = combo.events;
            final sameAsCurrent = streakEvents
                .take(3)
                .takeWhile((e) => e.hole == event.hole)
                .length;
            if (sameAsCurrent >= 3) {
              mult = 3.0;
              modifiers.add(ScoreModifier.comboTriple);
            } else if (sameAsCurrent >= 2) {
              mult = 2.0;
              modifiers.add(ScoreModifier.comboDouble);
            }
          }

          valueToAdd = (event.value * mult).round();
          appliedMultiplier = mult;
          switch (combo.type) {
            case ComboType.doubleCombo:
              modifiers.add(ScoreModifier.comboDouble);
              break;
            case ComboType.tripleCombo:
              modifiers.add(ScoreModifier.comboTriple);
              break;
            case ComboType.perfectStreak:
              modifiers.add(ScoreModifier.perfectStreak);
              break;
            default:
              break;
          }
        }
      }

      newScore = currentScore + valueToAdd;
    }

    // Aucun plancher : un hit négatif doit toujours être comptabilisé.
    bool wasOvershoot = false;

    // ===== OVERSHOOT HANDLING (Classic, Champion, Combo) =====
    if (newScore > target) {
      wasOvershoot = true;
      switch (config.overshootRule) {
        case OvershootRule.refuse:
          return ScoreApplyResult(
            previousScore: currentScore,
            newScore: currentScore,
            applied: false,
            isVictory: false,
            isOvershoot: true,
            message: 'overshoot_refused',
            baseValue: baseValue,
            appliedMultiplier: appliedMultiplier,
            // OVERSHOOT a priorité absolue sur les bonus visuels/sonores.
            modifiers: const [],
            combo: null,
          );

        case OvershootRule.bounce:
          int overshoot = newScore - target;
          newScore = target - overshoot;
          message = 'overshoot_bounce';
          break;

        case OvershootRule.hardcoreOvershoot:
        // Traité dans le bloc HARDCORE plus haut, ne devrait pas arriver ici
          break;
      }
    }

    final isVictory = newScore == target;

    return ScoreApplyResult(
      previousScore: currentScore,
      newScore: newScore,
      applied: true,
      isVictory: isVictory,
      isOvershoot: wasOvershoot,
      message: isVictory ? 'victory' : message,
      baseValue: baseValue,
      appliedMultiplier: appliedMultiplier,
      modifiers: modifiers,
      combo: combo,
    );
  }

  // ============================================
  // COMBO DETECTION (simplifié)
  // ============================================

  ComboModel? detectCombo({
    required List<ScoreEventModel> recentEvents,
    required int currentStreak,
  }) {
    if (recentEvents.isEmpty) return null;
    final current = recentEvents.first;

    // Aucun bonus sur une pénalité ou un multiplicateur spécial.
    if (current.value < 0 ||
        current.isNegative ||
        current.isX0 ||
        current.isX2) {
      return null;
    }

    // 1. PERFECT STREAK a priorité sur PRECISION et TRIPLE COMBO.
    // Les 3 derniers hits doivent tous appartenir à {+5, +10, +30}.
    // Cela couvre exactement les 3³ = 27 combinaisons demandées.
    const perfectValues = <int>{5, 10, 30};
    if (currentStreak >= 2 && recentEvents.length >= 3) {
      final lastThree = recentEvents.take(3).toList();
      final isPerfectStreak = lastThree.every(
            (event) =>
        !event.isX0 &&
            !event.isX2 &&
            !event.isNegative &&
            perfectValues.contains(event.value),
      );

      if (isPerfectStreak) {
        return ComboModel(
          type: ComboType.perfectStreak,
          count: currentStreak + 1,
          events: lastThree,
        );
      }
    }

    // 2. SAME HOLE COMBOS : Double ou Triple si aucun PERFECT STREAK.
    if (recentEvents.length >= 2) {
      int sameCount = 1;
      for (int i = 1; i < recentEvents.length; i++) {
        final event = recentEvents[i];
        if (event.value < 0 || event.isX0 || event.isX2) break;
        if (event.hole != current.hole) break;
        sameCount++;
      }

      if (sameCount >= 3) {
        return ComboModel(
          type: ComboType.tripleCombo,
          count: 3,
          events: recentEvents.take(3).toList(),
        );
      }

      if (sameCount == 2) {
        return ComboModel(
          type: ComboType.doubleCombo,
          count: 2,
          events: recentEvents.take(2).toList(),
        );
      }
    }

    // 3. PRECISION SHOT : +30 réellement isolé.
    if (current.value == 30) {
      return ComboModel(
        type: ComboType.precisionShot,
        count: 1,
        events: [current],
      );
    }

    return null;
  }

  // ============================================
  // PLAYER MANAGEMENT
  // ============================================
  List<PlayerModel> createPlayers(List<String> names) {
    return List.generate(
      names.length,
          (i) => PlayerModel(id: i, name: names[i]),
    );
  }

  int nextPlayerIndex(int current, int total) {
    return (current + 1) % total;
  }

  String suggestNextMove(int currentScore, int target) {
    final needed = target - currentScore;
    if (needed == 0) return 'victory_imminent';
    if (needed == 5) return 'aim_plus_5';
    if (needed == 10) return 'aim_plus_10';
    if (needed == 30) return 'aim_plus_30';
    if (needed > 30) return 'aim_high';
    if (needed < 0) return 'avoid_overshoot';
    return 'play_carefully';
  }

  bool isCombo(List<ScoreEventModel> recent) {
    if (recent.length < 3) return false;
    return recent[0].hole == recent[1].hole &&
        recent[1].hole == recent[2].hole;
  }
}

// ============================================================
// SCORE APPLY RESULT
// ============================================================
class ScoreApplyResult {
  final int previousScore;
  final int newScore;
  final bool applied;
  final bool isVictory;
  final bool isOvershoot;
  final String message;
  final int baseValue;
  final double appliedMultiplier;
  final List<ScoreModifier> modifiers;
  final ComboModel? combo;

  ScoreApplyResult({
    required this.previousScore,
    required this.newScore,
    required this.applied,
    required this.isVictory,
    required this.isOvershoot,
    required this.message,
    this.baseValue = 0,
    this.appliedMultiplier = 1.0,
    this.modifiers = const [],
    this.combo,
  });

  int get delta => newScore - previousScore;
  bool get isPositive => delta > 0;
  bool get isNegative => delta < 0;
  bool get isNeutral => delta == 0 && applied;
  bool get hasCombo => combo != null && combo!.isActive;
  bool get isAmplified => appliedMultiplier > 1.0;
}