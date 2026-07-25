// triball_game_area/lib/features/tournament/widgets/round_column.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/tournament_model.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import '../tournament_controller.dart';
import 'match_card.dart';

class RoundColumn extends StatelessWidget {
  final int round;
  final String roundLabel;
  final List<TournamentMatch> matches;
  final TournamentMatch? currentMatch;

  const RoundColumn({
    super.key,
    required this.round,
    required this.roundLabel,
    required this.matches,
    required this.currentMatch,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TournamentController>();

    return SizedBox(
      width: GameScreenBreakpoints.tournamentRoundWidth(),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: GameScreenBreakpoints.tournamentRoundHeaderPaddingH(),
            vertical: GameScreenBreakpoints.tournamentRoundHeaderPaddingV(),
          ),
          margin: EdgeInsets.only(
            bottom: GameScreenBreakpoints.tournamentRoundHeaderBottom(),
          ),
          decoration: BoxDecoration(
            color: ThemeColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ThemeColors.primary.withOpacity(0.5),
            ),
          ),
          child: Text(
            roundLabel.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: GameScreenBreakpoints.tournamentRoundHeaderSize(),
              fontWeight: FontWeight.w900,
              color: ThemeColors.primary,
              letterSpacing: 2,
            ),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: matches.map((match) {
                return MatchCard(
                  match: match,
                  isCurrent: match == currentMatch,
                  onStart: match == currentMatch
                      ? () => controller.startCurrentMatch()
                      : null,
                );
              }).toList(),
            ),
          ),
        ),
      ],
      ),
    );
  }
}