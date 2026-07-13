// lib/widgets/theme_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme_controller.dart';
import '../core/theme/theme_colors.dart';
import 'themed_text.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppThemeController>();

    return Obx(() => Row(
      mainAxisSize: MainAxisSize.min,
      children: AppThemeMode.values.map((mode) {
        final isSelected = controller.currentTheme.value == mode;
        return Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: _ThemeCard(
            mode: mode,
            isSelected: isSelected,
            onTap: () => controller.switchTheme(mode),
          ),
        );
      }).toList(),
    ));
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(mode);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 200.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: ThemeColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accent : accent.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: accent.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mode.icon, style: TextStyle(fontSize: 40.sp)),
            SizedBox(height: 12.h),
            ThemedText(
              mode.translationKey.tr,
              variant: TextVariant.title,
              color: isSelected ? accent : ThemeColors.textPrimary,
              fontSize: 16.sp,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            ThemedText(
              mode.descriptionKey.tr,
              variant: TextVariant.caption,
              fontSize: 11.sp,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (isSelected) ...[
              SizedBox(height: 12.h),
              Icon(Icons.check_circle, color: accent, size: 24.sp),
            ],
          ],
        ),
      ),
    );
  }

  Color _accentFor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.neon:     return const Color(0xFF00F5FF);
      case AppThemeMode.esports:  return const Color(0xFFFFD700);
      case AppThemeMode.carnival: return const Color(0xFFFF6B35);
    }
  }
}