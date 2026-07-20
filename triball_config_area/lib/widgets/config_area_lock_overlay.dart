import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../core/constants/game_constants.dart';
import '../core/controllers/config_broadcaster_controller.dart';
import '../core/services/game_session_guard_service.dart';
import '../core/theme/theme_colors.dart';

class ConfigAreaLockOverlay extends StatelessWidget {
  final Widget child;
  const ConfigAreaLockOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final guard = Get.find<GameSessionGuardService>();
    final broadcaster = Get.find<ConfigBroadcasterController>();

    return Obx(() {
      if (!guard.isLocked) return child;
      final status = broadcaster.remoteGameStatus.value;

      return Stack(
        children: [
          AbsorbPointer(absorbing: true, child: child),
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withOpacity(0.92),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, color: ThemeColors.warning, size: 64.sp),
                        SizedBox(height: 18.h),
                        Text(
                          'session_locked_title'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: ThemeColors.warning,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'session_locked_message'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 12.sp,
                            color: ThemeColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 22.h),
                        _StatusPanel(
                          state: status?.state ?? guard.remoteState.value,
                          player: status?.currentPlayerName,
                          elapsed: status?.elapsedFormatted ?? '--:--',
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: () => _showAdminDialog(guard),
                          icon: const Icon(Icons.admin_panel_settings),
                          label: Text('admin_unlock'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.warning,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 14.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _showAdminDialog(GameSessionGuardService guard) async {
    final codeController = TextEditingController();
    await Get.dialog<void>(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: Text('admin_access'.tr),
        content: TextField(
          controller: codeController,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: 'enter_admin_code'.tr,
            counterText: '',
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              final ok = guard.verifyAndGrantAdmin(
                codeController.text,
                GameConstants.adminSecurityCode,
              );
              if (ok) {
                Get.back();
              } else {
                Get.snackbar('error'.tr, 'invalid_security_code'.tr);
              }
            },
            child: Text('unlock_admin'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    codeController.dispose();
  }
}

class _StatusPanel extends StatelessWidget {
  final String state;
  final String? player;
  final String elapsed;
  const _StatusPanel({required this.state, this.player, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ThemeColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.warning.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(state.toUpperCase(), style: TextStyle(
            fontFamily: 'Orbitron', color: ThemeColors.warning,
            fontWeight: FontWeight.w800, fontSize: 14.sp,
          )),
          if (player != null) ...[
            SizedBox(height: 8.h),
            Text(player!, style: TextStyle(
              fontFamily: 'Orbitron', color: ThemeColors.textPrimary,
              fontSize: 16.sp,
            )),
          ],
          SizedBox(height: 6.h),
          Text(elapsed, style: TextStyle(
            fontFamily: 'Orbitron', color: ThemeColors.textSecondary,
            fontSize: 14.sp,
          )),
        ],
      ),
    );
  }
}
