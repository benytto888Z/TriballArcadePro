// Formatage des durées + modèle de classement (Game Area).
//
// Le temps affiché en fin de partie et le temps enregistré au top 10 doivent
// être STRICTEMENT identiques (snapshot figé), sinon le joueur voit deux
// chronos différents. Ces tests verrouillent ce contrat.
import 'package:flutter_test/flutter_test.dart';
import 'package:tribal_game_area/core/utils/game_time_formatter.dart';
import 'package:tribal_game_area/data/models/game_state_model.dart';
import 'package:tribal_game_area/data/models/leaderboard_entry_model.dart';
import 'package:tribal_game_area/data/models/match_type_model.dart';

void main() {
  group('GameTimeFormatter', () {
    test('mm:ss pour les écrans de jeu et de victoire', () {
      expect(GameTimeFormatter.mmSs(Duration.zero), '00:00');
      expect(GameTimeFormatter.mmSs(const Duration(seconds: 5)), '00:05');
      expect(
        GameTimeFormatter.mmSs(const Duration(minutes: 2, seconds: 5)),
        '02:05',
      );
      expect(
        GameTimeFormatter.mmSs(const Duration(seconds: 59, milliseconds: 999)),
        '00:59',
      );
      expect(
        GameTimeFormatter.mmSs(const Duration(minutes: 99, seconds: 59)),
        '99:59',
      );
    });

    test('mm:ss.cc pour le podium et le top 10', () {
      expect(
        GameTimeFormatter.mmSsHundredths(const Duration(milliseconds: 65432)),
        '01:05.43',
      );
      expect(GameTimeFormatter.mmSsHundredths(Duration.zero), '00:00.00');
      expect(
        GameTimeFormatter.mmSsHundredths(const Duration(milliseconds: 100990)),
        '01:40.99',
      );
    });

    test('partie = mm:ss, même chiffres que le podium sans les centièmes', () {
      const measured = Duration(milliseconds: 65432);
      final precise = GameTimeFormatter.mmSsHundredths(measured);
      expect(precise.split('.').first, GameTimeFormatter.mmSs(measured));
    });

    test('durée officielle = secondes affichées + seule la fraction mesurée', () {
      expect(
        GameTimeFormatter.officialDuration(
          displayedSeconds: 42,
          preciseMeasurement: const Duration(milliseconds: 1537),
        ).inMilliseconds,
        42537,
      );
      // Les minutes de la mesure précise sont ignorées : pas de double comptage.
      expect(
        GameTimeFormatter.officialDuration(
          displayedSeconds: 10,
          preciseMeasurement: const Duration(seconds: 65, milliseconds: 250),
        ).inMilliseconds,
        10250,
      );
      // Jamais de temps négatif au classement.
      expect(
        GameTimeFormatter.officialDuration(
          displayedSeconds: -3,
          preciseMeasurement: const Duration(milliseconds: 300),
        ).inMilliseconds,
        300,
      );
    });
  });

  group('LeaderboardEntryModel', () {
    final entry = LeaderboardEntryModel(
      playerName: 'AMZ',
      completionTime: const Duration(milliseconds: 65432),
      totalBalls: 7,
      date: DateTime.utc(2026, 9, 20, 12, 30),
      matchType: MatchType.soloChrono,
      gameMode: GameMode.hardcore,
      avatarId: '7d6b4f1a-0f3c-4a5f-9b0f-1c2d3e4f5a6b',
    );

    test('aller-retour JSON complet (storage local)', () {
      final json = entry.toJson();
      expect(json['playerName'], 'AMZ');
      expect(json['completionTimeMs'], 65432);
      expect(json['totalBalls'], 7);
      expect(json['matchType'], 'solo_chrono');
      expect(json['gameMode'], 'hardcore');
      expect(json['avatarId'], entry.avatarId);

      final restored = LeaderboardEntryModel.fromJson(json);
      expect(restored.playerName, entry.playerName);
      expect(restored.completionTime, entry.completionTime);
      expect(restored.totalBalls, entry.totalBalls);
      expect(restored.gameMode, GameMode.hardcore);
      expect(restored.matchType, MatchType.soloChrono);
      expect(restored.avatarId, entry.avatarId);
      expect(restored.date.isAtSameMomentAs(entry.date), isTrue);
    });

    test('avatarId omis quand absent (payload compact)', () {
      final noAvatar = LeaderboardEntryModel(
        playerName: 'KID',
        completionTime: const Duration(seconds: 30),
        totalBalls: 3,
        date: DateTime.utc(2026, 1, 1),
        matchType: MatchType.soloChrono,
        gameMode: GameMode.classic,
      );
      expect(noAvatar.toJson().containsKey('avatarId'), isFalse);
      expect(
        LeaderboardEntryModel.fromJson(noAvatar.toJson()).avatarId,
        isNull,
      );
    });

    test('accepte les clés courtes renvoyées par la plateforme', () {
      final fromPlatform = LeaderboardEntryModel.fromJson({
        'player': 'KID',
        'time_ms': 12345,
        'balls': 4,
        'date': '2026-01-02T03:04:05.000Z',
        'mode': 'combo',
        'avatar_id': 'abc-123',
      });
      expect(fromPlatform.playerName, 'KID');
      expect(fromPlatform.completionTime.inMilliseconds, 12345);
      expect(fromPlatform.totalBalls, 4);
      expect(fromPlatform.gameMode, GameMode.combo);
      expect(fromPlatform.avatarId, 'abc-123');
      // Un payload plateforme n'embarque pas de matchType → défaut solo chrono.
      expect(fromPlatform.matchType, MatchType.soloChrono);
    });

    test('payload compact pour l\'ESP32 (buffer limité)', () {
      final compact = entry.toEsp32Json();
      for (final key in [
        'player',
        'time_ms',
        'balls',
        'date',
        'match_type',
        'mode',
      ]) {
        expect(compact.containsKey(key), isTrue, reason: 'clé manquante: $key');
      }
      expect(compact['mode'], 'hardcore');
      expect(compact['time_ms'], 65432);
      // Pas de clé longue inutile : l'UUID voyage dans 'avatar_id' ajouté
      // par le websocket_controller, pas par ce payload.
      expect(compact.containsKey('avatar_id'), isFalse);
      expect(compact.containsKey('completionTimeMs'), isFalse);
    });

    test('JSON vide ne plante jamais (leaderboard corrompu)', () {
      final fallback = LeaderboardEntryModel.fromJson(<String, dynamic>{});
      expect(fallback.playerName, isEmpty);
      expect(fallback.completionTime, Duration.zero);
      expect(fallback.gameMode, GameMode.classic);
      expect(fallback.matchType, MatchType.soloChrono);
      expect(fallback.avatarId, isNull);
    });

    test('timeFormatted = mm:ss.cc et date en JJ/MM/AAAA', () {
      expect(entry.timeFormatted, '01:05.43');
      expect(entry.dateFormatted, '20/09/2026');
      expect(entry.toString(), contains('AMZ'));
    });
  });
}
