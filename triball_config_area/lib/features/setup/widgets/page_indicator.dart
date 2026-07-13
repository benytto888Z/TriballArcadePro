// lib/features/setup/widgets/page_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/theme_colors.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final List<String> pageTitles;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.pageTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final isActive = i == currentPage;
        final isPast = i < currentPage;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isActive || isPast
                        ? ThemeColors.primary
                        : ThemeColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isActive && ThemeColors.useGlow
                        ? [
                      BoxShadow(
                        color: ThemeColors.primary.withOpacity(0.6),
                        blurRadius: 8,
                      ),
                    ]
                        : null,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  pageTitles[i].toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 8.sp,
                    fontWeight:
                    isActive ? FontWeight.w800 : FontWeight.w500,
                    color: isActive
                        ? ThemeColors.primary
                        : ThemeColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}