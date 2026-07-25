// triball_config_area/lib/features/home/home_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/controllers/config_broadcaster_controller.dart';
import '../../core/controllers/websocket_controller.dart';
import '../../core/services/audio_service.dart';
import '../../data/models/match_type_model.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  // ============================================
  // DEPENDENCIES
  // ============================================
  final WebSocketController ws = Get.find<WebSocketController>();
  final AudioService audio = Get.find<AudioService>();
  final ConfigBroadcasterController broadcaster =
  Get.find<ConfigBroadcasterController>();

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onReady() {
    super.onReady();

    audio.playBgm(AssetPaths.audioBgmNeon);

    refreshHome();

    Future.delayed(
      const Duration(milliseconds: 700),
          () {
        if (!isClosed) {
          refreshHome();
        }
      },
    );
  }

  Future<void> refreshHome() async {
    if (kDebugMode) {
      print(
        '🏠 Refreshing Config Area HomeScreen',
      );
    }

    if (!ws.isConnected && !ws.isConnecting) {
      await ws.connect();
    }

    if (ws.isConnected) {
      broadcaster.refreshClientsInfo();
    }

    update();
  }

  // ============================================
  // ✅ NAVIGATION — Config Area ne lance pas de partie localement
  //   Elle envoie la config au Game Area via l'ESP32
  // ============================================

  /// Competition (2-6 joueurs) → Setup avec MatchType présélectionné
  void onCompetitionPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    Get.toNamed(
      AppRoutes.gameSetup,
      arguments: MatchType.competition,
    );
  }

  /// Solo Chrono (1 joueur) → Setup avec MatchType présélectionné
  void onSoloChronoPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    Get.toNamed(
      AppRoutes.gameSetup,
      arguments: MatchType.soloChrono,
    );
  }

  /// Tournoi (4/8/16) → Setup avec MatchType présélectionné
  void onTournamentPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    Get.toNamed(
      AppRoutes.gameSetup,
      arguments: MatchType.tournament,
    );
  }

  /// Play générique → Setup avec choix libre du MatchType
  void onPlayPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    Get.toNamed(AppRoutes.gameSetup);
  }

  /// Settings
  void onSettingsPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    Get.toNamed(AppRoutes.settings);
  }

  /// How to play
  void onHowToPlayPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    Get.toNamed(AppRoutes.howToPlay);
  }

  void onLeaderboardRemotePressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    Get.toNamed(AppRoutes.leaderboardRemote);
  }
}