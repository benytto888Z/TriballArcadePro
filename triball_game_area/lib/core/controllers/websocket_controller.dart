// triball_game_area/lib/core/controllers/websocket_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/models/game_state_model.dart';
import '../constants/ esp32_config.dart';
import '../constants/game_constants.dart';
import '../services/ websocket_service.dart';
import '../../data/models/platform_error_model.dart';
import '../../data/models/platform_leaderboard_model.dart';
import '../../data/models/platform_ready_model.dart';
import '../../data/models/platform_status_model.dart';
import '../../data/models/score_event_model.dart';
import 'platform_event_bus.dart';

/// Controller GetX réactif pour la communication WebSocket.
/// Version GAME AREA — reçoit détections de balles, configs, et gère leaderboard.
class WebSocketController extends GetxController {
  // ============================================
  // SINGLETON ACCESS
  // ============================================
  static WebSocketController get instance => Get.find<WebSocketController>();

  // ============================================
  // DEPENDENCIES
  // ============================================
  final WebSocketService _service = Get.find<WebSocketService>();
  final PlatformEventBus _bus = PlatformEventBus.instance;

  // ============================================
  // OBSERVABLE STATE
  // ============================================
  final Rx<WsConnectionState> connectionState =
      WsConnectionState.disconnected.obs;
  final Rx<DateTime?> lastMessageTime = Rx<DateTime?>(null);
  final RxString lastRawMessage = ''.obs;
  final RxString lastError = ''.obs;
  final RxInt reconnectAttempts = 0.obs;
  final RxInt messagesReceived = 0.obs;
  final RxInt messagesSent = 0.obs;

  // Statuts typés depuis l'ESP32
  final Rx<PlatformStatusModel?> currentStatus = Rx<PlatformStatusModel?>(null);
  final Rx<PlatformReadyModel?> readyInfo = Rx<PlatformReadyModel?>(null);
  final Rx<ScoreEventModel?> lastDetection = Rx<ScoreEventModel?>(null);
  final RxList<ScoreEventModel> detectionHistory = <ScoreEventModel>[].obs;
  final RxList<PlatformErrorModel> errorHistory = <PlatformErrorModel>[].obs;

  // Pings
  final Rx<DateTime?> lastPingSent = Rx<DateTime?>(null);
  final Rx<DateTime?> lastPongReceived = Rx<DateTime?>(null);
  final RxInt pingLatencyMs = 0.obs;
  Timer? _pingTimer;

  // ============================================
  // ✅ CLIENT ROLE TRACKING
  // ============================================
  final RxString clientRole = GameConstants.roleUnknown.obs;
  final RxString deviceName = ''.obs;
  final RxBool isDeclared = false.obs;

  // ============================================
  // COMPUTED
  // ============================================
  bool get isConnected => connectionState.value == WsConnectionState.connected;
  bool get isDisconnected =>
      connectionState.value == WsConnectionState.disconnected;
  bool get isConnecting =>
      connectionState.value == WsConnectionState.connecting ||
      connectionState.value == WsConnectionState.reconnecting;
  bool get hasError => connectionState.value == WsConnectionState.error;

  Duration? get timeSinceLastMessage {
    if (lastMessageTime.value == null) return null;
    return DateTime.now().difference(lastMessageTime.value!);
  }

  bool get isHealthy {
    if (!isConnected) return false;
    final since = timeSinceLastMessage;
    if (since == null) return false;
    return since.inSeconds < 30;
  }

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _attachServiceCallbacks();
    if (kDebugMode) print('🔌 WebSocketController initialized (GAME AREA)');
  }

  @override
  void onReady() {
    super.onReady();
    connect();
  }

  @override
  void onClose() {
    _pingTimer?.cancel();
    super.onClose();
  }

  // ============================================
  // SERVICE BINDING
  // ============================================
  void _attachServiceCallbacks() {
    _service.onStateChange = (state) {
      connectionState.value = state;
      reconnectAttempts.value = _service.reconnectAttempts;

      if (state == WsConnectionState.connected) {
        _startPingTimer();
        isDeclared.value = false;
      } else {
        _stopPingTimer();
        isDeclared.value = false;
      }
    };

    _service.onMessage = _handleIncomingMessage;

    _service.onError = (err) {
      lastError.value = err;
      if (kDebugMode) print('🔌 Service error: $err');
    };
  }

  // ============================================
  // MESSAGE HANDLING
  // ============================================
  void _handleIncomingMessage(String message) {
    messagesReceived.value++;
    lastMessageTime.value = DateTime.now();
    lastRawMessage.value = message;
    _bus.emitRawMessage(message);

    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        // ============================================
        // DÉTECTIONS DE BALLES (ESP32 → Game Area)
        // ============================================
        case 'detection':
          _handleDetection(data);
          break;

        case 'status':
          _handleStatus(data);
          break;
        case 'ready':
          _handleReady(data);
          break;
        case 'error':
          _handleError(data);
          break;
        case 'pong':
          _handlePong(data);
          break;
        case 'game_started':
          _bus.emitGameStarted();
          break;
        case 'game_stopped':
          _bus.emitGameStopped();
          break;
        case 'game_reset':
          _bus.emitGameReset();
          break;

        // ============================================
        // LEADERBOARD
        // ============================================
        case 'leaderboard_data':
          _handleLeaderboardData(data);
          break;
        case 'ack':
          _handleAck(data);
          break;

        case GameConstants.msgTypeShowLeaderboard:
          _bus.emitShowLeaderboard(data);
          if (kDebugMode) print('📺 Show leaderboard command received');
          break;
        case GameConstants.msgTypeShowWaiting:
          _bus.emitShowWaiting();
          if (kDebugMode) print('📺 Show waiting command received');
          break;

        // ============================================
        // ✅ RELAY MESSAGES (Game Area reçoit)
        // ============================================
        case GameConstants.msgTypeStartGameConfig:
          // Reçu depuis Config Area (via ESP32) → nouvelle config de partie
          _bus.emitConfigReceived(data);
          if (kDebugMode) print('📥 Config received from Config Area');
          break;

        case GameConstants.msgTypeChangeFilter:
          _bus.emitChangeFilter(data);
          if (kDebugMode) print('📺 Change filter command received');
          break;

        case 'stop_game':
          // Reçu depuis Config Area (via ESP32) → arrêt de partie à distance
          _bus.emitStopGameReceived(data);
          if (kDebugMode) print('📥 Stop game received');
          break;

        case GameConstants.msgTypeClientsInfo:
          _bus.emitClientsInfo(data);
          break;

        case GameConstants.msgTypeRemotePause:
          _bus.emitRemotePause();
          if (kDebugMode) print('⏸ Remote pause command received');
          break;
        case GameConstants.msgTypeRemoteResume:
          _bus.emitRemoteResume();
          if (kDebugMode) print('▶ Remote resume command received');
          break;

        case GameConstants.msgTypePlayerAvatar:
          _bus.emitPlayerAvatar(data);
          if (kDebugMode) {
            final player = data['player'] ?? 'unknown';
            print('📸 Avatar received for $player');
          }
          break;
        case GameConstants.msgTypeClearAvatars:
          _bus.emitClearAvatars();
          if (kDebugMode) print('🗑 Clear avatars command received');
          break;

        case GameConstants.msgTypeChangeTheme:
          _bus.emitChangeTheme(data);
          if (kDebugMode) print('🎨 Theme change command received');
          break;
        case GameConstants.msgTypeChangeLanguage:
          _bus.emitChangeLanguage(data);
          if (kDebugMode) print('🌍 Language change command received');
          break;

        default:
          if (kDebugMode) print('⚠️ Unknown message type: $type');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Parse error: $e — raw: $message');
    }
  }

  void _handleDetection(Map<String, dynamic> data) {
    try {
      final event = ScoreEventModel.fromJson(data);
      lastDetection.value = event;
      detectionHistory.insert(0, event);
      if (detectionHistory.length > 50) detectionHistory.removeLast();
      _bus.emitDetection(event);
      if (kDebugMode) print('🎯 Detection: $event');
    } catch (e) {
      if (kDebugMode) print('❌ Detection parse error: $e');
    }
  }

  void _handleStatus(Map<String, dynamic> data) {
    try {
      final status = PlatformStatusModel.fromJson(data);
      currentStatus.value = status;
      _bus.emitStatus(status);
    } catch (e) {
      if (kDebugMode) print('❌ Status parse error: $e');
    }
  }

  void _handleReady(Map<String, dynamic> data) {
    try {
      final ready = PlatformReadyModel.fromJson(data);
      readyInfo.value = ready;
      _bus.emitReady(ready);
      if (kDebugMode) print('✅ Platform ready: $ready');

      // ✅ Auto-declare le rôle après ready
      if (clientRole.value != GameConstants.roleUnknown && !isDeclared.value) {
        Timer(const Duration(milliseconds: 300), () {
          _declareRole();
        });
      }
    } catch (e) {
      if (kDebugMode) print('❌ Ready parse error: $e');
    }
  }

  void _handleError(Map<String, dynamic> data) {
    try {
      final error = PlatformErrorModel.fromJson(data);
      errorHistory.insert(0, error);
      if (errorHistory.length > 20) errorHistory.removeLast();
      _bus.emitError(error);
      if (kDebugMode) print('⚠️ Platform error: $error');
    } catch (e) {
      if (kDebugMode) print('❌ Error parse error: $e');
    }
  }

  void _handlePong(Map<String, dynamic> data) {
    lastPongReceived.value = DateTime.now();
    final ts = (data['ts'] ?? 0) as int;
    if (lastPingSent.value != null) {
      pingLatencyMs.value = DateTime.now()
          .difference(lastPingSent.value!)
          .inMilliseconds;
    }
    _bus.emitPong(ts);
  }

  void _handleLeaderboardData(Map<String, dynamic> data) {
    try {
      final leaderboard = PlatformLeaderboardData.fromJson(data);
      _bus.emitLeaderboardData(leaderboard);
      if (kDebugMode) print('📊 Leaderboard received: $leaderboard');
    } catch (e) {
      if (kDebugMode) print('❌ Leaderboard parse error: $e');
    }
  }

  void _handleAck(Map<String, dynamic> data) {
    _bus.emitAck(data);

    if (kDebugMode) {
      final forCmd = data['for'] ?? 'unknown';
      final success = data['success'] ?? false;
      final extra = data['extra'] ?? '';
      print('✅ ACK for $forCmd: success=$success extra=$extra');
    }

    // ✅ Marker déclaration réussie
    if (data['for'] == GameConstants.msgTypeClientDeclare &&
        data['success'] == true) {
      isDeclared.value = true;
      if (kDebugMode) print('✅ Client declared as: ${clientRole.value}');
    }
  }

  // ============================================
  // PUBLIC API — CONNECTION
  // ============================================
  Future<void> connect() async {
    if (kDebugMode) print('🔌 Connecting...');
    await _service.connect();
  }

  void disconnect() {
    if (kDebugMode) print('🔌 Disconnecting...');
    _service.disconnect();
  }

  Future<void> reconnect() async {
    if (kDebugMode) print('🔌 Reconnecting...');
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect();
  }

  // ============================================
  // ✅ CLIENT DECLARATION
  // ============================================

  /// Définit le rôle du client (à appeler AVANT ou APRÈS la connexion)
  void setClientRole(String role, {String? deviceName}) {
    clientRole.value = role;
    if (deviceName != null) this.deviceName.value = deviceName;
    if (kDebugMode) {
      print('🎭 Client role set: $role (${deviceName ?? "no name"})');
    }

    // Si déjà connecté, on redéclare
    if (isConnected && !isDeclared.value) {
      _declareRole();
    }
  }

  /// Envoie la déclaration au serveur
  void _declareRole() {
    if (!isConnected) return;
    if (clientRole.value == GameConstants.roleUnknown) return;

    sendCommand({
      'type': GameConstants.msgTypeClientDeclare,
      'role': clientRole.value,
      'deviceName': deviceName.value,
    });
  }

  // ============================================
  // GAME COMMANDS (Game Area contrôle la platform)
  // ============================================

  /// Démarre le mode de jeu sur l'ESP32 (active les capteurs)
  void startGame() {
    sendCommand({'type': GameConstants.msgTypeStart});
  }

  /// Arrête le mode de jeu sur l'ESP32 (désactive les capteurs)
  void stopGame() {
    sendCommand({'type': GameConstants.msgTypeStop});
  }

  /// Reset l'état du jeu sur l'ESP32
  void resetGame() {
    sendCommand({'type': GameConstants.msgTypeReset});
  }

  /// Ping manuel
  void sendPing() {
    lastPingSent.value = DateTime.now();
    sendCommand({
      'type': GameConstants.msgTypePing,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Contrôle une LED d'un trou (RGB)
  void setLed(int holeIndex, int r, int g, int b) {
    sendCommand({
      'type': GameConstants.msgTypeLed,
      'hole': holeIndex,
      'r': r,
      'g': g,
      'b': b,
    });
  }

  /// Envoie une configuration arbitraire à l'ESP32
  void sendConfig(Map<String, dynamic> config) {
    sendCommand({'type': GameConstants.msgTypeConfig, ...config});
  }

  // ============================================
  // ✅ HELPER : Convertit un mode (dynamic/enum/String) en String key
  // ============================================
  String _resolveMode(dynamic mode) {
    if (mode is String) return mode;
    if (mode is GameMode) {
      switch (mode) {
        case GameMode.classic:  return 'classic';
        case GameMode.hardcore: return 'hardcore';
        case GameMode.champion: return 'champion';
        case GameMode.combo:    return 'combo';
      }
    }
    return mode.toString();
  }

  // ============================================
  // LEADERBOARD COMMANDS (Game Area)
  // ============================================

  /// Soumet un score au leaderboard de la platform

  /// Soumet un score au leaderboard
  void submitScore({
    required dynamic mode,
    required String playerName,
    required int timeMs,
    required int balls,
    String? avatarId,
    DateTime? date,
  }) {
    if (!isConnected) {
      if (kDebugMode) print('❌ submitScore: NOT CONNECTED');
      return;
    }

    final modeKey = _resolveMode(mode);   // ✅ CORRIGÉ

    final payload = {
      'type': 'leaderboard_submit',
      'mode': modeKey,
      'player': playerName,
      'time_ms': timeMs,
      'balls': balls,
      if (avatarId != null) 'avatar_id': avatarId,
      'date': (date ?? DateTime.now()).toIso8601String(),
    };

    if (kDebugMode) {
      print('📤 submitScore:');
      print('   mode: $modeKey');
      print('   player: $playerName');
      print('   time_ms: $timeMs');
      print('   balls: $balls');
    }

    sendCommand(payload);
  }

  /// Demande le leaderboard d'un mode à la platform
  /// Demande le leaderboard d'un mode
  void requestLeaderboard(dynamic mode) {
    if (!isConnected) {
      if (kDebugMode) print('❌ requestLeaderboard: NOT CONNECTED');
      return;
    }

    final modeKey = _resolveMode(mode);   // ✅ CORRIGÉ

    if (kDebugMode) print('📤 requestLeaderboard: mode=$modeKey');

    sendCommand({
      'type': 'leaderboard_get',
      'mode': modeKey,
    });
  }

  /// Efface le leaderboard d'un mode

  /// Efface le leaderboard d'un mode
  void clearLeaderboard(dynamic mode, {String securityCode = ''}) {
    if (!isConnected) return;

    final modeKey = _resolveMode(mode);   // ✅ CORRIGÉ

    if (kDebugMode) print('📤 clearLeaderboard: mode=$modeKey');

    sendCommand({
      'type': 'leaderboard_clear',
      'mode': modeKey,
      'code': securityCode,
    });
  }

  /// Efface TOUS les leaderboards

  /// Efface TOUS les leaderboards
  void clearAllLeaderboards({String securityCode = ''}) {
    if (!isConnected) return;

    sendCommand({
      'type': 'leaderboard_clear_all',
      'code': securityCode,
    });
  }

  // ============================================
  // ✅ GAME AREA API — RELAY COMMANDS
  // ============================================

  /// Envoie le statut de la partie (Game Area → Config Area via ESP32)
  void sendGameStatusUpdate({
    required String state,
    String? currentPlayer,
    Map<String, int>? scores,
    int elapsedSeconds = 0,
    String? winner,
    int? currentTurn,
  }) {
    if (!isConnected) return;
    sendCommand({
      'type': GameConstants.msgTypeGameStatusUpdate,
      'state': state,
      if (currentPlayer != null) 'currentPlayer': currentPlayer,
      if (scores != null) 'scores': scores,
      'elapsedSeconds': elapsedSeconds,
      if (winner != null) 'winner': winner,
      if (currentTurn != null) 'currentTurn': currentTurn,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Demande la dernière config stockée (utile à la reconnexion)
  void requestLastConfig() {
    if (!isConnected) return;
    sendCommand({'type': GameConstants.msgTypeGetLastConfig});
  }

  /// Demande info des clients connectés
  void requestClientsInfo() {
    if (!isConnected) return;
    sendCommand({'type': GameConstants.msgTypeGetClientsInfo});
  }

  // ============================================
  // COMMAND DISPATCH
  // ============================================

  /// Envoie une commande JSON brute
  void sendCommand(Map<String, dynamic> data) {
    if (!isConnected) {
      if (kDebugMode) print('⚠️ Cannot send (not connected): $data');
      return;
    }
    try {
      _service.sendJson(data);
      messagesSent.value++;
    } catch (e) {
      if (kDebugMode) print('❌ Send error: $e');
    }
  }

  /// ✅ Demande au Config Area de nettoyer ses photos
  void sendClearAvatars() {
    if (!isConnected) return;
    sendCommand({
      'type': GameConstants.msgTypeClearAvatars,
    });
    if (kDebugMode) print('🗑 Clear avatars sent');
  }

  // ============================================
  // PING SCHEDULER
  // ============================================
  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(Duration(seconds: Esp32Config.pingInterval), (
      _,
    ) {
      if (isConnected) sendPing();
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }



  // ============================================
  // STATS HELPERS
  // ============================================
  void resetStats() {
    messagesReceived.value = 0;
    messagesSent.value = 0;
    detectionHistory.clear();
    errorHistory.clear();
    pingLatencyMs.value = 0;
  }
}
