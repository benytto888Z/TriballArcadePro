// triball_game_area/lib/features/leaderboard/widgets/empty_leaderboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../game/utils/game_screen_breakpoints.dart';

class EmptyLeaderboard extends StatelessWidget {
  const EmptyLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: GameScreenBreakpoints.lbDisconnectedIconSize(),
            color: ThemeColors.primary.withOpacity(0.3),
          ),
          SizedBox(height: 20.h),
          Text(
            'leaderboard_empty'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: GameScreenBreakpoints.lbDisconnectedTitleSize(),
              fontWeight: FontWeight.w700,
              color: ThemeColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'leaderboard_empty_desc'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: GameScreenBreakpoints.lbDisconnectedDescSize(),
              color: ThemeColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}