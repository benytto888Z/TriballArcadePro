// triball_config_area/lib/features/leaderboard_remote/leaderboard_remote_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/controllers/config_broadcaster_controller.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/theme_colors.dart';
import '../../data/models/game_state_model.dart';
import '../../widgets/floating_particles.dart';
import '../../widgets/themed_button.dart';
import '../../widgets/themed_card.dart';
import '../../widgets/themed_text.dart';

class LeaderboardRemoteScreen extends StatelessWidget {
  const LeaderboardRemoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final broadcaster = Get.find<ConfigBroadcasterController>();
    final audio = Get.find<AudioService>();
    final currentMode = ''.obs;
    final currentFilter = 'all'.obs;

    return Scaffold(
      backgroundColor: ThemeColors.backgroundDeep,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: ThemeColors.backgroundGradient,
            ),
          ),
          const FloatingParticles(count: 12),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  // ============= HEADER =============
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            audio.playSfx(AssetPaths.audioButtonPress);
                            Get.back();
                          },
                          icon: Icon(Icons.arrow_back,
                              color: ThemeColors.primary, size: 26.sp),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.tv, color: ThemeColors.primary,
                            size: 22.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ThemedText.headline(
                            'remote_leaderboard'.tr,
                            fontSize: 20.sp,
                            withGlow: true,
                            color: ThemeColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // ============= INFO =============
                  ThemedCard(
                    padding: EdgeInsets.all(14.w),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: ThemeColors.primary, size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'remote_leaderboard_desc'.tr,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 11.sp,
                              color: ThemeColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ============= STATUS =============
                  Obx(() {
                    final hasTV = broadcaster.hasGameAreaConnected;
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: (hasTV
                            ? ThemeColors.success
                            : ThemeColors.error)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (hasTV
                              ? ThemeColors.success
                              : ThemeColors.error)
                              .withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            hasTV ? Icons.tv : Icons.tv_off,
                            color: hasTV
                                ? ThemeColors.success
                                : ThemeColors.error,
                            size: 20.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            hasTV
                                ? 'game_area_ready'.tr
                                : 'no_game_area_connected'.tr,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 11.sp,
                              color: hasTV
                                  ? ThemeColors.success
                                  : ThemeColors.error,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),

                  // ============= MODE BUTTONS =============
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _RemoteModeButton(
                            mode: GameMode.classic,
                            icon: Icons.flag,
                            accentColor: ThemeColors.primary,
                            currentMode: currentMode,
                            onTap: () {
                              audio.playSfx(AssetPaths.audioCoinInsert);
                              currentMode.value = 'classic';
                              broadcaster.showLeaderboard(GameMode.classic);
                            },
                          ),
                          SizedBox(height: 10.h),
                          _RemoteModeButton(
                            mode: GameMode.hardcore,
                            icon: Icons.local_fire_department,
                            accentColor: ThemeColors.error,
                            currentMode: currentMode,
                            onTap: () {
                              audio.playSfx(AssetPaths.audioCoinInsert);
                              currentMode.value = 'hardcore';
                              broadcaster.showLeaderboard(GameMode.hardcore);
                            },
                          ),
                          SizedBox(height: 10.h),
                          _RemoteModeButton(
                            mode: GameMode.champion,
                            icon: Icons.workspace_premium,
                            accentColor: ThemeColors.tertiary,
                            currentMode: currentMode,
                            onTap: () {
                              audio.playSfx(AssetPaths.audioCoinInsert);
                              currentMode.value = 'champion';
                              broadcaster.showLeaderboard(GameMode.champion);
                            },
                          ),
                          SizedBox(height: 10.h),
                          _RemoteModeButton(
                            mode: GameMode.combo,
                            icon: Icons.bolt,
                            accentColor: ThemeColors.secondary,
                            currentMode: currentMode,
                            onTap: () {
                              audio.playSfx(AssetPaths.audioCoinInsert);
                              currentMode.value = 'combo';
                              broadcaster.showLeaderboard(GameMode.combo);
                            },
                          ),

                          SizedBox(height: 20.h),

// ============= DATE FILTER BUTTONS =============
                          ThemedText.title(
                            'select_filter'.tr,
                            fontSize: 14.sp,
                            color: ThemeColors.primary,
                          ),
                          SizedBox(height: 10.h),

                          Row(
                            children: [
                              Expanded(
                                child: _FilterButton(
                                  label: 'filter_all_time'.tr,
                                  filterKey: 'all',
                                  icon: Icons.all_inclusive,
                                  currentFilter: currentFilter,
                                  onTap: () {
                                    audio.playSfx(AssetPaths.audioButtonPress);
                                    currentFilter.value = 'all';
                                    broadcaster.changeLeaderboardFilter('all');
                                  },
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: _FilterButton(
                                  label: 'filter_today'.tr,
                                  filterKey: 'today',
                                  icon: Icons.today,
                                  currentFilter: currentFilter,
                                  onTap: () {
                                    audio.playSfx(AssetPaths.audioButtonPress);
                                    currentFilter.value = 'today';
                                    broadcaster.changeLeaderboardFilter('today');
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Expanded(
                                child: _FilterButton(
                                  label: 'filter_this_week'.tr,
                                  filterKey: 'this_week',
                                  icon: Icons.date_range,
                                  currentFilter: currentFilter,
                                  onTap: () {
                                    audio.playSfx(AssetPaths.audioButtonPress);
                                    currentFilter.value = 'this_week';
                                    broadcaster.changeLeaderboardFilter('this_week');
                                  },
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: _FilterButton(
                                  label: 'filter_this_month'.tr,
                                  filterKey: 'this_month',
                                  icon: Icons.calendar_month,
                                  currentFilter: currentFilter,
                                  onTap: () {
                                    audio.playSfx(AssetPaths.audioButtonPress);
                                    currentFilter.value = 'this_month';
                                    broadcaster.changeLeaderboardFilter('this_month');
                                  },
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ============= RETOUR WAITING =============
                  ThemedButton(
                    label: 'back_to_waiting_remote'.tr,
                    icon: Icons.home,
                    variant: ButtonVariant.ghost,
                    fullWidth: true,
                    height: 50.h,
                    fontSize: 13.sp,
                    onPressed: () {
                      audio.playSfx(AssetPaths.audioButtonPress);
                      currentMode.value = '';
                      broadcaster.showWaiting();
                    },
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoteModeButton extends StatelessWidget {
  final GameMode mode;
  final IconData icon;
  final Color accentColor;
  final RxString currentMode;
  final VoidCallback onTap;

  const _RemoteModeButton({
    required this.mode,
    required this.icon,
    required this.accentColor,
    required this.currentMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = currentMode.value == mode.key;

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 16.h,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? accentColor.withOpacity(0.2)
                : ThemeColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? accentColor : accentColor.withOpacity(0.4),
              width: isActive ? 2.5 : 1.5,
            ),
            boxShadow: isActive && ThemeColors.useGlow
                ? [
              BoxShadow(
                color: accentColor.withOpacity(0.5),
                blurRadius: 16,
              ),
            ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.translationKey.tr.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: isActive
                            ? accentColor
                            : ThemeColors.textPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      isActive
                          ? 'displaying_on_tv'.tr
                          : 'show_top10_on_tv'.tr,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 11.sp,
                        color: isActive
                            ? accentColor
                            : ThemeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isActive ? Icons.check_circle : Icons.send,
                color: isActive
                    ? accentColor
                    : accentColor.withOpacity(0.6),
                size: 22.sp,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final String filterKey;
  final IconData icon;
  final RxString currentFilter;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.filterKey,
    required this.icon,
    required this.currentFilter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = currentFilter.value == filterKey;

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? ThemeColors.secondary.withOpacity(0.2)
                : ThemeColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? ThemeColors.secondary
                  : ThemeColors.secondary.withOpacity(0.3),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive
                    ? ThemeColors.secondary
                    : ThemeColors.textSecondary,
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? ThemeColors.secondary
                        : ThemeColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}