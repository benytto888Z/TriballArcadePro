// leaderboard_manager.cpp
#include "leaderboard_manager.h"

LeaderboardManager::LeaderboardManager() {}

void LeaderboardManager::begin() {
  if (DEBUG_SERIAL) {
    Serial.println("🏆 LeaderboardManager initialized");
    Serial.println("   Modes: classic, hardcore, champion, combo");
    Serial.printf("   Max entries per mode: %d\n", LEADERBOARD_MAX_ENTRIES);
  }
}

// ============================================
// PUBLIC : SUBMIT ENTRY
// ============================================
bool LeaderboardManager::submitEntry(const String& mode, const LeaderboardEntry& entry) {
  if (!_isValidMode(mode)) {
    if (DEBUG_SERIAL) Serial.printf("❌ Invalid mode: %s\n", mode.c_str());
    return false;
  }

  if (!entry.isValid()) {
    if (DEBUG_SERIAL) Serial.println("❌ Invalid entry");
    return false;
  }

  // Charge les entrées existantes
  LeaderboardEntry entries[LEADERBOARD_MAX_ENTRIES];
  int count = _loadAll(mode, entries);

  // Ajoute la nouvelle si de la place
  bool added = false;
  if (count < LEADERBOARD_MAX_ENTRIES) {
    entries[count] = entry;
    count++;
    added = true;
  } else {
    // Sinon, vérifie si elle est meilleure que la pire
    _sortEntries(entries, count);
    if (entry.timeMs < entries[LEADERBOARD_MAX_ENTRIES - 1].timeMs) {
      entries[LEADERBOARD_MAX_ENTRIES - 1] = entry;
      added = true;
    }
  }

  if (added) {
    _sortEntries(entries, count);
    _saveAll(mode, entries, count);

    if (DEBUG_SERIAL) {
      Serial.printf("🏆 Added to %s leaderboard: %s (%.2fs, %d balls)\n",
                    mode.c_str(),
                    entry.player,
                    entry.timeMs / 1000.0,
                    entry.balls);
    }
  }

  return added;
}

// ============================================
// PUBLIC : GET ENTRIES
// ============================================
int LeaderboardManager::getEntries(const String& mode, LeaderboardEntry outEntries[LEADERBOARD_MAX_ENTRIES]) {
  if (!_isValidMode(mode)) return 0;
  return _loadAll(mode, outEntries);
}

// ============================================
// PUBLIC : GET JSON
// ============================================
String LeaderboardManager::getLeaderboardJson(const String& mode) {
  StaticJsonDocument<2048> doc;
  doc["type"] = "leaderboard_data";
  doc["mode"] = mode;

  JsonArray entries = doc.createNestedArray("entries");

  if (!_isValidMode(mode)) {
    String output;
    serializeJson(doc, output);
    return output;
  }

  LeaderboardEntry rawEntries[LEADERBOARD_MAX_ENTRIES];
  int count = _loadAll(mode, rawEntries);

  for (int i = 0; i < count; i++) {
    JsonObject e = entries.createNestedObject();
    e["rank"] = i + 1;
    e["player"] = rawEntries[i].player;
    e["time_ms"] = rawEntries[i].timeMs;
    e["balls"] = rawEntries[i].balls;
    e["date"] = rawEntries[i].date;
  }

  doc["count"] = count;

  String output;
  serializeJson(doc, output);
  return output;
}

// ============================================
// PUBLIC : CLEAR MODE
// ============================================
bool LeaderboardManager::clearMode(const String& mode) {
  if (!_isValidMode(mode)) return false;

  _prefs.begin(_getNamespace(mode), false);
  _prefs.clear();
  _prefs.end();

  if (DEBUG_SERIAL) {
    Serial.printf("🗑 Cleared %s leaderboard\n", mode.c_str());
  }
  return true;
}

// ============================================
// PUBLIC : CLEAR ALL
// ============================================
void LeaderboardManager::clearAll() {
  clearMode(GAME_MODE_CLASSIC);
  clearMode(GAME_MODE_HARDCORE);
  clearMode(GAME_MODE_CHAMPION);
  clearMode(GAME_MODE_COMBO);
  if (DEBUG_SERIAL) Serial.println("🗑 Cleared ALL leaderboards");
}

// ============================================
// PUBLIC : WOULD QUALIFY
// ============================================
bool LeaderboardManager::wouldQualify(const String& mode, uint32_t timeMs) {
  if (!_isValidMode(mode)) return false;

  LeaderboardEntry entries[LEADERBOARD_MAX_ENTRIES];
  int count = _loadAll(mode, entries);

  if (count < LEADERBOARD_MAX_ENTRIES) return true;

  _sortEntries(entries, count);
  return timeMs < entries[LEADERBOARD_MAX_ENTRIES - 1].timeMs;
}

// ============================================
// PUBLIC : GET STATS
// ============================================
void LeaderboardManager::getStats(const String& mode, int& totalEntries, uint32_t& bestTimeMs, uint16_t& avgBalls) {
  totalEntries = 0;
  bestTimeMs = 0;
  avgBalls = 0;

  if (!_isValidMode(mode)) return;

  LeaderboardEntry entries[LEADERBOARD_MAX_ENTRIES];
  int count = _loadAll(mode, entries);
  totalEntries = count;

  if (count == 0) return;

  _sortEntries(entries, count);
  bestTimeMs = entries[0].timeMs;

  uint32_t totalBalls = 0;
  for (int i = 0; i < count; i++) {
    totalBalls += entries[i].balls;
  }
  avgBalls = totalBalls / count;
}

// ============================================
// PRIVATE : NAMESPACE
// ============================================
const char* LeaderboardManager::_getNamespace(const String& mode) {
  if (mode == GAME_MODE_CLASSIC)  return PREF_NS_CLASSIC;
  if (mode == GAME_MODE_HARDCORE) return PREF_NS_HARDCORE;
  if (mode == GAME_MODE_CHAMPION) return PREF_NS_CHAMPION;
  if (mode == GAME_MODE_COMBO)    return PREF_NS_COMBO;
  return "";
}

// ============================================
// PRIVATE : VALID MODE
// ============================================
bool LeaderboardManager::_isValidMode(const String& mode) {
  return mode == GAME_MODE_CLASSIC ||
         mode == GAME_MODE_HARDCORE ||
         mode == GAME_MODE_CHAMPION ||
         mode == GAME_MODE_COMBO;
}

// ============================================
// PRIVATE : ENTRY → STRING (JSON compact)
// ============================================
String LeaderboardManager::_entryToString(const LeaderboardEntry& e) {
  StaticJsonDocument<256> doc;
  doc["p"] = e.player;
  doc["t"] = e.timeMs;
  doc["b"] = e.balls;
  doc["d"] = e.date;

  String output;
  serializeJson(doc, output);
  return output;
}

// ============================================
// PRIVATE : STRING → ENTRY
// ============================================
bool LeaderboardManager::_stringToEntry(const String& s, LeaderboardEntry& outEntry) {
  StaticJsonDocument<256> doc;
  DeserializationError err = deserializeJson(doc, s);
  if (err) return false;

  const char* p = doc["p"] | "";
  strncpy(outEntry.player, p, LEADERBOARD_NAME_MAXLEN);
  outEntry.player[LEADERBOARD_NAME_MAXLEN] = '\0';

  outEntry.timeMs = doc["t"] | 0;
  outEntry.balls  = doc["b"] | 0;

  const char* d = doc["d"] | "";
  strncpy(outEntry.date, d, 23);
  outEntry.date[23] = '\0';

  return outEntry.isValid();
}

// ============================================
// PRIVATE : LOAD ALL
// ============================================
int LeaderboardManager::_loadAll(const String& mode, LeaderboardEntry entries[LEADERBOARD_MAX_ENTRIES]) {
  const char* ns = _getNamespace(mode);
  if (strlen(ns) == 0) return 0;

  _prefs.begin(ns, true); // read-only

  int count = 0;
  for (int i = 0; i < LEADERBOARD_MAX_ENTRIES; i++) {
    char key[8];
    snprintf(key, sizeof(key), "e%d", i);

    String raw = _prefs.getString(key, "");
    if (raw.length() == 0) continue;

    if (_stringToEntry(raw, entries[count])) {
      count++;
    }
  }

  _prefs.end();
  return count;
}

// ============================================
// PRIVATE : SAVE ALL
// ============================================
void LeaderboardManager::_saveAll(const String& mode, LeaderboardEntry entries[LEADERBOARD_MAX_ENTRIES], int count) {
  const char* ns = _getNamespace(mode);
  if (strlen(ns) == 0) return;

  _prefs.begin(ns, false);
  _prefs.clear();

  int toSave = min(count, LEADERBOARD_MAX_ENTRIES);
  for (int i = 0; i < toSave; i++) {
    char key[8];
    snprintf(key, sizeof(key), "e%d", i);
    _prefs.putString(key, _entryToString(entries[i]));
  }

  _prefs.end();
}

// ============================================
// PRIVATE : SORT (insertion sort simple, count ≤ 10)
// ============================================
void LeaderboardManager::_sortEntries(LeaderboardEntry entries[], int count) {
  for (int i = 1; i < count; i++) {
    LeaderboardEntry key = entries[i];
    int j = i - 1;
    while (j >= 0 && entries[j].timeMs > key.timeMs) {
      entries[j + 1] = entries[j];
      j--;
    }
    entries[j + 1] = key;
  }
}