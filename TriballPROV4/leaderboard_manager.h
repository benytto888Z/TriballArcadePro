// leaderboard_manager.h
#ifndef LEADERBOARD_MANAGER_H
#define LEADERBOARD_MANAGER_H

#include <Arduino.h>
#include <Preferences.h>
#include <ArduinoJson.h>
#include "config.h"

// ============================================
// STRUCTURE ENTRÉE LEADERBOARD
// ============================================
struct LeaderboardEntry {
  char     player[LEADERBOARD_NAME_MAXLEN + 1];
  uint32_t timeMs;
  uint16_t balls;
  char     date[24];   // ISO 8601 : "2025-01-15T14:30:00Z"

  LeaderboardEntry() {
    player[0] = '\0';
    timeMs = 0;
    balls = 0;
    date[0] = '\0';
  }

  bool isValid() const {
    return timeMs > 0 && player[0] != '\0';
  }
};

// ============================================
// LEADERBOARD MANAGER
// ============================================
class LeaderboardManager {
public:
  LeaderboardManager();

  void begin();

  /// Ajoute une entrée pour un mode donné.
  /// Retourne true si elle est entrée dans le top 10.
  bool submitEntry(const String& mode, const LeaderboardEntry& entry);

  /// Récupère les entrées d'un mode (jusqu'à 10)
  int getEntries(const String& mode, LeaderboardEntry outEntries[LEADERBOARD_MAX_ENTRIES]);

  /// Convertit un leaderboard en JSON pour envoi WebSocket
  String getLeaderboardJson(const String& mode);

  /// Efface le leaderboard d'un mode
  bool clearMode(const String& mode);

  /// Efface tous les leaderboards
  void clearAll();

  /// Vérifie si un temps qualifierait pour le top 10
  bool wouldQualify(const String& mode, uint32_t timeMs);

  /// Statistiques d'un mode
  void getStats(const String& mode, int& totalEntries, uint32_t& bestTimeMs, uint16_t& avgBalls);

private:
  Preferences _prefs;

  /// Obtient le namespace Preferences pour un mode
  const char* _getNamespace(const String& mode);

  /// Valide qu'un mode est supporté
  bool _isValidMode(const String& mode);

  /// Encode une entrée en JSON string (pour stockage)
  String _entryToString(const LeaderboardEntry& e);

  /// Décode une entrée depuis JSON string
  bool _stringToEntry(const String& s, LeaderboardEntry& outEntry);

  /// Charge toutes les entrées d'un mode en RAM
  int _loadAll(const String& mode, LeaderboardEntry entries[LEADERBOARD_MAX_ENTRIES]);

  /// Sauvegarde toutes les entrées d'un mode
  void _saveAll(const String& mode, LeaderboardEntry entries[LEADERBOARD_MAX_ENTRIES], int count);

  /// Trie un tableau d'entrées par temps croissant
  void _sortEntries(LeaderboardEntry entries[], int count);
};

#endif