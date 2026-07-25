// triball_game_area/lib/features/tournament/widgets/champion_dialog.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/services/game_settings_service.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../tournament_controller.dart';
import '../../game/utils/game_screen_breakpoints.dart';

class ChampionDialog extends GetView<TournamentController> {
  const ChampionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tournament = controller.tournament.value;
      if (tournament == null) return const SizedBox.shrink();
      if (!tournament.isCompleted.value) return const SizedBox.shrink();
      final champion = tournament.champion.value;
      if (champion == null) return const SizedBox.shrink();

      final color = Helpers.playerColor(champion.id);

      return _ChampionDialogContent(
        championName: champion.name,
        color: color,
        totalMatches: tournament.totalMatchesCount,
        totalDuration: tournament.totalDurationFormatted,
        totalPlayers: tournament.players.length,
        onBackToWaiting: controller.backToWaiting,
      );
    });
  }
}

class _ChampionDialogContent extends StatefulWidget {
  final String championName;
  final Color color;
  final int totalMatches;
  final String totalDuration;
  final int totalPlayers;
  final VoidCallback onBackToWaiting;

  const _ChampionDialogContent({
    required this.championName,
    required this.color,
    required this.totalMatches,
    required this.totalDuration,
    required this.totalPlayers,
    required this.onBackToWaiting,
  });

  @override
  State<_ChampionDialogContent> createState() =>
      _ChampionDialogContentState();
}

class _ChampionDialogContentState extends State<_ChampionDialogContent> {
  int _autoReturnCountdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    try {
      final settings = Get.find<GameSettingsService>();
      _autoReturnCountdown = settings.leaderboardDisplaySeconds.value;
    } catch (_) {
      _autoReturnCountdown = 30;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _autoReturnCountdown--);
      if (_autoReturnCountdown <= 0) {
        timer.cancel();
        widget.onBackToWaiting();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, scale, _) {
            final screenHeight = MediaQuery.of(context).size.height;
            return Transform.scale(
              scale: scale,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: GameScreenBreakpoints.tournamentChampionDialogWidth(),
                  maxHeight: screenHeight *
                      GameScreenBreakpoints.tournamentChampionDialogMaxHeight(),
                ),
                child: SingleChildScrollView(
                  child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  GameScreenBreakpoints.tournamentChampionPadding(),
                ),
                decoration: BoxDecoration(
                  color: ThemeColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: widget.color, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.7),
                      blurRadius: 50,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🏆', style: TextStyle(fontSize: GameScreenBreakpoints.tournamentChampionTrophySize())),
                    SizedBox(height: 6.h),
                    Text(
                      'tournament_winner'.tr.toUpperCase(),
                      style: TextStyle(
                        fontFamily: GameConstants.gameFontFamily,
                        fontSize: GameScreenBreakpoints.tournamentChampionTitleSize(),
                        fontWeight: FontWeight.w800,
                        color: widget.color,
                        letterSpacing: 4,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      widget.championName.toUpperCase(),
                      style: TextStyle(
                        fontFamily: GameConstants.gameFontFamily,
                        fontSize: GameScreenBreakpoints.tournamentChampionNameSize(),
                        fontWeight: FontWeight.w900,
                        color: ThemeColors.textPrimary,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(color: widget.color, blurRadius: 20),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Stat(
                          icon: Icons.format_list_numbered,
                          label: 'tournament_matches'.tr,
                          value: '${widget.totalMatches}',
                          color: widget.color,
                        ),
                        _Stat(
                          icon: Icons.timer,
                          label: 'time'.tr,
                          value: widget.totalDuration,
                          color: widget.color,
                        ),
                        _Stat(
                          icon: Icons.group,
                          label: 'players'.tr,
                          value: '${widget.totalPlayers}',
                          color: widget.color,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      '${'auto_return_in'.tr} $_autoReturnCountdown s',
                      style: TextStyle(
                        fontFamily: GameConstants.gameFontFamily,
                        fontSize: 12.sp,
                        color: ThemeColors.textSecondary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: GameConstants.gameFontFamily,
            fontSize: GameScreenBreakpoints.tournamentChampionStatLabelSize(),
            color: ThemeColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: GameConstants.gameFontFamily,
            fontSize: GameScreenBreakpoints.tournamentChampionStatValueSize(),
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}