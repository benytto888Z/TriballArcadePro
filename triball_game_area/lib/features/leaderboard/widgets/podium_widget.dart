// triball_game_area/lib/features/leaderboard/widgets/podium_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../../data/models/leaderboard_entry_model.dart';
import '../../../widgets/player_avatar_widget.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import 'animated_triball_background.dart';

class PodiumWidget extends StatelessWidget {
  final List<LeaderboardEntryModel> top3;

  const PodiumWidget({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();

    return Container(
      height: GameScreenBreakpoints.lbPodiumHeight(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            ThemeColors.backgroundDeep.withOpacity(0.6),
            ThemeColors.surface.withOpacity(0.4),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: ThemeColors.primary.withOpacity(0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(
              child: AnimatedTriballBackground(opacity: 0.35),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (top3.length >= 2)
                    _PodiumStep(rank: 2, entry: top3[1],
                        pillarHeight: GameScreenBreakpoints.lbPodiumPillar2Height(),
                        color: const Color(0xFFC0C0C0), emoji: '🥈'),
                  SizedBox(width: 8.w),
                  _PodiumStep(rank: 1, entry: top3[0],
                      pillarHeight: GameScreenBreakpoints.lbPodiumPillar1Height(),
                      color: const Color(0xFFFFD700), emoji: '🥇', isFirst: true),
                  SizedBox(width: 8.w),
                  if (top3.length >= 3)
                    _PodiumStep(rank: 3, entry: top3[2],
                        pillarHeight: GameScreenBreakpoints.lbPodiumPillar3Height(),
                        color: const Color(0xFFCD7F32), emoji: '🥉'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumStep extends StatelessWidget {
  final int rank;
  final LeaderboardEntryModel entry;
  final double pillarHeight;
  final Color color;
  final String emoji;
  final bool isFirst;

  const _PodiumStep({
    required this.rank,
    required this.entry,
    required this.pillarHeight,
    required this.color,
    required this.emoji,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: GameScreenBreakpoints.lbPodiumCardWidth(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(emoji, style: TextStyle(
              fontSize: GameScreenBreakpoints.lbPodiumEmojiSize())),
          SizedBox(height: 2.h),

          PlayerAvatarWidget(
            playerName: entry.playerName,
            playerIndex: rank - 1,
            size: GameScreenBreakpoints.lbPodiumCardWidth() * 0.4,
            borderWidth: 2,
            gameMode: entry.gameMode.key,
          ),
          SizedBox(height: 4.h),
          Text(
            entry.playerName.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: GameScreenBreakpoints.lbPodiumNameFontSize(),
              fontWeight: FontWeight.w800,
              color: color,
              shadows: [Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 4)],
            ),
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Text(
              entry.timeFormatted,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: GameScreenBreakpoints.lbPodiumTimeFontSize(),
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            width: GameScreenBreakpoints.lbPodiumCardWidth() * 0.8,
            height: pillarHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.85), color.withOpacity(0.5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.6), blurRadius: 18),
              ],
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: GameScreenBreakpoints.lbPodiumRankFontSize(),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [Shadow(color: color, blurRadius: 12)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}