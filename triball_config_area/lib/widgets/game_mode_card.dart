// lib/widgets/game_mode_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme_controller.dart';
import '../core/theme/theme_colors.dart';
import '../data/models/game_state_model.dart';

class GameModeCard extends StatelessWidget {
  final GameMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const GameModeCard({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  Color _accent() {
    switch (mode) {
      case GameMode.classic:   return ThemeColors.primary;
      case GameMode.hardcore:  return ThemeColors.error;
      case GameMode.champion:  return ThemeColors.tertiary;
      case GameMode.combo:     return ThemeColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent();

    return Obx(() {
      final themeMode = Get.find<AppThemeController>().currentTheme.value;

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 225.w,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha:0.18)
                : ThemeColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? accent : accent.withValues(alpha:0.25),
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected && themeMode == AppThemeMode.neon
                ? [
              BoxShadow(
                color: accent.withValues(alpha:0.3),
                blurRadius: 18,
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mode.icon, style: TextStyle(fontSize: 30.sp)),
              SizedBox(height: 8.h),
              Text(
                mode.translationKey.tr.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: ThemeColors.fontPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? accent : ThemeColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                mode.descriptionKey.tr,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: ThemeColors.fontBody,
                  fontSize: 13.sp,
                  color: ThemeColors.textSecondary,
                  height: 1.3,
                ),
              ),
              if (isSelected) ...[
                SizedBox(height: 6.h),
                Icon(Icons.check_circle, color: accent, size: 18.sp),
              ],
            ],
          ),
        ),
      );
    });
  }
}