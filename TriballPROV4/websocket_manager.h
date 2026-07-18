// websocket_manager.h
#ifndef WEBSOCKET_MANAGER_H
#define WEBSOCKET_MANAGER_H

#include <Arduino.h>
#include <WebSocketsServer.h>
#include <ArduinoJson.h>
#include "config.h"
#include "config_relay_manager.h"

// Existing callbacks
typedef void (*VoidCmdHandler)();
typedef void (*LedCmdHandler)(int holeIndex, int r, int g, int b);
typedef void (*ConfigCmdHandler)(JsonDocument& doc);

// Leaderboard callbacks (v3.0)
typedef void (*LeaderboardSubmitHandler)(const String& mode, const String& player,
                                          uint32_t timeMs, uint16_t balls,
                                          const String& date,
                                          const String& avatarId);
typedef void (*LeaderboardGetHandler)(uint8_t clientNum, const String& mode);
typedef void (*LeaderboardClearHandler)(const String& mode);
typedef void (*LeaderboardClearAllHandler)();

class WebSocketManager {
public:
  WebSocketManager();

  void begin(ConfigRelayManager* relay);   // ✅ Prend le relay en paramètre
  void loop();

  // ============================================
  // OUTGOING
  // ============================================
  void sendReady(uint8_t clientNum);
  void sendDetection(const String& hole, int value,
                     const String& effect, uint8_t sensor);
  void sendStatus(bool gameActive);
  void broadcastEvent(const char* type);
  void sendRawTo(uint8_t clientNum, String& raw);

  uint8_t connectedClients();

  // ============================================
  // GAME COMMAND HANDLERS (existant)
  // ============================================
  void onStartGame(VoidCmdHandler h)  { _onStart  = h; }
  void onStopGame(VoidCmdHandler h)   { _onStop   = h; }
  void onResetGame(VoidCmdHandler h)  { _onReset  = h; }
  void onLed(LedCmdHandler h)         { _onLed    = h; }
  void onConfig(ConfigCmdHandler h)   { _onConfig = h; }

  // ============================================
  // LEADERBOARD HANDLERS (v3.0)
  // ============================================
  void onLeaderboardSubmit(LeaderboardSubmitHandler h) { _onLbSubmit   = h; }
  void onLeaderboardGet(LeaderboardGetHandler h)       { _onLbGet      = h; }
  void onLeaderboardClear(LeaderboardClearHandler h)   { _onLbClear    = h; }
  void onLeaderboardClearAll(LeaderboardClearAllHandler h) { _onLbClearAll = h; }

private:
  WebSocketsServer _ws;
  ConfigRelayManager* _relay = nullptr;   // ✅ NEW

  VoidCmdHandler   _onStart  = nullptr;
  VoidCmdHandler   _onStop   = nullptr;
  VoidCmdHandler   _onReset  = nullptr;
  LedCmdHandler    _onLed    = nullptr;
  ConfigCmdHandler _onConfig = nullptr;

  LeaderboardSubmitHandler   _onLbSubmit   = nullptr;
  LeaderboardGetHandler      _onLbGet      = nullptr;
  LeaderboardClearHandler    _onLbClear    = nullptr;
  LeaderboardClearAllHandler _onLbClearAll = nullptr;

  unsigned long _lastStatusTime = 0;

  void _handleEvent(uint8_t clientNum, WStype_t type,
                    uint8_t* payload, size_t length);
  void _handleText(uint8_t clientNum, uint8_t* payload, size_t length);
  void _sendPong(uint8_t clientNum);
  void _sendError(uint8_t clientNum, const char* message);
  void _sendAck(uint8_t clientNum, const char* type, bool success, const char* extra = nullptr);

  // ✅ NEW : Envoi générique via fonction globale
  static WebSocketManager* s_instance;
  static void _staticSendToClient(uint8_t clientNum, String& message);
  void _sendToClient(uint8_t clientNum, String& message);
};

#endif