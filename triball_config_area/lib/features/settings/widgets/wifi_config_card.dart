// lib/features/settings/widgets/wifi_config_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/ esp32_config.dart';
import '../../../core/services/platform_config_service.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../widgets/themed_button.dart';
import '../../../widgets/themed_card.dart';
import '../../../widgets/themed_text.dart';

class WifiConfigCard extends StatelessWidget {
  const WifiConfigCard({super.key});

  @override
  Widget build(BuildContext context) {
    final config = Get.find<PlatformConfigService>();

    return ThemedCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            children: [
              Icon(Icons.wifi, color: ThemeColors.primary, size: 22.h),
              SizedBox(width: 10.w),
              ThemedText.title('wifi_settings'.tr, fontSize: 16.h),
            ],
          ),
          SizedBox(height: 14.h),

          // ===== CURRENT WIFI INFO =====
          _InfoRow(
            icon: Icons.network_wifi,
            label: 'current_ssid'.tr,
            value: config.customSsid.value.isEmpty
                ? Esp32Config.wifiSSID
                : config.customSsid.value,
          ),
          SizedBox(height: 8.h),
          _InfoRow(
            icon: Icons.vpn_key,
            label: 'current_password'.tr,
            value: config.customPassword.value.isEmpty
                ? Esp32Config.wifiPassword
                : config.customPassword.value,
            copyable: true,
          ),

          SizedBox(height: 14.h),
          Divider(
              color: ThemeColors.primary.withOpacity(0.2), height: 1),
          SizedBox(height: 14.h),

          // ===== AUTO CONNECT TOGGLE =====
          Obx(() => Row(
            children: [
              Icon(Icons.autorenew,
                  color: ThemeColors.primary, size: 16.h),
              SizedBox(width: 10.w),
              Expanded(
                child: ThemedText.body(
                  'auto_connect'.tr,
                  fontSize: 13.h,
                ),
              ),
              Switch(
                value: config.autoConnect.value,
                onChanged: (v) => config.setAutoConnect(v),
                activeColor: ThemeColors.primary,
              ),
            ],
          )),
          SizedBox(height: 10.h),

          // ===== CHANGE CREDENTIALS BUTTON =====
          Center(
            child: ThemedButton(
              label: 'change_wifi_credentials'.tr,
              icon: Icons.edit,
              variant: ButtonVariant.secondary,
              width: 240.w,
              height: 40.h,
              fontSize: 11.h,
              onPressed: () => _showChangeWifiDialog(),
            ),
          ),

          SizedBox(height: 8.h),

          // ===== WARNING =====
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: ThemeColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: ThemeColors.warning.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber,
                    color: ThemeColors.warning, size: 14.h),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'wifi_change_warning'.tr,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 9.h,
                      color: ThemeColors.warning,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CHANGE WIFI DIALOG
  // ============================================
  void _showChangeWifiDialog() {
    final config = Get.find<PlatformConfigService>();
    final ssidCtrl = TextEditingController(
      text: config.customSsid.value.isEmpty
          ? Esp32Config.wifiSSID
          : config.customSsid.value,
    );
    final passwordCtrl = TextEditingController(
      text: config.customPassword.value.isEmpty
          ? Esp32Config.wifiPassword
          : config.customPassword.value,
    );

    Get.dialog(
      Dialog(
        backgroundColor: ThemeColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: ThemeColors.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wifi,
                      color: ThemeColors.primary, size: 22.h),
                  SizedBox(width: 8.w),
                  ThemedText.title(
                    'change_wifi_credentials'.tr,
                    fontSize: 14.h,
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // SSID
              TextField(
                controller: ssidCtrl,
                maxLength: 32,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 13.h,
                  color: ThemeColors.textPrimary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'wifi_ssid'.tr,
                  labelStyle: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11.h,
                    color: ThemeColors.primary,
                  ),
                  prefixIcon: Icon(Icons.network_wifi,
                      color: ThemeColors.primary, size: 16.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Password
              TextField(
                controller: passwordCtrl,
                maxLength: 63,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 13.h,
                  color: ThemeColors.textPrimary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'wifi_password'.tr,
                  labelStyle: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11.h,
                    color: ThemeColors.primary,
                  ),
                  prefixIcon: Icon(Icons.lock,
                      color: ThemeColors.primary, size: 16.h),
                  helperText: 'password_min_8_chars'.tr,
                  helperStyle: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9.h,
                    color: ThemeColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'cancel'.tr,
                      style: TextStyle(color: ThemeColors.textSecondary),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () async {
                      final ssid = ssidCtrl.text.trim();
                      final password = passwordCtrl.text.trim();

                      if (ssid.isEmpty || password.length < 8) {
                        Helpers.showSnackbar(
                          'error'.tr,
                          'wifi_invalid'.tr,
                          color: ThemeColors.error,
                        );
                        return;
                      }

                      final success = await config.updateWifiCredentials(
                        ssid: ssid,
                        password: password,
                      );

                      Get.back();

                      if (success) {
                        Helpers.showSnackbar(
                          'success'.tr,
                          'wifi_updated'.tr,
                          color: ThemeColors.success,
                          icon: Icons.check_circle,
                        );
                      } else {
                        Helpers.showSnackbar(
                          'error'.tr,
                          'wifi_update_failed'.tr,
                          color: ThemeColors.error,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.primary,
                    ),
                    child: Text('apply'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ThemeColors.textSecondary, size: 16.h),
        SizedBox(width: 10.w),
        SizedBox(
          width: 110.w,
          child: ThemedText.caption(
            label,
            fontSize: 11.h,
            color: ThemeColors.textSecondary,
          ),
        ),
        Expanded(
          child: ThemedText.body(
            value,
            fontSize: 13.h,
            color: ThemeColors.textPrimary,
            fontWeight: FontWeight.w600,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (copyable)
          InkWell(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: value));
              Get.snackbar(
                'success'.tr,
                'copied_to_clipboard'.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: ThemeColors.success.withOpacity(0.9),
                colorText: Colors.white,
                duration: const Duration(seconds: 1),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(Icons.copy,
                  size: 14.h,
                  color: ThemeColors.primary.withOpacity(0.7)),
            ),
          ),
      ],
    );
  }
}