// websocket_manager.cpp
#include "websocket_manager.h"

WebSocketManager* WebSocketManager::s_instance = nullptr;

WebSocketManager::WebSocketManager() : _ws(WS_PORT) {
  s_instance = this;
}

void WebSocketManager::begin(ConfigRelayManager* relay) {
  _relay = relay;

  // ✅ Assigne la fonction d'envoi global pour le relay
  g_sendToClient = _staticSendToClient;

  _ws.begin();
  _ws.onEvent([](uint8_t clientNum, WStype_t type,
                 uint8_t* payload, size_t length) {
    if (s_instance) s_instance->_handleEvent(clientNum, type, payload, length);
  });

  if (DEBUG_SERIAL) {
    Serial.printf("🔌 WebSocket started on port %d\n", WS_PORT);
  }
}

void WebSocketManager::loop() {
  _ws.loop();
}

uint8_t WebSocketManager::connectedClients() {
  return _ws.connectedClients();
}

// ============================================
// STATIC SEND (pour le relay)
// ============================================
void WebSocketManager::_staticSendToClient(uint8_t clientNum, String& message) {
  if (s_instance) s_instance->_sendToClient(clientNum, message);
}

void WebSocketManager::_sendToClient(uint8_t clientNum, String& message) {
  _ws.sendTXT(clientNum, message);
  if (DEBUG_SERIAL) {
    Serial.printf("📤 To #%u: %s\n", clientNum,
                  message.substring(0, 80).c_str());
  }
}

// ============================================
// EVENT HANDLER
// ============================================
void WebSocketManager::_handleEvent(uint8_t clientNum, WStype_t type,
                                    uint8_t* payload, size_t length) {
  switch (type) {
    case WStype_DISCONNECTED:
      if (DEBUG_SERIAL) Serial.printf("🔴 Client #%u disconnected\n", clientNum);
      if (_relay) _relay->unregisterClient(clientNum);
      break;

    case WStype_CONNECTED: {
      IPAddress ip = _ws.remoteIP(clientNum);
      String ipStr = ip.toString();
      if (DEBUG_SERIAL) {
        Serial.printf("🟢 Client #%u connected from %s\n",
                      clientNum, ipStr.c_str());
      }
      // Register avec rôle unknown, le client se déclarera après
      if (_relay) {
        _relay->registerClient(clientNum, CLIENT_ROLE_UNKNOWN,
                               "", ipStr);
      }
      sendReady(clientNum);
      break;
    }

    case WStype_TEXT:
      _handleText(clientNum, payload, length);
      break;

    default:
      break;
  }
}

void WebSocketManager::_handleText(uint8_t clientNum,
                                   uint8_t* payload, size_t length) {
  String msg = String((char*)payload).substring(0, length);
  if (DEBUG_SERIAL) {
    Serial.printf("📩 From #%u: %s\n", clientNum,
                  msg.substring(0, 100).c_str());
  }

  StaticJsonDocument<CONFIG_BUFFER_MAX_SIZE> doc;
  DeserializationError err = deserializeJson(doc, msg);
  if (err) {
    _sendError(clientNum, "Invalid JSON");
    return;
  }

  const char* type = doc["type"];
  if (!type) {
    _sendError(clientNum, "Missing 'type'");
    return;
  }

  // ============================================
  // ✅ NEW : CLIENT_DECLARE (rôles clients)
  // ============================================
  if (strcmp(type, "client_declare") == 0) {
    if (_relay) {
      const char* role       = doc["role"]       | CLIENT_ROLE_UNKNOWN;
      const char* deviceName = doc["deviceName"] | "Unknown Device";
      IPAddress ip = _ws.remoteIP(clientNum);

      _relay->registerClient(clientNum, String(role),
                             String(deviceName), ip.toString());
      _sendAck(clientNum, "client_declare", true, role);
    }
    return;
  }

  // ============================================
  // ✅ NEW : START_GAME_CONFIG (relay Config → Game)
  // ============================================
  if (strcmp(type, "start_game_config") == 0) {
    if (_relay) {
      // On envoie toute la config brute (msg) aux Game Area
      int sent = _relay->relayGameConfig(msg, clientNum);
      _sendAck(clientNum, "start_game_config", sent > 0,
               sent > 0 ? "relayed" : "no_game_area");
    }
    return;
  }

  // ============================================
  // ✅ NEW : STOP_GAME (relay Config → Game)
  // ============================================
  if (strcmp(type, "stop_game_remote") == 0) {
    if (_relay) {
      int sent = _relay->relayStopGame(clientNum);
      _sendAck(clientNum, "stop_game_remote", sent > 0);
    }
    return;
  }

  // ============================================
  // ✅ NEW : GAME_STATUS_UPDATE (relay Game → Config)
  // ============================================
  if (strcmp(type, "game_status_update") == 0) {
    if (_relay) {
      _relay->relayGameStatus(msg, clientNum);
      _sendAck(clientNum, "game_status_update", true);
    }
    return;
  }

  // ============================================
  // ✅ NEW : GET_LAST_CONFIG (Game Area demande la dernière config)
  // ============================================
  if (strcmp(type, "get_last_config") == 0) {
    if (_relay && _relay->hasValidConfig()) {
      String lastConfig = _relay->getLastConfig();
      _sendToClient(clientNum, lastConfig);
    } else {
      _sendAck(clientNum, "get_last_config", false, "no_config");
    }
    return;
  }

  // ============================================
  // ✅ NEW : GET_CLIENTS_INFO (debug/monitoring)
  // ============================================
  if (strcmp(type, "get_clients_info") == 0) {
    if (_relay) {
      String info = _relay->getClientsInfoJson();
      _sendToClient(clientNum, info);
    }
    return;
  }

  // ============================================
  // GAME COMMANDS (existant)
  // ============================================
  if (strcmp(type, "ping") == 0) {
    _sendPong(clientNum);
    return;
  }

  if (strcmp(type, "start_game") == 0) {
    if (_onStart) _onStart();
    return;
  }

  if (strcmp(type, "stop_game") == 0) {
    if (_onStop) _onStop();
    return;
  }

  if (strcmp(type, "reset") == 0) {
    if (_onReset) _onReset();
    return;
  }

  if (strcmp(type, "led") == 0) {
    if (_onLed) {
      int hole = doc["hole"] | -1;
      int r = doc["r"] | 0;
      int g = doc["g"] | 0;
      int b = doc["b"] | 0;
      _onLed(hole, r, g, b);
    }
    return;
  }

  if (strcmp(type, "config") == 0) {
    if (_onConfig) _onConfig(doc);
    return;
  }

  // ============================================
  // LEADERBOARD COMMANDS (v3.0)
  // ============================================
if (strcmp(type, "leaderboard_submit") == 0) {
  if (_onLbSubmit) {
    const char* mode   = doc["mode"]   | "";
    const char* player = doc["player"] | "";
    uint32_t timeMs    = doc["time_ms"] | 0;      // ✅ "time_ms" pas "timeMs"
    uint16_t balls     = doc["balls"]   | 0;
    const char* date   = doc["date"]      | "";
    const char* avatar = doc["avatar_id"] | "";

    Serial.printf("🔧 Parsed: mode='%s' player='%s' time=%u balls=%u\n",
                  mode, player, timeMs, balls);

    _onLbSubmit(String(mode), String(player), timeMs, balls,
                String(date), String(avatar));
    _sendAck(clientNum, "leaderboard_submit", true);
  } else {
    Serial.println("❌ _onLbSubmit handler NOT SET");
  }
  return;
}

  if (strcmp(type, "leaderboard_get") == 0) {
    if (_onLbGet) {
      const char* mode = doc["mode"] | "";
      _onLbGet(clientNum, String(mode));
    }
    return;
  }

if (strcmp(type, "leaderboard_clear") == 0) {
  if (_onLbClear) {
    const char* mode = doc["mode"] | "";
    const char* code = doc["code"] | "";

    // ✅ Vérification du code de sécurité
    if (strcmp(code, "1234") != 0) {
      Serial.println("❌ Invalid security code for leaderboard clear");
      _sendAck(clientNum, "leaderboard_clear", false, "invalid_code");
      return;
    }

    _onLbClear(String(mode));
    _sendAck(clientNum, "leaderboard_clear", true, mode);
  }
  return;
}

  if (strcmp(type, "leaderboard_clear_all") == 0) {
    if (_onLbClearAll) {
      _onLbClearAll();
      _sendAck(clientNum, "leaderboard_clear_all", true);
    }
    return;
  }

  // ============================================
// ✅ NEW : REMOTE DISPLAY COMMANDS
// ============================================
if (strcmp(type, "show_leaderboard") == 0) {
  if (_relay) {
    int sent = _relay->relayGameConfig(msg, clientNum);
    _sendAck(clientNum, "show_leaderboard", sent > 0);
    if (DEBUG_SERIAL) Serial.printf("📺 Show leaderboard relayed to %d Game Area(s)\n", sent);
  }
  return;
}

if (strcmp(type, "change_filter") == 0) {
  if (_relay) {
    int sent = _relay->relayGameConfig(msg, clientNum);
    _sendAck(clientNum, "change_filter", sent > 0);
    if (DEBUG_SERIAL) Serial.printf("📺 Change filter relayed to %d Game Area(s)\n", sent);
  }
  return;
}
if (strcmp(type, "show_waiting") == 0) {
  if (_relay) {
    int sent = _relay->relayGameConfig(msg, clientNum);
    _sendAck(clientNum, "show_waiting", sent > 0);
    if (DEBUG_SERIAL) Serial.printf("📺 Show waiting relayed to %d Game Area(s)\n", sent);
  }
  return;
}

if (strcmp(type, "remote_pause") == 0) {
  if (_relay) {
    int sent = _relay->relayGameConfig(msg, clientNum);
    _sendAck(clientNum, "remote_pause", sent > 0);
    if (DEBUG_SERIAL) Serial.printf("⏸ Remote pause relayed to %d Game Area(s)\n", sent);
  }
  return;
}
if (strcmp(type, "remote_resume") == 0) {
  if (_relay) {
    int sent = _relay->relayGameConfig(msg, clientNum);
    _sendAck(clientNum, "remote_resume", sent > 0);
    if (DEBUG_SERIAL) Serial.printf("▶ Remote resume relayed to %d Game Area(s)\n", sent);
  }
  return;
}

if (strcmp(type, "player_avatar") == 0) {
  if (_relay) {
    int sent = _relay->relayGameConfig(msg, clientNum);
    _sendAck(clientNum, "player_avatar", sent > 0);
    if (DEBUG_SERIAL) Serial.printf("📸 Avatar relayed to %d Game Area(s)\n", sent);
  }
  return;
}
if (strcmp(type, "clear_avatars") == 0) {
  if (_relay) {
    int sent = _relay->relayGameConfig(msg, clientNum);
    _sendAck(clientNum, "clear_avatars", sent > 0);
    if (DEBUG_SERIAL) Serial.println("🗑 Clear avatars relayed");
  }
  return;
}

if (strcmp(type, "change_theme") == 0) {
  if (_relay) {
    int sent = _relay->relayGameConfig(msg, clientNum);
    _sendAck(clientNum, "change_theme", sent > 0);
    if (DEBUG_SERIAL) Serial.printf("🎨 Theme change relayed to %d Game Area(s)\n", sent);
  }
  return;
}
if (strcmp(type, "change_language") == 0) {
  if (_relay) {
    int sent = _relay->relayGameConfig(msg, clientNum);
    _sendAck(clientNum, "change_language", sent > 0);
    if (DEBUG_SERIAL) Serial.printf("🌍 Language change relayed to %d Game Area(s)\n", sent);
  }
  return;
}

  // Type réellement inconnu
  _sendError(clientNum, "Unknown message type");
}

// ============================================
// OUTGOING MESSAGES
// ============================================
void WebSocketManager::sendReady(uint8_t clientNum) {
  StaticJsonDocument<256> doc;
  doc["type"]     = "ready";
  doc["firmware"] = FIRMWARE_VERSION;
  doc["sensors"]  = IR_SENSOR_COUNT;
  doc["leds"]     = LED_COUNT;
  doc["leaderboard_enabled"] = true;
  doc["config_relay_enabled"] = true;    // ✅ NEW

  String out;
  serializeJson(doc, out);
  _ws.sendTXT(clientNum, out);
}

void WebSocketManager::sendDetection(const String& hole, int value,
                                     const String& effect, uint8_t sensor) {
  StaticJsonDocument<256> doc;
  doc["type"]     = "detection";
  doc["hole"]     = hole;
  doc["value"]    = value;
  doc["effect"]   = effect;
  doc["sensor"]   = sensor;
  doc["distance"] = 0;
  doc["ts"]       = (uint32_t)millis();

  String out;
  serializeJson(doc, out);
  _ws.broadcastTXT(out);
  if (DEBUG_SERIAL) Serial.println("📤 " + out);
}

void WebSocketManager::sendStatus(bool gameActive) {
  StaticJsonDocument<256> doc;
  doc["type"]        = "status";
  doc["game_active"] = gameActive;
  doc["uptime"]      = (uint32_t)(millis() / 1000);
  doc["clients"]     = _ws.connectedClients();
  doc["free_heap"]   = (uint32_t)ESP.getFreeHeap();

  String out;
  serializeJson(doc, out);
  _ws.broadcastTXT(out);
}

void WebSocketManager::broadcastEvent(const char* type) {
  StaticJsonDocument<128> doc;
  doc["type"] = type;
  doc["ts"]   = (uint32_t)millis();

  String out;
  serializeJson(doc, out);
  _ws.broadcastTXT(out);
}

void WebSocketManager::sendRawTo(uint8_t clientNum, String& raw) {
  _ws.sendTXT(clientNum, raw);
}

void WebSocketManager::_sendPong(uint8_t clientNum) {
  StaticJsonDocument<64> doc;
  doc["type"] = "pong";
  doc["ts"]   = (uint32_t)millis();

  String out;
  serializeJson(doc, out);
  _ws.sendTXT(clientNum, out);
}

void WebSocketManager::_sendError(uint8_t clientNum, const char* message) {
  StaticJsonDocument<128> doc;
  doc["type"]    = "error";
  doc["message"] = message;

  String out;
  serializeJson(doc, out);
  _ws.sendTXT(clientNum, out);
}

void WebSocketManager::_sendAck(uint8_t clientNum, const char* type,
                                bool success, const char* extra) {
  StaticJsonDocument<128> doc;
  doc["type"] = "ack";
  doc["for"]  = type;
  doc["success"] = success;
  if (extra != nullptr) {
    doc["extra"] = extra;
  }

  String out;
  serializeJson(doc, out);
  _ws.sendTXT(clientNum, out);
}