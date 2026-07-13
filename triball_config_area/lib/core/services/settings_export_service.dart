// triball_config_area/lib/core/services/settings_export_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Service d'export/import des paramètres.
/// Version Config Area — pas de leaderboard local.
class SettingsExportService extends GetxService {
  final _storage = GetStorage();

  // ============================================
  // EXPORT
  // ============================================
  String exportAllSettings() {
    final data = <String, dynamic>{
      'app_name': 'TRIBALL PRO CONFIG AREA',
      'app_version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),

      // Display
      'theme': _storage.read('app_theme_mode'),
      'locale': _storage.read('app_locale'),

      // Game settings
      'turn_duration': _storage.read('settings_turn_duration'),
      'turn_warning': _storage.read('settings_turn_warning'),
      'transition_delay': _storage.read('settings_transition_delay'),

      // Audio
      'sound_enabled': _storage.read('sound_enabled'),
      'music_enabled': _storage.read('music_enabled'),
      'sfx_volume': _storage.read('sfx_volume'),
      'music_volume': _storage.read('music_volume'),

      // TTS
      'tts_enabled': _storage.read('tts_enabled'),
      'tts_pitch': _storage.read('tts_pitch'),
      'tts_rate': _storage.read('tts_rate'),
      'tts_volume': _storage.read('tts_volume'),

      // Platform config
      'custom_wifi_ssid': _storage.read('custom_wifi_ssid'),
      'custom_wifi_password': _storage.read('custom_wifi_password'),
      'led_brightness': _storage.read('led_brightness'),
      'detection_cooldown': _storage.read('detection_cooldown'),
      'debounce_ms': _storage.read('debounce_ms'),
      'auto_connect': _storage.read('auto_connect'),
      'config_device_name': _storage.read('config_device_name'),

      // Recent players
      'recent_player_names': _storage.read('recent_player_names'),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Copie l'export dans le clipboard
  Future<void> copyToClipboard() async {
    final json = exportAllSettings();
    await Clipboard.setData(ClipboardData(text: json));
  }

  // ============================================
  // IMPORT
  // ============================================
  Future<bool> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (!data.containsKey('app_version')) {
        if (kDebugMode) print('⚠️ Invalid backup file');
        return false;
      }

      for (final entry in data.entries) {
        if (entry.key == 'app_name' ||
            entry.key == 'app_version' ||
            entry.key == 'exported_at') continue;
        if (entry.value == null) continue;

        final storageKey = _mapKey(entry.key);
        if (storageKey != null) {
          await _storage.write(storageKey, entry.value);
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('⚠️ Import error: $e');
      return false;
    }
  }

  String? _mapKey(String key) {
    const mapping = {
      'theme': 'app_theme_mode',
      'locale': 'app_locale',
      'turn_duration': 'settings_turn_duration',
      'turn_warning': 'settings_turn_warning',
      'transition_delay': 'settings_transition_delay',
      'sound_enabled': 'sound_enabled',
      'music_enabled': 'music_enabled',
      'sfx_volume': 'sfx_volume',
      'music_volume': 'music_volume',
      'tts_enabled': 'tts_enabled',
      'tts_pitch': 'tts_pitch',
      'tts_rate': 'tts_rate',
      'tts_volume': 'tts_volume',
      'custom_wifi_ssid': 'custom_wifi_ssid',
      'custom_wifi_password': 'custom_wifi_password',
      'led_brightness': 'led_brightness',
      'detection_cooldown': 'detection_cooldown',
      'debounce_ms': 'debounce_ms',
      'auto_connect': 'auto_connect',
      'config_device_name': 'config_device_name',
      'recent_player_names': 'recent_player_names',
    };
    return mapping[key] ?? key;
  }

  // ============================================
  // RESET ALL
  // ============================================
  Future<void> resetAllData() async {
    await _storage.erase();
  }
}