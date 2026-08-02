import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/tournament_model.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import 'round_grid.dart';

/// Bracket vertical composé de RoundGrid.
/// Tous les matchs d'un round sont visibles simultanément, jusqu'à 4 par ligne.
class BracketView extends StatelessWidget {
  final TournamentModel tournament;
  const BracketView({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalRounds = tournament.totalRounds;
      final currentMatch = tournament.currentMatch;

      return Scrollbar(
        thumbVisibility: GameScreenBreakpoints.isMobile ||
            GameScreenBreakpoints.isTablet ||
            GameScreenBreakpoints.isIPad,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: GameScreenBreakpoints.tournamentBracketPaddingH(),
            vertical: GameScreenBreakpoints.tournamentBracketPaddingV(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(totalRounds, (index) {
              final round = index + 1;
              final matches = tournament.getMatchesForRound(round);
              final roundLabel = tournament.roundName(round).tr;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == totalRounds - 1
                      ? 0
                      : GameScreenBreakpoints.tournamentRoundSectionSpacing(),
                ),
                child: RoundGrid(
                  round: round,
                  roundLabel: roundLabel,
                  matches: matches,
                  currentMatch: currentMatch,
                ),
              );
            }),
          ),
        ),
      );
    });
  }
}
