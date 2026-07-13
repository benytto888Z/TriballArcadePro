// triball_config_area/lib/core/controllers/websocket_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../constants/ esp32_config.dart';
import '../constants/game_constants.dart';
import '../services/ websocket_service.dart';
import '../../data/models/platform_error_model.dart';
import '../../data/models/platform_ready_model.dart';
import '../../data/models/platform_status_model.dart';
import 'platform_event_bus.dart';

/// Controller GetX réactif pour la communication WebSocket.
/// Version CONFIG AREA — sans détection de balles ni leaderboard.
/// Se concentre sur l'envoi de config vers Game Area via relay ESP32.
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
  final Rx<PlatformStatusModel?> currentStatus =
  Rx<PlatformStatusModel?>(null);
  final Rx<PlatformReadyModel?> readyInfo = Rx<PlatformReadyModel?>(null);
  final RxList<PlatformErrorModel> errorHistory =
      <PlatformErrorModel>[].obs;

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
    if (kDebugMode) print('🔌 WebSocketController initialized (CONFIG AREA)');
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
        // ✅ Reset flag pour re-declare
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
        case 'ack':
          _handleAck(data);
          break;

      // ============================================
      // ✅ RELAY MESSAGES (Config Area reçoit)
      // ============================================
        case GameConstants.msgTypeGameStatusUpdate:
        // Reçu depuis Game Area (via ESP32) → statut de la partie
          _bus.emitRemoteStatus(data);
          if (kDebugMode) print('📊 Game status update received');
          break;
        case GameConstants.msgTypeClientsInfo:
          _bus.emitClientsInfo(data);
          break;


        case GameConstants.msgTypeClearAvatars:
          _bus.emitClearAvatars();
          if (kDebugMode) print('🗑 Clear avatars command received');
          break;

        default:
          if (kDebugMode) print('⚠️ Unknown message type: $type');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Parse error: $e — raw: $message');
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
      pingLatencyMs.value =
          DateTime.now().difference(lastPingSent.value!).inMilliseconds;
    }
    _bus.emitPong(ts);
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
  // BASIC COMMANDS
  // ============================================

  /// Envoie un ping manuel
  void sendPing() {
    lastPingSent.value = DateTime.now();
    sendCommand({
      'type': GameConstants.msgTypePing,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ============================================
  // ✅ CONFIG AREA API — RELAY COMMANDS
  // ============================================

  /// Envoie une configuration de partie (Config Area → Game Area via ESP32)
  void sendGameConfig(Map<String, dynamic> configJson) {
    if (!isConnected) {
      if (kDebugMode) print('⚠️ Cannot send config: not connected');
      return;
    }
    sendCommand({
      'type': GameConstants.msgTypeStartGameConfig,
      ...configJson,
    });
  }

  /// Envoie une commande d'arrêt à distance (Config Area → Game Area)
  void sendStopGameRemote() {
    if (!isConnected) return;
    sendCommand({
      'type': GameConstants.msgTypeStopGameRemote,
    });
  }

  /// Demande info des clients connectés
  void requestClientsInfo() {
    if (!isConnected) return;
    sendCommand({
      'type': GameConstants.msgTypeGetClientsInfo,
    });
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

  /// ✅ Demande à Game Area d'afficher le leaderboard d'un mode
  void showLeaderboardOnGameArea(String modeKey) {
    if (!isConnected) {
      if (kDebugMode) print('⚠️ Cannot show leaderboard: not connected');
      return;
    }
    sendCommand({
      'type': GameConstants.msgTypeShowLeaderboard,
      'mode': modeKey,
    });
    if (kDebugMode) print('📺 Show leaderboard: $modeKey');
  }

  /// ✅ Demande à Game Area de retourner au WaitingScreen
  void showWaitingOnGameArea() {
    if (!isConnected) {
      if (kDebugMode) print('⚠️ Cannot show waiting: not connected');
      return;
    }
    sendCommand({
      'type': GameConstants.msgTypeShowWaiting,
    });
    if (kDebugMode) print('📺 Show waiting');
  }

  /// ✅ Change le filtre date sur le LeaderboardScreen de Game Area
  void changeFilterOnGameArea(String filterKey) {
    if (!isConnected) return;
    sendCommand({
      'type': GameConstants.msgTypeChangeFilter,
      'filter': filterKey,
    });
    if (kDebugMode) print('📺 Change filter: $filterKey');
  }


  /// ✅ Envoie une commande PAUSE à Game Area
  void sendRemotePause() {
    if (!isConnected) return;
    sendCommand({'type': GameConstants.msgTypeRemotePause});
    if (kDebugMode) print('⏸ Remote pause sent');
  }

  /// ✅ Envoie une commande RESUME à Game Area
  void sendRemoteResume() {
    if (!isConnected) return;
    sendCommand({'type': GameConstants.msgTypeRemoteResume});
    if (kDebugMode) print('▶ Remote resume sent');
  }

  /// ✅ Envoie l'avatar d'un joueur au Game Area
  void sendPlayerAvatar({
    required String playerName,
    required String avatarUrl,        // ✅ URL au lieu de base64
    required int playerIndex,
  }) {
    if (!isConnected) return;
    sendCommand({
      'type': GameConstants.msgTypePlayerAvatar,
      'player': playerName,
      'playerIndex': playerIndex,
      'avatarUrl': avatarUrl,          // ✅ URL courte
    });
    if (kDebugMode) {
      print('📸 Avatar URL sent for $playerName: $avatarUrl');
    }
  }

  /// ✅ Demande au Game Area de supprimer les avatars temporaires
  void sendClearAvatars() {
    if (!isConnected) return;
    sendCommand({
      'type': GameConstants.msgTypeClearAvatars,
    });
  }

  // ============================================
  // PING SCHEDULER
  // ============================================
  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(
      Duration(seconds: Esp32Config.pingInterval),
          (_) {
        if (isConnected) sendPing();
      },
    );
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
    errorHistory.clear();
    pingLatencyMs.value = 0;
  }
}