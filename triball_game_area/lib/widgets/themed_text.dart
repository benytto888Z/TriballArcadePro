// lib/widgets/themed_text.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme_controller.dart';
import '../core/theme/theme_colors.dart';

enum TextVariant { display, headline, title, body, caption, label }

class ThemedText extends StatelessWidget {
  final String text;
  final TextVariant variant;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool withGlow;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ThemedText(
      this.text, {
        super.key,
        this.variant = TextVariant.body,
        this.color,
        this.fontSize,
        this.fontWeight,
        this.withGlow = false,
        this.textAlign,
        this.maxLines,
        this.overflow,
      });

  const ThemedText.display(this.text, {super.key, this.color, this.fontSize,
    this.withGlow = true, this.textAlign, this.maxLines, this.overflow,
    this.fontWeight}) : variant = TextVariant.display;

  const ThemedText.headline(this.text, {super.key, this.color, this.fontSize,
    this.withGlow = false, this.textAlign, this.maxLines, this.overflow,
    this.fontWeight}) : variant = TextVariant.headline;

  const ThemedText.title(this.text, {super.key, this.color, this.fontSize,
    this.withGlow = false, this.textAlign, this.maxLines, this.overflow,
    this.fontWeight}) : variant = TextVariant.title;

  const ThemedText.body(this.text, {super.key, this.color, this.fontSize,
    this.withGlow = false, this.textAlign, this.maxLines, this.overflow,
    this.fontWeight}) : variant = TextVariant.body;

  const ThemedText.caption(this.text, {super.key, this.color, this.fontSize,
    this.withGlow = false, this.textAlign, this.maxLines, this.overflow,
    this.fontWeight}) : variant = TextVariant.caption;

  const ThemedText.label(this.text, {super.key, this.color, this.fontSize,
    this.withGlow = false, this.textAlign, this.maxLines, this.overflow,
    this.fontWeight}) : variant = TextVariant.label;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ignore: unused_local_variable
      final mode = Get.find<AppThemeController>().currentTheme.value;
      final spec = _getSpec();
      final effectiveColor = color ?? spec.color;
      final showGlow = withGlow && ThemeColors.useGlow;

      return Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: TextStyle(
          fontFamily: spec.fontFamily,
          fontSize: fontSize ?? spec.fontSize,
          fontWeight: fontWeight ?? spec.fontWeight,
          color: effectiveColor,
          letterSpacing: spec.letterSpacing,
          height: 1.2,
          shadows: showGlow
              ? [
            Shadow(color: effectiveColor.withValues(alpha: 0.8), blurRadius: 12),
            Shadow(color: effectiveColor.withValues(alpha:0.5), blurRadius: 24),
          ]
              : null,
        ),
      );
    });
  }

  _TextSpec _getSpec() {
    switch (variant) {
      case TextVariant.display:
        return _TextSpec(
          fontFamily: ThemeColors.fontDisplay,
          fontSize: 48.sp,
          fontWeight: FontWeight.w900,
          color: ThemeColors.primary,
          letterSpacing: ThemeColors.letterSpacing * 2,
        );
      case TextVariant.headline:
        return _TextSpec(
          fontFamily: ThemeColors.fontPrimary,
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
          color: ThemeColors.textPrimary,
          letterSpacing: ThemeColors.letterSpacing,
        );
      case TextVariant.title:
        return _TextSpec(
          fontFamily: ThemeColors.fontPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: ThemeColors.textPrimary,
          letterSpacing: ThemeColors.letterSpacing * 0.5,
        );
      case TextVariant.body:
        return _TextSpec(
          fontFamily: ThemeColors.fontBody,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: ThemeColors.textPrimary,
          letterSpacing: 0,
        );
      case TextVariant.caption:
        return _TextSpec(
          fontFamily: ThemeColors.fontBody,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: ThemeColors.textSecondary,
          letterSpacing: 0,
        );
      case TextVariant.label:
        return _TextSpec(
          fontFamily: ThemeColors.fontPrimary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: ThemeColors.primary,
          letterSpacing: ThemeColors.letterSpacing,
        );
    }
  }
}

class _TextSpec {
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final double letterSpacing;

  _TextSpec({
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    required this.letterSpacing,
  });
}