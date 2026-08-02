import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/tournament_model.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import '../tournament_controller.dart';
import 'match_card.dart';

/// Affiche tous les matchs d'un round dans une grille compacte.
///
/// Exemples :
/// - 8 matchs : 4 colonnes × 2 lignes
/// - 4 matchs : 4 colonnes × 1 ligne
/// - 2 matchs : 2 colonnes × 1 ligne
/// - 1 match  : 1 colonne × 1 ligne
class RoundGrid extends StatelessWidget {
  final int round;
  final String roundLabel;
  final List<TournamentMatch> matches;
  final TournamentMatch? currentMatch;

  const RoundGrid({
    super.key,
    required this.round,
    required this.roundLabel,
    required this.matches,
    required this.currentMatch,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TournamentController>();
    final columns = GameScreenBreakpoints.tournamentGridColumns(matches.length);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: GameScreenBreakpoints.tournamentRoundHeaderPaddingH(),
        vertical: GameScreenBreakpoints.tournamentRoundHeaderPaddingV(),
      ),
      decoration: BoxDecoration(
        color: ThemeColors.surface.withOpacity(0.34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.primary.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() => _RoundHeader(
                round: round,
                label: roundLabel,
                completed: matches.where((m) => m.isCompleted.value).length,
                total: matches.length,
              )),
          SizedBox(height: GameScreenBreakpoints.tournamentRoundHeaderBottom()),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: matches.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: GameScreenBreakpoints.tournamentGridHSpacing(),
              mainAxisSpacing: GameScreenBreakpoints.tournamentGridVSpacing(),
              mainAxisExtent: GameScreenBreakpoints.tournamentGridCardExtent(),
            ),
            itemBuilder: (context, index) {
              final match = matches[index];
              final isCurrent = identical(match, currentMatch);
              return MatchCard(
                key: ValueKey('tournament_match_${match.matchId}'),
                match: match,
                isCurrent: isCurrent,
                onStart: isCurrent ? controller.startCurrentMatch : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RoundHeader extends StatelessWidget {
  final int round;
  final String label;
  final int completed;
  final int total;

  const _RoundHeader({
    required this.round,
    required this.label,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: GameScreenBreakpoints.tournamentMatchIconSize() * 1.3,
          height: GameScreenBreakpoints.tournamentMatchIconSize() * 1.3,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeColors.primary.withOpacity(0.18),
            border: Border.all(color: ThemeColors.primary.withOpacity(0.65)),
          ),
          child: Text(
            '$round',
            style: TextStyle(
              fontFamily: GameConstants.gameFontFamily,
              fontSize: GameScreenBreakpoints.tournamentMatchHeaderFontSize() * 1.3,
              fontWeight: FontWeight.w900,
              color: ThemeColors.primary,
              shadows: [ Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 7)],
            ),
          ),
        ),
        SizedBox(width: GameScreenBreakpoints.tournamentGridHSpacing()),
        Expanded(
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily:  GameConstants.gameFontFamily,
              fontSize: GameScreenBreakpoints.tournamentRoundHeaderSize(),
              fontWeight: FontWeight.w900,
              color: ThemeColors.primary,
              shadows: [ Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 7)],
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: GameScreenBreakpoints.tournamentRoundHeaderPaddingH(),
            vertical: GameScreenBreakpoints.tournamentRoundHeaderPaddingV() * .5,
          ),
          decoration: BoxDecoration(
            color: ThemeColors.success.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$completed / $total',
            style: TextStyle(
              fontFamily: GameConstants.gameFontFamily,
              fontSize: GameScreenBreakpoints.tournamentMatchStatusFontSize() *1.3,
              fontWeight: FontWeight.w800,
              color: ThemeColors.success,
              shadows: [ Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 7)],
            ),
          ),
        ),
      ],
    );
  }
}
