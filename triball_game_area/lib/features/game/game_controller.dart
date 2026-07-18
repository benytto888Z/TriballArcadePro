// triball_game_area/lib/features/game/game_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/game_constants.dart';
import '../../core/controllers/config_listener_controller.dart';
import '../../core/controllers/platform_event_bus.dart';
import '../../core/controllers/websocket_controller.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/avatar_storage_service.dart';
import '../../core/services/game_settings_service.dart';
import '../../core/services/tts_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/game_time_formatter.dart';
import '../../data/models/combo_model.dart';
import '../../data/models/game_config_model.dart';
import '../../data/models/game_state_model.dart';
import '../../data/models/match_type_model.dart';
import '../../data/models/platform_error_model.dart';
import '../../data/models/player_model.dart';
import '../../data/models/score_event_model.dart';
import '../../data/models/stop_game_command_model.dart';
import '../../data/repositories/game_repository.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../routes/app_routes.dart';
import '../tournament/tournament_controller.dart';
import '../waiting/waiting_controller.dart';

class GameController extends GetxController {
  // ============================================
  // DEPENDENCIES
  // ============================================
  final WebSocketController _ws = Get.find<WebSocketController>();
  final AudioService _audio = Get.find<AudioService>();
  final TtsService _tts = Get.find<TtsService>();
  final StorageService _storage = Get.find<StorageService>();
  final GameSettingsService _settings = Get.find<GameSettingsService>();
  final ConfigListenerController _listener =
  Get.find<ConfigListenerController>();
  final GameRepository _repo = GameRepository();
  late final LeaderboardRepository _leaderboardRepo;
  late final AvatarStorageService _avatarStorage;

  // ============================================
  // BUS SUBSCRIPTIONS
  // ============================================
  StreamSubscription<ScoreEventModel>? _detectionSub;
  StreamSubscription<PlatformErrorModel>? _errorSub;
  StreamSubscription<StopGameCommand>? _stopSub;

  StreamSubscription<void>? _remotePauseSub;
  StreamSubscription<void>? _remoteResumeSub;

  // ============================================
  // OBSERVABLE STATE (identique Family)
  // ============================================
  final Rx<GamePhase> phase = GamePhase.idle.obs;
  final RxList<PlayerModel> players = <PlayerModel>[].obs;
  final RxInt currentPlayerIndex = 0.obs;
  final RxInt countdownValue = 3.obs;
  final RxInt elapsedSeconds = 0.obs;
  final Rx<DateTime?> gameStartTime = Rx<DateTime?>(null);
  final Rx<DateTime?> gameEndTime = Rx<DateTime?>(null);
  final Rx<ScoreEventModel?> lastEvent = Rx<ScoreEventModel?>(null);
  final Rx<ScoreApplyResult?> lastResult = Rx<ScoreApplyResult?>(null);
  final Rx<PlayerModel?> winner = Rx<PlayerModel?>(null);
  final RxBool isNewRecord = false.obs;
  final RxInt newRecordRank = 0.obs;
  final RxInt comboCount = 0.obs;

  final Rx<ComboModel?> currentCombo = Rx<ComboModel?>(null);
  final RxBool showComboBanner = false.obs;
  Timer? _comboBannerTimer;

  final RxInt turnRemainingSeconds = 0.obs;
  final RxBool isTurnWarning = false.obs;
  Timer? _turnTimer;

  final RxBool bonusTurnActive = false.obs;
  final Set<int> _countdownPlayed = {};
  final RxBool showTurnTransitionCountdown = false.obs;
  Timer? _transitionTimer;
  final RxBool showControls = false.obs;
  final RxBool showScoreViewingPause = false.obs;
  final RxInt scoreViewingRemainingSeconds = 0.obs;
  Timer? _scoreViewingTimer;
  Timer? _comboTriplePauseTimer;

  final RxInt victorySnapshotSeconds = 0.obs;
  final Rx<Duration?> victoryExactDuration = Rx<Duration?>(null);
  // ✅ NEW : Flag anti-double sauvegarde
  bool _leaderboardSaved = false;

  // ✅ NEW : Timer de retour au WaitingScreen après victoire
  Timer? _returnToWaitingTimer;
  final RxInt returnToWaitingCountdown = 0.obs;

  // ✅ NEW : Status update timer (envoie au Config Area)
  Timer? _statusUpdateTimer;

  // ============================================
  // INTERNAL
  // ============================================
  late GameConfig config;
  Timer? _gameTimer;
  Timer? _countdownTimer;
  Timer? _eventCooldownTimer;
  bool _processingEvent = false;
  DateTime _lastEventTime = DateTime.fromMillisecondsSinceEpoch(0);

  // ============================================
  // GETTERS (identiques Family)
  // ============================================
  PlayerModel? get currentPlayer =>
      players.isNotEmpty && currentPlayerIndex.value < players.length
          ? players[currentPlayerIndex.value]
          : null;

  PlayerModel? get nextPlayerPreview {
    if (players.isEmpty) return null;
    final nextIdx =
    _repo.nextPlayerIndex(currentPlayerIndex.value, players.length);
    return players[nextIdx];
  }

  int get targetScore => config.targetScore;
  int get turnDuration => config.turnDurationSeconds;
  MatchType get matchType => config.matchType;
  GameMode get gameMode => config.mode;

  bool get isCompetition => matchType == MatchType.competition;
  bool get isSoloChrono => matchType == MatchType.soloChrono;
  bool get isTournament => matchType == MatchType.tournament;
  bool get isComboMode => gameMode == GameMode.combo;
  bool get isPlaying => phase.value == GamePhase.playing;
  bool get isPaused => phase.value == GamePhase.paused;
  bool get isCountdown => phase.value == GamePhase.countdown;
  bool get isVictory => phase.value == GamePhase.victory;
  bool get isTransition => phase.value == GamePhase.turnTransition;
  bool get isGameOver =>
      phase.value == GamePhase.victory || phase.value == GamePhase.gameOver;
  bool get isSoloMode => config.isSolo;
  bool get isMultiMode => config.isMulti;
  bool get savesToLeaderboard => config.savesToLeaderboard;

  double get turnProgress {
    if (turnDuration == 0) return 0;
    return 1.0 - (turnRemainingSeconds.value / turnDuration);
  }

  Duration get elapsedDuration =>
      Duration(seconds: elapsedSeconds.value);

  String get elapsedFormatted => GameTimeFormatter.mmSs(elapsedDuration);

  /// Strictement le même mm:ss que celui figé depuis GameScreen.
  String get victoryTimeFormatted => GameTimeFormatter.mmSs(
    Duration(seconds: victorySnapshotSeconds.value),
  );

  /// VictoryDialog reste en mm:ss. Les centièmes sont réservés au podium
  /// et aux lignes du classement.
  String get victoryTimeDetailed => victoryTimeFormatted;

  Duration get victoryExactDurationOrZero {
    return victoryExactDuration.value ??
        Duration(seconds: victorySnapshotSeconds.value);
  }

  /// ✅ Ces getters sont les SEULS à utiliser dans VictoryDialog
  String get finalElapsedFormatted => victoryTimeFormatted;
  String get elapsedFormattedDetailed => victoryTimeDetailed;

  // ============================================
  // CONTROLS
  // ============================================
  void toggleControls() => showControls.value = !showControls.value;
  void hideControls() => showControls.value = false;

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _leaderboardRepo = LeaderboardRepository();
    _avatarStorage = Get.find<AvatarStorageService>();
    _setupArgs();
    _setupBusListeners();
    _setupStopListener();
  }

  @override
  void onReady() {
    super.onReady();
    // ✅ Notifie Config Area : countdown
    _sendStatusToConfigArea('countdown');
    _startCountdown();
  }

  @override
  void onClose() {
    _detectionSub?.cancel();
    _errorSub?.cancel();
    _stopSub?.cancel();
    _remotePauseSub?.cancel();    // ✅ NEW
    _remoteResumeSub?.cancel();   // ✅ NEW
    _statusUpdateTimer?.cancel();
    _returnToWaitingTimer?.cancel();
    _cleanup();
    super.onClose();
  }

  void _cleanup() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    _eventCooldownTimer?.cancel();
    _turnTimer?.cancel();
    _comboBannerTimer?.cancel();
    _transitionTimer?.cancel();
    _scoreViewingTimer?.cancel();
    _comboTriplePauseTimer?.cancel();
    _statusUpdateTimer?.cancel();
    _returnToWaitingTimer?.cancel();
    // Ne pas envoyer stop_game ici : _cleanup() est aussi appelé par onClose
    // après une navigation, ce qui provoquait un second stop_game.
  }

  // ============================================
  // SETUP
  // ============================================
  void _setupArgs() {
    final args = Get.arguments;
    if (args is GameConfig) {
      config = args.copyWith(
        turnDurationSeconds: _settings.turnDurationSeconds.value,
        turnWarningSeconds: _settings.turnWarningSeconds.value,
      );
    } else {
      config = GameConfig.competition(
        mode: GameMode.classic,
        players: const ['Player 1', 'Player 2'],
      ).copyWith(
        turnDurationSeconds: _settings.turnDurationSeconds.value,
        turnWarningSeconds: _settings.turnWarningSeconds.value,
      );
    }

    players.value = _repo.createPlayers(config.playerNames);
    currentPlayerIndex.value = 0;

    if (kDebugMode) {
      print('🎮 Game initialized (GAME AREA):');
      print('   matchType=${config.matchType.key}');
      print('   mode=${config.mode.key}');
      print('   players=${config.playerCount}');
      print('   target=${config.targetScore}');
    }
  }

  void _setupBusListeners() {
    _detectionSub =
        PlatformEventBus.instance.onDetection.listen(_onDetection);

    _errorSub = PlatformEventBus.instance.onError.listen((err) {
      if (kDebugMode) print('🎮 Platform error: $err');
    });

    // ✅ NEW : Pause/Resume à distance
    _remotePauseSub = PlatformEventBus.instance.onRemotePause.listen((_) {
      if (kDebugMode) print('⏸ Remote pause received → pausing game');
      if (isPlaying) pauseGame();
    });

    _remoteResumeSub = PlatformEventBus.instance.onRemoteResume.listen((_) {
      if (kDebugMode) print('▶ Remote resume received → resuming game');
      if (isPaused) resumeGame();
    });
  }

  /// ✅ Écoute les commandes stop depuis Config Area
  void _setupStopListener() {
    _stopSub = _listener.onStopReceived.listen((cmd) {
      if (kDebugMode) print('🛑 Stop game received from Config Area');
      if (isPlaying || isPaused || isCountdown) {
        _returnToWaiting(reason: 'remote_stop');
      }
    });
  }

  // ============================================
  // ✅ STATUS UPDATES TO CONFIG AREA
  // ============================================
  void _startStatusUpdates() {
    _statusUpdateTimer?.cancel();
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (isPlaying || isPaused) {
        _sendStatusToConfigArea(isPlaying ? 'playing' : 'paused');
      }
    });
  }

  void _stopStatusUpdates() {
    _statusUpdateTimer?.cancel();
    _statusUpdateTimer = null;
  }

  void _sendStatusToConfigArea(String state) {
    final scores = <String, int>{};
    for (final p in players) {
      scores[p.name] = p.score.value;
    }

    _listener.sendStatusUpdate(
      state: state,
      currentPlayer: currentPlayer?.name,
      scores: scores,
      elapsedSeconds: elapsedSeconds.value,
      winner: winner.value?.name,
      currentTurn: currentPlayer?.turnsPlayed.value,
    );
  }

  // ============================================
  // COUNTDOWN
  // ============================================
  void _startCountdown() {
    phase.value = GamePhase.countdown;
    countdownValue.value = 3;
    _ttsSpeak('tts_countdown_for_player', params: {
      'name': currentPlayer?.name ?? '',
    });
    _playSfx(AssetPaths.audioCountdown);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdownValue.value--;
      if (countdownValue.value <= 0) {
        timer.cancel();
        _ttsSpeak('tts_go');
        _startGame();
      } else if (countdownValue.value == 2) {
        _ttsSpeak('tts_countdown_2');
        _playSfx(AssetPaths.audioCountdown);
      } else if (countdownValue.value == 1) {
        _ttsSpeak('tts_countdown_1');
        _playSfx(AssetPaths.audioCountdown);
      }
    });
  }

  // ============================================
  // GAME START
  // ============================================
  void _startGame() {
    phase.value = GamePhase.playing;
    gameStartTime.value = DateTime.now();
    elapsedSeconds.value = 0;

    if (players.isNotEmpty) {
      players[0].isActive.value = true;
      players[0].startTime.value = DateTime.now();
      players[0].resetForNewTurn();
    }

    _ws.startGame();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isPlaying) elapsedSeconds.value++;
    });

    _startTurnTimer();
    _startStatusUpdates();
    _playBgm();

    // ✅ Notifie Config Area
    _sendStatusToConfigArea('playing');

    if (kDebugMode) print('🎮 Game STARTED');
  }

  // ============================================
  // TURN TIMER (identique Family)
  // ============================================
  void _startTurnTimer() {
    _turnTimer?.cancel();
    turnRemainingSeconds.value = config.turnDurationSeconds;
    isTurnWarning.value = false;
    bonusTurnActive.value = false;
    _countdownPlayed.clear();

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPlaying) return;
      turnRemainingSeconds.value--;
      final remaining = turnRemainingSeconds.value;

      if (remaining == config.turnWarningSeconds) {
        isTurnWarning.value = true;
        _playSfx(AssetPaths.audioCountdown);
        _ttsSpeak('tts_hurry_up');
      }
      if (remaining > 0 && remaining <= config.turnWarningSeconds) {
        if (!_countdownPlayed.contains(remaining)) {
          _countdownPlayed.add(remaining);
          if (remaining <= 3) {
            _ttsSpeak('tts_countdown_$remaining');
          } else {
            _playSfx(AssetPaths.audioCountdown);
          }
        }
      }
      if (remaining <= 0) {
        timer.cancel();
        _autoSwitchToNextPlayer(reason: 'timeout');
      }
    });
  }

  void _stopTurnTimer() {
    _turnTimer?.cancel();
    _turnTimer = null;
    turnRemainingSeconds.value = 0;
    isTurnWarning.value = false;
    _countdownPlayed.clear();
  }

  void _resetTurnTimer() => _startTurnTimer();

  void _grantBonusTurn() {
    _turnTimer?.cancel();
    turnRemainingSeconds.value = config.turnDurationSeconds;
    isTurnWarning.value = false;
    bonusTurnActive.value = true;
    _countdownPlayed.clear();

    final player = currentPlayer;
    if (player != null) {
      player.resetForBonusTurn();
    }

    _ttsSpeak('bonus_turn_granted');
    _playSfx(AssetPaths.audioCombo);
    _startTurnTimer();

    Timer(const Duration(milliseconds: 2500), () {
      if (isPlaying) bonusTurnActive.value = false;
    });
  }

  // ============================================
  // AUTO-SWITCH + SCORE VIEWING PAUSE
  // ============================================
  void _autoSwitchToNextPlayer({
    required String reason,
    Duration scoreOverlayDelay = Duration.zero,
  }) {
    if (!isPlaying) return;

    // Bloquer immédiatement le tour et les capteurs : aucune balle
    // supplémentaire ne doit être comptée pendant le feedback TRIPLE.
    _stopTurnTimer();
    _ws.stopGame();
    phase.value = GamePhase.turnTransition;
    currentPlayer?.incrementTurn();

    _comboTriplePauseTimer?.cancel();
    if (scoreOverlayDelay > Duration.zero) {
      if (kDebugMode) {
        print('🔥 TRIPLE pause: ${scoreOverlayDelay.inSeconds}s before score overlay');
      }
      _comboTriplePauseTimer = Timer(scoreOverlayDelay, () {
        _comboTriplePauseTimer = null;
        if (phase.value == GamePhase.turnTransition) {
          _startScoreViewingPause();
        }
      });
    } else {
      _startScoreViewingPause();
    }
  }

  void _startScoreViewingPause() {
    showScoreViewingPause.value = true;
    scoreViewingRemainingSeconds.value =
        GameConstants.scoreViewingPauseSeconds;

    _scoreViewingTimer?.cancel();
    _scoreViewingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      scoreViewingRemainingSeconds.value--;
      if (scoreViewingRemainingSeconds.value <= 0) {
        timer.cancel();
        showScoreViewingPause.value = false;
        _startTurnTransitionCountdown();
      }
    });
  }

  void _startTurnTransitionCountdown() {
    showTurnTransitionCountdown.value = true;
    countdownValue.value = _settings.transitionDelaySeconds.value;

    if (isSoloChrono) {
      _ttsSpeak('tts_new_turn_solo', params: {
        'name': currentPlayer?.name ?? '',
      });
    } else {
      _ttsSpeak('tts_player_turn_simple', params: {
        'name': nextPlayerPreview?.name ?? '',
      });
    }

    _transitionTimer?.cancel();
    _transitionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdownValue.value--;
      if (countdownValue.value > 0 && countdownValue.value <= 3) {
        _playSfx(AssetPaths.audioCountdown);
      }
      if (countdownValue.value <= 0) {
        timer.cancel();
        showTurnTransitionCountdown.value = false;
        _performPlayerSwitch();
      }
    });
  }

  void _performPlayerSwitch() {
    if (players.isEmpty) return;

    if (isSoloChrono) {
      currentPlayer?.resetForNewTurn();
    } else {
      currentPlayer?.isActive.value = false;
      currentPlayer?.resetForNewTurn();
      currentPlayerIndex.value =
          _repo.nextPlayerIndex(currentPlayerIndex.value, players.length);
      currentPlayer?.isActive.value = true;
      currentPlayer?.resetForNewTurn();
    }

    currentCombo.value = null;
    comboCount.value = 0;
    showComboBanner.value = false;
    bonusTurnActive.value = false;
    _comboBannerTimer?.cancel();

    _playSfx(AssetPaths.audioTurnChange);
    phase.value = GamePhase.playing;
    _ws.startGame();
    _resetTurnTimer();

    // ✅ Notifie Config Area du changement
    _sendStatusToConfigArea('playing');
  }

  // ============================================
  // DETECTION HANDLING (identique Family)
  // ============================================
  void _onDetection(ScoreEventModel event) {
    if (!isPlaying) return;

    final now = DateTime.now();
    if (now.difference(_lastEventTime).inMilliseconds <
        GameConstants.detectionCooldown) return;
    if (_processingEvent) return;
    _processingEvent = true;
    _lastEventTime = now;

    try {
      final player = currentPlayer;
      if (player == null) return;

      final result = _repo.applyScore(
        currentScore: player.score.value,
        event: event,
        config: config,
        recentEvents: player.recentEvents.toList(),
        currentStreak: player.currentStreak.value,
      );

      lastEvent.value = event;
      lastResult.value = result;
      player.registerShot(event: event, applied: result.applied);

      if (result.hasCombo) {
        final combo = result.combo!;
        currentCombo.value = combo;
        comboCount.value = combo.count;
        player.registerCombo(combo.count);

        if (isComboMode) {
          _showComboBanner(combo);
          _playComboFeedback(combo);
        }
        if (combo.grantsBonusTurn) {
          Timer(const Duration(milliseconds: 1500), () {
            if (isPlaying) _grantBonusTurn();
          });
        }
      } else {
        currentCombo.value = null;
        comboCount.value = 0;
      }

      if (result.applied) {
        player.score.value = result.newScore;
        player.addScoreEntry(event.hole, result.delta, event.effect);
      }
      player.incrementBallsThisTurn();

      _playScoreFeedback(event, result);

      if (result.isVictory) {
        _onVictory(player);
        return;
      }

      if (result.isOvershoot) {
        if (config.mode == GameMode.hardcore) {
          final overshootBy = player.score.value - config.targetScore;
          _ttsSpeak('tts_hardcore_overshoot', params: {
            'points': '$overshootBy',
          });
        } else {
          _ttsSpeak('tts_overshoot');
        }
      }

      final hasBonusTurn = result.hasCombo &&
          result.combo!.grantsBonusTurn;

      if (!hasBonusTurn &&
          player.ballsThrownThisTurn.value >= config.ballsPerTurn) {
        final isTripleCombo = isComboMode &&
            result.combo?.type == ComboType.tripleCombo;

        _autoSwitchToNextPlayer(
          reason: '${config.ballsPerTurn} balls played',
          scoreOverlayDelay: isTripleCombo
              ? const Duration(
                  seconds: GameConstants
                      .comboTriplePauseBeforeScoreOverlaySeconds,
                )
              : Duration.zero,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Detection error: $e');
    } finally {
      _eventCooldownTimer?.cancel();
      _eventCooldownTimer = Timer(
        Duration(milliseconds: GameConstants.detectionCooldown),
            () => _processingEvent = false,
      );
    }
  }

  void _playScoreFeedback(ScoreEventModel event, ScoreApplyResult result) {
    if (event.isX0) {
      _playSfx(AssetPaths.audioScoreX0);
      _ttsSpeak('tts_zero');
    } else if (event.isX2) {
      _playSfx(AssetPaths.audioScoreX2);
      _ttsSpeak('tts_double');
    } else if (event.value == 30) {
      _playSfx(AssetPaths.audioScorePlus30);
      _ttsSpeak('tts_jackpot');
    } else if (event.value == 10) {
      _playSfx(AssetPaths.audioScorePlus10);
    } else if (event.value == 5) {
      _playSfx(AssetPaths.audioScorePlus5);
    } else if (event.value == -10) {
      _playSfx(AssetPaths.audioScoreMinus10);
    } else if (event.value == -5) {
      _playSfx(AssetPaths.audioScoreMinus5);
    } else if (event.isPositive) {
      _playSfx(AssetPaths.audioScorePositive);
    } else if (event.isNegative) {
      _playSfx(AssetPaths.audioScoreNegative);
    }
  }

  void _showComboBanner(ComboModel combo) {
    showComboBanner.value = true;
    _comboBannerTimer?.cancel();
    _comboBannerTimer = Timer(const Duration(milliseconds: 2500), () {
      showComboBanner.value = false;
    });
  }

  void _playComboFeedback(ComboModel combo) {
    _playSfx(AssetPaths.audioCombo);
    _ttsSpeak(combo.type.translationKey);
  }

  // ============================================
  // ✅ VICTORY → Retour au WaitingScreen après 10s
  // ============================================
  void _onVictory(PlayerModel player) {
    // ✅ CRUCIAL : Capturer le temps AVANT tout
    victorySnapshotSeconds.value = elapsedSeconds.value;

    final preciseMeasurement = gameStartTime.value == null
        ? Duration(seconds: elapsedSeconds.value)
        : DateTime.now().difference(gameStartTime.value!);

    // Les secondes officielles viennent du compteur visible. On conserve
    // uniquement les centièmes de la mesure précise pour le classement.
    // Ainsi 02:42 à l'écran devient par exemple 02:42.88, jamais 03:22.88.
    victoryExactDuration.value = GameTimeFormatter.officialDuration(
      displayedSeconds: victorySnapshotSeconds.value,
      preciseMeasurement: preciseMeasurement,
    );

    // ✅ STOPPER LE TIMER IMMÉDIATEMENT (avant toute autre opération)
    _gameTimer?.cancel();
    _gameTimer = null;

    phase.value = GamePhase.victory;
    winner.value = player;
    gameEndTime.value = DateTime.now();
    player.endTime.value = gameEndTime.value;
    player.officialElapsedDuration.value = victoryExactDuration.value;
    _stopTurnTimer();
    _stopStatusUpdates();
    _ws.stopGame();

    _playSfx(AssetPaths.audioVictory);
    _ttsSpeak('tts_victory_simple', params: {'name': player.name});

    _sendStatusToConfigArea('victory');

    // ✅ Reset le flag anti-double
    _leaderboardSaved = false;

    // ✅ Sauvegarde UNE SEULE FOIS
    if (savesToLeaderboard && !_leaderboardSaved) {
      _leaderboardSaved = true;
      _saveToLeaderboard(player);
    }

    _startReturnToWaitingTimer();

    if (kDebugMode) {
      print('🏆 VICTORY:');
      print('   Player: ${player.name}');
      print('   elapsedSeconds: ${elapsedSeconds.value}');
      print('   victorySnapshotSeconds: ${victorySnapshotSeconds.value}');
      print('   victoryExactDuration: ${victoryExactDuration.value}');
      print('   leaderboardSaved: $_leaderboardSaved');
    }
  }


  // ============================================
  // ✅ RETURN TO WAITING TIMER — Ne re-sauvegarde PAS
  // ============================================
  void _startReturnToWaitingTimer() {
    returnToWaitingCountdown.value =
        GameConstants.victoryDialogDisplaySeconds;

    _returnToWaitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      returnToWaitingCountdown.value--;
      if (returnToWaitingCountdown.value <= 0) {
        timer.cancel();
        // ✅ NE PAS re-sauvegarder ici, juste naviguer
        if (savesToLeaderboard) {
          _goToLeaderboardAfterVictory();
        } else {
          _returnToWaiting(reason: 'victory_timeout');
        }
      }
    });
  }

  /// ✅ Après victoire solo → affiche le leaderboard du mode joué

  // ============================================
  // ✅ GO TO LEADERBOARD — NE re-sauvegarde PAS
  // ============================================
  void _goToLeaderboardAfterVictory() {
    _cleanup();
    _audio.stopBgm();

    try {
      final waitingCtrl = Get.find<WaitingController>();
      if (winner.value != null) {
        waitingCtrl.setLastWinner(
          winner.value!.name,
          config.mode.translationKey.tr,
        );
      }
    } catch (_) {}

    _avatarStorage.clearCurrentGameAvatars();
    _ws.sendClearAvatars();
    _sendStatusToConfigArea('leaderboard');

    // ✅ JUSTE naviguer, PAS de _saveToLeaderboard ici
    Get.offAllNamed(
      AppRoutes.leaderboard,
      arguments: {
        'mode': config.mode,
        'autoReturn': true,
      },
    );
  }

  /// ✅ Retour au WaitingScreen
  // ============================================
  //_returnToWaiting — Nettoyer les avatars
  // ============================================
  void _returnToWaiting({required String reason}) {
    if (kDebugMode) print('🔙 Returning to WaitingScreen ($reason)');

    _ws.stopGame();
    _cleanup();
    _audio.stopBgm();

    // Notifie le WaitingController du dernier gagnant
    try {
      final waitingCtrl = Get.find<WaitingController>();
      if (winner.value != null) {
        waitingCtrl.setLastWinner(
          winner.value!.name,
          config.mode.translationKey.tr,
        );
      }
    } catch (_) {}

    // ✅ Nettoyer les avatars temporaires
    _avatarStorage.clearCurrentGameAvatars();

    // ✅ Demander au Config Area de nettoyer ses photos aussi
    _ws.sendClearAvatars();

    _sendStatusToConfigArea('waiting');

    Get.offAllNamed(AppRoutes.waiting);
  }




// ============================================
  // ✅ SAVE TO LEADERBOARD — Version anti-double
  // ============================================
  Future<void> _saveToLeaderboard(PlayerModel player) async {
    // ✅ Double check anti-double
    if (!_leaderboardSaved) {
      if (kDebugMode) print('❌ _saveToLeaderboard called but flag is false');
      return;
    }

    // ✅ Utilise le snapshot (pas un recalcul)
    final timeMs = victoryExactDuration.value?.inMilliseconds ??
        (victorySnapshotSeconds.value * 1000);

    if (kDebugMode) {
      print('════════════════════════════════════════');
      print('🏆 SAVE TO LEADERBOARD (ONCE)');
      print('   Player: ${player.name}');
      print('   TimeMs: $timeMs');
      print('   SnapshotSeconds: ${victorySnapshotSeconds.value}');
      print('   Balls: ${player.ballsThrown.value}');
      print('   Mode: ${config.mode.key}');
      print('   WS connected: ${_ws.isConnected}');
      print('════════════════════════════════════════');
    }

    if (timeMs <= 0) {
      if (kDebugMode) print('❌ Cannot save: timeMs is 0');
      return;
    }

    if (!_ws.isConnected) {
      if (kDebugMode) print('❌ Cannot save: not connected');
      return;
    }

    // ✅ ENVOI UNIQUE
    _ws.submitScore(
      mode: config.mode,
      playerName: player.name,
      timeMs: timeMs,
      balls: player.ballsThrown.value,
      date: DateTime.now(),
    );

    if (kDebugMode) print('📤 Score submitted ONCE to ESP32');

    await _storage.addRecentPlayerName(player.name);

    // Sauvegarder complètement l'avatar avant d'ouvrir le LeaderboardScreen.
    await _saveWinnerAvatarForTop10(player);

    // Attendre le broadcast auto
    await Future.delayed(const Duration(milliseconds: 2000));

    // Vérifier le classement (sans re-submit)
    try {
      final entries = await _leaderboardRepo.fetchLeaderboard(
        config.mode,
        forceRefresh: true,
      );

      if (entries.isNotEmpty) {
        final idx = entries.indexWhere(
              (e) => e.playerName == player.name &&
              (e.completionTime.inMilliseconds - timeMs).abs() < 500,
        );
        if (idx >= 0) {
          isNewRecord.value = true;
          newRecordRank.value = idx + 1;
          _ttsSpeak('tts_new_record');
          if (kDebugMode) print('🏅 NEW RECORD! Rank #${idx + 1}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Fetch leaderboard error: $e');
    }
  }

  /// ✅ Sauvegarde l'avatar du gagnant pour persistance top 10
  Future<void> _saveWinnerAvatarForTop10(PlayerModel player) async {
    try {
      final bytes = _avatarStorage.getCachedBytes(player.name);
      if (bytes != null) {
        await _avatarStorage.saveTop10Avatar(
          gameMode: config.mode.key,
          playerName: player.name,
          bytes: bytes,
        );
      } else if (kDebugMode) {
        print('📸 No downloaded avatar to persist for ${player.name}');
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Save avatar error: $e');
    }
  }
  // ============================================
  // CONTROL ACTIONS
  // ============================================
  void nextPlayer() {
    if (!isPlaying) return;
    _autoSwitchToNextPlayer(reason: 'manual');
  }

  void pauseGame() {
    if (!isPlaying) return;
    phase.value = GamePhase.paused;
    _gameTimer?.cancel();
    _turnTimer?.cancel();
    _audio.pauseBgm();
    _ws.stopGame();
    _sendStatusToConfigArea('paused');
  }

  void resumeGame() {
    if (!isPaused) return;
    phase.value = GamePhase.playing;
    _audio.resumeBgm();
    _ws.startGame();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });

    if (turnRemainingSeconds.value > 0) {
      _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!isPlaying) return;
        turnRemainingSeconds.value--;
        if (turnRemainingSeconds.value <= 0) {
          timer.cancel();
          _autoSwitchToNextPlayer(reason: 'timeout');
        }
      });
    }

    _sendStatusToConfigArea('playing');
  }

  void restartGame() {
    _cleanup();
    elapsedSeconds.value = 0;
    gameStartTime.value = null;
    gameEndTime.value = null;
    winner.value = null;
    isNewRecord.value = false;
    newRecordRank.value = 0;
    lastEvent.value = null;
    lastResult.value = null;
    // ✅ Reset le flag anti-double
    _leaderboardSaved = false;
    comboCount.value = 0;
    currentCombo.value = null;
    showComboBanner.value = false;
    bonusTurnActive.value = false;
    showTurnTransitionCountdown.value = false;
    showScoreViewingPause.value = false;
    victorySnapshotSeconds.value = 0;
    victoryExactDuration.value = null;
    returnToWaitingCountdown.value = 0;

    for (final p in players) {
      p.reset();
    }
    currentPlayerIndex.value = 0;
    _ws.resetGame();
    _sendStatusToConfigArea('countdown');
    _startCountdown();
  }

  void quitGame() {
    _returnToWaiting(reason: 'manual_quit');
  }

  void goToLeaderboard() {
    _ws.stopGame();
    _cleanup();
    _audio.stopBgm();
    Get.offAllNamed(AppRoutes.leaderboard);
  }

  // ============================================
  // LED CONTROL
  // ============================================
  void highlightHole(int holeIndex, {int r = 0, int g = 255, int b = 0}) {
    _ws.setLed(holeIndex, r, g, b);
  }

  void clearAllLeds() {
    for (int i = 0; i < 9; i++) _ws.setLed(i, 0, 0, 0);
  }

  // ============================================
  // HELPERS
  // ============================================
  void _playSfx(String path) {
    if (config.soundEnabled) _audio.playSfx(path);
  }

  void _playBgm() {
    if (config.soundEnabled) _audio.playBgm(AssetPaths.audioBgmNeon);
  }

  void _ttsSpeak(String key, {Map<String, String>? params}) {
    if (!config.ttsEnabled) return;
    String text = key.tr;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }
    _tts.speak(text);
  }

  void debugSimulateDetection({
    required String hole,
    required int value,
    required String effect,
  }) {
    _onDetection(ScoreEventModel(
      hole: hole,
      value: value,
      effect: effect,
      sensor: 0,
      distance: 25,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}