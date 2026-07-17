// lib/features/game/widgets/countdown_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../game_controller.dart';
import '../utils/game_screen_breakpoints.dart';

class CountdownOverlay extends GetView<GameController> {
  const CountdownOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Afficher si countdown initial OU transition entre joueurs
      final showInitial = controller.isCountdown;
      final showTransition = controller.showTurnTransitionCountdown.value;

      if (!showInitial && !showTransition) return const SizedBox.shrink();

      final value = controller.countdownValue.value;
      final isGo = value == 0;
      // ✅ En transition solo : afficher CE joueur (pas le suivant)
      //    En transition multi : afficher le PROCHAIN joueur
      //    En countdown initial : afficher le joueur courant
      final targetPlayer = showTransition && controller.isMultiMode
          ? controller.nextPlayerPreview
          : controller.currentPlayer;

      if (targetPlayer == null) return const SizedBox.shrink();

      final playerName = targetPlayer.name;
      final playerIndex = controller.players.indexOf(targetPlayer);
      final playerColor = Helpers.playerColor(
        playerIndex >= 0 ? playerIndex : 0,
      );

      // ✅ Numéro du tour à afficher
      // En solo + transition : c'est le NOUVEAU tour qui commence
      // En multi + transition : c'est le tour du nouveau joueur
      final turnNumber = showTransition && controller.isSoloMode
          ? targetPlayer.turnsPlayed.value + 1   // tours finis + le nouveau
          : targetPlayer.turnsPlayed.value + 1;

      return Container(
        //color: Colors.black.withValues(alpha:0.2),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(
                5.0,
                5.0,
              ),
              blurRadius: 10.0,
              spreadRadius: 5.0,
            ), //BoxShadow
            /*BoxShadow(
              color: Colors.white,
              offset: const Offset(0.0, 0.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ), //BoxShadow*/
          ],
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            key: ValueKey(value),
            tween: Tween(begin: 0.3, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (context, scale, _) {
              return Transform.scale(
                scale: scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ============= COUNTDOWN NUMBER =============
                    Text(
                      isGo ? 'GO!' : '$value',
                      style: TextStyle(
                        fontFamily: GameConstants.gameFontFamily,
                        fontSize: isGo ? GameScreenBreakpoints.countdownGoSize():  GameScreenBreakpoints.countdownNumberSize(),
                        fontWeight: FontWeight.w900,
                        color: isGo
                            ? ThemeColors.success
                            : playerColor,
                        letterSpacing: 8,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: isGo
                                ? ThemeColors.success
                                : playerColor,
                            blurRadius: 40,
                          ),
                          Shadow(
                            color: ThemeColors.primary,
                            blurRadius: 80,
                          ),
                        ],
                      ),
                    ),

                    if (!isGo) ...[
                      SizedBox(height: 10.h),
                      // ============= PLAYER NAME =============
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            playerName.toUpperCase(),
                            style: TextStyle(
                              fontFamily: GameConstants.gameFontFamily,
                              fontSize: GameScreenBreakpoints.countdownNameSize(),
                              color: playerColor,
                              letterSpacing: 6,
                              fontWeight: FontWeight.w900,
                              /*shadows: [
                                Shadow(
                                  color: playerColor,
                                  blurRadius: 15,
                                ),
                              ],*/
                              shadows: [
                                Shadow(
                                 // color: Color(0xff0b0302),
                                  color: playerColor,
                                  offset: Offset(0, 6),
                                  blurRadius: 85,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(width: 18.w),
                          Text(
                            " - ${'turn_number'.tr}$turnNumber".toUpperCase(),
                            style: TextStyle(
                              fontFamily: GameConstants.gameFontFamily,
                              fontSize: GameScreenBreakpoints.countdownSubtitleSize(),
                              color: playerColor,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                 // color: Color(0x730b0302),
                                  color: playerColor,
                                  offset: Offset(0, 6),
                                  blurRadius: 75,

                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // ✅ Numéro du tour à afficher


                      /*Text(
                        showTransition ? 'next_player'.tr.toUpperCase() : 'ready'.tr,
                        style: TextStyle(
                           fontFamily: GameConstants.gameFontFamily,
                          fontSize: 12.w,
                          color: ThemeColors.textSecondary,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),*/
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }
}