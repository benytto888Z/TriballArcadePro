// lib/data/models/guide_section_model.dart

import 'package:flutter/material.dart';

enum GuideCategory {
  basics,        // Bases du jeu
  modes,         // Modes de jeu
  scoring,       // Système de points
  combos,        // Combos & bonus
  controls,      // Contrôles
  tips,          // Astuces
  platform,      // Plateforme physique
  faq,           // Questions fréquentes
}

extension GuideCategoryX on GuideCategory {
  String get translationKey {
    switch (this) {
      case GuideCategory.basics:    return 'guide_cat_basics';
      case GuideCategory.modes:     return 'guide_cat_modes';
      case GuideCategory.scoring:   return 'guide_cat_scoring';
      case GuideCategory.combos:    return 'guide_cat_combos';
      case GuideCategory.controls:  return 'guide_cat_controls';
      case GuideCategory.tips:      return 'guide_cat_tips';
      case GuideCategory.platform:  return 'guide_cat_platform';
      case GuideCategory.faq:       return 'guide_cat_faq';
    }
  }

  IconData get icon {
    switch (this) {
      case GuideCategory.basics:    return Icons.school;
      case GuideCategory.modes:     return Icons.videogame_asset;
      case GuideCategory.scoring:   return Icons.calculate;
      case GuideCategory.combos:    return Icons.bolt;
      case GuideCategory.controls:  return Icons.touch_app;
      case GuideCategory.tips:      return Icons.lightbulb;
      case GuideCategory.platform:  return Icons.devices;
      case GuideCategory.faq:       return Icons.help_outline;
    }
  }

  String get emoji {
    switch (this) {
      case GuideCategory.basics:    return '🎯';
      case GuideCategory.modes:     return '🎮';
      case GuideCategory.scoring:   return '🧮';
      case GuideCategory.combos:    return '⚡';
      case GuideCategory.controls:  return '🎛';
      case GuideCategory.tips:      return '💡';
      case GuideCategory.platform:  return '🔌';
      case GuideCategory.faq:       return '❓';
    }
  }
}

class GuideItem {
  final String titleKey;
  final String descriptionKey;
  final IconData? icon;
  final Color? accentColor;
  final List<String>? bulletPointKeys;
  final Widget? customWidget;

  const GuideItem({
    required this.titleKey,
    required this.descriptionKey,
    this.icon,
    this.accentColor,
    this.bulletPointKeys,
    this.customWidget,
  });
}

class GuideSection {
  final GuideCategory category;
  final List<GuideItem> items;

  const GuideSection({
    required this.category,
    required this.items,
  });
}