// lib/features/tournament/widgets/match_card.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/tournament_model.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import '../tournament_controller.dart';

class MatchCard extends StatelessWidget {
  final TournamentMatch match;
  final bool isCurrent;
  final VoidCallback? onStart;

  const MatchCard({
    super.key,
    required this.match,
    this.isCurrent = false,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p1 = match.player1.value;
      final p2 = match.player2.value;
      final winner = match.winner.value;
      final isCompleted = match.isCompleted.value;
      final isInProgress = match.isInProgress.value;

      final borderColor = isCurrent
          ? ThemeColors.primary
          : (isCompleted
          ? ThemeColors.success.withOpacity(0.5)
          : ThemeColors.primary.withOpacity(0.2));

      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: ThemeColors.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: isCurrent ? 2.5 : 1.5,
          ),
          boxShadow: isCurrent && ThemeColors.useGlow
              ? [
            BoxShadow(
              color: ThemeColors.primary.withOpacity(0.5),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Match number + status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: isCurrent
                    ? ThemeColors.primary.withOpacity(0.2)
                    : ThemeColors.surface.withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'M${match.matchId + 1}',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: GameScreenBreakpoints.tournamentMatchHeaderFontSize(),
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  if (isCompleted)
                    Icon(Icons.check_circle,
                        color: ThemeColors.success, size: GameScreenBreakpoints.tournamentMatchIconSize())
                  else if (isInProgress)
                    Icon(Icons.play_circle,
                        color: ThemeColors.warning, size: GameScreenBreakpoints.tournamentMatchIconSize())
                  else if (isCurrent)
                      Text(
                        'tournament_play_now'.tr.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: GameScreenBreakpoints.tournamentMatchStatusFontSize(),
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                ],
              ),
            ),

            // Player 1
            _PlayerSlot(
              player: p1,
              isWinner: isCompleted && winner == p1,
              isLoser: isCompleted && winner != null && winner != p1,
              score: match.player1Score.value,
              showScore: isCompleted,
              playerIndex: p1?.id ?? 0,
            ),

            Divider(
              height: 1,
              color: ThemeColors.primary.withOpacity(0.15),
            ),

            // Player 2
            _PlayerSlot(
              player: p2,
              isWinner: isCompleted && winner == p2,
              isLoser: isCompleted && winner != null && winner != p2,
              score: match.player2Score.value,
              showScore: isCompleted,
              isBye: match.isBye && !isCompleted,
              playerIndex: p2?.id ?? 1,
            ),

            // Action button (if current)
            if (isCurrent && match.isReady && onStart != null)
              _AutoStartButton(
                key: ValueKey('auto_start_match_${match.matchId}'),
                matchId: match.matchId,
                onStart: onStart!,
              ),
              Padding(
                padding: EdgeInsets.all(6.w),
                child: InkWell(
                  onTap: onStart,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: ThemeColors.primary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6),
                      border:
                      Border.all(color: ThemeColors.primary, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow,
                            color: ThemeColors.primary, size: GameScreenBreakpoints.tournamentStartButtonIconSize()),
                        SizedBox(width: 4.w),
                        Text(
                          'play'.tr.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: GameScreenBreakpoints.tournamentStartButtonFontSize(),
                            fontWeight: FontWeight.w800,
                            color: ThemeColors.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _PlayerSlot extends StatelessWidget {
  final dynamic player;
  final bool isWinner;
  final bool isLoser;
  final int score;
  final bool showScore;
  final bool isBye;
  final int playerIndex;

  const _PlayerSlot({
    required this.player,
    required this.isWinner,
    required this.isLoser,
    required this.score,
    required this.showScore,
    this.isBye = false,
    required this.playerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final name = player?.name ?? '';
    final isEmpty = name.isEmpty;
    final color = Helpers.playerColor(playerIndex);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GameScreenBreakpoints.tournamentPlayerSlotPaddingH(),
        vertical: GameScreenBreakpoints.tournamentPlayerSlotPaddingV(),
      ),
      decoration: BoxDecoration(
        color: isWinner
            ? color.withOpacity(0.18)
            : (isLoser ? Colors.black.withOpacity(0.2) : Colors.transparent),
      ),
      child: Row(
        children: [
          if (!isEmpty && !isBye)
            Container(
              width: GameScreenBreakpoints.tournamentPlayerColorBarWidth(),
              height: GameScreenBreakpoints.tournamentPlayerColorBarHeight(),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (!isEmpty && !isBye) SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isBye
                  ? 'tournament_bye'.tr.toUpperCase()
                  : (isEmpty
                  ? 'tournament_tbd'.tr.toUpperCase()
                  : name.toUpperCase()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: GameScreenBreakpoints.tournamentPlayerFontSize(),
                fontWeight: isWinner ? FontWeight.w900 : FontWeight.w600,
                color: isEmpty || isBye
                    ? ThemeColors.textSecondary.withOpacity(0.5)
                    : (isWinner
                    ? color
                    : (isLoser
                    ? ThemeColors.textSecondary.withOpacity(0.5)
                    : ThemeColors.textPrimary)),
                letterSpacing: 0.8,
              ),
            ),
          ),
          if (isWinner)
            Icon(Icons.emoji_events, color: color, size: GameScreenBreakpoints.tournamentMatchIconSize()),
          if (showScore && !isEmpty && !isBye)
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                '$score',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: GameScreenBreakpoints.tournamentPlayerFontSize(),
                  fontWeight: FontWeight.w900,
                  color: isWinner
                      ? color
                      : ThemeColors.textSecondary.withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AutoStartButton extends StatefulWidget {
  final int matchId;
  final VoidCallback onStart;

  const _AutoStartButton({
    super.key,
    required this.matchId,
    required this.onStart,
  });

  @override
  State<_AutoStartButton> createState() => _AutoStartButtonState();
}

class _AutoStartButtonState extends State<_AutoStartButton> {
  static const int _initialCountdown = 7;
  int _countdown = _initialCountdown;
  Timer? _timer;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant _AutoStartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matchId != widget.matchId) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _countdown = _initialCountdown;
    _hasStarted = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _hasStarted) {
        timer.cancel();
        return;
      }

      final next = _countdown - 1;
      if (next <= 0) {
        timer.cancel();
        _hasStarted = true;
        if (mounted) setState(() => _countdown = 0);

        widget.onStart();
        return;
      }

      if (mounted) setState(() => _countdown = next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: ThemeColors.primary.withOpacity(0.25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ThemeColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow,
                color: ThemeColors.primary, size: GameScreenBreakpoints.tournamentStartButtonIconSize()),
            SizedBox(width: 4.w),
            Text(
              '${'auto_start_in'.tr} $_countdown s',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: GameScreenBreakpoints.tournamentStartButtonFontSize(),
                fontWeight: FontWeight.w800,
                color: ThemeColors.primary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}