// triball_config_area/lib/features/settings/widgets/game_area_info_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/controllers/config_broadcaster_controller.dart';
import '../../../core/controllers/websocket_controller.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../../data/models/match_type_model.dart';
import '../../../widgets/themed_button.dart';
import '../../../widgets/themed_card.dart';
import '../../../widgets/themed_text.dart';
import '../settings_controller.dart';

class GameAreaInfoCard extends GetView<SettingsController> {
  const GameAreaInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final broadcaster = Get.find<ConfigBroadcasterController>();

    return ThemedCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            children: [
              Icon(Icons.tv, color: ThemeColors.primary, size: 22.h),
              SizedBox(width: 10.w),
              ThemedText.title('game_area_settings'.tr, fontSize: 16.h),
              const Spacer(),
              Obx(() => _StatusBadge(
                isConnected: broadcaster.hasGameAreaConnected,
                count: broadcaster.gameAreaCount.value,
              )),
            ],
          ),
          SizedBox(height: 14.h),

          // ===== GAME AREA COUNT =====
          Obx(() {
            final count = broadcaster.gameAreaCount.value;
            return _InfoRow(
              icon: Icons.connected_tv,
              label: 'game_area_connected_count'.tr,
              value: '$count',
              color: count > 0 ? ThemeColors.success : ThemeColors.error,
            );
          }),
          SizedBox(height: 8.h),

          // ===== GAME AREA PLAYING STATUS =====
          Obx(() {
            final status = broadcaster.remoteGameStatus.value;
            final isPlaying = broadcaster.gameAreaIsPlaying.value;

            return Column(
              children: [
                _InfoRow(
                  icon: isPlaying ? Icons.play_circle : Icons.pause_circle,
                  label: 'game_area_state'.tr,
                  value: status != null
                      ? _stateLabel(status.state)
                      : 'unknown'.tr,
                  color: isPlaying
                      ? ThemeColors.success
                      : ThemeColors.textSecondary,
                ),
                if (status != null && status.isPlaying) ...[
                  SizedBox(height: 8.h),
                  _InfoRow(
                    icon: Icons.person,
                    label: 'current_player_label'.tr,
                    value: status.currentPlayerName ?? '--',
                    color: ThemeColors.primary,
                  ),
                  SizedBox(height: 8.h),
                  _InfoRow(
                    icon: Icons.timer,
                    label: 'elapsed_time'.tr,
                    value: status.elapsedFormatted,
                    color: ThemeColors.warning,
                  ),
                ],
                if (status != null && status.isVictory) ...[
                  SizedBox(height: 8.h),
                  _InfoRow(
                    icon: Icons.emoji_events,
                    label: 'winner'.tr,
                    value: status.winnerName ?? '--',
                    color: ThemeColors.warning,
                  ),
                ],
              ],
            );
          }),

          SizedBox(height: 14.h),
          Divider(color: ThemeColors.primary.withOpacity(0.2), height: 1),
          SizedBox(height: 14.h),

          // ===== LAST CONFIG SENT =====
          Obx(() {
            final lastConfig = broadcaster.lastSentConfig.value;
            final lastSentAt = broadcaster.lastSentAt.value;

            if (lastConfig == null) {
              return _InfoRow(
                icon: Icons.send,
                label: 'last_config_sent'.tr,
                value: 'none'.tr,
                color: ThemeColors.textSecondary,
              );
            }

            final timeStr = lastSentAt != null
                ? '${lastSentAt.hour.toString().padLeft(2, '0')}:'
                '${lastSentAt.minute.toString().padLeft(2, '0')}:'
                '${lastSentAt.second.toString().padLeft(2, '0')}'
                : '--';

            return Column(
              children: [
                _InfoRow(
                  icon: Icons.send,
                  label: 'last_config_sent'.tr,
                  value: timeStr,
                  color: ThemeColors.success,
                ),
                SizedBox(height: 4.h),
                _InfoRow(
                  icon: Icons.category,
                  label: 'match_type'.tr,
                  value: lastConfig.matchType.translationKey.tr,
                  color: ThemeColors.primary,
                ),
                SizedBox(height: 4.h),
                _InfoRow(
                  icon: Icons.videogame_asset,
                  label: 'game_mode'.tr,
                  value:
                  '${lastConfig.mode.icon} ${lastConfig.mode.translationKey.tr}',
                  color: ThemeColors.primary,
                ),
              ],
            );
          }),

          SizedBox(height: 14.h),

          // ===== ACTIONS =====
          Row(
            children: [
              Expanded(
                child: ThemedButton(
                  label: 'refresh'.tr,
                  icon: Icons.refresh,
                  variant: ButtonVariant.secondary,
                  height: 38.h,
                  fontSize: 11.h,
                  onPressed: controller.onRefreshClientsPressed,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ThemedButton(
                  label: 'stop_game_remote_btn'.tr,
                  icon: Icons.stop,
                  variant: ButtonVariant.secondary,
                  height: 38.h,
                  fontSize: 11.h,
                  onPressed: () {
                   // controller.audio.playSfx(AssetPaths.audioButtonPress);
                    controller.broadcaster.sendStopGame();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _stateLabel(String state) {
    switch (state) {
      case 'waiting': return 'state_waiting'.tr;
      case 'countdown': return 'state_countdown'.tr;
      case 'playing': return 'state_playing'.tr;
      case 'victory': return 'state_victory'.tr;
      case 'game_over': return 'state_game_over'.tr;
      default: return state;
    }
  }
}

// ============================================================
// STATUS BADGE
// ============================================================
class _StatusBadge extends StatelessWidget {
  final bool isConnected;
  final int count;

  const _StatusBadge({required this.isConnected, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? ThemeColors.success : ThemeColors.error;
    final label = isConnected ? '$count ${'connected'.tr}' : 'disconnected'.tr;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10.h,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
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
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16.h),
        SizedBox(width: 10.w),
        Expanded(
          child: ThemedText.caption(
            label,
            fontSize: 12.h,
            color: ThemeColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 12.h,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}