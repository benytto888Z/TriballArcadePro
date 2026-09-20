// Construction de la configuration de partie envoyée à l'écran de jeu.
//
// Le contrat est simple : ce que le Config Area choisit doit correspondre
// exactement à la règle TRIBALL, sinon la TV joue avec une autre règle.
import 'package:amzneontriballui/core/constants/game_constants.dart';
import 'package:amzneontriballui/data/models/game_config_model.dart';
import 'package:amzneontriballui/data/models/game_state_model.dart';
import 'package:amzneontriballui/data/models/match_type_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Constantes de règle', () {
    test('cible 100 pts / 3 balles / 40 s par tour', () {
      expect(GameConstants.targetScore, 100);
      expect(GameConstants.ballsPerTurn, 3);
      // ⚠️ doit rester identique au défaut du Game Area, sinon un lancement
      // autonome de la TV ne joue pas avec le même chrono.
      expect(GameConstants.turnDurationSeconds, 40);
      expect(GameConstants.turnWarningSeconds, 10);
    });

    test('clés des types de match (protocole WebSocket)', () {
      const expected = {
        MatchType.competition: 'competition',
        MatchType.soloChrono: 'solo_chrono',
        MatchType.tournament: 'tournament',
      };
      expected.forEach((type, key) {
        expect(type.key, key);
        expect(MatchTypeX.fromKey(key), type);
      });
      expect(MatchTypeX.fromKey('inconnu'), isNull);
    });
  });

  group('GameConfig — Solo Chrono', () {
    final config = GameConfig.soloChrono(mode: GameMode.classic, playerName: 'AMZ');

    test('1 joueur, top 10, pas de switch', () {
      expect(config.matchType, MatchType.soloChrono);
      expect(config.playerNames, ['AMZ']);
      expect(config.playerCount, 1);
      expect(config.isSolo, isTrue);
      expect(config.isSoloChrono, isTrue);
      expect(config.isMulti, isFalse);
      expect(config.savesToLeaderboard, isTrue);
      expect(config.supportsPlayerSwitch, isFalse);
    });

    test('réglages par défaut', () {
      expect(config.targetScore, 100);
      expect(config.ballsPerTurn, 3);
      expect(config.turnDurationSeconds, GameConstants.turnDurationSeconds);
      expect(config.turnWarningSeconds, GameConstants.turnWarningSeconds);
      expect(config.ttsEnabled, isTrue);
      expect(config.soundEnabled, isTrue);
      expect(config.overshootRule, OvershootRule.refuse);
    });

    test('Champion = cible 200 pts', () {
      expect(
        GameConfig.soloChrono(mode: GameMode.champion, playerName: 'AMZ')
            .targetScore,
        200,
      );
    });

    test('Hardcore autorise le dépassement (victoire à 100 exacts)', () {
      final hardcore =
          GameConfig.soloChrono(mode: GameMode.hardcore, playerName: 'AMZ');
      expect(hardcore.overshootRule, OvershootRule.hardcoreOvershoot);
      expect(hardcore.targetScore, 100);
    });
  });

  group('GameConfig — Compétition', () {
    test('2 à 6 joueurs, pas de top 10, switch autorisé', () {
      final config = GameConfig.competition(
        mode: GameMode.combo,
        players: ['A', 'B', 'C'],
      );
      expect(config.matchType, MatchType.competition);
      expect(config.playerCount, 3);
      expect(config.isCompetition, isTrue);
      expect(config.isMulti, isTrue);
      expect(config.savesToLeaderboard, isFalse);
      expect(config.supportsPlayerSwitch, isTrue);
      expect(config.overshootRule, OvershootRule.refuse);
    });

    test('une liste vide de joueurs est refusée en debug', () {
      expect(
        () => GameConfig.competition(mode: GameMode.classic, players: const []),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('GameConfig — Tournoi', () {
    test('bracket 4/8/16, top 10 hors tournoi', () {
      final config = GameConfig.tournament(
        mode: GameMode.classic,
        players: ['A', 'B', 'C', 'D'],
      );
      expect(config.matchType, MatchType.tournament);
      expect(config.isTournament, isTrue);
      expect(config.isSolo, isFalse);
      expect(config.savesToLeaderboard, isFalse);
      expect(MatchType.tournament.allowedSizes, [4, 8, 16]);
    });
  });

  group('GameConfig — copyWith', () {
    test('surcharge uniquement les champs fournis', () {
      final base = GameConfig.soloChrono(mode: GameMode.classic, playerName: 'AMZ');
      final next = base.copyWith(
        turnDurationSeconds: 60,
        ttsEnabled: false,
      );
      expect(next.turnDurationSeconds, 60);
      expect(next.ttsEnabled, isFalse);
      // intacts
      expect(next.matchType, base.matchType);
      expect(next.mode, base.mode);
      expect(next.ballsPerTurn, base.ballsPerTurn);
      expect(next.overshootRule, base.overshootRule);
      expect(next.soundEnabled, base.soundEnabled);
    });

    test('toString expose matchType × mode et la cible', () {
      final config = GameConfig.soloChrono(mode: GameMode.hardcore, playerName: 'AMZ');
      expect(config.toString(), contains('solo_chrono'));
      expect(config.toString(), contains('hardcore'));
      expect(config.toString(), contains('100'));
    });
  });

  group('Règle de dépassement', () {
    test('clé de traduction pour chaque règle', () {
      expect(OvershootRule.refuse.translationKey, 'overshoot_rule_refuse');
      expect(OvershootRule.bounce.translationKey, 'overshoot_rule_bounce');
      expect(
        OvershootRule.hardcoreOvershoot.translationKey,
        'overshoot_rule_hardcore',
      );
    });
  });
}
