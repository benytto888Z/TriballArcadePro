// lib/features/game/widgets/player_score_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/game_state_model.dart';
import '../../../data/models/player_model.dart';
import '../../../data/models/score_event_model.dart';
import '../../../widgets/player_avatar_widget.dart';
import '../game_controller.dart';
import '../utils/game_screen_breakpoints.dart'; // ✅ NEW

class PlayerScoreCard extends StatelessWidget {
  final PlayerModel player;
  final int index;
  final int targetScore;
  final int ballsPerTurn;
  final bool isCompact;

  const PlayerScoreCard({
    super.key,
    required this.player,
    required this.index,
    required this.targetScore,
    required this.ballsPerTurn,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Helpers.playerColor(index);

    return Obx(() {
      final isActive = player.isActive.value;
      final score = player.score.value;
      final progress = (score / targetScore).clamp(0.0, 1.0);
      final controller = Get.find<GameController>();
      final isHardcoreOvershoot =
          controller.gameMode == GameMode.hardcore &&
          score > controller.targetScore;
      return LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;

          // ✅ Utilise breakpoints
          final scoreSize = GameScreenBreakpoints.playerScoreFontSize(
            isCompact,
            h,
          );
          final showProgress = h > 100;
          final showRecentEvents = h > 100;
          final borderWidthActive =
              GameScreenBreakpoints.playerBorderWidthActive() *1.5;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            padding: EdgeInsets.only(
              left: GameScreenBreakpoints.playerCardPadding(isCompact), // ✅
              right: GameScreenBreakpoints.playerCardPadding(isCompact), // ✅
              top: GameScreenBreakpoints.playerCardPadding(isCompact), // ✅
              bottom: GameScreenBreakpoints.playerCardPaddingBootom(
                isCompact,
              ), // ✅
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: 0.05)
                  : ThemeColors.surface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? color : color.withValues(alpha: 0.3),
                width: isActive ? borderWidthActive : 1.5,
              ),
              boxShadow: isActive && ThemeColors.useGlow
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                        spreadRadius: 1,
                      ),
                    ]
                  : null/*[
                      BoxShadow(
                        color: Color(0xff0b0302),
                        offset: Offset(0, 6),
                        blurRadius: 5,
                      ),
                    ],*/
            ),
            child: Column(
              children: [
                // ============= HEADER =============
                Row(
                  children: [
                    // ✅ AVATAR (photo ou badge numéro)
                    PlayerAvatarWidget(
                      playerName: player.name,
                      playerIndex: index,
                      size: GameScreenBreakpoints.playerBadgeSize(),
                      borderWidth: isActive ? 5 : 2,
                    ),
                    SizedBox(width: 10.w),

                    // Nom du joueur
                    Expanded(
                      child: Text(
                        player.name.toUpperCase(),
                        style: TextStyle(
                          fontFamily: GameConstants.gameFontFamily,
                          fontSize: GameScreenBreakpoints.playerNameFontSize(
                            isCompact,
                          ),
                          fontWeight: FontWeight.w800,
                          color: isActive ? color : ThemeColors.textPrimary,
                          shadows: [
                            Shadow(
                              color: Color(0xff0b0302),
                              offset: Offset(0, 6),
                              blurRadius: 5,
                            ),
                          ],
                          letterSpacing: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // Badge tour
                    Obx(() {
                      final turn = player.turnsPlayed.value + 1;
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.h,
                        ),
                        margin: EdgeInsets.only(right: 2.w),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: color.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'T$turn',
                          style: TextStyle(
                            fontFamily: GameConstants.gameFontFamily,
                            fontSize:
                                GameScreenBreakpoints.playerTurnBadgeFontSize(),
                            fontWeight: FontWeight.w800,
                            color: color,
                            shadows: [
                              Shadow(
                                color: Color(0xff0b0302),
                                offset: Offset(0, 6),
                                blurRadius: 5,
                              ),
                            ],
                            letterSpacing: 0.5,
                            height: 1,
                          ),
                        ),
                      );
                    }),
                    SizedBox(width: 10.w),
                    // Score
                    Text(
                      '$score',
                      style: TextStyle(
                        fontFamily: GameConstants.gameFontFamily,
                        fontSize: scoreSize * 0.9,
                        fontWeight: FontWeight.w900,
                        color: isHardcoreOvershoot
                            ? ThemeColors
                                  .warning // ✅ Orange si dépassement
                            : color,
                        letterSpacing: 2,
                        height: 1,
                        shadows: isActive && ThemeColors.useGlow
                            ? [
                                Shadow(
                                  color: isHardcoreOvershoot
                                      ? ThemeColors.warning
                                      : color,
                                  blurRadius: 20,
                                ),
                              ]
                            : [
                                Shadow(
                                  color: Color(0xff0b0302),
                                  offset: Offset(0, 6),
                                  blurRadius: 5,
                                ),
                              ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // Star active
                    if (isActive)
                      Padding(
                        padding: EdgeInsets.only(left: 1.w),
                        child: Icon(
                          Icons.star,
                          size: GameScreenBreakpoints.playerStarSize(),
                          color: color,
                          shadows: [
                            Shadow(
                              color: Color(0xff0b0302),
                              offset: Offset(0, 6),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 24.h),

                // ============= PROGRESS BAR =============
                if (showProgress)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: GameScreenBreakpoints.playerProgressHeight(),
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),

                // ============= RECENT EVENTS =============
                if (showRecentEvents) ...[
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: GameScreenBreakpoints.sizeboxBetweenProEvents(),
                  ),
                  _PlayerRecentEvents(
                    events: player.recentEvents.toList(),
                    color: color,
                    isCompact: isCompact,
                  ),
                ],
              ],
            ),
          );
        },
      );
    });
  }
}

// ============================================================
// RECENT EVENTS
// ============================================================
class _PlayerRecentEvents extends StatelessWidget {
  final List<ScoreEventModel> events;
  final Color color;
  final bool isCompact;

  const _PlayerRecentEvents({
    required this.events,
    required this.color,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return SizedBox(
        height: 22.h,
        child: Center(
          child: Text(
            '—',
            style: TextStyle(
              fontFamily: GameConstants.gameFontFamily,
              fontSize: GameScreenBreakpoints.eventEmptyFontSize(), // ✅
              color: ThemeColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: events.take(5).map((event) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: _EventChip(event: event, isCompact: isCompact),
          );
        }).toList(),
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  final ScoreEventModel event;
  final bool isCompact;

  const _EventChip({required this.event, required this.isCompact});

  Color _color() {
    if (event.isX0) return ThemeColors.error;
    if (event.isX2) return ThemeColors.warning;
    if (event.value >= 30) return ThemeColors.primary;
    if (event.isPositive) return ThemeColors.success;
    if (event.isNegative) return ThemeColors.error;
    return ThemeColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GameScreenBreakpoints.eventChipPadding(), // ✅
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        event.displayValue,
        style: TextStyle(
          fontFamily: GameConstants.gameFontFamily,
          fontSize: GameScreenBreakpoints.eventChipFontSize(isCompact), // ✅
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
    );
  }
}
