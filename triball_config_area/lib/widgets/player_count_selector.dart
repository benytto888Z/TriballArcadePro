// lib/widgets/player_count_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/theme_colors.dart';
import '../core/utils/helpers.dart';

class PlayerCountSelector extends StatelessWidget {
  final int currentCount;
  final int minCount;
  final int maxCount;
  final ValueChanged<int> onChanged;

  const PlayerCountSelector({
    super.key,
    required this.currentCount,
    required this.minCount,
    required this.maxCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: List.generate(maxCount - minCount + 1, (i) {
        final value = minCount + i;
        final isSelected = value == currentCount;
        final accent = Helpers.playerColor(value - 1);

        return InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: isSelected
                  ? accent.withOpacity(0.2)
                  : ThemeColors.surface.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? accent : ThemeColors.primary.withOpacity(0.3),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected && ThemeColors.useGlow
                  ? [BoxShadow(color: accent.withOpacity(0.6), blurRadius: 12)]
                  : null,
            ),
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  fontFamily: ThemeColors.fontPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? accent : ThemeColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}