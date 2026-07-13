// lib/core/localization/locale_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/game_constants.dart';
import '../controllers/websocket_controller.dart';
import '../services/tts_service.dart';

class LocaleController extends GetxController {
  final _storage = GetStorage();
  static const _localeKey = 'app_locale';

  final Rx<Locale> currentLocale = const Locale('en', 'US').obs;

  static const Map<String, Locale> supportedLocales = {
    'fr': Locale('fr', 'FR'),
    'en': Locale('en', 'US'),
    'es': Locale('es', 'ES'),
    'de': Locale('de', 'DE'),
  };

  static const Map<String, String> languageNames = {
    'fr': 'Français',
    'en': 'English',
    'es': 'Español',
    'de': 'Deutsch',
  };

  static const Map<String, String> languageFlags = {
    'fr': '🇫🇷',
    'en': '🇬🇧',
    'es': '🇪🇸',
    'de': '🇩🇪',
  };

  @override
  void onInit() {
    super.onInit();
    _loadLocale();
  }

  void _loadLocale() {
    final saved = _storage.read(_localeKey) as String?;
    if (saved != null && supportedLocales.containsKey(saved)) {
      currentLocale.value = supportedLocales[saved]!;
    }
  }

  void changeLocale(String code) {
    if (!supportedLocales.containsKey(code)) return;
    currentLocale.value = supportedLocales[code]!;
    _storage.write(_localeKey, code);
    Get.updateLocale(currentLocale.value);
    // ✅ Notify TTS service (asynchrone, pas bloquant)
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        Get.find<TtsService>().updateLanguageOnChange();
      } catch (_) {}
    });


    // ✅ NEW : Notifier le Game Area via WebSocket
    _notifyGameArea(code);
  }

  /// ✅ Envoie la langue au Game Area via ESP32
  void _notifyGameArea(String langCode) {
    try {
      final ws = Get.find<WebSocketController>();
      if (ws.isConnected) {
        ws.sendCommand({
          'type': GameConstants.msgTypeChangeLanguage,
          'language': langCode,
        });
      }
    } catch (_) {}
  }

  String get currentLanguageName =>
      languageNames[currentLocale.value.languageCode] ?? 'English';

  String get currentLanguageFlag =>
      languageFlags[currentLocale.value.languageCode] ?? '🇬🇧';
}