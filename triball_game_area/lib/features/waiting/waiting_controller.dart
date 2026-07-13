// triball_game_area/lib/features/waiting/waiting_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/controllers/config_listener_controller.dart';
import '../../core/controllers/platform_event_bus.dart';
import '../../core/controllers/websocket_controller.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/avatar_storage_service.dart';
import '../../core/theme/app_theme_controller.dart';
import '../../data/models/game_state_model.dart';
import '../../data/models/match_type_model.dart';
import '../../data/models/remote_config_command_model.dart';
import '../../routes/app_routes.dart';

class WaitingController extends GetxController {
  // ============================================
  // DEPENDENCIES
  // ============================================
  final WebSocketController ws = Get.find<WebSocketController>();
  final ConfigListenerController listener =
  Get.find<ConfigListenerController>();
  final AudioService audio = Get.find<AudioService>();

  // ============================================
  // OBSERVABLES
  // ============================================
  final RxBool espConnected = false.obs;
  final RxBool configAreaConnected = false.obs;
  final RxInt currentLeaderboardMode = 0.obs;
  final RxString lastWinnerName = ''.obs;
  final RxString lastWinnerMode = ''.obs;

  final AvatarStorageService _avatarStorage =
  Get.find<AvatarStorageService>();

  // ============================================
  // SUBSCRIPTIONS
  // ============================================
  StreamSubscription<RemoteConfigCommand>? _configSub;
  Timer? _carouselTimer;


  // ✅ NEW : Subscriptions pour display commands
  StreamSubscription<Map<String, dynamic>>? _showLeaderboardSub;
  StreamSubscription<void>? _showWaitingSub;

  // ============================================
  // LEADERBOARD MODES POUR CAROUSEL
  // ============================================
  final List<GameMode> leaderboardModes = [
    GameMode.classic,
    GameMode.hardcore,
    GameMode.champion,
    GameMode.combo,
  ];

  GameMode get currentMode =>
      leaderboardModes[currentLeaderboardMode.value % leaderboardModes.length];

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    // ✅ Nettoyer les avatars temporaires au démarrage du WaitingScreen
    _avatarStorage.clearCurrentGameAvatars();
    _listenToConnection();
    _listenToConfig();
    _startLeaderboardCarousel();
    _listenToDisplayCommands();     // ✅ NEW
  }

  @override
  void onReady() {
    super.onReady();
    audio.playBgm(AssetPaths.audioBgmNeon);

    // Demande le premier leaderboard
    if (ws.isConnected) {
      ws.requestLeaderboard(currentMode);
    }
  }

  @override
  void onClose() {
    _configSub?.cancel();
    _carouselTimer?.cancel();
    _showLeaderboardSub?.cancel();  // ✅ NEW
    _showWaitingSub?.cancel();      // ✅ NEW
    super.onClose();
  }

  // ============================================
  // LISTENERS
  // ============================================
  void _listenToConnection() {
    ever(ws.connectionState, (_) {
      espConnected.value = ws.isConnected;
    });
    espConnected.value = ws.isConnected;

    // Config Area count
    ever(listener.configAreaCount, (count) {
      configAreaConnected.value = count > 0;
    });
    configAreaConnected.value = listener.hasConfigAreaConnected;
  }

  /// ✅ Écoute les configs reçues → transition vers GameScreen
  void _listenToConfig() {
    _configSub = listener.onConfigReceived.listen((command) {
      if (kDebugMode) {
        print('📥 WaitingController: Config received');
        print('   MatchType: ${command.gameConfig.matchType.key}');
        print('   Mode: ${command.gameConfig.mode.key}');
      }

      audio.stopBgm();
      audio.playSfx(AssetPaths.audioCoinInsert);

      // ✅ Router selon le MatchType
      switch (command.gameConfig.matchType) {
        case MatchType.tournament:
        // ✅ Tournoi → aller au BracketScreen
          Get.offNamed(
            AppRoutes.tournamentBracket,
            arguments: command.gameConfig,
          );
          break;

        case MatchType.competition:
        case MatchType.soloChrono:
        // ✅ Compétition/Solo → aller au GameScreen
          Get.offNamed(
            AppRoutes.game,
            arguments: command.gameConfig,
          );
          break;
      }

      // ✅ Appliquer le thème et la langue reçus avec la config
      if (command.theme != null) {
        try {
          final themeCtrl = Get.find<AppThemeController>();
          AppThemeMode themeMode;
          switch (command.theme) {
            case 'neon':     themeMode = AppThemeMode.neon; break;
            case 'esports':  themeMode = AppThemeMode.esports; break;
            case 'carnival': themeMode = AppThemeMode.carnival; break;
            default:         themeMode = AppThemeMode.neon;
          }
          themeCtrl.switchTheme(themeMode);
        } catch (_) {}
      }

      if (command.language != null) {
        try {
          final localeCtrl = Get.find<LocaleController>();
          localeCtrl.changeLocale(command.language!);
        } catch (_) {}
      }
    });
  }

  // ============================================
  // ✅ NEW : Écoute les commandes d'affichage depuis Config Area
  // ============================================

  void _listenToDisplayCommands() {
    // ✅ Commande : afficher le LeaderboardScreen existant
    _showLeaderboardSub = PlatformEventBus.instance.onShowLeaderboard.listen((data) {
      final modeKey = data['mode'] as String? ?? 'classic';

      if (kDebugMode) {
        print('📺 Show leaderboard command: mode=$modeKey');
      }

      // ✅ Navigue vers le LeaderboardScreen existant
      // Le mode sera passé en argument et récupéré par LeaderboardController
      Get.toNamed(AppRoutes.leaderboard, arguments: modeKey);
    });

    // ✅ Commande : retourner au WaitingScreen
    _showWaitingSub = PlatformEventBus.instance.onShowWaiting.listen((_) {
      if (kDebugMode) {
        print('📺 Return to waiting screen');
      }
      Get.offAllNamed(AppRoutes.waiting);
    });
  }

  // ============================================
  // LEADERBOARD CAROUSEL
  // ============================================
  void _startLeaderboardCarousel() {
    // Change de mode toutes les 10 secondes
    _carouselTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      currentLeaderboardMode.value++;

      // Demande le nouveau leaderboard à l'ESP32
      if (ws.isConnected) {
        ws.requestLeaderboard(currentMode);
      }
    });
  }

  /// Avance manuellement au mode suivant
  void nextLeaderboardMode() {
    currentLeaderboardMode.value++;
    if (ws.isConnected) {
      ws.requestLeaderboard(currentMode);
    }
  }

  /// Recule manuellement au mode précédent
  void previousLeaderboardMode() {
    if (currentLeaderboardMode.value > 0) {
      currentLeaderboardMode.value--;
    } else {
      currentLeaderboardMode.value = leaderboardModes.length - 1;
    }
    if (ws.isConnected) {
      ws.requestLeaderboard(currentMode);
    }
  }

  /// Met à jour le dernier gagnant (appelé après une victoire)
  void setLastWinner(String name, String mode) {
    lastWinnerName.value = name;
    lastWinnerMode.value = mode;
  }
}