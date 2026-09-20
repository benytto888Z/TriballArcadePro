// triball_game_area/lib/features/waiting/widgets/admin_exit_zone.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/services/avatar_storage_service.dart';
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
            // ✅ Diagnostic du stockage des avatars (support sur site)
            ListTile(
              leading: Icon(Icons.photo_library_outlined,
                  color: ThemeColors.primary),
              title: Text('admin_avatar_diagnostics'.tr),
              onTap: () async {
                Get.back();
                await _showAvatarDiagnostics();
              },
            ),
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

  // ============================================
  // ✅ DIAGNOSTIC AVATARS — où sont les .jpg du top 10 ?
  // ============================================
  /// Le dossier est choisi à l'exécution (exe -> cwd -> Documents -> Temp) et
  /// n'est donc pas toujours celui qu'on attend. Cet écran de support affiche le
  /// chemin réellement utilisé et les fichiers présents, sans brancher de console.
  Future<void> _showAvatarDiagnostics() async {
    AvatarStorageService? service;
    try {
      service = Get.find<AvatarStorageService>();
    } catch (_) {
      service = null; // service absent (ne doit pas arriver : permanent dans main)
    }

    final dir = service?.avatarsDirectory;
    final files = service == null ? <String>[] : await service!.listAvatarFiles();

    if (!mounted) return;
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: Text(
          'admin_avatar_diagnostics'.tr,
          style: TextStyle(color: ThemeColors.primary, fontSize: 16),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _diagRow(
                  'avatar_storage_state'.tr,
                  service != null && service.isAvatarStorageReady
                      ? 'avatar_storage_ready'.tr
                      : 'avatar_storage_unavailable'.tr,
                  ok: service != null && service.isAvatarStorageReady,
                ),
                const SizedBox(height: 8),
                _diagRow('avatar_storage_dir'.tr, dir ?? '—'),
                const SizedBox(height: 8),
                _diagRow(
                  '${'avatar_storage_files'.tr} (${files.length})',
                  files.isEmpty
                      ? 'avatar_storage_empty'.tr
                      : files.take(15).join('\n'),
                ),
                if (files.length > 15)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '… +${files.length - 15}',
                      style: const TextStyle(color: ThemeColors.textSecondary),
                    ),
                  ),
                if (dir == null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'avatar_storage_no_dir'.tr,
                    style: TextStyle(
                      color: ThemeColors.warning,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          if (dir != null)
            TextButton(
              onPressed: () => _openAvatarsFolder(dir),
              child: Text('avatar_storage_open'.tr),
            ),
          if (dir != null)
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: dir));
                Get.snackbar(
                  'success'.tr,
                  'avatar_storage_copied'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: ThemeColors.success.withOpacity(0.9),
                  colorText: Colors.white,
                );
              },
              child: Text('avatar_storage_copy_path'.tr),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }

  Widget _diagRow(String label, String value, {bool? ok}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: ThemeColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: ok == null
                  ? ThemeColors.textPrimary
                  : (ok ? ThemeColors.success : ThemeColors.error),
              fontSize: 12,
              fontFamily: 'Consolas',
            ),
          ),
        ),
      ],
    );
  }

  /// Note: `explorer` renvoie un code de sortie non nul même en cas de succès
  /// sous Windows -> on ne teste pas exitCode.
  Future<void> _openAvatarsFolder(String path) async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer', [path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [path]);
      }
    } catch (_) {
      // Ouvrir le dossier n'est jamais bloquant pour le jeu.
    }
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