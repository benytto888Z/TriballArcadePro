// lib/core/services/tts_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/audio_constants.dart';
import '../localization/locale_controller.dart';

class TtsVoice {
  final String name;
  final String locale;

  TtsVoice({required this.name, required this.locale});

  factory TtsVoice.fromMap(Map<String, dynamic> map) {
    return TtsVoice(
      name: map['name']?.toString() ?? 'Unknown',
      locale: map['locale']?.toString() ?? '',
    );
  }

  @override
  String toString() => '$name ($locale)';
}

class TtsService extends GetxService {
  final FlutterTts _tts = FlutterTts();
  final _storage = GetStorage();

  // ============================================
  // OBSERVABLES
  // ============================================
  final RxBool ttsEnabled = true.obs;
  final RxDouble pitch = AudioConstants.defaultVoicePitch.obs;
  final RxDouble rate = AudioConstants.defaultVoiceRate.obs;
  final RxDouble volume = AudioConstants.defaultVoiceVolume.obs;
  final RxList<TtsVoice> availableVoices = <TtsVoice>[].obs;
  final Rx<TtsVoice?> selectedVoice = Rx<TtsVoice?>(null);
  final RxBool isInitialized = false.obs;
  final RxBool isSpeaking = false.obs;

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _initTts();
  }

  void _loadSettings() {
    ttsEnabled.value = _storage.read('tts_enabled') ?? true;
    pitch.value = (_storage.read('tts_pitch') ??
        AudioConstants.defaultVoicePitch)
        .toDouble();
    rate.value = (_storage.read('tts_rate') ??
        AudioConstants.defaultVoiceRate)
        .toDouble();
    volume.value = (_storage.read('tts_volume') ??
        AudioConstants.defaultVoiceVolume)
        .toDouble();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setVolume(volume.value);
      await _tts.setPitch(pitch.value);
      await _tts.setSpeechRate(rate.value);
      await _updateLanguage();
      await _loadAvailableVoices();

      // Status listeners
      _tts.setStartHandler(() => isSpeaking.value = true);
      _tts.setCompletionHandler(() => isSpeaking.value = false);
      _tts.setCancelHandler(() => isSpeaking.value = false);
      _tts.setErrorHandler((msg) {
        isSpeaking.value = false;
        if (kDebugMode) print('🗣 TTS error: $msg');
      });

      isInitialized.value = true;
    } catch (e) {
      if (kDebugMode) print('🗣 TTS init error: $e');
    }
  }

// ============================================
// LANGUAGE MANAGEMENT — VERSION CORRIGÉE
// ============================================
  Future<void> _updateLanguage() async {
    try {
      final locale = Get.find<LocaleController>().currentLocale.value;
      String ttsLang;
      switch (locale.languageCode) {
        case 'fr':
          ttsLang = 'fr-FR';
          break;
        case 'es':
          ttsLang = 'es-ES';
          break;
        case 'de':
          ttsLang = 'de-DE';
          break;
        default:
          ttsLang = 'en-US';
      }
      await _tts.setLanguage(ttsLang);
    } catch (e) {
      if (kDebugMode) print('🗣 TTS lang error: $e');
    }
  }

  /// ✅ Méthode appelée au changement de langue
  Future<void> updateLanguageOnChange() async {
    // 1. Reset la voix sélectionnée AVANT de charger les nouvelles
    selectedVoice.value = null;

    // 2. Mettre à jour la langue TTS
    await _updateLanguage();

    // 3. Charger les nouvelles voix disponibles
    await _loadAvailableVoices();

    // 4. Essayer de restaurer une voix sauvegardée pour cette langue
    final locale = Get.find<LocaleController>().currentLocale.value;
    final savedVoiceName = _storage.read('tts_voice_${locale.languageCode}');

    if (savedVoiceName != null && availableVoices.isNotEmpty) {
      final voice = availableVoices.firstWhereOrNull(
            (v) => v.name == savedVoiceName,
      );
      if (voice != null) {
        await setVoice(voice);
        return;
      }
    }

    // 5. Sinon, prendre la première voix disponible
    if (availableVoices.isNotEmpty) {
      await setVoice(availableVoices.first);
    }
  }

// ============================================
// VOICES LOADING — Avec reset sécurisé
// ============================================
  Future<void> _loadAvailableVoices() async {
    try {
      // ✅ Reset la liste AVANT de la remplir
      availableVoices.clear();

      final voices = await _tts.getVoices;
      if (voices is List) {
        final locale = Get.find<LocaleController>().currentLocale.value;
        final langCode = locale.languageCode;

        final filtered = voices
            .map((v) => TtsVoice.fromMap(Map<String, dynamic>.from(v)))
            .where((v) => v.locale.toLowerCase().startsWith(langCode))
            .toList();

        availableVoices.value = filtered;

        if (kDebugMode) {
          print('🗣 Available voices for $langCode (${filtered.length}):');
          for (final v in filtered) {
            print('   - $v');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('🗣 Load voices error: $e');
    }
  }

  Future<void> setVoice(TtsVoice voice) async {
    try {
      await _tts.setVoice({
        'name': voice.name,
        'locale': voice.locale,
      });
      selectedVoice.value = voice;

      // Save preference per language
      final lang = Get.find<LocaleController>().currentLocale.value.languageCode;
      await _storage.write('tts_voice_$lang', voice.name);

      if (kDebugMode) print('🗣 Voice set: $voice');
    } catch (e) {
      if (kDebugMode) print('🗣 Set voice error: $e');
    }
  }

  // ============================================
  // SPEAK
  // ============================================
  Future<void> speak(String text) async {
    if (!ttsEnabled.value || text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      if (kDebugMode) print('🗣 Speak error: $e');
    }
  }

  Future<void> speakKey(String key,
      {Map<String, String>? params}) async {
    if (!ttsEnabled.value) return;

    String text = key.tr;

    // ✅ Interpolation manuelle ROBUSTE
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }

    await speak(text);
  }

  /// Test la voix avec une phrase exemple
  Future<void> speakTest() async {
    final lang = Get.find<LocaleController>().currentLocale.value.languageCode;
    final phrase =
        AudioConstants.ttsTestPhrases[lang] ?? 'Hello, this is a test';
    await speak(phrase);
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  // ============================================
  // TOGGLES & VOLUMES
  // ============================================
  void toggleTts() {
    ttsEnabled.value = !ttsEnabled.value;
    _storage.write('tts_enabled', ttsEnabled.value);
    if (!ttsEnabled.value) stop();
  }

  Future<void> setPitch(double v) async {
    pitch.value = v.clamp(AudioConstants.minPitch, AudioConstants.maxPitch);
    await _storage.write('tts_pitch', pitch.value);
    await _tts.setPitch(pitch.value);
  }

  Future<void> setRate(double v) async {
    rate.value = v.clamp(AudioConstants.minRate, AudioConstants.maxRate);
    await _storage.write('tts_rate', rate.value);
    await _tts.setSpeechRate(rate.value);
  }

  Future<void> setVolume(double v) async {
    volume.value = v.clamp(AudioConstants.minVolume, AudioConstants.maxVolume);
    await _storage.write('tts_volume', volume.value);
    await _tts.setVolume(volume.value);
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}