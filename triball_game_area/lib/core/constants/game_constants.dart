// lib/core/constants/game_constants.dart

import 'package:flutter/material.dart';

class GameConstants {

  // ==========================================
  // ✅ NEW : REMOTE THEME + LANGUAGE SYNC
  // ==========================================
  static const String msgTypeChangeTheme    = 'change_theme';
  static const String msgTypeChangeLanguage = 'change_language';

  // ==========================================
  // ✅ NEW : PLAYER AVATAR
  // ==========================================
  static const String msgTypePlayerAvatar = 'player_avatar';
  static const String msgTypeClearAvatars  = 'clear_avatars';

  /// Taille max de l'avatar en pixels (sera redimensionné)
  static const int avatarMaxSize = 150;

  /// Qualité JPEG (0-100)
  static const int avatarJpegQuality = 60;

  // ==========================================
  // ✅ NEW : REMOTE GAME CONTROL COMMANDS
  // ==========================================
  static const String msgTypeRemotePause  = 'remote_pause';
  static const String msgTypeRemoteResume = 'remote_resume';

  // ==========================================
  // ✅ ADMIN CODE
  // ==========================================
  static const String adminCode = '1234';

  // ==========================================
  // ✅ PLAYER NAME
  // ==========================================
  static const int playerNameMaxLength = 8;
  // ==========================================
  // ✅ NEW : FONT FAMILY pour tout le GameScreen
  // ==========================================
  static const String gameFontFamily = 'Rajdhani';

  // ==========================================
  // ✅ NEW : ESP32 LEADERBOARD MESSAGE TYPES
  // ==========================================
  static const String msgTypeLbSubmit    = 'leaderboard_submit';
  static const String msgTypeLbGet       = 'leaderboard_get';
  static const String msgTypeLbClear     = 'leaderboard_clear';
  static const String msgTypeLbClearAll  = 'leaderboard_clear_all';
  static const String msgTypeLbData      = 'leaderboard_data';
  static const String msgTypeAck         = 'ack';

  // ==========================================
  // ✅ NEW : LEADERBOARD DISPLAY AFTER VICTORY
  // ==========================================
  static const int defaultLeaderboardDisplaySeconds = 30;

  // ==========================================
  // ✅ NEW : HARDCORE MODE OVERSHOOT
  // ==========================================
  /// Score maximum atteignable en mode HARDCORE (dépassement autorisé)
  /// Au-delà, le score est plafonné.
  static const int hardcoreMaxScore = 200;

  // ✅ Helpers pour les styles de texte du game
  static TextStyle gameTextStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double letterSpacing = 0.5,
    double? height,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: gameFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      shadows: shadows,
    );
  }
  // ==========================================
  // GAME RULES
  // ==========================================
  static const int targetScore = 100;
  static const int maxPlayers = 6;
  static const int minPlayers = 1;
  static const int ballsPerTurn = 3;

  // ==========================================
  // ✅ TURN MANAGEMENT (NOUVEAU)
  // ==========================================
  static const int turnDurationSeconds = 30;     // Durée d'un tour
  static const int turnWarningSeconds = 10;      // Warning à 10s restantes
  static const int turnTransitionMs = 1800;      // Pause entre 2 tours

  // ✅ NEW : Pause après le tour pour visualiser le score
  static const int scoreViewingPauseSeconds = 5;

  /// En mode Combo, laisse le feedback TRIPLE visible avant le récapitulatif.
  static const int comboTriplePauseBeforeScoreOverlaySeconds = 3;

  // ==========================================
  // ✅ VICTORY DIALOG DISPLAY DURATION
  // ==========================================
  static const int victoryDialogDisplaySeconds = 10;

  // ==========================================
  // HOLE VALUES (matches ESP32 sensor mapping)
  // ==========================================
  static const Map<String, int> holeValues = {
    'LEFT_TOP': 10,
    'LEFT_MID': -5,
    'LEFT_LOW': 5,
    'CENTER_TOP': -10,
    'CENTER_MID': 30,
    'CENTER_LOW': 0,    // x0
    'RIGHT_TOP': 5,
    'RIGHT_MID': -5,
    'RIGHT_LOW': 0,     // x2
  };

  static const String holeMultiplyX2 = 'RIGHT_LOW';
  static const String holeMultiplyX0 = 'CENTER_LOW';

  // ==========================================
  // GAME MODES
  // ==========================================
  static const String modeClassic = 'classic';
  static const String modeSoloChrono = 'solo_chrono';
  static const String modeTournament = 'tournament';
  static const String modeHardcore = 'hardcore';
  static const String modeCombo = 'combo';
  static const String modeChampion = 'champion';

  // ==========================================
  // TIMINGS
  // ==========================================
  static const int scoreDisplayDuration = 2000;
  static const int turnTransitionDelay = 1500;
  static const int victoryAnimationDuration = 50000;
  static const int detectionCooldown = 1500;

  // ==========================================
  // ESP32 JSON MESSAGE TYPES
  // ==========================================
  // From ESP32 → Flutter
  static const String msgTypeDetection = 'detection';
  static const String msgTypeStatus = 'status';
  static const String msgTypePong = 'pong';
  static const String msgTypeError = 'error';
  static const String msgTypeReady = 'ready';

  // From Flutter → ESP32
  static const String msgTypePing = 'ping';
  static const String msgTypeReset = 'reset';
  static const String msgTypeConfig = 'config';
  static const String msgTypeLed = 'led';
  static const String msgTypeStart = 'start_game';
  static const String msgTypeStop = 'stop_game';

  // ==========================================
  // LEADERBOARD
  // ==========================================
  static const int topLeaderboardSize = 10;
  static const String leaderboardStorageKey = 'triball_leaderboard';

  // ==========================================
  // TARGET SCORES BY MODE
  // ==========================================
  static int getTargetScore(String mode) {
    switch (mode) {
      case modeChampion:
        return 200;
      default:
        return 100;
    }
  }

  // ==========================================
  // ✅ NEW : RELAY MESSAGE TYPES
  // ==========================================
  static const String msgTypeClientDeclare    = 'client_declare';
  static const String msgTypeStartGameConfig  = 'start_game_config';
  static const String msgTypeStopGameRemote   = 'stop_game_remote';
  static const String msgTypeGameStatusUpdate = 'game_status_update';
  static const String msgTypeGetLastConfig    = 'get_last_config';
  static const String msgTypeGetClientsInfo   = 'get_clients_info';
  static const String msgTypeClientsInfo      = 'clients_info';

  // ==========================================
  // ✅ NEW : CLIENT ROLES
  // ==========================================
  static const String roleUnknown    = 'unknown';
  static const String roleConfigArea = 'config_area';
  static const String roleGameArea   = 'game_area';
  static const String roleSpectator  = 'spectator';
  static const String roleFamily     = 'family';

  // ==========================================
  // ✅ NEW : CODE DE SÉCURITÉ POUR EFFACER LE CLASSEMENT
  // ==========================================

  static const String leaderboardClearCode = '1234';

  // ==========================================
  // ✅ NEW : REMOTE DISPLAY COMMANDS
  // ==========================================
  static const String msgTypeShowLeaderboard = 'show_leaderboard';
  static const String msgTypeShowWaiting     = 'show_waiting';
  static const String msgTypeChangeFilter    = 'change_filter';  // ✅ NEW
}