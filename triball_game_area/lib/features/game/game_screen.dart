// lib/features/game/game_screen.dart


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/game_constants.dart';
import '../../core/theme/theme_colors.dart';
import '../../data/models/game_state_model.dart';
import 'widgets/countdown_overlay.dart';
import '../../widgets/floating_particles.dart';
import '../../widgets/orientation_wrappers.dart';
import 'utils/game_screen_breakpoints.dart';       // ✅ NEW
import 'widgets/player_score_card.dart';
import 'widgets/score_popup.dart';
import 'widgets/score_viewing_pause_overlay.dart';
import 'widgets/turn_timer_widget.dart';
import 'widgets/victory_dialog.dart';
import 'game_controller.dart';
import 'widgets/combo_indicator.dart';
import 'widgets/controls_toggle_button.dart';
import 'widgets/game_controls_bar.dart';
import 'widgets/stats_panel.dart';

class GameScreen extends GetView<GameController> {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plys = controller.players.toList();

    // ✅ Récupère la taille du turn timer selon le device
    final turnTimerSize = GameScreenBreakpoints.turnTimerSize();

    return LandscapeImmersiveWrapper(
      child: Scaffold(
        backgroundColor: ThemeColors.backgroundDeep,
        body: Stack(
          children: [
            // ============================================
            // BACKGROUND
            // ============================================
            Container(
              decoration: BoxDecoration(
                gradient: ThemeColors.backgroundGradient,
              ),
            ),

            // ✅ Particules adaptées au device (+ nombreuses sur grands écrans)
            FloatingParticles(
              count: GameScreenBreakpoints.particlesCount(),
            ),

            // ✅ Turn timer — position et taille adaptées
           /* Positioned(
              top: GameScreenBreakpoints.turnTimerTop(),
              left: GameScreenBreakpoints.turnTimerLeft(),
              child: TurnTimerWidget(size: GameScreenBreakpoints.turnTimerSize()),
            ),*/

            Positioned(
              top: GameScreenBreakpoints.turnTimerTop(),
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: TurnTimerWidget(
                  size: GameScreenBreakpoints.turnTimerSize(),
                ),
              ),
            ),

            // ============================================
            // MAIN CONTENT
            // ============================================
            SafeArea(
              child: Padding(
                padding: GameScreenBreakpoints.screenPadding(),     // ✅
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ===== TOP BAR =====
                    const _TopBar(),
                    SizedBox(
                      height:
                      GameScreenBreakpoints.topBarBottomSpacing(plys.length),
                    ),
                    // ===== PLAYERS GRID =====
                    Expanded(
                      child: Center(child: _PlayersGrid()),
                    ),

                    SizedBox(height: 8.h),

                    // ===== STATS PANEL =====
                    const StatsPanel(),
                  ],
                ),
              ),
            ),

            // ============================================
            // SCORE POPUP (center)
            // ============================================
            const Positioned.fill(
              child: Align(alignment: Alignment.center, child: ScorePopup()),
            ),

            // ============================================
            // COMBO BANNER (top center)
            // ============================================
            Positioned(
              top: GameScreenBreakpoints.comboBannerTop(),       // ✅
              left: 0,
              right: 0,
              child: const Center(child: ComboIndicator()),
            ),

            // ============================================
            // ✅ CONTROLS TOGGLE BUTTON
            // ============================================
            Positioned(
              bottom: GameScreenBreakpoints.controlsButtonBottom(),   // ✅
              left: GameScreenBreakpoints.controlsButtonLeft(),        // ✅
              child: const ControlsToggleButton(),
            ),

            // ============================================
            // ✅ CONTROLS PANEL
            // ============================================
            Positioned(
              bottom: GameScreenBreakpoints.controlsPanelBottom(),    // ✅
              left: GameScreenBreakpoints.controlsButtonLeft(),
              child: const GameControlsBar(),
            ),

            // ============================================
            // ✅ SCORE VIEWING PAUSE (nouveau)
            // ============================================
            const ScoreViewingPauseOverlay(),

            // ============================================
            // COUNTDOWN OVERLAY
            // ============================================
            Positioned(
              top: 250.h,
              bottom: 0.h,
              left: 380.w,
              right: 380.w,
              child: const Center(child: CountdownOverlay()),
            ),

            // ============================================
            // VICTORY DIALOG
            // ============================================
            const VictoryDialog(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TOP BAR — Adapté au device
// ============================================================
class _TopBar extends GetView<GameController> {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left : Mode name + target
        Expanded(
          child: Obx(
                () => Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${controller.config.mode.translationKey.tr.toUpperCase()}:',
                  style: TextStyle(
                    fontFamily: GameConstants.gameFontFamily,
                    fontSize: GameScreenBreakpoints.topBarFontSize(),    // ✅
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.primary,
                    letterSpacing: 2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  ' ${controller.targetScore} pts',
                  style: TextStyle(
                    fontFamily: GameConstants.gameFontFamily,
                    fontSize: GameScreenBreakpoints.topBarFontSize(),    // ✅
                    color: ThemeColors.textSecondary,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),

        // Right : Game elapsed time
        Expanded(
          child: Obx(
                () => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${'time'.tr.toUpperCase()}: ',
                  style: TextStyle(
                    fontFamily: GameConstants.gameFontFamily,
                    fontSize: GameScreenBreakpoints.topBarFontSize(),    // ✅
                    color: ThemeColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    controller.elapsedFormatted,
                    style: TextStyle(
                      fontFamily: GameConstants.gameFontFamily,
                      fontSize: GameScreenBreakpoints.topBarTimeFontSize(), // ✅
                      fontWeight: FontWeight.w900,
                      color: ThemeColors.warning,
                      letterSpacing: 2,
                      shadows: ThemeColors.useGlow
                          ? [Shadow(color: ThemeColors.warning, blurRadius: 12)]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PLAYERS GRID — Adapté au device
// ============================================================
class _PlayersGrid extends GetView<GameController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final players = controller.players.toList();
      final count = players.length;
      int columns = 3;
      if (count == 2) {
        columns = 2;
      } else if (count == 1) {
        columns = 1;
      }

      final isCompact = count > 3;

      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing:
          GameScreenBreakpoints.playerCardHSpacing(),        // ✅
          mainAxisSpacing:
          GameScreenBreakpoints.playerCardVSpacing(),        // ✅
          mainAxisExtent:
          GameScreenBreakpoints.playerCardHeight(count),     // ✅
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          return PlayerScoreCard(
            player: players[index],
            index: index,
            targetScore: controller.targetScore,
            ballsPerTurn: controller.config.ballsPerTurn,
            isCompact: isCompact,
          );
        },
      );
    });
  }
}