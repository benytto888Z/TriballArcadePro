// triball_config_area/lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/game_constants.dart';
import '../../core/services/game_settings_service.dart';
import '../../core/theme/theme_colors.dart';
import '../../widgets/floating_particles.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/themed_button.dart';
import '../../widgets/themed_card.dart';
import '../../widgets/theme_selector.dart';
import '../../widgets/language_selector.dart';
import 'settings_controller.dart';
import 'widgets/game_area_info_card.dart';
import 'widgets/audio_settings_card.dart';
import 'widgets/tts_settings_card.dart';
import 'widgets/wifi_config_card.dart';
import 'widgets/platform_info_card.dart';
import 'widgets/data_management_card.dart';
import 'widgets/about_card.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundDeep,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: ThemeColors.backgroundGradient,
            ),
          ),
          const FloatingParticles(count: 10),
          SafeArea(
            child: Column(
              children: [
                // ============================================
                // HEADER
                // ============================================
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: controller.onBackPressed,
                        icon: Icon(Icons.arrow_back,
                            color: ThemeColors.primary, size: 28.h),
                      ),
                      SizedBox(width: 8.w),
                      ThemedText.headline(
                        'settings_title'.tr,
                        fontSize: 26.h,
                        withGlow: true,
                        color: ThemeColors.primary,
                      ),
                    ],
                  ),
                ),

                // ============================================
                // SCROLLABLE CONTENT
                // ============================================
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ===== 1. GAME AREA STATUS =====
                        const GameAreaInfoCard(),
                        SizedBox(height: 12.h),

                        // ===== 2. THEME =====
                        ThemedCard(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.palette,
                                      color: ThemeColors.primary,
                                      size: 24.h),
                                  SizedBox(width: 10.w),
                                  ThemedText.title(
                                      'theme'.tr, fontSize: 24.h),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    const ThemeSelector(),
                                    SizedBox(width: 8.w),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // ===== 3. LANGUAGE =====
                        ThemedCard(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.language,
                                      color: ThemeColors.primary,
                                      size: 24.h),
                                  SizedBox(width: 10.w),
                                  ThemedText.title(
                                      'language'.tr, fontSize: 24.h),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    const LanguageSelector(),
                                    SizedBox(width: 8.w),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // ===== 4. PLATFORM STATUS =====
                        const _PlatformStatusCard(),
                        SizedBox(height: 12.h),

                        // ===== 5. GAME SETTINGS =====
                        const _GameSettingsCard(),
                        SizedBox(height: 12.h),

                        // ===== 6. AUDIO =====
                        const AudioSettingsCard(),
                        SizedBox(height: 12.h),

                        // ===== 7. TTS =====
                        const TtsSettingsCard(),
                        SizedBox(height: 12.h),

                        // ===== 8. WIFI CONFIG =====
                        const WifiConfigCard(),
                        SizedBox(height: 12.h),

                        // ===== 9. PLATFORM INFO =====
                        const PlatformInfoCard(),
                        SizedBox(height: 12.h),

                        // ===== 10. DATA MANAGEMENT =====
                        const DataManagementCard(),
                        SizedBox(height: 12.h),

                        // ===== 11. ABOUT =====
                        const AboutCard(),
                        SizedBox(height: 16.h),

                        // ===== BACK BUTTON =====
                        Center(
                          child: ThemedButton(
                            label: 'back'.tr,
                            icon: Icons.arrow_back,
                            variant: ButtonVariant.ghost,
                            width: 200.w,
                            onPressed: controller.onBackPressed,
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
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
}

// ============================================================
// 4. PLATFORM STATUS CARD
// ============================================================
class _PlatformStatusCard extends GetView<SettingsController> {
  const _PlatformStatusCard();

  @override
  Widget build(BuildContext context) {
    return ThemedCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.router,
                  color: ThemeColors.primary, size: 22.h),
              SizedBox(width: 10.w),
              ThemedText.title(
                  'platform_status'.tr, fontSize: 16.h),
              const Spacer(),
              Obx(() => _EspStatusBadge(
                isConnected: controller.ws.isConnected,
              )),
            ],
          ),
          SizedBox(height: 14.h),

          // Infos
          Obx(() => Column(
            children: [
              _SimpleInfoRow(
                label: 'wifi_ssid'.tr,
                value: controller.wifiSsid,
              ),
              SizedBox(height: 6.h),
              _SimpleInfoRow(
                label: 'ip_address'.tr,
                value: controller.ipAddress,
              ),
              SizedBox(height: 6.h),
              _SimpleInfoRow(
                label: 'port'.tr,
                value: '${controller.port}',
              ),
              SizedBox(height: 6.h),
              _SimpleInfoRow(
                label: 'ping'.tr,
                value: '${controller.ws.pingLatencyMs.value}ms',
              ),
              SizedBox(height: 6.h),
              _SimpleInfoRow(
                label: 'last_message'.tr,
                value: controller.lastMessageFormatted,
              ),
              SizedBox(height: 6.h),
              _SimpleInfoRow(
                label: 'msg_received'.tr,
                value: '${controller.ws.messagesReceived.value}',
              ),
              SizedBox(height: 6.h),
              _SimpleInfoRow(
                label: 'msg_sent'.tr,
                value: '${controller.ws.messagesSent.value}',
              ),
            ],
          )),
          SizedBox(height: 12.h),

          // Actions
          Obx(() {
            final isConnected = controller.ws.isConnected;
            final isBusy = controller.ws.isConnecting;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ThemedButton(
                    label: 'connect'.tr,
                    icon: Icons.link,
                    variant: ButtonVariant.primary,
                    width: 100.w,
                    height: 36.h,
                    fontSize: 11.h,
                    onPressed: (isConnected || isBusy)
                        ? null
                        : controller.onConnectPressed,
                  ),
                  SizedBox(width: 6.w),
                  ThemedButton(
                    label: 'disconnect'.tr,
                    icon: Icons.link_off,
                    variant: ButtonVariant.secondary,
                    width: 110.w,
                    height: 36.h,
                    fontSize: 11.h,
                    onPressed: isConnected
                        ? controller.onDisconnectPressed
                        : null,
                  ),
                  SizedBox(width: 6.w),
                  ThemedButton(
                    label: 'reconnect'.tr,
                    icon: Icons.refresh,
                    variant: ButtonVariant.accent,
                    width: 110.w,
                    height: 36.h,
                    fontSize: 11.h,
                    onPressed:
                    isBusy ? null : controller.onReconnectPressed,
                  ),
                  SizedBox(width: 6.w),
                  ThemedButton(
                    label: 'ping'.tr,
                    icon: Icons.network_ping,
                    variant: ButtonVariant.ghost,
                    width: 80.w,
                    height: 36.h,
                    fontSize: 11.h,
                    onPressed:
                    isConnected ? controller.onPingPressed : null,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// 5. GAME SETTINGS CARD (Turn timer + Warning + Transition + Leaderboard display)
// ============================================================
class _GameSettingsCard extends StatelessWidget {
  const _GameSettingsCard();

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<GameSettingsService>();

    return ThemedCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.tune, color: ThemeColors.primary, size: 22.h),
              SizedBox(width: 10.w),
              ThemedText.title('game_settings'.tr, fontSize: 16.h),
            ],
          ),
          SizedBox(height: 16.h),

          // Turn duration
          Obx(() => _SettingsSlider(
            icon: Icons.timer,
            label: 'turn_duration'.tr,
            value: settings.turnDurationSeconds.value.toDouble(),
            min: 10,
            max: 120,
            divisions: 22,
            displayValue: '${settings.turnDurationSeconds.value}s',
            onChanged: (v) =>
                settings.setTurnDuration(v.toInt()),
          )),
          SizedBox(height: 10.h),

          // Turn warning
          Obx(() => _SettingsSlider(
            icon: Icons.warning_amber,
            label: 'turn_warning'.tr,
            value: settings.turnWarningSeconds.value.toDouble(),
            min: 3,
            max: 30,
            divisions: 27,
            displayValue: '${settings.turnWarningSeconds.value}s',
            onChanged: (v) =>
                settings.setTurnWarning(v.toInt()),
          )),
          SizedBox(height: 10.h),

          // Transition delay
          Obx(() => _SettingsSlider(
            icon: Icons.swap_horiz,
            label: 'transition_delay'.tr,
            value: settings.transitionDelaySeconds.value.toDouble(),
            min: 2,
            max: 15,
            divisions: 13,
            displayValue: '${settings.transitionDelaySeconds.value}s',
            onChanged: (v) =>
                settings.setTransitionDelay(v.toInt()),
          )),
          SizedBox(height: 10.h),

          // ✅ NEW : Leaderboard display duration
          Obx(() => _SettingsSlider(
            icon: Icons.leaderboard,
            label: 'leaderboard_display_duration'.tr,
            value: settings.leaderboardDisplaySeconds.value.toDouble(),
            min: 10,
            max: 120,
            divisions: 22,
            displayValue: '${settings.leaderboardDisplaySeconds.value}s',
            onChanged: (v) =>
                settings.setLeaderboardDisplaySeconds(v.toInt()),
          )),
          SizedBox(height: 8.h),
          Obx(() => _SettingsSlider(
            icon: Icons.emoji_events,
            label: 'victory_display_duration'.tr,
            value: settings.victoryDisplaySeconds.value.toDouble(),
            min: 5,
            max: 60,
            divisions: 11,
            displayValue: '${settings.victoryDisplaySeconds.value}s',
            onChanged: (v) => settings.setVictoryDisplaySeconds(v.toInt()),
          )),

          // Reset button
          Center(
            child: TextButton.icon(
              onPressed: () => settings.resetToDefaults(),
              icon: Icon(Icons.refresh,
                  color: ThemeColors.textSecondary, size: 14.h),
              label: Text(
                'reset_to_defaults'.tr,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: ThemeColors.textSecondary,
                  fontSize: 11.h,
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
// REUSABLE WIDGETS
// ============================================================

class _EspStatusBadge extends StatelessWidget {
  final bool isConnected;

  const _EspStatusBadge({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final color =
    isConnected ? ThemeColors.success : ThemeColors.error;
    final label = isConnected ? 'connected'.tr : 'disconnected'.tr;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 10.h,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SimpleInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _SimpleInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120.w,
          child: ThemedText.caption(
            label,
            fontSize: 12.h,
            color: ThemeColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12.h,
              fontWeight: FontWeight.w600,
              color: ThemeColors.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SettingsSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SettingsSlider({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: ThemeColors.primary, size: 16.h),
            SizedBox(width: 8.w),
            Expanded(
              child: ThemedText.body(
                label,
                fontSize: 13.h,
                color: ThemeColors.textPrimary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: ThemeColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ThemeColors.primary.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Text(
                displayValue,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12.h,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.primary,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape:
            const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape:
            const RoundSliderOverlayShape(overlayRadius: 14),
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
    );
  }
}