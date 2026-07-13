// triball_game_area/lib/features/leaderboard/widgets/leaderboard_mode_tabs.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import '../leaderboard_controller.dart';

class LeaderboardModeTabs extends GetView<LeaderboardController> {
  const LeaderboardModeTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: GameScreenBreakpoints.lbTabHeight(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: GameScreenBreakpoints.lbScreenPaddingH(),
        ),
        child: Obx(() {
          final selected = controller.selectedMode.value;
          return Row(
            children: controller.availableModes.map((mode) {
              final isSelected = selected == mode;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _ModeTab(
                  mode: mode,
                  isSelected: isSelected,
                  onTap: () => controller.selectMode(mode),
                ),
              );
            }).toList(),
          );
        }),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final GameMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  Color _accent() {
    switch (mode) {
      case GameMode.classic:  return ThemeColors.primary;
      case GameMode.hardcore: return ThemeColors.error;
      case GameMode.champion: return ThemeColors.tertiary;
      case GameMode.combo:    return ThemeColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: GameScreenBreakpoints.lbTabPaddingH(),
          vertical: GameScreenBreakpoints.lbTabPaddingV(),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withOpacity(0.2)
              : ThemeColors.surface.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accent : accent.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected && ThemeColors.useGlow
              ? [BoxShadow(color: accent.withOpacity(0.4), blurRadius: 12)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mode.icon,
              style: TextStyle(
                fontSize: GameScreenBreakpoints.lbTabIconSize(),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              mode.translationKey.tr.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: GameScreenBreakpoints.lbTabFontSize(),
                fontWeight: FontWeight.w800,
                color: isSelected ? accent : ThemeColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}