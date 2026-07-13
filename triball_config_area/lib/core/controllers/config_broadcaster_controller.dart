// triball_config_area/lib/core/controllers/config_broadcaster_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/models/game_config_model.dart';
import '../../data/models/game_state_model.dart';
import '../../data/models/match_type_model.dart';
import '../../data/models/remote_game_status_model.dart';
import '../constants/game_constants.dart';
import '../localization/locale_controller.dart';
import '../theme/app_theme_controller.dart';
import 'platform_event_bus.dart';
import 'websocket_controller.dart';

/// Controller qui envoie la configuration de partie
/// depuis Config Area vers Game Area (via ESP32 comme relais)
class ConfigBroadcasterController extends GetxController {
  // ============================================
  // DEPENDENCIES
  // ============================================
  final WebSocketController _ws = Get.find<WebSocketController>();
  final AppThemeController _theme = Get.find<AppThemeController>();
  final LocaleController _locale = Get.find<LocaleController>();

  // ============================================
  // OBSERVABLES
  // ============================================

  /// Nombre de Game Area connectées
  final RxInt gameAreaCount = 0.obs;

  /// Dernière config envoyée
  final Rx<GameConfig?> lastSentConfig = Rx<GameConfig?>(null);

  /// Timestamp du dernier envoi
  final Rx<DateTime?> lastSentAt = Rx<DateTime?>(null);

  /// Statut reçu de Game Area
  final Rx<RemoteGameStatus?> remoteGameStatus = Rx<RemoteGameStatus?>(null);

  /// Indique si le Game Area est en train de jouer
  final RxBool gameAreaIsPlaying = false.obs;

  // ============================================
  // SUBSCRIPTIONS
  // ============================================
  StreamSubscription<Map<String, dynamic>>? _ackSub;
  StreamSubscription<Map<String, dynamic>>? _statusSub;
  StreamSubscription<Map<String, dynamic>>? _clientsInfoSub;

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _declareAsConfigArea();
    _setupBusListeners();

    // Refresh clients info toutes les 10s
    Timer.periodic(const Duration(seconds: 10), (_) {
      if (_ws.isConnected) _ws.requestClientsInfo();
    });
  }

  @override
  void onClose() {
    _ackSub?.cancel();
    _statusSub?.cancel();
    _clientsInfoSub?.cancel();
    super.onClose();
  }

  // ============================================
  // SETUP
  // ============================================
  void _declareAsConfigArea() {
    _ws.setClientRole(
      GameConstants.roleConfigArea,
      deviceName: _generateDeviceName(),
    );
  }

  String _generateDeviceName() {
    // Nom généré depuis la plateforme (peut être customisé par l'user)
    return 'Config Tablet ${DateTime.now().millisecondsSinceEpoch % 1000}';
  }

  void _setupBusListeners() {
    // Écoute les ACK
    _ackSub = PlatformEventBus.instance.onAck.listen((ack) {
      if (kDebugMode) print('📨 ACK reçu: $ack');
    });

    // Écoute les status Game Area
    _statusSub = PlatformEventBus.instance.onRemoteStatus.listen((data) {
      try {
        final status = RemoteGameStatus.fromJson(data);
        remoteGameStatus.value = status;
        gameAreaIsPlaying.value = status.isPlaying;

        if (kDebugMode) {
          print('📊 Status Game Area: $status');
        }
      } catch (e) {
        if (kDebugMode) print('❌ Parse status error: $e');
      }
    });

    // Écoute les infos clients
    _clientsInfoSub = PlatformEventBus.instance.onClientsInfo.listen((data) {
      try {
        final clients = data['clients'] as List? ?? [];
        int count = 0;
        for (final c in clients) {
          if ((c as Map)['role'] == GameConstants.roleGameArea) {
            count++;
          }
        }
        gameAreaCount.value = count;
        if (kDebugMode) {
          print('👥 Game Area connectées: $count');
        }
      } catch (e) {
        if (kDebugMode) print('❌ Parse clients info error: $e');
      }
    });
  }

  // ============================================
  // ✅ SEND GAME CONFIG (main function)
  // ============================================

  /// Envoie la configuration de partie à toutes les Game Area connectées
  /// Retourne true si l'envoi a réussi (WebSocket ok, pas de garantie de réception)
  Future<bool> sendGameConfig(GameConfig config) async {
    if (!_ws.isConnected) {
      if (kDebugMode) print('⚠️ Cannot send config: not connected to ESP32');
      return false;
    }

    // Construction du JSON complet
    final configJson = _buildConfigJson(config);

    if (kDebugMode) {
      print('📤 Sending game config to Game Area(s):');
      print('   MatchType: ${config.matchType.key}');
      print('   Mode: ${config.mode.key}');
      print('   Players: ${config.playerNames.join(", ")}');
      print('   Game Area count: ${gameAreaCount.value}');
    }

    _ws.sendGameConfig(configJson);

    // Update state
    lastSentConfig.value = config;
    lastSentAt.value = DateTime.now();

    return true;
  }

  /// Construit le JSON de config à envoyer
  Map<String, dynamic> _buildConfigJson(GameConfig config) {
    return {
      'matchType': config.matchType.key,
      'gameMode': config.mode.key,
      'players': config.playerNames,
      'targetScore': config.targetScore,
      'ballsPerTurn': config.ballsPerTurn,
      'turnDurationSeconds': config.turnDurationSeconds,
      'turnWarningSeconds': config.turnWarningSeconds,
      'overshootRule': _overshootRuleKey(config.overshootRule),
      'options': {
        'ttsEnabled': config.ttsEnabled,
        'soundEnabled': config.soundEnabled,
      },
      'language': _locale.currentLocale.value.languageCode,
      'theme': _theme.currentTheme.value.name,
      'requestedBy': 'config_area',
      'ts': DateTime.now().millisecondsSinceEpoch,
    };
  }

  String _overshootRuleKey(OvershootRule rule) {
    switch (rule) {
      case OvershootRule.refuse:
        return 'refuse';
      case OvershootRule.bounce:
        return 'bounce';
      case OvershootRule.hardcoreOvershoot:
        return 'hardcoreOvershoot';
    }
  }

  /// ✅ Pause le jeu à distance (admin)
  void remotePause() {
    _ws.sendRemotePause();
  }

  /// ✅ Reprend le jeu à distance (admin)
  void remoteResume() {
    _ws.sendRemoteResume();
  }

  // ============================================
  // ✅ STOP GAME REMOTE
  // ============================================

  /// Envoie une commande d'arrêt de partie à toutes les Game Area
  Future<bool> sendStopGame() async {
    if (!_ws.isConnected) return false;
    _ws.sendStopGameRemote();
    if (kDebugMode) print('🛑 Stop game sent to Game Area(s)');
    return true;
  }

  // ============================================
  // ✅ HELPERS
  // ============================================

  /// Vérifie si au moins une Game Area est connectée
  bool get hasGameAreaConnected => gameAreaCount.value > 0;

  /// Vérifie si on peut démarrer une partie
  bool get canStartGame => _ws.isConnected && hasGameAreaConnected;

  /// Refresh manuel des infos clients
  void refreshClientsInfo() {
    if (_ws.isConnected) _ws.requestClientsInfo();
  }


  /// ✅ Affiche le leaderboard d'un mode sur Game Area
  void showLeaderboard(GameMode mode) {
    String modeKey;
    switch (mode) {
      case GameMode.classic:  modeKey = 'classic'; break;
      case GameMode.hardcore: modeKey = 'hardcore'; break;
      case GameMode.champion: modeKey = 'champion'; break;
      case GameMode.combo:    modeKey = 'combo'; break;
    }
    _ws.showLeaderboardOnGameArea(modeKey);
  }


  /// ✅ Change le filtre date sur le LeaderboardScreen de Game Area
  void changeLeaderboardFilter(String filterKey) {
    _ws.changeFilterOnGameArea(filterKey);
  }

  /// ✅ Retour au WaitingScreen sur Game Area
  void showWaiting() {
    _ws.showWaitingOnGameArea();
  }
}