// triball_config_area/lib/features/settings/widgets/about_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/themed_card.dart';
import '../../../widgets/themed_text.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: ThemeColors.primary, size: 22.h),
              SizedBox(width: 10.w),
              ThemedText.title('about'.tr, fontSize: 16.h),
            ],
          ),
          SizedBox(height: 14.h),

          _InfoRow(label: 'app_name'.tr, value: 'TRIBALL PRO'),
          SizedBox(height: 6.h),
          _InfoRow(label: 'app_type'.tr, value: 'CONFIG AREA'),
          SizedBox(height: 6.h),
          _InfoRow(label: 'app_version'.tr, value: '1.0.0'),
          SizedBox(height: 6.h),
          _InfoRow(label: 'edition'.tr, value: 'Game Center'),

          SizedBox(height: 12.h),
          Divider(color: ThemeColors.primary.withOpacity(0.2), height: 1),
          SizedBox(height: 12.h),

          _LinkItem(
            icon: Icons.menu_book,
            label: 'how_to_play'.tr,
            onTap: () => Get.toNamed(AppRoutes.howToPlay),
          ),
          SizedBox(height: 6.h),
          _LinkItem(
            icon: Icons.code,
            label: 'open_source_licenses'.tr,
            onTap: () => showLicensePage(
              context: Get.context!,
              applicationName: 'TRIBALL PRO CONFIG AREA',
              applicationVersion: '1.0.0',
            ),
          ),

          SizedBox(height: 14.h),

          Center(
            child: Column(
              children: [
                Text(
                  '⚡ TRIBALL PRO GAME CENTER ⚡',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9.h,
                    color: ThemeColors.primary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '© 2025 AMZ Elite Games',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 8.h,
                    color: ThemeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110.w,
          child: ThemedText.caption(
            label,
            fontSize: 11.h,
            color: ThemeColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12.h,
              fontWeight: FontWeight.w700,
              color: ThemeColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LinkItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        child: Row(
          children: [
            Icon(icon, color: ThemeColors.primary, size: 16.h),
            SizedBox(width: 10.w),
            Expanded(
              child: ThemedText.body(label, fontSize: 12.h),
            ),
            Icon(Icons.arrow_forward_ios,
                color: ThemeColors.primary.withOpacity(0.5), size: 12.h),
          ],
        ),
      ),
    );
  }
}