// lib/features/game/widgets/victory_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/game_constants.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/utils/helpers.dart';
import '../game_controller.dart';
import '../utils/game_screen_breakpoints.dart';

class VictoryDialog extends GetView<GameController> {
  const VictoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
      return Obx(() {
        if (!controller.isVictory ||
            !controller.showVictoryDialog.value) {
          return const SizedBox.shrink();
        }
      final winner = controller.winner.value;
      if (winner == null) return const SizedBox.shrink();

      final isNewRecord = controller.isNewRecord.value;
      final rank = controller.newRecordRank.value;
      final color = Helpers.playerColor(controller.players.indexOf(winner));

      // ✅ Calculer la largeur selon l'écran RÉEL (pas .w)
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      // ✅ Le dialog prend 50% de la largeur sur TV, 80% sur mobile
      final dialogWidth = screenWidth > 1200
          ? screenWidth *
                0.45 // TV : 45%
          : screenWidth > 900
          ? screenWidth *
                0.55 // Tablet : 55%
          : screenWidth * 0.85; // Mobile : 85%

      final dialogMaxHeight = screenHeight * 0.95;

      return Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.85)),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, scale, _) {
                return Transform.scale(
                  scale: scale,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: dialogWidth, // ✅ Largeur contrôlée
                      maxHeight: dialogMaxHeight, // ✅ Hauteur max
                    ),
                    child: Container(
                      //  width: GameScreenBreakpoints.victoryDialogWidth(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.w,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: color, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.7),
                            blurRadius: 60,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Obx(() {
                            final countdown =
                                controller.returnToWaitingCountdown.value;
                            if (countdown <= 0) return const SizedBox.shrink();
                            return Positioned(
                              top: 25.w,
                              right: 50.w ,
                              child: Text(
                                // '${'auto_return_in'.tr} $countdown s',
                                '$countdown Sec',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: GameConstants.gameFontFamily,
                                  fontSize: 90.sp,
                                  fontWeight: FontWeight.w800,
                                  color: ThemeColors.textSecondary,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xff0b0302),
                                      offset: Offset(0, 6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                  letterSpacing: 2,
                                ),
                              ),
                            );
                          }),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '🏆',
                                style: TextStyle(
                                  fontSize:
                                      GameScreenBreakpoints.victoryTrophySize(),
                                  shadows: [
                                    Shadow(
                                      color: Color(0xff0b0302),
                                      offset: Offset(0, 6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 3.h),

                              // VICTORY title
                              Text(
                                'victory'.tr,
                                style: TextStyle(
                                  fontFamily: GameConstants.gameFontFamily,
                                  fontSize:
                                      GameScreenBreakpoints.victoryTitleFontSize(),
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                  letterSpacing: 6,
                                  // shadows: [Shadow(color: color, blurRadius: 24)],
                                  shadows: [
                                    Shadow(
                                      color: Color(0xff0b0302),
                                      offset: Offset(0, 6),
                                      blurRadius: 7,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5.h),

                              // Winner name
                              Text(
                                winner!.name.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: GameConstants.gameFontFamily,
                                  fontSize:
                                      GameScreenBreakpoints.victoryNameFontSize(),
                                  fontWeight: FontWeight.w800,
                                  color: ThemeColors.textPrimary,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xff0b0302),
                                      offset: Offset(0, 6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                  letterSpacing: 2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 14.h),

                              // ============================================
                              // ✅ STATS — Temps synchronisé avec GameScreen
                              // ============================================
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _StatBox(
                                    icon: Icons.timer,
                                    label: 'time'.tr,
                                    value: controller.victoryTimeFormatted, // ✅
                                    color: color,
                                  ),
                                  _StatBox(
                                    icon: Icons.sports_baseball,
                                    label: 'balls_thrown'.tr,
                                    value: '${winner.ballsThrown.value}',
                                    color: color,
                                  ),
                                  _StatBox(
                                    icon: Icons.refresh,
                                    label: 'turn'.tr,
                                    value: 'T${winner.turnsPlayed.value + 1}',
                                    color: color,
                                  ),
                                ],
                              ),

                              // NEW RECORD (Solo Chrono uniquement)
                              if (isNewRecord && controller.isSoloChrono) ...[
                                SizedBox(height: 14.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ThemeColors.warning.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: ThemeColors.warning,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: ThemeColors.warning,
                                        size: 60.sp,
                                        shadows: [
                                          Shadow(
                                            color: Color(0xff0b0302),
                                            offset: Offset(0, 6),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        '${'new_record'.tr}  #$rank',
                                        style: TextStyle(
                                          fontFamily:
                                              GameConstants.gameFontFamily,
                                          color: ThemeColors.warning,
                                          fontSize: 60.sp,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 2,
                                          shadows: [
                                            Shadow(
                                              color: Color(0xff0b0302),
                                              offset: Offset(0, 6),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // ✅ BONUS : Affiche le temps précis en Solo Chrono
                                SizedBox(height: 6.h),
                                Text(
                                  controller.victoryTimeDetailed,
                                  style: TextStyle(
                                    fontFamily: GameConstants.gameFontFamily,
                                    color: ThemeColors.warning.withOpacity(0.7),
                                    fontSize: 80.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: Color(0xff0b0302),
                                        offset: Offset(0, 6),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              if (controller.isNotInTop10.value &&
                                  controller.isSoloChrono) ...[
                                SizedBox(height: 14.h),
                                Text(
                                  'not_in_top_10'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: GameConstants.gameFontFamily,
                                    color: ThemeColors.warning,
                                    fontSize: 60.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 70.sp),
        SizedBox(height: 4.h),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: GameConstants.gameFontFamily,
            fontSize: 40.sp,
            fontWeight: FontWeight.w900,
            color: ThemeColors.textSecondary,
            shadows: [
              Shadow(
                color: Color(0xff0b0302),
                offset: Offset(0, 6),
                blurRadius: 6,
              ),
            ],
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: GameConstants.gameFontFamily,
            fontSize: GameScreenBreakpoints.victoryStatFontSize(),
            fontWeight: FontWeight.w800,
            color: color,
            shadows: [
              Shadow(
                color: Color(0xff0b0302),
                offset: Offset(0, 6),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/*class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 130.w,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(height: 4.h),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: GameConstants.gameFontFamily,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}*/
