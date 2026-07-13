// triball_game_area/lib/core/theme/app_theme_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/platform_event_bus.dart';
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

  // ✅ NEW : Subscription pour thème distant
  StreamSubscription<Map<String, dynamic>>? _themeSub;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
    _listenToRemoteTheme();
  }

  @override
  void onClose() {
    _themeSub?.cancel();
    super.onClose();
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

  /// ✅ NEW : Écoute les changements de thème depuis Config Area
  void _listenToRemoteTheme() {
    _themeSub = PlatformEventBus.instance.onChangeTheme.listen((data) {
      final themeKey = data['theme'] as String? ?? 'neon';

      AppThemeMode newTheme;
      switch (themeKey) {
        case 'neon':     newTheme = AppThemeMode.neon; break;
        case 'esports':  newTheme = AppThemeMode.esports; break;
        case 'carnival': newTheme = AppThemeMode.carnival; break;
        default:         newTheme = AppThemeMode.neon;
      }

      if (currentTheme.value != newTheme) {
        switchTheme(newTheme);
      }
    });
  }

  Future<void> switchTheme(AppThemeMode theme) async {
    if (currentTheme.value == theme) return;
    currentTheme.value = theme;
    await _storage.write(_themeKey, theme.name);
    Get.changeTheme(currentThemeData);
    Get.forceAppUpdate();
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