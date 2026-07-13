// triball_config_area/lib/core/services/platform_config_service.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/websocket_controller.dart';

/// Service de configuration de la plateforme ESP32.
/// Accessible uniquement depuis CONFIG AREA (l'app admin).
///
/// Gère :
/// - WiFi credentials
/// - Hardware tuning (LED brightness, cooldown, debounce)
/// - Auto-connect
/// - OTA firmware update (futur)
/// - Reset aux valeurs par défaut
class PlatformConfigService extends GetxService {
  final _storage = GetStorage();
  late final WebSocketController _ws;

  // ============================================
  // STORAGE KEYS
  // ============================================
  static const String _keyCustomSsid = 'custom_wifi_ssid';
  static const String _keyCustomPassword = 'custom_wifi_password';
  static const String _keyLedBrightness = 'led_brightness';
  static const String _keyDetectionCooldown = 'detection_cooldown';
  static const String _keyDebounceMs = 'debounce_ms';
  static const String _keyAutoConnect = 'auto_connect';
  static const String _keyDeviceName = 'config_device_name';

  // ============================================
  // DEFAULTS
  // ============================================
  static const int defaultLedBrightness = 150;
  static const int defaultDetectionCooldown = 1500;
  static const int defaultDebounceMs = 30;
  static const String defaultSsid = 'amz_triball';
  static const String defaultPassword = '12345678';

  // ============================================
  // OBSERVABLES
  // ============================================
  final RxString customSsid = ''.obs;
  final RxString customPassword = ''.obs;
  final RxInt ledBrightness = defaultLedBrightness.obs;
  final RxInt detectionCooldown = defaultDetectionCooldown.obs;
  final RxInt debounceMs = defaultDebounceMs.obs;
  final RxBool autoConnect = true.obs;
  final RxString configDeviceName = 'Config Tablet'.obs;

  // ============================================
  // ✅ PLATFORM STATUS (lecture seule, reçu du ESP32)
  // ============================================
  final RxBool platformConnected = false.obs;
  final RxString firmwareVersion = ''.obs;
  final RxInt sensorsCount = 0.obs;
  final RxInt ledsCount = 0.obs;
  final RxBool configRelayEnabled = false.obs;

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _ws = Get.find<WebSocketController>();
    _loadSettings();
    _listenToReady();
    _listenToConnection();
  }

  void _loadSettings() {
    customSsid.value = _storage.read(_keyCustomSsid) ?? '';
    customPassword.value = _storage.read(_keyCustomPassword) ?? '';
    ledBrightness.value = _storage.read(_keyLedBrightness) ?? defaultLedBrightness;
    detectionCooldown.value = _storage.read(_keyDetectionCooldown) ?? defaultDetectionCooldown;
    debounceMs.value = _storage.read(_keyDebounceMs) ?? defaultDebounceMs;
    autoConnect.value = _storage.read(_keyAutoConnect) ?? true;
    configDeviceName.value = _storage.read(_keyDeviceName) ?? 'Config Tablet';

    if (kDebugMode) {
      print('⚙️ PlatformConfigService loaded:');
      print('   SSID: ${currentSsid}');
      print('   LED brightness: ${ledBrightness.value}');
      print('   Detection cooldown: ${detectionCooldown.value}ms');
      print('   Debounce: ${debounceMs.value}ms');
      print('   Auto-connect: ${autoConnect.value}');
      print('   Device name: ${configDeviceName.value}');
    }
  }

  /// Écoute le message "ready" de l'ESP32 pour récupérer les infos firmware
  void _listenToReady() {
    ever(_ws.readyInfo, (info) {
      if (info == null) return;
      firmwareVersion.value = info.firmware;
      sensorsCount.value = info.sensorsCount;
      ledsCount.value = info.ledsCount;

      if (kDebugMode) {
        print('⚙️ Platform info updated:');
        print('   Firmware: ${firmwareVersion.value}');
        print('   Sensors: ${sensorsCount.value}');
        print('   LEDs: ${ledsCount.value}');
      }
    });
  }

  /// Écoute l'état de connexion WebSocket
  void _listenToConnection() {
    ever(_ws.connectionState, (state) {
      platformConnected.value = _ws.isConnected;
    });
    platformConnected.value = _ws.isConnected;
  }

  // ============================================
  // GETTERS UTILES
  // ============================================

  /// SSID effectif (custom ou default)
  String get currentSsid =>
      customSsid.value.isNotEmpty ? customSsid.value : defaultSsid;

  /// Password effectif (custom ou default)
  String get currentPassword =>
      customPassword.value.isNotEmpty ? customPassword.value : defaultPassword;

  /// Infos complètes pour l'affichage
  String get platformInfoSummary {
    if (!platformConnected.value) return 'Non connecté';
    return '${firmwareVersion.value} | '
        '${sensorsCount.value} sensors | '
        '${ledsCount.value} LEDs';
  }

  // ============================================
  // LED BRIGHTNESS
  // ============================================
  Future<void> setLedBrightness(int value) async {
    final clamped = value.clamp(10, 255);
    ledBrightness.value = clamped;
    await _storage.write(_keyLedBrightness, clamped);

    // Envoi en temps réel à l'ESP32
    _sendConfigToEsp32({'led_brightness': clamped});

    if (kDebugMode) print('💡 LED brightness → $clamped');
  }

  // ============================================
  // DETECTION COOLDOWN
  // ============================================
  Future<void> setDetectionCooldown(int ms) async {
    final clamped = ms.clamp(500, 5000);
    detectionCooldown.value = clamped;
    await _storage.write(_keyDetectionCooldown, clamped);

    _sendConfigToEsp32({'detection_cooldown': clamped});

    if (kDebugMode) print('⏱ Detection cooldown → ${clamped}ms');
  }

  // ============================================
  // DEBOUNCE
  // ============================================
  Future<void> setDebounceMs(int ms) async {
    final clamped = ms.clamp(10, 200);
    debounceMs.value = clamped;
    await _storage.write(_keyDebounceMs, clamped);

    _sendConfigToEsp32({'debounce_ms': clamped});

    if (kDebugMode) print('🎯 Debounce → ${clamped}ms');
  }

  // ============================================
  // AUTO CONNECT
  // ============================================
  Future<void> setAutoConnect(bool value) async {
    autoConnect.value = value;
    await _storage.write(_keyAutoConnect, value);

    if (kDebugMode) print('🔌 Auto-connect → $value');
  }

  // ============================================
  // DEVICE NAME (pour l'affichage dans clients info)
  // ============================================
  Future<void> setDeviceName(String name) async {
    if (name.trim().isEmpty) return;
    configDeviceName.value = name.trim();
    await _storage.write(_keyDeviceName, name.trim());

    // Re-declare avec le nouveau nom
    _ws.setClientRole(
      _ws.clientRole.value,
      deviceName: name.trim(),
    );

    if (kDebugMode) print('📱 Device name → ${name.trim()}');
  }

  // ============================================
  // CHANGE WIFI CREDENTIALS (sur ESP32)
  // ============================================
  Future<bool> updateWifiCredentials({
    required String ssid,
    required String password,
  }) async {
    if (ssid.trim().isEmpty) {
      if (kDebugMode) print('❌ SSID cannot be empty');
      return false;
    }
    if (password.length < 8) {
      if (kDebugMode) print('❌ Password must be at least 8 characters');
      return false;
    }

    try {
      // Sauvegarde en local
      customSsid.value = ssid.trim();
      customPassword.value = password;
      await _storage.write(_keyCustomSsid, ssid.trim());
      await _storage.write(_keyCustomPassword, password);

      // Envoi à l'ESP32 (avec demande de redémarrage)
      _sendConfigToEsp32({
        'wifi_ssid': ssid.trim(),
        'wifi_password': password,
        'restart': true,
      });

      if (kDebugMode) {
        print('📶 WiFi credentials updated:');
        print('   SSID: ${ssid.trim()}');
        print('   Password: ${'*' * password.length}');
        print('   ⚠️ ESP32 will restart');
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ WiFi update error: $e');
      return false;
    }
  }

  // ============================================
  // OTA FIRMWARE UPDATE (Feature future)
  // ============================================
  Future<bool> requestOtaUpdate(String firmwareUrl) async {
    if (!_ws.isConnected) {
      if (kDebugMode) print('❌ Cannot OTA: not connected');
      return false;
    }

    try {
      _sendConfigToEsp32({
        'ota_url': firmwareUrl,
        'ota_start': true,
      });

      if (kDebugMode) print('🔄 OTA update requested: $firmwareUrl');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ OTA error: $e');
      return false;
    }
  }

  // ============================================
  // SEND ALL CURRENT CONFIG TO ESP32
  // ============================================
  /// Envoie toute la configuration actuelle à l'ESP32
  /// Utile après une reconnexion ou un reset
  Future<void> syncAllToEsp32() async {
    if (!_ws.isConnected) {
      if (kDebugMode) print('⚠️ Cannot sync: not connected');
      return;
    }

    if (kDebugMode) print('🔄 Syncing all config to ESP32...');

    _sendConfigToEsp32({
      'led_brightness': ledBrightness.value,
      'detection_cooldown': detectionCooldown.value,
      'debounce_ms': debounceMs.value,
    });

    if (kDebugMode) print('✅ Config synced to ESP32');
  }

  // ============================================
  // RESET PLATFORM TO DEFAULTS
  // ============================================
  Future<void> resetPlatformToDefaults() async {
    // Reset local
    customSsid.value = '';
    customPassword.value = '';
    ledBrightness.value = defaultLedBrightness;
    detectionCooldown.value = defaultDetectionCooldown;
    debounceMs.value = defaultDebounceMs;

    // Persistence
    await _storage.remove(_keyCustomSsid);
    await _storage.remove(_keyCustomPassword);
    await _storage.write(_keyLedBrightness, defaultLedBrightness);
    await _storage.write(_keyDetectionCooldown, defaultDetectionCooldown);
    await _storage.write(_keyDebounceMs, defaultDebounceMs);

    // Envoi à l'ESP32
    _sendConfigToEsp32({
      'reset_to_defaults': true,
    });

    if (kDebugMode) print('🔄 Platform reset to defaults');
  }

  // ============================================
  // RESET ALL APP DATA
  // ============================================
  Future<void> resetAllAppData() async {
    await _storage.erase();
    _loadSettings(); // Recharge les valeurs par défaut

    if (kDebugMode) print('🗑 All app data erased');
  }

  // ============================================
  // PRIVATE — Envoi config à l'ESP32
  // ============================================
  void _sendConfigToEsp32(Map<String, dynamic> config) {
    if (!_ws.isConnected) {
      if (kDebugMode) print('⚠️ Cannot send config: not connected');
      return;
    }

    _ws.sendCommand({
      'type': 'config',
      ...config,
    });

    if (kDebugMode) {
      print('📤 Config sent to ESP32: $config');
    }
  }

  // ============================================
  // EXPORT / IMPORT
  // ============================================

  /// Exporte tous les paramètres en Map
  Map<String, dynamic> exportSettings() {
    return {
      'platform_config_version': 1,
      'customSsid': customSsid.value,
      'customPassword': customPassword.value,
      'ledBrightness': ledBrightness.value,
      'detectionCooldown': detectionCooldown.value,
      'debounceMs': debounceMs.value,
      'autoConnect': autoConnect.value,
      'configDeviceName': configDeviceName.value,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Importe les paramètres depuis un Map
  Future<bool> importSettings(Map<String, dynamic> data) async {
    try {
      if (data['platform_config_version'] != 1) {
        if (kDebugMode) print('❌ Invalid config version');
        return false;
      }

      if (data['customSsid'] != null) {
        customSsid.value = data['customSsid'] as String;
        await _storage.write(_keyCustomSsid, customSsid.value);
      }
      if (data['customPassword'] != null) {
        customPassword.value = data['customPassword'] as String;
        await _storage.write(_keyCustomPassword, customPassword.value);
      }
      if (data['ledBrightness'] != null) {
        await setLedBrightness((data['ledBrightness'] as num).toInt());
      }
      if (data['detectionCooldown'] != null) {
        await setDetectionCooldown(
            (data['detectionCooldown'] as num).toInt());
      }
      if (data['debounceMs'] != null) {
        await setDebounceMs((data['debounceMs'] as num).toInt());
      }
      if (data['autoConnect'] != null) {
        await setAutoConnect(data['autoConnect'] as bool);
      }
      if (data['configDeviceName'] != null) {
        await setDeviceName(data['configDeviceName'] as String);
      }

      if (kDebugMode) print('✅ Settings imported successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Import error: $e');
      return false;
    }
  }
}