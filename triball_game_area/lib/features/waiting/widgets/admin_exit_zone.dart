// triball_game_area/lib/features/waiting/widgets/admin_exit_zone.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/platform_helper.dart';

class AdminExitZone extends StatefulWidget {
  const AdminExitZone({super.key});

  @override
  State<AdminExitZone> createState() => _AdminExitZoneState();
}

class _AdminExitZoneState extends State<AdminExitZone> {
  int _tapCount = 0;
  DateTime _lastTap = DateTime.now();

  void _onTap() {
    final now = DateTime.now();
    if (now.difference(_lastTap).inMilliseconds > 1500) {
      _tapCount = 0;
    }
    _lastTap = now;
    _tapCount++;

    if (_tapCount >= 5) {
      _tapCount = 0;
      _showAdminDialog();
    }
  }

  void _showAdminDialog() {
    final codeCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: ThemeColors.warning),
            SizedBox(width: 8),
            Text(
              'admin_access'.tr,
              style: TextStyle(color: ThemeColors.warning),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'enter_admin_code'.tr,
              style: TextStyle(color: ThemeColors.textSecondary),
            ),
            SizedBox(height: 16),
            TextField(
              controller: codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: ThemeColors.primary,
                letterSpacing: 10,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '• • • •',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              if (codeCtrl.text == GameConstants.leaderboardClearCode) {
                Get.back();
                _showExitOptions();
              } else {
                Get.snackbar(
                  'error'.tr,
                  'invalid_security_code'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: ThemeColors.error.withOpacity(0.9),
                  colorText: Colors.white,
                );
              }
            },
            child: Text(
              'confirm'.tr,
              style: TextStyle(color: ThemeColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitOptions() {
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: Text(
          'admin_options'.tr,
          style: TextStyle(color: ThemeColors.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle fullscreen
            ListTile(
              leading: Icon(Icons.fullscreen_exit, color: ThemeColors.primary),
              title: Text('toggle_fullscreen'.tr),
              onTap: () async {
                Get.back();
                if (PlatformHelper.isWindows) {
                  final isFullscreen = await windowManager.isFullScreen();
                  await windowManager.setFullScreen(!isFullscreen);
                  if (!isFullscreen) {
                    await windowManager.setAlwaysOnTop(true);
                  }
                }
              },
            ),
            // Toggle always on top
            ListTile(
              leading: Icon(Icons.push_pin, color: ThemeColors.primary),
              title: Text('toggle_always_on_top'.tr),
              onTap: () async {
                Get.back();
                if (PlatformHelper.isWindows) {
                  final isOnTop = await windowManager.isAlwaysOnTop();
                  await windowManager.setAlwaysOnTop(!isOnTop);
                }
              },
            ),
            Divider(color: ThemeColors.primary.withOpacity(0.3)),
            // Quit
            ListTile(
              leading: Icon(Icons.exit_to_app, color: ThemeColors.error),
              title: Text(
                'quit_app'.tr,
                style: TextStyle(color: ThemeColors.error),
              ),
              onTap: () async {
                Get.back();
                if (PlatformHelper.isWindows) {
                  await windowManager.setPreventClose(false);
                  await windowManager.close();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: 60.w,
        height: 60.h,
        color: Colors.transparent,
      ),
    );
  }
}