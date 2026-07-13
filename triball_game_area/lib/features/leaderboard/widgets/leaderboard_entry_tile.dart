// triball_game_area/lib/features/leaderboard/widgets/leaderboard_entry_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/leaderboard_entry_model.dart';
import '../../../widgets/player_avatar_widget.dart';
import '../../game/utils/game_screen_breakpoints.dart';

class LeaderboardEntryTile extends StatelessWidget {
  final LeaderboardEntryModel entry;
  final int rank;
  final Color rankColor;
  final String rankEmoji;

  const LeaderboardEntryTile({
    super.key,
    required this.entry,
    required this.rank,
    required this.rankColor,
    required this.rankEmoji,
  });

  bool get isTop3 => rank <= 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: GameScreenBreakpoints.lbEntrySpacing(),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: GameScreenBreakpoints.lbEntryPaddingH(),
        vertical: GameScreenBreakpoints.lbEntryPaddingV(),
      ),
      decoration: BoxDecoration(
        color: isTop3
            ? rankColor.withOpacity(0.1)
            : ThemeColors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTop3
              ? rankColor.withOpacity(0.6)
              : ThemeColors.primary.withOpacity(0.2),
          width: isTop3 ? 1.5 : 1,
        ),
        boxShadow: isTop3 && ThemeColors.useGlow
            ? [BoxShadow(color: rankColor.withOpacity(0.3), blurRadius: 10)]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: GameScreenBreakpoints.lbEntryRankBadgeSize(),
            child: isTop3
                ? Text(
              rankEmoji,
              style: TextStyle(
                fontSize: GameScreenBreakpoints.lbEntryRankEmojiSize(),
              ),
              textAlign: TextAlign.center,
            )
                : Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: ThemeColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ThemeColors.primary.withOpacity(0.4),
                ),
              ),
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: GameScreenBreakpoints.lbStatValueFontSize() * 0.7,
                  fontWeight: FontWeight.w900,
                  color: ThemeColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          PlayerAvatarWidget(
            playerName: entry.playerName,
            playerIndex: rank - 1,
            size: GameScreenBreakpoints.lbEntryRankBadgeSize() * 0.8,
            borderWidth: 1.5,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.playerName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: GameScreenBreakpoints.lbEntryNameFontSize(),
                    fontWeight: FontWeight.w800,
                    color: isTop3 ? rankColor : ThemeColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: GameScreenBreakpoints.lbEntryDateFontSize(),
                        color: ThemeColors.textSecondary),
                    SizedBox(width: 3.w),
                    Text(
                      entry.dateFormatted,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: GameScreenBreakpoints.lbEntryDateFontSize(),
                        color: ThemeColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(Icons.sports_baseball,
                        size: GameScreenBreakpoints.lbEntryDateFontSize(),
                        color: ThemeColors.textSecondary),
                    SizedBox(width: 3.w),
                    Text(
                      '${entry.totalBalls}',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: GameScreenBreakpoints.lbEntryDateFontSize(),
                        color: ThemeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: rankColor.withOpacity(0.5)),
            ),
            child: Text(
              entry.timeFormatted,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: GameScreenBreakpoints.lbEntryTimeFontSize(),
                fontWeight: FontWeight.w900,
                color: rankColor,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}