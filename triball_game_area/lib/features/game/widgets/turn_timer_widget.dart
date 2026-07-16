// lib/features/game/widgets/turn_timer_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../core/constants/game_constants.dart';
import '../game_controller.dart';
import '../utils/game_screen_breakpoints.dart';

class TurnTimerWidget extends GetView<GameController> {
  final double size;

  const TurnTimerWidget({super.key, this.size = 70});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      //if (!controller.isMultiMode) return const SizedBox.shrink();
      if (!controller.isPlaying && !controller.isTransition) {
        return const SizedBox.shrink();
      }

      final remaining = controller.turnRemainingSeconds.value;
      final progress = controller.turnProgress;
      final isWarning = controller.isTurnWarning.value;
      final isBonus = controller.bonusTurnActive.value; // ✅ NEW

      // ✅ Si bonus turn → couleur SUCCESS
      final color = isBonus
          ? ThemeColors.success
          : (isWarning ? ThemeColors.error : ThemeColors.primary);

      final realSize = size.w;

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        builder: (context, scale, _) {
          return Transform.scale(
            scale: isWarning ? scale * (0.95 + 0.1 * (remaining % 2)) : scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: realSize,
                  height: realSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: realSize,
                        height: realSize,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: color.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.h),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$remaining',
                                style: TextStyle(
                                  fontFamily: GameConstants.gameFontFamily,
                                  fontSize:
                                      GameScreenBreakpoints.turnTimerFontSize(),
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                  height: 1,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xff0b0302),
                                      offset: Offset(0, 6),
                                      blurRadius: 5,
                                    ),
                                  ],

                                  /*shadows: (isWarning || isBonus) && ThemeColors.useGlow
                                      ? [Shadow(color: color, offset: Offset(0, 6),blurRadius: 5)]
                                      : [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 5)],*/
                                ),
                              ),
                              Text(
                                'SEC',
                                style: TextStyle(
                                  fontFamily: GameConstants.gameFontFamily,
                                  fontWeight: FontWeight.w700,
                                  fontSize:
                                      GameScreenBreakpoints.turnTimerSecFontSize(),
                                  color: color.withOpacity(0.85),
                                  shadows: [
                                    Shadow(
                                      color: Color(0xff0b0302),
                                      offset: Offset(0, 6),
                                      blurRadius: 5,
                                    ),
                                  ],
                                  letterSpacing: 1.5,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ✅ NEW : "+1" badge si bonus turn actif
                if (isBonus)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.success,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: ThemeColors.useGlow
                            ? [
                                BoxShadow(
                                  color: ThemeColors.success.withOpacity(0.8),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '+1',
                        style: TextStyle(
                          fontFamily: GameConstants.gameFontFamily,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Color(0xff0b0302),
                              offset: Offset(0, 6),
                              blurRadius: 5,
                            ),
                          ],
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    });
  }
}
