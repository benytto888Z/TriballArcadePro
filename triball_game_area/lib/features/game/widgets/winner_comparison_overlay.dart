import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/game_time_formatter.dart';
import '../../../data/models/player_model.dart';
import '../game_controller.dart';

/// Tableau comparatif affiché avant le VictoryDialog lorsque plusieurs joueurs
/// atteignent la cible à la fin du même tour complet.
class WinnerComparisonOverlay extends GetView<GameController> {
  const WinnerComparisonOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showWinnerComparison.value) {
        return const SizedBox.shrink();
      }

      final candidates = controller.comparisonPlayers.toList();
      final selected = controller.comparisonWinner.value;

      return Positioned.fill(
        child: Material(
          color: Colors.black.withOpacity(0.90),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .94,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(22.w),
                    decoration: BoxDecoration(
                      color: ThemeColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ThemeColors.warning, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeColors.warning.withOpacity(.35),
                          blurRadius: 36,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.compare_arrows,
                            color: ThemeColors.warning, size: 46.sp),
                        SizedBox(height: 8.h),
                        Text(
                          'winner_comparison_title'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: ThemeColors.warning,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          controller.comparisonReasonKey.value.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 12.sp,
                            color: ThemeColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: candidates.map((player) {
                              final highlighted = selected == null || selected == player;
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 7.w),
                                child: _PlayerComparisonCard(
                                  player: player,
                                  highlighted: highlighted,
                                  selectedWinner: selected == player,
                                  targetTime:
                                      controller.targetReachedTimeFor(player),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          '${'victory_in'.tr} ${controller.comparisonCountdown.value} s',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: ThemeColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _PlayerComparisonCard extends StatelessWidget {
  final PlayerModel player;
  final bool highlighted;
  final bool selectedWinner;
  final Duration targetTime;

  const _PlayerComparisonCard({
    required this.player,
    required this.highlighted,
    required this.selectedWinner,
    required this.targetTime,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedWinner ? ThemeColors.success : ThemeColors.primary;
    return AnimatedOpacity(
      opacity: highlighted ? 1 : .48,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: 245.w.clamp(210.0, 340.0).toDouble(),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: color.withOpacity(selectedWinner ? .16 : .08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: selectedWinner ? 3 : 1.5),
        ),
        child: Column(
          children: [
            if (selectedWinner)
              Icon(Icons.emoji_events, color: ThemeColors.success, size: 30.sp),
            Text(
              player.name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            SizedBox(height: 10.h),
            _row('score'.tr, '${player.score.value}'),
            _row('balls_thrown'.tr, '${player.ballsThrown.value}'),
            _row('time'.tr, GameTimeFormatter.mmSsHundredths(targetTime)),
            _row('accuracy'.tr, '${player.accuracy.toStringAsFixed(0)}%'),
            _row('positive_hits'.tr,
                '${player.positiveHitRate.toStringAsFixed(0)}%'),
            _row('bonus'.tr, '${player.bonusShots.value}'),
            _row('combo_max'.tr, '×${player.maxComboCount.value}'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10.sp,
                    color: ThemeColors.textSecondary)),
          ),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  color: ThemeColors.textPrimary)),
        ],
      ),
    );
  }
}
