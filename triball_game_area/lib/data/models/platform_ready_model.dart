// lib/data/models/platform_ready_model.dart

/// Message envoyé par l'ESP32 lors de la connexion initiale
class PlatformReadyModel {
  final String firmware;
  final int sensorsCount;
  final int ledsCount;
  final DateTime receivedAt;

  PlatformReadyModel({
    required this.firmware,
    required this.sensorsCount,
    required this.ledsCount,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory PlatformReadyModel.fromJson(Map<String, dynamic> json) {
    return PlatformReadyModel(
      firmware: (json['firmware'] ?? 'unknown').toString(),
      sensorsCount: _toInt(json['sensors']),
      ledsCount: _toInt(json['leds']),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  String toString() =>
      'PlatformReady(firmware=$firmware, sensors=$sensorsCount, '
          'leds=$ledsCount)';
}