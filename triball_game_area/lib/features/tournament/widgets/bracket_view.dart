import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/tournament_model.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import 'round_grid.dart';

/// Bracket vertical composé de RoundGrid.
///
/// À chaque changement de round, le scroll attend que TournamentBracketScreen
/// redevienne réellement visible, puis place le nouveau round en haut.
class BracketView extends StatefulWidget {
  final TournamentModel tournament;

  const BracketView({
    super.key,
    required this.tournament,
  });

  @override
  State<BracketView> createState() => _BracketViewState();
}

class _BracketViewState extends State<BracketView> {
  late List<GlobalKey> _roundKeys;
  Worker? _roundWorker;
  Timer? _routeVisibilityTimer;
  int? _pendingRound;
  bool _scrolling = false;

  @override
  void initState() {
    super.initState();
    _createRoundKeys();
    _listenToRoundChanges();
  }

  @override
  void didUpdateWidget(covariant BracketView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.tournament, widget.tournament)) {
      _roundWorker?.dispose();
      _routeVisibilityTimer?.cancel();
      _pendingRound = null;
      _createRoundKeys();
      _listenToRoundChanges();
    }
  }

  void _createRoundKeys() {
    _roundKeys = List<GlobalKey>.generate(
      widget.tournament.totalRounds,
          (_) => GlobalKey(),
    );
  }

  void _listenToRoundChanges() {
    _roundWorker = ever<int>(
      widget.tournament.currentRound,
          (round) {
        if (round <= 1) return;
        _pendingRound = round;
        _waitUntilBracketIsVisible();
      },
    );

    // Cas où le widget est recréé alors que le tournoi est déjà avancé.
    final currentRound = widget.tournament.currentRound.value;
    if (currentRound > 1) {
      _pendingRound = currentRound;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _waitUntilBracketIsVisible();
      });
    }
  }

  void _waitUntilBracketIsVisible() {
    _routeVisibilityTimer?.cancel();

    // Le résultat du match est enregistré pendant que GameScreen est encore
    // au-dessus. On vérifie périodiquement la visibilité sans consommer le
    // scroll en arrière-plan.
    _routeVisibilityTimer = Timer.periodic(
      const Duration(milliseconds: 200),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final route = ModalRoute.of(context);
        if (route?.isCurrent != true) return;

        timer.cancel();
        _routeVisibilityTimer = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToPendingRound();
        });
      },
    );
  }

  Future<void> _scrollToPendingRound() async {
    if (!mounted || _scrolling) return;

    final round = _pendingRound;
    if (round == null || round <= 1 || round > _roundKeys.length) return;

    final targetContext = _roundKeys[round - 1].currentContext;
    if (targetContext == null) {
      // La grille peut nécessiter une frame supplémentaire après le retour.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToPendingRound();
      });
      return;
    }

    _scrolling = true;
    try {
      await Scrollable.ensureVisible(
        targetContext,
        alignment: 0.02,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
      _pendingRound = null;
    } finally {
      _scrolling = false;
    }
  }

  @override
  void dispose() {
    _roundWorker?.dispose();
    _routeVisibilityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalRounds = widget.tournament.totalRounds;
      final currentMatch = widget.tournament.currentMatch;

      return Scrollbar(
        // La TV n'a pas besoin d'une barre manipulable ; le mouvement est auto.
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
              final matches = widget.tournament.getMatchesForRound(round);
              final roundLabel = widget.tournament.roundName(round).tr;

              return Padding(
                key: _roundKeys[index],
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
