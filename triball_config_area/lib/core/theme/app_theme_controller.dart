// lib/core/theme/app_theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/asset_paths.dart';
import '../constants/game_constants.dart';
import '../controllers/websocket_controller.dart';
import '../services/audio_service.dart';
import 'neon_theme.dart';
import 'esports_theme.dart';
import 'carnival_theme.dart';

enum AppThemeMode { neon, esports, carnival }

extension AppThemeModeX on AppThemeMode {
  String get name {
    switch (this) {
      case AppThemeMode.neon:     return 'neon';
      case AppThemeMode.esports:  return 'esports';
      case AppThemeMode.carnival: return 'carnival';
    }
  }

  String get translationKey {
    switch (this) {
      case AppThemeMode.neon:     return 'theme_neon';
      case AppThemeMode.esports:  return 'theme_esports';
      case AppThemeMode.carnival: return 'theme_carnival';
    }
  }

  String get descriptionKey {
    switch (this) {
      case AppThemeMode.neon:     return 'theme_neon_desc';
      case AppThemeMode.esports:  return 'theme_esports_desc';
      case AppThemeMode.carnival: return 'theme_carnival_desc';
    }
  }

  String get icon {
    switch (this) {
      case AppThemeMode.neon:     return '🕹️';
      case AppThemeMode.esports:  return '🏆';
      case AppThemeMode.carnival: return '🎪';
    }
  }
}

class AppThemeController extends GetxController {
  static AppThemeController get instance => Get.find<AppThemeController>();

  final _storage = GetStorage();
  static const _themeKey = 'app_theme_mode';

  final Rx<AppThemeMode> currentTheme = AppThemeMode.neon.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final saved = _storage.read(_themeKey) as String?;
    if (saved != null) {
      try {
        currentTheme.value = AppThemeMode.values.firstWhere(
              (e) => e.name == saved,
          orElse: () => AppThemeMode.neon,
        );
      } catch (_) {
        currentTheme.value = AppThemeMode.neon;
      }
    }
  }



  Future<void> switchTheme(AppThemeMode theme) async {
    if (currentTheme.value == theme) return;
    currentTheme.value = theme;
    await _storage.write(_themeKey, theme.name);
    Get.changeTheme(currentThemeData);

    // ✅ NEW : Notifier le Game Area via WebSocket
    _notifyGameArea(theme);

    Get.forceAppUpdate();
  }

  /// ✅ Envoie le thème au Game Area via ESP32
  void _notifyGameArea(AppThemeMode theme) {
    try {
      final ws = Get.find<WebSocketController>();
      if (ws.isConnected) {
        ws.sendCommand({
          'type': GameConstants.msgTypeChangeTheme,
          'theme': theme.name,
        });
      }
    } catch (_) {}
  }


  ThemeData get currentThemeData {
    switch (currentTheme.value) {
      case AppThemeMode.neon:     return NeonTheme.themeData;
      case AppThemeMode.esports:  return EsportsTheme.themeData;
      case AppThemeMode.carnival: return CarnivalTheme.themeData;
    }
  }

  String get themeName {
    switch (currentTheme.value) {
      case AppThemeMode.neon:     return 'Neon Arcade';
      case AppThemeMode.esports:  return 'Esports Pro';
      case AppThemeMode.carnival: return 'Carnival Fun';
    }
  }

  bool get isNeon     => currentTheme.value == AppThemeMode.neon;
  bool get isEsports  => currentTheme.value == AppThemeMode.esports;
  bool get isCarnival => currentTheme.value == AppThemeMode.carnival;
  bool get isDark     => !isCarnival;
}