// triball_game_area/lib/features/tournament/tournament_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/controllers/config_listener_controller.dart';
import '../../core/controllers/websocket_controller.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/avatar_storage_service.dart';
import '../../core/services/game_settings_service.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/game_config_model.dart';
import '../../data/models/game_state_model.dart';
import '../../data/models/match_type_model.dart';
import '../../data/models/player_model.dart';
import '../../data/models/tournament_model.dart';
import '../../routes/app_routes.dart';

class TournamentController extends GetxController {
  // ============================================
  // DEPENDENCIES
  // ============================================
  final AudioService _audio = Get.find<AudioService>();
  final WebSocketController _ws = Get.find<WebSocketController>();
  final ConfigListenerController _listener =
  Get.find<ConfigListenerController>();
  final GameSettingsService _settings = Get.find<GameSettingsService>();
  final AvatarStorageService _avatars = Get.find<AvatarStorageService>();

  // ============================================
  // OBSERVABLES
  // ============================================
  final Rx<TournamentModel?> tournament = Rx<TournamentModel?>(null);
  final Rx<GameMode> selectedMode = GameMode.classic.obs;
  final RxBool waitingForMatch = false.obs;
  final Rx<GameConfig?> originalConfig = Rx<GameConfig?>(null);

  bool _expectingMatchResult = false;

  // ============================================
  // GETTERS
  // ============================================
  TournamentModel? get currentTournament => tournament.value;
  int get targetScore => selectedMode.value.targetScore;

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _setupFromArguments();
  }

  // ============================================
  // SETUP FROM CONFIG (reçue du Config Area)
  // ============================================
  void _setupFromArguments() {
    final args = Get.arguments;
    if (args is GameConfig) {
      originalConfig.value = args;
      selectedMode.value = args.mode;
      _generateBracket(args);
    }
  }

  void _generateBracket(GameConfig config) {
    final players = List.generate(
      config.playerCount,
          (i) => PlayerModel(id: i, name: config.playerNames[i]),
    );

    final t = TournamentModel(
      name: 'tournament_default_name'.tr,
      players: players,
    );

    t.generateBracket();
    t.start();
    tournament.value = t;

    _audio.playSfx(AssetPaths.audioCoinInsert);

    if (kDebugMode) {
      print('🏆 Tournament bracket generated:');
      print('   Players: ${config.playerCount}');
      print('   Mode: ${config.mode.key}');
      print('   Rounds: ${t.totalRounds}');
      print('   Matches: ${t.totalMatchesCount}');
    }

    // Notifie Config Area
    _sendTournamentStatus('bracket_ready');
  }

  // ============================================
  // START MATCH
  // ============================================
  void startCurrentMatch() {
    final t = tournament.value;
    if (t == null) return;

    final match = t.currentMatch;
    if (match == null || !match.isReady) return;

    _audio.playSfx(AssetPaths.audioCoinInsert);
    match.markAsStarted();
    _expectingMatchResult = true;
    waitingForMatch.value = true;

    final base = originalConfig.value;
    final config = GameConfig.tournament(
      mode: selectedMode.value,
      players: [
        match.player1.value!.name,
        match.player2.value!.name,
      ],
      overshootRule: base?.overshootRule ?? OvershootRule.refuse,
      ttsEnabled: base?.ttsEnabled ?? true,
      soundEnabled: base?.soundEnabled ?? true,
    ).copyWith(
      ballsPerTurn: base?.ballsPerTurn,
      turnDurationSeconds: base?.turnDurationSeconds,
      turnWarningSeconds: base?.turnWarningSeconds,
    );

    // Notifie Config Area
    _sendTournamentStatus('match_started');

    Get.toNamed(AppRoutes.game, arguments: config);
  }

  // ============================================
  // MATCH RESULT (appelé par GameController)
  // ============================================
  void onMatchResult({required PlayerModel winner}) {
    if (!_expectingMatchResult) return;
    _expectingMatchResult = false;

    final t = tournament.value;
    if (t == null) return;

    final match = t.currentMatch;
    if (match == null) return;

    final matchWinner = (winner.name == match.player1.value?.name)
        ? match.player1.value
        : match.player2.value;

    if (matchWinner != null) {
      t.advanceWinner(matchWinner);
      _audio.playSfx(AssetPaths.audioTurnChange);

      if (t.isCompleted.value) {
        _audio.playSfx(AssetPaths.audioVictory);
        _sendTournamentStatus('tournament_completed');
      } else {
        _sendTournamentStatus('match_completed');
      }
    }

    waitingForMatch.value = false;
    tournament.refresh();
  }

  // ============================================
  // STATUS TO CONFIG AREA
  // ============================================
  void _sendTournamentStatus(String state) {
    final t = tournament.value;
    if (t == null) return;

    _listener.sendStatusUpdate(
      state: state,
      currentPlayer: t.currentMatch?.player1.value?.name,
      scores: {},
      elapsedSeconds: 0,
      winner: t.champion.value?.name,
      currentTurn: t.currentRound.value,
    );
  }

  // ============================================
  // BACK TO WAITING
  // ============================================
  void backToWaiting() {
    final t = tournament.value;
    // Cette sortie normale n'est autorisée qu'une fois la finale terminée.
    if (t == null || !t.isCompleted.value) return;

    _audio.playSfx(AssetPaths.audioButtonPress);
    _ws.stopGame();
    _avatars.clearCurrentGameAvatars();
    _ws.sendClearAvatars();
    _listener.sendStatusUpdate(
      state: 'waiting',
      scores: const {},
      elapsedSeconds: 0,
      winner: t.champion.value?.name,
      currentTurn: t.totalRounds,
    );
    Get.offAllNamed(AppRoutes.waiting);
  }

  // ============================================
  // HELPERS
  // ============================================
  Color playerColor(int playerId) {
    return Helpers.playerColor(playerId);
  }
}