// lib/data/models/game_state_model.dart

// ============================================================
// GAME PHASES (inchangé)
// ============================================================
enum GamePhase {
  idle,
  setup,
  countdown,
  playing,
  turnTransition,
  paused,
  victory,
  gameOver,
}

extension GamePhaseX on GamePhase {
  String get name {
    switch (this) {
      case GamePhase.idle:            return 'idle';
      case GamePhase.setup:           return 'setup';
      case GamePhase.countdown:       return 'countdown';
      case GamePhase.playing:         return 'playing';
      case GamePhase.turnTransition:  return 'turn_transition';
      case GamePhase.paused:          return 'paused';
      case GamePhase.victory:         return 'victory';
      case GamePhase.gameOver:        return 'game_over';
    }
  }

  bool get isActive => this == GamePhase.playing;
  bool get isEnded =>
      this == GamePhase.victory || this == GamePhase.gameOver;
}

// ============================================================
// ✅ GAME MODES — Réduit à 4 valeurs seulement
// (Solo Chrono et Tournament sont maintenant des MatchType)
// ============================================================
enum GameMode {
  classic,     // 100 points exacts
  hardcore,    // x0 = -20 points
  champion,    // 200 points exacts
  combo,       // Multiplicateurs actifs
}

extension GameModeExtension on GameMode {
  /// Clé pour serialization
  String get key {
    switch (this) {
      case GameMode.classic:   return 'classic';
      case GameMode.hardcore:  return 'hardcore';
      case GameMode.champion:  return 'champion';
      case GameMode.combo:     return 'combo';
    }
  }

  /// Score cible pour ce mode
  int get targetScore {
    switch (this) {
      case GameMode.champion:  return 200;
      case GameMode.classic:   return 100;
      case GameMode.hardcore:  return 100;
      case GameMode.combo:     return 100;
    }
  }

  String get displayName {
    switch (this) {
      case GameMode.classic:   return 'Classic';
      case GameMode.hardcore:  return 'Hardcore';
      case GameMode.champion:  return 'Champion';
      case GameMode.combo:     return 'Combo';
    }
  }

  String get translationKey {
    switch (this) {
      case GameMode.classic:   return 'mode_classic';
      case GameMode.hardcore:  return 'mode_hardcore';
      case GameMode.champion:  return 'mode_champion';
      case GameMode.combo:     return 'mode_combo';
    }
  }

  String get descriptionKey {
    switch (this) {
      case GameMode.classic:   return 'mode_classic_desc';
      case GameMode.hardcore:  return 'mode_hardcore_desc';
      case GameMode.champion:  return 'mode_champion_desc';
      case GameMode.combo:     return 'mode_combo_desc';
    }
  }

  String get icon {
    switch (this) {
      case GameMode.classic:   return '🎯';
      case GameMode.hardcore:  return '🔥';
      case GameMode.champion:  return '👑';
      case GameMode.combo:     return '⚡';
    }
  }

  /// Ce mode active-t-il les multiplicateurs de combos ?
  bool get applyComboMultipliers {
    return this == GameMode.combo || this == GameMode.champion;
  }

  /// Alias métier : Combo et Champion partagent toutes les mécaniques combo.
  bool get hasComboFeatures => applyComboMultipliers;

  /// Ce mode applique-t-il la pénalité hardcore (x0 = -20) ?
  bool get applyHardcorePenalty {
    return this == GameMode.hardcore;
  }

  /// Parse depuis une clé string
  static GameMode? fromKey(String key) {
    for (final m in GameMode.values) {
      if (m.key == key) return m;
    }
    return null;
  }


}