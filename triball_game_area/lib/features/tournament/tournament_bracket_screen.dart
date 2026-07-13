// triball_game_area/lib/features/tournament/tournament_bracket_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/theme/theme_colors.dart';
import '../../widgets/floating_particles.dart';
import '../../widgets/themed_text.dart';
import '../game/utils/game_screen_breakpoints.dart';
import 'tournament_controller.dart';
import 'widgets/bracket_view.dart';
import 'widgets/champion_dialog.dart';
import 'widgets/tournament_stats_bar.dart';

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
                  padding: EdgeInsets.all(12.w),
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