// lib/core/localization/app_translations.dart

import 'package:get/get.dart';
import 'translations/fr_FR.dart';
import 'translations/en_US.dart';
import 'translations/es_ES.dart';
import 'translations/de_DE.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'fr_FR': frFR,
    'en_US': enUS,
    'es_ES': esES,
    'de_DE': deDE,
  };
}

// ==========================================
// EXTENSION POUR INTERPOLATION DE VARIABLES
// ==========================================
// Permet d'utiliser 'player_turn'.trParams({'name': 'Léo'})
// pour remplacer {name} dans la traduction.
// GetX a déjà cette fonctionnalité native via trParams !
//
// Exemple d'utilisation :
// 'player_turn'.trParams({'name': 'Léo'})
//   → FR: "Au tour de Léo"
//   → EN: "Léo's Turn"
//
// 'points_added'.trParams({'value': '30'})
//   → FR: "+30 points"
//   → DE: "+30 Punkte"
// ==========================================

extension TrParamsX on String {
  /// Helper court pour les paramètres
  String trArgs(Map<String, String> args) {
    return trParams(args);
  }
}