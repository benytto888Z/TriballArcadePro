// triball_game_area/lib/features/tournament/tournament_bracket_screen.dart
// ⚠️ ARCHIVE — copie obsolete, non compilée (hors lib/). Déplacée depuis triball_game_area/lib/features/tournament/tournament_bracket_screenOLD.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tribal_game_area/core/theme/theme_colors.dart';
import 'package:tribal_game_area/widgets/floating_particles.dart';
import 'package:tribal_game_area/widgets/themed_text.dart';
import 'package:tribal_game_area/features/game/utils/game_screen_breakpoints.dart';
import 'package:tribal_game_area/features/tournament/tournament_controller.dart';
import 'package:tribal_game_area/features/tournament/widgets/bracket_view.dart';
import 'package:tribal_game_area/features/tournament/widgets/champion_dialog.dart';
import 'package:tribal_game_area/features/tournament/widgets/tournament_stats_bar.dart';

class TournamentBracketScreen extends GetView<TournamentController> {
  const TournamentBracketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundDeep,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: ThemeColors.backgroundGradient,
            ),
          ),
          FloatingParticles(
            count: GameScreenBreakpoints.particlesCount(),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: GameScreenBreakpoints.tournamentScreenPadding(),
                  child: const TournamentStatsBar(),
                ),
                Expanded(
                  child: Obx(() {
                    final t = controller.tournament.value;
                    if (t == null) {
                      return Center(
                        child: ThemedText.body('loading'.tr),
                      );
                    }
                    return BracketView(tournament: t);
                  }),
                ),
              ],
            ),
          ),
          const ChampionDialog(),
        ],
      ),
    );
  }
}