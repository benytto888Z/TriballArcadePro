// triball_game_area/lib/core/controllers/config_listener_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/models/game_config_model.dart';
import '../../data/models/remote_config_command_model.dart';
import '../../data/models/stop_game_command_model.dart';
import '../constants/game_constants.dart';
import 'platform_event_bus.dart';
import 'websocket_controller.dart';

/// Controller qui écoute les configurations envoyées
/// depuis Config Area vers Game Area (via ESP32 comme relais)
class ConfigListenerController extends GetxController {
  // ============================================
  // DEPENDENCIES
  // ============================================
  final WebSocketController _ws = Get.find<WebSocketController>();

  // ============================================
  // OBSERVABLES
  // ============================================

  /// Nombre de Config Area connectées
  final RxInt configAreaCount = 0.obs;

  /// Dernière config reçue
  final Rx<RemoteConfigCommand?> lastReceivedCommand =
  Rx<RemoteConfigCommand?>(null);

  /// Dernière commande stop reçue
  final Rx<StopGameCommand?> lastStopCommand = Rx<StopGameCommand?>(null);

  /// Timestamp de la dernière réception
  final Rx<DateTime?> lastReceivedAt = Rx<DateTime?>(null);

  // ============================================
  // STREAMS EXPOSÉS (pour usage externe)
  // ============================================
  final _configReceivedStream =
  StreamController<RemoteConfigCommand>.broadcast();
  final _stopReceivedStream =
  StreamController<StopGameCommand>.broadcast();

  /// Émis à chaque config reçue depuis Config Area
  Stream<RemoteConfigCommand> get onConfigReceived =>
      _configReceivedStream.stream;

  /// Émis à chaque stop reçu depuis Config Area
  Stream<StopGameCommand> get onStopReceived =>
      _stopReceivedStream.stream;

  // ============================================
  // SUBSCRIPTIONS
  // ============================================
  StreamSubscription<Map<String, dynamic>>? _configSub;
  StreamSubscription<Map<String, dynamic>>? _stopSub;
  StreamSubscription<Map<String, dynamic>>? _clientsInfoSub;

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _declareAsGameArea();
    _setupBusListeners();

    // Refresh clients info toutes les 15s
    Timer.periodic(const Duration(seconds: 15), (_) {
      if (_ws.isConnected) _ws.requestClientsInfo();
    });

    // Demande la dernière config à la reconnexion
    ever(_ws.connectionState, (_) {
      if (_ws.isConnected && _ws.isDeclared.value) {
        Timer(const Duration(seconds: 2), () {
          if (_ws.isConnected) _ws.requestLastConfig();
        });
      }
    });
  }

  @override
  void onClose() {
    _configSub?.cancel();
    _stopSub?.cancel();
    _clientsInfoSub?.cancel();
    _configReceivedStream.close();
    _stopReceivedStream.close();
    super.onClose();
  }

  // ============================================
  // SETUP
  // ============================================
  void _declareAsGameArea() {
    _ws.setClientRole(
      GameConstants.roleGameArea,
      deviceName: _generateDeviceName(),
    );
  }

  String _generateDeviceName() {
    return 'Game TV ${DateTime.now().millisecondsSinceEpoch % 1000}';
  }

  void _setupBusListeners() {
    // ✅ Écoute les configs reçues
    _configSub = PlatformEventBus.instance.onConfigReceived.listen((data) {
      try {
        final command = RemoteConfigCommand.fromJson(data);
        lastReceivedCommand.value = command;
        lastReceivedAt.value = DateTime.now();

        if (kDebugMode) {
          print('📥 Config received: $command');
        }

        // Émission sur le stream local
        _configReceivedStream.add(command);
      } catch (e, stack) {
        if (kDebugMode) {
          print('❌ Config parse error: $e');
          print(stack);
        }
      }
    });

    // ✅ Écoute les commandes stop
    _stopSub = PlatformEventBus.instance.onStopGameReceived.listen((data) {
      try {
        final command = StopGameCommand.fromJson(data);
        lastStopCommand.value = command;

        if (kDebugMode) {
          print('🛑 Stop game received: $command');
        }

        _stopReceivedStream.add(command);
      } catch (e) {
        if (kDebugMode) print('❌ Stop parse error: $e');
      }
    });

    // ✅ Écoute les infos clients
    _clientsInfoSub = PlatformEventBus.instance.onClientsInfo.listen((data) {
      try {
        final clients = data['clients'] as List? ?? [];
        int count = 0;
        for (final c in clients) {
          if ((c as Map)['role'] == GameConstants.roleConfigArea) {
            count++;
          }
        }
        configAreaCount.value = count;

        if (kDebugMode) {
          print('👥 Config Area connectées: $count');
        }
      } catch (e) {
        if (kDebugMode) print('❌ Parse clients info error: $e');
      }
    });
  }

  // ============================================
  // ✅ SEND GAME STATUS (Game → Config)
  // ============================================

  /// Envoie le statut de la partie à toutes les Config Area
  void sendStatusUpdate({
    required String state,
    String? currentPlayer,
    Map<String, int>? scores,
    int elapsedSeconds = 0,
    String? winner,
    int? currentTurn,
  }) {
    if (!_ws.isConnected) return;

    _ws.sendGameStatusUpdate(
      state: state,
      currentPlayer: currentPlayer,
      scores: scores,
      elapsedSeconds: elapsedSeconds,
      winner: winner,
      currentTurn: currentTurn,
    );

    if (kDebugMode) {
      print('📤 Status sent: state=$state, player=$currentPlayer');
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Vérifie si au moins une Config Area est connectée
  bool get hasConfigAreaConnected => configAreaCount.value > 0;

  /// Récupère la GameConfig depuis la dernière commande reçue
  GameConfig? get lastReceivedConfig => lastReceivedCommand.value?.gameConfig;

  /// Refresh manuel
  void refreshClientsInfo() {
    if (_ws.isConnected) _ws.requestClientsInfo();
  }

  /// Redemande la dernière config au serveur
  void requestLastConfig() {
    if (_ws.isConnected) _ws.requestLastConfig();
  }
}