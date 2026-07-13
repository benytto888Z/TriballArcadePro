// lib/features/settings/widgets/platform_info_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/controllers/websocket_controller.dart';
import '../../../core/services/platform_config_service.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../widgets/themed_card.dart';
import '../../../widgets/themed_text.dart';

class PlatformInfoCard extends StatelessWidget {
  const PlatformInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ws = Get.find<WebSocketController>();
    final config = Get.find<PlatformConfigService>();

    return ThemedCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            children: [
              Icon(Icons.memory, color: ThemeColors.primary, size: 22.h),
              SizedBox(width: 10.w),
              ThemedText.title('platform_info'.tr, fontSize: 16.h),
            ],
          ),
          SizedBox(height: 14.h),

          // ===== FIRMWARE INFO =====
          Obx(() {
            final info = ws.readyInfo.value;
            if (info == null) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: ThemeColors.textSecondary, size: 14.h),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ThemedText.caption(
                        'platform_not_connected'.tr,
                        fontSize: 11.h,
                        color: ThemeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                _InfoRow(
                  icon: Icons.developer_board,
                  label: 'firmware'.tr,
                  value: info.firmware,
                ),
                SizedBox(height: 8.h),
                _InfoRow(
                  icon: Icons.sensors,
                  label: 'sensors_count'.tr,
                  value: '${info.sensorsCount}',
                ),
                SizedBox(height: 8.h),
                _InfoRow(
                  icon: Icons.lightbulb_outline,
                  label: 'leds_count'.tr,
                  value: '${info.ledsCount}',
                ),
              ],
            );
          }),

          SizedBox(height: 10.h),

          // ===== STATUS LIVE =====
          Obx(() {
            final status = ws.currentStatus.value;
            if (status == null) return const SizedBox.shrink();
            return Column(
              children: [
                Divider(
                    color: ThemeColors.primary.withOpacity(0.2),
                    height: 1),
                SizedBox(height: 10.h),
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'uptime'.tr,
                  value: status.uptimeFormatted,
                ),
                SizedBox(height: 8.h),
                _InfoRow(
                  icon: Icons.memory,
                  label: 'free_heap'.tr,
                  value: status.freeHeapFormatted,
                ),
                SizedBox(height: 8.h),
                _InfoRow(
                  icon: Icons.devices,
                  label: 'connected_clients'.tr,
                  value: '${status.clientsCount}',
                ),
              ],
            );
          }),

          SizedBox(height: 14.h),
          Divider(
              color: ThemeColors.primary.withOpacity(0.2), height: 1),
          SizedBox(height: 14.h),

          // ===== HARDWARE TUNING =====
          ThemedText.caption(
            'hardware_tuning'.tr.toUpperCase(),
            fontSize: 10.h,
            color: ThemeColors.textSecondary,
          ),
          SizedBox(height: 8.h),

          // LED Brightness
          Obx(() => _SliderRow(
            icon: Icons.brightness_6,
            label: 'led_brightness'.tr,
            value: config.ledBrightness.value.toDouble(),
            min: 10,
            max: 255,
            divisions: 49,
            displayValue: '${config.ledBrightness.value}',
            onChanged: (v) => config.setLedBrightness(v.toInt()),
          )),

          // Detection cooldown
          Obx(() => _SliderRow(
            icon: Icons.timer,
            label: 'detection_cooldown'.tr,
            value: config.detectionCooldown.value.toDouble(),
            min: 500,
            max: 5000,
            divisions: 45,
            displayValue: '${config.detectionCooldown.value}ms',
            onChanged: (v) => config.setDetectionCooldown(v.toInt()),
          )),

          // Debounce
          Obx(() => _SliderRow(
            icon: Icons.tune,
            label: 'debounce'.tr,
            value: config.debounceMs.value.toDouble(),
            min: 10,
            max: 200,
            divisions: 19,
            displayValue: '${config.debounceMs.value}ms',
            onChanged: (v) => config.setDebounceMs(v.toInt()),
          )),

          SizedBox(height: 8.h),

          // Reset hardware button
          Center(
            child: TextButton.icon(
              onPressed: () => config.resetPlatformToDefaults(),
              icon: Icon(Icons.restore,
                  color: ThemeColors.textSecondary, size: 14.h),
              label: Text(
                'reset_hardware_defaults'.tr,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: ThemeColors.textSecondary,
                  fontSize: 10.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ThemeColors.textSecondary, size: 14.h),
        SizedBox(width: 10.w),
        Expanded(
          child: ThemedText.caption(
            label,
            fontSize: 11.h,
            color: ThemeColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 12.h,
            fontWeight: FontWeight.w700,
            color: ThemeColors.primary,
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ThemeColors.primary, size: 14.h),
              SizedBox(width: 8.w),
              Expanded(
                child: ThemedText.body(label, fontSize: 11.h),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: ThemeColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10.h,
                    color: ThemeColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              activeColor: ThemeColors.primary,
              inactiveColor: ThemeColors.primary.withOpacity(0.2),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}