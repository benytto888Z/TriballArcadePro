// triball_game_area/lib/core/controllers/platform_event_bus.dart

import 'dart:async';
import '../../data/models/platform_error_model.dart';
import '../../data/models/platform_leaderboard_model.dart';  // ✅ IMPORTANT
import '../../data/models/platform_ready_model.dart';
import '../../data/models/platform_status_model.dart';
import '../../data/models/score_event_model.dart';           // ✅ IMPORTANT

class PlatformEventBus {
  PlatformEventBus._();
  static final PlatformEventBus instance = PlatformEventBus._();

  // ============================================
  // EXISTING STREAMS
  // ============================================
  final _detectionController =
  StreamController<ScoreEventModel>.broadcast();
  final _statusController =
  StreamController<PlatformStatusModel>.broadcast();
  final _readyController =
  StreamController<PlatformReadyModel>.broadcast();
  final _errorController =
  StreamController<PlatformErrorModel>.broadcast();
  final _rawController = StreamController<String>.broadcast();
  final _gameStartedController = StreamController<void>.broadcast();
  final _gameStoppedController = StreamController<void>.broadcast();
  final _gameResetController = StreamController<void>.broadcast();
  final _pongController = StreamController<int>.broadcast();
  final _ackController =
  StreamController<Map<String, dynamic>>.broadcast();

  final _remotePauseController = StreamController<void>.broadcast();
  final _remoteResumeController = StreamController<void>.broadcast();

  Stream<void> get onRemotePause => _remotePauseController.stream;
  Stream<void> get onRemoteResume => _remoteResumeController.stream;

  final _playerAvatarController =
  StreamController<Map<String, dynamic>>.broadcast();
  final _clearAvatarsController = StreamController<void>.broadcast();

  Stream<Map<String, dynamic>> get onPlayerAvatar =>
      _playerAvatarController.stream;
  Stream<void> get onClearAvatars =>
      _clearAvatarsController.stream;


  final _changeThemeController =
  StreamController<Map<String, dynamic>>.broadcast();
  final _changeLanguageController =
  StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onChangeTheme =>
      _changeThemeController.stream;
  Stream<Map<String, dynamic>> get onChangeLanguage =>
      _changeLanguageController.stream;

  // ============================================
  // ✅ LEADERBOARD STREAMS (GAME AREA uniquement)
  // ============================================
  final _leaderboardDataController =
  StreamController<PlatformLeaderboardData>.broadcast();

  // ============================================
  // RELAY STREAMS (Config ↔ Game)
  // ============================================
  final _configReceivedController =
  StreamController<Map<String, dynamic>>.broadcast();
  final _stopGameReceivedController =
  StreamController<Map<String, dynamic>>.broadcast();
  final _remoteStatusController =
  StreamController<Map<String, dynamic>>.broadcast();
  final _clientsInfoController =
  StreamController<Map<String, dynamic>>.broadcast();

  // ============================================
  // PUBLIC STREAMS (getters)
  // ============================================

  // Game detection
  Stream<ScoreEventModel> get onDetection => _detectionController.stream;

  // Platform
  Stream<PlatformStatusModel> get onStatus => _statusController.stream;
  Stream<PlatformReadyModel> get onReady => _readyController.stream;
  Stream<PlatformErrorModel> get onError => _errorController.stream;
  Stream<String> get onRawMessage => _rawController.stream;
  Stream<void> get onGameStarted => _gameStartedController.stream;
  Stream<void> get onGameStopped => _gameStoppedController.stream;
  Stream<void> get onGameReset => _gameResetController.stream;
  Stream<int> get onPong => _pongController.stream;
  Stream<Map<String, dynamic>> get onAck => _ackController.stream;

  // ✅ Leaderboard
  Stream<PlatformLeaderboardData> get onLeaderboardData =>
      _leaderboardDataController.stream;

  // Relay
  Stream<Map<String, dynamic>> get onConfigReceived =>
      _configReceivedController.stream;
  Stream<Map<String, dynamic>> get onStopGameReceived =>
      _stopGameReceivedController.stream;
  Stream<Map<String, dynamic>> get onRemoteStatus =>
      _remoteStatusController.stream;
  Stream<Map<String, dynamic>> get onClientsInfo =>
      _clientsInfoController.stream;

  // ============================================
  // EMITTERS
  // ============================================

  // ✅ Detection (GAME AREA)
  void emitDetection(ScoreEventModel event) {
    if (!_detectionController.isClosed) _detectionController.add(event);
  }

  // Platform
  void emitStatus(PlatformStatusModel status) {
    if (!_statusController.isClosed) _statusController.add(status);
  }

  void emitReady(PlatformReadyModel ready) {
    if (!_readyController.isClosed) _readyController.add(ready);
  }

  void emitError(PlatformErrorModel error) {
    if (!_errorController.isClosed) _errorController.add(error);
  }

  void emitRawMessage(String raw) {
    if (!_rawController.isClosed) _rawController.add(raw);
  }

  void emitGameStarted() {
    if (!_gameStartedController.isClosed) _gameStartedController.add(null);
  }

  void emitGameStopped() {
    if (!_gameStoppedController.isClosed) _gameStoppedController.add(null);
  }

  void emitGameReset() {
    if (!_gameResetController.isClosed) _gameResetController.add(null);
  }

  void emitPong(int timestamp) {
    if (!_pongController.isClosed) _pongController.add(timestamp);
  }

  void emitAck(Map<String, dynamic> ack) {
    if (!_ackController.isClosed) _ackController.add(ack);
  }

  // ✅ LEADERBOARD (GAME AREA)
  void emitLeaderboardData(PlatformLeaderboardData data) {
    if (!_leaderboardDataController.isClosed) {
      _leaderboardDataController.add(data);
    }
  }

  // RELAY
  void emitConfigReceived(Map<String, dynamic> config) {
    if (!_configReceivedController.isClosed) {
      _configReceivedController.add(config);
    }
  }

  void emitStopGameReceived(Map<String, dynamic> data) {
    if (!_stopGameReceivedController.isClosed) {
      _stopGameReceivedController.add(data);
    }
  }

  void emitRemoteStatus(Map<String, dynamic> status) {
    if (!_remoteStatusController.isClosed) {
      _remoteStatusController.add(status);
    }
  }

  void emitClientsInfo(Map<String, dynamic> info) {
    if (!_clientsInfoController.isClosed) {
      _clientsInfoController.add(info);
    }
  }

  final _showLeaderboardController =
  StreamController<Map<String, dynamic>>.broadcast();
  final _showWaitingController = StreamController<void>.broadcast();

  Stream<Map<String, dynamic>> get onShowLeaderboard =>
      _showLeaderboardController.stream;
  Stream<void> get onShowWaiting =>
      _showWaitingController.stream;

  void emitShowLeaderboard(Map<String, dynamic> data) {
    if (!_showLeaderboardController.isClosed) {
      _showLeaderboardController.add(data);
    }
  }

  void emitShowWaiting() {
    if (!_showWaitingController.isClosed) {
      _showWaitingController.add(null);
    }
  }

  final _changeFilterController =
  StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onChangeFilter =>
      _changeFilterController.stream;

  void emitChangeFilter(Map<String, dynamic> data) {
    if (!_changeFilterController.isClosed) _changeFilterController.add(data);
  }


  void emitRemotePause() {
    if (!_remotePauseController.isClosed) _remotePauseController.add(null);
  }

  void emitRemoteResume() {
    if (!_remoteResumeController.isClosed) _remoteResumeController.add(null);
  }

  void emitPlayerAvatar(Map<String, dynamic> data) {
    if (!_playerAvatarController.isClosed) _playerAvatarController.add(data);
  }

  void emitClearAvatars() {
    if (!_clearAvatarsController.isClosed) _clearAvatarsController.add(null);
  }

  void emitChangeTheme(Map<String, dynamic> data) {
    if (!_changeThemeController.isClosed) _changeThemeController.add(data);
  }

  void emitChangeLanguage(Map<String, dynamic> data) {
    if (!_changeLanguageController.isClosed) _changeLanguageController.add(data);
  }

  // ============================================
  // CLEANUP
  // ============================================
  void dispose() {
    _detectionController.close();
    _statusController.close();
    _readyController.close();
    _errorController.close();
    _rawController.close();
    _gameStartedController.close();
    _gameStoppedController.close();
    _gameResetController.close();
    _pongController.close();
    _ackController.close();
    _leaderboardDataController.close();
    _configReceivedController.close();
    _stopGameReceivedController.close();
    _remoteStatusController.close();
    _clientsInfoController.close();
    _showLeaderboardController.close();
    _showWaitingController.close();
    _changeFilterController.close();
    _playerAvatarController.close();
    _clearAvatarsController.close();
    _changeThemeController.close();
    _changeLanguageController.close();
  }
}