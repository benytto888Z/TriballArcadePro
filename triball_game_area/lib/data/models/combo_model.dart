// lib/data/models/combo_model.dart

import 'score_event_model.dart';

enum ComboType {
  none,
  doubleCombo,      // 2 hits identiques de suite → ×2
  tripleCombo,      // 3 hits identiques de suite → ×3
  perfectStreak,    // 3 hits positifs consécutifs → ×3 + tour bonus
  precisionShot,    // Hit du +30 (annonce seulement)
}

extension ComboTypeX on ComboType {
  String get displayName {
    switch (this) {
      case ComboType.doubleCombo:   return 'DOUBLE';
      case ComboType.tripleCombo:   return 'TRIPLE';
      case ComboType.perfectStreak: return 'STREAK';
      case ComboType.precisionShot: return 'PRECISION';
      case ComboType.none:          return '';
    }
  }

  String get translationKey {
    switch (this) {
      case ComboType.doubleCombo:   return 'combo_double';
      case ComboType.tripleCombo:   return 'combo_triple';
      case ComboType.perfectStreak: return 'combo_streak';
      case ComboType.precisionShot: return 'combo_precision';
      case ComboType.none:          return '';
    }
  }

  String get emoji {
    switch (this) {
      case ComboType.doubleCombo:   return '⚡';
      case ComboType.tripleCombo:   return '🔥';
      case ComboType.perfectStreak: return '✨';
      case ComboType.precisionShot: return '🎯';
      case ComboType.none:          return '';
    }
  }

  /// Multiplicateur appliqué au score
  double get multiplier {
    switch (this) {
      case ComboType.doubleCombo:   return 2.0;   // ✅ Modifié : ×2
      case ComboType.tripleCombo:   return 3.0;   // ✅ Modifié : ×3
      case ComboType.perfectStreak: return 3.0;   // ✅ Modifié : ×3
      case ComboType.precisionShot: return 1.0;
      case ComboType.none:          return 1.0;
    }
  }

  /// Indique si ce combo donne un tour bonus (chrono reset)
  bool get grantsBonusTurn {
    return this == ComboType.perfectStreak;   // ✅ Seul perfectStreak
  }

  int get priority {
    switch (this) {
      case ComboType.tripleCombo:   return 80;
      case ComboType.perfectStreak: return 70;
      case ComboType.doubleCombo:   return 60;
      case ComboType.precisionShot: return 40;
      case ComboType.none:          return 0;
    }
  }
}

class ComboModel {
  final ComboType type;
  final int count;
  final List<ScoreEventModel> events;
  final DateTime timestamp;

  ComboModel({
    required this.type,
    required this.count,
    required this.events,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isActive => type != ComboType.none;
  bool get grantsBonusTurn => type.grantsBonusTurn;

  @override
  String toString() =>
      'Combo(${type.displayName} ×$count, mult=${type.multiplier})';
}