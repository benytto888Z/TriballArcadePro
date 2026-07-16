// triball_game_area/lib/features/leaderboard/widgets/mode_filter_chips.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/values/app_styles.dart';
import '../../../data/repositories/leaderboard_repository.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import '../leaderboard_controller.dart';

class ModeFilterChips extends GetView<LeaderboardController> {
  const ModeFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
        children: LeaderboardFilter.values.map((filter) {
          final isSelected = controller.selectedFilter.value == filter;
          return Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: InkWell(
              onTap: () => controller.selectFilter(filter),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: GameScreenBreakpoints.lbFilterPaddingH(),
                  vertical: GameScreenBreakpoints.lbFilterPaddingV(),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ThemeColors.secondary.withOpacity(0.2)
                      : ThemeColors.surface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? ThemeColors.secondary
                        : ThemeColors.secondary.withOpacity(0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  filter.translationKey.tr.toUpperCase(),
                  style: AppStyles.styleGeneralShadowCl(
                    GameScreenBreakpoints.lbFilterFontSize()*1.3,
                    FontWeight.w700,
                      isSelected
                          ? ThemeColors.secondary
                          : ThemeColors.textSecondary,
                  ),

                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }
}