// triball_game_area/lib/features/tournament/widgets/bracket_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/tournament_model.dart';
import 'round_column.dart';

class BracketView extends StatelessWidget {
  final TournamentModel tournament;

  const BracketView({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalRounds = tournament.totalRounds;
      final currentMatch = tournament.currentMatch;

      return LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: availableHeight,
                maxHeight: availableHeight,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(totalRounds, (i) {
                  final round = i + 1;
                  final matches = tournament.getMatchesForRound(round);
                  final roundLabel = tournament.roundName(round).tr;

                  return Padding(
                    padding: EdgeInsets.only(right: 20.w),
                    child: SizedBox(
                      height: availableHeight,
                      child: RoundColumn(
                        round: round,
                        roundLabel: roundLabel,
                        matches: matches,
                        currentMatch: currentMatch,
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      );
    });
  }
}