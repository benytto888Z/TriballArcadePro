// triball_config_area/lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/theme/theme_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/animated_logo.dart';
import '../../widgets/floating_particles.dart';
import '../../widgets/game_area_status_indicator.dart';
import '../../widgets/home_menu_card.dart';
import '../../widgets/themed_text.dart';
import 'home_controller.dart';
import 'widgets/admin_game_controls_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundDeep,
      body: Stack(
        children: [
          // ============= BACKGROUND =============
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.background,
                  ThemeColors.backgroundDeep,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const FloatingParticles(count: 20),

          // ============= CONTENT =============
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: 22.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ============= LOGO =============
                  SizedBox(height: 20.h),
                  Center(
                    child: AnimatedLogo(
                      fontSize: 38,
                      subtitleFontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // ============= APP TYPE BADGE =============
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: ThemeColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ThemeColors.accent.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tune,
                              color: ThemeColors.accent, size: 14.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'CONFIG AREA',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: ThemeColors.accent,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ============= CONNECTION STATUS =============
                  GameAreaStatusIndicator(
                    showLabel: true,
                    compact: false,
                    onTap: () => Get.toNamed(AppRoutes.settings),
                  ),
                  SizedBox(height: 24.h),

                  // ============= MENU CARDS =============

                  // ===== TYPES DE MATCH =====
                  _SectionTitle(
                    icon: Icons.category,
                    label: 'match_type'.tr,
                  ),
                  SizedBox(height: 8.h),

                  HomeMenuCard(
                    icon: Icons.groups,
                    title: 'match_type_competition'.tr,
                    description: 'match_type_competition_desc'.tr,
                    accentColor: ThemeColors.primary,
                    onTap: controller.onCompetitionPressed,
                  ),
                  SizedBox(height: 10.h),

                  HomeMenuCard(
                    icon: Icons.timer,
                    title: 'match_type_solo_chrono'.tr,
                    description: 'match_type_solo_chrono_desc'.tr,
                    accentColor: ThemeColors.warning,
                    onTap: controller.onSoloChronoPressed,
                  ),
                  SizedBox(height: 10.h),

                  HomeMenuCard(
                    icon: Icons.emoji_events,
                    title: 'match_type_tournament'.tr,
                    description: 'match_type_tournament_desc'.tr,
                    accentColor: ThemeColors.accent,
                    onTap: controller.onTournamentPressed,
                  ),
                  SizedBox(height: 20.h),

                  // ===== UTILITAIRES =====
                  _SectionTitle(
                    icon: Icons.apps,
                    label: 'utilities'.tr,
                  ),
                  SizedBox(height: 8.h),

                  HomeMenuCard(
                    icon: Icons.leaderboard,
                    title: 'remote_leaderboard'.tr,
                    description: 'remote_leaderboard_short'.tr,
                    accentColor: ThemeColors.warning,
                    onTap: controller.onLeaderboardRemotePressed,
                  ),
                  SizedBox(height: 10.h),

                  HomeMenuCard(
                    icon: Icons.menu_book,
                    title: 'how_to_play'.tr,
                    description: 'how_to_play_subtitle'.tr,
                    accentColor: ThemeColors.tertiary,
                    onTap: controller.onHowToPlayPressed,
                  ),
                  SizedBox(height: 10.h),

                  HomeMenuCard(
                    icon: Icons.settings,
                    title: 'settings'.tr,
                    description: 'settings_title'.tr,
                    accentColor: ThemeColors.textSecondary,
                    onTap: controller.onSettingsPressed,
                  ),
                  SizedBox(height: 20.h),

                  // ===== ADMIN CONTROLS =====
                  _SectionTitle(
                    icon: Icons.admin_panel_settings,
                    label: 'admin_controls'.tr,
                  ),
                  SizedBox(height: 8.h),

                  const AdminGameControlCard(),
                  SizedBox(height: 20.h),

                  // ============= VERSION =============
                  Center(
                    child: Text(
                      'app_version'.tr,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: ThemeColors.textSecondary.withOpacity(0.5),
                        fontSize: 9.sp,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Row(
        children: [
          Icon(icon, color: ThemeColors.primary, size: 14.sp),
          SizedBox(width: 6.w),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: ThemeColors.primary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}