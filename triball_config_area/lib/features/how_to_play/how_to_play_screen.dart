// lib/features/how_to_play/how_to_play_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/theme/theme_colors.dart';
import '../../data/models/guide_section_model.dart';
import '../../widgets/floating_particles.dart';
import '../../widgets/orientation_wrappers.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/themed_text.dart';
import 'how_to_play_controller.dart';
import 'widgets/guide_card.dart';

class HowToPlayScreen extends GetView<HowToPlayController> {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PortraitWrapper(
      child: ThemedScaffold(
        body: Stack(
          children: [
            const FloatingParticles(count: 10),
            SafeArea(
              child: Column(
                children: [
                  // ============= HEADER =============
                  _Header(),

                  // ============= CATEGORY SELECTOR (horizontal scroll) =============
                  _CategorySelector(),
                  SizedBox(height: 8.h),

                  // ============= SECTION TITLE =============
                  _SectionTitle(),
                  SizedBox(height: 8.h),

                  // ============= CONTENT (expandable cards) =============
                  Expanded(
                    child: _SectionContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================
class _Header extends GetView<HowToPlayController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          IconButton(
            onPressed: controller.onBackPressed,
            icon: Icon(
              Icons.arrow_back,
              color: ThemeColors.primary,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 6.w),
          Icon(
            Icons.menu_book,
            color: ThemeColors.primary,
            size: 22.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ThemedText.headline(
              'how_to_play'.tr,
              fontSize: 22.sp,
              withGlow: true,
              color: ThemeColors.primary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CATEGORY SELECTOR (tabs horizontaux scrollables)
// ============================================================
class _CategorySelector extends GetView<HowToPlayController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.h,
      child: Obx(() {
        final selected = controller.selectedCategory.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: GuideCategory.values.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final cat = GuideCategory.values[index];
            final isSelected = selected == cat;
            return _CategoryTab(
              category: cat,
              isSelected: isSelected,
              onTap: () => controller.selectCategory(cat),
            );
          },
        );
      }),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final GuideCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? ThemeColors.primary : ThemeColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColors.primary.withOpacity(0.15)
              : ThemeColors.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ThemeColors.primary
                : ThemeColors.textSecondary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected && ThemeColors.useGlow
              ? [
            BoxShadow(
              color: ThemeColors.primary.withOpacity(0.4),
              blurRadius: 12,
            )
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: TextStyle(fontSize: 18.sp)),
            SizedBox(height: 2.h),
            Text(
              category.translationKey.tr,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================
class _SectionTitle extends GetView<HowToPlayController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cat = controller.selectedCategory.value;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            Icon(cat.icon, color: ThemeColors.primary, size: 16.sp),
            SizedBox(width: 8.w),
            ThemedText.title(
              cat.translationKey.tr,
              fontSize: 14.sp,
              color: ThemeColors.primary,
            ),
          ],
        ),
      );
    });
  }
}

// ============================================================
// SECTION CONTENT (expandable cards)
// ============================================================
class _SectionContent extends GetView<HowToPlayController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.currentSection.items;
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GuideCard(
            item: items[index],
            index: index,
          );
        },
      );
    });
  }
}