// lib/widgets/glow_container.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme_controller.dart';

class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double blurRadius;
  final double spreadRadius;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlowContainer({
    super.key,
    required this.child,
    required this.glowColor,
    this.blurRadius = 20,
    this.spreadRadius = 0,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = Get.find<AppThemeController>().currentTheme.value;
      final useGlow = mode == AppThemeMode.neon;

      return Container(
        padding: padding,
        decoration: useGlow
            ? BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.6),
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
            ),
            BoxShadow(
              color: glowColor.withOpacity(0.3),
              blurRadius: blurRadius * 2,
              spreadRadius: spreadRadius,
            ),
          ],
        )
            : null,
        child: child,
      );
    });
  }
}