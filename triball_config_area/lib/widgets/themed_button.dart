// lib/widgets/themed_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme_controller.dart';
import '../core/theme/theme_colors.dart';

enum ButtonVariant { primary, secondary, accent, ghost }

class ThemedButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double? height;
  final bool fullWidth;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const ThemedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.width,
    this.height,
    this.fullWidth = false,
    this.fontSize,
    this.padding,
  });

  @override
  State<ThemedButton> createState() => _ThemedButtonState();
}

class _ThemedButtonState extends State<ThemedButton> {
  bool _hovered = false;
  bool _pressed = false;

  Color get _color {
    switch (widget.variant) {
      case ButtonVariant.primary:   return ThemeColors.primary;
      case ButtonVariant.secondary: return ThemeColors.secondary;
      case ButtonVariant.accent:    return ThemeColors.accent;
      case ButtonVariant.ghost:     return ThemeColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ignore: unused_local_variable
      final mode = Get.find<AppThemeController>().currentTheme.value;
      final color = _color;
      final isDisabled = widget.onPressed == null;

      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.fullWidth ? double.infinity : widget.width,
            height: widget.height ?? 56.h,
            padding: widget.padding ??
                EdgeInsets.symmetric(horizontal: 16.w),
            decoration: _buildDecoration(color, isDisabled),
            child: _buildContent(color),
          ),
        ),
      );
    });
  }

  // ✅ CONTENU AVEC PROTECTION OVERFLOW
  Widget _buildContent(Color color) {
    final textWidget = Text(
      widget.label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: ThemeColors.fontPrimary,
        color: _textColor(color),
        fontSize: widget.fontSize ?? 14.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: ThemeColors.letterSpacing,
      ),
    );

    if (widget.icon == null) {
      // ✅ Texte seul : on l'enveloppe pour qu'il puisse être tronqué
      return Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: textWidget,
        ),
      );
    }

    // ✅ Icône + texte : Row protégé
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, color: _textColor(color), size: 18.sp),
          SizedBox(width: 8.w),
          // ✅ Flexible pour permettre la troncature
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: textWidget,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration(Color color, bool isDisabled) {
    final mode = Get.find<AppThemeController>().currentTheme.value;

    switch (mode) {
      case AppThemeMode.neon:
        return BoxDecoration(
          color: _pressed
              ? color.withValues(alpha: 0.3)
              : (_hovered
              ? color.withValues(alpha:0.15)
              : color.withValues(alpha:0.08)),
          borderRadius: BorderRadius.circular(ThemeColors.cornerRadius),
          border: Border.all(color: color, width: _hovered ? 2.5 : 2),
          boxShadow: isDisabled
              ? null
              : [
            BoxShadow(
              color: color.withValues(alpha:_hovered ? 0.7 : 0.4),
              blurRadius: _hovered ? 20 : 12,
              spreadRadius: _hovered ? 2 : 0,
            ),
          ],
        );
      case AppThemeMode.esports:
        return BoxDecoration(
          color: _pressed ? color.withValues(alpha:0.8) : color,
          borderRadius: BorderRadius.circular(ThemeColors.cornerRadius),
          boxShadow: isDisabled
              ? null
              : [
            BoxShadow(
              color: Colors.black.withValues(alpha:_hovered ? 0.5 : 0.3),
              blurRadius: _hovered ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        );
      case AppThemeMode.carnival:
        return BoxDecoration(
          color: _pressed ? color.withValues(alpha:0.9) : color,
          borderRadius:
          BorderRadius.circular(ThemeColors.cornerRadiusLarge),
          boxShadow: isDisabled
              ? null
              : [
            BoxShadow(
              color: color.withValues(alpha:_hovered ? 0.6 : 0.4),
              blurRadius: _hovered ? 16 : 8,
              offset: Offset(0, _pressed ? 2 : 4),
            ),
          ],
        );
    }
  }

  Color _textColor(Color bg) {
    final mode = Get.find<AppThemeController>().currentTheme.value;
    if (mode == AppThemeMode.neon) return bg; // glow effect
    if (mode == AppThemeMode.esports) return Color(0xff0b0302); // glow effect
    return Colors.white;
  }
}