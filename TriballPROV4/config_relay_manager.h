// config_relay_manager.h
#ifndef CONFIG_RELAY_MANAGER_H
#define CONFIG_RELAY_MANAGER_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include "config.h"

/// Info d'un client connecté
struct ClientInfo {
  uint8_t     clientNum;
  String      role;              // config_area | game_area | spectator | family
  String      deviceName;        // Ex: "Tablette Léo", "TV Salle 1"
  String      ip;
  unsigned long connectedAt;
  bool        isActive;

  ClientInfo() : clientNum(0), role(CLIENT_ROLE_UNKNOWN), deviceName(""), ip(""), connectedAt(0), isActive(false) {}
};

/// Types de messages relay
enum RelayMessageType {
  RELAY_START_GAME_CONFIG,
  RELAY_STOP_GAME,
  RELAY_GAME_STATUS_UPDATE,
  RELAY_UNKNOWN
};

class ConfigRelayManager {
public:
  ConfigRelayManager();

  void begin();
  void loop();

  // ============================================
  // CLIENT MANAGEMENT
  // ============================================
  void registerClient(uint8_t clientNum, const String& role, const String& deviceName, const String& ip);
  void unregisterClient(uint8_t clientNum);
  ClientInfo* findClient(uint8_t clientNum);
  int countClientsByRole(const String& role);

  /// Retourne la liste des clientNum ayant un rôle donné
  int getClientsByRole(const String& role, uint8_t outClients[MAX_CLIENTS]);

  // ============================================
  // CONFIG RELAY
  // ============================================

  /// Stocke la config reçue de Config Area et la relay aux Game Area
  /// Retourne le nombre de Game Area qui recevront la config
  int relayGameConfig(const String& configJson, uint8_t fromClientNum);

  /// Envoie la commande stop_game aux Game Area
  int relayStopGame(uint8_t fromClientNum);

  /// Relay du statut du jeu vers les Config Area (pour affichage temps réel)
  int relayGameStatus(const String& statusJson, uint8_t fromClientNum);

  /// Récupère la dernière config stockée (pour restauration à la reconnexion)
  String getLastConfig();
  bool hasValidConfig();
  void clearLastConfig();

  // ============================================
  // BROADCAST HELPERS
  // ============================================

  /// Broadcast un événement à tous les clients d'un rôle donné
  int broadcastToRole(const String& role, const String& message);

  /// Info générale sur les clients connectés
  String getClientsInfoJson();

private:
  ClientInfo _clients[MAX_CLIENTS + 1]; // Index 0 non utilisé (clientNum commence à 0)

  // Buffer pour la dernière config
  String _lastConfigJson;
  unsigned long _lastConfigTimestamp;
  bool _hasConfig;

  // Cleanup périodique
  unsigned long _lastCleanupTime;
  void _checkConfigExpiry();
};

// ============================================
// CALLBACK TYPE pour envoi WebSocket
// ============================================
typedef void (*SendToClientFn)(uint8_t clientNum, String& message);

extern SendToClientFn g_sendToClient;  // Assigné par websocket_manager

#endif