// lib/data/models/match_type_model.dart

/// Type de match : détermine la structure du jeu
/// (nombre de joueurs, top 10, etc.)
enum MatchType {
  competition,   // 2-6 joueurs, tour rotatif
  soloChrono,    // 1 joueur, chrono, top 10 enregistré
  tournament,    // 4/8/16 joueurs, bracket élimination
}

extension MatchTypeX on MatchType {
  /// Clé pour serialization JSON / storage
  String get key {
    switch (this) {
      case MatchType.competition: return 'competition';
      case MatchType.soloChrono:  return 'solo_chrono';
      case MatchType.tournament:  return 'tournament';
    }
  }

  /// Clé de traduction (i18n)
  String get translationKey {
    switch (this) {
      case MatchType.competition: return 'match_type_competition';
      case MatchType.soloChrono:  return 'match_type_solo_chrono';
      case MatchType.tournament:  return 'match_type_tournament';
    }
  }

  /// Clé description i18n
  String get descriptionKey {
    switch (this) {
      case MatchType.competition: return 'match_type_competition_desc';
      case MatchType.soloChrono:  return 'match_type_solo_chrono_desc';
      case MatchType.tournament:  return 'match_type_tournament_desc';
    }
  }

  String get displayName {
    switch (this) {
      case MatchType.competition: return 'Compétition';
      case MatchType.soloChrono:  return 'Solo Chrono';
      case MatchType.tournament:  return 'Tournoi';
    }
  }

  String get icon {
    switch (this) {
      case MatchType.competition: return '⚔️';
      case MatchType.soloChrono:  return '⏱';
      case MatchType.tournament:  return '🏆';
    }
  }

  /// Nombre minimum de joueurs pour ce type
  int get minPlayers {
    switch (this) {
      case MatchType.competition: return 2;
      case MatchType.soloChrono:  return 1;
      case MatchType.tournament:  return 4;
    }
  }

  /// Nombre maximum de joueurs pour ce type
  int get maxPlayers {
    switch (this) {
      case MatchType.competition: return 6;
      case MatchType.soloChrono:  return 1;
      case MatchType.tournament:  return 16;
    }
  }

  /// Ce type de match sauvegarde-t-il un score au top 10 ?
  bool get savesToLeaderboard {
    return this == MatchType.soloChrono;
  }

  /// Ce type de match permet-il le switch entre joueurs ?
  bool get supportsPlayerSwitch {
    return this == MatchType.competition;
  }

  /// Tailles de bracket autorisées pour tournoi
  List<int> get allowedSizes {
    switch (this) {
      case MatchType.competition: return [2, 3, 4, 5, 6];
      case MatchType.soloChrono:  return [1];
      case MatchType.tournament:  return [4, 8, 16];
    }
  }

  /// Parse depuis une clé string
  static MatchType? fromKey(String key) {
    for (final t in MatchType.values) {
      if (t.key == key) return t;
    }
    return null;
  }
}