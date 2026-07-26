// lib/data/models/score_modifier_model.dart

import 'combo_model.dart';

class ScoreModifierResult {
  final int baseValue;
  final int finalValue;
  final double multiplier;
  final List<ScoreModifier> modifiers;
  final ComboModel? combo;
  final List<String> messages;

  ScoreModifierResult({
    required this.baseValue,
    required this.finalValue,
    this.multiplier = 1.0,
    this.modifiers = const [],
    this.combo,
    this.messages = const [],
  });

  bool get hasCombo => combo != null && combo!.isActive;
  bool get hasMultiplier => multiplier != 1.0;
  bool get isAmplified => finalValue.abs() > baseValue.abs();
}

class ScoreModifier {
  final String name;
  final String translationKey;
  final double multiplier;
  final int flatBonus;

  const ScoreModifier({
    required this.name,
    required this.translationKey,
    this.multiplier = 1.0,
    this.flatBonus = 0,
  });

  // Modifiers prédéfinis
  static const ScoreModifier hardcorePenalty = ScoreModifier(
    name: 'hardcore_penalty',
    translationKey: 'hardcore_penalty',
    flatBonus: -20,
  );

  static const ScoreModifier comboDouble = ScoreModifier(
    name: 'combo_double',
    translationKey: 'combo_double',
    multiplier: 2.0,   // ✅ ×2
  );

  static const ScoreModifier comboTriple = ScoreModifier(
    name: 'combo_triple',
    translationKey: 'combo_triple',
    multiplier: 3.0,   // ✅ ×3
  );

  static const ScoreModifier perfectStreak = ScoreModifier(
    name: 'perfect_streak',
    translationKey: 'combo_streak',
    // Ne modifie pas les points : récompense = nouveau tour uniquement.
    multiplier: 1.0,
  );

  static const ScoreModifier x2Multiplier = ScoreModifier(
    name: 'x2',
    translationKey: 'score_doubled',
    multiplier: 2.0,
  );

  static const ScoreModifier x0Reset = ScoreModifier(
    name: 'x0',
    translationKey: 'score_reset_to_zero',
    multiplier: 0.0,
  );
}