// lib/widgets/themed_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme_controller.dart';
import '../core/theme/theme_colors.dart';

class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = Get.find<AppThemeController>().currentTheme.value;
      final color = borderColor ?? ThemeColors.primary;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeColors.cornerRadiusLarge),
          child: Container(
            width: width,
            height: height,
            padding: padding ?? EdgeInsets.all(16.w),
            decoration: _decoration(mode, color),
            child: child,
          ),
        ),
      );
    });
  }

  BoxDecoration _decoration(AppThemeMode mode, Color color) {
    switch (mode) {
      case AppThemeMode.neon:
        return BoxDecoration(
          color: ThemeColors.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(ThemeColors.cornerRadiusLarge),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 15),
          ],
        );
      case AppThemeMode.esports:
        return BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(ThemeColors.cornerRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AppThemeMode.carnival:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ThemeColors.cornerRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        );
    }
  }
}