// triball_game_area/lib/features/leaderboard/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/game_constants.dart';
import '../../core/theme/theme_colors.dart';
import '../../data/models/game_state_model.dart';
import '../../widgets/floating_particles.dart';
import '../../widgets/themed_text.dart';
import '../game/utils/game_screen_breakpoints.dart';
import 'leaderboard_controller.dart';
import 'widgets/empty_leaderboard.dart';
import 'widgets/leaderboard_disconnected.dart';
import 'widgets/leaderboard_entry_tile.dart';
import 'widgets/leaderboard_mode_tabs.dart';
import 'widgets/mode_filter_chips.dart';
import 'widgets/podium_widget.dart';
import 'widgets/stats_summary_card.dart';

class LeaderboardScreen extends GetView<LeaderboardController> {
  const LeaderboardScreen({super.key});

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
          FloatingParticles(
            count: GameScreenBreakpoints.particlesCount(),
          ),
          SafeArea(
            child: Column(
              children: [
                const _Header(),
                const LeaderboardModeTabs(),
                SizedBox(height: 8.h),
                Expanded(
                  child: Obx(() {
                    if (!controller.isConnected.value) {
                      return const LeaderboardDisconnected();
                    }
                    if (controller.isLoading.value) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: ThemeColors.primary,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16.h),
                            ThemedText.caption(
                              'loading_leaderboard'.tr,
                              fontSize: GameScreenBreakpoints.lbStatLabelFontSize(),
                            ),
                          ],
                        ),
                      );
                    }
                    if (controller.isEmpty) {
                      return const EmptyLeaderboard();
                    }
                    return const _Content();
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends GetView<LeaderboardController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GameScreenBreakpoints.lbScreenPaddingH(),
        vertical: 12.h,
      ),
      child: Row(
        children: [
          /*IconButton(
            onPressed: controller.onBackPressed,
            icon: Icon(
              Icons.arrow_back,
              color: ThemeColors.primary,
              size: GameScreenBreakpoints.lbHeaderIconSize(),
            ),
          ),
          SizedBox(width: 4.w),*/
          Icon(
            Icons.emoji_events,
            color: ThemeColors.primary,
            size: GameScreenBreakpoints.lbHeaderIconSize(),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ThemedText.headline(
              'leaderboard_title'.tr,
              fontSize: GameScreenBreakpoints.lbHeaderFontSize(),
              withGlow: true,
              color: ThemeColors.primary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          /*Obx(() {
            if (!controller.isConnected.value) return const SizedBox.shrink();
            return IconButton(
              onPressed: controller.refresh,
              icon: Icon(
                Icons.refresh,
                color: ThemeColors.primary,
                size: GameScreenBreakpoints.lbHeaderIconSize(),
              ),
            );
          }),*/
          /*Obx(() {
            if (controller.isEmpty || !controller.isConnected.value) {
              return const SizedBox.shrink();
            }
            return IconButton(
              onPressed: () => _confirmClear(),
              icon: Icon(
                Icons.delete_outline,
                color: ThemeColors.error,
                size: GameScreenBreakpoints.lbHeaderIconSize(),
              ),
            );
          }),*/
          Obx(() {
            if (!controller.autoReturnActive.value) return const SizedBox.shrink();
            final countdown = controller.autoReturnCountdown.value;
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: GameScreenBreakpoints.lbScreenPaddingH(),
                vertical: 6.h,
              ),
              color: ThemeColors.warning.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, color: ThemeColors.warning,
                      size: GameScreenBreakpoints.lbStatIconSize()),
                  SizedBox(width: 8.w),
                  Text(
                    '${'auto_return_in'.tr} $countdown s',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: GameScreenBreakpoints.lbStatLabelFontSize(),
                      color: ThemeColors.warning,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /*void _confirmClear() {
    final codeController = TextEditingController();
    final controller = Get.find<LeaderboardController>();

    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: Row(
          children: [
            Icon(Icons.lock, color: ThemeColors.warning),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'clear_leaderboard'.tr,
                style: TextStyle(color: ThemeColors.warning),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'clear_requires_code'.tr,
              style: TextStyle(
                color: ThemeColors.textSecondary,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: ThemeColors.primary,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '• • • •',
                hintStyle: TextStyle(
                  fontSize: 24,
                  color: ThemeColors.textSecondary.withOpacity(0.3),
                  letterSpacing: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ThemeColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ThemeColors.warning, width: 2),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'clear_mode_warning'.tr.replaceAll(
                '{mode}',
                controller.selectedMode.value.translationKey.tr,
              ),
              style: TextStyle(
                color: ThemeColors.error,
                fontSize: 11,
                fontStyle: FontStyle.italic,
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
              if (codeController.text == GameConstants.leaderboardClearCode) {
                Get.back();
                controller.clearCurrentMode();
                Get.snackbar(
                  'success'.tr,
                  'leaderboard_cleared'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: ThemeColors.success.withOpacity(0.9),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              } else {
                Get.snackbar(
                  'error'.tr,
                  'invalid_security_code'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: ThemeColors.error.withOpacity(0.9),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: Text(
              'clear_confirm'.tr,
              style: TextStyle(
                color: ThemeColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }*/
}
class _Content extends GetView<LeaderboardController> {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GameScreenBreakpoints.lbScreenPaddingH(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== LEFT: Podium + Stats =====
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const StatsSummaryCard(),
                  SizedBox(height: 16.h),
                  const ModeFilterChips(),
                  SizedBox(height: 16.h),
                  Obx(() {
                    final top3 = controller.filteredEntries.take(3).toList();
                    if (top3.isEmpty) return const SizedBox.shrink();
                    return PodiumWidget(top3: top3);
                  }),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),

          SizedBox(width: 24.w),

          // ===== RIGHT: Entry list (rank 4-10) =====
          Expanded(
            flex: 3,
            child: Obx(() {
              final all = controller.filteredEntries.toList();
              if (all.length <= 3) return const SizedBox.shrink();
              final rest = all.skip(3).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
                    child: ThemedText.caption(
                      'other_rankings'.tr.toUpperCase(),
                      fontSize: GameScreenBreakpoints.lbStatLabelFontSize(),
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: rest.length,
                      itemBuilder: (context, index) {
                        final rank = index + 4;
                        return LeaderboardEntryTile(
                          entry: rest[index],
                          rank: rank,
                          rankColor: controller.rankColor(rank),
                          rankEmoji: controller.rankEmoji(rank),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}