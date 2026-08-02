// lib/features/game/widgets/stats_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../game_controller.dart';
import '../utils/game_screen_breakpoints.dart';

/// Panneau de stats live HORIZONTAL — affiche les stats du JOUEUR COURANT
class StatsPanel extends GetView<GameController> {
  const StatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final player = controller.currentPlayer;
      if (player == null) return const SizedBox.shrink();

      // ✅ Couleur du joueur courant
      final playerColor = Helpers.playerColor(controller.currentPlayerIndex.value);

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: ThemeColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: playerColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: ThemeColors.useGlow
              ? [
            BoxShadow(
              color: playerColor.withValues(alpha: 0.2),
              blurRadius: 10,
            )
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ============= ✅ PLAYER NAME HEADER =============

            // ============= STATS HORIZONTALES =============
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatItem(
                    icon: Icons.sports_baseball,
                    label: 'shots'.tr,
                    value: '${player.totalShots.value}',
                    color: ThemeColors.primary,
                  ),
                  _Separator(),
                  _StatItem(
                    icon: Icons.gps_fixed,
                    label: 'accuracy'.tr,
                    value: '${player.accuracy.toStringAsFixed(0)}%',
                    color: ThemeColors.success,
                  ),
                  _Separator(),
                  _StatItem(
                    icon: Icons.local_fire_department,
                    label: 'streak'.tr,
                    value: '${player.currentStreak.value}',
                    color: ThemeColors.warning,
                  ),
                  _Separator(),
                  _StatItem(
                    icon: Icons.bolt,
                    label: 'combo_max'.tr,
                    value: '×${player.maxComboCount.value}',
                    color: ThemeColors.secondary,
                  ),
                  _Separator(),
                  _StatItem(
                    icon: Icons.star,
                    label: 'bonus'.tr,
                    value: '${player.bonusShots.value}',
                    color: ThemeColors.tertiary,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ============================================================
// STAT ITEM (compact horizontal)
// ============================================================
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: GameConstants.gameFontFamily,
            fontSize: GameScreenBreakpoints.statsPanelLabelSize(),
            fontWeight: FontWeight.w900,
            color: ThemeColors.textSecondary,
            shadows: [
              Shadow(
                color: Color(0xff0b0302),
                offset: Offset(0, 6),
                blurRadius: 6,
              ),
            ],
            letterSpacing: 1.2,
            height: 1,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: GameScreenBreakpoints.statsPanelIconSize()),
            SizedBox(width: 4.w),
            Text(
              value,
              style: TextStyle(
                fontFamily: GameConstants.gameFontFamily,
                fontSize:  GameScreenBreakpoints.statsPanelValueSize(),
                fontWeight: FontWeight.w600,
                color: color,
                shadows: [
                  Shadow(
                    color: Color(0xff0b0302),
                    offset: Offset(0, 6),
                    blurRadius: 5,
                  ),
                ],
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: GameScreenBreakpoints.statsPanelDividerHeight(),
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      color: ThemeColors.primary.withValues(alpha: 0.2),
    );
  }
}