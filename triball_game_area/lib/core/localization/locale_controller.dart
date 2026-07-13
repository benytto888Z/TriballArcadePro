// triball_game_area/lib/core/localization/locale_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/platform_event_bus.dart';
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

  // ✅ NEW : Subscription
  StreamSubscription<Map<String, dynamic>>? _langSub;

  @override
  void onInit() {
    super.onInit();
    _loadLocale();
    _listenToRemoteLanguage();
  }

  @override
  void onClose() {
    _langSub?.cancel();
    super.onClose();
  }

  void _loadLocale() {
    final saved = _storage.read(_localeKey) as String?;
    if (saved != null && supportedLocales.containsKey(saved)) {
      currentLocale.value = supportedLocales[saved]!;
    }
  }

  /// ✅ NEW : Écoute les changements de langue depuis Config Area
  void _listenToRemoteLanguage() {
    _langSub = PlatformEventBus.instance.onChangeLanguage.listen((data) {
      final langCode = data['language'] as String? ?? 'en';
      if (supportedLocales.containsKey(langCode)) {
        if (currentLocale.value.languageCode != langCode) {
          changeLocale(langCode);
        }
      }
    });
  }

  void changeLocale(String code) {
    if (!supportedLocales.containsKey(code)) return;
    currentLocale.value = supportedLocales[code]!;
    _storage.write(_localeKey, code);
    Get.updateLocale(currentLocale.value);

    // Notify TTS
    try {
      Get.find<TtsService>().updateLanguageOnChange();
    } catch (_) {}
  }

  String get currentLanguageName =>
      languageNames[currentLocale.value.languageCode] ?? 'English';

  String get currentLanguageFlag =>
      languageFlags[currentLocale.value.languageCode] ?? '🇬🇧';
}