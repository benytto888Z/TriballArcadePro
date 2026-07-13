// lib/features/how_to_play/widgets/guide_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/guide_section_model.dart';
import '../how_to_play_controller.dart';
import 'hole_grid_demo.dart';

class GuideCard extends GetView<HowToPlayController> {
  final GuideItem item;
  final int index;

  const GuideCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.expandedItemIndex.value == index;
      final color = item.accentColor ?? ThemeColors.primary;

      return Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: ThemeColors.surface.withOpacity(isExpanded ? 0.7 : 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded ? color : color.withOpacity(0.3),
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: isExpanded && ThemeColors.useGlow
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15)]
              : null,
        ),
        child: Column(
          children: [
            // ============= HEADER (toujours visible) =============
            InkWell(
              onTap: () => controller.toggleExpand(index),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Row(
                  children: [
                    // Icône
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: Center(
                        child: Icon(
                          item.icon ?? Icons.info_outline,
                          color: color,
                          size: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Titre
                    Expanded(
                      child: Text(
                        item.titleKey.tr,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isExpanded ? color : ThemeColors.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    // Arrow
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 250),
                      turns: isExpanded ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more,
                        color: color,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============= CONTENT (si expanded) =============
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      item.descriptionKey.tr,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12.sp,
                        color: ThemeColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    // Bullet points
                    if (item.bulletPointKeys != null) ...[
                      SizedBox(height: 10.h),
                      ...item.bulletPointKeys!.map(
                            (key) => Padding(
                          padding: EdgeInsets.only(
                              bottom: 6.h, left: 4.w),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.arrow_right,
                                color: color,
                                size: 18.sp,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  key.tr,
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 11.sp,
                                    color: ThemeColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Custom widget (ex: grille de trous)
                    if (item.customWidget != null) ...[
                      SizedBox(height: 12.h),
                      _resolveCustomWidget(item.customWidget!),
                    ],
                  ],
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }

  Widget _resolveCustomWidget(Widget placeholder) {
    // Pour l'instant on a juste la grille de démo
    return const HoleGridDemo();
  }
}