// config_relay_manager.cpp
#include "config_relay_manager.h"

// Pointeur global vers la fonction d'envoi (assigné par websocket_manager)
SendToClientFn g_sendToClient = nullptr;

ConfigRelayManager::ConfigRelayManager()
  : _lastConfigJson(""),
    _lastConfigTimestamp(0),
    _hasConfig(false),
    _lastCleanupTime(0)
{}

// ============================================
// BEGIN
// ============================================
void ConfigRelayManager::begin() {
  for (int i = 0; i <= MAX_CLIENTS; i++) {
    _clients[i] = ClientInfo();
  }

  if (DEBUG_SERIAL) {
    Serial.println("🔀 ConfigRelayManager initialized");
    Serial.printf("   Max clients: %d\n", MAX_CLIENTS);
    Serial.printf("   Buffer size: %d bytes\n", CONFIG_BUFFER_MAX_SIZE);
    Serial.printf("   Config TTL: %d s\n", CONFIG_CACHE_TTL_MS / 1000);
  }
}

// ============================================
// LOOP (cleanup périodique)
// ============================================
void ConfigRelayManager::loop() {
  unsigned long now = millis();

  // Cleanup toutes les 30 secondes
  if (now - _lastCleanupTime > 30000) {
    _lastCleanupTime = now;
    _checkConfigExpiry();
  }
}

void ConfigRelayManager::_checkConfigExpiry() {
  if (!_hasConfig) return;

  unsigned long age = millis() - _lastConfigTimestamp;
  if (age > CONFIG_CACHE_TTL_MS) {
    if (DEBUG_SERIAL) {
      Serial.printf("🧹 Config cache expired (age=%lums)\n", age);
    }
    clearLastConfig();
  }
}

// ============================================
// CLIENT MANAGEMENT
// ============================================
void ConfigRelayManager::registerClient(uint8_t clientNum, const String& role,
                                        const String& deviceName, const String& ip) {
  if (clientNum > MAX_CLIENTS) return;

  _clients[clientNum].clientNum   = clientNum;
  _clients[clientNum].role        = role;
  _clients[clientNum].deviceName  = deviceName;
  _clients[clientNum].ip          = ip;
  _clients[clientNum].connectedAt = millis();
  _clients[clientNum].isActive    = true;

  if (DEBUG_SERIAL) {
    Serial.printf("✅ Client #%u registered: role=%s, name=%s, ip=%s\n",
                  clientNum, role.c_str(), deviceName.c_str(), ip.c_str());
  }

  // ✅ Si un Game Area se connecte et qu'on a une config valide, la lui envoyer
  if (role == CLIENT_ROLE_GAME && hasValidConfig()) {
    if (DEBUG_SERIAL) {
      Serial.printf("📤 Sending cached config to new Game Area (#%u)\n", clientNum);
    }
    if (g_sendToClient != nullptr) {
      g_sendToClient(clientNum, _lastConfigJson);
    }
  }
}

void ConfigRelayManager::unregisterClient(uint8_t clientNum) {
  if (clientNum > MAX_CLIENTS) return;

  if (_clients[clientNum].isActive && DEBUG_SERIAL) {
    Serial.printf("❌ Client #%u unregistered (role=%s)\n",
                  clientNum, _clients[clientNum].role.c_str());
  }

  _clients[clientNum] = ClientInfo();
}

ClientInfo* ConfigRelayManager::findClient(uint8_t clientNum) {
  if (clientNum > MAX_CLIENTS) return nullptr;
  if (!_clients[clientNum].isActive) return nullptr;
  return &_clients[clientNum];
}

int ConfigRelayManager::countClientsByRole(const String& role) {
  int count = 0;
  for (int i = 0; i <= MAX_CLIENTS; i++) {
    if (_clients[i].isActive && _clients[i].role == role) {
      count++;
    }
  }
  return count;
}

int ConfigRelayManager::getClientsByRole(const String& role, uint8_t outClients[MAX_CLIENTS]) {
  int count = 0;
  for (int i = 0; i <= MAX_CLIENTS; i++) {
    if (_clients[i].isActive && _clients[i].role == role) {
      if (count < MAX_CLIENTS) {
        outClients[count++] = _clients[i].clientNum;
      }
    }
  }
  return count;
}

// ============================================
// RELAY GAME CONFIG (Config Area → Game Area)
// ============================================
int ConfigRelayManager::relayGameConfig(const String& configJson, uint8_t fromClientNum) {

  // 1. Stocker la config en RAM
  if (configJson.length() > CONFIG_BUFFER_MAX_SIZE) {
    if (DEBUG_SERIAL) {
      Serial.printf("❌ Config too large (%d > %d bytes)\n",
                    configJson.length(), CONFIG_BUFFER_MAX_SIZE);
    }
    return 0;
  }

  _lastConfigJson = configJson;
  _lastConfigTimestamp = millis();
  _hasConfig = true;

  if (DEBUG_SERIAL) {
    Serial.printf("💾 Config stored (%d bytes) from client #%u\n",
                  configJson.length(), fromClientNum);
  }

  // 2. Broadcast aux Game Area
  int sent = broadcastToRole(CLIENT_ROLE_GAME, _lastConfigJson);

  if (DEBUG_SERIAL) {
    Serial.printf("📡 Config relayed to %d Game Area(s)\n", sent);
  }

  return sent;
}

// ============================================
// RELAY STOP GAME
// ============================================
int ConfigRelayManager::relayStopGame(uint8_t fromClientNum) {
  // Construit le message stop_game
  StaticJsonDocument<128> doc;
  doc["type"] = "stop_game";
  doc["from"] = fromClientNum;
  doc["ts"] = millis();

  String msg;
  serializeJson(doc, msg);

  int sent = broadcastToRole(CLIENT_ROLE_GAME, msg);

  if (DEBUG_SERIAL) {
    Serial.printf("🛑 Stop game relayed to %d Game Area(s)\n", sent);
  }

  return sent;
}

// ============================================
// RELAY GAME STATUS (Game Area → Config Area, optionnel)
// ============================================
int ConfigRelayManager::relayGameStatus(const String& statusJson, uint8_t fromClientNum) {
  int sent = broadcastToRole(CLIENT_ROLE_CONFIG, statusJson);

  if (DEBUG_SERIAL && sent > 0) {
    Serial.printf("📊 Game status relayed to %d Config Area(s)\n", sent);
  }

  return sent;
}

// ============================================
// GET/CLEAR LAST CONFIG
// ============================================
String ConfigRelayManager::getLastConfig() {
  return _hasConfig ? _lastConfigJson : "";
}

bool ConfigRelayManager::hasValidConfig() {
  if (!_hasConfig) return false;
  unsigned long age = millis() - _lastConfigTimestamp;
  return age <= CONFIG_CACHE_TTL_MS;
}

void ConfigRelayManager::clearLastConfig() {
  _lastConfigJson = "";
  _lastConfigTimestamp = 0;
  _hasConfig = false;
  if (DEBUG_SERIAL) {
    Serial.println("🧹 Config cache cleared");
  }
}

// ============================================
// BROADCAST TO ROLE
// ============================================
int ConfigRelayManager::broadcastToRole(const String& role, const String& message) {
  if (g_sendToClient == nullptr) {
    if (DEBUG_SERIAL) {
      Serial.println("❌ g_sendToClient not assigned");
    }
    return 0;
  }

  int sent = 0;
  uint8_t clients[MAX_CLIENTS];
  int count = getClientsByRole(role, clients);

  // Copie du message pour éviter const issue
  String msgCopy = message;

  for (int i = 0; i < count; i++) {
    g_sendToClient(clients[i], msgCopy);
    sent++;
  }

  return sent;
}

// ============================================
// CLIENTS INFO JSON
// ============================================
String ConfigRelayManager::getClientsInfoJson() {
  StaticJsonDocument<1024> doc;
  doc["type"] = "clients_info";

  JsonArray arr = doc.createNestedArray("clients");

  for (int i = 0; i <= MAX_CLIENTS; i++) {
    if (!_clients[i].isActive) continue;

    JsonObject c = arr.createNestedObject();
    c["clientNum"]   = _clients[i].clientNum;
    c["role"]        = _clients[i].role;
    c["deviceName"]  = _clients[i].deviceName;
    c["ip"]          = _clients[i].ip;
    c["uptime"]      = (millis() - _clients[i].connectedAt) / 1000;
  }

  doc["hasConfig"] = _hasConfig;
  doc["configAge"] = _hasConfig ? (millis() - _lastConfigTimestamp) / 1000 : 0;

  String output;
  serializeJson(doc, output);
  return output;
}