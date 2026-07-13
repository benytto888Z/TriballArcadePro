// lib/features/setup/widgets/match_type_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme_controller.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/match_type_model.dart';

class MatchTypeCard extends StatelessWidget {
  final MatchType matchType;
  final bool isSelected;
  final VoidCallback onTap;

  const MatchTypeCard({
    super.key,
    required this.matchType,
    required this.isSelected,
    required this.onTap,
  });

  Color _accent() {
    switch (matchType) {
      case MatchType.competition: return ThemeColors.primary;
      case MatchType.soloChrono:  return ThemeColors.warning;
      case MatchType.tournament:  return ThemeColors.accent;
    }
  }

  String _playerRange() {
    switch (matchType) {
      case MatchType.competition: return '2-6';
      case MatchType.soloChrono:  return '1';
      case MatchType.tournament:  return '4/8/16';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent();

    return Obx(() {
      final themeMode = Get.find<AppThemeController>().currentTheme.value;

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 250.w,
          padding: EdgeInsets.symmetric(horizontal:18.w, vertical: 9.w),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withOpacity(0.10)
                : ThemeColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accent : accent.withOpacity(0.3),
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected && themeMode == AppThemeMode.neon
                ? [
              BoxShadow(
                color: accent.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(matchType.icon, style: TextStyle(fontSize: 35.w)),
              SizedBox(height: 10.h),
              Text(
                matchType.translationKey.tr.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? accent : ThemeColors.textPrimary,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 8.h),
              // Player count badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accent.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, color: accent, size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '${_playerRange()} ${'players'.tr.toLowerCase()}',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                matchType.descriptionKey.tr,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10.sp,
                  color: ThemeColors.textSecondary,
                  height: 1.4,
                ),
              ),
              if (isSelected) ...[
                SizedBox(height: 8.h),
                Icon(Icons.check_circle, color: accent, size: 20.sp),
              ],
            ],
          ),
        ),
      );
    });
  }
}