class Esp32Config {
  // WiFi AP Settings (from ESP32 code)
  static const String wifiSSID     = 'amz_triball';
  static const String wifiPassword = '12345678';

  // WebSocket Settings
  static const String ip     = '192.168.4.1';
  static const int    wsPort = 81;
  static const String wsUrl  = 'ws://$ip:$wsPort/';

  // HTTP Settings (for testing/compatibility)
  static const int httpPort     = 80;
  static const String statusUrl = 'http://$ip/status';
  static const String pingUrl   = 'http://$ip/ping';

  // Connection Settings
  static const int connectionTimeout    = 10;   // seconds
  static const int reconnectDelay       = 3;    // seconds
  static const int maxReconnectAttempts = 100;
  static const int pingInterval         = 5;    // seconds


}