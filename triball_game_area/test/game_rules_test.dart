// Test des règles métier TRIBALL (Game Area).
//
// Ces tests verrouillent la règle du jeu validée :
///  • cible = 100 points EXACTEMENT (200 en Champion)
///  • 3 balles par tour
///  • timer de tour = 40 s dans TOUS les modes
///  • combos uniquement en mode Combo/Champion, jamais sur les hits négatifs / x0
///  • Perfect Streak = tour bonus, neutre sur les points
///  • Hardcore : x0 = -20 points et dépassement autorisé
import 'package:flutter_test/flutter_test.dart';
import 'package:tribal_game_area/core/constants/game_constants.dart';
import 'package:tribal_game_area/data/models/combo_model.dart';
import 'package:tribal_game_area/data/models/game_state_model.dart';
import 'package:tribal_game_area/data/models/match_type_model.dart';
import 'package:tribal_game_area/data/models/score_modifier_model.dart';

void main() {
  group('Score', () {
    test('cible = 100 points exacts, 200 en Champion', () {
      expect(GameConstants.targetScore, 100);
      expect(GameMode.classic.targetScore, 100);
      expect(GameMode.hardcore.targetScore, 100);
      expect(GameMode.combo.targetScore, 100);
      expect(GameMode.champion.targetScore, 200);
    });

    test('getTargetScore(String) reste aligné sur l\'enum GameMode', () {
      expect(GameConstants.getTargetScore(GameConstants.modeChampion), 200);
      expect(GameConstants.getTargetScore(GameConstants.modeClassic), 100);
      for (final mode in GameMode.values) {
        expect(
          GameConstants.getTargetScore(mode.key),
          mode.targetScore,
          reason: 'divergence de cible pour le mode ${mode.key}',
        );
      }
    });

    test('4 trous marquent négatif, 2 sont spéciaux (x0 / x2)', () {
      expect(GameConstants.holeValues.length, 9);
      expect(GameConstants.holeValues['CENTER_MID'], 30);
      expect(
        GameConstants.holeValues.values.where((v) => v < 0).length,
        3,
        reason: 'LEFT_MID, CENTER_TOP, RIGHT_MID',
      );
      expect(GameConstants.holeValues[GameConstants.holeMultiplyX0], 0);
      expect(GameConstants.holeValues[GameConstants.holeMultiplyX2], 0);
    });

    test('le plafond hardcore évite un score aberrant sur la TV', () {
      expect(GameConstants.hardcoreMaxScore, greaterThan(GameConstants.targetScore));
    });
  });

  group('Tours', () {
    test('3 balles par tour, 40 s de chrono, pause de 5 s avant le suivant', () {
      expect(GameConstants.ballsPerTurn, 3);
      // ⚠️ 40 s = règle officielle ET défaut du Config Area.
      expect(GameConstants.turnDurationSeconds, 40);
      expect(GameConstants.turnWarningSeconds, 10);
      expect(GameConstants.scoreViewingPauseSeconds, 5);
      expect(GameConstants.turnWarningSeconds,
          lessThan(GameConstants.turnDurationSeconds));
    });

    test('bornes de joueurs', () {
      expect(GameConstants.minPlayers, 1);
      expect(GameConstants.maxPlayers, 6);
    });
  });

  group('Combos', () {
    test('multiplicateurs actifs uniquement en Combo et Champion', () {
      expect(GameMode.combo.applyComboMultipliers, isTrue);
      expect(GameMode.champion.applyComboMultipliers, isTrue);
      expect(GameMode.classic.applyComboMultipliers, isFalse);
      expect(GameMode.hardcore.applyComboMultipliers, isFalse);
      expect(GameMode.combo.hasComboFeatures, isTrue);
      expect(GameMode.classic.hasComboFeatures, isFalse);
    });

    test('DOUBLE = x2, TRIPLE = x3, PERFECT STREAK = neutre sur les points', () {
      expect(ComboType.doubleCombo.multiplier, 2.0);
      expect(ComboType.tripleCombo.multiplier, 3.0);
      expect(ComboType.perfectStreak.multiplier, 1.0);
      expect(ComboType.precisionShot.multiplier, 1.0);
      expect(ComboType.none.multiplier, 1.0);
    });

    test('seul le Perfect Streak accorde un tour bonus', () {
      expect(ComboType.perfectStreak.grantsBonusTurn, isTrue);
      expect(ComboType.doubleCombo.grantsBonusTurn, isFalse);
      expect(ComboType.tripleCombo.grantsBonusTurn, isFalse);
      expect(ComboType.precisionShot.grantsBonusTurn, isFalse);
      expect(ComboType.none.grantsBonusTurn, isFalse);

      final streak = ComboModel(
        type: ComboType.perfectStreak,
        count: 3,
        events: const [],
      );
      expect(streak.isActive, isTrue);
      expect(streak.grantsBonusTurn, isTrue);
      expect(streak.toString(), contains('STREAK'));

      final none = ComboModel(
        type: ComboType.none,
        count: 0,
        events: const [],
      );
      expect(none.isActive, isFalse);
    });

    test('priorité d\'affichage: TRIPLE > STREAK > DOUBLE > PRECISION > none', () {
      expect(ComboType.tripleCombo.priority,
          greaterThan(ComboType.perfectStreak.priority));
      expect(ComboType.perfectStreak.priority,
          greaterThan(ComboType.doubleCombo.priority));
      expect(ComboType.doubleCombo.priority,
          greaterThan(ComboType.precisionShot.priority));
      expect(ComboType.precisionShot.priority,
          greaterThan(ComboType.none.priority));
    });

    test('clé de traduction non vide pour tout combo actif', () {
      for (final type in ComboType.values.where((t) => t != ComboType.none)) {
        expect(type.translationKey, isNotEmpty, reason: type.displayName);
      }
      expect(ComboType.none.translationKey, isEmpty);
    });
  });

  group('Modificateurs de score', () {
    test('pénalité hardcore = -20, x0 annule, x2 double', () {
      expect(ScoreModifier.hardcorePenalty.flatBonus, -20);
      expect(ScoreModifier.x0Reset.multiplier, 0.0);
      expect(ScoreModifier.x2Multiplier.multiplier, 2.0);
      expect(ScoreModifier.comboDouble.multiplier, 2.0);
      expect(ScoreModifier.comboTriple.multiplier, 3.0);
      // Le streak ne distribue pas de points : seulement un tour bonus.
      expect(ScoreModifier.perfectStreak.multiplier, 1.0);
      expect(ScoreModifier.perfectStreak.flatBonus, 0);
      expect(ScoreModifier.hardcorePenalty.multiplier, 1.0);
    });

    test('ScoreModifierResult: amplified / multiplier / combo', () {
      final amplified = ScoreModifierResult(
        baseValue: 10,
        finalValue: 30,
        multiplier: 3.0,
      );
      expect(amplified.isAmplified, isTrue);
      expect(amplified.hasMultiplier, isTrue);
      expect(amplified.hasCombo, isFalse);
      expect(amplified.modifiers, isEmpty);
      expect(amplified.messages, isEmpty);

      // Un hit négatif non modifié n'est jamais "amplifié".
      final negative = ScoreModifierResult(baseValue: -5, finalValue: -5);
      expect(negative.isAmplified, isFalse);
      expect(negative.hasMultiplier, isFalse);

      // x0 : multiplicateur actif mais score écrasé, donc pas amplifié.
      final reset = ScoreModifierResult(
        baseValue: 30,
        finalValue: 0,
        multiplier: 0.0,
      );
      expect(reset.hasMultiplier, isTrue);
      expect(reset.isAmplified, isFalse);
    });
  });

  group('Types de match', () {
    test('seul le Solo Chrono alimente le top 10', () {
      expect(MatchType.soloChrono.savesToLeaderboard, isTrue);
      expect(MatchType.competition.savesToLeaderboard, isFalse);
      expect(MatchType.tournament.savesToLeaderboard, isFalse);
    });

    test('le switch entre joueurs est réservé à la Compétition', () {
      expect(MatchType.competition.supportsPlayerSwitch, isTrue);
      expect(MatchType.soloChrono.supportsPlayerSwitch, isFalse);
      expect(MatchType.tournament.supportsPlayerSwitch, isFalse);
    });

    test('bornes de joueurs par type de match', () {
      expect(MatchType.soloChrono.minPlayers, 1);
      expect(MatchType.soloChrono.maxPlayers, 1);
      expect(MatchType.competition.minPlayers, 2);
      expect(MatchType.competition.maxPlayers, GameConstants.maxPlayers);
      expect(MatchType.tournament.minPlayers, 4);
      expect(MatchType.tournament.allowedSizes, [4, 8, 16]);
      for (final size in MatchType.tournament.allowedSizes) {
        // Bracket d'élimination directe = puissance de 2.
        expect(size & (size - 1), 0, reason: '$size n\'est pas une puissance de 2');
      }
    });
  });

  group('Protocole', () {
    test('clés GameMode stables (stockage + ESP32)', () {
      const expected = {
        GameMode.classic: 'classic',
        GameMode.hardcore: 'hardcore',
        GameMode.champion: 'champion',
        GameMode.combo: 'combo',
      };
      expect(GameMode.values.length, expected.length);
      expected.forEach((mode, key) {
        expect(mode.key, key);
        expect(GameModeExtension.fromKey(key), mode);
      });
      expect(GameModeExtension.fromKey('unknown'), isNull);
      // Solo Chrono et Tournoi ne sont PLUS des GameMode.
      expect(GameModeExtension.fromKey('solo_chrono'), isNull);
      expect(GameModeExtension.fromKey('tournament'), isNull);
    });

    test('clés MatchType stables', () {
      const expected = {
        MatchType.competition: 'competition',
        MatchType.soloChrono: 'solo_chrono',
        MatchType.tournament: 'tournament',
      };
      expect(MatchType.values.length, expected.length);
      expected.forEach((type, key) {
        expect(type.key, key);
        expect(MatchTypeX.fromKey(key), type);
      });
      expect(MatchTypeX.fromKey(''), isNull);
    });

    test('phases de jeu', () {
      expect(GamePhase.playing.isActive, isTrue);
      expect(GamePhase.paused.isActive, isFalse);
      expect(GamePhase.victory.isEnded, isTrue);
      expect(GamePhase.gameOver.isEnded, isTrue);
      expect(GamePhase.playing.isEnded, isFalse);
      expect(GamePhase.turnTransition.name, 'turn_transition');
      expect(GamePhase.gameOver.name, 'game_over');
    });
  });
}
