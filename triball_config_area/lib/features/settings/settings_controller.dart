// triball_config_area/lib/features/settings/settings_controller.dart

import 'package:get/get.dart';
import '../../core/constants/ esp32_config.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/controllers/config_broadcaster_controller.dart';
import '../../core/controllers/websocket_controller.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/platform_config_service.dart';

class SettingsController extends GetxController {
  // ============================================
  // DEPENDENCIES
  // ============================================
  final WebSocketController ws = Get.find<WebSocketController>();
  final AudioService audio = Get.find<AudioService>();
  final PlatformConfigService platformConfig =
  Get.find<PlatformConfigService>();
  final ConfigBroadcasterController broadcaster =
  Get.find<ConfigBroadcasterController>();

  // ============================================
  // PLATFORM INFOS
  // ============================================
  String get wifiSsid => platformConfig.currentSsid;
  String get wifiPassword => platformConfig.currentPassword;
  String get ipAddress => Esp32Config.ip;
  int get port => Esp32Config.wsPort;

  // ============================================
  // LAST MESSAGE FORMATTED
  // ============================================
  String get lastMessageFormatted {
    final dt = ws.lastMessageTime.value;
    if (dt == null) return '--';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ============================================
  // ACTIONS
  // ============================================
  void onConnectPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    ws.connect();
  }

  void onDisconnectPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    ws.disconnect();
  }

  void onReconnectPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    ws.reconnect();
  }

  void onPingPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    ws.sendPing();
  }

  /// ✅ Force la re-déclaration du rôle
  void onRedeclarePressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    ws.setClientRole(
      ws.clientRole.value,
      deviceName: platformConfig.configDeviceName.value,
    );
  }

  /// ✅ Refresh info des clients connectés
  void onRefreshClientsPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    ws.requestClientsInfo();
  }

  void onBackPressed() {
    audio.playSfx(AssetPaths.audioButtonPress);
    Get.back();
  }
}