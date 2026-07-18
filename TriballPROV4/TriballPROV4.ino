// triball.ino — TRIBALL ARCADE PRO v4.0
// ESP32 + IR + WS2812 + WebSocket + Leaderboard + Config Relay
//
// v4.0 : Ajout du système de relay pour Config Area ↔ Game Area
//        (mode Game Center avec 2 apps distinctes)

#include <WiFi.h>
#include "config.h"
#include "sensor_manager.h"
#include "led_manager.h"
#include "websocket_manager.h"
#include "leaderboard_manager.h"
#include "config_relay_manager.h"      // ✅ NEW v4.0

// ============================================
// GLOBAL OBJECTS
// ============================================
SensorManager      sensors;
LedManager         leds;
WebSocketManager   ws;
LeaderboardManager leaderboard;
ConfigRelayManager configRelay;         // ✅ NEW v4.0

// ============================================
// STATE
// ============================================
bool gameActive = false;
unsigned long lastScanTime = 0;
unsigned long lastStatusTime = 0;

// ============================================
// FORWARD DECLARATIONS
// ============================================
void setupWiFi();
void onStartGameCommand();
void onStopGameCommand();
void onResetGameCommand();
void onLedCommand(int holeIndex, int r, int g, int b);
void onConfigCommand(JsonDocument& doc);

void onLeaderboardSubmit(const String& mode, const String& player,
                          uint32_t timeMs, uint16_t balls, const String& date);
void onLeaderboardGet(uint8_t clientNum, const String& mode);
void onLeaderboardClear(const String& mode);
void onLeaderboardClearAll();

// ============================================
// SETUP
// ============================================
void setup() {
  Serial.begin(115200);
  delay(100);

  Serial.println("\n=========================================");
  Serial.println("   🎮 TRIBALL ARCADE PRO v4.0 (RELAY)");
  Serial.println("=========================================\n");

  setupWiFi();

  leds.begin();
  sensors.begin();
  leaderboard.begin();
  configRelay.begin();                    // ✅ NEW
  ws.begin(&configRelay);                 // ✅ Passe le relay au WS

  // Register game handlers (existant)
  ws.onStartGame(onStartGameCommand);
  ws.onStopGame(onStopGameCommand);
  ws.onResetGame(onResetGameCommand);
  ws.onLed(onLedCommand);
  ws.onConfig(onConfigCommand);

  // Register leaderboard handlers (v3.0)
  ws.onLeaderboardSubmit(onLeaderboardSubmit);
  ws.onLeaderboardGet(onLeaderboardGet);
  ws.onLeaderboardClear(onLeaderboardClear);
  ws.onLeaderboardClearAll(onLeaderboardClearAll);

  leds.showReady();

  Serial.println("\n✅ System ready!");
  Serial.println("📡 SSID: " WIFI_SSID);
  Serial.print("🌐 IP:   ");
  Serial.println(WiFi.softAPIP());
  Serial.print("🔌 WS:   ws://");
  Serial.print(WiFi.softAPIP());
  Serial.print(":");
  Serial.println(WS_PORT);
  Serial.println("🏆 Leaderboards: 4 modes");
  Serial.println("🔀 Config Relay: enabled");     // ✅ NEW
  Serial.println("👥 Max clients: " + String(MAX_CLIENTS));
  Serial.println("\nWaiting for clients...\n");
}

// ============================================
// LOOP
// ============================================
void loop() {
  ws.loop();
  leds.update();
  configRelay.loop();                     // ✅ NEW : cleanup config expirée

  unsigned long now = millis();

  // Scan IR sensors
  if (now - lastScanTime >= SCAN_INTERVAL) {
    lastScanTime = now;
    sensors.scan();
  }

  // Send detection if any
  if (sensors.hasNewDetection()) {
    String  hole    = sensors.getDetectedHole();
    int     value   = sensors.getDetectedValue();
    String  effect  = sensors.getDetectedEffect();
    uint8_t sensor  = sensors.getDetectedSensor();

    ws.sendDetection(hole, value, effect, sensor);
    leds.flashHole(hole, effect, value);
  }

  // Broadcast status
  if (now - lastStatusTime >= STATUS_INTERVAL) {
    lastStatusTime = now;
    ws.sendStatus(gameActive);
  }
}

// ============================================
// WiFi SOFT-AP
// ============================================
void setupWiFi() {
  WiFi.mode(WIFI_AP);
  WiFi.softAP(WIFI_SSID, WIFI_PASSWORD, WIFI_CHANNEL, 0, MAX_CLIENTS);
  delay(100);
  Serial.print("📡 SoftAP started — IP: ");
  Serial.println(WiFi.softAPIP());
}

// ============================================
// GAME COMMAND HANDLERS
// ============================================
void onStartGameCommand() {
  gameActive = true;
  sensors.enable();
  leds.showGameActive();
  ws.broadcastEvent("game_started");
  Serial.println("🎮 GAME STARTED");
}

void onStopGameCommand() {
  gameActive = false;
  sensors.disable();
  leds.showGameStopped();
  ws.broadcastEvent("game_stopped");
  Serial.println("🛑 GAME STOPPED");
}

void onResetGameCommand() {
  gameActive = false;
  sensors.disable();
  sensors.reset();
  leds.showGameReset();
  ws.broadcastEvent("game_reset");
  Serial.println("🔄 GAME RESET");
}

void onLedCommand(int holeIndex, int r, int g, int b) {
  if (holeIndex < 0 || holeIndex >= 9) return;
  leds.setHole(holeIndex, r, g, b);
}

void onConfigCommand(JsonDocument& doc) {
  Serial.println("⚙️ Config received");
}

// ============================================
// LEADERBOARD HANDLERS
// ============================================
// triball.ino

void onLeaderboardSubmit(const String& mode, const String& player,
                          uint32_t timeMs, uint16_t balls, const String& date,
                          const String& avatarId) {
  Serial.println("════════════════════════════════════════");
  Serial.println("📥 LEADERBOARD SUBMIT RECEIVED");
  Serial.printf("   mode: '%s'\n", mode.c_str());
  Serial.printf("   player: '%s'\n", player.c_str());
  Serial.printf("   timeMs: %u\n", timeMs);
  Serial.printf("   balls: %u\n", balls);
  Serial.printf("   date: '%s'\n", date.c_str());
  Serial.printf("   mode valid: %s\n", 
    (mode == GAME_MODE_CLASSIC || mode == GAME_MODE_HARDCORE ||
     mode == GAME_MODE_CHAMPION || mode == GAME_MODE_COMBO) ? "YES" : "NO");
  Serial.println("════════════════════════════════════════");

  LeaderboardEntry entry;
  strncpy(entry.player, player.c_str(), LEADERBOARD_NAME_MAXLEN);
  entry.player[LEADERBOARD_NAME_MAXLEN] = '\0';
  entry.timeMs = timeMs;
  entry.balls  = balls;
  strncpy(entry.date, date.c_str(), 23);
  entry.date[23] = '\0';
  strncpy(entry.avatarId, avatarId.c_str(), 36);
  entry.avatarId[36] = '\0';

  Serial.printf("   entry.isValid(): %s\n", entry.isValid() ? "YES" : "NO");
  Serial.printf("   entry.player: '%s' (len=%d)\n", entry.player, strlen(entry.player));
  Serial.printf("   entry.timeMs: %u\n", entry.timeMs);

  bool added = leaderboard.submitEntry(mode, entry);

  Serial.printf("   RESULT: %s\n", added ? "✅ ADDED" : "❌ NOT ADDED");

  if (added) {
    String json = leaderboard.getLeaderboardJson(mode);
    Serial.printf("   Broadcasting leaderboard (%d bytes)\n", json.length());
    for (uint8_t i = 0; i < ws.connectedClients(); i++) {
      ws.sendRawTo(i, json);
    }
    Serial.println("📤 Updated leaderboard broadcasted to all clients");
  } else {
    Serial.println("   Score not good enough for top 10 OR invalid entry");
  }
  Serial.println("════════════════════════════════════════");
}

void onLeaderboardGet(uint8_t clientNum, const String& mode) {
  Serial.printf("📤 Leaderboard GET: mode='%s' → client #%u\n", mode.c_str(), clientNum);

  String json = leaderboard.getLeaderboardJson(mode);
  Serial.printf("   JSON length: %d bytes\n", json.length());
  Serial.printf("   JSON preview: %s\n", json.substring(0, min((int)json.length(), 200)).c_str());

  ws.sendRawTo(clientNum, json);
}

void onLeaderboardClear(const String& mode) {
  leaderboard.clearMode(mode);
  String json = leaderboard.getLeaderboardJson(mode);
  for (uint8_t i = 0; i < ws.connectedClients(); i++) {
    ws.sendRawTo(i, json);
  }
}

void onLeaderboardClearAll() {
  leaderboard.clearAll();
  const char* modes[] = {GAME_MODE_CLASSIC, GAME_MODE_HARDCORE,
                          GAME_MODE_CHAMPION, GAME_MODE_COMBO};
  for (int m = 0; m < 4; m++) {
    String json = leaderboard.getLeaderboardJson(modes[m]);
    for (uint8_t i = 0; i < ws.connectedClients(); i++) {
      ws.sendRawTo(i, json);
    }
  }
}