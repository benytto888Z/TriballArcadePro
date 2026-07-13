// triball_game_area/lib/features/splash/splash_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/controllers/config_listener_controller.dart';
import '../../core/controllers/websocket_controller.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final RxString status = 'loading'.obs;
  final RxDouble progress = 0.0.obs;
  final RxBool isReady = false.obs;
  final RxBool platformConnected = false.obs;

  WebSocketController? _ws;

  @override
  void onInit() {
    super.onInit();
    try {
      _ws = Get.find<WebSocketController>();
    } catch (e) {
      if (kDebugMode) print('Splash deps not ready: $e');
    }
  }

  @override
  void onReady() {
    super.onReady();
    _runSequence();
  }

  Future<void> _runSequence() async {
    await _step(0.15, 'init_services', 400);
    await _step(0.30, 'init_audio', 400);

    status.value = 'connect_platform';
    progress.value = 0.50;

    if (_ws != null) {
      _ws!.connect();
      ever(_ws!.connectionState, (state) {
        platformConnected.value = _ws!.isConnected;
      });
    }

    int waited = 0;
    while (!platformConnected.value && waited < 4000) {
      await Future.delayed(const Duration(milliseconds: 100));
      waited += 100;
    }

    await _step(0.80, 'declaring_role', 500);
    await _step(1.0, 'ready', 400);

    isReady.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    Get.offAllNamed(AppRoutes.waiting);
  }

  Future<void> _step(double p, String s, int delay) async {
    progress.value = p;
    status.value = s;
    await Future.delayed(Duration(milliseconds: delay));
  }
}