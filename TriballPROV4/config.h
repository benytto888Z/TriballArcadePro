// config.h
#ifndef CONFIG_H
#define CONFIG_H

// ============================================
// WiFi Access Point (inchangé)
// ============================================
#define WIFI_SSID     "amz_triball"
#define WIFI_PASSWORD "12345678"
#define WIFI_CHANNEL  1
#define MAX_CLIENTS   6              // ✅ Augmenté : Config + Game + spectateurs

// ============================================
// WebSocket Server (inchangé)
// ============================================
#define WS_PORT 81

// ============================================
// IR Sensors (inchangé)
// ============================================
#define IR_SENSOR_COUNT 9
#define IR_ACTIVE_LOW  true

const uint8_t IR_PINS[IR_SENSOR_COUNT] = {
  32, 33, 25, 26, 27, 14, 23, 4, 15
};

// ============================================
// LEDs (inchangé)
// ============================================
#define LED_PIN        13
#define LED_COUNT      27
#define LED_BRIGHTNESS 150

// ============================================
// Timing (inchangé)
// ============================================
#define SCAN_INTERVAL      5
#define DETECTION_COOLDOWN 1500
#define STATUS_INTERVAL    5000
#define LED_FLASH_DURATION 1200
#define DEBOUNCE_MS        30

// ============================================
// Holes (inchangé)
// ============================================
#define HOLE_LEFT_TOP    "LEFT_TOP"
#define HOLE_CENTER_TOP  "CENTER_TOP"
#define HOLE_RIGHT_TOP   "RIGHT_TOP"
#define HOLE_LEFT_MID    "LEFT_MID"
#define HOLE_CENTER_MID  "CENTER_MID"
#define HOLE_RIGHT_MID   "RIGHT_MID"
#define HOLE_LEFT_LOW    "LEFT_LOW"
#define HOLE_CENTER_LOW  "CENTER_LOW"
#define HOLE_RIGHT_LOW   "RIGHT_LOW"

#define VAL_LEFT_TOP     10
#define VAL_CENTER_TOP  -10
#define VAL_RIGHT_TOP    5
#define VAL_LEFT_MID    -5
#define VAL_CENTER_MID   30
#define VAL_RIGHT_MID   -5
#define VAL_LEFT_LOW     5
#define VAL_CENTER_LOW   0
#define VAL_RIGHT_LOW    0

// ============================================
// Leaderboard (inchangé v3.0)
// ============================================
#define LEADERBOARD_MAX_ENTRIES  10
#define LEADERBOARD_NAME_MAXLEN  8

#define GAME_MODE_CLASSIC   "classic"
#define GAME_MODE_HARDCORE  "hardcore"
#define GAME_MODE_CHAMPION  "champion"
#define GAME_MODE_COMBO     "combo"

#define PREF_NS_CLASSIC   "lb_classic"
#define PREF_NS_HARDCORE  "lb_hardcore"
#define PREF_NS_CHAMPION  "lb_champion"
#define PREF_NS_COMBO     "lb_combo"

// ============================================
// ✅ NEW v4.0 : CONFIG RELAY SYSTEM
// ============================================

/// Rôles possibles pour un client WebSocket
#define CLIENT_ROLE_UNKNOWN    "unknown"
#define CLIENT_ROLE_CONFIG     "config_area"
#define CLIENT_ROLE_GAME       "game_area"
#define CLIENT_ROLE_SPECTATOR  "spectator"
#define CLIENT_ROLE_FAMILY     "family"        // App originale (backward compat)

/// Taille max du buffer pour stocker la dernière config JSON en RAM
#define CONFIG_BUFFER_MAX_SIZE 2048

/// TTL de la dernière config en RAM (millisecondes)
/// Après ce délai sans utilisation, la config est purgée
#define CONFIG_CACHE_TTL_MS 300000  // 5 minutes

/// Nombre max de clients par rôle
#define MAX_CONFIG_CLIENTS 2
#define MAX_GAME_CLIENTS 2

// ============================================
// Firmware info
// ============================================
#define FIRMWARE_VERSION "TRIBALL_v4.0_RELAY"    // ✅ v4.0
#define DEBUG_SERIAL true

#endif