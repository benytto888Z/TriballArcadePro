// lib/core/services/screen_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum AppOrientation { portrait, landscape }

class ScreenService extends GetxService with WidgetsBindingObserver {
  final Rx<AppOrientation> currentOrientation = AppOrientation.portrait.obs;
  final RxBool isFullscreen = false.obs;
  final Rx<Size> screenSize = const Size(428, 926).obs;

  static ScreenService get instance => Get.find<ScreenService>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // ============================================
  // PORTRAIT
  // ============================================
  Future<void> setPortraitNormal() async {
    try {
      // ✅ Reset complet d'abord
      await SystemChrome.setPreferredOrientations([]);
      await Future.delayed(const Duration(milliseconds: 50));

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await _showSystemUI();
      currentOrientation.value = AppOrientation.portrait;
      isFullscreen.value = false;
      if (kDebugMode) print('📱 → PORTRAIT mode');
    } catch (e) {
      if (kDebugMode) print('⚠️ Failed portrait: $e');
    }
  }

  // ============================================
  // LANDSCAPE FULLSCREEN
  // ============================================
  Future<void> setLandscapeImmersive() async {
    try {
      // ✅ Reset complet d'abord pour forcer le changement
      await SystemChrome.setPreferredOrientations([]);
      await Future.delayed(const Duration(milliseconds: 50));

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await _enableImmersive();
      currentOrientation.value = AppOrientation.landscape;
      isFullscreen.value = true;
      if (kDebugMode) print('🎮 → LANDSCAPE IMMERSIVE mode');
    } catch (e) {
      if (kDebugMode) print('⚠️ Failed landscape: $e');
    }
  }

  // ============================================
  // INTERNAL
  // ============================================
  Future<void> _enableImmersive() async {
    if (kIsWeb) return;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
          overlays: [],
        );
      }
    } catch (_) {}
  }

  Future<void> _showSystemUI() async {
    if (kIsWeb) return;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        );
      }
    } catch (_) {}
  }

  // ============================================
  // METRICS LISTENER
  // ============================================
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    screenSize.value = size;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Re-apply current mode après mise en arrière-plan
      if (currentOrientation.value == AppOrientation.landscape) {
        setLandscapeImmersive();
      } else {
        setPortraitNormal();
      }
    }
  }
}