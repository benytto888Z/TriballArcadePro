// triball_game_area/lib/features/leaderboard/widgets/leaderboard_disconnected.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../widgets/themed_button.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import '../leaderboard_controller.dart';

class LeaderboardDisconnected extends GetView<LeaderboardController> {
  const LeaderboardDisconnected({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off,
            size: GameScreenBreakpoints.lbDisconnectedIconSize(),
            color: ThemeColors.error.withOpacity(0.6),
          ),
          SizedBox(height: 20.h),
          Text(
            'leaderboard_offline_title'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: GameScreenBreakpoints.lbDisconnectedTitleSize(),
              fontWeight: FontWeight.w800,
              color: ThemeColors.error,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'leaderboard_offline_desc'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: GameScreenBreakpoints.lbDisconnectedDescSize(),
              color: ThemeColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          ThemedButton(
            label: 'reconnect'.tr,
            icon: Icons.refresh,
            variant: ButtonVariant.primary,
            width: 200.w,
            onPressed: controller.reconnect,
          ),
        ],
      ),
    );
  }
}