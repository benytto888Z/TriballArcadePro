// triball_game_area/lib/features/tournament/widgets/tournament_stats_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/theme_colors.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import '../tournament_controller.dart';

class TournamentStatsBar extends GetView<TournamentController> {
  const TournamentStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = controller.tournament.value;
      if (t == null) return const SizedBox.shrink();

      final progress = t.progress;
      final completed = t.completedMatchesCount;
      final total = t.totalMatchesCount;

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: GameScreenBreakpoints.tournamentStatsPaddingH(),
          vertical: GameScreenBreakpoints.tournamentStatsPaddingV(),
        ),
        decoration: BoxDecoration(
          color: ThemeColors.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ThemeColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.account_tree,
                color: ThemeColors.primary, size: GameScreenBreakpoints.tournamentStatsIconSize()),
            SizedBox(width: 8.w),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.name.toUpperCase(),
                    style: TextStyle(
                      fontFamily: GameConstants.gameFontFamily,
                      fontSize: GameScreenBreakpoints.tournamentStatsTitleSize() * 1.3,
                      fontWeight: FontWeight.w900,
                      color: ThemeColors.primary,
                      shadows: [ Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 7)],
                      letterSpacing: 1.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: 15.w),
                  Text(
                    '${'tournament_round'.tr} ${t.currentRound.value}/${t.totalRounds} · $completed/$total',
                    style: TextStyle(
                      fontFamily: GameConstants.gameFontFamily,
                      fontSize: GameScreenBreakpoints.tournamentStatsSubtitleSize() * 1.3,
                      color: ThemeColors.textSecondary,
                      shadows: [ Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 7)],
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: GameScreenBreakpoints.tournamentProgressWidth() * 1.4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: GameScreenBreakpoints.tournamentProgressHeight(),
                      backgroundColor: ThemeColors.primary.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(ThemeColors.warning),
                    ),
                  ),
                  SizedBox(width: 22.w),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontFamily: GameConstants.gameFontFamily,
                      fontSize: GameScreenBreakpoints.tournamentStatsSubtitleSize() * 1.3,
                      color: ThemeColors.warning,
                      shadows: [ Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 7)],
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}