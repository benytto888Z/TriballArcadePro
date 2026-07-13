// lib/widgets/home_menu_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme_controller.dart';
import '../core/theme/theme_colors.dart';

/// Card cliquable pour le menu principal — alternative aux boutons.
/// Affiche : icône grande + titre + description courte + flèche.
class HomeMenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Color accentColor;
  final VoidCallback onTap;

  const HomeMenuCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<HomeMenuCard> createState() => _HomeMenuCardState();
}

class _HomeMenuCardState extends State<HomeMenuCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = Get.find<AppThemeController>().currentTheme.value;

      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..scale(_pressed ? 0.97 : (_hovered ? 1.02 : 1.0)),
            padding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 16.h,
            ),
            decoration: _buildDecoration(mode),
            child: Row(
              children: [
                // ICON
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.accentColor.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.accentColor,
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 16.w),

                // TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title.toUpperCase(),
                        style: TextStyle(
                          fontFamily: ThemeColors.fontPrimary,
                          color: widget.accentColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.description != null) ...[
                        SizedBox(height: 3.h),
                        Text(
                          widget.description!,
                          style: TextStyle(
                            fontFamily: ThemeColors.fontBody,
                            color: ThemeColors.textSecondary,
                            fontSize: 11.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // ARROW
                Icon(
                  Icons.arrow_forward_ios,
                  color: widget.accentColor.withOpacity(_hovered ? 1.0 : 0.5),
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  BoxDecoration _buildDecoration(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.neon:
        return BoxDecoration(
          color: ThemeColors.surface.withOpacity(_hovered ? 0.7 : 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.accentColor.withOpacity(_hovered ? 1.0 : 0.4),
            width: _hovered ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(_hovered ? 0.4 : 0.15),
              blurRadius: _hovered ? 20 : 12,
            ),
          ],
        );
      case AppThemeMode.esports:
        return BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovered ? 0.5 : 0.3),
              blurRadius: _hovered ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AppThemeMode.carnival:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(_hovered ? 0.4 : 0.2),
              blurRadius: _hovered ? 16 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        );
    }
  }
}