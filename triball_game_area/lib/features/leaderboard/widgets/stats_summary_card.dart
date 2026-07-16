// triball_game_area/lib/features/leaderboard/widgets/stats_summary_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/values/app_styles.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import '../leaderboard_controller.dart';

class StatsSummaryCard extends GetView<LeaderboardController> {
  const StatsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: ThemeColors.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ThemeColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat(
              icon: Icons.format_list_numbered,
              label: 'total_games'.tr,
              value: '${controller.totalEntries}',
              color: ThemeColors.primary,
            ),
            _Divider(),
            _Stat(
              icon: Icons.timer,
              label: 'best_time'.tr,
              value: controller.bestTime != null
                  ? _formatDuration(controller.bestTime!)
                  : '--',
              color: ThemeColors.warning,
            ),
            _Divider(),
            _Stat(
              icon: Icons.sports_baseball,
              label: 'avg_balls'.tr,
              value: '${controller.avgBalls}',
              color: ThemeColors.success,
            ),
            _Divider(),
            _Stat(
              icon: Icons.group,
              label: 'players'.tr,
              value: '${controller.uniquePlayers}',
              color: ThemeColors.secondary,
            ),
          ],
        ),
      );
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color,
                size: GameScreenBreakpoints.lbStatIconSize()),
            SizedBox(width: 4.w),
            Text(
              value,
              style: AppStyles.styleGeneralShadowCl(
                GameScreenBreakpoints.lbStatValueFontSize()*1.3,
                FontWeight.w900,
               color,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          label.toUpperCase(),
          style: AppStyles.styleGeneralShadowCl(
            GameScreenBreakpoints.lbStatLabelFontSize()*1.3,
            FontWeight.w700, ThemeColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: GameScreenBreakpoints.statsPanelDividerHeight(),
      color: ThemeColors.primary.withOpacity(0.2),
    );
  }
}