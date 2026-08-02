// lib/data/models/tournament_model.dart

import 'package:get/get.dart';
import 'player_model.dart';

// ============================================================
// TOURNAMENT MATCH
// ============================================================
class TournamentMatch {
  final int matchId;
  final int round;
  final int positionInRound;       // Position dans la colonne
  Rx<PlayerModel?> player1;
  Rx<PlayerModel?> player2;
  Rx<PlayerModel?> winner;
  RxBool isCompleted;
  RxBool isInProgress;
  Rx<DateTime?> startedAt;
  Rx<DateTime?> completedAt;
  RxInt player1Score;
  RxInt player2Score;

  TournamentMatch({
    required this.matchId,
    required this.round,
    required this.positionInRound,
    PlayerModel? player1,
    PlayerModel? player2,
    PlayerModel? winner,
    bool isCompleted = false,
    bool isInProgress = false,
  })  : player1 = Rx<PlayerModel?>(player1),
        player2 = Rx<PlayerModel?>(player2),
        winner = Rx<PlayerModel?>(winner),
        isCompleted = isCompleted.obs,
        isInProgress = isInProgress.obs,
        startedAt = Rx<DateTime?>(null),
        completedAt = Rx<DateTime?>(null),
        player1Score = 0.obs,
        player2Score = 0.obs;

  bool get isReady =>
      player1.value != null && player2.value != null && !isCompleted.value;

  bool get isBye => player1.value != null && player2.value == null;

  PlayerModel? get loser {
    if (winner.value == null) return null;
    if (winner.value == player1.value) return player2.value;
    return player1.value;
  }

  void markAsStarted() {
    isInProgress.value = true;
    startedAt.value = DateTime.now();
  }

  void markAsCompleted(PlayerModel winnerPlayer,
      {int? p1Score, int? p2Score}) {
    winner.value = winnerPlayer;
    isCompleted.value = true;
    isInProgress.value = false;
    completedAt.value = DateTime.now();
    if (p1Score != null) player1Score.value = p1Score;
    if (p2Score != null) player2Score.value = p2Score;
  }

  Duration? get duration {
    if (startedAt.value == null || completedAt.value == null) return null;
    return completedAt.value!.difference(startedAt.value!);
  }
}

// ============================================================
// TOURNAMENT
// ============================================================
class TournamentModel {
  final String name;
  final List<PlayerModel> players;
  final RxList<TournamentMatch> matches;
  final RxInt currentRound;
  final RxInt currentMatchIndex;
  final RxBool isCompleted;
  final Rx<PlayerModel?> champion;
  final Rx<DateTime?> startedAt;
  final Rx<DateTime?> completedAt;

  TournamentModel({
    required this.name,
    required this.players,
    List<TournamentMatch>? matches,
    int currentRound = 1,
    int currentMatchIndex = 0,
    bool isCompleted = false,
  })  : matches = (matches ?? []).obs,
        currentRound = currentRound.obs,
        currentMatchIndex = currentMatchIndex.obs,
        isCompleted = isCompleted.obs,
        champion = Rx<PlayerModel?>(null),
        startedAt = Rx<DateTime?>(null),
        completedAt = Rx<DateTime?>(null);

  // ============================================
  // COMPUTED
  // ============================================
  int get totalRounds {
    int n = players.length;
    int rounds = 0;
    while (n > 1) {
      n = (n / 2).ceil();
      rounds++;
    }
    return rounds;
  }

  String roundName(int round) {
    final remaining = totalRounds - round + 1;
    switch (remaining) {
      case 1: return 'tournament_final';
      case 2: return 'tournament_semi';
      case 3: return 'tournament_quarter';
      case 4: return 'tournament_eight';
      default: return 'tournament_round';
    }
  }

  List<TournamentMatch> getMatchesForRound(int round) {
    return matches.where((m) => m.round == round).toList();
  }

  TournamentMatch? get currentMatch {
    final roundMatches = getMatchesForRound(currentRound.value);
    if (currentMatchIndex.value < roundMatches.length) {
      return roundMatches[currentMatchIndex.value];
    }
    return null;
  }

  Duration? get totalDuration {
    if (startedAt.value == null) return null;
    final end = completedAt.value ?? DateTime.now();
    return end.difference(startedAt.value!);
  }

  String get totalDurationFormatted {
    final d = totalDuration;
    if (d == null) return '--:--';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '${h}h${m}m';
    return '$m:$s';
  }

  int get completedMatchesCount =>
      matches.where((m) => m.isCompleted.value).length;

  int get totalMatchesCount => matches.length;

  double get progress {
    if (totalMatchesCount == 0) return 0;
    return completedMatchesCount / totalMatchesCount;
  }

  // ============================================
  // BRACKET GENERATION
  // ============================================
  void generateBracket() {
    matches.clear();
    int matchCounter = 0;

    // Shuffle players for random matchups
    final shuffled = List<PlayerModel>.from(players)..shuffle();

    // Pad with byes if not power of 2
    final powerOf2 = _nextPowerOfTwo(shuffled.length);
    while (shuffled.length < powerOf2) {
      // Will be byes (no player2)
      shuffled.add(_emptyPlayer(shuffled.length));
    }

    // ===== ROUND 1 =====
    final round1Matches = <TournamentMatch>[];
    for (int i = 0; i < shuffled.length; i += 2) {
      final match = TournamentMatch(
        matchId: matchCounter++,
        round: 1,
        positionInRound: i ~/ 2,
        player1: shuffled[i],
        player2: shuffled[i + 1].name.startsWith('__BYE__')
            ? null
            : shuffled[i + 1],
      );
      // Auto-advance for byes
      if (match.isBye) {
        match.markAsCompleted(match.player1.value!);
      }
      round1Matches.add(match);
      matches.add(match);
    }

    // ===== Subsequent rounds (empty matches) =====
    int currentPlayers = round1Matches.length;
    int round = 2;
    while (currentPlayers > 1) {
      final nextRoundMatches = (currentPlayers / 2).ceil();
      for (int i = 0; i < nextRoundMatches; i++) {
        matches.add(TournamentMatch(
          matchId: matchCounter++,
          round: round,
          positionInRound: i,
        ));
      }
      currentPlayers = nextRoundMatches;
      round++;
    }

    // ✅ Propagate byes automatically
    _propagateByes();

    // Skip auto-advanced bye matches to find first real match
    _advanceToNextPlayableMatch();
  }

  void _propagateByes() {
    for (int r = 1; r < totalRounds; r++) {
      final roundMatches = getMatchesForRound(r);
      for (int i = 0; i < roundMatches.length; i++) {
        final match = roundMatches[i];
        if (match.isCompleted.value && match.winner.value != null) {
          _placeWinnerInNextRound(match);
        }
      }
    }
  }

  void _advanceToNextPlayableMatch() {
    for (int r = 1; r <= totalRounds; r++) {
      final roundMatches = getMatchesForRound(r);
      for (int i = 0; i < roundMatches.length; i++) {
        final match = roundMatches[i];
        if (!match.isCompleted.value && match.isReady) {
          currentRound.value = r;
          currentMatchIndex.value = i;
          return;
        }
      }
    }
  }

  PlayerModel _emptyPlayer(int id) {
    return PlayerModel(id: -id, name: '__BYE__');
  }

  int _nextPowerOfTwo(int n) {
    int p = 1;
    while (p < n) p *= 2;
    return p;
  }

  // ============================================
  // ADVANCE WINNER
  // ============================================
  void advanceWinner(PlayerModel winnerPlayer,
      {int? winnerScore, int? loserScore}) {
    final match = currentMatch;
    if (match == null) return;

    final p1Score =
    winnerPlayer == match.player1.value ? winnerScore : loserScore;
    final p2Score =
    winnerPlayer == match.player2.value ? winnerScore : loserScore;

    match.markAsCompleted(winnerPlayer,
        p1Score: p1Score, p2Score: p2Score);

    // Place winner in next round
    _placeWinnerInNextRound(match);

    // Move to next match
    _moveToNextMatch();
  }

  void _placeWinnerInNextRound(TournamentMatch match) {
    if (match.round >= totalRounds) {
      // Final match → champion
      champion.value = match.winner.value;
      isCompleted.value = true;
      completedAt.value = DateTime.now();
      return;
    }

    final nextRoundMatches = getMatchesForRound(match.round + 1);
    final nextMatchPosition = match.positionInRound ~/ 2;

    if (nextMatchPosition >= nextRoundMatches.length) return;

    final nextMatch = nextRoundMatches[nextMatchPosition];

    // Place in player1 or player2 slot based on position
    if (match.positionInRound % 2 == 0) {
      nextMatch.player1.value = match.winner.value;
    } else {
      nextMatch.player2.value = match.winner.value;
    }
  }

  void _moveToNextMatch() {
    final roundMatches = getMatchesForRound(currentRound.value);

    // Find next non-completed match in current round
    for (int i = currentMatchIndex.value + 1; i < roundMatches.length; i++) {
      if (!roundMatches[i].isCompleted.value && roundMatches[i].isReady) {
        currentMatchIndex.value = i;
        return;
      }
    }

    // Round finished, move to next round
    if (currentRound.value < totalRounds) {
      currentRound.value++;
      currentMatchIndex.value = 0;
      // Find first ready match in new round
      final newRoundMatches = getMatchesForRound(currentRound.value);
      for (int i = 0; i < newRoundMatches.length; i++) {
        if (!newRoundMatches[i].isCompleted.value &&
            newRoundMatches[i].isReady) {
          currentMatchIndex.value = i;
          return;
        }
      }
    }
  }

  void start() {
    startedAt.value = DateTime.now();
  }
}