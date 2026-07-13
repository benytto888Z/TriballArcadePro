// triball_config_area/lib/core/controllers/platform_event_bus.dart

import 'dart:async';
import '../../data/models/platform_error_model.dart';
import '../../data/models/platform_ready_model.dart';
import '../../data/models/platform_status_model.dart';

class PlatformEventBus {
  PlatformEventBus._();
  static final PlatformEventBus instance = PlatformEventBus._();

  // ============================================
  // PLATFORM STREAMS
  // ============================================
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

  // ============================================
  // RELAY STREAMS (Config Area côté réception)
  // ============================================
  final _remoteStatusController =
  StreamController<Map<String, dynamic>>.broadcast();
  final _clientsInfoController =
  StreamController<Map<String, dynamic>>.broadcast();

  final _clearAvatarsController = StreamController<void>.broadcast();

  Stream<void> get onClearAvatars => _clearAvatarsController.stream;

  // ============================================
  // PUBLIC STREAMS
  // ============================================
  Stream<PlatformStatusModel> get onStatus => _statusController.stream;
  Stream<PlatformReadyModel> get onReady => _readyController.stream;
  Stream<PlatformErrorModel> get onError => _errorController.stream;
  Stream<String> get onRawMessage => _rawController.stream;
  Stream<void> get onGameStarted => _gameStartedController.stream;
  Stream<void> get onGameStopped => _gameStoppedController.stream;
  Stream<void> get onGameReset => _gameResetController.stream;
  Stream<int> get onPong => _pongController.stream;
  Stream<Map<String, dynamic>> get onAck => _ackController.stream;
  Stream<Map<String, dynamic>> get onRemoteStatus =>
      _remoteStatusController.stream;
  Stream<Map<String, dynamic>> get onClientsInfo =>
      _clientsInfoController.stream;

  // ============================================
  // EMITTERS
  // ============================================
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

  void emitClearAvatars() {
    if (!_clearAvatarsController.isClosed) _clearAvatarsController.add(null);
  }


  // ============================================
  // CLEANUP
  // ============================================
  void dispose() {
    _statusController.close();
    _readyController.close();
    _errorController.close();
    _rawController.close();
    _gameStartedController.close();
    _gameStoppedController.close();
    _gameResetController.close();
    _pongController.close();
    _ackController.close();
    _remoteStatusController.close();
    _clientsInfoController.close();
    _clearAvatarsController.close();
  }
}