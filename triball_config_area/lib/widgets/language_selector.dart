// lib/widgets/language_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/localization/locale_controller.dart';
import '../core/theme/theme_colors.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocaleController>();

    return Obx(() => Row(
      mainAxisSize: MainAxisSize.min,
      children: LocaleController.supportedLocales.keys.map((code) {
        final isSelected =
            controller.currentLocale.value.languageCode == code;
        final flag = LocaleController.languageFlags[code]!;
        final name = LocaleController.languageNames[code]!;

        return Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: InkWell(
            onTap: () => controller.changeLocale(code),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? ThemeColors.secondary.withOpacity(0.15)
                    : ThemeColors.surface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? ThemeColors.secondary
                      : ThemeColors.primary.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected && ThemeColors.useGlow
                    ? [
                  BoxShadow(
                    color: ThemeColors.secondary.withOpacity(0.5),
                    blurRadius: 12,
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(flag, style: TextStyle(fontSize: 22.sp)),
                  SizedBox(width: 10.w),
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: ThemeColors.fontPrimary,
                      color: isSelected
                          ? ThemeColors.secondary
                          : ThemeColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      letterSpacing: ThemeColors.letterSpacing,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ));
  }
}