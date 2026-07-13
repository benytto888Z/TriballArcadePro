// triball_config_area/lib/features/splash/splash_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/controllers/config_broadcaster_controller.dart';
import '../../core/controllers/websocket_controller.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  // ============================================
  // OBSERVABLES
  // ============================================
  final RxString status = 'loading'.obs;
  final RxDouble progress = 0.0.obs;
  final RxBool isReady = false.obs;
  final RxBool platformConnected = false.obs;
  final RxBool gameAreaDetected = false.obs;

  // ============================================
  // DEPENDENCIES
  // ============================================
  WebSocketController? _ws;
  ConfigBroadcasterController? _broadcaster;

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    try {
      _ws = Get.find<WebSocketController>();
      _broadcaster = Get.find<ConfigBroadcasterController>();
    } catch (e) {
      if (kDebugMode) print('Splash deps not ready: $e');
    }
  }

  @override
  void onReady() {
    super.onReady();
    _runSequence();
  }

  // ============================================
  // SEQUENCE
  // ============================================
  Future<void> _runSequence() async {
    // Step 1 — Init services
    await _step(0.15, 'init_services', 400);

    // Step 2 — Audio
    await _step(0.30, 'init_audio', 400);

    // Step 3 — Connect to ESP32
    status.value = 'connect_platform';
    progress.value = 0.50;

    if (_ws != null) {
      _ws!.connect();
      ever(_ws!.connectionState, (state) {
        platformConnected.value = _ws!.isConnected;
      });
    }

    // Wait up to 3s for ESP32 connection
    int waited = 0;
    while (!platformConnected.value && waited < 3000) {
      await Future.delayed(const Duration(milliseconds: 100));
      waited += 100;
    }

    // Step 4 — Check Game Area
    status.value = 'checking_game_area';
    progress.value = 0.70;

    if (_broadcaster != null && platformConnected.value) {
      _ws!.requestClientsInfo();

      // Wait up to 2s for Game Area detection
      waited = 0;
      while (!gameAreaDetected.value && waited < 2000) {
        gameAreaDetected.value = _broadcaster!.hasGameAreaConnected;
        await Future.delayed(const Duration(milliseconds: 200));
        waited += 200;
      }
    }

    // Step 5 — Ready
    await _step(0.90, 'ready', 300);
    await _step(1.0, 'ready', 300);

    isReady.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> _step(double p, String s, int delay) async {
    progress.value = p;
    status.value = s;
    await Future.delayed(Duration(milliseconds: delay));
  }
}