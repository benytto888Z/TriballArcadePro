// triball_game_area/lib/features/tournament/widgets/tournament_stats_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../tournament_controller.dart';

class TournamentStatsBar extends GetView<TournamentController> {
  const TournamentStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = controller.tournament.value;
      if (t == null) return const SizedBox.shrink();

      final progress = t.progress;
      final completed = t.completedMatchesCount;
      final total = t.totalMatchesCount;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: ThemeColors.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ThemeColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.account_tree,
                color: ThemeColors.primary, size: 16.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.name.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.primary,
                      letterSpacing: 1.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${'tournament_round'.tr} ${t.currentRound.value}/${t.totalRounds} · $completed/$total',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 9.sp,
                      color: ThemeColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: 80.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: ThemeColors.primary.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(ThemeColors.warning),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 9.sp,
                      color: ThemeColors.warning,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}