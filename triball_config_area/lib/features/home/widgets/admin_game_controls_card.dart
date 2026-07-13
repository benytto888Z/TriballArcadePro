
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/controllers/config_broadcaster_controller.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../widgets/themed_button.dart';
import '../../../widgets/themed_card.dart';
import '../../../widgets/themed_text.dart';

class AdminGameControlCard extends StatelessWidget {
  const AdminGameControlCard();

  @override
  Widget build(BuildContext context) {
    final broadcaster = Get.find<ConfigBroadcasterController>();
    final audio = Get.find<AudioService>();
    final isUnlocked = false.obs;

    return ThemedCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            children: [
              Icon(Icons.admin_panel_settings,
                  color: ThemeColors.warning, size: 22.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: ThemedText.title(
                  'admin_controls'.tr,
                  fontSize: 14.sp,
                  color: ThemeColors.warning,
                ),
              ),
              // Lock/Unlock indicator
              Obx(() => Icon(
                isUnlocked.value ? Icons.lock_open : Icons.lock,
                color: isUnlocked.value
                    ? ThemeColors.success
                    : ThemeColors.textSecondary,
                size: 18.sp,
              )),
            ],
          ),
          SizedBox(height: 12.h),

          // ===== UNLOCK BUTTON ou CONTROLS =====
          Obx(() {
            if (!isUnlocked.value) {
              // ===== LOCKED STATE =====
              return InkWell(
                onTap: () => _showAdminCodeDialog(isUnlocked),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: ThemeColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ThemeColors.warning.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock,
                          color: ThemeColors.warning, size: 18.sp),
                      SizedBox(width: 10.w),
                      Text(
                        'unlock_admin'.tr,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.warning,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ===== UNLOCKED STATE =====
            return Column(
              children: [
                // Status du Game Area
                Obx(() {
                  final status = broadcaster.remoteGameStatus.value;
                  final isGamePlaying = status?.isPlaying ?? false;
                  final isPaused = status?.state == 'paused';

                  return Column(
                    children: [
                      // Status indicator
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: (isGamePlaying
                              ? ThemeColors.success
                              : isPaused
                              ? ThemeColors.warning
                              : ThemeColors.textSecondary)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (isGamePlaying
                                ? ThemeColors.success
                                : isPaused
                                ? ThemeColors.warning
                                : ThemeColors.textSecondary)
                                .withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isGamePlaying
                                  ? Icons.play_circle
                                  : isPaused
                                  ? Icons.pause_circle
                                  : Icons.circle_outlined,
                              color: isGamePlaying
                                  ? ThemeColors.success
                                  : isPaused
                                  ? ThemeColors.warning
                                  : ThemeColors.textSecondary,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              isGamePlaying
                                  ? 'state_playing'.tr
                                  : isPaused
                                  ? 'state_paused'.tr
                                  : 'state_waiting'.tr,
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: isGamePlaying
                                    ? ThemeColors.success
                                    : isPaused
                                    ? ThemeColors.warning
                                    : ThemeColors.textSecondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // ===== PAUSE / RESUME BUTTONS =====
                      Row(
                        children: [
                          Expanded(
                            child: ThemedButton(
                              label: 'pause'.tr,
                              icon: Icons.pause,
                              variant: ButtonVariant.secondary,
                              height: 46.h,
                              fontSize: 12.sp,
                              onPressed: isGamePlaying
                                  ? () {
                                audio.playSfx(
                                    AssetPaths.audioButtonPress);
                                broadcaster.remotePause();
                              }
                                  : null,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: ThemedButton(
                              label: 'resume'.tr,
                              icon: Icons.play_arrow,
                              variant: ButtonVariant.primary,
                              height: 46.h,
                              fontSize: 12.sp,
                              onPressed: isPaused
                                  ? () {
                                audio.playSfx(
                                    AssetPaths.audioButtonPress);
                                broadcaster.remoteResume();
                              }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // ===== STOP GAME =====
                      ThemedButton(
                        label: 'stop_game_remote_btn'.tr,
                        icon: Icons.stop,
                        variant: ButtonVariant.ghost,
                        fullWidth: true,
                        height: 40.h,
                        fontSize: 11.sp,
                        onPressed: (isGamePlaying || isPaused)
                            ? () {
                          audio.playSfx(AssetPaths.audioButtonPress);
                          broadcaster.sendStopGame();
                        }
                            : null,
                      ),
                    ],
                  );
                }),
                SizedBox(height: 10.h),

                // ===== LOCK BUTTON =====
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      isUnlocked.value = false;
                      audio.playSfx(AssetPaths.audioButtonPress);
                    },
                    icon: Icon(Icons.lock,
                        color: ThemeColors.textSecondary, size: 14.sp),
                    label: Text(
                      'lock_admin'.tr,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: ThemeColors.textSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showAdminCodeDialog(RxBool isUnlocked) {
    final codeCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: Row(
          children: [
            Icon(Icons.lock, color: ThemeColors.warning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'admin_access'.tr,
                style: TextStyle(color: ThemeColors.warning),
              ),
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
            const SizedBox(height: 16),
            TextField(
              controller: codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              autofocus: true,
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
                hintStyle: TextStyle(
                  fontSize: 28,
                  color: ThemeColors.textSecondary.withOpacity(0.3),
                  letterSpacing: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  BorderSide(color: ThemeColors.warning, width: 2),
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
            onPressed: () {
              if (codeCtrl.text == GameConstants.adminCode) {
                isUnlocked.value = true;
                Get.back();
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
}