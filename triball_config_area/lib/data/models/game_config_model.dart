// lib/data/models/game_config_model.dart

import '../../core/constants/game_constants.dart';
import 'game_state_model.dart';
import 'match_type_model.dart';

/// Configuration immutable d'une partie
class GameConfig {
  final MatchType matchType;                // ✅ NEW : type de match
  final GameMode mode;                       // Mode de jeu (Classic/Hardcore/etc.)
  final List<String> playerNames;
  final int targetScore;                     // Calculé selon mode
  final int ballsPerTurn;
  final int turnDurationSeconds;
  final int turnWarningSeconds;
  final OvershootRule overshootRule;
  final bool ttsEnabled;
  final bool soundEnabled;

  const GameConfig({
    required this.matchType,
    required this.mode,
    required this.playerNames,
    required this.targetScore,
    this.ballsPerTurn = 3,
    this.turnDurationSeconds = GameConstants.turnDurationSeconds,
    this.turnWarningSeconds = GameConstants.turnWarningSeconds,
    this.overshootRule = OvershootRule.refuse,
    this.ttsEnabled = true,
    this.soundEnabled = true,
  });

  // ============================================
  // ✅ NEW FACTORIES — Basées sur MatchType × GameMode
  // ============================================

  /// Compétition entre 2-6 joueurs
  factory GameConfig.competition({
    required GameMode mode,
    required List<String> players,
    int ballsPerTurn = 3,
    int? turnDurationSeconds,
    int? turnWarningSeconds,
    OvershootRule? overshootRule,

    bool ttsEnabled = true,
    bool soundEnabled = true,
  }) {
    assert(players.length >= 2 && players.length <= 6,
    'Competition needs 2-6 players');

    return GameConfig(
      matchType: MatchType.competition,
      mode: mode,
      playerNames: players,
      targetScore: mode.targetScore,
      ballsPerTurn: ballsPerTurn,
      turnDurationSeconds:
      turnDurationSeconds ?? GameConstants.turnDurationSeconds,
      turnWarningSeconds:
      turnWarningSeconds ?? GameConstants.turnWarningSeconds,
      overshootRule: overshootRule ?? _defaultOvershootRule(mode),  // ✅
      ttsEnabled: ttsEnabled,
      soundEnabled: soundEnabled,
    );
  }

  /// Solo Chrono (1 joueur, top 10 enregistré ESP32)
  factory GameConfig.soloChrono({
    required GameMode mode,
    required String playerName,
    int ballsPerTurn = 3,
    int? turnDurationSeconds,
    int? turnWarningSeconds,
    OvershootRule? overshootRule,
    bool ttsEnabled = true,
    bool soundEnabled = true,
  }) {
    return GameConfig(
      matchType: MatchType.soloChrono,
      mode: mode,
      playerNames: [playerName],
      targetScore: mode.targetScore,
      ballsPerTurn: ballsPerTurn,
      turnDurationSeconds:
      turnDurationSeconds ?? GameConstants.turnDurationSeconds,
      turnWarningSeconds:
      turnWarningSeconds ?? GameConstants.turnWarningSeconds,
      overshootRule: overshootRule ?? _defaultOvershootRule(mode),  // ✅
      ttsEnabled: ttsEnabled,
      soundEnabled: soundEnabled,
    );
  }

  /// Tournoi (4/8/16 joueurs, élimination directe)
  factory GameConfig.tournament({
    required GameMode mode,
    required List<String> players,
    int ballsPerTurn = 3,
    int? turnDurationSeconds,
    int? turnWarningSeconds,
    OvershootRule? overshootRule,           // ✅ Nullable
    bool ttsEnabled = true,
    bool soundEnabled = true,
  }) {
    return GameConfig(
      matchType: MatchType.tournament,
      mode: mode,
      playerNames: players,
      targetScore: mode.targetScore,
      ballsPerTurn: ballsPerTurn,
      turnDurationSeconds:
      turnDurationSeconds ?? GameConstants.turnDurationSeconds,
      turnWarningSeconds:
      turnWarningSeconds ?? GameConstants.turnWarningSeconds,
      overshootRule: overshootRule ?? _defaultOvershootRule(mode),  // ✅
      ttsEnabled: ttsEnabled,
      soundEnabled: soundEnabled,
    );
  }

  // ✅ NEW : Helper pour déterminer la règle par défaut selon le mode
  static OvershootRule _defaultOvershootRule(GameMode mode) {
    if (mode == GameMode.hardcore) {
      return OvershootRule.hardcoreOvershoot;   // ✅ Hardcore = dépassement OK
    }
    return OvershootRule.refuse;                 // Autres modes = refuse
  }

  // ============================================
  // GETTERS
  // ============================================
  int get playerCount => playerNames.length;

  bool get isSolo => matchType == MatchType.soloChrono;
  bool get isMulti => playerCount > 1;
  bool get isCompetition => matchType == MatchType.competition;
  bool get isTournament => matchType == MatchType.tournament;
  bool get isSoloChrono => matchType == MatchType.soloChrono;

  /// Ce match sauvegarde-t-il un score au top 10 ?
  bool get savesToLeaderboard => matchType.savesToLeaderboard;

  /// Ce match supporte-t-il le switch entre joueurs ?
  bool get supportsPlayerSwitch => matchType.supportsPlayerSwitch;

  // ============================================
  // COPY WITH
  // ============================================
  GameConfig copyWith({
    MatchType? matchType,
    GameMode? mode,
    List<String>? playerNames,
    int? targetScore,
    int? ballsPerTurn,
    int? turnDurationSeconds,
    int? turnWarningSeconds,
    OvershootRule? overshootRule,
    bool? ttsEnabled,
    bool? soundEnabled,
  }) {
    return GameConfig(
      matchType: matchType ?? this.matchType,
      mode: mode ?? this.mode,
      playerNames: playerNames ?? this.playerNames,
      targetScore: targetScore ?? this.targetScore,
      ballsPerTurn: ballsPerTurn ?? this.ballsPerTurn,
      turnDurationSeconds:
      turnDurationSeconds ?? this.turnDurationSeconds,
      turnWarningSeconds:
      turnWarningSeconds ?? this.turnWarningSeconds,
      overshootRule: overshootRule ?? this.overshootRule,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  String toString() =>
      'GameConfig(${matchType.key} × ${mode.key}, players=$playerCount, '
          'target=$targetScore)';
}

// ============================================================
// OVERSHOOT RULE (inchangé)
// ============================================================
enum OvershootRule {
  refuse,           // Refuse le score si dépassement
  bounce,           // Rebond : 100 - (score - 100)
  hardcoreOvershoot // ✅ NEW : autorise dépassement, victoire à 100 exact
}

extension OvershootRuleX on OvershootRule {
  String get translationKey {
    switch (this) {
      case OvershootRule.refuse:            return 'overshoot_rule_refuse';
      case OvershootRule.bounce:            return 'overshoot_rule_bounce';
      case OvershootRule.hardcoreOvershoot: return 'overshoot_rule_hardcore';
    }
  }
}

/// ⚠️ ALIAS TEMPORAIRES pour compat avec l'ancien code
/// À SUPPRIMER après l'étape C
extension _TempCompatExtensions on GameConfig {
  // Simule les anciens booléens
  bool get isSoloChronoLegacy => matchType == MatchType.soloChrono;
  bool get isTournamentLegacy => matchType == MatchType.tournament;
}