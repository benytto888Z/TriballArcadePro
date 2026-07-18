// lib/core/services/websocket_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../constants/ esp32_config.dart';

// ✅ Renommé pour éviter le conflit avec Flutter's ConnectionState
enum WsConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

extension WsConnectionStateX on WsConnectionState {
  String get label {
    switch (this) {
      case WsConnectionState.disconnected: return 'disconnected';
      case WsConnectionState.connecting:   return 'connecting';
      case WsConnectionState.connected:    return 'connected';
      case WsConnectionState.reconnecting: return 'reconnecting';
      case WsConnectionState.error:        return 'error';
    }
  }

  bool get isConnected    => this == WsConnectionState.connected;
  bool get isDisconnected => this == WsConnectionState.disconnected;
  bool get isConnecting   =>
      this == WsConnectionState.connecting ||
          this == WsConnectionState.reconnecting;
  bool get isError        => this == WsConnectionState.error;
}

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Timer? _noDataTimer;

  WsConnectionState connectionState = WsConnectionState.disconnected;
  int reconnectAttempts = 0;
  DateTime? lastMessageTime;
  bool _isDisposed = false;
  bool _isConnecting = false;

  // Callbacks
  void Function(String message)? onMessage;
  void Function(WsConnectionState state)? onStateChange;
  void Function(String error)? onError;

  Future<void> connect() async {
    if (_isDisposed) return;
    if (_isConnecting) {
      print('WS: Already connecting - skipping');
      return;
    }

    _isConnecting = true;
    _cleanup();
    _updateState(WsConnectionState.connecting);
    print('WS: Connecting to ${Esp32Config.wsUrl}');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(Esp32Config.wsUrl));
      await _channel!.ready.timeout(
        const Duration(seconds: Esp32Config.connectionTimeout),
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );

      _isConnecting = false;
      reconnectAttempts = 0;
      lastMessageTime = DateTime.now();
      _updateState(WsConnectionState.connected);
      print('WS: Connected ✅');

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleStreamError,
        onDone: _handleDone,
        cancelOnError: false,
      );
    } catch (e) {
      _isConnecting = false;
      _updateState(WsConnectionState.error);
      print('WS: Connection error: $e');
      onError?.call(e.toString());
      _scheduleReconnect();
    }
  }

  void send(String message) {
    if (_channel != null && connectionState == WsConnectionState.connected) {
      try {
        _channel!.sink.add(message);
        print('WS: Sent: $message');
      } catch (e) {
        print('WS: Send failed: $e');
        onError?.call('Send failed: $e');
      }
    } else {
      print('WS: Cannot send "$message" - Not connected');
    }
  }

  void sendJson(Map<String, dynamic> data) => send(jsonEncode(data));

  void disconnect() {
    print('WS: Disconnecting...');
    _cleanup();
    _updateState(WsConnectionState.disconnected);
  }

  void dispose() {
    _isDisposed = true;
    _cleanup();
    onMessage = null;
    onStateChange = null;
    onError = null;
    print('WS: Disposed');
  }

  // ============================================================
  //  PRIVATE
  // ============================================================
  void _handleMessage(dynamic message) {
    lastMessageTime = DateTime.now();
    String msg = message.toString();
    print('WS: Received: $msg');
    onMessage?.call(msg);
  }

  void _handleStreamError(dynamic error) {
    _isConnecting = false;
    print('WS: Stream error: $error');
    onError?.call(error.toString());
    _updateState(WsConnectionState.error);
    _scheduleReconnect();
  }

  void _handleDone() {
    _isConnecting = false;
    print('WS: Stream closed');
    _updateState(WsConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _cleanup() {
    _isConnecting = false;
    _pingTimer?.cancel();
    _pingTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _noDataTimer?.cancel();
    _noDataTimer = null;
    _subscription?.cancel();
    _subscription = null;
    if (_channel != null) {
      try {
        // ✅ CORRIGÉ : Utilise 1000 au lieu de status.goingAway (1001)
        _channel!.sink.close(1000);
      } catch (_) {}
      _channel = null;
    }
  }

  void _updateState(WsConnectionState newState) {
    connectionState = newState;
    onStateChange?.call(newState);
    print('WS: State -> ${newState.label}');
  }

  void _scheduleReconnect() {
    if (_isDisposed || _reconnectTimer != null) return;

    reconnectAttempts++;

    // Mode borne : ne jamais abandonner. Dès que le SoftAP ESP32 redevient
    // disponible, Game Area doit se reconnecter sans action humaine.
    final cappedAttempt = reconnectAttempts
        .clamp(1, Esp32Config.maxReconnectAttempts) as int;
    int delay = Esp32Config.reconnectDelay *
        (cappedAttempt > 3 ? 3 : cappedAttempt);
    print('WS: Reconnecting in $delay s (attempt $reconnectAttempts)');
    _updateState(WsConnectionState.reconnecting);
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      _reconnectTimer = null;
      connect();
    });
  }
}