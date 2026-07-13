// lib/features/game/widgets/score_viewing_pause_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../game_controller.dart';
import '../utils/game_screen_breakpoints.dart';

/// Overlay affiché entre la fin du tour et le CountdownOverlay
/// Permet au joueur de visualiser son score courant pendant 5 secondes
class ScoreViewingPauseOverlay extends GetView<GameController> {
  const ScoreViewingPauseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showScoreViewingPause.value) {
        return const SizedBox.shrink();
      }

      final player = controller.currentPlayer;
      if (player == null) return const SizedBox.shrink();

      final playerIndex = controller.players.indexOf(player);
      final playerColor = Helpers.playerColor(
        playerIndex >= 0 ? playerIndex : 0,
      );

      final remaining = controller.scoreViewingRemainingSeconds.value;

      return IgnorePointer(
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, scale, _) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 20.h,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: playerColor,
                        width: 3,
                      ),
                      boxShadow: ThemeColors.useGlow
                          ? [
                        BoxShadow(
                          color: playerColor.withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ============= LABEL =============
                        Text(
                          'end_of_turn'.tr.toUpperCase(),
                          style: TextStyle(
                            fontFamily: GameConstants.gameFontFamily,
                            fontSize: 55.sp,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.textSecondary,
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // ============= PLAYER NAME =============
                        Text(
                          player.name.toUpperCase(),
                          style: TextStyle(
                            fontFamily: GameConstants.gameFontFamily,
                            fontSize: GameScreenBreakpoints.scoreViewingNameFontSize(),
                            fontWeight: FontWeight.w900,
                            color: playerColor,
                            letterSpacing: 3,
                            shadows: ThemeColors.useGlow
                                ? [
                              Shadow(
                                color: playerColor,
                                blurRadius: 15,
                              ),
                            ]
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12.h),

                        // ============= SCORE =============
                        Obx(() {
                          final score = player.score.value;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$score',
                                style: TextStyle(
                                  fontFamily: GameConstants.gameFontFamily,
                                  fontSize: GameScreenBreakpoints.scoreViewingScoreFontSize(),
                                  fontWeight: FontWeight.w900,
                                  color: playerColor,
                                  height: 1,
                                  letterSpacing: 2,
                                  shadows: ThemeColors.useGlow
                                      ? [
                                    Shadow(
                                      color: playerColor,
                                      blurRadius: 25,
                                    ),
                                  ]
                                      : null,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '/ ${controller.targetScore}',
                                style: TextStyle(
                                  fontFamily: GameConstants.gameFontFamily,
                                  fontSize: 60.sp,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeColors.textSecondary,
                                ),
                              ),
                            ],
                          );
                        }),
                        SizedBox(height: 4.h),

                        // ============= LABEL SCORE =============
                        Text(
                          'current_score'.tr.toUpperCase(),
                          style: TextStyle(
                            fontFamily: GameConstants.gameFontFamily,
                            fontSize: 45.sp,
                            color: ThemeColors.textSecondary,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ============= COUNTDOWN AVANT SWITCH =============
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: ThemeColors.warning,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                color: ThemeColors.warning,
                                size: 55.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${'next_turn_in'.tr} ',
                                style: TextStyle(
                                  fontFamily: GameConstants.gameFontFamily,
                                  fontSize: 55.sp,
                                  color: ThemeColors.textSecondary,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                '$remaining',
                                style: TextStyle(
                                  fontFamily: GameConstants.gameFontFamily,
                                  fontSize: GameScreenBreakpoints.scoreViewingCountdownFontSize(),
                                  fontWeight: FontWeight.w900,
                                  color: ThemeColors.warning,
                                ),
                              ),
                              Text(
                                ' s',
                                style: TextStyle(
                                  fontFamily: GameConstants.gameFontFamily,
                                  fontSize: 55.sp,
                                  color: ThemeColors.warning,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}